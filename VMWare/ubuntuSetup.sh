#!/bin/bash

# Copyright (c) 2015 Justin Rummel
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Created by Justin Rummel
# Version 1.0.0 - 2013-3-28

# Modified by Justin Rummel
# Version 1.1.0 - 2015-01-21

### Description
# Goal is to have a script that performs the basic setup needs for a brand new Ubuntu Server.

### Assumptions
# -	You are installing the server from Ubuntu's setup assistant, not using VMware's "easy"
# 	setup assistant.  The reason for this is Ubuntu will ask you for a custom hostname.
# -	There is no encryption on the volume
# -	The Partitioning method is the default "use entire disk w/ LVM"

# Base Variables that I use for all scripts.  Creates Log files and sets date/time info
declare -x SCRIPTPATH="${0}"
declare -x RUNDIRECTORY="${0%/*}"
declare -x SCRIPTNAME="${0##*/}"

logtag="${0##*/}"
debug_log="disable"
logDate=`date "+%Y-%m-%d"`
logDateTime=`date "+%Y-%m-%d_%H:%M:%S"`
log_dir="/var/log/${logtag}"
LogFile="${logtag}-${logDate}.log"

# Script Variables

# Script Functions
verifyRoot () {
    #Make sure we are root before proceeding.
    [ `id -u` != 0 ] && { echo "$0: Please run this as root."; exit 0; }
}

logThis () {
	# Output to stdout and LogFile.
    logger -s -t "${logtag}" "$1"
    [ "${debug_log}" == "enable" ] && { echo "${logDateTime}: ${1}" >> "${log_dir}/${LogFile}"; }
}

init () {
    # Make our log directory
    [ ! -d $log_dir ] && { mkdir $log_dir; }

    # Now make our log file
    if [ -d $log_dir ]; then
        [ ! -e "${log_dir}/${LogFile}" ] && { touch $log_dir/${LogFile}; logThis "Log file ${LogFile} created"; logThis "Date: ${logDateTime}"; }
    else
        echo "Error: Could not create log file in directory $log_dir."
        exit 1
    fi
    echo " " >> "${log_dir}/${LogFile}"
}

update() {
	echo -n "Do you want run 'apt-get update'? [y|n]:"
	read -n 1 replySTATIC
	echo " "
	if [ "${replySTATIC}" == "y" ]; then
		logThis "Running apt-get update"
		getUpdates=$(sudo /usr/bin/apt-get -qy update > /dev/null)
		[ $? != 0 ] && { logThis "apt-get update had an error.  Stopping now!"; exit 1; } || { logThis "apt-get update completed successfully."; }
	fi
}

upgrade() {
	echo -n "Do you want run 'apt-get dist-upgrade'? [y|n]:"
	read -n 1 replySTATIC
	echo " "
	if [ "${replySTATIC}" == "y" ]; then
		logThis "Running apt-get dist-upgrade (this may take some time.  Patience.)"
		getUpgrades=$(sudo /usr/bin/apt-get -qy dist-upgrade > /dev/null)
		[ $? != 0 ] && { logThis "apt-get dist-upgrade had an error.  Stopping now!"; exit 1; } || { logThis "apt-get dist-upgrade completed successfully."; }
	fi
}

sshServer() {
	sshCheck=$(netstat -natp | grep [s]shd | grep LISTEN | grep -v tcp6)
	[ $? != 0 ] && { logThis "openssh-server is NOT installed."; installOpenssh; } || { logThis "openssh-server is running."; }
}

installOpenssh() {
	logThis "Installing openssh-server."
	installSSH=$(sudo /usr/bin/apt-get install openssh-server -qy)
	[ $? != 0 ] && { logThis "apt-get install openssh-server had an error.  Stopping now!"; exit 1; } || { logThis "apt-get install openssh-server completed successfully."; }
}

curlCLI() {
	curlCheck=$(which curl)
	[ $? != 0 ] && { logThis "curl is NOT installed."; installCurl; } || { logThis "curl is available."; }
}

installCurl() {
	logThis "Installing curl."
	installSSH=$(sudo /usr/bin/apt-get install curl -qy)
	[ $? != 0 ] && { logThis "apt-get install curl had an error.  Stopping now!"; exit 1; } || { logThis "apt-get install curl completed successfully."; }
}

setNetwork() {
	echo -n "Do you want to set a static IP? [y|n]:"
	read -n 1 replySTATIC
	echo " "
	[ "${replySTATIC}" != "y" ] && { logThis "Keeping DHCP settings."; findName; } || { static; }
}

static() {
	echo -n "Type the IP address for this server: "
	read IP
	logThis "Setting IP for ${IP}"
	echo " "

	echo -n "Type the subnet mask for this server: "
	read MASK
	logThis "Setting subnet mask for ${MASK}"
	echo " "

	echo -n "Type the Gateway for this server: "
	read GATE
	logThis "Setting Gateway for ${GATE}"
	echo " "

	echo -n "Type your DNS servers IP address (separated by a space): "
	read DNS
	logThis "Setting DNS servers for ${DNS}"
	echo " "

	echo -n "Type the DNS Search Name: "
	read SEARCH
	logThis "Setting DNS Search Name for ${SEARCH}"
	echo " "

	echo "Final check!"
	echo "address ${IP}"
	echo "netmask ${MASK}"
	echo "gateway ${GATE}"
	echo "dns-nameservers ${DNS}"
	echo "dns-search ${SEARCH}"
	echo " "
	echo -n "Is this correct? ${SETSTATIC} [y|n]: "
	read -n 1 replySET
	echo " "
	[ "${replySET}" != "y" ] && { logThis "You got this far and want to cancel?  Lets just stop and be safe."; exit 1; } || { setInterface "${IP}" "${MASK}" "${GATE}" "${DNS}" "${SEARCH}"; }
}

setInterface () {
	logThis "Setting new Static IP address, and restarting eth0"
	interface="/etc/network/interfaces"

	echo "# This file describes the network interfaces available on your system" > "${interface}"
	echo "# and how to activate them. For more information, see interfaces(5)." >> "${interface}"
	echo " " >> "${interface}"
	echo "# The loopback network interface" >> "${interface}"
	echo "auto lo" >> "${interface}"
	echo "iface lo inet loopback" >> "${interface}"
	echo " " >> "${interface}"
	echo "# The primary network interface" >> "${interface}"
	echo "auto eth0" >> "${interface}"
	echo "iface eth0 inet static" >> "${interface}"
	echo "address ${1}" >> "${interface}"
	echo "netmask ${2}" >> "${interface}"
	echo "gateway ${3}" >> "${interface}"
	echo "dns-nameservers ${4}" >> "${interface}"
	echo "dns-search ${5}" >> "${interface}"
	echo " "

	echo "Reboot Your Server now! (sudo reboot), then walk through this script again but saying no to all the items already completed."
}

findName () {
	logThis "Finding your IP Address and DNS record"
	ipAddress=`ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f1`
	dnsName=`host "${ipAddress}" | awk -F " " '{print $NF}' | sed 's/\.$//'`

	echo -n "Your IP address is ${ipAddress} with the DNS name ${dnsName} correct? [y|n]: "
	read -n 1 replyIP
	echo " "
	[ "${replyIP}" != "y" ] && { logThis "You just set your IP address, and now it's wrong?  Lets just stop and be safe"; exit 1; } || { setName "${dnsName}"; }
}

setName () {
	logThis "Setting your server name with the DNS record of your IP Address"
	hosts="/etc/hosts"
	hostname="/etc/hostname"

	host=`echo "${dnsName}" | awk -F "." '{print $1}'`
	echo "${host}" > "${hostname}"

	echo "127.0.0.1	localhost" > "${hosts}"
	echo "127.0.1.1	${host}	${dnsName}" >> "${hosts}"
	echo " " >> "${hosts}"
	echo "# The following lines are desirable for IPv6 capable hosts" >> "${hosts}"
	echo "::1     localhost ip6-localhost ip6-loopback" >> "${hosts}"
	echo "ff02::1 ip6-allnodes" >> "${hosts}"
	echo "ff02::2 ip6-allrouters" >> "${hosts}"

	echo "Reboot Your Server now! (sudo reboot)"
}

verifyRoot
#init
sshServer
curlCLI
update
upgrade
setNetwork

exit 0
