#!/bin/bash

set -xe

cp -r /usr/share/archiso/configs/releng build/releng
cp -r ./src ./build/releng/airootfs/root/archinstall
sudo mkarchiso -v -w /tmp/archiso-tmp -o ./build/out ./build/releng
sudo rm -rf /tmp/archiso-tmp
