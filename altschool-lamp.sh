#!/bin/bash

set -e

vagrant ssh master <<EOF
    #add user named altschool to sudo group
    sudo useradd -m -G sudo altschool -s /bin/bash 
    #add password for altschool user
    echo -e "rexy1\nrexy1\n" | sudo passwd altschool 
    #add altschool user to root group
    sudo usermod -aG root altschool
    sudo useradd -ou 0 -g 0 altschool
    #generate ssh keys for the altschool user
    sudo -u altschool ssh-keygen -t rsa -b 4096 -f /home/altschool/.ssh/id_rsa -N "" -y
    #copy the generated public key to the master machine and into a file called altschoolkey
    sudo cp /home/altschool/.ssh/id_rsa.pub altschoolkey
    #generate ssh keys for the vagrant master user
    sudo ssh-keygen -t rsa -b 4096 -f /home/vagrant/.ssh/id_rsa -N ""
    #add the public key for the vagrant master user into a file called authorized_keys on the slave machine
    sudo cat /home/vagrant/.ssh/id_rsa.pub | sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@192.168.1.10 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
    #add the public key for the altschool user into a file called authorized_keys on the slave machine
    sudo cat ~/altschoolkey | sshpass -p "vagrant" ssh vagrant@192.168.1.10 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
    #password provided because the sudo command is used as the altschool user
    sshpass -p "rexy1" sudo -u altschool mkdir -p /mnt/altschool/slave
    sshpass -p "rexy1" sudo -u altschool scp -r /mnt/* vagrant@192.168.1.10:/home/vagrant/mnt
    #store running processes in the file path /home/vagrant/running_processes
    sudo ps aux > /home/vagrant/running_processes
    exit
EOF


vagrant ssh master <<EOF

echo -e "\n\nUpdating Apt Packages and upgrading latest patches\n"
sudo apt update -y

sudo apt install apache2 -y

echo -e "\n\nAdding firewall rule to Apache\n"
sudo ufw allow in "Apache"

sudo ufw status

echo -e "\n\nInstalling MySQL\n"
sudo apt install mysql-server -y

echo -e "\n\nPermissions for /var/www\n"
sudo chown -R www-data:www-data /var/www
echo -e "\n\n Permissions have been set\n"

sudo apt install php libapache2-mod-php php-mysql -y

echo -e "\n\nEnabling Modules\n"
sudo a2enmod rewrite
sudo phpenmod mcrypt

#use the steam editor 'search and replace' function to edit the /etc/apache2/mods-enabled/dir.conf file
sudo sed -i 's/DirectoryIndex index.html index.cgi index.pl index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf

echo -e "\n\nRestarting Apache\n"
sudo systemctl reload apache2

echo -e "\n\nLAMP Installation Completed"

exit 0

EOF

vagrant ssh slave_1 <<EOF

echo -e "\n\nUpdating Apt Packages and upgrading latest patches\n"
sudo apt update -y

sudo apt install apache2 -y

echo -e "\n\nAdding firewall rule to Apache\n"
sudo ufw allow in "Apache"

sudo ufw status

echo -e "\n\nInstalling MySQL\n"
sudo apt install mysql-server -y

echo -e "\n\nPermissions for /var/www\n"
sudo chown -R www-data:www-data /var/www
echo -e "\n\n Permissions have been set\n"

sudo apt install php libapache2-mod-php php-mysql -y

echo -e "\n\nEnabling Modules\n"
sudo a2enmod rewrite
sudo phpenmod mcrypt

sudo sed -i 's/DirectoryIndex index.html index.cgi index.pl index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf

echo -e "\n\nRestarting Apache\n"
sudo systemctl reload apache2

echo -e "\n\nLAMP Installation Completed"

exit 0

EOF
   


