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

# Version 1.1.0 - 2013-10-29
# Version 1.1.1 - 2014-10-16 

### Description 
# Goal is to find out what vesion of the OS is running, PLUS if the machine is a client or server.
# Needed for Mt Lion as a "Server OS" is now depricated.  It's just an app.

### Variables
osx=`sw_vers -productVersion | awk -F "." '{print $2}'`

### Functions
oldSchool () {
    productName=`sw_vers -productName`
	productVersion=`sw_vers -productVersion`
	buildVersion=`sw_vers -buildVersion`

	echo "<result>${productName} ${productVersion} (${buildVersion})</result>"
}

newSchool () {
	if serverinfo -q --configured; then osxs=" Server"; else osxs=""; fi

	productName=`sw_vers -productName`
	productName2="${productName}${osxs}"
	productVersion=`sw_vers -productVersion`
	buildVersion=`sw_vers -buildVersion`

	echo "<result>${productName2} ${productVersion} (${buildVersion})</result>"
}

[ "${osx}" -gt "7" ] && { newSchool; } || { oldSchool; }

exit 0

