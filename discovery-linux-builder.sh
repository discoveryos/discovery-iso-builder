#!/bin/bash
set -e

# -----------------------------
# Paths
# -----------------------------
BUILD=$HOME/mydistro/build
SRC=$BUILD/sources
ROOTFS=$HOME/mydistro/rootfs
KERNEL_CONFIG=$HOME/mydistro/kernel-config
INITRAMFS_IMG=$HOME/mydistro/initramfs.img

mkdir -p $SRC $ROOTFS

# -----------------------------
# 0️⃣ Create standard Linux directories
# -----------------------------
echo "Creating standard Linux filesystem directories..."
mkdir -p $ROOTFS/{bin,sbin,lib,lib64,dev,etc,proc,sys,tmp,var,home,usr/bin,usr/sbin}
chmod 1777 $ROOTFS/tmp
chmod 755 $ROOTFS/home

# -----------------------------
# 0️⃣b Create minimal device nodes in /dev
# -----------------------------
echo "Creating minimal /dev device nodes..."
sudo mknod -m 666 $ROOTFS/dev/null c 1 3
sudo mknod -m 666 $ROOTFS/dev/zero c 1 5
sudo mknod -m 666 $ROOTFS/dev/tty c 5 0
sudo mknod -m 666 $ROOTFS/dev/console c 5 1
sudo mknod -m 666 $ROOTFS/dev/ptmx c 5 2
sudo mknod -m 666 $ROOTFS/dev/random c 1 8
sudo mknod -m 666 $ROOTFS/dev/urandom c 1 9

cd $SRC

# -----------------------------
# 1️⃣ Download all sources
# -----------------------------
echo "Downloading sources..."

# Toolchain
wget -c https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.xz
wget -c https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz
wget -c https://ftp.gnu.org/gnu/glibc/glibc-2.38.tar.xz

# Core utilities
wget -c https://ftp.gnu.org/gnu/coreutils/coreutils-9.3.tar.xz
wget -c https://ftp.gnu.org/gnu/findutils/findutils-4.9.0.tar.xz
wget -c https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz
wget -c https://ftp.gnu.org/gnu/grep/grep-3.11.tar.xz
wget -c https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz
wget -c https://ftp.gnu.org/gnu/gzip/gzip-1.12.tar.xz
wget -c https://ftp.gnu.org/gnu/xz/xz-5.4.4.tar.xz
wget -c https://www.kernel.org/pub/linux/utils/util-linux/v2.39/util-linux-2.39.tar.xz

# Kernel headers
wget -c https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.4.12.tar.xz

# Systemd and networking
wget -c https://github.com/systemd/systemd/releases/download/v254/systemd-254.tar.gz
wget -c https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-6.4.0.tar.xz
wget -c https://downloads.sourceforge.net/project/dhcpcd/dhcpcd/9.5.7/dhcpcd-9.5.7.tar.xz

# X11 / graphics libraries
wget -c https://xorg.freedesktop.org/archive/individual/lib/libdrm-2.4.112.tar.xz
wget -c https://mesa.freedesktop.org/archive/mesa-23.3.0.tar.xz
wget -c https://xorg.freedesktop.org/archive/individual/xserver/xorg-server-21.1.9.tar.xz

wget -c https://xorg.freedesktop.org/archive/individual/lib/libX11-1.8.5.tar.xz
wget -c https://xorg.freedesktop.org/archive/individual/lib/libXext-1.4.2.tar.xz
wget -c https://xorg.freedesktop.org/archive/individual/lib/libXrender-0.9.12.tar.xz
wget -c https://xorg.freedesktop.org/archive/individual/lib/libXrandr-1.6.3.tar.xz
wget -c https://xorg.freedesktop.org/archive/individual/lib/libXfixes-6.0.0.tar.xz
wget -c https://xorg.freedesktop.org/archive/individual/lib/libXcursor-1.2.0.tar.xz
wget -c https://xorg.freedesktop.org/archive/individual/lib/libXi-1.8.tar.xz
wget -c https://xorg.freedesktop.org/archive/individual/lib/libXinerama-1.1.4.tar.xz
wget -c https://xorg.freedesktop.org/archive/individual/lib/libXxf86vm-1.1.5.tar.xz
wget -c https://xorg.freedesktop.org/archive/individual/lib/libxcb-1.15.tar.gz
wget -c https://download.savannah.gnu.org/releases/freetype/freetype-2.13.0.tar.xz
wget -c https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.14.2.tar.xz
wget -c https://github.com/harfbuzz/harfbuzz/releases/download/7.1.0/harfbuzz-7.1.0.tar.xz
wget -c https://www.x.org/archive/individual/lib/libxkbcommon-1.5.0.tar.xz

# XFCE Desktop
wget -c https://archive.xfce.org/xfce/4.18/src/xfce4-4.18.tar.xz
wget -c https://archive.xfce.org/xfce/lightdm-1.32.0.tar.xz

# System services
wget -c https://dbus.freedesktop.org/releases/dbus/dbus-1.16.10.tar.gz
wget -c https://www.freedesktop.org/software/polkit/releases/0.118/polkit-0.118.tar.gz

echo "All sources downloaded!"

# -----------------------------
# 2️⃣ Build Linux Kernel
# -----------------------------
echo "Building Linux kernel..."
tar -xf linux-6.4.12.tar.xz
cd linux-6.4.12
if [ -f $KERNEL_CONFIG ]; then
    cp $KERNEL_CONFIG .config
else
    make defconfig
fi
make -j$(nproc)
make INSTALL_MOD_PATH=$ROOTFS modules_install
make INSTALL_PATH=$ROOTFS/boot install
cd $SRC

# -----------------------------
# 3️⃣ Build toolchain
# -----------------------------
for pkg in binutils-2.41 gcc-13.2.0 glibc-2.38; do
    echo "Building $pkg..."
    tar -xf $pkg.tar.* 2>/dev/null || true
    mkdir -p build-$pkg && cd build-$pkg
    if [[ $pkg == "gcc-13.2.0" ]]; then
        ../gcc-13.2.0/contrib/download_prerequisites
        ../gcc-13.2.0/configure --prefix=/usr --enable-languages=c,c++ --disable-multilib
    elif [[ $pkg == "glibc-2.38" ]]; then
        ../glibc-2.38/configure --prefix=/usr
    else
        ../$pkg/configure --prefix=/usr --disable-multilib
    fi
    make -j$(nproc)
    make DESTDIR=$ROOTFS install
    cd $SRC
done

# -----------------------------
# 4️⃣ Build core utilities
# -----------------------------
for pkg in coreutils-9.3 findutils-4.9.0 sed-4.9 grep-3.11 tar-1.35 gzip-1.12 xz-5.4.4 util-linux-2.39; do
    echo "Building $pkg..."
    tar -xf $pkg.tar.* 2>/dev/null || true
    mkdir -p build-$pkg && cd build-$pkg
    ../$pkg/configure --prefix=/usr
    make -j$(nproc)
    make DESTDIR=$ROOTFS install
    cd $SRC
done

# -----------------------------
# 5️⃣ Linux headers
# -----------------------------
tar -xf linux-6.4.12.tar.xz
cd linux-6.4.12
make headers_install INSTALL_HDR_PATH=$ROOTFS/usr
cd $SRC

# -----------------------------
# 6️⃣ Build systemd
# -----------------------------
tar -xf systemd-254.tar.gz
mkdir -p build-systemd && cd build-systemd
../systemd-254/configure --prefix=/usr --sysconfdir=/etc
make -j$(nproc)
make DESTDIR=$ROOTFS install
cd $SRC

# -----------------------------
# 7️⃣ Networking
# -----------------------------
for pkg in iproute2-6.4.0 dhcpcd-9.5.7 dbus-1.16.10 polkit-0.118; do
    echo "Building $pkg..."
    tar -xf $pkg.tar.* 2>/dev/null || true
    mkdir -p build-$pkg && cd build-$pkg
    if [[ $pkg == "dbus-1.16.10" ]]; then
        ../dbus-1.16.10/configure --prefix=/usr --sysconfdir=/etc
    elif [[ $pkg == "polkit-0.118" ]]; then
        ../polkit-0.118/configure --prefix=/usr --sysconfdir=/etc
    else
        ../$pkg/configure --prefix=/usr
    fi
    make -j$(nproc)
    make DESTDIR=$ROOTFS install
    cd $SRC
done

# -----------------------------
# 8️⃣ Build graphics / X11 libraries
# -----------------------------
for pkg in libdrm-2.4.112 mesa-23.3.0 xorg-server-21.1.9 \
           libX11-1.8.5 libXext-1.4.2 libXrender-0.9.12 libXrandr-1.6.3 \
           libXfixes-6.0.0 libXcursor-1.2.0 libXi-1.8 libXinerama-1.1.4 \
           libXxf86vm-1.1.5 libxcb-1.15 freetype-2.13.0 fontconfig-2.14.2 \
           harfbuzz-7.1.0 libxkbcommon-1.5.0; do
    echo "Building $pkg..."
    tar -xf $pkg.tar.* 2>/dev/null || true
    mkdir -p build-$pkg && cd build-$pkg
    ../$pkg/configure --prefix=/usr
    make -j$(nproc)
    make DESTDIR=$ROOTFS install
    cd $SRC
done

# -----------------------------
# 9️⃣ Build XFCE + LightDM
# -----------------------------
for pkg in xfce4-4.18 lightdm-1.32.0; do
    echo "Building $pkg..."
    tar -xf $pkg.tar.* 2>/dev/null || true
    mkdir -p build-$pkg && cd build-$pkg
    ../$pkg/configure --prefix=/usr
    make -j$(nproc)
    make DESTDIR=$ROOTFS install
    cd $SRC
done

# -----------------------------
# 🔟 Create initramfs
# -----------------------------
echo "Creating initramfs..."
mkdir -p $ROOTFS/{dev,proc,sys,tmp}
cat > $ROOTFS/init <<'EOF'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
echo "Booted minimal initramfs!"
/usr/bin/dbus-daemon --system &
exec startxfce4
EOF
chmod +x $ROOTFS/init

cd $ROOTFS
sudo find . | cpio -H newc -o | gzip > $INITRAMFS_IMG

echo "✅ Initramfs created at $INITRAMFS_IMG"
echo "All packages, kernel, XFCE desktop, and minimal /dev nodes built. Bootable distro ready!"
