Vultr で kubeadm を使ってオンプレ。

2021/05/29
なんとかできた

containerd ではなかなかうまく行かないので docker ためしたら一発でいけた。

とりあえずチュートリアル

```
kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
# kubectl delete deployment kubernetes-bootcamp
watch kubectl get deployments
export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
```

proxy したりするアクセスがうまくいかなかった。

試した
  - FW消してみる -> 効果なし
  - worker 消してみる -> deploy 終わらない。
    - control-plane にはつくられないのかな？
    - `kubectl taint nodes --all node-role.kubernetes.io/master-`
    - うごいた

もう一回試す。

`kubectl exec -it $POD_NAME -- /bin/bash` で調べたら 8080 で受け付けている。

`kubectl exec -it $POD_NAME -- curl localhost:8080` は動くね。


```
work@master0:~$ curl http://localhost:8001/api/v1/namespaces/default/pods/$POD_NAME/proxy/
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {

  },
  "status": "Failure",
  "message": "error trying to reach service: dial tcp 10.244.0.5:80: connect: connection refused",
  "reason": "ServiceUnavailable",
  "code": 503
}
```

```
root@kubernetes-bootcamp-57978f5f5d-5mksp:/# ifconfig
eth0      Link encap:Ethernet  HWaddr 8e:84:9b:8c:ec:15
          inet addr:10.244.0.5  Bcast:10.244.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1450  Metric:1
          RX packets:5738 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3813 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:31125636 (29.6 MiB)  TX bytes:263572 (257.3 KiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:2151 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2151 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:91304 (89.1 KiB)  TX bytes:91304 (89.1 KiB)
```

`10.244.0.5` はあってるけど見ている port が違いそう。

公式チュートリアルでも exec して調べたけれど、 8080 は受けていて、80 は使われていなかったのでバージョン違いとかかなぁ。

```
kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1 --port 8080
```

でうまくいった。
なんか環境変数かなんかでデフォルト変えてるんかな。

`env` にはなかった。設定ファイルかな。探してみようと思ったけど、まいっか。

```
work@master0:~$ kubectl get deploy --output yaml | grep ports -C 4
        containers:
        - image: gcr.io/google-samples/kubernetes-bootcamp:v1
          imagePullPolicy: IfNotPresent
          name: kubernetes-bootcamp
          ports:
          - containerPort: 8080
            protocol: TCP
          resources: {}
          terminationMessagePath: /dev/termination-log
```

`edit` で頑張れば指定できそうだ。

## 設定ファイルとか

- `/etc/kubernetes/`: 色々ある
  - `manifest/`: 
  - `admin.conf`: `~/.kube/config` のもと

## expose

```
kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080
export NODE_PORT=$(kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}')
echo $NODE_PORT
32711
curl localhost:32711
# 帰ってくる

work@master0:~$ kubectl get service
NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes            ClusterIP   10.96.0.1       <none>        443/TCP          3h9m
kubernetes-bootcamp   NodePort    10.111.65.181   <none>        8080:32711/TCP   13m

curl 10.111.65.181:8080
# これも帰ってくる

curl ${PUBLIC_IP}:32711
# これも帰ってくる!
```

2番目のルーティングってどうなってるんだろう。


## scale

```
kubectl get rs  # replica set
kubectl scale deployments/kubernetes-bootcamp --replicas=4

# loadtest してみる
sudo apt-get install -y apache2-utils

```

```
work@master0:~$ kubectl get pods -o wide
NAME                                  READY   STATUS              RESTARTS   AGE    IP           NODE      NOMINATED NODE   READINESS GATES
kubernetes-bootcamp-fb5c67579-988zs   0/1     ContainerCreating   0          14m    <none>       worker0   <none>           <none>
kubernetes-bootcamp-fb5c67579-m62fg   1/1     Running             0          101m   10.244.0.7   master0   <none>           <none>
kubernetes-bootcamp-fb5c67579-nbg2r   0/1     ContainerCreating   0          14m    <none>       worker0   <none>           <none>
kubernetes-bootcamp-fb5c67579-x9pbg   0/1     ContainerCreating   0          14m    <none>       worker0   <none>           <none>
```

worker0 に pod 作るのに失敗していそうだ。


```
kubectl describe pods

(...)
Events:
  Type     Reason                  Age                    From               Message
  ----     ------                  ----                   ----               -------
  Normal   Scheduled               14m                    default-scheduler  Successfully assigned default/kubernetes-bootcamp-fb5c67579-x9pbg to worker0
  Warning  FailedCreatePodSandBox  14m                    kubelet            Failed to create pod sandbox: rpc error: code = Unknown desc = failed to set up sandbox container "35aad575f6f123c735fd99fe7915d18738ac63d70c2d1484b009cd2ed96d7565" network for pod "kubernetes-bootcamp-fb5c67579-x9pbg": networkPlugin cni failed to set up pod "kubernetes-bootcamp-fb5c67579-x9pbg_default" network: failed to set bridge addr: "cni0" already has an IP address different from 10.244.2.1/24
  Warning  FailedCreatePodSandBox  14m                    kubelet            Failed to create pod sandbox: rpc error: code = Unknown desc = failed to set up sandbox container "1c7fc9ff6d4e4b1b7b194442f004758efa5b4ba7575a9df03f6dbeca60de9ce1" network for pod "kubernetes-bootcamp-fb5c67579-x9pbg": networkPlugin cni failed to set up pod "kubernetes-bootcamp-fb5c67579-x9pbg_default" network: failed to set bridge
(...)
```


https://stackoverflow.com/questions/61373366/networkplugin-cni-failed-to-set-up-pod-xxxxx-network-failed-to-set-bridge-add

CNI 関連っぽいね。なんとなく 10.244.(here).1/24 が連番っぽくて、一回 worker を reset した際に CNI のリセットまでしなかったのが良くなかったんじゃないかなと予想。

なのでもう一回リセ

```
# on worker
sudo kubeadm reset --force
sudo systemctl stop kubelet
sudo systemctl stop docker
sudo rm -rf /var/lib/cni/
sudo rm -rf /var/lib/kubelet/*
sudo rm -rf /etc/cni/
sudo ifconfig cni0 down
sudo ifconfig flannel.1 down
sudo ifconfig docker0 down
# 追記
sudo ip link set cni0 down
sudo brctl delbr cni0

# on master
kubectl delete node worker0
```

ref: https://stackoverflow.com/a/61544151/5659342

(
関係ないが、join 時の digest 計算

```
openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -pubkey | openssl rsa -pubin -outform der | openssl dgst -sha256 -hex
```
)


だめだ

```
kubectl describe pods
(...)
  Warning  FailedCreatePodSandBox  3s                kubelet            Failed to create pod sandbox: rpc error: code = Unknown desc = failed to set up sandbox container "e455d4e3f9bfd02688705e11de76a3688d1f2cba9787c8ec047162c4828d70ac" network for pod "kubernetes-bootcamp-fb5c67579-sb47n": networkPlugin cni failed to set up pod "kubernetes-bootcamp-fb5c67579-sb47n_default" network: failed to set bridge addr: "cni0" already has an IP address different from 10.244.3.1/24
  Normal   SandboxChanged          2s (x9 over 21s)  kubelet            Pod sandbox changed, it will be killed and re-created.
  Warning  FailedCreatePodSandBox  0s                kubelet            (combined from similar events): Failed to create pod sandbox: rpc error: code = Unknown desc = failed to set up sandbox container "86fb4288b395fa93339a9e1065d3d42e0f1c786cb236d5976bb2bb93548685af" network for pod "kubernetes-bootcamp-fb5c67579-sb47n": networkPlugin cni failed to set up pod "kubernetes-bootcamp-fb5c67579-sb47n_default" network: failed to set bridge addr: "cni0" already has an IP address different from 10.244.3.1/24
```

多分リセット失敗したな。
下の二行を追記

```
work@worker0:~$ ifconfig cni0
cni0: error fetching interface information: Device not found
```

よさ

```
work@master0:~$ kubectl get pods -o wide
NAME                                  READY   STATUS    RESTARTS   AGE    IP           NODE      NOMINATED NODE   READINESS GATES
kubernetes-bootcamp-fb5c67579-m62fg   1/1     Running   0          137m   10.244.0.7   master0   <none>           <none>
kubernetes-bootcamp-fb5c67579-pz56t   1/1     Running   0          18s    10.244.4.3   worker0   <none>           <none>
kubernetes-bootcamp-fb5c67579-tbclr   1/1     Running   0          18s    10.244.4.2   worker0   <none>           <none>
kubernetes-bootcamp-fb5c67579-wzhjs   1/1     Running   0          18s    10.244.4.4   worker0   <none>           <none>
```

うまくいった！

```
work@master0:~$ curl localhost:$NODE_PORT
Hello Kubernetes bootcamp! | Running on: kubernetes-bootcamp-fb5c67579-pz56t | v=1
work@master0:~$ curl localhost:$NODE_PORT
Hello Kubernetes bootcamp! | Running on: kubernetes-bootcamp-fb5c67579-m62fg | v=1
work@master0:~$ curl localhost:$NODE_PORT
Hello Kubernetes bootcamp! | Running on: kubernetes-bootcamp-fb5c67579-pz56t | v=1
work@master0:~$ curl localhost:$NODE_PORT
Hello Kubernetes bootcamp! | Running on: kubernetes-bootcamp-fb5c67579-tbclr | v=1
work@master0:~$ curl localhost:$NODE_PORT
Hello Kubernetes bootcamp! | Running on: kubernetes-bootcamp-fb5c67579-wzhjs | v=1
work@master0:~$ curl localhost:$NODE_PORT
Hello Kubernetes bootcamp! | Running on: kubernetes-bootcamp-fb5c67579-pz56t | v=1
```


```
ab -n 10000 -c 100 http://localhost:$NODE_PORT/

Percentage of the requests served within a certain time (ms)
  50%     49
  66%     67
  75%     81
  80%     89
  90%    107
  95%    118
  98%    127
  99%    137
 100%    163 (longest request)

ab -n 100 -c 10 http://localhost:$NODE_PORT/

Percentage of the requests served within a certain time (ms)
  50%      7
  66%      9
  75%     11
  80%     11
  90%     14
  95%     16
  98%     18
  99%     20
 100%     20 (longest request)
```

ふむ！


```
ab -n 100 -c 10 (tf output -json host_v4_list | jq -r .master0):31388/


Percentage of the requests served within a certain time (ms)
  50%    100
  66%    111
  75%    114
  80%    115
  90%    119
  95%    131
  98%    137
  99%    137
 100%    137 (longest request)
```

一回大きい数でやったらレートリミットされてそうな雰囲気あった！
スケールダウンして試してみよう。

うーん。ためしてみたけど、あきらかに200を超えたあたりで制限かかっていて、うまく比較できない。

まあでも単発なら基本問題ない。


## Update

```
kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=jocatalin/kubernetes-bootcamp:v2
```

## admin account


```
cat <<'EOF' > admin-account.yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-cluster-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin
  namespace: default
EOF


kubectl get secrets "$(kubectl get sa/admin -o go-template='{{ (index .secrets 0).name }}')" -o go-template='{{ .data.token | base64decode }}' && echo
```

## dashboard

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
```

## curl

```
kubectl run --rm -it --restart=Never --image-pull-policy=IfNotPresent --image=docker.io/radial/busyboxplus:curl bb

kubectl run --rm -it --restart=Never --image-pull-policy=IfNotPresent --image=docker.io/library/ubuntu ubu
```

## crictl

```
sudo crictl -r unix:///var/run/crio/crio.sock images
```


## CRI-O

### 注意点

- `/etc/cni/net.d/10-crio...` などを自動で作るかもしれないが、消しておかないと flannel より優先されてしまう。
  - このとき、他のノードから Kube DNS などにアクセスできなくなってしまう
- image 名は `docker.io/` を 、docker hubの場合は prepend する必要がある。


## 再構築にかかる時間

destroy -> apply -> kubeadm init 完了

開始: Mon Jun  7 23:44:45 JST 2021
終了: Mon 07 Jun 2021 02:51:33 PM UTC

7分弱?


## IPV6対応

対応中に全然うまく行かず参照したページ一覧

- official k8s document
  - https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/dual-stack-support/
  - https://kubernetes.io/docs/concepts/services-networking/dual-stack/
  - https://kubernetes.io/docs/tasks/network/validate-dual-stack/
- calico
  - https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises
  - https://docs.projectcalico.org/networking/ipv6
  - https://www.projectcalico.org/enable-ipv6-on-kubernetes-with-project-calico/
  - https://www.projectcalico.org/dual-stack-operation-with-calico-on-kubernetes/
- va linux
  - https://valinux.hatenablog.com/entry/20200722
  - https://www.valinux.co.jp/technologylibrary/document/orchestration/kubernetes/
- others
  - https://medium.com/@elfakharany/how-to-enable-ipv6-on-kubernetes-aka-dual-stack-cluster-ac0fe294e4cf



トラブルシュート

- `kubeclt get node -o yaml | grep -i internalip -C 3` で ipv6 アドレスが表示されない
  - https://github.com/kubernetes/kubeadm/issues/203
  - `--node-ip=<ipv4>,<ipv6>` を kubelet の設定に食わせた。 `/etc/default/kubelet` かな。
  - `<ipv4>` の方は private ip (ens7)、 `<ipv6>` のほうは ens7 にはなかったのでとりあえず ens3 のものを。
  - ens7 は MTU が 1450 に設定しなければいけないことから暗号化されていると勝手に思っているがほんとか。
  - 
- ``


