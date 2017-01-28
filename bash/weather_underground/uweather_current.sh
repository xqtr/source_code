#!/bin/bash

#Don't Change!!!
dir="$(dirname "$(readlink -f "$0")")"

#Use your own Key and location
apikey=""
state=""
city=""
lang="EN"

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

#Example for using Colors
#echo -e "${bldylw}   Choose Server to connect...${txtrst}"

#Usefull ANSI Codes
#CSI n A  CUU – Cursor Up
#CSI n B  CUD – Cursor Down
#CSI n C  CUF – Cursor Forward
#CSI n D  CUB – Cursor Back
#CSI n ; m H  CUP – Cursor Position   Moves the cursor to row n column m 

data=$(curl -Ls -X GET http://api.wunderground.com/api/$apikey/conditions/q/$state/$city.json | sed 's/\/weather\///g')

#Function to get json Values
function jsonval {
    temp=`echo $data | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]//g' | sed 's/\"//g' | grep "$1" -m 1 -w`
    echo ${temp##*|}
}

#Get weather data we need to display
loc_string=$(jsonval "full" $data)
current=$(jsonval "weather" $data)
temp=$(jsonval "temperature_string" $data)
wind=$(jsonval "wind_string" $data)
feels=$(jsonval "feelslike_string" $data)
icon=$(jsonval "icon_url" $data)
humidity=$(jsonval "relative_humidity" $data)
pressure=$(jsonval "pressure_mb" $data)
dew=$(jsonval "dewpoint_string" $data)

#Get the name for the icon to use
fullname="${icon##*/}"
extension="${fullname##*.}"
filename="${fullname%.*}"

#Display weather icon
cat $dir/icons.ans | grep "$filename" -m 1 -A 8 | tail -n +3

#Display other data, by using ANSI codes to move cursor
echo -e "\e[7A\e[21G $bldwht Location  : $bldylw$loc_string $txtrst"
echo -e "\e[21G $bldwht Condition : $bldylw$current"
echo -e "\e[21G $bldwht Temp.     : $bldylw$temp"
echo -e "\e[21G $bldwht Feels     : $bldylw$feels"
echo -e "\e[21G $bldwht Wind      : $bldylw$wind"
echo -e "\e[21G $bldwht Humidity  : $bldylw$humidity"
echo -e "\e[21G $bldwht Pressure  : $bldylw$pressure mb"
echo -e "\e[21G $bldwht Dewpoint  : $bldylw$dew"

echo -e "\e[4B"


