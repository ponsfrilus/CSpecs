#!/bin/bash

# found on http://www.sinisterstuf.org/blog/115/checking-computer-specs-in-linu 

#This script reports the following specs about your PC:
# -How much space is available on each hard disk drive
# -How much space is used/available on each mounted partition
# -How much memory is available on each RAM device
# -How fast is each CPU core (single core machines only have 1 entry)
# -The name, driver used and memory available from your graphics accelerator

#Some of the commands in this script require root privelages, so
#it will display an error if you try to run it as a normal user.

#Written by Siôn le Roux (sion@sionleroux.com)
#This script is in the public domain, but it would be nice if you let
#me know if you like it, or have any suggestions for improvements! :-)

#this is a function that outputs all the specs
function check_my_specs() {
    echo ""
    echo " = PC Specs = "
    echo #check the disk space with fdisk
    echo "== Disk Space =="
    fdisk -l | grep 'Disk .* bytes' | sed 's/, [0-9].*$//'
    echo #check disk usage with df
    echo "== Current Disk Usage =="
    df -h | grep -e "^Filesystem" -e "^\/dev"
    echo #I'm not very familiar with dmidecode but it can get RAM info
    echo "== RAM =="
    counter=0
    dmidecode --type 17 | grep 'Size' | sed 's/^.//' | sed 's/S/s/' | while read -r ram
    do #this for loop is used to display the number before the ram
	counter=`expr $counter + 1`
	echo "Slot "$counter" "$ram
    done
    echo #cpu info is read from /proc/cpu
    echo "== CPU =="
    counter=0
    cat /proc/cpuinfo | grep 'name' | sed 's/.*\: //' | while read -r cpu
    do #this for loop is used to display the number before the cpu core
	counter=`expr $counter + 1`
	echo "Core "$counter": "$cpu
    done
    echo #after the 'subdomain' is found, it is used to get the card info
    echo "== Graphics =="
    lspci -vs `lspci | grep VGA | sed 's/ .*//'` | grep -e "Memory" -e "VGA" -e "Kernel" | sed 's/^.//' | sed 's/^[0-9].*\: //' | sed 's/(.*)//'
}

#call the function above if root, otherwise display an error
if [[ $UID -ne 0 ]]
then
    echo "This script needs to be run as root!"
else
    check_my_specs
fi
