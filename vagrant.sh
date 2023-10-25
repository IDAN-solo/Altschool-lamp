#!/bin/bash

#Initialize the vagrant machines in a specified directory
if [["pwd" == "~/Documents/vms1"]]; then
vagrant init ubuntu/focal64
else 
echo "creating vms1 folder to initialize vm"
mkdir -p ~/Documents/vms1
cd ~/Documents/vms1
vagrant init ubuntu/focal64
fi

#Configure the Vagrantfile to provision the master and slave machines
#Configure the Vagrantfile to provision the master vm
cat <<EOF > Vagrantfile
Vagrant.configure("2") do |config|

  config.vm.define "master" do |master|

    master.vm.hostname = "master"
    master.vm.box = "ubuntu/focal64"
    master.vm.network "private_network", ip: "192.168.1.11"

    master.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y avahi-daemon libnss-mdns
    sudo apt install sshpass -y
    echo "Hello from the master vm"
    SHELL
  end

#Configure the Vagrantfile to provision the slave vm

    config.vm.define "slave_1" do |slave_1|

    slave_1.vm.hostname = "slave-1"
    slave_1.vm.box = "ubuntu/focal64"
    slave_1.vm.network "private_network", ip: "192.168.1.10"

    slave_1.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt install sshpass -y
    sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sudo systemctl restart sshd
    sudo apt-get install -y avahi-daemon libnss-mdns
    echo "Hello from the slave vm"
    SHELL
  end

    config.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = "2"
    end
end
EOF

#Start the master and slave vms
vagrant up

#Run the altschool-lamp script after the machines have been started
source altschool-lamp.sh 


  

