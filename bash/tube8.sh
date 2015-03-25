#!/bin/bash

source ~/Scripts/pref.cfg

function tube8_streamer() {
youtube-dl -o - "$1" | mplayer -ao alsa - 
}

#if [ -z $DISPLAY ]
#  then
#    DIALOG=dialog
#  else
#    DIALOG=Xdialog
#  fi

curl -s www.tube8.com | grep '<div id="video_' | sed -n -e 's/.*<div id=\"video_//p' | sed -n -e 's/\" class="box-thumbnail-inner">//p' > $tmp/vids.$$

if [ "$(cat $tmp/vids.$$)" = "" ]
then 
  dialog --msgbox "No Videos found..." 5 30
  rm -f $tmp/vids.$$
  exec $menu/restricted.sh
fi

i=1
while read line
do
id=$(echo $line | cut -d"/" -f6)
name=$(echo $line | cut -d"/" -f5)
echo $id $name >>$tmp/options.$$ 
  i=`expr $i + 1`
done <$tmp/vids.$$
OPTIONS=`cat $tmp/options.$$`


# present menu options
dialog --title " Tube8.com " --cancel-label "Back" --no-items --menu "Select video:" $l1 $col $l2 ${OPTIONS} 2> $tmp/answer

if [ "$?" = "0" ]
then
	ch=$(cat $tmp/vids.$$ | grep $(cat $tmp/answer))
echo $ch
sleep 5

	tube8_streamer $ch

#Change resolution back to normal, if something goes wrong. 
	
	exec $menu/tube8.sh
# Cancel is pressed
else
        exec $ecdir/emucom
fi
rm -f $tmp/vids.$$
rm -f $tmp/options.$$
exit
