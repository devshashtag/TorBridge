#!/usr/bin/env bash

# read status tor service and remove broken bridges

TorConfigFile="/etc/tor/torrc"


# this script need to run as root
if [[ $UID -ne 0 ]]; then
    echo -e "\e[31mThis script must be run as root !\e[m "
    exit 1
fi

# usage
function usage(){
    echo -e "\e[0;1;33mPart of Tor Bridges -> Bridge Manager"
    echo -e "\e[35mUSAGE :"
    echo -e "\e[0;32m\t-t | --test-bridges\t\e[0;36m\tremove broken bridges"
    echo -e "\e[0;32m\t-r | --reset-tor\t\t\e[0;36mrestart tor service"
    echo -e "\e[0;32m\t-h | --help\t\t\t\e[0;36mshow this help"
    echo -e "\e[m"
}

# read unable connetion bridges from status tor and comment bad bridges
function remove_broken_bridges(){

    echo -ne "\e[0;33mwaiting for find broken bridges:\n\t"
    broken_bridges=$(systemctl status tor.service|grep "unable"|egrep -o "([0-9]{1,3}.){3}[0-9]{1,3}:[0-9]{2,8}")
    [[ ! -z $(echo $broken_bridges|tr -d '\n') ]] &&
    {
        echo -e "\e[1;31mBroken Bridges:"
        for bridge in ${broken_bridges[@]};do
            echo -e "\t\e[1;35m[\e[31mX\e[35m] \e[0;36m$bridge"
            sed -i "s/^Bridge.*${bridge}/#&/g" $TorConfigFile
        done
        # good bridges
        # echo -e "\e[32m$(cat $TorConfigFile|egrep --color=auto "^Bridge.*")"

        echo -e "\e[33mbroken bridges successfully removed.\e[m"
    } ||
        echo -e "\e[1;35mAll bridges are healthy\e[m"
}

# args
if [[ $# -lt 1 ]];then
    remove_broken_bridges
fi

while [ "$1" != "" ]; do
    case $1 in
        -t | --test-bridges ) remove_broken_bridges ;;

        -r | --reset-tor    )
        {
            # restart tor
            systemctl restart tor.service
            echo -e "\e[1;35mwaiting for restart tor service .."
            res=0
            status=" "
            while [[ "$res" -lt "100" ]];do
                sleep 0.1
                res=$(systemctl status tor.service |egrep -o "Bootstrapped[^%]*"|tail -n 1|cut -d' ' -f2)
                [[ -z $(grep "$res" <<< "$status") ]] && status="$res$status" && echo -ne "|$res"
            done
            echo "|"
        };;

        -h | --help | *) usage && exit 0;;
    esac
    shift
done

