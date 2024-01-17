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

cat << EOF > /etc/systemd/network/25-wireless.network
[Match]
Name=wlp1s0

[Network]
DHCP=yes
MulticastDNS=yes
EOF

systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service
systemctl enable iwd.service
systemctl enable docker.service

passwd

useradd -m -G wheel,docker bite
sed '/%wheel ALL=(ALL:ALL) ALL/s/^# //' -i /etc/sudoers
passwd bite

sed '/Color/s/^#//' -i /etc/pacman.conf
sed '/ParallelDownloads/s/^#//' -i /etc/pacman.conf

bootctl install
systemctl enable systemd-boot-update.service
cat << EOF > /boot/loader/loader.conf
default arch.conf
timeout 0
EOF
cat << EOF > /boot/loader/entries/arch.conf
title     Arch Linux
linux     /vmlinuz-linux
initrd    /amd-ucode.img
initrd    /initramfs-linux.img
options   root=PARTLABEL=root rw quiet
EOF
