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
# Version 1.0.0 - 2014-10-02

### Description 
# I'm looking for the domain_name_server section of  the ipconfig command.  
# I assume I'm looking for the LAST IP address that is handed via your DHCP server.
# This was created for JNUC 2014 Policies presentation, there are always better ways to do things
# for your environment.  

### Variables
DNS_SERVER="10.13.12.122"
FILE_SERVER="host.domain.tld"
SHARE_NAME="Shared"
PROTOCOL="afp"

WIFI=`networksetup -listnetworkserviceorder | grep "Wi-Fi" | tail -1 | awk -F ": " '{print $NF}' | sed 's/)//g'`
ETHERNET=`networksetup -listnetworkserviceorder | grep "Ethernet" | tail -1 | awk -F ": " '{print $NF}' | sed 's/)//g'`

WIFI_DNS=`ipconfig getpacket "${WIFI}" | awk '/domain_name_server/ {print $NF}' | sed 's/}//g'`
ETH_DNS=`ipconfig getpacket "${ETHERNET}" | awk '/domain_name_server/ {print $NF}' | sed 's/}//g'`

### Functions
net_mount() {
	open "${PROTOCOL}://${FILE_SERVER}/${SHARE_NAME}/"
}

[[  "${ETH_DNS}" == "${DNS_SERVER}" ]] && { net_mount; exit 0; } || { echo "${ETH_DNS}"; }
[[  "${WIFI_DNS}" == "${DNS_SERVER}" ]] && { net_mount; exit 0; } || { echo "${WIFI_DNS}"; }

echo "Not on the network.  I'll stop now."
exit 0
