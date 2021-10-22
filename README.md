# Tor Bridge cli

**a simple script for get tor bridge from** : `https://bridges.torproject.org/bridges` **and manage tor service**

**new version** :
[![asciicast](https://asciinema.org/a/292599.svg)](https://asciinema.org/a/292599)

**other screenshots** : 

![alt text](https://raw.githubusercontent.com/DevsHashtag/TorBridge/master/screenshots/colored_status.png)


![alt text](https://raw.githubusercontent.com/DevsHashtag/TorBridge/master/screenshots/manage_bridges.png)


![alt text](https://raw.githubusercontent.com/DevsHashtag/TorBridge/master/screenshots/manage_bridges-1.png)

## Requirements (before installation)
**Script runs with tor for now! i'll add a proxy version later**
Install these packages with your package manager:
1. **tor**
2. **obfs4proxy**
3. **proxychains4**
4. **feh**

Ubuntu,Debian :
```bash
# sudo apt install tor obfs4proxy proxychains4 feh
```
Arch Linux :
```bash
# sudo pacman -S tor obfs4proxy proxychains-ng feh
```
## install
**curl** :
```bash
curl -s "https://raw.githubusercontent.com/DevsHashtag/TorBridge/master/tbcli-installer"|sudo bash
```

**local repo** :
```bash 
git clone https://github.com/DevsHashtag/TorBridge.git
chmod +x tbcli-installer-local
sudo ./tbcli-installer-local
```

## uninstall 

```bash
sudo tbcli -u 
```

## USAGE
**this script need to run as root** (*for get/add/remove/disable/enable bridges and restart tor service*)
```bash
tbcli -h :
    a simple script for get tor bridge from https://bridges.torproject.org/bridges?transport=obfs4 and manage tor service

USAGE :
	-a | -A | --add-bridges	             add bridges into /etc/tor/torrc and print bridges
	-p | -P | --print-only-bridges       just print bridges
	-d | -D | --disable-broken-bridges   disable broken bridges in this network connection
	-c | -C | --clear-broken-bridges     remove all broken bridges from config file /etc/tor/torrc
	-e | -E | --enable-all-bridges       enable all broken bridges
	-r | -R | --reset-tor                restart tor service(you can use for start tor btw)
	-s | -S | --status-tor [length]      status tor service(**no need to root permission, default length is 10**)
	-o | -O | --off-tor                  stop tor service
	-u | -U | --uninstall                uninstall Script
	-h | -H | --help                     show help(**no need to root permission**)


```

## More
>  Special thanks to : **virtualdemon**
