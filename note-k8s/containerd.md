

## docker

```
sudo apt-get install -y docker.io
```



## containerd

```
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

CONTAINERD_VERSION="1.5.0"
wget "https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz"
tar xvf "containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz"
sudo cp ./bin/containerd /usr/local/bin
rm -f "containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz"
rm -rf bin

wget "https://github.com/containerd/containerd/archive/v${CONTAINERD_VERSION}.zip"
unzip "v${CONTAINERD_VERSION}.zip"
sudo cp "containerd-${CONTAINERD_VERSION}/containerd.service" /etc/systemd/system
rm -f "v${CONTAINERD_VERSION}.zip"
rm -rf "containerd-${CONTAINERD_VERSION}"
sudo chmod 755 /etc/systemd/system/containerd.service

containerd config default \
  | sed \
  -e 's/SystemdCgroup\s\+=\s\+false/SystemdCgroup = true/' \
  | sudo tee /etc/containerd/config.toml

sudo systemctl enable containerd.service
sudo systemctl start containerd.service
```
