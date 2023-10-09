#!/bin/sh

echo "name=esp,type=uefi,bootable,size=+500MiB" | sfdisk /dev/sda --quiet --wipe always
echo "name=swap,type=swap,size=+1GiB" | sfdisk /dev/sda --append --quiet --wipe always
echo "name=root,type=linux,size=+10GiB" | sfdisk /dev/sda --append --quiet --wipe always
echo "name=home,type=linux" | sfdisk /dev/sda --append --quiet --wipe always
sfdisk /dev/sda --list --verify
