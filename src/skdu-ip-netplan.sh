#!/bin/bash
clear
# Creates a backup
echo -e "\e[93m WARNING \e[0m, you will change the ip address of your server. Make sure that you have a physical access to him. TAP CTRL C for cancel the action"
if [ -d "/etc/netplan/backup" ];then
echo ""
# echo "Le dossier /etc/netplan/backup est déjà présent sur le système";
else
mkdir /etc/netplan/backup
echo "/etc/netplan/backup has been created ! "
fi
locateNetplan=`find /etc/netplan/ -name "*.yaml" | cut -c14-`
cp /etc/netplan/$locateNetplan /etc/netplan/backup/netplan_`date +%Y%m%d%H%M`
# Changes dhcp from 'yes' to 'no'
# sed -i "s/dhcp4: yes/dhcp4: no/g" $locateNetplan
# Retrieves the NIC information
nic=`ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}' | cut -c2- | head -1`
# echo $nic:
# Ask for input on network configuration
read -p "Configure the network with DHCP ? (O/n) : " dhcp
dhcp=${dhcp:-o}
if [ $dhcp = 'O' ] || [ $dhcp = 'o' ]; then
cat > /etc/netplan/$locateNetplan << EOF
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    $nic:
      dhcp4: yes
EOF

else
read -p "Enter the static IP in CIDR notation (ex : 192.168.0.10/24) : " staticip 
read -p "Enter the IP of your gateway : " gatewayip
read -p "Enter the first dns ip : " dns1
read -p "enter the second dns ip : " dns2
cat > /etc/netplan/$locateNetplan << EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $nic:
      dhcp4: no
      addresses:
        - $staticip
      gateway4: $gatewayip
      nameservers:
          addresses: [$dns1, $dns2]
EOF
cat > /etc/resolv.conf << EOF
domain localdomain
search localdomain
nameserver $dns1
nameserver $dns2
EOF
fi
sudo netplan apply
echo -e "\e[92m Your ip address has been changed ! (with netplan daemon) \e[0m"
# echo -e "\e[92m Reboot your computer to apply definitly the modification \e[0m"
echo -e "Press Enter to continue" 
read
clear
