#!/bin/bash

apt update
apt install -y git build-essential make

# Build cc65 (NES toolchain)
git clone https://github.com/cc65/cc65.git
cd cc65
make
make install

echo "cc65 installed!"