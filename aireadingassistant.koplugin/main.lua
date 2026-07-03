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

  if self.ui and self.ui.menu then
    self.ui.menu:registerToMainMenu(self)
  end

  -- 动态生成并绑定最多 5 个菜单项槽
  for i = 1, 5 do
    local key = "aireadingassistant_AI_Prompt" .. i
    self.ui.highlight:addToHighlightDialog(key, function(_reader_highlight_instance)
      local enabled_key = "enabled" .. i
      local text_key = "menu_text" .. i
      local prompt_key = "prompt" .. i

      return {
        text = CONFIGURATION and CONFIGURATION[text_key] or ("AI Prompt " .. i),
        enabled = true,
        show_in_highlight_dialog_func = function()
          if CONFIGURATION and CONFIGURATION[enabled_key] == false then
            return false
          end
          return true
        end,
        callback = function()
          local text = _reader_highlight_instance.selected_text.text
          -- 使用 nextTick 确保 UI 响应
          UIManager:nextTick(function()
              self:handlePrompt(CONFIGURATION and CONFIGURATION[prompt_key], _reader_highlight_instance, text)
          end)
        end,
      }
    end)
  end
end

function AIReadingAssistant:handlePrompt(system_prompt_override, _reader_highlight_instance, captured_text)
  local highlightedText = captured_text or (_reader_highlight_instance.selected_text and _reader_highlight_instance.selected_text.text) or ""
  
  local success, CONFIGURATION = pcall(function() return require("configuration") end)

  if success and CONFIGURATION and CONFIGURATION.auto_expand_to_sentence then
    local success_ctx, prev, next_ctx = pcall(function()
      return _reader_highlight_instance:getSelectedWordContext(50)
    end)
    if success_ctx then
      highlightedText = Utils.expand_to_sentence(highlightedText, prev, next_ctx)
    end
  end

  NetworkMgr:runWhenOnline(function()
    if not updateMessageShown then
      updateMessageShown = true
    end

    local system_prompt = (system_prompt_override or "") .. "\n\n请返回纯文本，不要包含markdown格式符号"

    local message_history = {
      { role = "system", content = system_prompt },
      { role = "user", content = highlightedText }
    }

    ConversationHandler.start(_("AI阅读助手"), message_history, _reader_highlight_instance, {
      onClose = function()
        if _reader_highlight_instance and _reader_highlight_instance.onClose then
          pcall(function()
            _reader_highlight_instance:onClose()
          end)
        end
      end
    }, self.ui, UIManager)
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

function AIReadingAssistant:addToMainMenu(menu_items)
    local CONFIGURATION = require("configuration")
    local SettingsMenu = require("settings_menu")
    local menu = SettingsMenu.getMenu(CONFIGURATION)
    menu.sorting_hint = "more_tools"
    menu_items.aireadingassistant = menu
end

return AIReadingAssistant
