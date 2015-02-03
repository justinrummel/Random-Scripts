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

# Version 1.0.0 - 9/23/2012

### Description 
# Goal is to remove Recovery HD just in case your imaging fleet of OS X machines has it available
# This will remove the Recovery HD partition and then merge the extra space w/ the primary drive

# Script Variables
RecoveryHDName="Recovery HD"
RecoveryHDID=`/usr/sbin/diskutil list | grep "$RecoveryHDName" | awk 'END { print $NF }'`
HDName="MBA HD"
MBAHD=`/usr/sbin/diskutil list | grep "$HDName" | awk 'END { print $NF }'`

### functions
[[ "${RecoveryHDID}" != "" && "${MBAHD}" != "" ]] && { echo "Removing ${RecoveryHDName} from ${MBAHD}"; } || { echo "There is an error.  Stopping now."; exit 1; }
diskutil eraseVolume HFS+ ErasedDisk "/dev/${RecoveryHDID}"

[[ "${RecoveryHDID}" != "" && "${MBAHD}" != "" ]] && { diskutil mergePartitions HFS+ "${HDName}" "${MBAHD}" "${RecoveryHDID}"; }
exit 0
