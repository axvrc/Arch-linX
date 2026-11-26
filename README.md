# Arch-linX

Script de instalación automatizada de Arch Linux personalizado.

## Descripción

Este repositorio contiene un script Bash que instala un sistema Arch Linux
completamente configurado desde el entorno live oficial de Arch. Está pensado
para uso personal y como punto de partida para una posible ISO futura.

## Características de la v0.1

- Compatibilidad con **UEFI y BIOS** usando GRUB y tabla GPT.
- Particionado automático de disco completo (sin swap).
- Entorno gráfico **Niri** (Wayland).
- Administrador de archivos **Thunar**.
- Navegador **qutebrowser**.
- Terminal **Alacritty** y editor **Neovim**.
- Drivers de video para **Intel y AMD**.
- Audio con **PipeWire + WirePlumber**.
- Red con **NetworkManager**.
- Optimizaciones para **laptops**: `tlp`, `brightnessctl`, `libinput`.
- Usuario predeterminado: `linX` / `12345`.
- Acceso root bloqueado; se usa `sudo`.

## Requisitos

- USB o ISO de Arch Linux oficial en modo live.
- Conexión a internet.
- Ejecutar como `root`.

## Uso

1. Arranca con el ISO oficial de Arch Linux.
2. Conecta a internet.
3. Clona este repositorio:

   ```bash
   pacman -Sy git
   git clone https://github.com/tu-usuario/Arch-linX.git
   cd Arch-linX
   ```

4. Ejecuta el script indicando el disco de destino:

   ```bash
   ./install.sh /dev/sda
   ```

   También puedes ejecutarlo sin argumentos para ver los discos disponibles:

   ```bash
   ./install.sh
   ```

5. Confirma escribiendo `SI` cuando se te pida.
6. Espera a que termine y reinicia:

   ```bash
   reboot
   ```

## Advertencias

- **El script borra TODO el contenido del disco seleccionado.**
- No uses este script en hardware real sin probarlo antes en una máquina virtual.
- Esta es una versión inicial (v0.1); úsala bajo tu propia responsabilidad.

## Próximos pasos

- Selección interactiva de disco.
- Soporte para swap, `/home` separada y particionado manual.
- Instalación opcional de **i3** y **OpenBox**.
- Personalización con dotfiles y temas.
- Generación de ISO con `archiso`.

## Referencias

- [Guía oficial de instalación de Arch](https://wiki.archlinux.org/title/Installation_guide)
- [archiso](https://wiki.archlinux.org/title/Archiso)
- [Niri](https://github.com/YaLTeR/niri)
