#!/bin/bash

#Install everything needed (can be commented out)
sudo apt-get install -y figlet f2fs-tools bsdtar

PURPLE="\e[35m"
STOP="\e[0m"
printf "${PURPLE}"
figlet Arch ARM Installer
printf "${STOP}"

USER1=$USER
#sudo su root -c "$USER1"

#Ask sudo pw for later use
echo "$(tput setaf 3)Give your sudo password$(tput sgr 0)"
sudo echo "$(tput setaf 2)Thanks$(tput sgr 0)"


lsblk -d
printf "$(tput setaf 2)Choose your USB stick: $(tput sgr 0)"

read USB

USB=$(sed 's/[0-9]*//g' <<< $USB)


echo;sleep 1


#Ask user to choose the SD card (example: sda)
lsblk -d
printf "$(tput setaf 2)Choose your SD card: $(tput sgr 0)"

read SD

SD=$(sed 's/\p.*//' <<< $SD)

#sudo dd if=/dev/zero of=/dev/$SD status=progress

echo;sleep 1

#Check if SD partitions is mounted (unmount if mounted)
echo "$(tput setaf 3)checking if partitions are in use$(tput sgr 0)"
echo;sleep 1
if [ $(mount | grep -c /dev/$SD'p1') != 0 ]
then
        echo "$(tput setaf 3)unmounting first partition of SD card$(tput sgr 0)"
        sudo umount /dev/$SD'p1'
        echo "$(tput setaf 2)unmounted first partition of SD card$(tput sgr 0)"
else
        echo "$(tput setaf 2)first partition of SD card not mounted$(tput sgr 0)"
fi

echo;sleep 1

if [ $(mount | grep -c /dev/$SD'p2') != 0 ]
then
        echo "$(tput setaf 3)unmounting second partition of SD card$(tput sgr 0)"
        sudo umount /dev/$SD'p2'
        echo "$(tput setaf 2)unmounted second partition of SD card$(tput sgr 0)"
else

        echo "$(tput setaf 2)second partition of SD card not mounted$(tput sgr 0)"
fi

echo;sleep 1

if [ $(mount | grep -c /dev/$USB'1') != 0 ]
then
        echo "$(tput setaf 3)unmounting USB stick$(tput sgr 0)"
        sudo umount /dev/$USB'1'
        echo "$(tput setaf 2)unmounted USB stick$(tput sgr 0)"
else

        echo "$(tput setaf 2)USB stick not mounted$(tput sgr 0)"
fi

echo;sleep 1

#Creates first and second partition
(
sleep 2
echo o
sleep 2
echo n
echo p
echo 1
echo
echo +100M
echo t
echo c
echo n
echo p
echo 2
echo
echo
echo w
) | sudo fdisk /dev/$SD

sleep 1

echo "$(tput setaf 2)fdisk done$(tput sgr 0)"

echo
echo;sleep 1

sudo rm -fr /mnt/boot
sudo rm -fr /mnt/root
sudo rm -fr /mnt/usb

#Format partitions
#First partition
sleep 2
echo "$(tput setaf 3)formating first partition to vfat$(tput sgr 0)"
sudo mkfs.vfat /dev/$SD'p1'
echo "$(tput setaf 2)first partition formated to vfat$(tput sgr 0)"

echo

sleep 1

echo
#Second partition
echo "$(tput setaf 3)formating second partition to f2fs$(tput sgr 0)"
sudo mkfs.f2fs -f /dev/$SD'p2'
echo "$(tput setaf 2)second partition formated to f2fs$(tput sgr 0)"

echo
echo ;sleep 1

sudo rm -fr /mnt/boot
sudo rm -fr /mnt/root
sudo rm -fr /mnt/usb

sleep 1

#Make directories where partitions are mounted
echo "$(tput setaf 3)creating directories$(tput sgr 0)"
sudo mkdir /mnt/boot
sudo mkdir /mnt/root
sudo mkdir /mnt/usb
echo "$(tput setaf 2)directories created$(tput sgr 0)"
echo
echo ;sleep 1
#Mount partitions to directories
echo "$(tput setaf 3)mounting partitions to directories$(tput sgr 0)"
sudo mount /dev/$SD'p1' /mnt/boot
echo "$(tput setaf 2)first partition mounted$(tput sgr 0)"
sleep 1
sudo mount -t f2fs /dev/$SD'p2' /mnt/root
echo "$(tput setaf 2)second partition mounted$(tput sgr 0)"
sudo mount /dev/$USB'1' /mnt/usb
echo "$(tput setaf 2)usb mounted$(tput sgr 0)"

echo
echo
sudo rm -fr /mnt/boot/*
sudo rm -fr /mnt/root/*

sleep 2
#Download root filesystem
if 	ls ArchLinuxARM-rpi-2-latest.tar.gz 1> /dev/null 2>&1; then
	echo "$(tput setaf 2)filesystem already downloaded$(tput sgr 0)"
else
    	echo "$(tput setaf 2)downloading filesystem$(tput sgr 0)"
	sudo su root -c 'wget -P /home/xubuntu/pi/ http://archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz'
fi

echo

sleep 1
#Extract root filesystem
echo "$(tput setaf 3)extracting filesystem in$(tput sgr 0)"
sudo bsdtar -v -xpf /home/$USER/pi/ArchLinuxARM-rpi-2-latest.tar.gz -C /mnt/root
sudo bsdtar -v -xpf /home/xubuntu/pi/ArchLinuxARM-rpi-2-latest.tar.gz -C /mnt/root > /tmp/bsdtar12345
echo "$(tput setaf 1)3$(tput sgr 0)"
sleep 1
echo "$(tput setaf 3)2$(tput sgr 0)"
sleep 1
echo "$(tput setaf 2)1$(tput sgr 0)"
sleep 1
printf "${PURPLE}"
sudo su root -c 'bash /tmp/bsdtar12345'
printf "${STOP}"
echo "$(tput setaf 2)root filesystem extracted$(tput sgr 0)"

echo;sleep 1

echo "$(tput setaf 3)Disabling audit messages$(tput sgr 0)"
sudo su root -c "sed -i '$ s/$/ audit=0/' /mnt/root/boot/cmdline.txt"
echo "$(tput setaf 2)Audit messages disabled$(tput sgr 0)"

#sudo su root -c 'bash /home/linux/rename.sh'


sudo ls /mnt/usb/*.txt | sed -r 's/^.+\///' | sed 's/\..*//' | cat
printf "$(tput setaf 2)Choose your txt file: $(tput sgr 0)"
read TXT
echo "cp /mnt/usb/$TXT.txt /mnt/root/home/alarm/link" > /tmp/txtlink12345
sudo bash /tmp/txtlink12345
echo "$(tput setaf 2)Link and name copied$(tput sgr 0)"

echo;sleep 1

echo "$(tput setaf 3)syncing (can take up to 5 minutes)$(tput sgr 0)"
sudo su root -c 'sync'
echo "$(tput setaf 2)sync done$(tput sgr 0)"


echo

#Move boot files to the first partition
echo "$(tput setaf 3)moving boot files$(tput sgr 0)"
sudo su root -c 'mv /mnt/root/boot/* /mnt/boot'
echo "$(tput setaf 2)boot files moved$(tput sgr 0)"

#Increase /tmp size
sudo su root -c 'echo "tmpfs   /tmp         tmpfs   rw,nodev,nosuid,size=2G          0  0" >> /mnt/root/etc/fstab'

echo;sleep 1

#Copy scripts to pi
sudo su root -c 'cp /home/xubuntu/pi/ArchSetup.sh /mnt/root/home/alarm/ArchSetup.sh'
sudo su root -c 'cp /home/xubuntu/pi/issue /mnt/root/etc/issue'
sudo su root -c 'cp /home/xubuntu/pi/xorg.conf /mnt/root/home/alarm/xorg.conf'
sudo su root -c 'cp /home/xubuntu/pi/bp /mnt/root/home/alarm/.bash_profile'
sudo su root -c 'cp /home/xubuntu/pi/nettest.sh /mnt/root/home/alarm/nettest.sh'
sudo su root -c 'cp /home/xubuntu/pi/chromium_restart.sh /mnt/root/home/alarm/chromium_restart.sh'
sudo su root -c 'cp /home/xubuntu/pi/xinitrc /mnt/root/home/alarm/.xinitrc'
sudo su root -c 'cp /home/xubuntu/pi/timesyncd.conf /mnt/root/home/alarm/timesyncd.conf'
echo "$(tput setaf 2)Scripts copied to pi$(tput sgr 0)"
echo
echo;sleep 1

#Unmount partitions
echo "$(tput setaf 3)unmounting partitions$(tput sgr 0)"
echo;sleep 1
if [ $(mount | grep -c /mnt/boot) != 0 ]
then
        echo "$(tput setaf 3)unmounting /mnt/boot$(tput sgr 0)"
        sudo su root -c "umount /dev/$SD'p1'"
        echo "$(tput setaf 2)unmounted /mnt/boot$(tput sgr 0)"
else
        echo "$(tput setaf 1)ERROR$(tput sgr 0)"
        echo "$(tput setaf 1)partition already unmounted$(tput sgr 0)"
fi

echo;sleep 1

if [ $(mount | grep -c /mnt/root) != 0 ]
then
        echo "$(tput setaf 3)unmounting /mnt/root$(tput sgr 0)"
        sudo su root -c "umount /dev/$SD'p2'"
        echo "$(tput setaf 2)unmounted /mnt/root$(tput sgr 0)"
else
        echo "$(tput setaf 1)ERROR$(tput sgr 0)"
        echo "$(tput setaf 1)partition already unmounted$(tput sgr 0)"
fi

sleep 1

#sudo mv /mnt/usb/$TXT.txt /mnt/usb/Ready
#ArchLinuxARM-rpi-2-latest.tar.gz*

printf "${PURPLE}"
figlet Arch ARM Installed
printf "${STOP}"
