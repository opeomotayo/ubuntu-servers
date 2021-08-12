Vagrant.configure("2") do |config|
    config.vm.provision "shell", inline: <<-SHELL
        apt-get update -y
        echo "172.22.22.10  master-node" >> /etc/hosts
        echo "172.22.22.11  worker-node01" >> /etc/hosts
        echo "172.22.22.12  worker-node02" >> /etc/hosts
    SHELL
    
    config.vm.define "master" do |master|
      master.vm.box = "bento/ubuntu-21.04"
      master.vm.hostname = "master-node"
      master.vm.network "private_network", ip: "172.22.22.10"
      # master.vm.provision :docker
      master.vm.provision :docker_compose, run: "always" #vagrant plugin install vagrant-docker-compose
      master.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/id_rsa.pub"
      master.vm.provision "file", source: "~/.ssh/id_rsa", destination: "~/.ssh/id_rsa"
      id_rsa_pub = File.read("#{Dir.home}/.ssh/id_rsa.pub")
      master.vm.provision "copy ssh public key", type: "shell",
      inline: "echo \"#{id_rsa_pub}\" >> /home/vagrant/.ssh/authorized_keys"
      master.vm.provider "virtualbox" do |vb|
          vb.memory = 8192
          vb.cpus = 3
      end
      master.vm.provision "shell", path: "scripts/common.sh"
      master.vm.provision "shell", path: "scripts/master.sh"
    end

    (1..1).each do |i|
  
    config.vm.define "node0#{i}" do |node|
      node.vm.box = "bento/ubuntu-21.04"
      node.vm.hostname = "worker-node0#{i}"
      node.vm.network "private_network", ip: "172.22.22.1#{i}"
      # node.vm.provision :docker
      node.vm.provision :docker_compose, run: "always" #vagrant plugin install vagrant-docker-compose
      # node.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/id_rsa.pub"
      node.vm.provider "virtualbox" do |vb|
          vb.memory = 8192
          vb.cpus = 3
      end
      id_rsa_pub = File.read("#{Dir.home}/.ssh/id_rsa.pub")
      node.vm.provision "copy ssh public key", type: "shell",
      inline: "echo \"#{id_rsa_pub}\" >> /home/vagrant/.ssh/authorized_keys"
      # node.vm.provision "shell", inline: <<-SHELL
      #   cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
      # SHELL
      node.vm.provision "shell", path: "scripts/common.sh"
      node.vm.provision "shell", path: "scripts/node.sh"
    end
    
    end
  end