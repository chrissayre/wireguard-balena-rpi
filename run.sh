#!/usr/bin/env bash
#
# run.sh loads the wireguard kernel module and it's dependencies, if needed

OS_VERSION=$(awk '{ print $2 }' <<< "$BALENA_HOST_OS_VERSION")
modPath="output/wireguard-linux-compat/src_${BALENA_DEVICE_TYPE}_${OS_VERSION}.prod_from_src/wireguard.ko"
echo " :: OS Version is $OS_VERSION"

if lsmod | grep wireguard >/dev/null 2>&1; then
	echo " :: Skipping wireguard load, already loaded"
	echo " :: Loaded Wireguard version: $(cat /sys/module/wireguard/version 2>/dev/null || echo "failed to obtain version")"
else
	echo " :: Loading pre-req modules"
	modprobe -a udp_tunnel ip6_udp_tunnel

	echo " :: Loading wireguard"
	modinfo "$modPath"
	if ! insmod "$modPath"; then
	 	dmesg | grep wireguard
	fi
fi

if [[ -n "$DEBUG_MODE" ]]; then
  exec sleep infinity
fi