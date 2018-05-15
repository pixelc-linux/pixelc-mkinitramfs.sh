# Minimal Pixel C initial ramdisk generator

This generates a minimal initial ramdisk for a Pixel C that simply mounts
the root filesystem and switches to it.

To use, simply exec:

```
./mkinitramfs.sh
```

The script will automatically fetch an appropriate Busybox binary as well
as firmware for bluetooth and graphics/tegra.

You can prevent auto-fetching by placing the firmware in the "firmware"
directory (create it) and busybox in the "downloaded" directory. Otherwise,
it will download firmware from linux-firmware.git and a static Busybox binary
for aarch64 from Debian.

While getting firmware, the script also creates the following archives:

- `firmware_all.tar.gz`
- `firmware_brcm_extra_only.tar.gz`

The first archive contains all the firmware needed to bring up the onboard
hardware. The second archive contains only the parts not present out of box
in the `linux-firmware` repository/packages. You can use these to get the
firmware in your rootfs, as opposed to just initramfs; if your distro provides
a `linux-firmware` package, it is recommended to install that and then use the
`firmware_brcm_extra_only.tar.gz` archive to supply the rest of the files,
otherwise you can use the `firmware_all.tar.gz` archive. The primary reason
to use `linux-firmware` as whole is for potential peripherals needing
proprietary blobs.
