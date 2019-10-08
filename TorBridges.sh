#!/usr/bin/env bash


HTML_FILE="img.html"
IMAGE_FILE="captcha.jpg"
BridgeFile="bridges.txt"

LinkGetTorBridge="https://bridges.torproject.org/bridges?transport=obfs4"

# requirements for run this script
if [[ ! $(which feh) || ! $(which tor) || ! $(which proxychains4) || ! $(which obfs4proxy)  ]]; then
    echo -e "\e[31mCheck that programs are installed ? => ( proxychains4 , feh ,tor , obfs4proxy )\e[m "
    exit 1
fi

if [[ $UID -ne 0 ]]; then
    echo -e "\e[31mThis script must be run as root!\e[m "
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

# get tor bridges
function get_tor_bridges(){
    # get Captcha
    proxychains4 -q curl -s "$LinkGetTorBridge" -o $HTML_FILE

    # net test
    [[ -z $(cat $HTML_FILE 2>/dev/null) ]] && echo "Error TOR" && exit 0

    # cut base64 Image challenge and convert to image
    base64 -i -d <<< $(cat $HTML_FILE |egrep -o "\/9j\/[^\"]*") > $IMAGE_FILE

    # view image
    feh $IMAGE_FILE &
    FEH_PID=$!

    # Captcha challenge field ( code of captcha )
    Cap_Challenge=$(cat img.html |grep value|head -n 1|cut -d\" -f 2)



    # Enter code captcha
    while [[ -z $Cap_Response ]]; do
        # show ip
        echo -ne "\e[35m[ "
        proxychains4 -q curl ipecho.net/plain

        # get code from user
        echo -ne " ]\e[1;34m Enter code (Enter 'r' For Reset Captcha): "
        read Cap_Response

        # reset captcha
        [[ $Cap_Response == "r" ]] && {
                                        # kill feh job
                                        kill $FEH_PID

                                        # delete tmp files
                                        ClearFiles "${HTML_FILE}" "${IMAGE_FILE}" "${BridgeFile}"

                                        # emtpy capcha for while
                                        Cap_Response=""

                                        # reset captcha
                                        get_tor_bridges

                                        exit 0
                                    }

        # slove captcha and get Bridges
        proxychains4 -q curl -s "https://bridges.torproject.org/bridges?transport=obfs4" \
                            --data "captcha_challenge_field=${Cap_Challenge}&captcha_response_field=${Cap_Response}&submit=submit" -o "$BridgeFile"

        # cut bridges from html file(if code is incorrect bridges file is empty)
        RES=$(cat "$BridgeFile" |grep obfs4 |egrep -o "^[^<]*")

        # if Cap_Response is correct. bridges save into /etc/tor/torrc . incorrect show error
        if [[ ! -z $(echo $RES|tr -d '\n') ]]; then
            BRIDGES=$(echo "$RES" |sed 's/^/Bridge /g')
        else
            echo -e "\e[1;33mThe code entered is incorrect! try again ..\e[m"
            Cap_Response=""
            continue
        fi

    done

    # kill feh job
    kill $FEH_PID

    # delete tmp files
    ClearFiles "${HTML_FILE}" "${IMAGE_FILE}" "${BridgeFile}"

    # add Bridges Into torrc
    if [ -e "/etc/tor/torrc" ]; then

        # add 'UseBridges 1' in to /etc/tor/torrc if not exist
        if [[ ! $(grep "UseBridges 1" /etc/tor/torrc) ]]; then
            echo "UseBridges 1" >> /etc/tor/torrc
        fi

        # add 'ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy' in to /etc/tor/torrc if not exist
        if [[ ! $(grep "ClientTransportPlugin obfs4 exec" /etc/tor/torrc) ]]; then
            obfs4proxy=$(which obfs4proxy)
            echo "ClientTransportPlugin obfs4 exec ${obfs4proxy}" >> /etc/tor/torrc
        fi

        sudo echo -e "\n${BRIDGES}" >> /etc/tor/torrc
        echo -e "\e[35mBridges Added into \e[35m/etc/tor/torrc\n"

        echo -e "\e[36m${BRIDGES}"

        echo -e "\e[1;33mwaiting for remove broken bridges .."
        remove-broken-bridges
    else
        echo -e "\e[31m /etc/tor/torrc doesn't exist"
        exit 0
    fi
}



get_tor_bridges
