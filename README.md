# Arch-linX

Sistema Arch Linux personalizado construido con `archiso`.

## Descripcion

Este repositorio contiene un perfil de `archiso` que genera una ISO booteable
con Arch-linX: un entorno Arch Linux preconfigurado para uso personal.

Ya no se usa un script de instalacion separado. La ISO arranca directamente
al sistema configurado.

## Caracteristicas de la v0.1

- ISO booteable en **UEFI y BIOS**.
- Entorno principal: **Niri + noctalia** (Wayland).
- Entorno secundario: **i3** (X11).
- Gestor de sesiones: **greetd + tuigreet**.
- Administrador de archivos **Thunar**.
- Navegador **qutebrowser**.
- Terminal **Alacritty** y editor **Neovim**.
- Drivers de video para **Intel y AMD**.
- Audio con **PipeWire + WirePlumber**.
- Red con **NetworkManager**.
- Optimizaciones para **laptops**: `tlp`, `brightnessctl`, `libinput`.
- Usuario predeterminado: `linX` / `12345`.
- Acceso root bloqueado; se usa `sudo`.
- Teclado de consola: `us`.
- Locale: `es_MX.UTF-8`.
- Zona horaria: `America/Mexico_City`.

## Requisitos

- `archiso` instalado.
- Conexion a internet para descargar paquetes.
- Espacio libre en disco (la ISO ocupa varios GB).

## Construir la ISO

```bash
sudo mkarchiso -v -w ./work -o ./out ./archiso
```

La ISO resultante quedara en:

```bash
./out/arch-linx-YYYY.MM.DD-x86_64.iso
```

## Usar la ISO

1. Graba o monta la ISO en un USB o maquina virtual.
2. Arranca desde la ISO.
3. En el gestor de inicio (`tuigreet`), elige entre **Niri** o **i3**.
4. Inicia sesion con:
   - Usuario: `linX`
   - Contrasena: `12345`

## Advertencias

- Esta es una version inicial (v0.1); usala bajo tu propia responsabilidad.
- No incluye instalador a disco por ahora; es un sistema live.
- Prueba en maquina virtual antes de usar en hardware real.

## Proximos pasos

- Persistencia de datos en USB.
- Instalador a disco opcional.
- Personalizacion con dotfiles y temas.
- Soporte opcional para OpenBox.

## Referencias

- [Guia oficial de instalacion de Arch](https://wiki.archlinux.org/title/Installation_guide)
- [archiso](https://wiki.archlinux.org/title/Archiso)
- [Niri](https://github.com/YaLTeR/niri)
- [noctalia](https://github.com/noctalia-dev/noctalia)
- [i3](https://i3wm.org/)
