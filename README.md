# Pi LED SysMonitor
![Luacheck](https://github.com/galjonsfigur/pi-led-sysmonitor/workflows/Luacheck/badge.svg)

Simple script written in Lua to show status of the system by 3 indicator LEDs
connected to GPIO pins. It requires fairly modern GNU/Linux environment that
uses NetworkManager for connectivity and SystemD as an init system. 

Features:
- Monitor SystemD units (services, mounts, timers etc.)
- Monitor NetworkManager connections (wifi, ethernet, etc)

### Installation instructions:
- install Lua 5.3 via packet manager of your repository 
(for example `sudo apt-get install lua5.3`)
- clone this repository into your SBC
- adjust configuration file in `src/config.lua` to your needs
- move repository catalog into /opt: `sudo mv pi-led-sysmonitor /opt/`
- test the script: `cd /opt/pi-led-sysmonitor/` and `sudo ./sysmonitor.lua`
(to kill the script press Ctrl-C several times
- add SystemD service to run the script: 
`sudo mv /opt/pi-led-sysmonitor/pi-led-sysmonitor.service /etc/systemd/system/`
and reload: `sudo systemctl daemon-reload`
- Enable and start the service:
`sudo systemctl --now enable pi-led-sysmonitor.service`

### License
MIT