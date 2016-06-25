#!/bin/bash

#ffmpegs -r 30 -s 1680x1050 -f x11grab -i :0.0 -vcodec msmpeg4v2 -qscale 1 $1
#ffmpeg -r 25 -s 800x600 -f x11grab -i :0.0+0,0 -vcodec msmpeg4v2 -qscale 1 $1
 ffmpeg -f pulse -ac 2 -i default -f x11grab -r 30 -s 800x600 -i :0.0+440,250 -acodec pcm_s16le -vcodec libx264 -preset ultrafast -threads 0 -y $1
#ffmpeg -f alsa -ac 2 -acodec pcm_s16le -i hw:0 -f x11grab -r 25 -s 800x600 -i :0.0 -vcodec msmpeg4v2 -qscale 1 $1
#ffmpeg -video_size 800x600 -framerate 25 -f x11grab -i :0.0+0,0 -f pulse -ac 2 -i default $1
#ffmpeg -video_size 800x600 -framerate 25 -f x11grab -i :0.0+0,0 -f alsa -ac 2 -i hw:0 $1
#ffmpeg -f alsa -ac 2 -acodec mp3 -f x11grab -r 30 -s 1280x960 -i :0.0 -vcodec msmpeg4v2 -qscale 1 $1
#ffmpeg -f alsa -ac 2 -ab 128k -i pulse -acodec mp3 -f x11grab -r 30 -s 1680x1050 -i :0.0 -vcodec msmpeg4v2 -qscale 1 ~/hello.avi  
