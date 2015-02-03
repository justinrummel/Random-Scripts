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

# DESCRIPTION
# This is not used anymore.  This was to help clean out test posts to PCP running on Mac OS X 10.6 Server after integration was complete

# variables for testing
test="disable"		# for testing purposes, use enable

# functions
verifyRoot () {
	#Make sure we are root before proceeding.
	[ `id -u` != 0 ] && { echo "$0: Please run this as root."; exit 0; }
}

showIntro () {
	# Test Mode disclaimer
	echo "\n\c"
	[ "${test}" == "enable" ] && { echo "########## Test Mode Enabled ##########\nAll delete commands have been beaten over the head with Chickens.\n\n"; }
	
	# variables
	pcpFiles=`serveradmin settings pcast:shared_filesystem | awk -F "\"" '{print $2}'`
	wikiFiles=`serveradmin settings teams:repositoryPath | awk -F "\"" '{print $2}'`

	script=`echo $0 | sed 's/.\///' | awk -F . '{print $1}'`
	echo "Now running $script on $HOSTNAME."

	# Checking to see if we are running on OS X Server
	OSCheck=`sw_vers -productName | awk -F " " '{print $4}'`
	[ ! "$OSCheck" == "Server" ] && { echo "Sorry, this is not OS X Server... no matter what you have running."; exit 1; }

	# Checking for pcast
	echo "Testing for 'pcast' service"
	pservice=`serveradmin status pcast | grep pcast:state | awk -F \" '{print $2}'`
	[ "$pservice" == "RUNNING" ] && { echo "Podcast Producer is running"; } || { echo "This script runs on your PCP server only."; exit 0; }
}

showOptions () {
	if [[ "$OSCheck" == "Server" && "$pservice" == "RUNNING" ]]; then
		echo "\n\c"
		echo "Please choose one of the following options:"
		echo "\t1) List Workflows"
		echo "\t2) List Podcasts"
		echo "\t3) List Wiki Posts\n"
		
		echo "Type the number you want to run, or Q to quit, followed by [ENTER]: \c"
		read option
	else
		echo "OSCheck: $OSCheck"
		echo "pservice: $pservice"
	fi

	#set -xv
	case $option in 
		1)
			clear
			workflowList
			;;
		2)
			clear
			podcastList
			;;
		3) 
			clear
			wikiList
			;;
		*)
			exit 1
	esac			
}

workflowList () {
##########
# Perform a find to get each plist file and grab the Name and UUID (which will be copy/paste to delete)
##########
	echo "\n\c"
	echo "Now listing Workflow names and UUID's\n"

##########
# It would be nice to get this info from the db.sqlite3 database, however it does not store the Name of the workflow.
##########
#
#	workflowID=`sqlite3 ${pcpFiles}/Server/db.sqlite3 "SELECT id FROM workflows"'`
#	workflowPATH=`sqlite3 ${pcpFiles}/Server/db.sqlite3 "SELECT uuid FROM workflows"'`
#	echo "\n\c"
#	[ "${workflows}" == "" ] && { echo "There are no Podcasts posts to delte."; exit 0; }
#	[ -d $pcpFiles ] && { echo "$workflows"; }

	find "${pcpFiles}/Server/Workflows/" -name "*.pwf" | while read info; do
		workName=`PlistBuddy -c "Print Name" "${info}/Contents/Info.plist"`
		workUUID=`PlistBuddy -c "Print UUID" "${info}/Contents/Info.plist"`
		printf "\"%s\" - (%s)\n" "$workName" "$workUUID"
	done

	echo "\n\c"
	echo "Copy/Paste an UUID to delete, or press Q to quit to the main menu, followed by [ENTER]: \c"
	read deleteUUID

##########
# Are you sure you want to delete?
##########
    # Check entry
    [[ "$deleteUUID" == "q" || "$deleteUUID" == "Q" ]] && { clear; showOptions; }
    
	# When deleting a Podcast, read the number entered by the User
	if [ "$deleteUUID" ]; then 
		deleteWorkTitle=`PlistBuddy -c "Print Name" "${pcpFiles}/Server/Workflows/${deleteUUID}.pwf/Contents/Info.plist"`
		echo "You picked UUID $deleteUUID - \"${deleteWorkTitle}\".  Are you sure you want to delete this? [Type \"YES\"]: \c"
		read verifyWID
	fi
	
	# Verify that we REALLY want to delete the Podcast
	if [ "$verifyWID" == "YES" ]; then
		[ "$test" == "enable" ] && { echo "Chicken: skipped --deleteworkflow $deleteUUID"; } || { podcast --deleteworkflow --workflow_uuid "$deleteUUID"; }
		[ "$test" == "enable" ] && { echo "Chicken: skipped --disablefeed $deleteUUID"; } || { podcast --disablefeed --feed_uuid "$deleteUUID"; }
		[ "$test" == "enable" ] && { echo "Chicken Scratch"; } || { echo "\"$deleteWorkTitle\" has been deleted"; }
		showOptions
	else
		echo "Verification failed.  You must type \"YES\" (without the quotes)\n\n"
	fi
}

podcastList () {
##########
# Performing a SQL search to get the ID and Title.
##########
	podcasts=`sqlite3 "${pcpFiles}/Server/db.sqlite3" "SELECT ID, TITLE FROM episodes" | awk -F "|" '{print $1 ") " $2}'`
	echo "\n\c"
	[ "${podcasts}" == "" ] && { echo "There are no Podcasts posts to delete.  Press Q to quit to the main menu followed by [ENTER]: \c"; read; clear; showOptions; }
	[ -d "$pcpFiles" ] && { echo "$podcasts"; }
	echo "\n\c"
	echo "Pick an ID to delete, or press Q to quit to the main menu, followed by [ENTER]: \c"
	read deleteID

##########
# Are you sure you want to delete?
##########
    # Check entry
    [[ "$deleteID" == "q" || "$deleteID" == "Q" ]] && { clear; showOptions; }

	# When deleting a Podcast, read the number entered by the User
	if [ "$deleteID" ]; then 
		deleteTitle=`sqlite3 "${pcpFiles}/Server/db.sqlite3" "SELECT TITLE FROM episodes WHERE ID='${deleteID}'"`
		echo "You picked #$deleteID - \"${deleteTitle}\".  Are you sure you want to delete this? [Type \"YES\"]: \c"
		read verifyID
	fi
	
	# Verify that we REALLY want to delete the Podcast
	if [ "$verifyID" == "YES" ]; then
		# Now lets delete within the PCP Library
		deleteUUID=`sqlite3 "${pcpFiles}/Server/db.sqlite3" "SELECT UUID FROM episodes WHERE ID='${deleteID}'"`
		deleteDate=`sqlite3 "${pcpFiles}/Server/db.sqlite3" "SELECT strftime('%Y-%m-%d', created_at) FROM episodes WHERE ID='${deleteID}'"`
		echo "Removing: ${pcpFiles}/Content/${deleteDate}/${deleteUUID}.prb"
		[ "$test" == "enable" ] && { echo "Chicken: ${pcpFiles}/Content/${deleteDate}/${deleteUUID}.prb"; } || { rm -rf "${pcpFiles}/Content/${deleteDate}/${deleteUUID}.prb"; }

		# Update Library
		[ "$test" == "enable" ] && { echo "Chicken: pcastconfig --sync_library"; } || { pcastconfig --sync_library; }
		[ "$test" == "enable" ] && { echo "Chicken Scratch"; } || { echo "\"$deleteTitle\" has been deleted"; }
		showOptions
	else
		echo "Verification failed.  You must type \"YES\" (without the quotes)\n\n"
	fi
}

wikiList () {
	# Check to see if Wiki still exists, if yes... delete
	# set -x
	# wikiGroup=`PlistBuddy ${pcpFiles}/Server/Workflows/${deleteUUID}.pwf/Contents/Resources/accounts.plist -c "Print" | grep URL | awk -F " " '{print $3}' | awk -F "/" '{print $5}'`
	# echo "${wikiFiles}/Groups/${wikiGroup}/weblog/"
	
	wiki=`sqlite3 "${wikiFiles}/globalIndex.db" "SELECT uid, title FROM pages WHERE disabled=0" | awk -F "/" '{print $4}' | awk -F "|" '{print $1 ") " $2}' | grep -v welcome`
	echo "\n\c"
	[ "${wiki}" == "" ] && { echo "There are no Wiki posts to delete.  Press Q to quit to the main menu followed by [ENTER]: \c"; read; clear; showOptions; }
	echo "${wiki}"
	echo "\n\c"
	echo "Copy/Paste the five-digit hash you want to delete, or press Q to quit to the main menu followed by [ENTER]: \c"
	read wikiID

##########
# Are you sure you want to delete?
##########
    # Check entry
    [[ "$wikiID" == "q" || "$wikiID" == "Q" ]] && { clear; showOptions; }

	# When deleting a Wiki Post, read the hash entered by the User.  This has is the same as you seen in the URL when looking at an individual post.
	if [ "$wikiID" ]; then 
		deleteWiki=`sqlite3 "${wikiFiles}/globalIndex.db" "SELECT title FROM pages WHERE uid LIKE '%${wikiID}'"`
		echo "You picked \"${deleteWiki}\".  Are you sure you want to delete this? [Type \"YES\"]: \c"
		read verifyPath
	fi

	if [ "$verifyPath" == "YES" ]; then
		deletePath=`sqlite3 "${wikiFiles}/globalIndex.db" "SELECT path FROM pages WHERE uid LIKE '%${wikiID}'"`
		sqlite3 "${wikiFiles}/globalIndex.db" "UPDATE pages SET disabled=1 WHERE uid LIKE '%${wikiID}'"
		[ "$test" == "enable" ] && { echo "Chicken: ${deletePath}"; } || { rm -rf "${deletePath}"; }
		[ "$test" == "enable" ] && { echo "Chicken Scratch"; } || { echo "\"$deleteWiki\" has been deleted"; }
		showOptions
	else
		echo "Verification failed.  You must type \"YES\" (without the quotes)\n\n"
	fi
}

readme () {
	echo "
PCPdelete.sh README
README Last Updated: 2/13/2011

Description
Individuals who perform integrations of Podcast Producer (PCP) or who are administrators of their PCP environments and begin testing workflows find themselves with a server that contains media files which are no longer suited for a production environment.  Integrators/SysAdmins also know that the current tools for removing Podcasts are limited to a minus button within Wiki/Blog (which does not remove the actual PNG/MOV files, nor removes them from the PCP Library).  In order to fully delete Podcasts, PCPdelete was created.

Solution
PCPdelete provides a Command line interface that allows you to delete from three different selections:

1) List Workflows
2) List Podcasts
3) List Wiki Posts

How To
1. Workflows
Function: This section will list all the available workflows within your PCP environment.  The script looks inside your {PCPLibrary}/Server/Workflows/ and finds all the "pwf" files, then print's their Names and UUIDs.  Copy/Paste the UUID and the script performs "podcast --deleteworkflow --workflow_uuid" and "podcast --disablefeed --feed_uuid" to ensure the Workflow has been deleted and all the associated RSS feeds are updated.

Logic: Now normally I would like to pull information from a database, however, the db.sqlite3 for workflows does not provide the name... only the ID, UUID, and Bundle Path (among other items).  Future release would be nice to get the correct BASH syntax and perform a PlistBuddy on the bundle_path field.  

2. Podcasts
Function: Even though this is listed for Podcasts, it only effects the PCP Library, not the actual Wiki/Blog page that your users see.  This is needed because if anyone actually dug into the PCP Library, they would be able to find all the test posts (or posts that were deleted for one reason or another).  The unfortunate thing is I cannot find any link between Wiki/Blog and the PCP Library within the OS or any SQLite3 databases.  

3. Wiki Posts
Function: The Wiki section of this script is needed because the minus button within the Wiki/Blog URL only deletes the page, not the media files (PNG/MOV).  There are a lot of sqlite3 commands against your Collaboration/globalIndex.db database, but in short it performs an UPDATE command that disables the post, then deletes all the files of that page.
"
	exit 0
}

[ "$1" == "help" ] && { readme; }

verifyRoot
showIntro
showOptions

exit 0
