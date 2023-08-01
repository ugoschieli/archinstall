echo "Hello from chroot"

ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc

sed '/en_US.UTF-8 UTF-8/s/^#//' -i /etc/locale.gen
locale-gen

cat << EOF > /etc/locale.conf
LANG=en_US.UTF-8
EOF

cat << EOF > /etc/vconsole.conf
KEYMAP=fr
EOF

cat << EOF > /etc/hostname
gemini
EOF

localectl set-x11-keymap fr

systemctl enable NetworkManager.service
systemctl enable pipewire-pulse.service
systemctl enable bluetooth.service

passwd

useradd -m -G wheel ugo
sed '/%wheel ALL=(ALL:ALL) ALL/s/^# //' -i /etc/sudoers
passwd ugo

sed '/Color/s/^#//' -i /etc/pacman.conf
sed '/ParallelDownloads/s/^#//' -i /etc/pacman.conf

bootctl install
cat << EOF > /boot/loader/loader.conf
default arch.conf
EOF
cat << EOF > /boot/loader/entries/arch.conf
title     Arch Linux
linux     /vmlinuz-linux
initrd    /amd-ucode.img
initrd    /initramfs-linux.img
options   root=PARTLABEL=ROOT_PART rw quiet
EOF
systemctl enable systemd-boot-update.service
