#!/bin/bash

# Compile LineageOS 18.1 (Android 11) for Samsung Galaxy S7 (herolte)
## This script assumes you have stood up an Ubuntu 22.x resource according to the AWS script. Keep in mind, it is optimized for t2.2xlarge. Cleaned up and compiled with GPT 5.5-mini

sudo apt update

sudo apt install -y \
    git-core gnupg flex bison build-essential zip curl zlib1g-dev \
    gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev \
    x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev \
    libxml2-utils xsltproc unzip fontconfig python-is-python3 \
    ccache tmux

export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
ccache -M 50G

mkdir -p ~/bin
PATH=~/bin:$PATH

if [ ! -f ~/bin/repo ]; then
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
fi

mkdir -p ~/android
cd ~/android

mkdir lineage
cd lineage

# ~15 minutes on my hardware
repo init \
    -u https://github.com/LineageOS/android.git \
    -b lineage-18.1 \
    --git-lfs \
    --no-clone-bundle

# Change me if you are using a different hardware config
repo sync -j8



###############################################################################
# Obtain Samsung proprietary vendor blobs (TheMuppets)
###############################################################################
# Ensure that you are in the lineage-18.1 branch if you are downloading directly.

mkdir -p vendor/samsung

# Option 1: clone directly if you have the correct repository
git clone -b lineage-18.1 \
    <THE_MUPPETS_VENDOR_REPOSITORY> \
    vendor/samsung/universal8890-common

# Option 2: unpack a downloaded vendor tree
# unzip universal8890-common-lineage-18.1.zip
# mv universal8890-common vendor/samsung/

# Verify
test -f vendor/samsung/universal8890-common/universal8890-common-vendor.mk

###############################################################################
# Build
###############################################################################

source build/envsetup.sh

breakfast herolte

tmux new -s lineage

export USE_CCACHE=1
export NINJA_ARGS="-j8"

# WARNING: About 10.5 hours on my hardware
brunch herolte

### All done. Download your zip and md5 sum/ hash from: ~/android/lineage/out/target/product/herolte/
# e.g. lineage-18.1-20260726-UNOFFICIAL-herolte.zip.sha256sum && lineage-18.1-20260726-UNOFFICIAL-herolte.zip
