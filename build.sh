#!/bin/bash

function compile() 
{

source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 50G
export ARCH=arm64
export KBUILD_BUILD_HOST=WSLUbuntu
export KBUILD_BUILD_USER="Maddox"
workspace=$(pwd)
othersource=$(dirname "$workspace")
cd "$othersource" || exit
 if ! [ -d "clang" ]; then
git clone --depth=1  https://gitlab.com/LeCmnGend/proton-clang.git -b clang-13 clang
 fi
 cd "$workspace" || exit
echo "try setup kernelSU"
 if ! [ -d "KernelSU" ]; then
curl -LSs "https://raw.githubusercontent.com/rsuntk/KernelSU/main/kernel/setup.sh" | bash -s main
 fi

 if ! [ -d "out" ]; then
echo "Kernel OUT Directory Not Found . Making Again"
mkdir out


make O=out ARCH=arm64 ares_user_defconfig

 fi

PATH=${othersource}/clang/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC="clang" \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${othersource}/clang/bin/aarch64-linux-gnu-" \
                      CROSS_COMPILE_ARM32="${othersource}/clang/bin/arm-linux-gnueabi-" \
		      LD=ld.lld \
                      STRIP=llvm-strip \
                      AS=llvm-as \
		      AR=llvm-ar \
		      NM=llvm-nm \
		      OBJCOPY=llvm-objcopy \
   		      OBJDUMP=llvm-objdump \
                      CONFIG_NO_ERROR_ON_MISMATCH=y 2>&1 | tee error.log 
}

compile

