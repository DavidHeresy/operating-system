#!/bin/bash


# -- CONFIG --

# TODO: Ask for confirmation of these values or enter new ones.

BOOT_SIZE="200MiB"
SWAP_SIZE="4GiB"
ROOT_SIZE="20GiB"

KEYMAP="de-latin1-nodeadkeys"
TIMEZONE="Europe/Berlin"
LANG="de_DE.UTF-8"

HOSTNAME="PC"
USER="david"


# -- CHECK FIRMWARE --

if [[ $(ls /sys/firmware/efi/efivars > /dev/null 2>&1) ]]; then
    echo -e "\nUEFI firmware is not supported."
    exit 1
fi


# -- SET KEYBOARD LAYOUT --

loadkeys $KEYMAP &&


# -- SHOW DISKS --

echo -e "\nBlock devices:" &&
lsblk &&


# -- SELECT DISK --

echo -e "\n"

while true
do
    read -p "Enter target block device (e.g. sda): " disk

    if [[ ${#disk} -ne 3 ]]; then
        echo -e "Please enter a disk from the list."
        continue
    fi

    if [[ $disk != sd* ]]; then
        echo -e "Please enter a disk from the list."
        continue
    fi

    check=$(lsblk | grep $disk)
    if [[ -z "${check// }" ]]; then 
        echo -e "Please enter a disk from the list."
        continue
    fi

    break
done


# -- CONFIRMATION --

while true
do
    read -p "Are you sure you want to partition /dev/$disk? (y/N) " answer

    case $answer in
        [yY]* ) break;;
        [nN]* ) exit;;
        * ) continue;;
    esac
done


# -- CLEAN THE DISK --

dd if=/dev/zero of=/dev/$disk bs=512 count=1 &&


# -- CREATE PARTITIONS --

echo ", 4MiB, 21686148-6449-6E6F-744E-656564454649, *" | \
    sfdisk --lable gpt /dev/$disk &&

echo ", $BOOT_SIZE"     | sfdisk --append /dev/$disk &&
echo ", $SWAP_SIZE, S"  | sfdisk --append /dev/$disk &&
echo ", $ROOT_SIZE"     | sfdisk --append /dev/$disk &&
echo ","                | sfdisk --append /dev/$disk &&


# -- PARTITIONS --

boot_part="/dev/$disk""2" &&
swap_part="/dev/$disk""3" &&
root_part="/dev/$disk""4" &&
home_part="/dev/$disk""5" &&


# -- FILE SYSTEMS --

mkfs.ext4 $boot_part &&
mkfs.ext4 $root_part &&
mkfs.ext4 $home_part &&

mkswap $swap_part &&
swapon $swap_part &&


# -- MOUNT PARTITIONS --

mount $root_part /mnt &&

mkdir /mnt/boot &&
mkdir /mnt/home &&

mount $home_part /mnt/home &&
mount $boot_part /mnt/boot &&


# -- INSTALL BASE SYSTEM --

basestrap /mnt \
    base base-devel \
    runit elogind-runit \
    linux linux-firmware \
    grub amd-ucode intel-ucode \
    man-db man-pages texinfo \
    dhcpcd wpa_supplicant \
    connman-runit connman-gtk &&


# -- FSTAB --

fstabgen -U /mnt >> /mnt/etc/fstab &&


# -- CHROOT --

alias cr="artools-chroot /mnt" &&


# -- SYSTEM CLOCK --

cr ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime &&
cr hwclock --systohc &&


# -- LOCALIZATION --

cr echo "$LANG UTF-8" >> /etc/locale.gen &&
cr locale-gen &&
cr echo "LANG=$LANG" > /etc/locale.conf &&


# -- KEYMAP --

cr echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf &&


# -- HOSTNAME --

cr echo "$HOSTNAME" > /etc/hostname &&


# -- HOSTS --

cr echo "127.0.0.1 localhost" >> /etc/hosts &&
cr echo "::1       localhost" >> /etc/hosts &&
cr echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts &&


# -- BOOT LOADER --

cr grub-install --target=i386-pc /dev/$disk &&
cr grub-mkconfig -o /boot/grub/grub.cfg &&


# -- PASSWORD --

cr passwd &&


# -- USER --

cr useradd -m $USER &&
cr passwd $USER &&


# -- NETWORK --

cr ln -s /etc/runit/sv/connmand /etc/runit/runsvdir/default &&


# -- UNMOUNT AND REBOOT --

umount -R /mnt &&
reboot
