#!/bin/sh

FIRMWARE_GIT="git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git"
BCMDHD_CAL="https://android.googlesource.com/device/google/dragon/+/oreo-mr1-iot-release/bcmdhd.cal?format=TEXT"
BCMDHD_NAME="brcmfmac4354-sdio.txt"

echo "Getting firmware..."

mkdir -p downloaded

if [ -d "firmware" ]; then
    echo "Firmware already found, skipping..."
    exit 0
fi

if [ ! -d "downloaded/linux-firmware" ]; then
    if [ ! -x "$(command -v git)" ]; then
        echo "Git is not installed, exitting..."
        exit 1
    fi
    git clone --depth 1 "$FIRMWARE_GIT" downloaded/linux-firmware
    if [ $? -ne 0 ]; then
        echo "Git failed, exitting..."
        exit 1
    fi
fi

if [ ! -d "downloaded/$BCMDHD_NAME" ]; then
    if [ ! -x "$(command -v wget)" ]; then
        echo "Wget is not installed, exitting..."
        exit 1
    fi
    # should be on most systems
    if [ ! -x "$(command -v perl)" ]; then
        echo "Perl is not installed, exitting..."
        exit 1
    fi
    wget "$BCMDHD_CAL" -O  "downloaded/$BCMDHD_NAME.base64"
    if [ $? -ne 0 ]; then
        echo "Wget failed, exitting..."
        exit 1
    fi
    cat "downloaded/$BCMDHD_NAME.base64" | \
        perl -MMIME::Base64 -ne 'printf "%s\n",decode_base64($_)' > \
            "downloaded/$BCMDHD_NAME"
    rm -f "downloaded/$BCMDHD_NAME.base64"
fi

mkdir -p firmware/brcm
mkdir -p firmware/nvidia/gm20b
mkdir -p firmware/nvidia/tegra210

# Broadcom fw
cp "downloaded/$BCMDHD_NAME" firmware/brcm
cp downloaded/linux-firmware/brcm/brcmfmac4354* firmware/brcm

# Maxwell fw
cp -R downloaded/linux-firmware/nvidia/gm20b/* firmware/nvidia/gm20b
# this is a symlink so we need to expand that
rm firmware/nvidia/gm20b/gr/sw_method_init.bin
cp downloaded/linux-firmware/nvidia/gm200/gr/sw_method_init.bin firmware/nvidia/gm20b/gr

# Tegra fw
cp -R downloaded/linux-firmware/nvidia/tegra210/* firmware/nvidia/tegra210

# licenses
cp downloaded/linux-firmware/LICENCE.broadcom_bcm43xx firmware
cp downloaded/linux-firmware/LICENCE.nvidia firmware

echo "Done getting firmware."
