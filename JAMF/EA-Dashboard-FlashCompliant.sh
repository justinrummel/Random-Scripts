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
# Version 1.0.1 - 2014-02-05
# Version 1.0.2 - 2014-12-17

# Modified by Justin
# Version 1.0.1 reversed logic to find if compliant vs. not compliant.
# Version 1.0.2 not sure why logic is so hard.


### Description
#  Find the current installed version of Flash.
#  And compare to XProtect

# Base Variables that I use for all scripts.  Creates Log files and sets date/time info
declare -x SCRIPTPATH="${0}"
declare -x RUNDIRECTORY="${0%%/*}"
declare -x SCRIPTNAME="${0##*/}"

logtag="${0##*/}"
debug_log="enable"
logDate=`date +"Y.m.d"`
logDateTime=`date +"Y-m-d_H.M.S"`
log_dir="/Library/Logs/${logtag}"
LogFile="${logtag}-${logDate}.log"


# Script Variables
#Flash (not sure why there is a .lzma in one of my test machines, but this way I find the plugin that is installed!)
fPlugin=`find /Library/Internet\ Plug-Ins -name "Flash*" -d 1 | awk -F "/" {'print $4'}`
flashVendor=`/usr/bin/defaults read /Library/Internet\ Plug-Ins/"${fPlugin}"/Contents/Info CFBundleIdentifier`
flashVersion=`/usr/bin/defaults read /Library/Internet\ Plug-Ins/"${fPlugin}"/Contents/Info CFBundleVersion`

#Xprotect
sourceDir="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/"
file="XProtect.plist"
metaFile="XProtect.meta.plist"


# Script Functions
adobeFlash () {
	appleX=`/usr/libexec/PlistBuddy -c "print :PlugInBlacklist:10:com.macromedia.Flash\ Player.plugin:MinimumPlugInBundleVersion" "${sourceDir}${metaFile}"`

#	echo "${appleX}"
#	echo "${flashVersion}"

	Xoct1=`echo "${appleX}" | awk -F "." '{print $1}'`
	Xoct2=`echo "${appleX}" | awk -F "." '{print $2}'`
	Xoct3=`echo "${appleX}" | awk -F "." '{print $3}'`
	Xoct4=`echo "${appleX}" | awk -F "." '{print $4}'`

	oct1=`echo "${flashVersion}" | awk -F "." '{print $1}'`
	oct2=`echo "${flashVersion}" | awk -F "." '{print $2}'`
	oct3=`echo "${flashVersion}" | awk -F "." '{print $3}'`
	oct4=`echo "${flashVersion}" | awk -F "." '{print $4}'`

#	echo "$oct1 -lt $Xoct1"
#	echo "$oct2 -lt $Xoct2"
#	echo "$oct3 -lt $Xoct3"
#	echo "$oct4 -ge $Xoct4"

	[[ "${oct1}" -lt "${Xoct1}" ]] && { echo "<result>Not Compliant</result>"; exit 0; }
	[[ "${oct2}" -lt "${Xoct2}" ]] && { echo "<result>Not Compliant</result>"; exit 0; }
	[[ "${oct3}" -lt "${Xoct3}" ]] && { echo "<result>Not Compliant</result>"; exit 0; }
	[[ "${oct4}" -lt "${Xoct4}" ]] && { echo "<result>Not Compliant</result>"; exit 0; } || { echo "<result>Compliant</result>"; }
}

[ "$flashVendor" == "" ] && { echo "<result>Flash Plug-In Not Available</result>"; exit 0; } || { adobeFlash; }

exit 0;
