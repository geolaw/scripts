#!/bin/bash

# requires ffmpeg, ffprobe, imagemagick's convert and vidstab python module , python3

# print usage if no params
if [ -z $1 ]; then
    echo "usage: $0 -f <video file> -F <convert evaluate filter > -r <factor to reduce fps captures> -s <start mm:sec.fraction> -S <stabilize video first 0/1>"
    echo "for a list of all convert filters, run convert -list evaluate "
    exit
fi
# do the base software checks, only check python and vidstab if using -S
for i in ffmpeg ffprobe convert; do
    which $i 2>&1 > /dev/null
    if [ "$?" != "0" ]; then
        echo "Required program $i not found, exiting";
        exit;
    fi
done

until [[ -z $1  ]]; do
    case $1 in
	-f)  filename="$2"; shift ;;  # quote this in case video contains spaces
	-F)  filter=$2; shift ;;
	-r)  reduce_factor=$2; shift ;;
	-s)  start_time=$2; shift ;;
	-S)  stabilize=$2; shift ;;
    esac
    shift
done

# need to check the basic requires params of $filename and $filter are all there

newvid=new.mp4
if [ -z $stabilize ] || [ $stabilize == 0 ]; then
    echo "skipping stabilizing video"
    # just copy $filename to $newvid
    cp "$filename" $newvid
else
    which python3 2>&1 > /dev/null
    if [ "$?" != "0" ]; then
        echo "video stabilization requires python3 not found, exiting";
        exit;
    fi
    pip3 show vidstab 2>&1 > /dev/null
    if [ "$?" != "0" ]; then
        echo "video stabilization requires pip3 vidstab not found, exiting";
        exit;
    fi
    echo "stabilizing video"
    # first pass $filename through vidstab to stabilize it  - use the $newvid from here out to leave the source  video the same
    python3 -m vidstab -i "$filename" -o $newvid
fi

TMPDIR="tmp_$$"

if [ -e $TMPDIR ]; then
	rm -rf $TMPDIR
	mkdir $TMPDIR
else
    mkdir $TMPDIR
fi

# use ffprobe to determine length and fps from these 2 output lines
# Duration: 00:00:21.77, start: 0.000000, bitrate: 25404 kb/s
# Stream #0:0(eng): Video: h264 (High) (avc1 / 0x31637661), yuv420p(tv, bt709), 2400x1080, 25151 kb/s, SAR 1:1 DAR 20:9, 30 fps, 30 tbr, 90k tbn, 180k tbc (default)

ffprobe "$newvid" > $TMPDIR/ff_output 2>&1
duration_string=$(grep Duration: $TMPDIR/ff_output);
fps_string=$(grep Stream $TMPDIR/ff_output);

# probably won't have a hour or minute long video for this, so we just strip out the last digits
duration=$(echo $duration_string| sed 's/.*Duration.*[0-9][0-9]:[0-9][0-9]:\([0-9][0-9]\.[0-9][0-9]\),.*/\1/');
fps=$(echo $fps_string |sed 's/.*\([0-9][0-9]\) fps.*/\1/');

# optional $reduce_factor -  to decrease the number of slices - e.g. for 30 fps and 2 $reduce_factor, will capture 15 slices per second
if [ ! -z $reduce_factor ]; then
	images_per_sec=$(echo "$fps / $reduce_factor" | bc);
    else
        images_per_sec=$fps
fi

# optional -s option  to start slicing at a certain point in the video - e.g. instable video for the first 10 seconds, pass 11 to start slicing at 11 seconds in.
if [ -z  $start_time ]; then
	start_time="-ss 0"
else
	start_time="-ss $start_time"
fi

frames=$(echo "scale=2;$duration * $images_per_sec" | bc);
echo "Video is $duration seconds long at $fps fps - - will capture $images_per_sec images per second - which  should generate $frames images - start at $start_time"
# note that the -r $fps option placement is important.  If places BEFORE the -i it affects the input file rate
ffmpeg $start_time -loglevel quiet -stats -hide_banner -i "$newvid" -q:v 1 -r $images_per_sec   $TMPDIR/slice_%04d.png

# cd into $TMPDIR so all the output is generated in the $TMPDIR
cd $TMPDIR

newname="${filename%.*}_stacked.png"
#nice convert  -monitor -flatten slice* -evaluate-sequence $i output_$i.png
time convert  slice* -evaluate-sequence $filter ../$newname
exit;
if [ "$?" == "0" ]; then
    cd ..
    rm -r $TMPDIR
    rm $newvid
fi
ls -la $newname
