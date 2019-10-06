#!/usr/bin/env bash

# read status tor service and remove broken bridges

tor_conf_file=/etc/tor/torrc

function remove_broken_bridges(){
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
    # restart tor
    systemctl restart tor.service
    echo -e "\e[1;35mwaiting for restart tor service .."
    sleep 5

}

# this script need to run as root
if [[ $UID -ne 0 ]]; then
    echo -e "\e[31mThis script must be run as root\e[m "
    exit 1
fi

remove_broken_bridges