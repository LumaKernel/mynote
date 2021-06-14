## Elastic Cloud on Kubernetes

https://www.elastic.co/jp/downloads/elastic-cloud-kubernetes

```
kubectl apply -f https://download.elastic.co/downloads/eck/1.6.0/all-in-one.yaml
```

よわよわいんすたんすを立ち上げる。

```
cat <<EOF | tee es.yml
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: quickstart
spec:
  version: 7.13.1
  nodeSets:
  - name: default
    count: 1
    config:
      node.store.allow_mmap: false
EOF

kubectl apply -f -
```
