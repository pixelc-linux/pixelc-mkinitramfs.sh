#!/bin/sh

# root device
ROOTDEV="mmcblk0p7"
# directory on root device with the actual rootfs
ROOTDIR="/"
# the init program
INIT="/sbin/init"

# output file name
OUTFILE="initrd.img"

help() {
    echo "Usage: " $0 " [arguments]"
    echo "Available options:"
    echo "  -h           print this message"
    echo "  -o FILENAME  write into FILENAME (default: $OUTFILE)"
    echo "  -d DEVICE    the partition containing rootfs (default: $ROOTDEV)"
    echo "  -s PATH      the directory containing rootfs (default: $ROOTDIR)"
    echo "  -i INIT      the init program to launch (default: $INIT)"
    echo ""
    echo "By default, rootfs is on /data (mmcblk0p7), not in any subdir."
    echo "The -s option is intended for dual boot with Android if you want to"
    echo "preserve your user data, while the -d option is typically for when"
    echo "you want to install Linux onto the /system partition (mmcblk0p4)."
    echo "Overriding -i is only for if your rootfs doesn't use /sbin/init."
}

while getopts o:d:s:i:h OPT; do
    case $OPT in
        o) OUTFILE=$OPTARG ;;
        d) ROOTDEV=$OPTARG ;;
        s) ROOTDIR=$OPTARG ;;
        i) INIT=$OPTARG ;;
        h) help; exit 0 ;;
        \?)
            echo "Unrecognized option: $OPTARG"
            help
            exit 1
        ;;
    esac
done

echo "Generating initrd for rootfs in $ROOTDIR on partition" \
     "$ROOTDEV with init executable $INIT..."
echo ""

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
rm -f $OUTFILE
rm -rf output

# pre-populate ramdisk structure
echo "Creating directory structure..."
mkdir output
mkdir output/dev
mkdir output/lib
mkdir output/sys
mkdir -p output/mnt/root

# config file
echo "Generating config file..."
cat << EOF >> output/conf
export ROOTDEV="${ROOTDEV}"
export ROOTDIR="${ROOTDIR}"
export INIT="${INIT}"
EOF

echo "Copying binaries..."
cp skel/init downloaded/busybox output

echo "Copying firmware..."
cp -R firmware output/lib

# create the ramdisk
echo "Creating initrd..."
cd output
find . | cpio -o -H newc > ../$OUTFILE
cd ..

# cleanup
echo "Final cleanup..."
rm -rf output

echo "Initrd created: $OUTFILE"
