#!/usr/bin/env bash

sudo apt update

# Install scrcpy
sudo apt install ffmpeg libsdl2-2.0-0 adb wget \
                 gcc git pkg-config meson ninja-build libsdl2-dev \
                 libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev \
                 libswresample-dev libusb-1.0-0 libusb-1.0-0-dev

git clone https://github.com/Genymobile/scrcpy ~/scrcpy
$HOME/scrcpy/install_release.sh


# Add user to plugdev group
sudo usermod -aG plugdev $USER


# Disable mouse cursor
sudo apt install unclutter
echo "exec --no-startup-id unclutter -idle 0.5 -root" >> $HOME/.config/i3/config


# Install wiringOP
cd
git clone https://github.com/orangepi-xunlong/wiringOP.git -b next --depth=1
cd wiringOP
sudo ./build clean
sudo ./build