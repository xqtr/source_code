#!/bin/bash
       
#title           : APRS packet reader
#description     : 
#author			 : xqtr
#date            : 10/02/2015
#version         : 1.0
#usage			 : ./aprs.sh
#notes           :

# filter r/38.36/23.10/100 

#Variables ${2:-1}
server=$1
port=${2:-14580}
lat=${3:-38.36}
lon=${4:-23.10}
range=${5:-100}
user=${6:-"TSTUSR"}
pass=${7:-"-1"}

 
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
 
function choose_server () {
	clear
	echo -e "${bldylw}		Choose Server to connect...${txtrst}"
	echo
	echo -e "${bldgrn}For more servers check: http://aprs2.net/APRServe2.txt${txtrst}"
	echo
	echo -e "${bldred}_,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,_${txtrst}"
	echo
	echo -e "${bldwht}1. ${txtwht} sv2hrt.dyndns.org:14578	- Greece${txtrst}"
	echo -e "${bldwht}2. ${txtwht} sv2hrt.dyndns.org:2323	-	>>	Weather${txtrst}"
	echo -e "${bldwht}3. ${txtwht} sv2hrt.dyndns.org:1314	-	>>	Messages${txtrst}"
	echo -e "${bldwht}4. ${txtwht} greece.aprs2.net:14580	- Greece${txtrst}"
	echo -e "${bldwht}5. ${txtwht} euro.aprs2.net:14580 ${txtrst}"
	echo -e "${bldwht}6. ${txtwht} rotate.aprs.net :14580${txtrst}"
	echo -e "${bldwht}7. ${txtwht} first.aprs.net:10152${txtrst}"
	echo -e "${bldwht}8. ${txtwht} second.aprs.net:10152${txtrst}"
	echo -e "${bldwht}9. ${txtwht} third.aprs.net:10152${txtrst}"
	echo
	echo -e "${bldred}_,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,__,.-'~'-.,_${txtrst}"
	echo
	echo -e "${bldwht}Enter your selection (ex. 9): ${txtrst}"
	echo
	read nos
	
case $nos in
	1)	server="sv2hrt.dyndns.org"
		port="14578"
		;;
	2)	server="sv2hrt.dyndns.org"
		port="2323"
		;;
	3)	server="sv2hrt.dyndns.org"
		port="1314"
		;;
	4)	server="greece.aprs2.net"
		port="14580"
		;;
	5)	server="euro.aprs2.net"
		port="14580"
		;;
	6)	server="rotate.aprs.net"
		port="14580"
		;;
	7)	server="first.aprs.net"
		port="10152"
		;;
	8)	server="second.aprs.net"
		port="10152"
		;;
	9)	server="third.aprs.net"
		port="10152"
		;;
    *)	echo "Invalid selection. Try again."
		exit;;
esac
	
}

function create_script () {
	echo "#!/usr/bin/expect" > ./aprsconnect.sh
	echo "spawn nc $server $port" >> ./aprsconnect.sh
	echo "expect {" >> ./aprsconnect.sh
	echo "		-re \".*APRS.*\" { send \"user $user pass $pass vers testsoftware 1.0_05 filter r/$lat/$lon/$range\r\" }" >> ./aprsconnect.sh
	echo "		-re \".*aprs.*\" { send \"user $user pass $pass vers testsoftware 1.0_05 filter r/$lat/$lon/$range\r\" }" >> ./aprsconnect.sh
	echo "}" >> ./aprsconnect.sh
	echo "interact" >> ./aprsconnect.sh
	chmod +x ./aprsconnect.sh
}

# Display usage if no parameters given
if [[ -z "$@" ]]; then
	choose_server
fi
if [ $1 == "--help" ]; then
	clear
	echo -e "${bldylw}BASH APRS Reader${txtrst}"
	echo
	echo -e "${bldgrn}Usage:${txtrst}"
	echo
	echo -e "${bldwht}./aprs.sh --help : ${txtwht}Shows this screen${txtrst}"
	echo -e "${bldwht}./aprs.sh <server> <port> : ${txtwht}Connects to giver server, with default params${txtrst}"
	echo -e "${bldwht}./aprs.sh <server> <port> <lat> <lon> <range> <user> <pass>: ${txtwht}Connects to server, with given filter/params${txtrst}"
	echo
	echo "To redirect both to stdout and to a file give this:"
	echo "./aprs.sh <server> <port> <lon> <lat> <user> <pass> | tee <logfile> 2>&1"
	echo
	exit 0
fi

create_script
./aprsconnect.sh
rm -f ./aprsconnect.sh
exit 0
