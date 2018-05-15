# Minimal Pixel C initial ramdisk generator

This generates a minimal initial ramdisk for a Pixel C that simply mounts
the root filesystem and switches to it.

To use, simply exec:

```
./mkinitramfs.sh
```

You will need a `firmware_all.tar.gz` in the current directory. You can get it
by running [this](https://github.com/pixelc-linux/pixelc-get_firmware.sh).

You can also provide a custom path to it as well as other useful things, run
the script with `-h` for more detailed information.

The script will automatically fetch an appropriate Busybox binary.
