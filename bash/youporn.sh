#!/bin/bash

source ~/Scripts/pref.cfg

function youporn_streamer() {
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

curl -s www.youporn.com > $tmp/yp.$$

cat  $tmp/yp.$$ | grep '<a href="/category/' | sed 's/\(<li>\)/\n\1/g' | sed -n -e 's/.*<a href=\"\(.*\)\">.*/\1/p' > $tmp/cats.$$


if [ "$(cat $tmp/cats.$$)" = "" ]
then 
  dialog --msgbox "No Videos found..." 5 30
  rm -f $tmp/cats.$$
  rm -f $tmp/yp.$$
  exec $menu/restricted.sh
fi

rm -f $tmp/options.$$ 
i=1
while read line
do
id=$(echo $line | cut -d"/" -f3)
name=$(echo $line | cut -d"/" -f4)
echo $id "$name" >>$tmp/options.$$ 
  i=`expr $i + 1`
done <$tmp/cats.$$
OPTIONS=`cat $tmp/options.$$`

# present menu options

while :
do

dialog --title " Youporn.com " --cancel-label "Back" --column-separator , --menu "Select Category:" $l1 $col $l2 ${OPTIONS} 2> $tmp/answer

if [ "$?" = "0" ]
then
	ch=$(cat $tmp/cats.$$ | grep -w $(cat $tmp/answer))

	curl -s "www.youporn.com$ch" > $tmp/yp.$$


# Cancel is pressed
else
rm -f $tmp/vids.$$
rm -f $tmp/options.$$
rm -f $tmp/yp.$$
        exit
fi

cat $tmp/yp.$$ | grep '<a href="/watch/' | sed -n -e 's/.*<a href=\"\(.*\)\">.*/\1/p' > $tmp/vids.$$

if [ "$(cat $tmp/vids.$$)" = "" ]
then 
  dialog --msgbox "No Videos found..." 5 30
  rm -f $tmp/vids.$$
	exit
fi

rm -f $tmp/options1.$$
i=1
while read line
do
id=$(echo $line | cut -d"/" -f3)
name=$(echo $line | cut -d"/" -f4)
echo $id "$name" >>$tmp/options1.$$ 
  i=`expr $i + 1`
done <$tmp/vids.$$
OPTIONS=`cat $tmp/options1.$$`

# present menu options

dialog --title " Youporn.com " --column-separator , --menu "Select video:" $l1 $col $l2 ${OPTIONS} 2> $tmp/answer


if [ "$?" = "0" ]
then
	ch=$(cat $tmp/vids.$$ | grep $(cat $tmp/answer))
 
	youporn_streamer "http://www.youporn.com"$ch

#Change resolution back to normal, if something goes wrong. 
	
	exec ~/Scripts/youporn.sh
# Cancel is pressed
else
rm -f $tmp/vids.$$
rm -f $tmp/options.$$
rm -f $tmp/yp.$$
        exit
fi
done
rm -f $tmp/vids.$$
rm -f $tmp/options.$$
rm -f $tmp/yp.$$
exit
