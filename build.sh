#!/bin/bash
workspace=$(pwd)
othersource=$(dirname "$workspace")
function compile() 
{

source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 50G
export ARCH=arm64
export KBUILD_BUILD_HOST=WSLUbuntu
export KBUILD_BUILD_USER="Maddox"
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

PATH="${othersource}/clang/bin:${PATH}" \
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
function ak3()
{
	 cd "$othersource" || exit
	 rm -rf Anykernel3
 	 echo "===== 克隆 AnyKernel3 ====="

git clone --depth=1 https://github.com/osm0sis/AnyKernel3.git Anykernel3
cd "$workspace/"

sed -i 's/do.devicecheck=1/do.devicecheck=0/g' $othersource/Anykernel3/anykernel.sh
sed -i 's!BLOCK=/dev/block/platform/omap/omap_hsmmc.0/by-name/boot;!BLOCK=auto;!g' $othersource/Anykernel3/anykernel.sh
sed -i 's/IS_SLOT_DEVICE=0;/is_slot_device=auto;/g'  $othersource/Anykernel3/anykernel.sh
cp $workspace/out/arch/arm64/boot/Image.gz-dtb $othersource/Anykernel3
cd $othersource/Anykernel3
zip -r9 Test-OSS-KERNEL-ARES-S.zip
}

compile
ak3

