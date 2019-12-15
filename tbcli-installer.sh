#!/usr/bin/env bash

# installer tor bridges
mkdir -p ~/.local/bin
cd ~/.local/bin

repo="https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/"

# download files
curl -s -o get-tor-bridges "${repo}get-tor-bridges.sh"
curl -s -o bridges-manager "${repo}bridges-manager.sh"
curl -s -o tbcli-config    "${repo}tbcli-config"

# check files
if [[ ! -e get-tor-bridges && ! -e bridges-manager && ! -e config ]]; then
    echo -e "\e[1;31mfiles are not available . Please Check the Permission or Connection.\e[m"
    exit 1
fi

# execute permission
chmod +x remove-broken-bridges
chmod +x get-tor-bridges
chmod +x config 

# shell file config
shell_file=$HOME/.$(egrep -o "[^/]*$" <<< $SHELL)rc

# check file exist
[[ ! -e "$shell_file" ]] && echo -e "\e[31mError cant find shell config!\e[m"

# automatically add path program to shell config file jsut support bash and zshrc
if [[ ! -z $(egrep "bash|zsh" <<< $shell_file) ]]; then
    # add path run script into PATH variable
    if [[ -z $(cat $shell_file|egrep "if \[ -e ~/.local/bin \]; then") ]]; then

        echo "if [ -e ~/.local/bin ]; then" >> $shell_file
        echo "    export PATH=\"\$PATH:\$HOME/.local/bin/\"">> $shell_file
        echo "fi" >> $shell_file
        echo -e "\e[1;32mrun path was added automatically.\e[m"
    else
        echo -e "\e[1;32mpath already added.\e[m"
    fi
else
    # manual installation
    echo -e "\e[1;33mPlease add these lines to your '${SHELL}' config file and continue with manual installation\e[1;35m"
    echo -e "if [ -e ~/.local/bin ]; then"
    echo -e "    export PATH=\"\$PATH:\$HOME/.local/bin/\""
    echo -e "fi"
fi

echo -e "\e[1;32mScript installed successfully!\e[m"
