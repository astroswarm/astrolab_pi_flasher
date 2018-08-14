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
    echo "Raspbian archive not found. Downloading..."
    mkdir -p ./tmp
    curl -L -o ./tmp/$RASPBIAN_ARCHIVE $RASPBIAN_URL
  fi
fi

vagrant up --provision

echo "Raspbian image saved in ./tmp. You may now run vagrant destroy."