
# Install helm
wget https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz
tar xvf helm-v3.16.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/bin/

# Install ingress controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm pull ingress-nginx/ingress-nginx
tar -xzf ingress-nginx-4.11.3.tgz
vi ingress-nginx/values.yaml
>> Sửa type: LoadBalancing => type: NodePort
>> Sửa nodePort http: "" => http: "30080"
>> Sửa nodePort https: "" => https: "30443"
kubectl create ns ingress-nginx
helm -n ingress-nginx install ingress-nginx -f ingress-nginx/values.yaml ingress-nginx


# Cấu hình nginx server Load balancer
vi /etc/nginx/sites-available/default 
vi /etc/nginx/conf.d/ingress.conf

##
upstream my_servers {
    server 192.168.254.111:30080;
    server 192.168.254.112:30080;
    server 192.168.254.113:30080;
}

server {
    listen 80;

    location / {
        proxy_pass http://my_servers;
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
##
nginx -t
systemctl restart nginx

