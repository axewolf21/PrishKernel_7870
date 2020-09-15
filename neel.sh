#!/bin/bash
echo "Setting Up Environment"
echo ""
export CROSS_COMPILE=../toolchain/gcc-linaro-7.5.0/bin/aarch64-linux-gnu-
export ARCH=arm64
export ANDROID_MAJOR_VERSION=q
export PLATFORM_VERSION=10.0.0
export USE_CCACHE=1
chmod a+x AnyKernel/zip.sh # if exists ofc
clear
CACHE()
{
rm ./arch/arm64/boot/Image
rm ./arch/arm64/boot/Image.gz
rm Image
rm dtb
rm *.zip
rm ./arch/arm64/boot/dts/*.dtb
rm ./AIK/split_img/boot.img-dt
rm ./AIK/split_img/boot.img-zImage
}
CLEAN()
{
make clean && make mrproper
}
BUILD()
{
echo "#"
echo "Building DTB"
echo "#"
make j7velte_defconfig
DTS=arch/arm64/boot/dts
make exynos7870-j7velte_sea_open_00.dtb exynos7870-j7velte_sea_open_01.dtb exynos7870-j7velte_sea_open_03.dtb
./tools/dtbtool "$DTS"/ -o dtb
echo "Cleanup DTB"
rm ./"$DTS"/*.dtb
echo "#"
echo "Building zImage"
echo "#"
make j7velte_defconfig
# REMINDER: [DISABLE FROM CONFIG OR IT WILL OVERLAP]
make CONFIG_LOCALVERSION=" ZEUS -Q v1 J701X"
CPU=`nproc --all`
make -j"$CPU"
cp ./arch/arm64/boot/Image ./Image
}
AIK()
{
echo "#"
echo "Making Image-AIK"
echo "#"
rm ./AIK/split_img/boot.img-dt
rm ./AIK/split_img/boot.img-zImage
rm image-new.img
cp ./arch/arm64/boot/Image ./Image
cp ./arch/arm64/boot/Image ./AIK/split_img/boot.img-zImage
cp dtb ./AIK/split_img/boot.img-dt
./AIK/repackimg.sh
cp ./AIK/image-new.img ./Flashable/boot.img
cd Flashable
./zip.sh
cd ..
}
ANYKERNEL()
{
echo "#"
echo "AnyKernel"
echo "#"
cd AnyKernel
cp ../dtb ./
cp ../arch/arm64/boot/Image ./
./zip.sh
cd ..
}
echo "Select"
echo "1 = Clear Cache"
echo "2 = Dirty Build"
echo "3 = Clean Build"
echo "4 = AIK"
echo "5 = AnyKernel"
echo "6 = Exit"
read n
if [ $n -eq 1 ]; then
CACHE
CLEAN
clear
elif [ $n -eq 2 ]; then
CACHE
clear
BUILD
elif [ $n -eq 3 ]; then
CACHE
clear
CLEAN
clear
BUILD
echo "##"
echo "Kernel Compiled"
echo "##"
elif [ $n -eq 4 ]; then
AIK
elif [ $n -eq 5 ]; then
ANYKERNEL
elif [ $n -eq 6 ]; then
exit
fi
