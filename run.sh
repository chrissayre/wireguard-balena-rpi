#!/usr/bin/env bash

OS_VERSION=$(awk '{ print $2 }' <<< "$BALENA_HOST_OS_VERSION")
modPath="output/wireguard-linux-compat/src_${BALENA_DEVICE_TYPE}_${OS_VERSION}.prod_from_src/wireguard.ko"
echo "OS Version is $OS_VERSION"

if lsmod | grep wireguard >/dev/null 2>&1; then
	echo "skipping wireguard load, already loaded"
	echo "Loaded Wireguard version: $(cat /sys/module/wireguard/version 2>/dev/null || echo "failed to obtain version")"
else
	echo "loading pre-req modules"
	modprobe udp_tunnel ip6_udp_tunnel || true

	echo "loading wireguard"
	modinfo "$modPath"
	if ! insmod "$modPath"; then
	 	dmesg | grep wireguard
		exit $?
	fi
fi

# now we wait forever, allows debugging the container
exec sleep infinity