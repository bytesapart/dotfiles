#!/bin/bash

# This script installs some of the post-installation scripts that I need
# the objective of this script would be, in it's final state, to
# a. Install all the pacman softwares I need
# b. Copy all the configurations that I would need.
# Therefore, this script will be a post installation script that will set up a lot of environment for me
# after the `archinstall` has been run once the arch iso boots up

# First off, do a pacman -Syyu
# Some explainations
# pacman -Syu 
# 	updates your databases if the repositories haven't been checked recently, and upgrades any new package versions.
#
# pacman -Syyu
# 	forces updates of your databases for all repositories (even if it was just updated recently) and upgrades any new package versions.
#
# pacman -Syuu
# 	upgrades packages and also downgrades packages (if you happen to have a newer version than in the repository). 
# 	Normally this should not be used. Only if you're trying to fix a specific issue due to a new package being removed from the repository.
# pacman -Qdtq : Remove all unwanted orphaned packages
 sudo pacman -Syyu --noconfirm


# First step would be to pacman install git, llvm, clang and the like
sudo pacman -S git llvm clang python python-pip firefox --noconfirm
sudo pacman -S base-devel --noconfirm
sudo pacman -S cmake libtool make perl pkg-config ninja diffutils --noconfirm # Neovim dependencies
sudo pacman -S dbus fontconfig freetype2 hicolor-icon-theme lcms2 libglvnd librsync libx11 libxu libxkbcommon-x11 wayland imagemahick libcanberra python-pygments libxcursor libxinerama libxrandr wayland-protocols --noconfirm  # Kitty Dependencies
sudo pacman -S python-sphinx python-sphinx-furo python-sphinxext-opengraph python-sphinx-copybutton python-sphinx-inline-tabs --noconfirm  # Kitty Manual Dependencies
# Audio and misc.
sudo pacman -S zip unzip zsh neofetch brightnessctl zathura libreoffice alsa-utils pipewire-alsa pipewire-pulse pipewire-jack qjackctl pavucontrol qbittorrent vlc libinput --noconfirm
# KVM/Virtual Manager
sudo pacman -S virt-manager qemu vde2 dnsmasq bridge-utils openbsd-netcat --noconfirm
sudo pacman -S ebtables iptables libguestfs dmidecode --noconfirm


# Git configurations
git config --global user.name "Osama Iqbal"
git config --global user.email iqbal.osama@icloud.com

# Create the Project directory and pull in things
cd ~
if [[ ! -d "Project" ]]; then
  mkdir Project
fi
cd Project

# Use clang as the main build compiler
export CC=/usr/bin/clang
export CXX=/usr/bin/clang++

# Pikaur Build
if [[ ! -d "pikaur" ]]; then
  git clone https://aur.archlinux.org/pikaur.git
  cd pikaur
  makepkg -fsri
  cd ~/Project
else
  echo "pikaru already exists. Skipping build..."
fi
pikaur -S rar --noconfirm

# Neovim Build
if [[ ! -d "neovim" ]]; then
  git clone https://github.com/neovim/neovim.git
  cd neovim
  mkdir .deps
  cd .deps
  cmake -G Ninja ../third-party/
  ninja
  cd ..
  mkdir build
  cd build
  cmake -G Ninja -D CMAKE_BUILD_TYPE=RelWithDebInfo ..
  ninja
  sudo ninja install
  git config --global core.editor nvim
  git config --global --add safe.directory /home/osama/Project/neovim
  cd ~/Project
else
  echo "neovim already exists. Skipping build..."
fi


# kitty build


# ssh stuff
# cd ~
# mkdir .ssh
# chmod 700 .ssh
# cp ../Downloads/id_rsa.pub
# cp ../Downloads/id_rsa
# chmod 600 id_rsa
# chmod 644 id_rsa.pub



# cd linux-package
# sudo cp -R bin/ /usr/
# sudo cp -R lib/ /usr/
# sudo cp -R share/ /usr/

# i3-msg reload
# pikaur -S nerd-fonts-fira-code --noconfirm

# git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 ; nvim
# cd ~/.config/nvim
# mkdir lua/custom
# cp examples/init.lua lua/custom/init.lua
# cp examples/chadrc.lua lua/custom/chadrc.lua

# sudo nvim /etc/udev/rules.d/backlight.rules # Remember to copy file in configs!

# echo "options hid_apple fnmode=0" | sudo tee -a /etc/modprobe.d/hid_apple.conf
# sudo mkinitcpio -p linux

# sudo systemctl enable libvirtd.service
# sudo systemctl start libvirtd.service
# sudo usermod -a -G libvirt $(whoami)
# sudo systemctl restart libvirtd.service
