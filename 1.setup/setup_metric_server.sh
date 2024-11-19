helm repo add  metric-server https://kubernetes-sigs.github.io/metrics-server/
helm pull metric-server/metrics-server
tar -xvf metrics-server-*
helm install metric-server metrics-server -n kube-system