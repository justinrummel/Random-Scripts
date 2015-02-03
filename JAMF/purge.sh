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
# Version 1.0.0 - 2013-11-17

# Modified by Justin Rummel
# Vesion 1.0.1 - 2014-10-16

### Description 
# Goal is to use the purge command to clear out unused memory.  
# Confession, I feel dirty doing this

# Base Variables that I use for all scripts.  Creates Log files and sets date/time info
declare -x SCRIPTPATH="${0}"
declare -x RUNDIRECTORY="${0%/*}"
declare -x SCRIPTNAME="${0##*/}"

logtag="${0##*/}"
debug_log="disable"
logDate=`date "+%Y-%m-%d"`
logDateTime=`date "+%Y-%m-%d_%H:%M:%S"`
log_dir="/Library/Logs/${logtag}"
LogFile="${logtag}-${logDate}.log"

# Script Variables
osx=`sw_vers -productVersion | awk -F "." '{print $2}'`

# Script Functions

# Output to stdout and LogFile.
logThis () {
    logger -s -t "${logtag}" "$1"
    [ "${debug_log}" == "enable" ] && { echo "${logDateTime}: ${1}" >> "${log_dir}/${LogFile}"; }
}


#init () {
#    # Make our log directory
#    [ ! -d $log_dir ] && { mkdir $log_dir; }
#
#    # Now make our log file
#    if [ -d $log_dir ]; then
#        [ ! -e "${log_dir}/${LogFile}" ] && { touch $log_dir/${LogFile}; logThis "Log file ${LogFile} created"; logThis "Date: ${logDateTime}"; }
#    else
#        echo "Error: Could not create log file in directory $log_dir."
#        exit 1
#    fi
#    echo " " >> "${log_dir}/${LogFile}"
#}

purgeRAM () {
    [ "${osx}" -gt "8" ] && { purge="/usr/sbin/purge"; }
    [ "${osx}" -eq "8" ] && { purge="/usr/bin/purge"; }
    [ "${osx}" -lt "8" ] && { logThis "Not sure if 'purge' is supported on your OS."; }

    /usr/bin/sudo "${purge}";
    [ "$?" -ne "0" ] && { logThis "Error, purge command failed with the status: $?"; }
}

purgeRAM

exit 0
