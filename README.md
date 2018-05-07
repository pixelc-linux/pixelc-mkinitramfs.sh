# Minimal Pixel C initial ramdisk generator

This generates a minimal initial ramdisk for a Pixel C that simply mounts
the root filesystem and switches to it.

To use, simply exec:

   ./mkinitrd.sh

Before doing that, you will want to place a busybox binary for ARM in the
current directory. This git repository does not distribute binaries, so do
that yourself. The script will take care of putting it in the right place.

The script automatically downloads the necessary firmware to be included in
the ramdisk (bluetooth and nvidia).