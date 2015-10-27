#!/bin/bash

# contain.sh - Something to manage network isolation

# Goal is to make it easy to create separate network namespaces, then
# start programs in their context, with their own network stack. 

# Inspired by Bocker, I wanted only the network isolation component, 
# and needed to not have the rest of the isolation. 

# Requirements:
# bridge-utils 
# pump

BRIDGE_IF=br0

function contain_exists() {
   ip netns list | grep -qw $1 && echo 1 || echo 0
}

# This funciton should create an overlay fs 
function contain_init() {
    [[ "$(contain_exists "$1")" == 1 ]] && echo "ip netns $1 already exists" && exit 1
    echo "ip netns $1 does not exist, let's create it"

    iface_e="$1"e  # interface on the outside of the isolation (external)
    iface_i="$1"i  # interface on the inside of the isolation  (internal)
    netns="$1"     # name of the net namespace

    ip link add dev $iface_e type veth peer name $iface_i
    ip link set dev $iface_e up
    ip link set $iface_e master $BRIDGE_IF
    ip netns add $netns
    ip link set $iface_i netns $netns
    ip netns exec $netns ip link set dev lo up
    ip netns exec $netns ip link set dev $iface_i up
    ip netns exec $netns pump -i $iface_i -h $1 -d --no-resolvconf --no-ntp 
}

function contain_run() {
    [[ "$(contain_exists "$1")" == 0 ]] && echo "ip netns $1 does not exist, please run contain init first" && exit 1
  
    ip netns exec $1 "${@:2}"
}

function contain_destroy() {
    [[ "$(contain_exists "$1")" == 0 ]] && echo "ip netns $1 does not exist, nothing to destroy" && exit 1
    ip netns del $1 || echo "Could not delete namespace"
    ip link delete dev "$1"e || echo "Could not delete veth device"
}

# This should be made smarter; not sure if anything in normal system operation would create a netns. Maybe LXC etc would interfere? 
function contain_ls() {
    ip netns list
}

function contain_help() {
echo "hallp!"
echo "Also remember that this depends on the pump DHCP client"
exit 1;
}


[[ -z "${1-}" ]] && contain_help "$0"
case $1 in
	exists|init|help|run|destroy|ls) contain_"$1" "${@:2}" ;;
	*) contain_help "$0" ;;
esac
