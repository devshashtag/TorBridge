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
    echo -e "\e[0;32m\t-c | --disable-check-bridges\t\e[0;36mdont try to find broken bridges"
    echo -e "\e[0;32m\t-r | --reset-tor\t\e[0;36mrestart tor service"
    echo -e "\e[0;32m\t-h | --help\t\t\e[0;36mshow this help"
    echo -e "\e[m"
}

# read unable connetion bridges from status tor and comment bad bridges
function remove_broken_bridges(){

    echo -ne "\e[1;33mwaiting for find broken bridges:\n\t"
    bad_bridges=$(systemctl status tor.service|grep "unable"|egrep -o "([0-9]{1,3}.){3}[0-9]{1,3}:[0-9]{2,8}")
    [[ ! -z $(echo $bad_bridges|tr -d '\n') ]] &&
    {
        echo -e "\e[31mBad Bridges:"
        echo -e "\e[36m$bad_bridges" |sed 's/^/\t/g'
        for i in ${bad_bridges[@]};do
            sed -i "s/Bridge.*${i}/#&/g" $tor_conf_file
        done
        # good bridges
        # echo -e "\e[32m$(cat $tor_conf_file|egrep --color=auto "^Bridge.*")"

        echo -e "\e[33mbroken bridges successfully removed.\e[m"
    } ||
        echo -e "\e[1;35mAll bridges are healthy\e[m"
}
check="True"
# args
while [ "$1" != "" ]; do
    case $1 in
        -c | --disable-check-bridges ) check="False" ;;

        -r | --reset-tor    )
        {
            # restart tor
            systemctl restart tor.service
            echo -e "\e[1;35mwaiting for restart tor service .."

            status=" "
            while [[ "$res" != "100" ]];do
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

if [[ $check == "True" ]];then
    remove_broken_bridges
fi
