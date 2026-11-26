#!/bin/bash
#
# Configuracion final del sistema Arch-linX dentro del airootfs
# Este script se ejecuta como root dentro del chroot antes de crear squashfs.
#

set -euo pipefail

USERNAME="linX"
USER_PASSWORD="12345"
HOSTNAME="LinkX-Laptop"

echo "==> Generando locales..."
locale-gen

echo "==> Configurando reloj de hardware..."
hwclock --systohc

echo "==> Creando usuario ${USERNAME}..."
useradd -m -G wheel,video,audio,network,input -s /bin/bash "${USERNAME}"
echo "${USERNAME}:${USER_PASSWORD}" | chpasswd

echo "==> Bloqueando acceso directo a root..."
passwd -l root

echo "==> Habilitando servicios..."
systemctl enable NetworkManager.service
systemctl enable systemd-timesyncd.service
systemctl enable fstrim.timer
systemctl enable tlp.service
systemctl enable greetd.service

echo "==> Deshabilitando systemd-networkd para evitar conflictos con NetworkManager..."
systemctl mask systemd-networkd.service
systemctl mask systemd-networkd-wait-online.service

echo "==> Regenerando initramfs..."
mkinitcpio -P

echo "==> Configuracion de Arch-linX completada."
