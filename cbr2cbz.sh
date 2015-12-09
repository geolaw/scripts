#!/bin/bash  -x
# Author: George Law
# License: GPL3+
# takes a cbr comic book archive and reformats it as cbz.
# requires unzip + unrar
#
# suitable to be used either as a exec option to find :  find . -name "*.cbr" -exec cbr2cbz.sh {} \;
# or as a option within the nemo file manager using included cbr2cbz.nemo_action

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
FULLFILE="$1" #including full path
FILE=`echo $FULLFILE|rev|awk -F\/ '{print $1}'|rev` #just the file name
OUTFILE=`echo $FILE|sed 's/cbr/cbz/'`
DIR=`dirname $FULLFILE`
if [ "$DIR" == "" ]; then
    DIR=./
fi
echo Converting $FILE to cbz format.
TMPDIR=$$
if [ -e /tmp/$TMPDIR ]; then
   rm -rf /tmp/$TMPDIR
fi
echo Extracting rar to /tmp/$TMPDIR
mkdir "/tmp/$TMPDIR";
unrar x $DIR/"$FILE" -o "/tmp/$TMPDIR/";
cd /tmp/$TMPDIR

echo "Creating zip $DIR/$OUTFILE from /tmp/$TMPDIR"
zip -r "$DIR/$OUTFILE"  *
cd $PWD
rm -rf "/tmp/$TMPDIR";
#Remove or comment out this line if you want to keep cbr files
#rm -rf "$DIR/$FILE"
echo Conversion of $FILE successful!
ls -la "$DIR/$OUTFILE"
IFS=$SAVEIFS
