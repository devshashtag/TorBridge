#!/bin/bash
# --------------------------------------- #
# - - - - - - - - - - - - - - - - - - - - #
# - - - - - - -  TorBridge  - - - - - - - #
# - - - - - - - Micro Robot - - - - - - - #
# - - - - - - - - - - - - - - - - - - - - #
# --------------------------------------- #
# a simple tool for get tor bridge from   #
# https://bridges.torproject.org/bridges  #
# ----------------------------------------#

HTML_FILE="img.html"
IMAGE_FILE="captcha.jpg"

# get Captcha 
proxychains -q curl -s "https://bridges.torproject.org/bridges?transport=obfs4" -o $HTML_FILE

proxychains -q curl ipecho.net/plain
# cut base64 Image challenge and convert to image
base64 -i -d <<< $(cat $HTML_FILE |egrep -o "\/9j\/[^\"]*") > $IMAGE_FILE

#Captcha challenge field  
Cap_Challenge=$(cat img.html |grep value|head -n 1|cut -d\" -f 2)

#Enter code captcha
while [[ -z $Cap_Response ]]; do 
	read -p "Enter code : " Cap_Response
done
# get captcha
proxychains -q curl -s "https://bridges.torproject.org/bridges?transport=obfs4" \
					-H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/30200101 Firefox/68.0" \
					-H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
					-H "Accept-Language: en-US,en;q=0.5" --compressed \
					-H "Content-Type: application/x-www-form-urlencoded" \
					-H "Connection: keep-alive" \
					-H "Upgrade-Insecure-Requests: 1" \
					-H "Pragma: no-cache" \
					-H "Cache-Control: no-cache" \
					--data "captcha_challenge_field=${Cap_Challenge}&captcha_response_field=${Cap_Response}&submit=submit" -o bridges

cat bridges |grep obfs4 |cut -d ' ' -f 1,2,3,4,5|egrep -o "^[^<]*"|sed 's/^/Bridge /g'










