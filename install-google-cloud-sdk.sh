#!/bin/sh

GZ_FILE=google-cloud-sdk-309.0.0-linux-x86_64.tar.gz

curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${GZ_FILE} --progress-bar

tar zxvf ${GZ_FILE} google-cloud-sdk 2>&1 |
while read line; do
    x=$((x+1))
    echo -en "$x Extracted\r"
done

rm $GZ_FILE

sh google-cloud-sdk/install.sh