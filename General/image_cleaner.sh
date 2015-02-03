#!/bin/sh
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

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/libexec export PATH

# Backup, Use at your own risk, it's not our fault if you lost data

# README
#	this script does some cleanup in preperation for building an image
#	best to run this from single user mode, or at least right before you shutdown (do not use in Target Disk Mode)
#   target disk mode functionality to be introduced later
#	run this as root, or with sudo rights

#variables
ADMIN="appleadmin"						# change this to whatever your Local Admin is named and you have been using to install software
TARGET_HD="/Volumes/Macintosh HD"
ADMINPATH="/Users/"					# path of your Local Admin (/private/var could be for hidden admins)
SETUPAGAIN="disable" 				# Run the Setup Assistant as if it was brand new out of the box (enable or disable)  
ROOTD="disable"						# enable if root was used for this image (enable or disable), and you want to clean it up
ADMIN_CLEANUP="enable"				# enable if root admin used for this image (enable or disable), and you want to clean it up
SHARED="disable"					# enable if you wante to remove everything from the /Users/Shared folder (enable or disable)  !!!WARNING!!! see message below
PRIVACY_RESET="enable"				# enable if you want to reset all privacy settings on 10.8 or later
DELETE_SWAPFILE="enable"			# enable if you want to delete the OS swapfile
DELETE_VOLINFO="enable"				# enable if you want to delete the volinfo db
DELETE_SLEEPIMAGE="enable"			# enable if you want to delete the OS sleepimage
DELETE_DS_FILES="enable"			# enable if you want to globally remove all .DS_Store files on a machine
RESET_BOOTCACHE="enable"			# enable if you want to reset (remove) the bootcache.playlist; recreated upon system boot for boot optimization. Can vary and is hardware-dependent
CLEAN_SINGLE_KEXT_CACHE="enable"	# enable if you want to clean (delete) all cached kernel extensions (cached kernel code, linked kexts, and some potential kext info dictionaries)
CLEAN_MULTI_KEXT_CACHE="enable"		# enable if you want to clean (delete) all multi-cached kernel extensions (multiplus kernel caches and their associated userinfo dictionaries)
EMPTY_BASE_TRASH="enable"			# enable to empty trash at the boot level volume
SELF_DESTRUCT="enable"				# force script to securely remove itself (default is immediately)

#set machine names back to generic
#/usr/sbin/scutil --set ComputerName "OSX_Standard_Image"
#/usr/sbin/scutil --set LocalHostName "osximg"

#enable Setup Assistant
if [ "$SETUPAGAIN" == "enable" ]; then
	if [ -e /private/var/db/.AppleSetupDone ]; then
		rm -f /private/var/db/.AppleSetupDone
	fi
		
	if [ -e /private/var/db/.AutoBindDone ]; then
		rm -f /private/var/db/.AutoBindDone
	fi
fi

#delete swapfiles (these are typically equivalent in size to the physical RAM, in GB, from the target machine)
if [ "$DELETE_SWAPFILE" == "enable" ]; then
rm /private/var/vm/swapfile*
fi

#delete sleep image for a truly "clean" system
if [ "$DELETE_SLEEPIMAGE" == "enable" ]; then
	if [ -e /var/vm/sleepimage ]; then
		rm -f /var/vm/sleepimage
	fi
fi

#delete volume info DB
if [ "$DELETE_VOLINFO" == "enable" ]; then
	if [ -e /private/var/db/volinfo.database ]; then
		rm -f /private/var/db/volinfo.database
	fi
fi

#delete tccutil database if asked for (check for 10.8 first)
OSXREV=`sw_vers -productVersion`
if [ "$OSXREV" == "enable" ]; then
	OSXREV=`sw_vers -productVersion`
	if [ ${OSXREV:3:1} == 8 ]; then
		tccutil reset
	fi
fi		

#delete all ds_store files
if [ "$DELETE_DS_FILES" == "enable" ]; then
sudo find . -name *.DS_Store -type f -exec rm {} \;
fi

#delete the bootcache.playlist file
if [ "$RESET_BOOTCACHE" == "enable" ]; then
	if [ -e /var/db/BootCache.playlist ]; then
		sudo rm /var/db/BootCache.playlist
	fi
fi

#delete kextcaches
if [ "$CLEAN_SINGLE_KEXT_CACHE" == "enable" ]; then
	if [ -e /System/Library/Extensions.kextcache ]; then
		sudo rm /System/Library/Extensions.kextcache
	fi
fi

#delete multi-kextcaches
if [ "$CLEAN_MULTI_KEXT_CACHE" == "enable" ]; then
	if [ -e /System/Library/Extensions.mkext ]; then
		sudo rm /System/Library/Extensions.mkext
	fi
fi

#empty system trash
if [ "$EMPTY_BASE_TRASH" == "enable" ]; then
	sudo rm /.Trashes*;
fi

#cleanup local admin's home dir
if [ "$ADMIN_CLEANUP" == "enable" ]; then
rm -rf ${ADMINPATH}${ADMIN}/Desktop/*
rm -rf ${ADMINPATH}${ADMIN}/Documents/*
rm -rf ${ADMINPATH}${ADMIN}/Library/Caches/*
rm -rf ${ADMINPATH}${ADMIN}/Library/Recent\ Servers/*
rm -rf ${ADMINPATH}${ADMIN}/Library/Logs/*
rm -rf ${ADMINPATH}${ADMIN}/Library/Keychains/*
rm -rf ${ADMINPATH}${ADMIN}/Library/Preferences/ByHost/*
rm -f ${ADMINPATH}${ADMIN}/Library/Preferences/com.apple.recentitems.plist
rm -rf ${ADMINPATH}${ADMIN}/Movies/*
rm -rf ${ADMINPATH}${ADMIN}/Music/*
rm -rf ${ADMINPATH}${ADMIN}/Pictures/*
rm -rf ${ADMINPATH}${ADMIN}/Public/Drop\ Box/*
rm -f ${ADMINPATH}${ADMIN}/.DS_Store
rm -rf ${ADMINPATH}${ADMIN}/.Trash
rm -f ${ADMINPATH}${ADMIN}/.bash_history
rm -rf ${ADMINPATH}${ADMIN}/.ssh
fi

#cleanup root's home dir
if [ "$ROOTD" == "enable" ]; then
	rm -rf /private/var/root/Desktop/*
	rm -rf /private/var/root/Documents/*
	rm -rf /private/var/root/Downloads/*
	rm -rf /private/var/root/Library/Caches/*
	rm -rf /private/var/root/Library/Recent\ Servers/*
	rm -rf /private/var/root/Library/Logs/*
	rm -rf /private/var/root/Library/Keychains/*
	rm -rf /private/var/root/Library/Preferences/ByHost/*
	rm -f /private/var/root/Library/Preferences/com.apple.recentitems.plist
	rm -rf /private/var/root/Public/Drop\ Box/*
	rm -f /private/var/root/.DS_Store
	rm -rf /private/var/root/.Trash
	rm -f /private/var/root/.bash_history
	rm -rf /private/var/root/.ssh
fi

#clean up global caches and temp data
rm -rf /Library/Caches/*
rm -rf /System/Library/Caches/*
rm -f /private/etc/ssh_host*
if [ "$SHARED" == "enable" ]; then
	rm -rf /Users/Shared/*   #check licenses (i.e. Adobe) and other software may store information at this location
fi

#clean up Managed preferences
rm -rf /Library/Managed\ Preferences/*

#network interfaces - this is regenerated on reboot and can differ on different hardware
rm /Library/Preferences/SystemConfiguration/NetworkInterfaces.plist

#Leopard - cleanup local KDC, see http://support.apple.com/kb/TS1245
rm -rf /private/var/db/.configureLocalKDC
rm -rf /private/var/db/krb5kdc
rm -rf /private/etc/krb5.keytab
#rm -rf /Library/Keychains/System.keychain  (Do not destory.  Needed if SSID or 802.1x are installed)


#log cleanup. We touch the log file after removing it since syslog
#won't create missing logs.
rm /private/var/log/alf.log
touch /private/var/log/alf.log
rm /private/var/log/cups/access_log
touch /private/var/log/cups/access_log
rm /private/var/log/cups/error_log
touch /private/var/log/cups/error_log
rm /private/var/log/cups/page_log
touch /private/var/log/cups/page_log
rm /private/var/log/daily.out
rm /private/var/log/ftp.log*
touch /private/var/log/ftp.log
rm -rf /private/var/log/httpd/*
rm /private/var/log/lastlog
rm /private/var/log/lookupd.log*
rm /private/var/log/lpr.log*
rm /private/var/log/mail.log*
touch /private/var/log/lpr.log
rm /private/var/log/mail.log*
touch /private/var/log/mail.log
rm /private/var/log/monthly.out
rm /private/var/log/run_radmind.log
rm -rf /private/var/log/samba/*
rm /private/var/log/secure.log
touch /private/var/log/secure.log
rm /private/var/log/system.log*
touch /private/var/log/system.log
rm /private/var/log/weekly.out
rm /private/var/log/windowserver.log
touch /private/var/log/windowserver.log
rm /private/var/log/windowserver_last.log
rm /private/var/log/wtmp.*

#self-destruct -- requires 10.5 or later. This needs to be updated to address Mac OS X 11, but will work for 10.5-10.9.
OSXREV=`sw_vers -productVersion`
if [ "$OSXREV" == "enable" ]; then
	OSXREV=`sw_vers -productVersion`
	if [ ${OSXREV:3:1} >= 5 ]; then
		if [ "$SELF_DESTRUCT" == "enable" ]; then
			/usr/bin/srm $0 image_cleaner.sh
		fi
	fi
fi		
