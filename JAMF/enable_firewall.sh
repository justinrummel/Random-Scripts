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
# Version 1.0.0 - 2014-10-02

### Description
# This is an example to always enforce the Application layer Firewall on startup

# enable firewall
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1

# unload alf
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.alf.useragent.plist
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist

# load alf
sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist
sudo launchctl load /System/Library/LaunchDaemons/com.apple.alf.useragent.plist

exit 0
