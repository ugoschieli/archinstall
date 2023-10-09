#!/bin/sh

echo "name=esp,type=uefi,bootable,size=+500MiB" | sfdisk /dev/sda --append --quiet
echo "name=swap,type=swap,size=+1GiB" | sfdisk /dev/sda --append --quiet
echo "name=root,type=linux,size=+10GiB" | sfdisk /dev/sda --append --quiet
echo "name=home,type=linux" | sfdisk /dev/sda --append --quiet
sfdisk /dev/sda --list --verify
