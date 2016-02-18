#!/bin/bash

# Base script found on http://www.sinisterstuf.org/blog/115/checking-computer-specs-in-linu 
# adapter by [@posnfrilus](https://github.com/ponsfrilus)

# This script reports the following specs about your PC:
#  - How much space is available on each hard disk drive
#  - How much space is used/available on each mounted partition
#  - How much memory is available on each RAM device
#  - How fast is each CPU core (single core machines only have 1 entry)
#  - The name, driver used and memory available from your graphics accelerator

# Some of the commands in this script require root privelages, so
# it will display an error if you try to run it as a normal user.

# Written by Siôn le Roux (sion@sionleroux.com @sinisterstuf)
# This script is in the public domain, but it would be nice if you let
# me know if you like it, or have any suggestions for improvements! :-)


# Initialize our own variables:
output_file=""
verbose=0

function ascii() {
    echo ""
    echo "      OoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoO"
	echo "      8      _________   ___________________                            8"
	echo "      0      \_   ___ \ /   _____/\______   \ ____   ____   ______      0"
	echo "      8      /    \  \/ \_____  \  |     ___// __ \_/ ___\ /  ___/      8"
	echo "      0      \     \____/        \ |    |   \  ___/\  \___ \___ \       0"
	echo "      8       \______  /_______  / |____|    \___  >\___  >____  >      8"
	echo "      0              \/        \/                \/     \/     \/       0"
	echo "      OoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoO ponsfrilus 2016 OoO"
	echo "                    download me on https://github.com/ponsfrilus/CSpecs  "
	echo ""
}

function title() {
    echo "Computer Specs"
    echo "=============="
    echo ""
}

# General information
function gen_info() {
    IP=`wget http://ipinfo.io/ip -qO -`
    echo -e "* RUN DATE = \t\t`date +"%Y-%m-%d %H:%M:%S"`"
    echo -e "* HOSTNAME = \t\t`hostname`"
    echo -e "* IP = \t\t\t$IP"
    echo -e "* CURRENT USER =\t`whoami`"
    echo -e "* USERS LIST ="
    for u in `ls /home`
    do
        echo "    * $u"
    done
    echo ""
}

# System Information
function sys_info() {
    # dmidecode | grep -A3 -B3 Version
    echo "## System Information"
    echo "\`\`\`"
    dmidecode | sed -n '/System Information/,/^$/p' | sed '1d;$d'
    echo -e "\`\`\`\n"
}

# Release information
function release_info() {
    # dmidecode | grep -A3 -B3 Version
    echo "## Release Information"
    echo "\`\`\`"
    uname -a
    cat /etc/lsb-release
    echo -e "\`\`\`\n"
}

# BIOS Information
function bios_info() {
    # dmidecode | grep -A3 -B3 Version
    echo "## BIOS Information"
    echo "\`\`\`"
    dmidecode | sed -n '/BIOS Information/,/^$/p' | sed '1d;$d'
    echo -e "\`\`\`\n"
}

# Check the disk space with fdisk
function disc_info() {
    echo "## Disk Space"
    echo "\`\`\`"
    fdisk -l /dev/[sh]d? 2>/dev/null | grep -e 'Disk /' -e 'Disklabel' -e 'Disk identifier'
    echo ""
    fdisk -l /dev/[sh]d? 2>/dev/null | sed -n '/Device/,$p'
    echo -e "\`\`\`\n"
    # check disk usage with df
    echo "### Current Disk Usage"
    echo "\`\`\`"
    df -h | grep -e "^Filesystem" -e "^\/dev"
    echo -e "\`\`\`\n"
}

# Get RAM information
function ram_info() {
    echo "## RAM"
    echo "\`\`\`"
    counter=0
    dmidecode --type 17 | grep 'Size' | sed 's/^.//' | sed 's/S/s/' | while read -r ram
    do # this for loop is used to display the number before the ram
	    counter=`expr $counter + 1`
	    echo "Slot "$counter" "$ram
    done
    echo -e "\`\`\`\n"
}

# Get CPU information
function cpu_info() {
    echo "## CPU"
    echo "\`\`\`"
    counter=0
    cat /proc/cpuinfo | grep 'name' | sed 's/.*\: //' | while read -r cpu
    do # this for loop is used to display the number before the cpu core
	    counter=`expr $counter + 1`
	    echo "Core "$counter": "$cpu
    done
    echo -e "\`\`\`\n"
}

# Get GPU information
function gpu_info() {
    echo "## Graphics"
    echo "\`\`\`"
    for bus in `lspci | grep VGA | sed 's/ .*//'`
    do
        lspci -vs $bus | grep -e "Memory" -e "VGA" -e "Kernel" | sed 's/^.//' | sed 's/^[0-9].*\: //' | sed 's/(.*)//'
    done
    echo -e "\`\`\`\n"
}

# Get Audio information
function audio_info() {
    echo "## Audio"
    echo "\`\`\`"
    for bus in `lspci | grep 'Audio device:' | sed 's/ .*//'`
    do
        lspci -vs $bus | sed -n 's/^[0-9].*\: //p'
        lspci -vs $bus | grep 'Kernel driver in use: '| xargs
    done
    echo -e "\`\`\`\n"
}

# Get Networking information
function net_info() {
    echo "## Network"
    echo "\`\`\`"
    for bus in `lspci | grep 'Network controller:' | sed 's/ .*//'`
    do
        lspci -vs $bus | sed -n 's/^[0-9].*\: //p'
        lspci -vs $bus | grep 'Kernel driver in use: '| xargs
    done
    echo -e "\`\`\`\n"
}

# Get RAW Information
function raw_info() {
    echo "## RAW Information"
    echo "### lspci"
    echo "\`\`\`"
    lspci
    echo -e "\`\`\`\n"
    echo ""
    echo "### lsusb"
    echo "\`\`\`"
    lsusb
    echo -e "\`\`\`\n"
    echo ""
    echo "### lshw"
    echo "\`\`\`"
    lshw # sudo lshw -html | html2markdown > test.md
    echo -e "\`\`\`\n"
    echo ""
    echo "### hwinfo"
    echo "\`\`\`"
    hwinfo
    echo -e "\`\`\`\n"
    echo ""
    echo "### ip a"
    echo "\`\`\`"
    ip a
    echo -e "\`\`\`\n"
    echo ""
}

# this is a function that outputs all the specs
function check_my_specs() {
    ascii
    title
    gen_info
    sys_info
    release_info
    bios_info
    disc_info
    ram_info
    cpu_info
    gpu_info
    audio_info
    net_info
}

# Usage info
function help() {
cat << EOF
Usage: ${0##*/} [-hvrsp] [-f OUTFILE]
Looks into your computer and write the result to standard output.

    -h          display this help and exit
    -f OUTFILE  write the result to OUTFILE (markdown)
    -p          save result as PDF
    -r          raw information
    -s          sprunge output
    -v          verbose mode
    
EOF
}

# call the function above if root, otherwise display an error
if [[ $UID -ne 0 ]]
then
    echo "This script needs to be run as root!"
else
    OPTIND=1 # Reset is necessary if getopts was used previously in the script.  It is a good idea to make this local in a function.
    while getopts ":hvf:rsp" opt; do
        case "$opt" in
            h)
                help
                exit 0
                ;;
            v)
                set -x
                ;;
            f)
                output_file=$OPTARG
                ;;
            r)  # http://stackoverflow.com/questions/15184358/how-to-avoid-bash-command-substitution-to-remove-the-newline-character
                raw_info_data=$(raw_info)
                ;;
            p)
                pdf="pdf"
                ;;
            s)
                sprunge="sprunge"
                ;;
            '?')
                help >&2
                exit 1
                ;;
            :)
                echo "Option -$OPTARG requires an argument." >&2
                exit 1
                ;;
        esac
    done
    shift "$((OPTIND-1))" # Shift off the options and optional --.
    

    if [[ -z $output_file ]]
    then
        # check_my_specs
        check_my_specs_data=$(check_my_specs)
        echo "$check_my_specs_data" > tmp.md
        echo "$raw_info_data" >> tmp.md
        if [[ -n $pdf ]]
        then
            out_file=computer_specs_`date +"%Y-%m-%d_%H%M%S"`.pdf
            pandoc -V papersize:a4paper -V geometry:margin=1cm tmp.md -o $out_file
        fi
        if [[ -n $sprunge ]]
        then
            cat tmp.md | perl sprunge.pl
        fi
        cat tmp.md
        rm tmp.md
    else
        check_my_specs > $output_file
        echo "$raw_info_data" >> $output_file
        cat $output_file
        if [[ -n $pdf ]]
        then
        echo "ICI"
            pandoc -V papersize:a4paper -V geometry:margin=1cm $output_file -o computer_specs_`date +"%Y-%m-%d_%H%M%S"`.pdf
        fi
        if [[ -n $sprunge ]]
        then
            cat "$output_file" | perl sprunge.pl
        fi
    fi
fi
