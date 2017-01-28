#!/bin/bash
for i in *.wav; do 
sox "$i" $(basename "$i").ogg flanger 30 10 95 40 2 tri 45 lin pitch -400 chorus 0.4 0.8 20 0.5 0.10 2 -t echo 0.9 0.8 33 0.9 echo 0.7 0.7 10 0.2 echo 0.9 0.2 55 0.5 vol 40; done
