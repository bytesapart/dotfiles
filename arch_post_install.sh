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
# PLEASE NOTE: USE archinstall's POST INSTALLATION TO `pacman -S networkmanager` and `systemctl start NetworkManager.service`
 sudo pacman -Syyu --noconfirm


# First step would be to pacman install git, llvm, clang and the like
sudo pacman -S git llvm clang python python-pip firefox --noconfirm
sudo pacman -S base-devel --noconfirm
sudo pacman -S cmake libtool make perl pkg-config ninja diffutils --noconfirm # Neovim dependencies
sudo pacman -S dbus fontconfig freetype2 hicolor-icon-theme lcms2 libglvnd librsync libx11 libxi libxkbcommon-x11 wayland imagemagick libcanberra python-pygments libxcursor libxinerama libxrandr wayland-protocols --noconfirm  # Kitty Dependencies
sudo pacman -S python-sphinx python-sphinx-furo python-sphinxext-opengraph python-sphinx-copybutton python-sphinx-inline-tabs --noconfirm  # Kitty Manual Dependencies
# Audio and misc.
sudo pacman -S zip unzip zsh neofetch brightnessctl zathura alsa-utils pipewire-alsa pavucontrol qbittorrent vlc libinput zathura-cb zathura-djvu zathura-pdf-mupdf zathura-ps xclip gtk2 gimp --noconfirm
# KVM/Virtual Manager
sudo pacman -S virt-manager qemu vde2 dnsmasq bridge-utils openbsd-netcat --noconfirm
sudo pacman -S ebtables libguestfs dmidecode --noconfirm
sudo pacman -S ncurses libevent libutempter wget curl --noconfirm
sudo pacman -S scrcpy xf86-input-wacom --noconfirm
sudo pacman -S usbutils kdiskmark --noconfirm
sudo pacman -S rustup go --noconfirm
sudo pacman -S udisks2 --noconfirm
sudo pacman -S zsh arandr --noconfirm
sudo pacman -S cronie gparted swtpm --noconfirm
sudo pacman -S libreoffice --noconfirm
sudo pacman -S iptables --noconfirm
sudo pacman -S texlive --noconfim

# Git configurations
git config --global user.name "Osama Iqbal"
git config --global user.email iqbal.osama@icloud.com

# Get the SSH keys

cd ~
mkdir .ssh
chmod 700 .ssh
cd .ssh
cp ~/Downloads/ssh.zip .
# echo "Enter the ssh zip URL"
# read ssh_zip_url
# wget $ssh_zip_url
unzip ssh.zip
sudo chmod 600 id_rsa
sudo chmod 644 id_rsa.pub



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

# Install PyNVIM
python -m pip install pynvim


# kitty build
if [[ ! -d "kitty" ]]; then
  git clone https://github.com/kovidgoyal/kitty.git
  cd kitty
  python3 setup.py linux-package
  cd linux-package
  sudo cp -R bin/ /usr/
  sudo cp -R lib/ /usr/
  sudo cp -R share/ /usr/
  cd ~/Project
else
  echo "kitty already exists. Skipping build..."
fi

if [[ ! -d "tmux" ]]; then
  git clone https://github.com/tmux/tmux.git
  cd tmux
  sh autogen.sh
  ./configure && make
  sudo make install
  cd ~/Project
else
  echo "tmux already exists. Skipping build..."
fi


# Install nerd-fonts-fira-code
i3-msg reload
sudo pikaur -S nerd-fonts-fira-code --noconfirm
sudo pikaur -S logiops # For Logitech MX Master 3 mouse

# Install NvChad (TODO: Replace this with your own in the future!)
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 ; nvim
cd ~/.config/nvim
mkdir lua/custom
cp examples/init.lua lua/custom/init.lua
cp examples/chadrc.lua lua/custom/chadrc.lua

# Setup Keychron K2 stuff
echo "options hid_apple fnmode=0" | sudo tee -a /etc/modprobe.d/hid_apple.conf
sudo mkinitcpio -p linux

# Setup UMC202HD stuff
sudo modprobe -r snd_usb_audio
echo "options snd_usb_audio implicit_fb=1" | sudo tee -a /etc/modprobe.d/snd_usb_audio.conf
sudo mkinitcpio -p linux

# Setup KVM stuff
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service
sudo usermod -a -G libvirt $(whoami)
sudo systemctl restart libvirtd.service

cd ~
cd Project
if [[ ! -d "dotfiles" ]]; then
  git clone git@github.com:bytesapart/dotfiles.git  
  cd ~/Project
else
  echo "dotfiles already exists. Skip pulling dotfiles"
fi

# Backlight rules, important for setting up of backlight!
sudo cp ~/Project/dotfiles/etc/udev/rules.d/backlight.rules /etc/udev/rules.d/backlight.rules
sudo chmod 644 /etc/udev/rules.d/backlight.rules

# Touchpad configurations
sudo cp ~/Project/dotfiles/etc/X11/xorg.conf.d/30-touchpad.conf /etc/X11/xorg.conf.d/30-touchpad.conf
sudo chmod 644 /etc/X11/xorg.conf.d/30-touchpad.conf

# Logitech MX Master mouse configuration
sudo cp ~/Project/dotfiles/etc/logid.cfg /etc/logid.cfg
sudo systemctl enable --now logid

cd ~
if [[ ! -d ".config" ]]; then
  mkdir .config
  chmod 755 .config
else
  echo ".config directory already exits"
fi
cp ~/Project/dotfiles/i3/config .config/i3/config
chmod 644 .config/i3/config

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/plugins/zsh-autosuggestions
cp ~/Project/dotfiles/zsh/.zshrc ~/.zshrc

# Copy kitty configurations
mkdir ~/.config/kitty
cp ~/Project/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
cp ~/Project/dotfiles/kitty/current-theme.conf ~/.config/kitty/current-theme.conf
chmod 600 ~/.config/kitty/kitty.conf
chmod 600 ~/.config/kitty/current-theme.conf

# For Milton, checkout Milton, download SDL-2.0.22, change nvim src/system_includes to have SDL2/SDL.h and the like, similartly with third_party/imgui/imgui_impl_sdl/cpp. Change 2.0.8 to 2.0.22 in CMakeLists.txt in the base directory, then build it.

export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
cd ~/Project
if [[ ! -d "milton" ]]; then
  git clone https://github.com/serge-rgb/milton.git
  cd milton
  cd third_party
  wget https://www.libsdl.org/release/SDL2-2.0.22.tar.gz
  tar -zxvf SDL2-2.0.22.tar.gz
  sed -i 's/SDL.h/SDL2\/SDL.h/g' imgui/imgui_impl_sdl.cpp
  sed -i 's/SDL_syswm.h/SDL2\/SDL_syswm.h/g' imgui/imgui_impl_sdl.cpp
  cd ..
  sed -i 's/SDL.h/SDL2\/SDL.h/g' src/system_includes.h
  sed -i 's/SDL_syswm.h/SDL2\/SDL_syswm.h/g' src/system_includes.h

  sed -i 's/SDL2-2.0.8/SDL2-2.0.22/g' CMakeLists.txt
  sed -i 's/SDL2-2.0.8/SDL2-2.0.22/g' build-lin.sh

  ./build-lin.sh
else
  echo "milton already exists. Skipping build..."
fi

cd ~/Project

if [[ ! -d "resume" ]]; then
  git clone git@github.com:bytesapart/resume.git
  cd ~
else
  echo "resume exits. Skipping clone..."
fi

chsh -s `which zsh`
