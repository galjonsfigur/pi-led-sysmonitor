---
-- Configuration file - tailor it to your needs
local M = {}
-- GPIO number for /sys/class/gpio Linux interface
-- Gets lit if any of units on list are in "bad" (failed or similar) state
M.redLED = 3
-- Gets lit if connected to WiFi or Ethernet
M.greenLED = 19
-- Gets lit if there is an error in script
M.blueLED = 18

M.leds = {M.redLED, M.greenLED, M.blueLED}


-- Inputs
-- If pressed for ~5 seconds will command system to shutdown
M.shutdownButton = 16

M.buttons = {M.shutdownButton}

-- List of units - can be any type
M.unitsToCheck = {
  "nginx.service",
  "srv-backup.mount",
  "srv-data.mount",
  "var-log.mount",
  "aria2.service",
  "docker.service",
  "fail2ban.service",
  "mosquitto.service",
  "nginx.service",
  "seafile.service",
  "seahub.service",
  "ssh.service",
  "ufw.service",
  "acme.timer"
}

-- List of interfaces to check - only one of bellow needs to be connected to
-- indicate Green LED status
M.interfacesToCheck = {
  "wifi",
  "ethernet"
}

-- Check interval in seconds
M.checkInterval = 5

return M