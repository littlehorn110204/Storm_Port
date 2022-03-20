#!/bin/bash

GREEN='\033[0;32M'
NC='\033[0m'

clear

#bAMMER
printf "${GREEN}																										\n"
printf "   █████████  ███████████    ███████    ███████████   ██████   ██████											\n"
printf "  ███░░░░░███░█░░░███░░░█  ███░░░░░███ ░░███░░░░░███ ░░██████ ██████ 											\n"
printf " ░███    ░░░ ░   ░███  ░  ███     ░░███ ░███    ░███  ░███░█████░███ 											\n"
printf " ░░█████████     ░███    ░███      ░███ ░██████████   ░███░░███ ░███ 											\n"
printf "  ░░░░░░░░███    ░███    ░███      ░███ ░███░░░░░███  ░███ ░░░  ░███ 											\n"
printf "  ███    ░███    ░███    ░░███     ███  ░███    ░███  ░███      ░███ 											\n"
printf " ░░█████████     █████    ░░░███████░   █████   █████ █████     █████											\n"
printf "  ░░░░░░░░░     ░░░░░       ░░░░░░░    ░░░░░   ░░░░░ ░░░░░     ░░░░░ 											\n"
                                                                    
                                                                    
                                                                    
printf "          ███████████     ███████    ███████████   ███████████ 													\n"													     
printf "         ░░███░░░░░███  ███░░░░░███ ░░███░░░░░███ ░█░░░███░░░█ 													\n"     
printf "          ░███    ░███ ███     ░░███ ░███    ░███ ░   ░███  ░  													\n"     
printf "          ░██████████ ░███      ░███ ░██████████      ░███     													\n"     
printf "          ░███░░░░░░  ░███      ░███ ░███░░░░░███     ░███     													\n"     
printf "          ░███        ░░███     ███  ░███    ░███     ░███     													\n"     
printf "          █████        ░░░███████░   █████   █████    █████    													\n"     
printf "         ░░░░░           ░░░░░░░    ░░░░░   ░░░░░    ░░░░░     													\n"  

printf "           By littlehorn110204  |  Inspired by  macosta-42                                                                         ${NC}\n"
#cHECK ARGUMENT NUMBER
if [ "$#" -ne 1 ]; then
	printf "{$GREEN}\n[!] Usage: $0 [RHOST] [!]${NC}\n"
	exit 1
fi

#cHECK RHOST LENGTH
if [ $#1 -ge 16 ];
then
	printf "${GREEN}\n[!] Invalid RHOST [!]${NC}\n"
	exit 1
else
	target=$1
fi

#cHECK FOR ROOT
uid=$(id -u)
if [ x$uid != x0 ]
then
	printf -v cmd_str '%q ' "$0" "$@"
	exec sudo su -c "$cmd_str"
fi

#cHECK FOR DEPENDENCIES
if ! command -v nmap &> /dev/null
then
	printf "${GREEN}\n[*] Installing nmap... [*]${NC}\n"
	sudo apt-get istall nmap -y
fi

if ! command -v xsltproc &> /dev/null
then
	printf "${GREEN}\n[*] Installing xsltproc...[*]\n${NC}"
	sudo apt-get install xsltproc -y
fi

#cREATE DIRECTORIES
printf "${GREEN}\n[}+{] Creating Directory [}+{]\n${NC}"
mkdir -p ${target}/nmap

#sTARTING HTTP SERVER
user_authority=$(echo $XAUTHORITY | rev | cut -d '/' -f 2 | rev)
printf "${GREEN}\n[}+{] Launching HTTP server [}+{]\n${NC}"
sudo -H -u $user_authority gnome-terminal -e "python3 -m http.server 9999" & 
sleep 5

#sTARTING FIREFOX
printf "${GREEN}\n[}+{] Launching Firefox [}+{]\n${NC}"
sudo -H -u $user_authority gnome-terminal --tab -e "firefox -private localhost:9999" &

#iNITIAL BASIC VERY FAST SCAN
printf "${GREEN}\n[}+{] Basic Scan [}+{]\n${NC}"
sudo nmap --min-rate 500 -T4 -F -oX ${target}/nmap/00_initial.xml ${target} --open -v
xsltproc ${target}/nmap/00_initial.xml -o ${target}/nmap/00_initial.html
sudo rm -rf ${target}/nmap/00_initial.xml

#fULL PORT SCAN WITH SERVICE DISCOVERY
printf "${GREEN}\n[}+{] Fullport Scan [}+{]\n${NC}"
sudo nmap --min-rate 500 -T4 -sC -sV -O -p- -oX ${target}/nmap/01_fullscan.xml ${target}
xsltproc ${target}/nmap/01_fullscan.xml -o ${target}/nmap/01_fullscan.html

#eXTRACT OPEN PORTS
cat ${target}/nmap/01_fullscan.xml | grep syn-ack | cut -d '"' -f 4 > tmp.txt
paste -s -d, tmp.txt > ${target}/nmap/ports.txt
sudo rm -rf tmp.txt 
ports=$(cat ${target}/nmap/ports.txt)
sudo rm -rf ${target}/nmap/ports.txt

#SEARCHSPLOIT
printf "${GREEN}\n[}+{] Searchsploit Services [}+{]\n${NC}"
grep 'product' ${target}/nmap/01_fullscan.xml | cut -d '"' -f 14 | awk '{print$1}' > ${target}/nmap/product.txt
grep 'product' ${target}/nmap/01_fullscan.xml | cut -d '"' -f 16 | awk '{print$1}' > ${target}/nmap/version.txt
paste ${target}/nmap/product.txt ${target}/nmap/version.txt > ${target}/nmap/service.txt
sudo rm -rf ${target}/nmap/product.txt ${target}/nmap/version.txt
while read service; do
		printf "${GREEN}\nSearchsploit ${service}: \n${NC}"
		searchsploit ${service}
done < ${target}/nmap/service.txt
sudo rm -rf ${target}/nmap/01_fullscan.xml

#sEARCH NMAP SCRIPT
printf "${GREEN}\n[}+{] Search Services In nmap Script [}+{]\n${NC}"
while read service; do 
		printf "${GREEN}\nnse ${service}: \n${NC}"
		runuser -u ${user_authority} -- locate *.nse | grep -i "(echo ${service} | awk '{print $1}')"
		runuser -u ${user_authority} -- locate *.nse | grep -i "${service}"
done < ${target}/nmap/service.txt
sudo rm -rf ${target}/nmap/service.txt

#vULN SCAN ON OPEN PORTS
printf "${GREEN}\n[}+{] Vulnerability Scan [}+{]\n${NC}"
sudo nmap -Pn --script vuln -sV -p ${ports} -oX ${target}/nmap/02_vuln.xml ${target}
rm -rf ${target}/nmap/ports.txt
xsltproc ${target}/nmap/02_vuln.xml -o ${target}/nmap/02_vuln.html
rm -rf ${target}/nmap/02_vuln.xml

#uDP SCAN
printf "${GREEN}\n[}+{] UDP Scan [}+{]\n${NC}"
sudo nmap --min-rate 500 -sU -O -p- -oX ${target}/nmap/03_udp.xml ${target}
xsltproc ${target}/nmap/03_udp.xml -o ${target}/nmap/03_udp.html
sudo rm -rf ${target}/nmap/03_udp.xml