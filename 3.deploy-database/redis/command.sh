# Tạo folder wokrer
sudo mkdir /database/redis
sudo chown -R nobody:nogroup /database/
sudo chmod -R 777 /database

# create namespace
kubectl create ns architecture

# Create file cấu hình
vi values.yaml

## Begin values.yaml
architecture: replication

auth:
  enabled: true # áp dụng
  password: "viettu"

master:
  persistence:
    enabled: true
    existingClaim: redis-pvc
    size: 3Gi

replica:
  replicaCount: 3
  persistence:
    enabled: true
    existingClaim: redis-pvc
    size: 3Gi

sentinel: # fail over
  enabled: true
  replicas: 3
## End values.yaml


# Trên khai redis with helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install redis-sentinel bitnami/redis --values values.yaml --namespace architecture

