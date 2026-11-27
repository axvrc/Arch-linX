#!/bin/bash
#
# Arch-linX install script v0.1
# Instala un Arch Linux personalizado con Niri, GRUB (UEFI/BIOS) y
# particionado automatico de disco completo.
#
# Uso: ./install.sh [DISCO]
# Ejemplo: ./install.sh /dev/sda
#

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuracion editable
# -----------------------------------------------------------------------------
HOSTNAME="LinkX-Laptop"
USERNAME="linX"
USER_PASSWORD="12345"
TIMEZONE="America/Mexico_City"
LOCALE="es_MX.UTF-8"
KEYMAP="us"

# -----------------------------------------------------------------------------
# Funciones de utilidad
# -----------------------------------------------------------------------------
error() {
    echo "ERROR: $*" >&2
    exit 1
}

info() {
    echo "==> $*"
}

warn() {
    echo "ADVERTENCIA: $*"
}

check_root() {
    [[ $EUID -eq 0 ]] || error "Este script debe ejecutarse como root."
}

check_internet() {
    info "Comprobando conexion a internet..."
    if ! ping -c 1 -W 5 archlinux.org >/dev/null 2>&1; then
        error "No hay conexion a internet. Conectate a la red antes de continuar."
    fi
}

check_live_env() {
    if [[ ! -d /sys/firmware/efi ]] && [[ ! -f /etc/arch-release ]]; then
        warn "No parece que estes usando el entorno live de Arch Linux."
    fi
}

detect_firmware() {
    if [[ -d /sys/firmware/efi/efivars ]]; then
        echo "uefi"
    else
        echo "bios"
    fi
}

list_disks() {
    lsblk -d -p -n -o NAME,SIZE,MODEL,TRAN || true
}

select_disk() {
    local disk="${1:-}"

    if [[ -z "$disk" ]]; then
        info "Discos disponibles:"
        list_disks
        echo
        read -rp "Introduce el disco objetivo (ej. /dev/sda): " disk
    fi

    [[ -n "$disk" ]] || error "No se especifico ningun disco."
    [[ -b "$disk" ]] || error "'$disk' no es un dispositivo de bloque valido."

    echo "$disk"
}

confirm_wipe() {
    local disk="$1"

    echo
    warn "SE BORRARA TODO EL CONTENIDO DE: $disk"
    warn "Esta operacion es DESTRUCTIVA e IRREVERSIBLE."
    echo
    read -rp "Escribe 'SI' para continuar: " respuesta

    [[ "$respuesta" == "SI" ]] || error "Instalacion cancelada por el usuario."
}

ensure_sgdisk() {
    if ! command -v sgdisk >/dev/null 2>&1; then
        info "Instalando gptfdisk en el entorno live..."
        pacman -Sy --noconfirm gptfdisk
    fi
}

# -----------------------------------------------------------------------------
# Particionado y formateo
# -----------------------------------------------------------------------------
partition_disk() {
    local disk="$1"
    local firmware="$2"

    info "Limpiando tabla de particiones de $disk..."
    ensure_sgdisk
    sgdisk -Z "$disk"
    sgdisk -o "$disk"

    if [[ "$firmware" == "uefi" ]]; then
        info "Creando particiones GPT para UEFI..."
        sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI" "$disk"
        sgdisk -n 2:0:0 -t 2:8300 -c 2:"ROOT" "$disk"
    else
        info "Creando particiones GPT para BIOS..."
        sgdisk -n 1:0:+2M -t 1:ef02 -c 1:"BIOSBOOT" "$disk"
        sgdisk -n 2:0:0 -t 2:8300 -c 2:"ROOT" "$disk"
    fi

    partprobe "$disk"
    sleep 2
}

format_partitions() {
    local disk="$1"
    local firmware="$2"

    if [[ "$firmware" == "uefi" ]]; then
        info "Formateando particion EFI como FAT32..."
        mkfs.vfat -F 32 -n EFI "${disk}1"
    fi

    info "Formateando particion raiz como ext4..."
    mkfs.ext4 -L ROOT "${disk}2"
}

mount_partitions() {
    local disk="$1"
    local firmware="$2"

    info "Montando particiones..."
    mount "${disk}2" /mnt
    mkdir -p /mnt/boot/efi

    if [[ "$firmware" == "uefi" ]]; then
        mount "${disk}1" /mnt/boot/efi
    fi
}

# -----------------------------------------------------------------------------
# Instalacion base
# -----------------------------------------------------------------------------
enable_multilib() {
    info "Habilitando repositorio multilib..."
    sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
    pacman -Sy
}

install_base() {
    info "Instalando paquetes base. Esto puede tardar varios minutos..."

    enable_multilib

    local pkgs=(
        # Base del sistema
        base base-devel linux linux-lts linux-firmware

        # Herramientas del instalador y sistema de archivos
        grub efibootmgr os-prober dosfstools e2fsprogs gptfdisk parted

        # Red y utilidades basicas
        networkmanager network-manager-applet openssh git curl wget
        man-db man-pages

        # Audio
        pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber
        pipewire-audio alsa-utils alsa-lib alsa-firmware pavucontrol

        # Fuentes
        noto-fonts noto-fonts-emoji

        # Drivers de video Intel y AMD
        mesa lib32-mesa xf86-video-amdgpu xf86-video-ati xf86-video-intel
        vulkan-radeon vulkan-intel intel-ucode amd-ucode

        # Laptop
        tlp brightnessctl libinput

        # Entorno grafico 1: Niri + Noctalia (Wayland)
        niri noctalia xorg-xwayland wl-clipboard
        xdg-desktop-portal xdg-desktop-portal-gnome xdg-user-dirs
        polkit

        # Entorno grafico 2: i3 (X11)
        i3-wm i3status i3lock dmenu
        xorg-server xorg-xinit xorg-xrandr xorg-xset xorg-xinput
        picom feh dunst

        # Gestor de sesiones
        greetd greetd-tuigreet

        # Administrador de archivos
        thunar thunar-volman gvfs ntfs-3g exfat-utils

        # Aplicaciones esenciales
        alacritty neovim qutebrowser

        # Utilidades varias
        zip unzip p7zip
    )

    pacstrap -K /mnt "${pkgs[@]}"
}

# -----------------------------------------------------------------------------
# Configuracion del sistema dentro del chroot
# -----------------------------------------------------------------------------
configure_system() {
    local disk="$1"
    local firmware="$2"

    info "Generando fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab

    info "Configurando sistema dentro del chroot..."
    arch-chroot /mnt /bin/bash <<CHROOT_EOF
set -euo pipefail

info() {
    echo "==> (chroot) \$*"
}

# Zona horaria
info "Configurando zona horaria ${TIMEZONE}..."
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc

# Locale
info "Generando locale ${LOCALE}..."
echo "${LOCALE} UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}" > /etc/locale.conf

# Mapa de teclado para consola
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf

# Hostname
info "Configurando hostname ${HOSTNAME}..."
echo "${HOSTNAME}" > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1\tlocalhost
::1\t\tlocalhost
127.0.1.1\t${HOSTNAME}.localdomain\t${HOSTNAME}
EOF

# Usuario
info "Creando usuario ${USERNAME}..."
useradd -m -G wheel,video,audio,network,input -s /bin/bash "${USERNAME}"
echo "${USERNAME}:${USER_PASSWORD}" | chpasswd

# Root bloqueado (se usa sudo)
info "Bloqueando acceso directo a root..."
passwd -l root

# Sudo para el grupo wheel
info "Configurando sudo..."
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

# Archivos de sesion para el gestor de inicio
info "Creando archivos de sesion..."
mkdir -p /usr/share/wayland-sessions /usr/share/xsessions

cat > /usr/share/wayland-sessions/niri.desktop <<EOF
[Desktop Entry]
Name=Niri
Comment=Scrollable-tiling Wayland compositor
Exec=niri
Type=Application
EOF

cat > /usr/share/xsessions/i3.desktop <<EOF
[Desktop Entry]
Name=i3
Comment=i3 tiling window manager
Exec=i3
Type=Application
EOF

# Configuracion de greetd
info "Configurando greetd..."
mkdir -p /etc/greetd
cat > /etc/greetd/config.toml <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --remember-session --asterisks"
user = "${USERNAME}"
EOF

# Servicios
info "Habilitando servicios..."
systemctl enable NetworkManager.service
systemctl enable systemd-timesyncd.service
systemctl enable fstrim.timer
systemctl enable tlp.service
systemctl enable greetd.service

# Inicializar initramfs
info "Regenerando initramfs..."
mkinitcpio -P

# Bootloader GRUB
info "Instalando GRUB..."
if [[ "${firmware}" == "uefi" ]]; then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --removable
else
    grub-install --target=i386-pc "${disk}"
fi

info "Generando configuracion de GRUB..."
grub-mkconfig -o /boot/grub/grub.cfg

CHROOT_EOF
}

# -----------------------------------------------------------------------------
# Finalizacion
# -----------------------------------------------------------------------------
finish() {
    info "Desmontando sistemas de archivos..."
    umount -R /mnt || true

    echo
    info "Instalacion completada."
    info "Puedes reiniciar con: reboot"
    info "Usuario: ${USERNAME}"
    info "Contrasena: ${USER_PASSWORD}"
    info "Hostname: ${HOSTNAME}"
}

# -----------------------------------------------------------------------------
# Flujo principal
# -----------------------------------------------------------------------------
main() {
    local disk="${1:-}"

    check_root
    check_internet
    check_live_env

    local firmware
    firmware="$(detect_firmware)"
    info "Firmware detectado: ${firmware^^}"

    disk="$(select_disk "$disk")"
    confirm_wipe "$disk"

    timedatectl set-ntp true

    partition_disk "$disk" "$firmware"
    format_partitions "$disk" "$firmware"
    mount_partitions "$disk" "$firmware"

    install_base
    configure_system "$disk" "$firmware"
    finish
}

main "$@"
