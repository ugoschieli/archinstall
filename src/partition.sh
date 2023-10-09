#!/bin/sh

echo "name=esp,type=uefi,bootable,size=+500MiB" | sfdisk /dev/sda -n --wipe always
echo "name=swap,type=swap,size=+1GiB" | sfdisk /dev/sda -n -a --wipe always
echo "name=root,type=linux,size=+10GiB" | sfdisk /dev/sda -n -a --wipe always
echo "name=home,type=linux" | sfdisk /dev/sda -n -a --wipe always
