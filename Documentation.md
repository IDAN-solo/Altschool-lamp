This repo contains a bash script that orchestrates the automated deployment 
of two Vagrant-based Ubuntu systems, designated as 'Master' and 'Slave', with an integrated LAMP stack on both systems.

Prerequisites:
-Vagrant 
-Virtualbox(Provider)

Vm configuration (vagrant.sh)
-The machines are configured by editing the Vagrantfile. The master vm is configured to have a hostname: master, box: ubuntu/focal64 and a constant ip address of 192.168.1.11
-The slave vm is configured to have a hostname: slave_1, box: ubuntu/focal64 and a constant ip of 192.168.1.10
-Both master and slave vms are provisioned using an inline shell to update and upgrade, install ssh pass(which enables password authentication), restart the sshd service to apply changes made and install a dns.
-Using the search and replace function of the stream editor I enabled ssh password authentication on the slave machine to prompt an external user to enter a password during an attempt to login.
-Both machines use Virtualbox as a provider with a memory of 1024mb and 2 cpus allocated

altschool-lamp.sh configuration:
-This script creates a user 'altschool' and adds the altschool user to the sudo group.
-Then it generates ssh keys for the altschool user and copies the public key to a file named altschoolkey on the master machine.
-Next, it adds the public key for the altschool user into a file called authorized_keys on the slave machine(This allows the altschool to ssh into the slave machine without a password).
-It also copies a file named "/mnt" from the master to the slave machine using the altschool user on the master machine, and stores the currently running processes in the file path /home/vagrant/running_processes on the master node.
-Lastly, the script installs an AMP(Apache, My SQL and PHP) stack on the master and slave machines.