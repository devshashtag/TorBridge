#!/usr/bin/env bash

# installer tor bridges

mkdir -p ~/.local/bin
cd ~/.local/bin

curl -s -o get-tor-bridges https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/TorBridges.sh

curl -s -o remove-broken-bridges https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/remove_broken_bridges.sh

chmod +x remove-broken-bridges
chmod +x get-tor-bridges

[[ -z $(echo $PATH|grep $HOME/.local/bin) ]] &&
{
    shell_file=$HOME/.$(egrep -o "[^/]*$" <<< $SHELL)rc
    [[ -z "$shell_file" ]] && echo -e "\e[31mError cant find shell config!\e[m" && exit 0

    # add path program to shell config file
    [[ ! -z $(egrep "bash|zsh" <<< $shell_file) ]] &&
    {

        # add path run script into PATH variable
        echo -e "\e[1;32mrun path was added automatically.\e[m"
        echo "if [ -e \"~/.local/bin\" ]; then" >> $shell_file
        echo "    export PATH=\"\$PATH:\$HOME/.local/bin/\"">> $shell_file
        echo "fi" >> $shell_file
    }||
    {
        # manual installation
        echo "\e[1;33mPlease add these lines to your ${shell_file} file and continue with manual installation\e[1;35m"
        echo "if [ -e \"~/.local/bin\" ]; then"
        echo "    export PATH=\"\$PATH:\$HOME/.local/bin/\""
        echo "fi"

    }
}

echo -e "\e[32mScript installed successfully!\e[m"
