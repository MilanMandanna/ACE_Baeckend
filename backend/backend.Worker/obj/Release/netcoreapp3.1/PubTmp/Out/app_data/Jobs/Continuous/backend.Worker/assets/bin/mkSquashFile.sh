#!/bin/sh
cd "$0"

echo "$2"
echo "$3"
#set permissions properly
cd temp
find . -exec chmod 777 {} \;
cd ..

mksquashfs "$2" "$3"

