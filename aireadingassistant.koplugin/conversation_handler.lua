local AICompanionViewer = require("aicompanionviewer")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local _ = require("gettext")
local queryAI = require("ai_query")
local Utils = require("utils")
local HistoryManager = require("history_manager")
local Event = require("ui/event")

local CONFIGURATION
local success, result = pcall(function() return require("configuration") end)
if success then
  CONFIGURATION = result
else
  CONFIGURATION = { max_ai_response_lines = 0 }
end

local ConversationHandler = {}

function ConversationHandler.start(title, initial_messages, highlight_instance, callbacks, ui, UIManagerInstance)
    callbacks = callbacks or {}
    local message_history = initial_messages
    local _UIManager = UIManagerInstance or UIManager

    local function truncate_response(text)
        if CONFIGURATION.max_ai_response_lines and CONFIGURATION.max_ai_response_lines > 0 then
            local lines = {}
            for line in text:gmatch("[^\n]+") do
                table.insert(lines, line)
            end
            if #lines > CONFIGURATION.max_ai_response_lines then
                local truncated_text = table.concat(lines, "\n", 1, CONFIGURATION.max_ai_response_lines)
                return truncated_text .. "\n[...]\n" .. _("（内容已截断，共") .. #lines .. _("行，显示前") .. CONFIGURATION.max_ai_response_lines .. _("行）")
            end
        end
        return text
    end

    local function handleResponse(answer_raw)
         local normalized_answer = Utils.normalize_whitespace(answer_raw)
         local answer_display = truncate_response(normalized_answer)
         table.insert(message_history, { role = "assistant", content = answer_raw })
         
         local result_text = Utils.createResultText(message_history)
         
         local viewer
         local function onAsk(v, question)
             table.insert(message_history, { role = "user", content = question })
             local success, res = pcall(function() return queryAI(message_history) end)
             if success and res then
                 local ans = Utils.normalize_whitespace(res)
                 table.insert(message_history, { role = "assistant", content = res })
                 v:update(Utils.createResultText(message_history), truncate_response(ans))
             else
                 UIManager:show(InfoMessage:new{ text = _("Error: ") .. tostring(res), timeout = 5 })
             end
         end
         
         viewer = AICompanionViewer:new{
             title = title,
             text = result_text,
             reader_highlight_instance = highlight_instance,
             latest_response = answer_display,
             onAskQuestion = onAsk,
            close_callback = function() 
                HistoryManager:saveConversation(message_history)
                _UIManager:scheduleIn(0.2, function()
                    if ui and ui.onClearSelection then
                        ui:onClearSelection()
                    end
                    _UIManager:broadcastEvent(Event:new("ClearSelection"))
                    if callbacks.onClose then callbacks.onClose() end
                end)
            end
         }
         UIManager:show(viewer)
    end

    -- 阻塞查询前，确保没有任何 Dialog 还在 UI 栈中
    local success, result = pcall(function() return queryAI(initial_messages) end)
    if success and result then
        handleResponse(result)
    else
        UIManager:show(InfoMessage:new{ text = _("AI Error: ") .. tostring(result), timeout = 5 })
        UIManager:broadcastEvent(Event:new("ClearSelection"))
    end
end

return ConversationHandler
