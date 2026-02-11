local Device = require("device")
local InputContainer = require("ui/widget/container/inputcontainer")
local NetworkMgr = require("ui/network/manager")
local _ = require("gettext")
local AICompanionViewer = require("aicompanionviewer")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local Notification = require("ui/widget/notification")
local Event = require("ui/event")

local ConversationHandler = require("conversation_handler")
local Utils = require("utils")
local menu_cleaner = require("menu_cleaner") -- NEW: for custom menu cleanup

local AIReadingAssistant = InputContainer:new {
  name = "aireadingassistant",
  is_doc_only = true,
}

local updateMessageShown = false

function AIReadingAssistant:init()
  local success, result = pcall(function() return require("configuration") end)
  local CONFIGURATION
  if success then
    CONFIGURATION = result
  else
    print("configuration.lua not found, using default menu text")
  end

  self.ui.highlight:addToHighlightDialog("aireadingassistant_AI_Prompt1", function(_reader_highlight_instance)
    return {
      text = CONFIGURATION and CONFIGURATION.menu_text1 or _("AI Prompt 1"),
      enabled = true,
      callback = function()
        local text = _reader_highlight_instance.selected_text.text
        -- 使用 nextTick 确保 UI 响应
        UIManager:nextTick(function()
            self:handlePrompt(1, _reader_highlight_instance, text)
        end)
      end,
    }
  end)

  self.ui.highlight:addToHighlightDialog("aireadingassistant_AI_Prompt2", function(_reader_highlight_instance)
    return {
      text = CONFIGURATION and CONFIGURATION.menu_text2 or _("AI Prompt 2"),
      enabled = true,
      callback = function()
        local text = _reader_highlight_instance.selected_text.text
        UIManager:nextTick(function()
            self:handlePrompt(2, _reader_highlight_instance, text)
        end)
      end,
    }
  end)

  self.ui.highlight:addToHighlightDialog("aireadingassistant_AI_Prompt3", function(_reader_highlight_instance)
    return {
      text = CONFIGURATION and CONFIGURATION.menu_text3 or _("AI Prompt 3"),
      enabled = true,
      callback = function()
        local text = _reader_highlight_instance.selected_text.text
        UIManager:nextTick(function()
            self:handlePrompt(3, _reader_highlight_instance, text)
        end)
      end,
    }
  end)
end

function AIReadingAssistant:handlePrompt(prompt_number, _reader_highlight_instance, captured_text)
  local highlightedText = captured_text or (_reader_highlight_instance.selected_text and _reader_highlight_instance.selected_text.text) or ""
  
  local success, result = pcall(function() return require("configuration") end)
  local CONFIGURATION
  if success then
    CONFIGURATION = result
  end

  if CONFIGURATION and CONFIGURATION.auto_expand_to_sentence then
    local success_ctx, prev, next_ctx = pcall(function()
      return _reader_highlight_instance:getSelectedWordContext(50)
    end)
    if success_ctx then
      highlightedText = Utils.expand_to_sentence(highlightedText, prev, next_ctx)
    end
  end

  -- 之前尝试在这里立即清除选区（即使延迟0.5秒）也会导致 KOReader 崩溃
  -- 原因可能是清除选区会销毁底层对象，而该对象在后续流程中仍被引用
  -- 或者与菜单的关闭事件存在冲突。
  -- 因此，为了稳定性，我们回退到“在对话框关闭后才清除选区”的策略。
  -- 选区的清除工作将由 ConversationHandler 在关闭 AI 窗口时的回调中执行。
  
  if _reader_highlight_instance and _reader_highlight_instance.onClose then
    _reader_highlight_instance:onClose()
  end

  NetworkMgr:runWhenOnline(function()
    if not updateMessageShown then
      updateMessageShown = true
    end

    local default_prompt = "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly. Answer as concisely as possible."
    local prompt_key = "prompt" .. prompt_number
    local system_prompt = (CONFIGURATION and CONFIGURATION[prompt_key] or default_prompt) .. "\n\n请返回纯文本，不要包含markdown格式符号"

    local message_history = {
      { role = "system", content = system_prompt },
      { role = "user", content = highlightedText }
    }

    ConversationHandler.start(_("AI阅读助手"), message_history, _reader_highlight_instance, nil, self.ui, UIManager)
  end)
end

function AIReadingAssistant:onDictButtonsReady(dict_popup, buttons)
    table.insert(buttons, 1, {{
        id = "ai_reading_assistant_dictionary",
        text = _("AI 词典"),
        callback = function()
            local word = dict_popup.word
            local highlight = dict_popup.highlight
            
            -- 这个逻辑之前已经确认成功
            if dict_popup.onClose then
                dict_popup:onClose()
            else
                UIManager:close(dict_popup)
            end
            
            if self.ui and self.ui.onClearSelection then
                self.ui:onClearSelection()
            end

            NetworkMgr:runWhenOnline(function()
                local showAIDictionary = require("ai_dictionary")
                showAIDictionary(self.ui, word, highlight)
            end)
        end,
    }})
end

return AIReadingAssistant
