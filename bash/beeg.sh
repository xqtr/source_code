#!/bin/bash

#source ./pref.cfg

tmp='/tmp'

function play {
echo $(tty) | grep "/dev/tty"
if [ $? != 0 ]; then
	vlc $1
else
	mplayer -vo fbdev2 -ao alsa -fs $1
fi
   
}


function viewmenu () {
dialog --keep-window \
--no-tags --menu "Office Menu" 16 30 9 \
1 "Watch Video" \
2 "View Image" \
3 "Download"  2> $tmp/answer

if [ "$?" = "0" ]
then
	ch=$(cat $tmp/answer)
	case $ch in
	# /home is selected
	  1) play $1
		viewmenu $1 $2;;
	  2) wget http://img.beeg.com/236x177/$2.jpg -O $tmp/$2.jpg
		xdg-open $tmp/$2.jpg
		viewmenu $1 $2;;
          3) wget $1
		disown
		viewmenu $1 $2;;
	  *) exit;;
        esac
 
# Cancel is pressed
else
        mainmenu
fi
}

#if [ -z $DISPLAY ]
#  then
#    DIALOG=dialog
#  else
#    DIALOG=Xdialog
#  fi


function mainmenu {

IFS=$'\n\t'
i=1
while read a b ; do 
echo $a $b >> $tmp/opt.$$
i=`expr $i + 1`;
done < <(paste $tmp/beeg_vids.$$ $tmp/beeg_desc.$$)

OPTIONS=`cat $tmp/opt.$$`

# present menu options
dialog --title " beeg.com " --no-items --menu "Select video:" 20 78 18 ${OPTIONS} 2> $tmp/answer

if [ "$?" = "0" ]
then
	ch=$(cat $tmp/answer | cut -d" " -f1)
	#echo $ch
	
	curl -s http://beeg.com/$ch > $tmp/beeg1.$$
    cat $tmp/beeg1.$$ | grep 'download title' | sed -n -e 's/.*<a href=\"\(.*\)\"\ >.*/\1/p'
	cat $tmp/beeg1.$$ | grep 'download title' | sed 's/<a href="//g' | sed 's/"//g' | sed 's/      //g' | cut -d" " -f1 > $tmp/link.$$
	clear


	viewmenu $(cat $tmp/link.$$) $ch
		
	#sleep 5

	#tube8_streamer $ch
	
# Cancel is pressed
else
 clear
fi
}

curl -s http://beeg.com > $tmp/beeg.$$

cat  $tmp/beeg.$$ | grep 'var tumbid' | sed 's/var tumbid  =\[//g' | sed 's/];//g' | sed 's/,/\n/g' > $tmp/beeg_vids.$$

cat  $tmp/beeg.$$ | grep 'var tumbalt' | sed 's/var tumbalt =\[//g' | sed 's/];//g' | sed 's/, / /g' | sed 's/,/\n/g' > $tmp/beeg_desc.$$

if [ "$(cat $tmp/beeg_vids.$$)" = "" ]
then 
  dialog --msgbox "No Videos found..." 5 30
  rm -f $tmp/beeg.$$
  rm -f $tmp/beeg_vids.$$
  rm -f $tmp/beeg_desc.$$
  exit  
fi

mainmenu

unset IFS 
rm -f $tmp/beeg.$$
rm -f $tmp/beeg1.$$
rm -f $tmp/link.$$
rm -f $tmp/beeg_vids.$$
rm -f $tmp/options.$$
rm -f $tmp/opt.$$
rm -f $tmp/beeg_desc.$$
rm -f $tmp/answer
exit
