# Tor Bridge cli

**a simple script for get tor bridge from** : `https://bridges.torproject.org/bridges`
**and manage tor service**

**old version** :
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
curl -s "https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/tbcli-installer.sh" |bash
```

## uninstall 

```bash
tbcli -u 
```

## USAGE
**this script need to run as root** (*for get/add/remove/disable/enable bridges and restart tor service*)
```bash
tbcli -h :
    -a | -A | --add-bridges             add bridges into /etc/tor/torrc and print bridges
    -p | -P | --print-only-bridges      just print bridges
    -d | -D | --disable-broken-bridges  disable broken bridges in this network connection
    -c | -C | --clear-broken-bridges    remove all broken briges
    -e | -E | --enable-all-bridges      enable all disabled Bridges
    -r | -R | --reset-tor               restart tor service
    -u | -U | --uninstall               uninstall Script
    -h | -H | --help                    show this help
```

## More
>  Special thanks to : **virtualdemon**
