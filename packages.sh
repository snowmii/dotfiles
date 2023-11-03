#!/bin/bash

pacstrap -i /mnt base base-devel linux linux-lts linux-headers linux-firmware intel-ucode sudo networkmanager dhpcd pulseaudio bluez git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ~
yay -S man vim fzf neofetch awesome alacritty nautilus sddm refind xorg-xrandr rofi nvidia nvidia-utils lib32-nvidia-utils nvidia-settings usbutils opentabletdriver google-chrome discord code cava cmatrix extra/zip extra/nerd-fonts extra/adobe-source-han-sans-tw-fonts extra/adobe-source-han-sans-tw-fonts extra/noto-fonts-emoji catppuccin-gtk-theme-macchiato catppuccin-cursors-macchiato 
