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

# Description
# Create a jks keystore for SSL Certificates.  Useful for Ubuntu installs of JAMF and you want to use a 3rd party certificate

# Base Variables that I use for all scripts.  Creates Log files and sets date/time info
declare -x SCRIPTPATH="${0}"
declare -x RUNDIRECTORY="${0%%/*}"
declare -x SCRIPTNAME="${0##*/}"

logtag="${0##*/}"
debug_log="enable"
logDate=`date +"%Y.%m.%d"`
logDateTime=`date +"%Y-%m-%d_%H.%M.%S"`
log_dir="/tmp/${logtag}"
LogFile="${logtag}-${logDate}.log"

# variables
keyPass="changeme"
interface=`ifconfig  -s | grep eth | awk '{print $1}'`
myIP=`ip addr show "${interface}" | grep -v inet6 | grep inet | awk '{print $2}' | awk -F "/" '{print $1}'`
fqdn=`host 192.168.1.130 | awk -F " " '{print $5}' | sed 's/.$//'`

# Output to stdout and LogFile.
logThis () {
    logger -s -t "${logtag}" "$1"
    [ "${debug_log}" == "enable" ] && { echo "${logDateTime}: ${1}" >> "${log_dir}/${LogFile}"; }
}

init () {
	# Make our log directory
    [ ! -d $log_dir ] && { mkdir $log_dir; }

    # Make now make our log file
    if [ -d $log_dir ]; then
        [ ! -e "${log_dir}/${LogFile}" ] && { touch $log_dir/${LogFile}; logThis "Log file ${LogFile} created"; logThis "Date: ${logDateTime}"; }
    else
        echo "Error: Could not create log file in directory $log_dir."
        exit 1
    fi
    echo " " >> "${log_dir}/${LogFile}"
}

confCheck () {
	[ "${keyPass}" == "changeme" ] && { echo -n "You have not changed the default password, do you want to change it? [y|n]: "; }
	read -n 1 validateChange
	echo " "
	[ "${validateChange}" != "y" ] && { logThis "OK, I'll use the default key password"; } || { keyNewPass; }
}

keyNewPass () {
	echo -n "Please type your new key password: "
	read -s newPass
	echo " "
	echo -n "Please type key password again to verify: "
	read -s newPass2
	echo " "
	echo " "
	[ "${newPass}" != "${newPass2}" ] && { logThis "Oops.  You fat fingered your password.  Start over."; exit 0; }
	[ "${newPass}" != "" ] && { logThis "New Password Accepted."; } || { logThis "You must be confused.  I'll stop now before I make a mess."; exit 0; }
}

keyCheck () {
	logThis "Checking for keytool command"
	keyPath=`whereis keytool | awk -F " " '{print $2}'`
	[ "${keyPath}" == "" ] && { keyDownload; }
}

keyDownload () {
	echo -n "keytool cannot be found.  Want me to install jdk and jre tools? [y|n]: "
	read -n 1 validateInstall
	echo " "
	echo " "
	[ "${validateInstall}" == "y" ] && { logThis "Running sudo apt-get for TWO installs.  You will need to provide your password w/ sudo rights."; } || { logThis "OK, I'll stop now."; exit 0; }

	sudo apt-get install openjdk-6-jdk
	sudo apt-get install openjdk-6-jre-headless

	logThis "Validating install"
	keyPath2=`whereis keytool | awk -F " " '{print $2}'`
	[ "${keyPath2}" == "" ] && { logThis "Ok, somethings is wrong. I'll stop now before I make a mess."; exit 1; }
}

keyGen () {
	logThis "Collecting Certificate Info"
	echo -n -e "\tType in your FIRST name: "
	read fname
	echo -n -e "\tType in your LAST name: "
	read lname
	echo -n -e "\tType in your city: "
	read city
	echo -n -e "\tType in your state (do not abbreviate): "
	read state
	echo -n -e "\tType in your country 2 letter code (US): "
	read -n 2 country
	echo " "
	echo " "

	[ "${newPass}" != "" ] && { mypass="${newPass}"; } || { mypass="${keyPass}"; }
	keytool -genkey -keystore "${fqdn}".jks -alias tomcat -keyalg RSA -keysize 2048 -storepass "${mypass}" -keypass "${mypass}" -dname "CN=${fname} ${lname}, OU=${fqdn}, O=${fqdn}, L=${city}, S=${state}, C=${country}"
	keytool -certreq -keystore "${fqdn}".jks -alias tomcat -keyalg RSA -storepass "${mypass}" -file "${fqdn}".csr

	logThis "${fqdn}.jks has been created"
	logThis "${fqdn}.csr has been created.  Send this to your 3rd party SSL Cert provider."
	echo " "
	cat "./${fqdn}.csr"
	echo " "
	logThis "When you have your .cer file, use './${logtag} import _file_.cer' to complete this script"
	logThis "Don't forget to import your root CA BEFORE you import your signed Cert!"
	logThis	"keytool -import -alias root -keystore ${fqdn}.jks -trustcacerts -file /path/too/ca.pem"
	echo " "
	echo " "
}

importCheck () {
#	[ "$2" == "" ] && { echo -n "Your .cer file is missing.  Do you just want to copy/paste your key? [y|n]: "; }
#	read -n 1 copyYesNo
#	echo " "
#	if [ "${copyYesNo}" == "y" ]; then 
#		echo "Paste your signed cert key from your 3rd party SSL Cert provider"
#		read -n signedCert
#		echo "${signedCert}" > "${fqdn}".cer
#	fi
	certExt=`echo "$2" | rev | cut -b 1-3 | rev`

	logThis "Going to verify your commands."
	[ "${2}" == "" ] && { logThis "Your .cer file is missing.  Be sure to enter a file name."; exit 1; }
	[ ! -e "${2}" ] && { logThis "$2 cannot be found.  Be sure it is placed in the same directory as this script ${SCRIPTPATH}"; exit 1; }
	[ "${certExt}" != "cer" ] && { logThis "$2 file extension does not end with '.cer'.  Please fix so I know you have read the directions"; exit 1; }

#	keyImport
	logThis "Ready to import ${2}!"
	importNOW=`keytool -import -alias tomcat -keystore "${fqdn}".jks -trustcacerts -file "${2}"`

	[ "${importNOW}" ] && { logThis "Importing ${2} was successful!"; } || { logThis "There was an error.  Sorry. *sad trombone*"; exit 1; }
}

#keyImport () {
#	[ "${copyYesNo}" == "y" ] && { myFile="${fqdn}".cer; } || { myFile="$2"; }
#	keytool -import -alias tomcat -keystore "${fqdn}".jks -trustcacerts -file "${myFile}"
#	keytool -import -alias tomcat -keystore "${fqdn}".jks -trustcacerts -file "${2}"
#}

case "$1" in
	import)
		importCheck "$1" "$2"
		;;
	generate)
		init
		confCheck
		keyCheck
		keyGen
		;;
	*)
		echo "To use this script, start with './${logtag} generate' to create your csr and jks keystore."
		exit 0
esac