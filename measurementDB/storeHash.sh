#!/bin/bash
# (c) Copyright 2016-2017 Hewlett Packard Enterprise Development LP
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License, version 2, as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Authors:	Victor Sallard
#		Adrian L. Shaw <adrianlshaw@acm.org>
#
# This script will find the debian packages, unpack them,
# hash the executables and store the hash in Redis.
# It will also keep track of the already hashed packages
# and store their name in a file

computeHash(){
	TEMP=$(mktemp -d --tmpdir=./$TDIR)
	dpkg -x ../packages/$1 $TEMP
	cd $TEMP
	find ./ -type f ! -empty | sed '/^\s*$/d' | xargs file | grep -i "ELF" | cut -d ":" -f 1 | xargs sha1sum | sed "s/$/@$(basename $1 | sed -e 's/[\/&]/\\&/g')/g"
	cd ..
	rm -rf $TEMP
	exit 0
}

export -f computeHash

TDIR=$(mktemp -d --tmpdir=./)
touch scan_files
cd $TDIR
cat ../scan_files | parallel computeHash {} >> ../shaLog

rm ../scan_files

sort -u ../shaLog > shlg
mv shlg ../shaLog
cd ..
rm -rf $TDIR
