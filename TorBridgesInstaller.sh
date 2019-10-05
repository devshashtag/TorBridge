#!/usr/bin/env bash

# installer tor bridges

mkdir -p ~/.local/bin
cd ~/.local/bin

curl -s -o get-tor-bridges https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/TorBridge.sh

curl -s -o remove-broken-bridges https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/bad_bridges_remover.sh

chmod +x remove-broken-bridges
chmod +x get-tor-bridges

[[ -z $(echo $PATH|grep $HOME/.local/bin) ]] &&
{
    shell_file=$HOME/.$(egrep -o "[^/]*$" <<< $SHELL)rc
    # add path run script into PATH variable
    cat <<< """
if [ -e "~/.local/bin" ]; then
    export PATH="\$PATH:\$HOME/.local/bin/"
fi
""" >> $shell_file
    source $shell_file
}

echo -e "\e[32mScript installed successfully! "
