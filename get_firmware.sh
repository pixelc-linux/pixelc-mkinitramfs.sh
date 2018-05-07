#!/bin/sh

FIRMWARE_GIT="git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git"

echo "Getting firmware..."

if [ -d "firmware" ]; then
    echo "Firmware already found, skipping..."
    exit 0
fi

if [ ! -x "$(command -v git)" ]; then
    echo "Git is not installed, exitting..."
    exit 1
fi

if [ ! -d "linux-firmware" ]; then
    git clone --depth 1 "$FIRMWARE_GIT" linux-firmware
    if [ $? -ne 0 ]; then
        echo "Git failed, exitting..."
        exit 1
    fi
fi

mkdir -p firmware/brcm
mkdir -p firmware/nvidia/gm20b
mkdir -p firmware/nvidia/tegra210

# Broadcom fw
cp brcmfmac4354* firmware/brcm
cp linux-firmware/brcm/brcmfmac4354* firmware/brcm

# Maxwell fw
cp -R linux-firmware/nvidia/gm20b/* firmware/nvidia/gm20b

# Tegra fw
cp -R linux-firmware/nvidia/tegra210/* firmware/nvidia/tegra210

echo "Done getting firmware."
