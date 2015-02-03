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
# Version 1.0.0 - 11/15/2012

# Modified by
# Version 


### Description 
# Goal is to install VMWare Tools on an Ubuntu Server.  Don't forget to mount the CD first! 

# variables
cdMNT="/mnt/cdrom/"
cdDEV="/dev/cdrom/"

### Be sure to select "Install VMWare Tools" from the "Virtual Machine" dropdown menu in VMWare Fusion
[ ! -d "${cdMNT}" ] && { echo "creating ${cdMNT}"; sudo mkdir "${cdMNT}"; } || { echo "${cdMNT} already exists.  Moving on..."; }
[ ! -d "${cdDEV}" ] && { echo "mounting ${cdDEV} to ${cdMNT}"; sudo mount "${cdDEV}" "${cdMNT}"; }

vmTGZ=`find "${cdMNT}" -name "VMwareTools*"` 2>/dev/null

cd /tmp
if [ -e "${vmTGZ}" ]; then
	cp "${cdMNT}${vmTGZ}" ./
	tar xzvf "${vmTGZ}" 
	cd vmware-tools-distrib/
	sudo apt-get install build-essential
	sudo apt-get install build-essential linux-headers-`uname -r`
	sudo ./vmware-install.pl --default
	sudo reboot
else
	echo "Something went wrong.  Stopping now."
	exit 1
fi
exit 0
