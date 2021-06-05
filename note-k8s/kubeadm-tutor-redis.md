## redis


以下をやる

https://kubernetes.io/docs/tutorials/configuration/configure-redis-using-configmap/

## config map

```
cat <<EOF >./example-redis-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-redis-config
data:
  redis-config: ""
EOF

kubectl apply -f example-redis-config.yaml

work@master0:~/work$ kubectl get cm
NAME                   DATA   AGE
example-redis-config   1      30s
kube-root-ca.crt       1      31h
```

ok

## redis pod

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/pods/config/redis-pod.yaml

work@master0:~/work$ kubectl get po
NAME                                   READY   STATUS        RESTARTS   AGE
redis                                  1/1     Running       0          7m8s

work@master0:~/work$ kubectl exec -it po/redis -- /bin/bash
root@redis:/data# ls -l /redis-master/redis.conf
lrwxrwxrwx 1 root root 17 May 30 12:20 /redis-master/redis.conf -> ..data/redis.conf
root@redis:/data# cat /redis-master/redis.conf
root@redis:/data# exit


work@master0:~/work$ kubectl describe configmap/example-redis-config
Name:         example-redis-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
redis-config:
----

Events:  <none>
```

この `redis-config:` が空文字入っているのは、参照されると空文字初期化される的な仕組みとか思ってたら普通に最初の初期化で書いてた


```
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-redis-config
data:
  redis-config: |
    maxmemory 2mb
    maxmemory-policy allkeys-lru

# に編集して、

kubectl apply -f example-redis-config.yaml


work@master0:~/work$ kubectl describe configmap/example-redis-config
Name:         example-redis-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
redis-config:
----
maxmemory 2mb
maxmemory-policy allkeys-lru

Events:  <none>
```

あとは pod を消して作り直せばよい。
変えただけではファイル内容自体も特に変わっていなかった。




