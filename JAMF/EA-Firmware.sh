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
# Goal is to find out if a firmware password has been set.  
# Must have the 'setregproptool' installed at /usr/local/bin by a separate install
# for this to work as 'setregproptool' is not available by default in OSX.  You can 
# get it from Recovery HD, or "Install OS X Mountain Lion.app"

### Variables

### Functions
detect () {
	FPenabled=`setregproptool -c`
	[ ! "${FPenabled}" ] && { echo "<result>Enabled</result>"; } || { echo "<result>Disabled</result>"; }
}

[ -e "/usr/local/bin/setregproptool" ] && { detect; } || { echo "CLI missing"; }
exit 0
