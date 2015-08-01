#!/bin/bash

# clone.sh is a wrapper around aufs (and maybe later overlayfs instead) to allow for easy creation of duplicated daemons

# The main use case for developing this is game servers, where there will be a static base image (except for when 
# there is an udpate to the server, in which case all instances need the same server)

BASE_DIR=/home/sirsquidness/base
DEST_DIR=/home/sirsquidness/servers

function clone_init() {
    [[ -z $1 || -z $2 ]] && echo "Need to specify at least a destination and a base" && exit 1

    DEST=$DEST_DIR/$1

#     the mount argument is something like br:/topleveldir:/secondleveldir:/basedir, so we must
#     build that out of our arguments
 
    MOUNTTHING="br"
    for NEXT in $*; do  
        MOUNTTHING="$MOUNTTHING:$BASE_DIR/$NEXT"
    done
    mount -t aufs -o $MOUNTTHING none $DEST
}


function clone_help() {
   echo """
Usage: clone init destination_name highest_base [ next_base [ lower_base [ even_lower_base ... ] ] ]

The bases go in the same order as the aufs mount arguments - so the base coming
 first goes over the top of the second one, and the second over the third. 

for example, I may do:

clone init tf2-prophunt-3  tf2-prophunt tf2

That will make a folder in servers/ called tf2-prophunt-3 in which I would put 
some config files to set the server name to 'TF2 Prophunt #3' or simlar

Each folder in servers/ will have a matching folder in base/ which stores all
of the customisations for that 

And then in tf2-prophunt, I would put the prophunt maps and config files

Then I would have a srcds install in the tf2 base folder. 

These will not be restored on reboot, so either use a script to call clone.sh
or use this script as inspiration to make your fstab yourself. 
"""
exit 0
}
echo "${1-}"
[[ -z "${1-}" ]] && clone_help "$0"
case $1 in
	init) clone_"$1" "${@:2}" ;;
	*) clone_help "$0" ;;
esac
