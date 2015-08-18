
# Contain

A bash script to make managing and using network namespaces easier. 


## Usage

`contain init SomeName` to create a new network namespace

`contain run SomeName ./srcds_run -game tf` to run a Team Fortress 2 server in the SomeName namespace

`contain destroy SomeName` to dispose of a name space. 


At time of writing, we are using DHCP to assign IP addresses to the internal namespace interface, but 
I would like to change this to be configurable so I can set static IPs. Because we don't give the 
container a new root filesystem, its /etc/hostname will be the same as the main host, so the DHCP 
request for the container will will send with the same hostname.


## Requirements

* A bridge with an interface name to match the BRIDGE_IF var (default br0) 
* A version of linux that supports network namespaces (ie, any distro from recent years)
* root

## To Do

* Make a partner utility to use overlayfs 
* Make this script more robust 
* Make a web wrapper around this so I can launch game servers from the web, straight in to a namespace
 *  eg https://github.com/yudai/gotty
* Make DHCP request in container use a different hostname
* ??? 
