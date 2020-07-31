---
-- Utilities to wrap some GNU/Linux userspace programs.

local M = {}

local systemdSubStates = {
  -- If state is missing form section then it probably shares the same name with
  -- state name from other section.
  -- Automount unit substates
  ["dead"] = false,
  ["waiting"] = true,
  ["running"] = true,
  ["failed"] = false,
  -- Device unit substates
  ["tentative"] = true, -- For example FUSE subsystem
  ["plugged"] = true,
  -- Mount unit substates
  ["mounted"] = true,
  ["mounting"] = false,
  ["mounting-done"] = false,
  ["remounting"] = false,
  ["remounting-sigterm"] = false,
  ["remounting-sigkill"] = false,
  ["unmounting-sigterm"] = false,
  ["unmounting-sigkill"] = false,
  ["cleaning"] = false,
  -- Path unit substates

  -- Scope unit substates
  ["abandoned"] = false,
  ["stop-sigterm"] = false,
  ["stop-sigkill"] = false,
  -- Service unit substates
  ["condition"] = false,
  ["start-pre"] = false,
  ["start"] = false,
  ["start-post"] = false,
  ["exited"] = true,
  ["reload"] = false,
  ["stop"] = false,
  ["stop-watchdog"] = false,
  ["stop-post"] = false,
  ["final-sigterm"] = false,
  ["final-sigkill"] = false,
  ["auto-restart"] = false,
  -- Slice unit substates
  ["active"] = true,
  -- Socket unit substates
  ["start-chown"] = false,
  ["listening"] = true,
  ["stop-pre"] = false,
  ["stop-pre-sigterm"] = false,
  ["stop-pre-sigkill"] = false,
  -- Swap unit substates
  ["activating"] = false,
  ["activating-done"] = false,
  ["deactivating"] = false,
  ["deactivating-sigterm"] = false,
  ["deactivating-sigkill"] = false,

  -- Target unit substates

  -- Timer unit substates
  ["elapsed"] = true,
}

setmetatable(systemdSubStates,{__index = function() return false end})

---
-- Returns connection status on interface type.
-- @param interface_type string Type of NetworkManager interface
-- for example "wifi", "ethernet", "bridge" etc.
-- @return boolean true if any connection on interface type
-- has 'connected' status, false otherwise
function M.getNetworkStatus(interface_type)
  local handle = io.popen("nmcli --terse d")
  local result = handle:read("*a")
  handle:close()
  local interface_lines = {}
  for line in result:gmatch("([^\n]*)\n?") do
    if line:find(interface_type) then table.insert(interface_lines, line) end
  end
  local status = false
  for _,value in pairs(interface_lines) do
    if value:find("connected") then status = true end
  end
  return status
end

---
-- Returns SystemD unit (automount, device, mount, path, scope, service, slice,
-- socket, swap, target or timer) status in form of a string.
-- @param service_name string name of the service for example "nginx.service"
-- @return boolean true if the service is running or false if otherwise
-- @return string state of the service or false on state unknown to this script
-- Possible states:
-- active, inactive, activating, deactivating, failed, not-found, dead
function M.getUnitStatus(service_name)
  local handle = io.popen("systemctl show -p SubState --value "..service_name)
  local result = handle:read("*a")
  handle:close()
  if not result then result = "function error" end
  result = result:gsub("\n", "") -- Remove line break
  return systemdSubStates[result], result
end

---
-- Checks all SystemD units in memory.
-- @return boolean true if every unit is in "good" state, false otherwise.
-- @return table list with units in "good" state or list with failed units.
-- XXX: does not work when unit has strange names - interesting bug form SystemD
function M.checkAllUnits()
  local successUnits, failedUnits = {}, {}
  local handle = io.popen("systemctl list-units -t service --no-pager --no-legend| cut -d' ' -f1")
  local result = handle:read("*a")
  handle:close()
  for unit in result:gmatch("([^\n]*)\n?") do
    if M.getUnitStatus(unit) then
      table.insert(successUnits, unit)
    else
      table.insert(failedUnits, unit)
    end
  end

  if #failedUnits ~= 0 then
    return false, failedUnits
  else
    return true, successUnits
  end
end

---
-- Halts execution of script for s seconds.
-- Interrupts will not be caught when using this function.
-- @param s seconds for delay - decimals can be used.
function M.sleep(s)
  os.execute("sleep " .. tonumber(s))
end

---
-- Shutdowns the system (to be precise halts the kernel as form most SBCs
-- poweroff can lead to immediate reboot).
-- This function shouldn't return as the whole system should be shutting down.
function M.shutdown()
  os.execute("systemctl halt")
end
return M