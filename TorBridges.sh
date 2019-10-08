#!/usr/bin/env bash


HTML_FILE="img.html"
IMAGE_FILE="captcha.jpg"
BridgeFile="bridges.txt"
TorConfigFile="/etc/tor/torrc"
IpSite="icanhazip.com"
LinkGetTorBridge="https://bridges.torproject.org/bridges?transport=obfs4"


# requirements for run this script
if [[ ! $(which feh) || ! $(which tor) || ! $(which proxychains4) || ! $(which obfs4proxy)  ]]; then
    echo -e "\e[31mCheck that programs are installed ? => ( proxychains4 , feh ,tor , obfs4proxy )\e[m "
    exit 1
fi

# This script need to run as root
if [[ $UID -ne 0 ]]; then
    echo -e "\e[31mThis script must be run as root!\e[m "
    exit 1
fi

# usage
function usage(){
    echo -e "\e[0;1;33mA Simple Script for get tor bridge from\e[1;35m https://bridges.torproject.org/bridges\e[m"
    echo -e "\e[35mUSAGE :"
    echo -e "\e[0;32m\t-a | --add-bridges\t\e[0;36madd bridges to /etc/tor/torrc"
    echo -e "\e[0;32m\t-t | --test-bridges\t\e[0;36mtest bridges and comment broken bridges"
    echo -e "\e[0;32m\t-r | --reset-tor\t\e[0;36mrestart tor service"
    echo -e "\e[0;32m\t-h | --help\t\t\e[0;36mshow this help"
    echo -e "\e[m"
}

# delete files
function ClearFiles() {
    for file in $@; do
        if [[ -e "$file" ]]; then
            rm $file
        fi
    done
}

# get tor bridges
function get_tor_bridges(){

    # add bridges into file $TorConfigFile (default=True)
    AddBridges="$1"

    # remove broken bridges (default=True)
    RemoveBrokenBridges="$2"

    # restart Tor Service (default=True)
    ReTor="$3"


    # delete tmp files
    ClearFiles "${HTML_FILE}" "${IMAGE_FILE}" "${BridgeFile}"

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
        echo -ne "\e[1;35m[ $(proxychains4 -q curl -s "$IpSite") ] \e[1;34m"


        # get code from user
        read -p "Enter code (Enter 'r' For Reset Captcha): " Cap_Response

        # reset captcha
        [[ $Cap_Response == "r" ]] &&
        {
            # kill feh job
            kill $FEH_PID

            # delete tmp files
            ClearFiles "${HTML_FILE}" "${IMAGE_FILE}" "${BridgeFile}"

            # clear data in Cap_Response for while condition true
            Cap_Response=""

            # reset captcha
            get_tor_bridges "$AddBridges" "$RemoveBrokenBridges" "$ReTor"

            exit 0
        }

        # slove captcha and get Bridges
        proxychains4 -q curl -s "https://bridges.torproject.org/bridges?transport=obfs4" \
                            --data "captcha_challenge_field=${Cap_Challenge}&captcha_response_field=${Cap_Response}&submit=submit" -o "$BridgeFile"

        # cut bridges from html file(if code is incorrect bridges file is empty)
        RES=$(cat "$BridgeFile" |grep obfs4 |egrep -o "^[^<]*")

        # if Cap_Response is correct. bridges save into $TorConfigFile . incorrect show error
        if [[ ! -z $(echo $RES|tr -d '\n') ]]; then
            BRIDGES=$(echo "$RES" |sed 's/^/Bridge /g')
        else
            echo -e "\e[1;33mThe code entered is incorrect! try again ..\e[m"
            # continue . True while
            Cap_Response=""
        fi
    done

    # kill feh job
    kill $FEH_PID

    # delete tmp files
    ClearFiles "${HTML_FILE}" "${IMAGE_FILE}" "${BridgeFile}"

    # add Bridges Into torrc
    if [ -e "$TorConfigFile" ]; then

        # add 'UseBridges 1' in to $TorConfigFile if not exist
        if [[ ! $(grep "UseBridges 1" $TorConfigFile) ]]; then
            echo "UseBridges 1" >> $TorConfigFile
        fi

        # add 'ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy' into $TorConfigFile if not exist
        if [[ ! $(grep "ClientTransportPlugin obfs4 exec" $TorConfigFile) ]]; then
            obfs4proxy=$(which obfs4proxy)
            echo "ClientTransportPlugin obfs4 exec ${obfs4proxy}" >> $TorConfigFile
        fi

        if [[ "$AddBridges" == "True" ]]; then
            sudo echo -e "\n${BRIDGES}" >> $TorConfigFile
            echo -e "\e[35mBridges Added into \e[35m$TorConfigFile\n"
        fi

        # show bridges
        echo -e "\e[36m${BRIDGES}"

        if [[ "$RemoveBrokenBridges" == "True" ]]; then
            remove-broken-bridges
        fi

        if [[ "$ReTor" == "True" ]]; then
            remove-broken-bridges -r
        fi

    else
        echo -e "\e[31m $TorConfigFile doesn't exist"
        exit 0
    fi
}

# # reset terminal
# tput reset


AddBridges="False"
RemoveBrokenBridges="False"
ReTor="False"

while [ "$1" != "" ]; do
    case $1 in
        -a | --add-bridges  ) AddBridges="True" ;;

        -t | --test-bridges ) RemoveBrokenBridges="True" ;;

        -r | --reset-tor    ) ReTor="True";;

        -h | --help | *) usage && exit 0;;
    esac
    shift
done

# get tor bridges
get_tor_bridges "$AddBridges" "$RemoveBrokenBridges" "$ReTor"
