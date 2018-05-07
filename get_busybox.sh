#!/bin/sh

BUSYBOX_DEB="http://ftp.debian.org/debian/pool/main/b/busybox/busybox-static_1.27.2-2_arm64.deb"

if [ -f "./busybox" ]; then
    echo "Busybox already found, skipping..."
    exit 0
fi

if [ ! -x "$(command -v ar)" ]; then
    echo "Ar needed to unpack .deb archives, exitting..."
    exit 1
fi

if [ ! -x "$(command -v tar)" ]; then
    echo "Tar needed to unpack .deb archives, exitting..."
    exit 1
fi

mkdir busybox_deb

echo "Getting busybox package..."
wget "$BUSYBOX_DEB" -O busybox_deb/busybox.deb
if [ $? -ne 0 ]; then
    echo "Busybox download fialed, exitting..."
    exit 1
fi

echo "Unpacking busybox package... (1/2)"
cd busybox_deb
ar x busybox.deb
if [ $?  -ne 0 ]; then
    echo "Busybox unpack failed, exitting..."
    cd ..
    rm -rf busybox_deb
    exit 1
fi

echo "Unpacking busybox package... (2/2)"
tar xf data.tar.xz
if [ $? -ne 0 ]; then
    echo "Busybox unpack failed, exitting..."
    cd ..
    rm -rf busybox_deb
    exit 1
fi

echo "Moving busybox binary..."
mv bin/busybox ..
cd ..

echo "Cleaning up temporary files..."
rm -rf busybox_deb
