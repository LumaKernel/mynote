

host1
45.32.40.71
10.25.112.3/20
5a:00:03:5b:e5:a9

host2
45.76.199.216
10.25.112.4/20

host3
45.63.126.181
10.25.112.5/20
5a:00:03:5b:e5:ab

```
network:
  version: 2
  renderer: networkd
  ethernets:
    ens7:
      match:
        macaddress: 5a:00:03:5b:e5:ab
      mtu: 1450
      dhcp4: no
      addresses: [10.25.112.5/20]
```



```
# ssh root@{}
{
useradd --home-dir /home/work --shell /bin/bash --create-home work
usermod -aG sudo work
sed -i -e 's/^PermitRootLogin\s.*$/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i -e 's/^\s*#\?\s*PasswordAuthentication\s.*$/PasswordAuthentication no/g' /etc/ssh/sshd_config
sudo -u work mkdir -p /home/work/.ssh
cp /root/.ssh/authorized_keys /home/work/.ssh/authorized_keys
chown -R work:work /home/work
echo "work    ALL=NOPASSWD: ALL" >> /etc/sudoers
service ssh reload
exit
}

# ssh work@{}

{
## initialize
sudo apt-get update

## install network tools
sudo apt-get install -y net-tools ifstat nmap
}



wget -q --show-progress --https-only --timestamping \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssl \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssljson
cfssl --version
cfssljson --version

wget https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

## CA

{

cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

}



for instance in host1 host2 host3; do
cat > ${instance}-csr.json <<EOF
{
  "CN": "system:node:${instance}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF
done

# cfssl gencert \
#   -ca=ca.pem \
#   -ca-key=ca-key.pem \
#   -config=ca-config.json \
#   -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
#   -profile=kubernetes \
#   ${instance}-csr.json | cfssljson -bare ${instance}

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=host1,45.32.40.71,10.25.112.3 \
  -profile=kubernetes \
  host1-csr.json | cfssljson -bare host1

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=host1,45.76.199.216,10.25.112.4 \
  -profile=kubernetes \
  host2-csr.json | cfssljson -bare host2

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=host1,45.63.126.181,10.25.112.5 \
  -profile=kubernetes \
  host3-csr.json | cfssljson -bare host3


KUBERNETES_PUBLIC_ADDRESS=45.32.40.71,45.76.199.216,45.63.126.181

KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

{
cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes

}


for instance in host1 host2 host3; do
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.pem \
    --client-key=${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done

```
