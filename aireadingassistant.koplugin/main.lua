local Device = require("device")
local InputContainer = require("ui/widget/container/inputcontainer")
local NetworkMgr = require("ui/network/manager")
local _ = require("gettext")
local AICompanionViewer = require("aicompanionviewer")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local Notification = require("ui/widget/notification")

local showAIDialog = require("dialogs")

local queryAI = require("ai_query")

-- Helper function to normalize whitespace in AI responses
local function normalize_whitespace(text)
  if not text then return "" end
  -- Replace tabs with spaces, then multiple spaces with a single space
  text = text:gsub("\t", " "):gsub(" +", " ")
  -- Trim leading/trailing whitespace
  return text:match("^%s*(.-)%s*$")
end

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
      text = CONFIGURATION and CONFIGURATION.menu_text1 or "AI概念解析",
      enabled = true,
      callback = function()
        self:handlePrompt(1, _reader_highlight_instance)
      end,
    }
  end)

  self.ui.highlight:addToHighlightDialog("aireadingassistant_AI_Prompt2", function(_reader_highlight_instance)
    return {
      text = CONFIGURATION and CONFIGURATION.menu_text2 or "AI翻译",
      enabled = true,
      callback = function()
        self:handlePrompt(2, _reader_highlight_instance)
      end,
    }
  end)

  self.ui.highlight:addToHighlightDialog("aireadingassistant_AI_Prompt3", function(_reader_highlight_instance)
    return {
      text = CONFIGURATION and CONFIGURATION.menu_text3 or "AI知识扩展",
      enabled = true,
      callback = function()
        self:handlePrompt(3, _reader_highlight_instance)
      end,
    }
  end)

  self.ui.highlight:addToHighlightDialog("aireadingassistant_AI_Custom", function(_reader_highlight_instance)
    return {
      text = _("问 AI"),
      enabled = true,
      callback = function()
        self:handleCustomPrompt(_reader_highlight_instance)
      end,
    }
  end)
end

function AIReadingAssistant:handleCustomPrompt(_reader_highlight_instance)
  NetworkMgr:runWhenOnline(function()
    if not updateMessageShown then
      -- UpdateChecker.checkForUpdates()
      updateMessageShown = true
    end
    showAIDialog(self.ui, _reader_highlight_instance.selected_text.text)
  end)
end

function AIReadingAssistant:handlePrompt(prompt_number, _reader_highlight_instance)
  NetworkMgr:runWhenOnline(function()
    if not updateMessageShown then
      -- UpdateChecker.checkForUpdates()
      updateMessageShown = true
    end

    local success, result = pcall(function() return require("configuration") end)
    local CONFIGURATION
    if success then
      CONFIGURATION = result
    else
      print("configuration.lua not found, using default system prompts")
    end
    local system_prompt
    if prompt_number == 1 then
      system_prompt = (CONFIGURATION and CONFIGURATION.prompt1 or "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly. Answer as concisely as possible.") .. "\n\n请返回纯文本，不要包含markdown格式符号"
    elseif prompt_number == 2 then
      system_prompt = (CONFIGURATION and CONFIGURATION.prompt2 or "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly. Answer as concisely as possible.") .. "\n\n请返回纯文本，不要包含markdown格式符号"
    elseif prompt_number == 3 then
      system_prompt = (CONFIGURATION and CONFIGURATION.prompt3 or "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly. Answer as concisely as possible.") .. "\n\n请返回纯文本，不要包含markdown格式符号"
    end

    local highlightedText = _reader_highlight_instance.selected_text.text
    local message_history = {
      { role = "system", content = system_prompt },
      { role = "user", content = highlightedText }
    }

    local answer, error_msg
    success, error_msg = pcall(function()
      return queryAI(message_history)
    end)

    if success and error_msg then
      answer = normalize_whitespace(error_msg)
      table.insert(message_history, { role = "assistant", content = answer })

      local result_text = ""
      for i = 1, #message_history do
        if message_history[i].role == "user" then
          result_text = result_text .. _("原文: ") .. message_history[i].content .. "\n\n"
        elseif message_history[i].role == "assistant" then
          result_text = result_text .. _("AI助手: ") .. message_history[i].content .. "\n\n"
        end
      end

      local aicompanion_viewer = AICompanionViewer:new{
        title = _("AI阅读助手"),
        text = result_text,
        reader_highlight_instance = _reader_highlight_instance,
        latest_response = answer,  -- Pass the latest AI response
        onAskQuestion = function(aicompanion_viewer, question)
          table.insert(message_history, { role = "user", content = question })

          local followup_answer, followup_error
          local followup_success, followup_result = pcall(function()
            return queryAI(message_history)
          end)

          if followup_success and followup_result then
            followup_answer = normalize_whitespace(followup_result)
            table.insert(message_history, { role = "assistant", content = followup_answer })

            local result_text = ""
            for i = 1, #message_history do
              if message_history[i].role == "user" then
                result_text = result_text .. _("原文: ") .. message_history[i].content .. "\n\n"
              elseif message_history[i].role == "assistant" then
                result_text = result_text .. _("AI: ") .. message_history[i].content .. "\n\n"
              end
            end

            aicompanion_viewer:update(result_text, followup_answer)  -- Pass the latest response when updating
          else
            local error_text = followup_result and tostring(followup_result) or "发生未知错误"
            UIManager:show(InfoMessage:new{ text = _("AI 查询出错: " .. error_text), timeout = 5 })
          end
        end
      }

      UIManager:show(aicompanion_viewer)
    else
      local error_text = error_msg and tostring(error_msg) or "发生未知错误"
      UIManager:show(InfoMessage:new{ text = _("AI 查询出错: " .. error_text), timeout = 5 })
    end
  end)
end

return AIReadingAssistant