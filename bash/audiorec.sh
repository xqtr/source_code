#!/bin/sh

while true; do 
  sox -S -c 1 -r 22100 -t alsa default ./$(date +"%F_%T").vorbis silence 1 0.1 5% 1 1.0 5%

done 
