#!/usr/bin/env lua
local utils = require 'src.utils'
local gpio = require 'src.gpio'
local config = require 'src.config'

local function setup()
  for _, pinID in pairs(config.leds) do
    gpio.configureOutGPIO(pinID)
    gpio.writeGPIO(pinID, 0)
  end

  for _, pinID in pairs(config.buttons) do
    gpio.configureInGPIO(pinID)
  end
end

local function loop()
  local connectionOK = false
  local unitsOK = true

  for _, interface in pairs(config.interfacesToCheck) do
    local interfaceOK = utils.getNetworkStatus(interface)
    if interfaceOK then
      connectionOK = true
    end
  end
  for _, unit in pairs(config.unitsToCheck) do
    local unitOK = utils.getUnitStatus(unit)
    if not unitOK then
      unitsOK = false
    end
  end

  if connectionOK then
    gpio.writeGPIO(config.greenLED, 1)
  else
    gpio.writeGPIO(config.greenLED, 0)
  end

  if not unitsOK then
    gpio.writeGPIO(config.redLED, 1)
  else
    gpio.writeGPIO(config.redLED, 0)
  end
end

local function checkInput()
  -- Shutdown button is active low
  local shutdownButton = gpio.readGPIO(config.shutdownButton)
  if shutdownButton then return end
  -- Wait one second to de-bounce button
  utils.sleep(1)
  shutdownButton = gpio.readGPIO(config.shutdownButton)
  if shutdownButton then return end
  print("Shutdown button pressed - hold ~5 sec to shutdown the system")
  -- Indicate that button is pressed
  for _, pinID in pairs(config.leds) do
    gpio.writeGPIO(pinID, 0)
  end
  utils.sleep(1)
  -- Light up LED after led to indicate that program is responding
  for _, pinID in pairs(config.leds) do
    shutdownButton = gpio.readGPIO(config.shutdownButton)
    if shutdownButton then return end
    gpio.writeGPIO(pinID, 1)
    utils.sleep(1)
  end
  -- Finally shut down the system and turn off the LEDs
    for _, pinID in pairs(config.leds) do
    gpio.writeGPIO(pinID, 0)
  end
   print("System shutdown.")
  utils.shutdown()
end



local function main()
  -- Execute setup and loop
  local err = pcall(setup)
  if not err then
    print("Cannot configure GPIO - check permissions!")
    os.exit(1)
  end
  print("SysMonitor started.")
  -- This should check inputs every second and checks system
  -- status every config.checkInterval
  while true do
    local counter = 0
    repeat
      checkInput()
      utils.sleep(1)
      counter = counter + 1
    until counter < config.checkInterval
    local loopErr = pcall(loop)
    if not loopErr then
      gpio.writeGPIO(config.blueLED, 1)
    else
      gpio.writeGPIO(config.blueLED, 0)
    end
  end
end

main()
