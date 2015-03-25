#!/bin/bash

source ./pref.cfg

function youjizz_streamer() {
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

curl -s "http://www.youjizz.com/" > $tmp/yp.$$


cat $tmp/yp.$$ | grep "<a class=\"frame" | sed -n -e 's/.*<a class=\"frame\" href=\(.*\)><\/a>.*/\1/p' |  cut -d"'" -f2 > $tmp/vids.$$

if [ "$(cat $tmp/vids.$$)" = "" ]
then 
  dialog --msgbox "No Videos found..." 5 30
  rm -f $tmp/vids.$$
  exec $ecdir/emucom
fi

i=1
while read line
do
id=$(echo $line | cut -d"/" -f3 | cut -d"." -f1)
echo $id >>$tmp/options1.$$ 
  i=`expr $i + 1`
done <$tmp/vids.$$
OPTIONS=`cat $tmp/options1.$$`

# present menu options

dialog --title " Youjizz.com " --cancel-label "Back" --column-separator " " --no-tags --menu "Select video:" $l1 $col $l2 ${OPTIONS} 2> $tmp/answer

if [ "$?" = "0" ]
then
	ch=$(cat $tmp/answer)

	youjizz_streamer "http://www.youjizz.com/videos/$ch.html"
	exec $menu/redtube.sh
# Cancel is pressed
else
rm -f $tmp/vids.$$
rm -f $tmp/options.$$
rm -f $tmp/yp.$$
exec $menu/restricted.sh
rm -f $tmp/options1.$$
fi
done
rm -f $tmp/vids.$$
rm -f $tmp/options.$$
rm -f $tmp/options1.$$
rm -f $tmp/yp.$$
exit
