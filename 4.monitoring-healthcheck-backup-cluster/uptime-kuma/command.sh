# Create foler worker
sudo mkdir -o /database/monitoring
sudo chown -R nobody:nogroup /database
sudo chmod -R 777 /data

# Add repo
helm repo add uptime-kuma https://helm.irsigler.cloud
vi values.yaml

## 
volume:
  enabled: true
  accessMode: ReadWriteOnce
  existingClaim: "uptime-kuma-pvc"
##

# Install
helm repo update
helm install devopseduvn-uptime uptime-kuma/uptime-kuma -n monitoring -f values.yaml

