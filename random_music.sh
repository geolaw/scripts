#!/bin/bash

# GEL (C) 2022
# work in progress
# randomizes music playback

IFS="$(printf '\n\t')"
MUSIC="/Music/Music"
cd $MUSIC
back_to_root=0

while [ 1 ]; do
	#pwd
        # randomize the files/directories in the current directory
	dir=$(ls | shuf -n1);
        # count the files/directories inside to provide a # tracks
	count=$(find $dir -ls |wc -l);  # will also contain directories, -t file?
        if [ $back_to_root == 1 ]; then
	    echo -n "play $lastdir -> $dir? ($count) y/n/q > "
        else
	    echo -n "play $dir? ($count) y/n/q > "
        fi
	read answer

	if [ "$answer" == "y" ]; then
		# if $count > 10, e.g. artist with many albums, cd into it and then loop back to the top
		echo "$dir has $count songs"
		# if count > X , cd into $dir and then
		if [[ $count -gt 10 && $back_to_root == 0 ]]; then
			# cd into $dir and then fall back to the top to select a random album from this artist
			cd $dir
                        lastdir="$dir"
			back_to_root=1  # flag to track position
		else
			# play dir
			mpv $dir
			# if back_to_root is set, we cd back to the top and restart with another artist
			if [ "$back_to_root" == "1" ]; then
				cd $MUSIC
				back_to_root=0
			fi
                        lastdir=""
		fi
	else
		if [ "$answer" == "q" ]; then
			exit;
		fi
                # else  = if they answer n - fall through and re-randomize
        fi
done

