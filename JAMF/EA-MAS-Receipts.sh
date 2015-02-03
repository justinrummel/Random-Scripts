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
#
# Discovery on HOW to do this by Magervalp: http://magervalp.github.com/2013/03/19/poking-around-in-masreceipts.html 

# Created by Justin Rummel
# Version 1.0.0 - 2013-03-19

# Modified by
# Version 1.0.1 2013-03-19 by Justin  see commit notes.


### Description 
# Goal is to find out if the Apple ID that is assigned to the "/Applications/App Store.app" 
# matches with an Application that is installed from MAS and is available in the /Applications folder.

### Base Variables that I use for all scripts.  Creates Log files and sets date/time info
declare -x SCRIPTPATH="${0}"
declare -x RUNDIRECTORY="${0%/*}"
declare -x SCRIPTNAME="${0##*/}"

logtag="${0##*/}"
debug_log="enable"
logDate=`date +"%Y-%m-%d"`
logDateTime=`date +"%Y-%m-%d_H%:M%:%S"`
log_dir="/Library/Logs/${logtag}"
LogFile="${logtag}-${logDate}.log"

### Script Variables
cUser=`ps -jax | grep [c]onsole | awk '{print $1}'`
DSPersonID=`defaults read /Users/"${cUser}"/Library/Preferences/com.apple.storeagent DSPersonID`
apps="/Applications/"
receipt="/Contents/_MASReceipt/receipt"
tmpPath="/tmp/MASreceipts/"
idTotal=`count "${tmpPath}"*`

### Script Functions
# Search the /Applications folder, find all "MAS" applications (i.e. the app has an _MASReceipt/receipt item)
# then pipe out the Bundle identifier info so we can read the data with another function.
appSearch () {
	[ ! -d "${tmpPath}" ] && { mkdir "${tmpPath}"; }
	for app in "${apps}"* ; do
		if [ -d "${app}" ]; then
			#echo $(basename "$app")
			#[ -e "${app}${receipt}" ] && { echo "${app}"; }
			[ -e "${app}${receipt}" ] && { payload "${app}${receipt}" "$(basename "$app")"; }
		fi
	done
}

payload () {
	openssl asn1parse -inform der -in "${1}" | grep -m 1 'OCTET STRING' | cut -d: -f4 | xxd -r -p > "${tmpPath}$2"
}

# Search the tmp folder of Bundle identifier info, and extract the ID that is embedded.
receiptSearch () {
	if [ "${idTotal}" != 0 ]; then
		echo "<result>"
		for MAS in "${tmpPath}"* ; do
			#echo $(basename "$MAS")
			[ -e "${MAS}" ] && { MSPersonID "${MAS}"; }
		done
		echo "</result>"
	fi
}

# Report if the com.apple.storeagent matches the ID of the MAS app.
MSPersonID () {
	PID=`printf "%d\n" 0x$(openssl asn1parse -inform der -in "${1}" | grep -A 2 ':04$' | tail -1 | cut -d: -f4 | cut -c5-)`
	[ "${PID}" == "${DSPersonID}" ] && { echo "$(basename "$1") matches MAS Apple ID"; } || { echo "$(basename "$1") DOES NOT Match"; }
}

# Just in case if the App Store is not set with an ID, validate that it is not blank.  
# Not sure if this is a accurate test, but till I get some feed back this is better than nothing. 
[ "${DSPersonID}" != "" ] && { appSearch; receiptSearch; } || { echo "<result>com.apple.storeagent not set</result>"; }
exit 0
