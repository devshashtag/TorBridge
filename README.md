# ABOUT

**a simple script for get tor bridge from** :` https://bridges.torproject.org/bridges`

**new version** :
[![asciicast](https://asciinema.org/a/CVdg9arcaLU9nyXsvuW7FOyEn.svg)](https://asciinema.org/a/CVdg9arcaLU9nyXsvuW7FOyEn)


## Requirements (before installation)
**Script runs with tor for now! i'll add a proxy version later**
Install these packages with your package manager:
1. **tor**
2. **obfs4proxy**
3. **proxychains-ng**
4. **feh**

## install
**with curl** :
```bash
mkdir -p /tmp/tor-installer && cd /tmp/tor-installer && curl -s -o tbcli-installer https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/tbcli-installer.sh && chmod +x tbcli-installer && ./tbcli-installer && shell_file=$HOME/.$(egrep -o "[^/]*$" <<< $SHELL)rc && source $shell_file && cd
```

## uninstall 

```bash
get-tor-bridges -u 
```

## USAGE
**this script need to run as root**(*for add bridges and restart tor service*)
```bash
    get-tor-bridges :
                -a | --add-bridges            add bridges to /etc/tor/torrc
                -d | --disable-broken-bridge  Disable broken Bridges in this network connection
                -e | --enable-all-bridge      Enable all disabled Bridges
                -r | --reset-tor              restart tor service
                -u | --uninstall              uninstall Script
                -h | --help                   show this help

```
```bash
    bridges-manager :
                -d | --disable-broken-bridge Disable broken Bridges in this network connection
                -e | --enable-all-bridge     Enable all disabled Bridges
                -r | --reset-tor             restart tor service
                -h | --help                  show this help

```

## More
>  Special thanks to : **virtualdemon**
