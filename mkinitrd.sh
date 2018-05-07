#!/bin/sh

# root device
export ROOTDEV=mmcblk0p7
# directory on root device with the actual rootfs
export ROOTDIR=
export INIT=/sbin/init

if [ ! -f "./busybox" ]; then
    echo "Busybox binary missing, exitting..."
    exit 1
fi

# fetch firmware
./get_firmware.sh
if [ $? -ne 0 ]; then
    echo "Failed getting firmware, exitting..."
    exit 1
fi

# cleanup
echo "Cleanup..."
rm -rf out

# pre-populate ramdisk structure
echo "Creating directory structure..."
mkdir out
mkdir out/dev
mkdir out/lib
mkdir out/sys
mkdir -p out/mnt/root

# config file
echo "Generating config file..."
cat << EOF >> out/conf
export ROOTDEV="${ROOTDEV}"
export ROOTDIR="${ROOTDIR}"
export INIT="${INIT}"
EOF

echo "Copying binaries..."
cp init busybox out

echo "Copying firmware..."
cp -R firmware out/lib

# create the ramdisk
echo "Creating initrd..."
cd out
find . | cpio -o -c -H newc > ../initrd.img
cd ..

# cleanup
echo "Final cleanup..."
#rm -rf out

echo "Initrd created: initrd.img"
