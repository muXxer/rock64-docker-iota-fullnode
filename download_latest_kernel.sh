#!/bin/sh

echo "Downloading latest kernel from https://github.com/ayufan-rock64/linux-build/releases..."
latest_file=`curl -s https://api.github.com/repos/ayufan-rock64/linux-build/releases | grep browser_download_url | grep linux-image | grep -v linux-image-4.4. | grep -v dbg | grep arm64.deb | head -n 1 | cut -d '"' -f 4`
curl -L $latest_file -O

file_name=`echo $latest_file | rev | cut -d '/' -f 1 | rev`
echo "Downloaded:"
echo "   File name = $file_name"

echo "Installing the downloaded kernel image:"
sudo dpkg -i $file_name
