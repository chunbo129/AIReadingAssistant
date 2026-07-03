local json = require("json")
local util = require("util")

local SettingsStorage = {}

function SettingsStorage.getSettingsPath()
  local settings_dir = "."
  if util and util.getSettingsDir then
    settings_dir = util.getSettingsDir()
  end
  return settings_dir .. "/aireadingassistant_settings.json"
end

function SettingsStorage.load(default_config)
  local path = SettingsStorage.getSettingsPath()
  local f = io.open(path, "r")
  if not f then
    -- Return a copy of defaults
    local copy = {}
    for k, v in pairs(default_config) do
      copy[k] = v
    end
    return copy
  end
  local content = f:read("*a")
  f:close()
  if not content or content == "" then
    local copy = {}
    for k, v in pairs(default_config) do
      copy[k] = v
    end
    return copy
  end
  local success, res = pcall(json.decode, content)
  if success and type(res) == "table" then
    -- Merge defaults with loaded settings
    local merged = {}
    for k, v in pairs(default_config) do
      merged[k] = v
    end
    for k, v in pairs(res) do
      merged[k] = v
    end
    return merged
  else
    local copy = {}
    for k, v in pairs(default_config) do
      copy[k] = v
    end
    return copy
  end
end

function SettingsStorage.save(config)
  local path = SettingsStorage.getSettingsPath()
  local f = io.open(path, "w")
  if f then
    -- Strip helper methods
    local clean_config = {}
    for k, v in pairs(config) do
      if type(v) ~= "function" then
        clean_config[k] = v
      end
    end
    f:write(json.encode(clean_config))
    f:close()
    return true
  end
  return false
end

return SettingsStorage
