TODO: 書いてる途中

## Create admin account

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

kubectl apply -f ./admin-account.yml
kubectl get secrets "$(kubectl get sa/admin -o go-template='{{ (index .secrets 0).name }}')" -o go-template='{{ .data.token | base64decode }}' && echo
```

## Kubeapps

```
cat <<'EOF' > kubeapps-values.yml
apprepository:
  initialRepos:
    - name: bitnami
      url: https://charts.bitnami.com/bitnami
    - name: elastic
      url: https://helm.elastic.co
    - name: dashboard
      url: https://kubernetes.github.io/dashboard/
    - name: grafana
      url: https://grafana.github.io/helm-charts
    - name: minio
      url: https://operator.min.io/
    - name: fluent
      url: https://fluent.github.io/helm-charts
EOF

kubectl create namespace kubeapps
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install kubeapps --namespace -f ./kubeapps-values.yml kubeapps bitnami/kubeapps


# Upgrade


export POSTGRESQL_PASSWORD=$(kubectl get secret --namespace "kubeapps" kubeapps-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)
helm upgrade -n kubeapps -f ./kubeapps-values.yml --set postgresql.postgresqlPassword=$POSTGRESQL_PASSWORD kubeapps bitnami/kubeapps

```

## Dashboard

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
```

## Elastic system

```
kubectl apply -f https://download.elastic.co/downloads/eck/1.6.0/all-in-one.yaml
```

## Elastic search

## TODO: grafana helm

## TODO: minio helm

## TODO: fluentd
