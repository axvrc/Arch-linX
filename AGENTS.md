# AGENTS.md — Arch-linX

## Project purpose

This repository contains the build artifacts for a **personal, Arch Linux-based installation system**. The immediate goal is **not** to maintain a full Linux distribution, but to produce a reproducible, automated way to install a customized Arch Linux environment on real hardware and virtual machines.

The long-term vision is to evolve this into a personal ISO (built with `archiso`) and, only if strictly necessary, a small personal package repository. Avoid scope creep into a full distro fork unless explicitly requested by the user.

## Current stage

- Repository contains `install.sh` v0.1 and `README.md`.
- Script installs a complete Arch system from the official live ISO.
- Next expected work: test in VM, fix issues, then iterate to v0.2.

## Locked decisions

| Decision | Value |
|----------|-------|
| Firmware support | UEFI + BIOS |
| Partition table | GPT |
| Bootloader | GRUB |
| Disk handling v0.1 | Automatic full-disk wipe; target disk passed as argument |
| Swap | None |
| Window manager | Niri (primary); i3 and OpenBox planned as optional later |
| File manager | Thunar |
| Web browser | qutebrowser |
| Terminal | Alacritty |
| Text editor | Neovim |
| Video drivers | Intel + AMD |
| Audio stack | PipeWire + WirePlumber |
| Networking | NetworkManager |
| Bluetooth | Not included in v0.1 |
| Machine type | Laptop (includes `tlp`, `brightnessctl`, `libinput`) |
| Default username | `linX` |
| Default user password | `12345` |
| Hostname | `LinkX-Laptop` |
| Root account | Locked; root access via `sudo` only |
| Default locale | `es_MX.UTF-8` |
| Default timezone | `America/Mexico_City` |
| Console keymap | `es` |
| Package source | Official Arch repositories only (no custom repos in v0.1) |

## Architecture decisions

1. **Start simple, evolve later.**
   - Phase 1: Bash install script (`install.sh`). ✅ Current.
   - Phase 2: `archiso` profile that embeds the script and generates a bootable ISO.
   - Phase 3 (optional): personal PKGBUILDs and a private package repository.
   - Phase 4 (very unlikely): a true Arch fork.

2. **Use official Arch tooling.**
   - `pacstrap`, `arch-chroot`, `genfstab`, `pacman` for installation.
   - `sgdisk` for GPT partitioning.
   - `archiso` for ISO generation (future).
   - `GRUB` as bootloader because it supports both UEFI and BIOS from the same GPT layout.

3. **Target environments.**
   - Primary: bare-metal UEFI/BIOS laptops and desktops.
   - Secondary: virtual machines (QEMU/KVM, VirtualBox) for testing.

4. **No custom repos or patched packages in Phase 1.**
   - Use only official Arch repositories.
   - Customizations come from package selection, dotfiles, and configuration files, not from repackaging software.

## Coding style

- Scripts are written in **Bash** and target the Arch Linux live environment.
- Use `set -euo pipefail` in all scripts.
- Fail fast with clear, Spanish-language error messages (the user prefers Spanish).
- Prefer explicit commands over clever one-liners.
- Quote all variables.
- Validate user input and hardware assumptions before destructive operations.
- Keep the script modular: helper functions at the top, main flow at the bottom.

## Workflow for agents

When working on this project:

1. **Ask before assuming.** Confirm the target environment (UEFI/BIOS, disk, desktop/window manager, packages) before generating destructive commands.
2. **Test in a VM first.** Use QEMU/KVM or VirtualBox before suggesting the user run anything on real hardware.
3. **Keep backups.** Remind the user that disk partitioning and formatting are destructive.
4. **Document every step.** Update `README.md` and this file as the project evolves.
5. **Version-lock major decisions.** If the user chooses a desktop environment, window manager, bootloader, or disk layout, record it in this file so future agents do not undo it.

## User preferences

- Language: Spanish.
- Wants the system to feel "completely mine" but is open to starting small.
- Beginner with Arch derivatives; prefers simple, working solutions over theoretical purity.
- Happy to test in VMs before running on real hardware.

## Open questions / future work

- [ ] Test `install.sh` on UEFI VM.
- [ ] Test `install.sh` on BIOS VM.
- [ ] Add disk selection/interactive partitioning for v0.2.
- [ ] Add optional i3/OpenBox installation.
- [ ] Add dotfiles and theme configuration.
- [ ] Build ISO with `archiso`.

## Useful references

- Arch Installation Guide: https://wiki.archlinux.org/title/Installation_guide
- archiso: https://wiki.archlinux.org/title/Archiso
- pacman: https://wiki.archlinux.org/title/Pacman
- GRUB: https://wiki.archlinux.org/title/GRUB
- Niri: https://github.com/YaLTeR/niri
