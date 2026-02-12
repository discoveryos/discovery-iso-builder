# 🖥 MyLinuxDistro – Fully Automated Minimal XFCE Linux Distro Builder

A fully automated script to build a **minimal Linux distro** from scratch, including:

- Linux kernel compilation  
- Core utilities and system libraries  
- Systemd, networking, and essential services  
- X11 / graphics libraries  
- XFCE desktop environment with LightDM  
- Bootable initramfs  
- Automatic creation of standard Linux filesystem layout  

This project allows you to **create a bootable Linux system** without using any pre-existing distro base.

---

## 📦 Features

- Creates all standard Linux directories:

- Sets up minimal `/dev` nodes (`console`, `tty`, `null`, `zero`, `random`, `urandom`, `ptmx`)  
- Downloads, builds, and installs:

  - **Toolchain:** GCC, Binutils, glibc  
  - **Core utilities:** Coreutils, Findutils, Sed, Grep, Tar, XZ, Gzip, Util-linux  
  - **Kernel:** Linux 6.x (configurable)  
  - **System:** Systemd, D-Bus, Polkit  
  - **Networking:** iproute2, dhcpcd  
  - **Graphics / X11:** libdrm, Mesa, Xorg-server, X11 libraries  
  - **Desktop environment:** XFCE 4.18, LightDM  

- Automatically generates a **minimal initramfs** for booting  

---

## ⚙️ Host Requirements

Before running the build script, install **all required host dependencies**:

```bash
sudo apt update
sudo apt install -y build-essential make gcc g++ binutils bison flex autoconf automake libtool pkg-config \
wget curl xz-utils gzip bzip2 tar unzip patch git m4 perl python3 \
libncurses-dev libssl-dev libgmp-dev libmpfr-dev libmpc-dev libisl-dev \
zlib1g-dev libbz2-dev liblzma-dev \
libx11-dev libxext-dev libxrender-dev libxrandr-dev libxfixes-dev libxcursor-dev \
libxi-dev libxinerama-dev libxxf86vm-dev libxcb1-dev libxcb-util0-dev libxkbcommon-dev \
libdrm-dev libfreetype-dev libfontconfig1-dev libharfbuzz-dev mesa-common-dev libgl1-mesa-dev \
libdbus-1-dev libdbus-glib-1-dev libpam0g-dev libcap-dev libaudit-dev libseccomp-dev libpolkit-gobject-1-dev \
texinfo gperf intltool python3-pip bc cpio qemu-system-x86


