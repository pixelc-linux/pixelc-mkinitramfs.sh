#!/bin/sh

# root device
export ROOTDEV=mmcblk0p7
# directory on root device with the actual rootfs
export ROOTDIR=
export INIT=/sbin/init

# cleanup
rm -rf out

# pre-populate ramdisk structure
mkdir out
mkdir out/dev
mkdir out/sys
mkdir -p out/mnt/root

# config file
cat << EOF >> out/conf
export ROOTDEV="${ROOTDEV}"
export ROOTDIR="${ROOTDIR}"
export INIT="${INIT}"
EOF

cp init busybox out
cp -R lib out

# create the ramdisk
cd out
find . | cpio -o -c -H newc > ../initrd.img
cd ..

# cleanup
rm -rf out
