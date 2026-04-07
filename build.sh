#!/bin/bash

ca65 main.asm -o main.o
ld65 main.o -C linker.cfg -o aetherbound.nes

echo "Build complete: aetherbound.nes"