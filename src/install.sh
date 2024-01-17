#!/bin/bash

set -xeuo pipefail

DISK=/dev/nvme0n1;
EFI_PART="${DISK}p1";
SWAP_PART="${DISK}p2";
ROOT_PART="${DISK}p3";
EFI_SIZE=512;
SWAP_SIZE=10;

echo "name=esp,type=uefi,bootable,size=+${EFI_SIZE}MB" | sfdisk ${DISK} --quiet --wipe always
echo "name=swap,type=swap,size=+${SWAP_SIZE}GB"        | sfdisk ${DISK} --append --quiet --wipe always
echo "name=root,type=linux"                            | sfdisk ${DISK} --append --quiet --wipe always
sfdisk ${DISK} --list --verify

mkfs.fat -F 32 -n "efi"  $EFI_PART
mkswap         -L "swap" $SWAP_PART
mkfs.ext4      -L "root" $ROOT_PART

mount $ROOT_PART /mnt
mount --mkdir $EFI_PART /mnt/boot
swapon $SWAP_PART

sed '/ParallelDownloads/s/^#//' -i /etc/pacman.conf
pacstrap -K /mnt base linux linux-firmware amd-ucode iwd vim openssh docker sudo

genfstab -U /mnt >> /mnt/etc/fstab

ln -sf /run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf

mkdir /mnt/root/archinstall
cp chroot.sh /mnt/root/archinstall
arch-chroot /mnt /root/archinstall/chroot.sh

umount  $EFI_PART
umount  $ROOT_PART
swapoff $SWAP_PART

echo 'Installation finished'
