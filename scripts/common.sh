#! /bin/bash

# Variable Declaration

KUBERNETES_VERSION="1.20.6-00"

# Enable ssh password authentication
echo "Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "Set root password"
echo -e "admin\nadmin" | passwd root >/dev/null 2>&1

# Set local user account
echo "Set up local user account"
useradd -m -s /bin/bash opeomotayo >/dev/null 2>&1
echo -e "admin\nadmin" | passwd opeomotayo >/dev/null 2>&1
echo "opeomotayo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Update bashrc file
echo "export TERM=xterm" >> /etc/bashrc

# disable swap 
sudo swapoff -a
# keeps the swaf off during reboot
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

sudo apt-get update -y
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

# Following configurations are recomended in the kubenetes documentation for Docker runtime. Please refer https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "Docker Runtime Configured Successfully"

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install -y kubelet=$KUBERNETES_VERSION kubectl=$KUBERNETES_VERSION kubeadm=$KUBERNETES_VERSION
sudo apt-mark hold kubelet kubeadm kubectl

#sonarqube memory requirement
# grep -qF 'vagrant - nofile 65536' /etc/security/limits.conf || echo 'vagrant - nofile 65536' >> /etc/security/limits.confecho vm.max_map_count=262144 > /etc/sysctl.d/vm_max_map_count.conf
# sysctl --system
