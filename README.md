# WorksenseArchArmPi
Arch ARM Worksense install script for arch based distros.

This script will install Arch ARM based linux for Raspberry Pi 2 / 3 (SD CARD)

When installed to SD card Raspberry will launch with Arch ARM. 

After launching you have to navigate to user alarm and run the installation script `ArchSetup`

It will automatically search for Wifis that you have to choose which one you are using and do basic updates and adding startup scripts


This install script is based on Elmo Tetri's Arch arm worksense install script.
[GitLab E.T](https://gitlab.com/E.T/arch-arm-worksense-install-script)

## Current issues
- Xorg is not checking for correct device, so no output is given by chromium
- Datetime is needed to put manually to get Wifi working
- Datetime service is not running automatically / it wont get the correct time