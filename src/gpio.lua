-- Based on code from: https://github.com/rsisto/luaGpio/
-- GPIO utilities
local M = {}

---
-- Writes data to a file
-- @param location string file path to write
-- @param contents data to write (number or string)
local function writeToFile(location, contents)
	local fileToWrite = io.open(location, 'w')
	fileToWrite:write(contents)
	fileToWrite:close()
end

---
-- Reads a character from file and returns first letter of the file
-- @param location string file path to read
-- @return string first letter of the file
local function readFromFile(location)
	local fileToRead = io.open(location, 'r')
	local fileStr = fileToRead:read(1)
	fileToRead:close()
	return fileStr
end

---
-- Check if file exists
-- @param location string  file path to check
-- @return boolean true if file exists and false otherwise
local function fileExists(location)
   local file = io.open(location, "r")
   if file then
     file:close()
     return true
   else
     return false
   end
end

---
-- Exports GPIO pin to use as an output pin
-- @param id GPIO pin number
function M.configureOutGPIO(id)
  -- export GPIO pin if needed
	if not fileExists("/sys/class/gpio/gpio"..tostring(id).."/direction") then
		writeToFile("/sys/class/gpio/export", id)
	end
	writeToFile("/sys/class/gpio/gpio"..id.."/direction", "out")
end

---
-- Exports GPIO ID to use as an input pin
-- @param id GPIO pin number
function M.configureInGPIO(id)
  -- export GPIO pin if needed
	if not fileExists("/sys/class/gpio/gpio"..id.."/direction") then
		writeToFile("/sys/class/gpio/export", id)
	end
	writeToFile("/sys/class/gpio/gpio"..id.."/direction", "in")
end

----
-- Reads GPIO pin and returns its value
-- GPIO pin must be configured before using this function
-- @param id GPIO pin number
-- @return boolean true if state is 1(high) and false on state 0(low)
function M.readGPIO(id)
  local state = readFromFile("/sys/class/gpio/gpio"..id.."/value")
  if state == '1' then
    return true
  else
    return false
  end
end

---
-- Writes a value to GPIO pin
-- GPIO pin must be configured to output before using this function
-- @param id GPIO pin number
function M.writeGPIO(id, val)
	writeToFile("/sys/class/gpio/gpio"..id.."/value", val)
end

return M
