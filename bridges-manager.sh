#!/usr/bin/env bash 
# part of Tor Bridges
# Bridge Manager 

# Add config file 
source tbcli-config  2>/dev/null 
if [[ $? -ne 0 ]] ; then 
    echo -e "\e[31m file config Not exist" 
    exit 1 
fi 

# this script need to run as root
if [[ $UID -ne 0 ]]; then
    echo -e "${red}This script must be run as root !\e[m "
    exit 1
fi

# usage
function usage(){
    echo -e "${light_magenta}USAGE ${light_yellow}Bridge Manager ${light_red}:"
    echo -e "${light_green}\t-d | --disable-broken-bridge\t${cyan}Disable broken Bridges in this network connection"
    echo -e "${light_green}\t-e | --enable-all-bridge\t${cyan}Enable all disabled Bridges"
    echo -e "${light_green}\t-r | --reset-tor\t\t${cyan}mrestart tor service"
    echo -e "${light_green}\t-h | --help\t\t\t${cyan}show this help"
    echo -e "${nc}"
}

# read 'unable connetion bridges' from status tor and comment broken bridges
function disable_broken_bridges(){
    # check tor file is exist
    if [ -e "$tor_config_file" ]; then
        echo -ne "${light_yellow}waiting for find broken bridges:\n\t"
        # broken bridges
        broken_bridges=$(systemctl status tor.service|grep "unable"|egrep -o "([0-9]{1,3}.){3}[0-9]{1,3}:[0-9]{2,8}")
        # check bridges exist
        [[ ! -z $(echo $broken_bridges|tr -d '\n') ]] &&
            {
                echo -e "${light_red}Broken Bridges:"
                # comment broken bridges 
                for bridge in ${broken_bridges[@]};do
                    echo -e "\t${light_magenta}[${light_red}X${light_magenta}] ${cyan}${bridge}"
                    sed -i "s/^Bridge.*${bridge}/#&/g" "$tor_config_file"
                done
                # good bridges
                # echo -e "\e[32m$(cat $tor_config_file|egrep --color=auto "^Bridge.*")"
                echo -e "${light_yellow}broken bridges successfully disable.\e[m"
            } ||
                echo -e "${magenta}All bridges are healthy\e[m"
        echo -e "${cyan}Active Bridges : $(cat $tor_config_file |grep ^Bridge|wc -l)\e[m"
    else
        echo -e "${red}Tor config file $tor_config_file doesn't exist"
        exit 0
    fi
}

# enable all disabled bridge
function enable_all_bridges(){
    # check tor file is exist
    if [ -e "$tor_config_file" ]; then
        Disable_Bridges=$(cat $tor_config_file | egrep "#Bridge obfs4")
        if [[ ! -z "$Disable_Bridges" ]]; then 
            echo -e "${yellow}Disable Bridges : \n${light_red}$Disable_Bridges" 
            sed -i "s/^#Bridge obfs4/Bridge obfs4/g" "$tor_config_file"
            echo -e "${light_green}Enabled."
        else
            echo -e "${light_yellow}All bridges are enable"
            echo -e "${cyan}Active Bridges : $(cat /etc/tor/torrc |grep ^Bridge|wc -l)${nc}"
        fi
    else
        echo -e "${red}Tor config file $tor_config_file doesn't exist"
        exit 0
    fi
    
}

# restart tor with display bar 
function reset_tor(){
    # restart tor
    systemctl restart tor.service
    echo -e "${magenta}wait for restart tor service .."
    # my tor status bar
    res=0
    status=" "
    sep="${red}\n-> "
    while [[ "$res" -lt "100" ]];do
        sleep 0.1
        res=$(systemctl status tor.service |egrep -o "Bootstrapped[^%]*"|tail -n 1|cut -d' ' -f2)
        [[ -z $(grep "$res" <<< "$status") ]] && status="$res$status" && echo -ne "${sep}${light_green}${res}"
    done
    echo -e "\n"
}

while [ "$1" != "" ]; do
    case $1 in
        -d | --disable-broken-bridge ) disable_broken_bridges ;;
        -e | --enable-all-bridge     ) enable_all_bridges     ;; 
        -r | --reset-tor             ) reset_tor              ;; 
        -h | --help | *) usage && exit 0;;
    esac
    shift
done

