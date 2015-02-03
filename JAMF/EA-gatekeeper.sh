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

# Version 1.1.0 - 2013-11-02

### Description 
# Goal is to find out if Gatekeeper is active.
# Only available on 10.7.5+ or 10.8.0+ OS

### Variables
osmajor=`sw_vers -productVersion | awk -F "." '{print $1}'`
osminor=`sw_vers -productVersion | awk -F "." '{print $2}'`
osrev=`sw_vers -productVersion | awk -F "." '{print $3}'`

### Functions
# Checks Gatekeeper status on 10.7.x Macs
function lionGatekeeper () {
	if [ "${osrev}" -ge "5" ]; then
		gatekeeper_status=`spctl --status | grep "assessments" | cut -c13-`
		[ "${gatekeeper_status}" == "disabled" ] && { echo "<result>Disabled</result>"; } || { echo "<result>Active</result>"; }
	else
		echo "<result>N/A; Update to the latest version of Lion.</result>"
	fi
}

# Checks Gatekeeper status on 10.8.x Macs
function mtLionGatekeeper () {
		gatekeeper_status=`spctl --status | grep "assessments" | cut -c13-`
		[ "${gatekeeper_status}" == "disabled" ] && { echo "<result>Disabled</result>"; } || { echo "<result>Active</result>"; }
}

[[ "${osminor}" < "7" ]] && { echo "<result>Gatekeeper N/A for this OS</result>"; }
[[ "${osminor}" == "7" ]] && { lionGatekeeper; }
[[ "${osminor}" > "7" ]] && { mtLionGatekeeper; }
exit 0
