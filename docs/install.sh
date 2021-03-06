#!/bin/bash


# -- STRICT MODE --

set -euo pipefail


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


# -- SHOW DISKS --

echo -e "\nBlock devices:"
lsblk


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

dd if=/dev/zero of=/dev/$disk bs=512 count=1


# -- CREATE BIOS/GPT/LVM PARTITIONS --

sfdisk -X gpt --force /dev/sda <<PARTITION_TABLE
,4MiB,21686148-6449-6E6F-744E-656564454649
,$BOOT_SIZE
,$SWAP_SIZE,S
,$ROOT_SIZE
,,E6D6D379-F507-44C2-A23C-238F2A3DF928
PARTITION_TABLE


# -- PARTITIONS --

boot_part="/dev/$disk""2"
swap_part="/dev/$disk""3"
root_part="/dev/$disk""4"
home_part="/dev/$disk""5"


# -- FILE SYSTEMS --

mkfs.ext4 $boot_part
mkfs.ext4 $root_part
mkfs.ext4 $home_part

mkswap $swap_part
swapon $swap_part


# -- MOUNT PARTITIONS --

mount $root_part /mnt

mkdir /mnt/boot
mkdir /mnt/home

mount $home_part /mnt/home
mount $boot_part /mnt/boot


# -- INSTALL BASE SYSTEM --

basestrap /mnt \
    base base-devel \
    runit elogind-runit \
    linux linux-firmware \
    grub amd-ucode intel-ucode \
    man-db man-pages texinfo \
    dhcpcd wpa_supplicant \
    connman-runit connman-gtk


# -- FSTAB --

fstabgen -U /mnt >> /mnt/etc/fstab


# -- CHROOT --

artools-chroot /mnt <<CHROOT_ENVIRONMENT
# -- STRICT MODE --

set -euo pipefail


# -- SYSTEM CLOCK --

ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc


# -- LOCALIZATION --

echo "$LANG UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LANG" > /etc/locale.conf


# -- KEYMAP --

echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf


# -- HOSTNAME --

echo "$HOSTNAME" > /etc/hostname


# -- HOSTS --

echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts


# -- BOOT LOADER --

grub-install --target=i386-pc /dev/$disk
grub-mkconfig -o /boot/grub/grub.cfg


# -- NETWORK --

ln -s /etc/runit/sv/connmand /etc/runit/runsvdir/default
CHROOT_ENVIRONMENT


# -- ROOT PASSWORD --

artools-chroot /mnt passwd


# -- USER --

artools-chroot /mnt useradd -m $USER
artools-chroot /mnt passwd $USER


# -- UNMOUNT AND REBOOT --

umount -R /mnt
shutdown -h now

