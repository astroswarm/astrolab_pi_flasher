#!/usr/bin/env sh

RASPBIAN_RELEASE=2016-11-25-raspbian-jessie-lite
RASPBIAN_URL=http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2016-11-29/$RASPBIAN_RELEASE.zip

if [ -e ./tmp/$RASPBIAN_RELEASE.img ]
then
  echo "Raspbian image found."
else
  echo "Raspbian image not found."

  if [ -e ./tmp/$RASPBIAN_RELEASE.zip ]
  then
    echo "Raspbian archive found."
  else
    echo "Raspbian archive not found. Downloading latest..."
    mkdir -p ./tmp
    curl -L -o ./tmp/$RASPBIAN_RELEASE.zip $RASPBIAN_URL
  fi

  echo "Extracting Raspbian archive..."
  unzip ./tmp/$RASPBIAN_RELEASE.zip -d ./tmp
fi

echo "Please flash your SD card with ./tmp/${RASPBIAN_RELEASE}.img using a tool like Etcher.io."
echo "When done, ensure the flashed SD card is mounted."
read -p "Press [Enter] to continue."

echo "Enter target wifi network: "
read WIFI_NETWORK
echo "Enter target wifi password: "
read WIFI_PASSWORD

echo "Enabling SSH..."
touch /Volumes/boot/ssh
echo "Done."

echo "Configuring wifi..."
cat >/Volumes/boot/wpa_supplicant.conf <<EOS
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
country=US
update_config=1
ap_scan=1
network={
  ssid="${WIFI_NETWORK}"
  psk="${WIFI_PASSWORD}"
}
EOS
echo "Done."

echo "Configuration complete. Please eject your SD card."

echo "You can look for your Raspberry Pi on your network with:"
echo "    ping -c 1 google.com &> /dev/null ; arp -a | grep b8:27"
echo " or sudo nmap -sP 10.0.1.0/24 | awk '/^Nmap/{ip=\$NF}/B8:27:EB/{print ip}'"
