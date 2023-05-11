#!/bin/sh
cd "$0"

#set permissions properly
cd temp
find . -exec chmod 777 {} \;
cd ..

mksquashfs "$2" "$3"

