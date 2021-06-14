## Helm


```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm version
```


### Redis Cluster

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/redis-cluster

helm pull bitnami/redis-cluster
```

### Kubeapps

```
helm repo add bitnami https://charts.bitnami.com/bitnami
kubectl create namespace kubeapps
helm install kubeapps --namespace kubeapps bitnami/kubeapps
```
