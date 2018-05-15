#!/bin/sh

FIRMWARE_GIT="git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git"

GOOGLE_URL="https://android.googlesource.com/device/google/dragon/+/oreo-mr1-iot-release"
BCMDHD_URL="${GOOGLE_URL}/bcmdhd.cal?format=TEXT"
BCMDHD_NAME="brcmfmac4354-sdio.txt"
BCMHCD_URL="${GOOGLE_URL}/bluetooth/BCM4350C0_003.001.012.0364.0754.hcd?format=TEXT"
BCMHCD_NAME="BCM4354.hcd"

echo "Getting firmware..."

mkdir -p downloaded

if [ -d "firmware" ]; then
    echo "Firmware already found, skipping..."
    exit 0
fi

if [ ! -x "$(command -v tar)" ]; then
    echo "Tar is not installed, exitting..."
    exit 1
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

base64_decode() {
    cat "$1.base64" |
        perl -MMIME::Base64 -ne 'printf "%s\n",decode_base64($_)' > "$1"
    rm -f "$1.base64"
}

get_google() {
    if [ ! -f "$1" ]; then
        if [ ! -x "$(command -v wget)" ]; then
            echo "Wget is not installed, exitting..."
            exit 1
        fi
        # should be on most systems
        if [ ! -x "$(command -v perl)" ]; then
            echo "Perl is not installed, exitting..."
            exit 1
        fi
        wget "$2" -O "$1.base64"
        if [ $? -ne 0 ]; then
            echo "Wget failed, exitting..."
            exit 1
        fi
        base64_decode "$1"
    fi
}

get_google "downloaded/$BCMDHD_NAME" "$BCMDHD_URL"
get_google "downloaded/$BCMHCD_NAME" "$BCMHCD_URL"


make_tarball() {
    echo "Creating firmware tarball: $1..."
    rm -rf tarball
    mkdir -p tarball/lib
    cd tarball
    cp -R ../firmware lib
    tar czf "../$1.tar.gz" .
    if [ $? -ne 0 ]; then
        echo "Archiving firmware failed."
        cd ..
        rm -rf tarball firmware
        exit 1
    fi
    cd ..
    rm -rf tarball
}

mkdir -p firmware/brcm

# Broadcom stuff not in linux-firmware
cp "downloaded/$BCMDHD_NAME" firmware/brcm
cp "downloaded/$BCMHCD_NAME" firmware/brcm
cp downloaded/linux-firmware/brcm/brcmfmac4354*.txt firmware/brcm
cp downloaded/linux-firmware/LICENCE.broadcom_bcm43xx firmware/LICENCE.broadcom_bcm4354

# for installation next to full linux-firmware
make_tarball firmware_brcm_extra_only

# Present in linux-firmware
cp downloaded/linux-firmware/brcm/brcmfmac4354*.bin firmware/brcm

mkdir -p firmware/nvidia/gm20b
mkdir -p firmware/nvidia/tegra210

# Maxwell fw
cp -R downloaded/linux-firmware/nvidia/gm20b/* firmware/nvidia/gm20b
# this is a symlink so we need to expand that
rm firmware/nvidia/gm20b/gr/sw_method_init.bin
cp downloaded/linux-firmware/nvidia/gm200/gr/sw_method_init.bin firmware/nvidia/gm20b/gr

# Tegra fw
cp -R downloaded/linux-firmware/nvidia/tegra210/* firmware/nvidia/tegra210

# Nvidia license
cp downloaded/linux-firmware/LICENCE.nvidia firmware

# all firmware needed for the device
make_tarball firmware_all

echo "Done getting firmware."
