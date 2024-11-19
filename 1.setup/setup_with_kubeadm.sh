sudo apt update -y && sudo apt upgrade -y

# - Tạo user devops và chuyển sang user devops
adduser devops
usermod -aG sudo devops
su devops
cd /home/devops


# Tắt swap

sudo swapoff -a
sudo sed -i '/swap.img/s/^/#/' /etc/fstab   

# Cấu hình module kernel

sudo tee /etc/modules-load.d/containerd.conf <<EOF
> overlay
> br_netfilter
EOF

# Tải module kernel

sudo modprobe overlay
sudo modprobe br_netfilter

# Cấu hình hệ thống mạng

echo "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee -a /etc/sysctl.d/kubernetes.conf
echo "net.bridge.bridge-nf-call-iptables = 1" | sudo tee -a /etc/sysctl.d/kubernetes.conf
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/kubernetes.con

# Áp dụng cấu hình sysctl
sudo sysctl --system

# Cài đặt các gói cần thiết và thêm kho Docker
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Cài đặt containerd
sudo apt update -y
sudo apt install -y containerd.io

# Cấu hình containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.

# Khởi động containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
systemctl status containerd

# Thêm kho lưu trữ Kubernetes (để cụm k8s hoạt được phài cài 3 thành phần kubelet, kubeadm, kubectl)
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Cài đặt các gói Kubernetes
sudo apt update -y
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


# Setup với 1 master và 2 worker
## Server master
sudo kubeadm init
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config



## 2 Server worker
kubeadm join 192.168.254.111:6443 --token 4mhb4o.sr1fuc9p85u3m9ri --discovery-token-ca-cert-hash sha256:9b29c40eb885b61112fd7afe54441a63bb08e5b6f6b39aafcf04345a2aa53519

# Để cụm k8s hoạt động ==> thêm network ở đây là calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

# Reset cụm và khởi tạo lại từ đầu
## Trên cả 3 server
sudo kubeadm reset -f
sudo rm -rf /var/lib/etcd
sudo rm -rf /etc/kubernetes/manifests/*

## cụm 3 master đồng thời 3 worker
sudo kubeadm init --control-plane-endpoint "192.168.254.111:6443" --upload-certs
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Join master
 sudo kubeadm join 192.168.254.111:6443 --token tyfe4v.0pifzw16yeqikpsm \
        --discovery-token-ca-cert-hash sha256:df6e6a8f5c42a17503b8fe4ba63c74ec6d0915bd726fff709b58129f9459fe69 \
        --control-plane --certificate-key f16830dd96ee74bf604bf55c460ccb381a217539aa468d4acea64bf9435c9997

# Giúp node master có thể được schedule như node woker
kubectl taint nodes k8s-master-1 node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint nodes k8s-master-2 node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint nodes k8s-master-3 node-role.kubernetes.io/control-plane:NoSchedule-