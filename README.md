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
mkdir -p /tmp/tor-installer && cd /tmp/tor-installer && curl -s -o tor-bridges-installer https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/TorBridgesInstaller.sh && chmod +x tor-bridges-installer && ./tor-bridges-installer && cd
```

## Run

get bridges :
```bash
sudo get-tor-bridges
```

**read code from image (**for example =>` 9autjyaz`**) and write in terminal**

```bash
your ip => enter code (enter r for reset captcha) : 9autjyaz

Bridges Added into /etc/tor/torrc :
Bridge obfs4 87.239.87.142:43618 562C4B1FB0DAEFFDDDAD..............
Bridge obfs4 217.12.199.62:44313 F7AD3CC4C00786BA4F.............
Bridge obfs4 104.175.38.225:34363 8014246EC27A8BBF1A...........
```

## Remove bad bridges

remove bad bridges from file /etc/tor/torrc :
```bash
sudo remove-broken-bridges
```

![TBCLI preview](https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/screenshot/removeBrokenBridges.jpg)

## More
>  Special thanks to : **virtualdemon**
