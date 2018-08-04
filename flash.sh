#!/usr/bin/env sh

RASPBIAN_URL=http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2018-06-29/2018-06-27-raspbian-stretch-lite.zip
RASPBIAN_ARCHIVE=$(echo $RASPBIAN_URL | sed 's:.*/\(.*\):\1:')
RASPBIAN_IMAGE=$(echo $RASPBIAN_ARCHIVE | sed 's:\(.*\)\.zip:\1.img:')

if [ -e ./tmp/$RASPBIAN_IMAGE ]
then
  echo "Raspbian image found."
else
  echo "Raspbian image not found."

  if [ -e ./tmp/$RASPBIAN_ARCHIVE ]
  then
    echo "Raspbian archive found."
  else
    echo "Raspbian archive not found. Downloading latest..."
    mkdir -p ./tmp
    curl -L -o ./tmp/$RASPBIAN_ARCHIVE $RASPBIAN_URL
  fi

  echo "Extracting Raspbian archive..."
  unzip ./tmp/$RASPBIAN_ARCHIVE -d ./tmp
fi

echo "Please flash your SD card with ./tmp/${RASPBIAN_IMAGE} using a tool like Etcher.io."
echo "When done, ensure the flashed SD card is mounted."
read -p "Press [Enter] to continue."

echo "Enabling SSH..."
touch /Volumes/boot/ssh
echo "Done."

echo "Configuration complete. Please eject your SD card."

echo "You can look for your Raspberry Pi on your network with:"
echo "    ping -c 1 google.com &> /dev/null ; arp -a | grep b8:27"
echo " or sudo nmap -sP 10.0.1.0/24 | awk '/^Nmap/{ip=\$NF}/B8:27:EB/{print ip}'"
