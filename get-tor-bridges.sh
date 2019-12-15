#!/usr/bin/env bash


HTML_FILE="img.html"
IMAGE_FILE="captcha.jpg"
BridgeFile="bridges.txt"
IpSite="icanhazip.com"

# Add config file 
source tbcli-config 2>/dev/null
if [[ $? -ne 0 ]] ; then 
    echo -e "\e[31mfile config Not exist" 
    exit 1 
fi 

# requirements for run this script
if [[ ! $(which feh) || ! $(which tor) || ! $(which proxychains4) || ! $(which obfs4proxy)  ]]; then
    echo -e "${light_red}Check that programs are installed ? => ( proxychains4 , feh ,tor , obfs4proxy )\e[m "
    exit 1
fi

# usage
function usage(){
    echo -e "${light_yellow}A Simple Script for get tor bridge from${light_magenta} https://bridges.torproject.org/bridges\e[m"
    echo -e "${light_magenta}USAGE :"
    echo -e "${light_green}\t-a | --add-bridges\t\t${cyan}add bridges to $tor_config_file"
    echo -e "${light_green}\t-d | --disable-broken-bridge\t${cyan}Disable broken Bridges in this network connection"
    echo -e "${light_green}\t-e | --enable-all-bridge\t${cyan}Enable all disabled Bridges"
    echo -e "${light_green}\t-r | --reset-tor\t\t${cyan}restart tor service"
    echo -e "${light_green}\t-u | --uninstall\t\t${cyan}uninstall Script"
    echo -e "${light_green}\t-h | --help\t\t\t${cyan}show this help"
    echo -e "${nc}"
}

# delete files
function ClearFiles() {
    for file in "${HTML_FILE}" "${IMAGE_FILE}" "${BridgeFile}"; do
        if [[ -e "$file" ]]; then
            rm $file
        fi
    done
}

# get tor bridges
function get_tor_bridges(){

    # add bridges into file $tor_config_file (default=False)
    add_bridges="$1"

    # args for manager bridges 
    args_bridges_manager="$2"

    # delete tmp files
    ClearFiles 

    # get Captcha
    proxychains4 -q curl -s "$url_bridges" -o "$HTML_FILE"

    # net test
    [[ -z $(cat "$HTML_FILE" 2>/dev/null) ]] && echo "Error TOR" && exit 0

    # cut base64 Image challenge and convert to image
    base64 -i -d <<< $(cat "$HTML_FILE" |egrep -o "\/9j\/[^\"]*") > $IMAGE_FILE

    # view image
    feh "$IMAGE_FILE" &
    FEH_PID=$!

    # Captcha challenge field ( code of captcha )
    Cap_Challenge=$(cat "$HTML_FILE" |grep value |head -n 1 |cut -d\" -f 2)

    # Enter code captcha
    while [[ -z $Cap_Response ]]; do
        # show ip
        echo -ne "${light_magenta}[ $(proxychains4 -q curl -s "$IpSite") ] ${light_blue}"


        # get code from user
        read -p "Enter code (Enter 'r' For Reset Captcha): " Cap_Response

        # reset captcha
        [[ $Cap_Response == "r" ]] &&
        {
            # kill feh job
            kill $FEH_PID

            # clear data in Cap_Response for while condition true
            Cap_Response=""

            # reset captcha
            get_tor_bridges "$AddBridges" "$RemoveBrokenBridges" "$ReTor"

            exit 0
        }

        # slove captcha and get Bridges
        proxychains4 -q curl -s "$url_bridges" \
        --data "captcha_challenge_field=${Cap_Challenge}&captcha_response_field=${Cap_Response}&submit=submit" -o "$BridgeFile"

        # cut bridges from html file(if code is incorrect bridges file is empty)
        RES=$(cat "$BridgeFile" |grep obfs4 |egrep -o "^[^<]*")

        # if Cap_Response is correct. bridges save into $tor_config_file . incorrect show error
        if [[ ! -z $(echo $RES|tr -d '\n') ]]; then
            BRIDGES=$(echo "$RES" |sed 's/^/Bridge /g')
        else
            echo -e "${light_yellow}The code entered is incorrect! try again ..\e[m"
            # continue . True while
            Cap_Response=""
        fi
    done

    # kill feh job
    kill $FEH_PID

    # add Bridges Into torrc
    if [ -e "$tor_config_file" ]; then

        # add 'UseBridges 1' in to $tor_config_file if not exist
        if [[ ! $(grep "UseBridges 1" $tor_config_file) ]]; then
            echo "UseBridges 1" >> $tor_config_file
        fi

        # add 'ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy' into $tor_config_file if not exist
        if [[ ! $(grep "ClientTransportPlugin obfs4 exec" $tor_config_file) ]]; then
            obfs4proxy=$(which obfs4proxy)
            echo "ClientTransportPlugin obfs4 exec ${obfs4proxy}" >> $tor_config_file
        fi

        if [[ "$add_bridges" == "True" ]]; then
            sudo echo -e "\n${BRIDGES}" >> $tor_config_file
            echo -e "${light_magenta}Bridges Added into ${magenta}${tor_config_file}\n"
        fi

        # show bridges
        echo -e "${cyan}${BRIDGES}"

        if [[ ! -z "$args_bridges_manager" ]]; then
            bridges-manager $args_bridges_manager
        fi

    else
        echo -e "${red}Tor config file $tor_config_file doesn't exist"
        exit 0
    fi
}

# uninstall script
function UninstallTBCLI(){
    echo -ne "${light_blue}"
    read -p "Do you want to delete this Script (y/n): " req
    if [[ "$req" == [yY]* ]]; then 

        echo -e "${light_green}Wait for uninstall${red}...${light_yellow}"
        #~~~ remove TBCLI
        file_projects="get-tor-bridges bridges-manager tbcli-config"
        path=$(which "get-tor-bridges" |sed 's/[^\/]*$//g')

        # check path not empty
        if [[ ! -z "$(ls $path|tr -d '\n ')" && ! -z "$path" ]] ;then 
            cd $path
            echo -e "$path $file_projects"
            rm $file_projects
            #~~~ end remove 
            echo -e "${light_magenta}Thanks for using this script."
        else
            echo -e "${light_red}can't remove script."
        fi

    fi
    echo -e "${nc}"
}
# # reset terminal
# tput reset


add_bridges="False"
args_bridges_manager=""

while [ "$1" != "" ]; do
    case $1 in
        -a | --add-bridges  ) add_bridges="True" ;;

        -d | --disable-broken-bridge ) args_bridges_manager="$args_bridges_manager -d" ;;

        -e | --enable-all-bridge     ) args_bridges_manager="$args_bridges_manager -e" ;;

        -r | --reset-tor    ) args_bridges_manager="$args_bridges_manager -r" ;;  
        
        -u | --uninstall    ) UninstallTBCLI && exit 0 ;;

        -h | --help | *) usage && exit 0;;
    esac
    shift
done

# This script need to run as root
if [[ $UID -ne 0 ]]; then
    echo -e "${red}This script must be run as root!${nc}"
    exit 1
fi

# delete tmp files
trap ClearFiles EXIT

# get tor bridges
get_tor_bridges "$add_bridges" "$args_bridges_manager"
