#!/bin/bash

OS_VERSION=$(echo "$BALENA_HOST_OS_VERSION" | cut -d " " -f 2)
echo "OS Version is $OS_VERSION"

mod_dir="wireguard-linux-compat/src_${BALENA_DEVICE_TYPE}_${OS_VERSION}*"
for each in $mod_dir; do
	echo "Loading wireguard from '$mod_dir'"
	insmod "$each/wireguard.ko"
	lsmod | grep wireguard
done

while true; do
	sleep 60
done
