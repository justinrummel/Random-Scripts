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
# Version 1.0.0 - 1/14/2013

# Modified by
# Version 


### Description 
#  Find the Vendor (Apple or Oracle) for the current version of Java.  
#  Based on Rich's post at: http://derflounder.wordpress.com/2012/10/31/casper-extension-attribute-scripts-to-report-java-browser-plug-in-info/
#  and Christoph von Gabler-Sahm (linked via Rich)

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
javaVendor=`/usr/bin/defaults read /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Info CFBundleIdentifier`
javaVersion=`/usr/bin/defaults read /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Info CFBundleShortVersionString`
javaProject=`/usr/bin/defaults read /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/version ProjectName 2>/dev/null`


# Script Functions
appleJava () {
	[ "${javaProject}" == "" ] && { echo "<result>Apple (${javaVersion})</result>"; } || { echo "<result>Apple (${javaProject} - ${javaVersion})</result>"; }
}

oracleJava () {
	[ "${javaProject}" == "" ] && { echo "<result>Oracle (${javaVersion})</result>"; } || { echo "<result>Oracle (${javaProject} - ${javaVersion})</result>"; }
}

[ "$javaVendor" == "" ] && { echo "<result>No Java Plug-In Available</result>"; exit 0;}
[ "$javaVendor" == "com.apple.java.JavaAppletPlugin" ] && { appleJava;}
[ "$javaVendor" == "com.oracle.java.JavaAppletPlugin" ] && { oracleJava;}

exit 0;