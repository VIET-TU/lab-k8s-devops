# insall on nfs server
sudo apt install nfs-server -y
sudo mkdir /data
sudo chown -R nobody:nogroup /data
sudo chmod -R 777 /data
sudo vi /etc/exports
/database *(rw,sync,no_subtree_check,no_root_squash)
sudo exportfs -rav
sudo systemctl restart nfs-server

# insall on client
sudo apt install nfs-common -y


