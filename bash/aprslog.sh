#!/bin/bash
       
#title           : APRS packet logger
#description     : 
#author			 : xqtr
#date            : 10/02/2015
#version         : 1.0
#usage			 : ./aprslog.sh <logfile>
#notes           :

# Text color variables
txtred='\e[0;31m' # red
txtgrn='\e[0;32m' # green
txtylw='\e[0;33m' # yellow
txtblu='\e[0;34m' # blue
txtpur='\e[0;35m' # purple
txtcyn='\e[0;36m' # cyan
txtwht='\e[0;37m' # white
bldred='\e[1;31m' # red - Bold
bldgrn='\e[1;32m' # green
bldylw='\e[1;33m' # yellow
bldblu='\e[1;34m' # blue
bldpur='\e[1;35m' # purple
bldcyn='\e[1;36m' # cyan
bldwht='\e[1;37m' # white
txtund=$(tput sgr 0 1) # Underline
txtbld=$(tput bold) # Bold
txtrst='\e[0m' # Text reset 

# Feedback indicators
#info=${bldwht}*${txtrst}
#pass=${bldblu}*${txtrst}
#warn=${bldred}!${txtrst}
 
# Indicator usage
#echo -e "${info} "
#echo -e "${pass} "
#echo -e "${warn} "

if [ $1 == "--help" ]; then
	clear
	echo -e "${bldylw}BASH APRS Logger${txtrst}"
	echo
	echo -e "${bldgrn}Usage:${txtrst}"
	echo
	echo "./aprslog.sh <logfile>"
	echo
	echo "To use while logging use this:"
	echo " tail -f <logfile> | ./aprslog.sh "
	echo
	exit 0
fi


IFS=$'\n'  
#for line in $(cat $1) 
#for line in $(tail -f $1) 
while :
do 
 read line
 [[ $line == "" ]] && tmp="${tmp:0:$((${#tmp}-1))}"
 tmp="$tmp"$line$'\n'
echo "===================================================================="
echo -e "${txtrst}Packet: ${txtylw}$line"
echo "--------------------------------------------------------------------"
callf=$(echo ${line} | grep -E -oh "[sSjJ][vVyY][0-9][a-zA-Z]{1,3}-?([0-9]|[a-z]|[A-Z])?" | head -1) 
if [ "$callf" != "" ]; then
	tmp=$(echo ${line} | sed 's/"${callf}"/ /g')
	echo -e "${txtrst}Callsign: ${bldcyn}$callf"
fi
#tmp=$(echo $line | sed "s/$callf//g")
mail=$(echo $line | grep -E -oh "\w+@[a-zA-Z_]+?\.[a-zA-Z]{1,3}")
if [ "$mail" != "" ]; then
	tmp=$(echo ${tmp} | sed 's/"${mail}"/ /g')
	echo -e "${txtrst}Email: ${bldred}$mail"
fi

timer=$(echo $line | grep -E -oh "(\@|\*)?[0-3][0-9][0-2][0-9][0-5][0-9]z")
if [ "$timer" != "" ]; then
	tmp=$(echo ${tmp} | sed 's/"${timer}"/ /g')
	echo -e "${txtrst}Date: ${bldwht}${timer:1:2}"
	echo -e "${txtrst}Time: ${bldred}${timer:3:2}:${timer:5:3} Zulu Time"
fi
timer=$(echo $line | grep -E -oh "(\@|\*)?[0-3][0-9][0-2][0-9][0-5][0-9]\/")
if [ "$timer" != "" ]; then
	tmp=$(echo ${tmp} | sed 's/"${timer}"/ /g')
	echo -e "${txtrst}Date: ${bldwht}${timer:1:2}"
	echo -e "${txtrst}Time: ${bldred}${timer:3:2}:${timer:5:3} Local Time"
fi
timer=$(echo $line | grep -E -oh "(\@|\*)?[0-2][0-9][0-5][0-9][0-5][0-9]h")
if [ "$timer" != "" ]; then
	tmp=$(echo ${tmp} | sed 's/"${timer}"/ /g')
	#echo -e "${txtrst}Date: ${bldwht}${timer:1:2}"
	echo -e "${txtrst}Time: ${bldred}${timer:1:2}:${timer:3:2}:${timer:5:2} Local Time"
fi

freq=$(echo $line | grep -E -oh "[0-9]{1,9}\.[0-9]{2,5}[MmHhZz]{2,3}")
if [ -n "$freq" ]; then
	tmp=$(echo $tmp | sed 's/"$freq"/ /g')
	echo -e "${txtrst}Freq: ${bldgrn}$freq"
fi
#tmp=$(echo $tmp | sed "s/$freq/ /g")
phone=$(echo $line | grep -E -oh "[26][0-9]{9}|[26][0-9]{2,4}[-| ][0-9]{5,7}")
if [ -n "$phone" ]; then
	tmp=$(echo $tmp | sed 's/"$phone"/ /g')
	echo -e "${txtrst}Phone: ${bldylw}$phone"
fi
#tmp=$(echo $tmp | sed "s/$phone//g")
coord=$(echo $line | grep -E -oh "[0-9]{4,5}\.[0-9]{2}[NnEewWsS][NnEewWsS]?")
if [ -n "$coord" ]; then
	tmp=$(echo $tmp | sed 's/"$coord"/ /g')
	wlat=$(echo "scale=6;${coord:0:2} + ${coord:2:2} / 60 + ${coord:5:2} / 3600" | bc -l)
	long=$(echo -e "$coord" | sed -n '2p')
	wlong=$(echo "scale=6;${long:1:2} + ${long:3:2} / 60 + ${long:6:2} / 3600" | bc -l)
	echo -e "${txtrst}Coords:"
	echo -e "${bldblu}	$wlat"
	echo -e "${bldblu}	$wlong"

echo "	$(wget -O- -q "http://maps.google.com/maps/api/geocode/xml?latlng=$wlat,$wlong&sensor=false"|\
grep formatted|\
head -n1|\
cut -d\> -f2|\
cut -d\< -f1)"
	
	
fi
#tmp=$(echo $tmp | sed "s/$coord//g")
http=$(echo $line | grep -E -oh "(www|mailto\:|(news|(ht|f)tp(s?))\://)(([^[:space:]]+)|([^[:space:]]+)( #([^#]+)#)?)")
if [ -n "$http" ]; then
	tmp=$(echo $tmp | sed 's/"$http"/ /g')
	echo -e "${txtrst}Website: ${bldwht}$http"
fi

#weather packet
#_112/001g002t052h45b10224OWW
weather=$(echo $line | grep -E -oh "_[0-3][0-9][0-9]/[0-9]{3}g[0-9]{3}t[0-9]{3}(r[0-9]{3})?(p[0-9]{3})?(P[0-9]{3})?(h[0-9]{2})?(b[0-9]{5})?(h[0-9]{2})?")
if [ -n "$weather" ]; then
	tmp=$(echo $tmp | sed 's/"$weather"/ /g')
	echo -e "${txtrst}Weather:"
	echo -e "	${txtrst}Wind Direction : ${bldwht}$(echo $weather | grep -E -oh "_[0-3][0-9][0-9]") degrees"
	speed=$(echo $weather | grep -E -oh "/[0-9]{3}")
	speed=${speed:1:3}
	speed=$(echo "$speed * 1.60934" | bc)
	echo -e "	${txtrst}Wind Speed: ${bldwht}$speed kph"
	wspeed=$(echo $weather | grep -E -oh "g[0-9]{3}")
	wspeed=${speed:1:3}
	wspeed=$(echo "$speed * 1.60934" | bc)
	echo -e "	${txtrst}Max. Wind Gust: ${bldwht}$wspeed kph"
	temp=$(echo $weather | grep -E -oh "t[0-9]{3}")
	temp=${temp:1:3}
	temp=$(echo "($temp - 32) * 0.55" | bc)
	echo -e "	${txtrst}Temp.: ${bldwht}$temp Celsius"
	echo -e "	${txtrst}Rain: ${bldwht}$(echo $weather | grep -E -oh "r[0-9]{3}") inch/100 (Last Hour)"
	echo -e "	${txtrst}Rain: ${bldwht}$(echo $weather | grep -E -oh "p[0-9]{3}") inch/100 (24 Hours)"
	echo -e "	${txtrst}Rain: ${bldwht}$(echo $weather | grep -E -oh "P[0-9]{3}") inch/100 {Since Midnight)"
	echo -e "	${txtrst}Humidity: ${bldwht}$(echo $weather | grep -E -oh "h[0-9]{2}") %"
	echo -e "	${txtrst}Barometer: ${bldwht}$(echo $weather | grep -E -oh "b[0-9]{5}") mb/10"
fi

#tmp=$(echo $tmp | sed "s/$http//g")
#echo "--------------------"
echo -e "${txtrst}"
#echo -e "${bldcyn}$callf	-=	${bldwht}$http ${bldred}$mail ${bldgrn}$freq ${bldylw}$phone ${bldblu}$coord${txtrst}"
echo "===================================================================="
echo
echo
done 
unset IFS


#grep -E  -e "[0-9]{1,9}\.[0-9]{2,5}[MmHhZz]{2,3}" -e "[26][0-9]{9}|[26][0-9]{2,4}[-| ][0-9]{5,7}" -e "[0-9]{4,5}\.[0-9]{2}[NnEe]" -e "(mailto\:|(news|(ht|f)tp(s?))\://)(([^[:space:]]+)|([^[:space:]]+)( #([^#]+)#)?)"
