local json = require("json")
local util = require("util")

local HistoryManager = {}

function HistoryManager:getHistoryPath()
    local settings_dir = "."
    if util and util.getSettingsDir then
        settings_dir = util.getSettingsDir()
    end
    return settings_dir .. "/aireadingassistant_history.json"
end

function HistoryManager:saveConversation(conversation)
    if not conversation or #conversation == 0 then return end
    
    local path = self:getHistoryPath()
    local history = self:loadHistory()
    
    table.insert(history, {
        timestamp = os.time(),
        messages = conversation
    })
    
    -- Keep last 50 conversations to prevent unlimited growth
    if #history > 50 then
        table.remove(history, 1)
    end
    
    local f = io.open(path, "w")
    if f then
        f:write(json.encode(history))
        f:close()
    end
end

function HistoryManager:loadHistory()
    local path = self:getHistoryPath()
    local f = io.open(path, "r")
    if not f then return {} end
    local content = f:read("*a")
    f:close()
    
    if not content or content == "" then return {} end
    local success, res = pcall(json.decode, content)
    if success then return res else return {} end
end

return HistoryManager