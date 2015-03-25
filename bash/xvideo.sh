#!/bin/bash

source ./pref.cfg

function xvideo_streamer() {
echo $(tty) | grep "/dev/tty"
if [ $? != 0 ]; then
	youtube-dl -q -o - "$1" | vlc -
else
	youtube-dl -q -o - "$1" | mplayer -vo fbdev2 -really-quiet -fs -ao alsa - 
fi
}

#if [ -z $DISPLAY ]
#  then
#    DIALOG=dialog
#  else
#    DIALOG=Xdialog
#  fi

#dialog --rangebox "Please enter page:" 2 40 1 40 1 2>$tmp/answer

#if [ "$?" = "0" ]
#then
#page=$(cat $tmp/answer)
#curl -s "http://www.xvideos.com/new/$page/" > $tmp/pmht_output
# else
#  exec $menu/restricted.sh
#fi

curl -s "http://www.xvideos.com" > $tmp/pmht_output

cat $tmp/pmht_output | grep "<p><a href=\"" | sed -n -e 's/.*<p><a href=\"\(.*\)<\/a><\/p>.*/\1/p' > $tmp/pmht_vids

if [ "$(cat $tmp/pmht_vids)" = "" ]
then 
  dialog --msgbox "No Videos found..." 5 30
  rm -f $tmp/pmht_vids
  rm -f $tmp/pmht_output
  exec $menu/restricted.sh
fi

rm -f $tmp/pmht_options1 
i=1
while read line
do
id=$(echo $line | cut -d"/" -f2)
name=$(echo $line | cut -d"/" -f4 | cut -d">" -f1 | cut -d"\"" -f1 )
echo $id $name>>$tmp/pmht_options1 
  i=`expr $i + 1`
done <$tmp/pmht_vids
OPTIONS=`cat $tmp/pmht_options1`

# present menu options

dialog --title " XVideo.com " --cancel-label "Back" --column-separator " " --no-tags --menu "Select video:" $l1 $col $l2 ${OPTIONS} 2> $tmp/answer

if [ "$?" = "0" ]
then
	ch=$(cat $tmp/answer)
	xvideo_streamer "http://www.xvideos.com/$ch"
	exec $menu/redtube.sh
# Cancel is pressed
else
rm -f $tmp/pmht_vids
rm -f $tmp/pmht_options
rm -f $tmp/pmht_output
exec $menu/restricted.sh
rm -f $tmp/pmht_options1
fi
done
rm -f $tmp/pmht_vids
rm -f $tmp/pmht_options
rm -f $tmp/pmht_options1
rm -f $tmp/pmht_output
exit
