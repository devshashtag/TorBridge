# ABOUT

**a simple script for get tor bridge from** :` https://bridges.torproject.org/bridges`

![TBCLI preview](https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/screenshot/captcha.jpg)
![TBCLI preview](https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/screenshot/Bridges.jpg)

## Requirements (before installation)
**Script runs with tor for now! i'll add a proxy version later**
Install these packages with your package manager:
1. tor
2. obfs4proxy
3. proxychains-ng
4. feh

## Download
with curl :
```bash
mkdir -p /tmp/tor-installer && cd /tmp/tor-installer && curl -s -o tor-bridges-installer https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/TorBridgesInstaller.sh && chmod +x tor-bridges-installer && ./tor-bridges-installer && shell_file=$HOME/.$(egrep -o "[^/]*$" <<< $SHELL)rc && source $shell_file && cd
```

## Run

get bridges :
```bash
sudo get-tor-bridges
```

**read code from image (**for example =>` AkP92qaM`**) and write in terminal**

```bash
{Tor ip} => enter code (enter r for reset captcha) : AkP92qaM

Bridges Added into /etc/tor/torrc :
Bridge obfs4 217.112.131.53:443 1DF71F28E8A97C285A5F58857...........
Bridge obfs4 70.69.20.165:53934 B4BA94C26FA87E647261D734B..........
Bridge obfs4 172.105.81.183:443 E5350EF0B0F2B75D2C6DBDFD2..........
```

## Remove bad bridges

remove bad bridges from file /etc/tor/torrc :
```bash
sudo remove-broken-bridges
```

![TBCLI preview](https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/screenshot/removeBrokenBridges.jpg)

## More
>  Special thanks to : **virtualdemon**
