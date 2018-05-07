# Minimal Pixel C initial ramdisk generator

This generates a minimal initial ramdisk for a Pixel C that simply mounts
the root filesystem and switches to it.

To use, simply exec:

```
./mkinitrd.sh
```

The script will automatically fetch an appropriate Busybox binary as well
as firmware for bluetooth and graphics/tegra.

You can prevent auto-fetching by placing the firmware in the "firmware"
directory (create it) and busybox in the current directory. Otherwise, it
will download firmware from linux-firmware.git and a static Busybox binary
for aarch64 from Debian.