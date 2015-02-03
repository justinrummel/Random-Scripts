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

#variables
APNS="gateway.push.apple.com"


### APNS has several IP address.  Lets find just one
echo "Getting /one/ of the IP's for ${APNS}"
gpacIP=`dig A "${APNS}" +short | grep -v gateway | head -n 1`
[ "${gpacIP}" != "" ] && { echo "Found ${gpacIP}"; } || { echo "Uh oh... something is wrong so I'll stop."; exit 0; }

### We're really trying to find the DNS name to test
echo "Getting the PTR record for ${gpacIP}"
gpacTempDNS=`host "${gpacIP}" | awk '{print $NF}'`
gpacTrim=`echo "${gpacTempDNS}" | tail -c -2`
[ "${gpacTrim}" == "." ] && { gpacDNS=`echo "${gpacTempDNS}" | sed 's/.$//'`; } || { gpacDNS="gpacTempDNS"; }
[ gpacDNS != "" ] && { echo "Using ${gpacDNS}"; } || { echo "Uh oh... something is wrong so I'll stop."; exit 0; }

### can we connect to our specific APNS server?
echo "Testing ${gpacDNS} over port 2195"
TEST=`openssl s_client -connect "${gpacDNS}":2195 -no_ssl3 -no_tls1 | grep CONNECTED | cut -c 1-9`;
[ "${TEST}" == "CONNECTED" ] && { echo "We can connect to ${gpacDNS}!"; } || { echo "There was an error... something is blocking port 2195"; }

