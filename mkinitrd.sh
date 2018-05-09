#!/bin/sh

# root device
ROOTDEV="mmcblk0p7"
# directory on root device with the actual rootfs
ROOTDIR="/"
# mount options
MOUNTOPTS_RW="rw,noatime,nodirtime,errors=panic"
MOUNTOPTS="ro"
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
    echo "  -m PARAMS    the options passed to mount (default: $MOUNTOPTS)"
    echo "  -i INIT      the init program to launch (default: $INIT)"
    echo ""
    echo "By default, rootfs is on /data (mmcblk0p7), not in any subdir."
    echo "Keep in mind that using a subdirectory might not always work right"
    echo "and is considered EXPERIMENTAL, so use at your own risk. It exists"
    echo "only to cover the case when you want to dual boot your system with"
    echo "Android."
    echo "The -m option lets you alter the options with which the filesystem"
    echo "is mounted. By default it's 'ro' but for subdir rootfs it has to be"
    echo "read-write, so $MOUNTOPTS_RW is used."
    echo "The -d option allows you to choose the partition on which your root"
    echo "filesystem is present. You might want to use this if you repartition"
    echo "your device or if you installed the OS into /system (mmdcblk0p4)."
    echo "Overriding -i is only for if your rootfs doesn't use /sbin/init."
}

while getopts o:d:s:i:m:h OPT; do
    case $OPT in
        o) OUTFILE=$OPTARG ;;
        d) ROOTDEV=$OPTARG ;;
        s)
            ROOTDIR=$OPTARG
            if [ -n "$ROOTDIR" ] && [ "$ROOTDIR" != "/" ]; then
                MOUNTOPTS="$MOUNTOPTS_RW"
            fi
        ;;
        m) MOUNTOPTS=$OPTARG ;;
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
     "$ROOTDEV (mounted with '$MOUNTOPTS') with init executable $INIT..."
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
echo ""
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
mkdir -p output/mnt/data

# config file
echo "Generating config file..."
cat << EOF >> output/conf
export ROOTDEV="${ROOTDEV}"
export ROOTDIR="${ROOTDIR}"
export MOUNTOPTS="${MOUNTOPTS}"
export INIT="${INIT}"
EOF

echo "Copying binaries..."
cp skel/init downloaded/busybox output

echo "Copying firmware..."
cp -R firmware output/lib

# list contents first
echo ""
echo "Initrd contents:"
cd output
find .

# create the ramdisk
echo ""
echo "Creating initrd..."
find . | cpio -o -H newc > ../$OUTFILE
cd ..

# cleanup
echo "Final cleanup..."
rm -rf output

echo "Initrd created: $OUTFILE"
