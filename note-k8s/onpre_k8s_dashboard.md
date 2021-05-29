# dashboard

をおいて ssh トンネルでアクセスをしてみる。

```
work@master0:~$ kubectl get namespace
NAME              STATUS   AGE
default           Active   5h29m
elastic-system    Active   4h26m
kube-node-lease   Active   5h29m
kube-public       Active   5h29m
kube-system       Active   5h29m

work@master0:~$ kubectl get serviceaccount
NAME      SECRETS   AGE
default   1         5h30m

work@master0:~$ kubectl get configmap
NAME               DATA   AGE
kube-root-ca.crt   1      5h31m

work@master0:~$ kubectl get secret
NAME                  TYPE                                  DATA   AGE
default-token-czdvx   kubernetes.io/service-account-token   3      5h31m

work@master0:~$ kubectl get role
No resources found in default namespace.

work@master0:~$ kubectl get clusterrole
NAME                                                                   CREATED AT
admin                                                                  2021-05-29T05:15:13Z
cluster-admin                                                          2021-05-29T05:15:13Z
edit                                                                   2021-05-29T05:15:13Z
elastic-operator                                                       2021-05-29T06:17:45Z
elastic-operator-edit                                                  2021-05-29T06:17:45Z
elastic-operator-view                                                  2021-05-29T06:17:45Z
flannel                                                                2021-05-29T05:15:15Z
kubeadm:get-nodes                                                      2021-05-29T05:15:14Z
system:aggregate-to-admin                                              2021-05-29T05:15:13Z
(...)

work@master0:~$ kubectl get rolebinding
No resources found in default namespace.
```

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml

namespace/kubernetes-dashboard created
serviceaccount/kubernetes-dashboard created
service/kubernetes-dashboard created
secret/kubernetes-dashboard-certs created
secret/kubernetes-dashboard-csrf created
secret/kubernetes-dashboard-key-holder created
configmap/kubernetes-dashboard-settings created
role.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
deployment.apps/kubernetes-dashboard created
service/dashboard-metrics-scraper created
deployment.apps/dashboard-metrics-scraper created
```

```
work@master0:~$ kubectl get serviceaccount --namespace=kubernetes-dashboard
NAME                   SECRETS   AGE
default                1         72s
kubernetes-dashboard   1         72s

work@master0:~$ kubectl get pods --namespace=kubernetes-dashboard -owide
NAME                                         READY   STATUS    RESTARTS   AGE     IP            NODE      NOMINATED NODE   READINESS GATES
dashboard-metrics-scraper-856586f554-md5l2   1/1     Running   0          6m40s   10.244.4.10   worker0   <none>           <none>
kubernetes-dashboard-78c79f97b4-mbtr8        1/1     Running   0          6m40s   10.244.4.11   worker0   <none>           <none>
```

ok!

## ssh tunnel

とりあえず WF は戸締まり。

(ちょっと大変だった)

```
# on master
kubectl proxy

# on local
ssh -i ~/.ssh/id_rsa_vultr -L 8888:localhost:8001 work@$MASTER

# local のブラウザから
http://localhost:8888/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/.
```

```
work@master0:~$ kubectl get ServiceAccount --namespace=kubernetes-dashboard
NAME                   SECRETS   AGE
default                1         3h28m
kubernetes-dashboard   1         3h28m


# そのままだと、何も表示されずうごかなかったから下記を追加
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-admin-kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
EOF

ssh -i ~/.ssh/id_rsa_vultr work@$MASTER 'kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/kubernetes-dashboard -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"' | win32yank.exe -i
```

ok!
