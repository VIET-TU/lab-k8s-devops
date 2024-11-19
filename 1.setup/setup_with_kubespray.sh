# addhost cả 3 server
192.168.254.111 k8s-master-1
192.168.254.112 k8s-master-2
192.168.254.113 k8s-master-3

#Tắt swaff
sudo swapoff -a
## Tắt vĩnh viễn
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# install ansible
apt update -y && apt upgrade -y
apt install ansible-core -y

# tạo ssh keygen
ssh-keygen -t rsa
ssh-copy-id 192.168.254.111
ssh-copy-id 192.168.254.112
ssh-copy-id 192.168.254.113

# clone source code kubespray với branch là release-2.24
git clone https://github.com/kubernetes-sigs/kubespray.git --branch release-2.24
cd kubespray/
cp -rfp inventory/sample inventory/mycluster


# Sửa file hosts.yaml
vi inventory/mycluster/hosts.ini
[all]
k8s-master-1 ansible_host=192.168.254.111  ip=192.168.254.111
k8s-master-2 ansible_host=192.168.254.112  ip=192.168.254.112
k8s-master-3 ansible_host=192.168.254.113  ip=192.168.254.113


[kube-master]
k8s-master-1
k8s-master-2
k8s-master-3

[kube-node]
k8s-master-1
k8s-master-2
k8s-master-3

[etcd]
k8s-master-1

[k8s-cluster:children]
kube-master
kube-node

[calico-rr]

[vault]
k8s-master-1
k8s-master-2
k8s-master-3

# Run
ansible-playbook -i inventory/mycluster/hosts.ini  --become --become-user=root cluster.yml
## Nếu error thì reset
ansible-playbook -i inventory/mycluster/hosts.ini  --become --become-user=root reset.yml


# confige lại cordns
kubectl edit configmap coredns -n kube-system
forward . 8.8.8.8 8.8.4.4 {}

kubectl delete pod  coredns-555ddbcdc6-59p52 -n kube-system
kubectl delete pod  coredns-57d8cf4855-kvjm6 -n kube-system
kubectl delete pod  coredns-57d8cf4855-x267p -n kube-system


# Cài lại cicalo
## Xóa các DaemonSet và Pod của Calico:
kubectl delete -n kube-system daemonset calico-node
kubectl delete -n kube-system deployment calico-kube-controllers

##Xóa Các CRD
kubectl delete crd felixconfigurations.crd.projectcalico.org
kubectl delete crd bgppeers.crd.projectcalico.org
kubectl delete crd blockaffinities.crd.projectcalico.org
kubectl delete crd clusterinformations.crd.projectcalico.org
kubectl delete crd globalnetworkpolicies.crd.projectcalico.org
kubectl delete crd globalnetworksets.crd.projectcalico.org
kubectl delete crd hostendpoints.crd.projectcalico.org
kubectl delete crd ipamblocks.crd.projectcalico.org
kubectl delete crd ipamconfigs.crd.projectcalico.org
kubectl delete crd ipamhandles.crd.projectcalico.org
kubectl delete crd ippools.crd.projectcalico.org
kubectl delete crd kubecontrollersconfigurations.crd.projectcalico.org
kubectl delete crd networkpolicies.crd.projectcalico.org
kubectl delete crd networksets.crd.projectcalico.org

## Xóa configmap
kubectl delete -n kube-system service calico-typha
kubectl delete -n kube-system configmap calico-config

## Tải xuống calicoctl
curl -O -L https://github.com/projectcalico/calico/releases/download/v3.27.3/calicoctl-linux-amd64
chmod +x calicoctl-linux-amd64
sudo mv calicoctl-linux-amd64 /usr/local/bin/calicoctl

## Áp dụng cấu hình
curl -O -L https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml | kubectl apply -f calico.yaml



