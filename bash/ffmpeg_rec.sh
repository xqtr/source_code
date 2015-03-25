#!/bin/bash

ffmpeg -r 30 -s 1680x1050 -f x11grab -i :0.0 -vcodec msmpeg4v2 -qscale 1 ~/hello.avi

#ffmpeg -f alsa -ac 2 -ab 56k -i pulse -acodec pcm_s16le -f x11grab -r 30 -s 1280x960 -i :0.0 -vcodec msmpeg4v2 -qscale 1 ~/hello.avi

#ffmpeg -f alsa -ac 2 -ab 128k -i pulse -acodec mp3 -f x11grab -r 30 -s 1280x960 -i :0.0 -vcodec msmpeg4v2 -qscale 1 ~/hello.avi  
#ffmpeg -f alsa -ac 2 -ab 128k -i pulse -acodec mp3 -f x11grab -r 30 -s 1680x1050 -i :0.0 -vcodec msmpeg4v2 -qscale 1 ~/hello.avi  
