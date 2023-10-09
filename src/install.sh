#!/bin/bash

set -xeuo pipefail

CONFIG=virtualbox

if [[ $CONFIG == "gemini" ]]; then
    DISK=/dev/nvme0n1;
    ESP="${DISK}p1";
    SWAP_PART="${DISK}p2";
    ROOT_PART="${DISK}p3";
    HOME_PART="${DISK}p4";
    ESP_SIZE=500;
    SWAP_SIZE=10;
    ROOT_SIZE=50;
elif [[ $CONFIG == "qemu" ]]; then
    DISK=/dev/vda;
    ESP="${DISK}1";
    SWAP_PART="${DISK}2";
    ROOT_PART="${DISK}3";
    HOME_PART="${DISK}4";
    ESP_SIZE=500;
    SWAP_SIZE=1;
    ROOT_SIZE=10;
elif [[ $CONFIG == "virtualbox" ]]; then
    DISK=/dev/sda;
    ESP="${DISK}1";
    SWAP_PART="${DISK}2";
    ROOT_PART="${DISK}3";
    HOME_PART="${DISK}4";
    ESP_SIZE=500;
    SWAP_SIZE=1;
    ROOT_SIZE=10;
fi

echo "name=esp,type=uefi,bootable,size=+${ESP_SIZE}MiB" | sfdisk /dev/sda --quiet --wipe always
echo "name=swap,type=swap,size=+${SWAP_SIZE}GiB" | sfdisk /dev/sda --append --quiet --wipe always
echo "name=root,type=linux,size=+${ROOT_SIZE}GiB" | sfdisk /dev/sda --append --quiet --wipe always
echo "name=home,type=linux" | sfdisk /dev/sda --append --quiet --wipe always
sfdisk /dev/sda --list --verify

mkfs.fat -F 32 -n "efi" $ESP
mkswap -L "swap" $SWAP_PART
mkfs.ext4 -L "root" $ROOT_PART
mkfs.ext4 -L "home" $HOME_PART

mount $ROOT_PART /mnt
mount --mkdir $ESP /mnt/boot
mount --mkdir $HOME_PART /mnt/home
swapon $SWAP_PART

sed '/ParallelDownloads/s/^#//' -i /etc/pacman.conf
pacstrap -K /mnt `grep -v '^#' ./pkglist.txt`

genfstab -U /mnt >> /mnt/etc/fstab

cp chroot.sh /mnt/archinstall
cp -r configs /mnt/archinstall
arch-chroot /mnt /mnt/archinstall/chroot.sh

umount $ESP
umount $HOME_PART
umount $ROOT_PART
swapoff $SWAP_PAR

echo 'Installation finished'
