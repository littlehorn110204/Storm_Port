# Storm_Port
##Storm_Port

For educational purposes only.
Description:

A basic nmap scan script

This is an educational script created to show port vulnerability/security  

    With this tool you can run 4 different kinds of scans

#Very fast basic scan:

sudo nmap --min-rate 500 -T4 -F -oX nmap/initial [IP] --open -v

#Fullport scan:

sudo nmap --min-rate 500 -T4 -sC -sV -O -p- -oX nmap/fullscan [IP]

#Vulnerability scan:

sudo nmap -Pn --script vuln -sV -p [PORTS] -oX nmap/vuln [IP]

#UDP scan:

sudo nmap --min-rate 500 -sU -O -T4 -p- -oX nmap/udp [IP]

    Convert xml scan report into html

    Run a Python3 HTTP server on port 9999

    Launch Firefox on localhost:9999




#Usage:

./Storm_Port.sh [RHOST]
From littlehorn110204 Studios; UrdydrU Dynamics-
