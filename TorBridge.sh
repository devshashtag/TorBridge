#!/usr/bin/env bash

HTML_FILE="img.html"
IMAGE_FILE="captcha.jpg"
BridgeFile="bridges"


# requirements for run this script
if [[ ! $(which feh) || ! $(which tor) || ! $(which proxychains4) || ! $(which obfs4proxy)  ]]; then
    echo -e "\e[31mCheck that programs are installed ? => ( proxychains4 , feh ,tor , obfs4proxy )\e[m "
    exit 1
fi

if [[ $UID -ne 0 ]]; then
    echo -e "\e[31mThis script must be run as root\e[m "
    exit 1
fi

# delete tmp files
function ClearFiles() {
    for file in $@; do
        if [ -e $file ]; then
            rm $file
        fi
    done
}
# delete tmp files
ClearFiles "${HTML_FILE}" "${IMAGE_FILE}" "${BridgeFile}"

# reset terminal
tput reset

# get Captcha
proxychains4 -q curl -s "https://bridges.torproject.org/bridges?transport=obfs4" -o $HTML_FILE

# net test
[[ -z $(cat $HTML_FILE) ]] && echo "Error TOR" && exit 0

# cut base64 Image challenge and convert to image
base64 -i -d <<< $(cat $HTML_FILE |egrep -o "\/9j\/[^\"]*") > $IMAGE_FILE

# view image
feh $IMAGE_FILE &
FEH_PID=$!

# Captcha challenge field
Cap_Challenge=$(cat img.html |grep value|head -n 1|cut -d\" -f 2)

# show ip
echo -ne "\e[35m"
proxychains4 -q curl ipecho.net/plain
echo -ne "\e[1;34m"
# Enter code captcha
while [[ -z $Cap_Response ]]; do
    read -p " => Enter code (Enter 'r' For Reset Captcha): " Cap_Response

    # kill feh job
    kill $FEH_PID

    [[ $Cap_Response == "r" ]] && {
                                    ClearFiles "${HTML_FILE}" "${IMAGE_FILE}" "${BridgeFile}"
                                    $0
                                    exit 0
                                  }
done

# end captcha
proxychains4 -q curl -s "https://bridges.torproject.org/bridges?transport=obfs4" \
                     --data "captcha_challenge_field=${Cap_Challenge}&captcha_response_field=${Cap_Response}&submit=submit" -o "$BridgeFile"

# cut bridges from html file
RES=$(cat "$BridgeFile" |grep obfs4 |egrep -o "^[^<]*")

# delete tmp files
ClearFiles "${HTML_FILE}" "${IMAGE_FILE}" "${BridgeFile}"

# if Cap_Response is correct bridges save into /etc/tor/torrc . incorrect show error
[[ ! -z $(echo $RES|tr -d '\n') ]] &&
    BRIDGES=$(echo "$RES" |sed 's/^/Bridge /g') ||
    {
        echo -e "\e[33mThe code entered is incorrect\e[m"
        exit 0
    }

#add Bridges Into torrc
if [ -e "/etc/tor/torrc" ]; then
    if [[ ! $(grep "UseBridges 1" /etc/tor/torrc) ]]; then
        echo "UseBridges 1" >> /etc/tor/torrc
    fi

    if [[ ! $(grep "ClientTransportPlugin obfs4 exec" /etc/tor/torrc) ]]; then
        obfs4proxy=$(which obfs4proxy)
        echo "ClientTransportPlugin obfs4 exec ${obfs4proxy}" >> /etc/tor/torrc
    fi
    sudo echo -e "\n${BRIDGES}" >> /etc/tor/torrc
    echo -e "\e[35mBridges Added into \e[35m/etc/tor/torrc : \n\e[36m${BRIDGES}\n "
else
    echo -e "\e[31m /etc/tor/torrc doesn't exist"
    exit 0
fi




