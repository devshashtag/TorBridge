# ABOUT

**a simple script for get tor bridge from** :` https://bridges.torproject.org/bridges`

![TBCLI preview](https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/screenshot/captcha.jpg)
![TBCLI preview](https://raw.githubusercontent.com/MicroRobotProgrammer/TorBridge/master/screenshot/Bridges.jpg)


## Download
	mkdir TorBridgeCLI
	cd  TorBridgeCLI
	git clone https://github.com/MicroRobotProgrammer/TorBridge.git

## Run
```bash
chmod +x ./TorBridge.sh
sudo ./TorBridge.sh
```
**read code from image(for example : 9autjyaz) and write in terminal**
you'r ip => enter code (enter `r` for reset captcha):`9autjyaz`
```bash
Bridges Added into /etc/tor/torrc :
Bridge obfs4 87.239.87.142:43618 562C4B1FB0DAEFFDDDAD..............
Bridge obfs4 217.12.199.62:44313 F7AD3CC4C00786BA4F.............
Bridge obfs4 104.175.38.225:34363 8014246EC27A8BBF1A...........
```


## Requirements

*** tor, feh, proxychains4, obfs4proxy***

## More
>  Special thanks to :  **virtualdemon**

