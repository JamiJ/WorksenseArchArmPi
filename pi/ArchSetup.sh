#!/bin/bash

macaddress=$(cat /sys/class/net/wlan0/address)
echo MAC ADDRESS
echo "$(tput setaf 1)$macaddress$(tput sgr 0)"
echo "$(tput setaf 2)$macaddress$(tput sgr 0)"
echo "$(tput setaf 3)$macaddress$(tput sgr 0)"
echo "$(tput setaf 4)$macaddress$(tput sgr 0)"
echo "$(tput setaf 5)$macaddress$(tput sgr 0)"
echo "$(tput setaf 6)$macaddress$(tput sgr 0)"
printf "\n\n\n\n"
echo "$(tput setaf 2)Press any key to proceed$(tput sgr 0)"
read -n 1 -s

#Finnish keyboard
loadkeys fi
echo "$(tput setaf 2)Finnish keyboard in use$(tput sgr 0)"



echo;sleep 5



#Connect to wifi
echo "$(tput setaf 2)Choose your wifi and connect$(tput sgr 0)"
sleep 1
echo "$(tput setaf 2)Opening wifi-menu in$(tput sgr 0)"
sleep 1
echo "$(tput setaf 1)3$(tput sgr 0)"
sleep 1
echo "$(tput setaf 3)2$(tput sgr 0)"
sleep 1
echo "$(tput setaf 2)1$(tput sgr 0)"
sleep 1

function wifi() {
wifi-menu

sleep 1

#Connect to wifi
firstresult=$(netctl list | grep wlan0)
sleep 1
firstresult=$(sed 's/ //g' <<< $firstresult)
firstresult=$(sed 's/\*//g' <<< $firstresult)
firstresult=$(sed 's/\+//g' <<< $firstresult)
echo "$(tput setaf 2)$firstresult$(tput sgr 0)"
netctl start $firstresult
echo "$(tput setaf 2)Wireless connected$(tput sgr 0)"
sleep 10
if ping -q -c 5 -W 5 8.8.8.8 >/dev/null; then
  echo "$(tput setaf 2)Network working$(tput sgr 0)"
else
  wifi-menu
fi
}
wifi

echo;sleep 2



echo "$(tput setaf 3)Set timezone to Finland & set-ntp to 0$(tput sgr 0)"
sleep 1
timedatectl set-timezone Europe/Helsinki
timedatectl set-ntp 0
echo "$(tput setaf 2)Timezone set & set-ntp 0$(tput sgr 0)"



echo;sleep 4



echo "$(tput setaf 3)Updating keyring$(tput sgr 0)"
sleep 1
#Set up the pacman keyring
pacman-key --init



echo;sleep 1



#Reload the default keys in keyring
pacman-key --populate archlinuxarm
echo "$(tput setaf 2)Keyring updated$(tput sgr 0)"

echo;sleep 1

echo "$(tput setaf 3)Installing f2fs$(tput sgr 0)"
pacman --needed --noconfirm -S f2fs-tools
echo "$(tput setaf 2)Installed f2fs$(tput sgr 0)"

echo;sleep 5

echo "$(tput setaf 3)Update system$(tput sgr 0)"
sleep 2
#System update
pacman --noconfirm -Syu
echo "$(tput setaf 2)System updated $(tput sgr 0)"



echo;sleep 5



echo "$(tput setaf 3)Installing needed software$(tput sgr 0)"
sleep 2
#Download everything needed
pacman --needed --noconfirm -S libtool sudo cronie xdotool unclutter fbset libdrm archlinux-keyring xorg-xinit xf86-video-fbturbo xorg-xrefresh xorg-server xf86-video-fbdev midori base base-devel
echo "$(tput setaf 2)Software installed$(tput sgr 0)"



echo;sleep 10



echo "$(tput setaf 3)Copying conf files$(tput sgr 0)"
sleep 1
cp xorg.conf /usr/share/X11/xorg.conf.d/99-fbturbo.conf
cp timesyncd.conf /etc/system/timesyncd.conf

echo "$(tput setaf 2)Conf files copied$(tput sgr 0)"



echo;sleep 5



echo "$(tput setaf 3)Making changes to sudoers$(tput sgr 0)"
sleep 1
echo "alarm  ALL=NOPASSWD: ALL" > /etc/sudoers.d/myOverrides
echo "$(tput setaf 2)Changes made$(tput sgr 0)"



echo;sleep 5



echo "$(tput setaf 3)Checking monitor size$(tput sgr 0)"
sleep 1
#Check for monitor size
CMD="$(fbset -s | awk '$1 == "geometry" { print $2" "$3 }')"
CMD=$(tr " " , <<< $CMD)
echo $CMD
echo "$(tput setaf 2)Monitor size saved$(tput sgr 0)"



echo;sleep 5



#Make Midori start on boot
copylink=$(tail -qn 1 link)
echo -e "\n\nexec midori -a "$copylink >> /home/alarm/.xinitrc
echo "$(tput setaf 2)Midori startup copied to .xinitrc$(tput sgr 0)"



echo;sleep 5



#Save mac address
echo "$(tput setaf 3)Copying mac address to home folder$(tput sgr 0)"
cat /sys/class/net/wlan0/address > /home/alarm/mac
echo "$(tput setaf 2)Mac address copied to home folder (/home/alarm/mac)$(tput sgr 0)"



echo;sleep 5



#Automatic login
echo "$(tput setaf 3)Enabling automatic login$(tput sgr 0)"
mkdir -p /etc/systemd/system/getty@tty1.service.d/
echo -e "[Service]\nExecStart=\nExecStart=-/usr/bin/agetty --autologin alarm --noclear %I $TERM" | tee -a /etc/systemd/system/getty@tty1.service.d/override.conf
echo "$(tput setaf 2)Automatic login enabled$(tput sgr 0)"



echo;sleep 5



export DISPLAY=localhost:0.0
echo "$(tput setaf 2)DISPLAY exported$(tput sgr 0)"



echo;sleep 5



echo "$(tput setaf 3)Enable and start cronie services$(tput sgr 0)"
sleep 2
systemctl enable cronie.service
systemctl start cronie.service
echo "$(tput setaf 2)Cronie services have been enabled and started$(tput sgr 0)"



echo;sleep 5



echo "$(tput setaf 3)Creating a nettest crontab$(tput sgr 0)"
sleep 1
#Write out current crontab (crontab is empty so you will get a message "no crontab for alarm")
su alarm -c "crontab -l > netcron"
#Echo new cron into cron file
su alarm -c "echo @reboot bash /home/alarm/nettest.sh >> netcron"
#Install new cron file
su alarm -c "crontab netcron"
su alarm -c "rm netcron"
echo "$(tput setaf 2)Nettest crontab created$(tput sgr 0)"



echo;sleep 5



echo "$(tput setaf 3)Creating a reboot crontab$(tput sgr 0)"
sleep 1
#Write out current crontab
crontab -l > rebootcron
#Echo new cron into cron file
echo @midnight reboot >> rebootcron
#Install new cron file
crontab rebootcron
rm rebootcron
echo "$(tput setaf 2)Reboot crontab created$(tput sgr 0)"



echo;sleep 5



location=$(head -qn 1 link | sed 's/ //g' | tr -d '\n'| tr -d '\r')
hostnamectl set-hostname $location-map
echo "$(tput setaf 2)Hostname changed to $location-map$(tput sgr 0)"



echo;sleep 5



#Delete old wifi
netctl stop-all
rm -f /etc/netctl/wlan0-*



echo;sleep 5



#Connect to wifi
echo "$(tput setaf 2)Choose your wifi and connect$(tput sgr 0)"
sleep 1
echo "$(tput setaf 2)Opening wifi-menu in$(tput sgr 0)"
sleep 1
echo "$(tput setaf 1)3$(tput sgr 0)"
sleep 1
echo "$(tput setaf 3)2$(tput sgr 0)"
sleep 1
echo "$(tput setaf 2)1$(tput sgr 0)"
sleep 1
wifi-menu



sleep 1



#Connect to wifi
result=$(netctl list | grep wlan0)
sleep 1
result=$(sed 's/ //g' <<< $result)
result=$(sed 's/\*//g' <<< $result)
result=$(sed 's/\+//g' <<< $result)
echo "$(tput setaf 2)$result$(tput sgr 0)"
netctl start $result
netctl enable $result
echo "$(tput setaf 2)Wireless connected$(tput sgr 0)"



echo;sleep 2



echo "$(tput setaf 2)Install Finished$(tput sgr 0)"
sleep 2
echo "$(tput setaf 2)Rebooting$(tput sgr 0)"
sleep 2
#Reboot
reboot
