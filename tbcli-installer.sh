#!/usr/bin/env bash

repo="https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/"

# Tor Bridges CLI path
mkdir -p ~/.local/bin
mkdir -p ~/.config/tbcli 

# ----  download files ----
cd ~/.local/bin
curl -s -o tbcli "${repo}tbcli.sh"
chmod +x tbcli # add execute permission
# ------ Config file ------
cd ~/.config/tbcli
curl -s -o tbcli-config "${repo}tbcli-config"
chmod +x tbcli-config # add execute permission

# check files
if [[ ! -e ~/.local/bin/get-tor-bridges && ! -e ~/.config/tbcli/tbcli-config ]]; then
    echo -e "\e[1;31mrequire files not available . Please Check the Permission or Connection.\e[m"
    exit 1
fi

# shell file config
shell_file=$HOME/.$(egrep -o "[^/]*$" <<< $SHELL)rc

# check file exist
[[ ! -e "$shell_file" ]] && echo -e "\e[1;31mError: \e[1;33mcan't find shell config!\e[m"

# Automatically add path program to shell config file jsut support bash and zshrc
if [[ ! -z $(egrep "bash|zsh" <<< $shell_file) ]]; then
    # add path run script into PATH variable
    if [[ -z $(cat "$shell_file"|egrep "if \[ -e ~/.local/bin \]; then") ]]; then
        echo "if [ -e ~/.local/bin ]; then" >> "$shell_file"
        echo "    export PATH=\"\$PATH:\$HOME/.local/bin/\"">> "$shell_file"
        echo "fi" >> "$shell_file"
        echo -e "\e[1;32mrun path was added automatically.\e[m"
    else
        echo -e "\e[1;32mpath already added.\e[m"
    fi
    source "$shell_file"
    echo -e "\e[1;32mScript installed successfully!\e[m"
    echo -e "\e[1;32mPlease Check 'tbcli -h' command\e[m"
    echo -e "\e[1;33mdo u want change tbcli config ? please check \e[1;34m~/.config/tbcli-config.\e[m"
else
    # manual installation
    echo -e "\e[1;33mPlease add these lines to your '${SHELL}' config file and continue with manual installation\e[1;35m"
    echo -e "if [ -e ~/.local/bin ]; then"
    echo -e "    export PATH=\"\$PATH:\$HOME/.local/bin/\""
    echo -e "fi"
    echo -e "\e[1;32mScript installed successfully!\e[m"
    echo -e "\e[1;32mPlease Check 'tbcli -h' command after add path in to shell file\e[m"
    echo -e "\e[1;33mdo u want change tbcli config ? please check \e[1;34m~/.config/tbcli/tbcli-config.\e[m"
fi


