#!/bin/sh

while getopts d:s:o: opts; do
  case ${opts} in
    d) ROOTDEV=${OPTARG} ;;
    s) ROOTDIR=${OPTARG} ;;
    o) OUTPUT=${OPTARG} ;;
  esac
done

if [ -z "$ROOTDEV" ]; then
  ROOTDEV=mmcblk0p7
fi

if [ -z "$ROOTDIR" ]; then
  ROOTDIR=
fi

if [ -z "$OUTPUT" ]; then
  OUTPUT=initrd.img
fi

export INIT=/sbin/init

echo "Root Device: $ROOTDEV"
echo "Root Dir: $ROOTDIR"

# fetch busybox
./get_busybox.sh
if [ $? -ne 0 ]; then
    echo "Failed getting busybox, exitting..."
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
rm -f $OUTPUT
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
find . | cpio -o -H newc > ../$OUTPUT
cd ..

# cleanup
echo "Final cleanup..."
rm -rf out

echo "Initrd created: $OUTPUT"
