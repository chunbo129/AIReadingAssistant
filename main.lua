local Device = require("device")
local InputContainer = require("ui/widget/container/inputcontainer")
local NetworkMgr = require("ui/network/manager")
local _ = require("gettext")
local ChatGPTViewer = require("chatgptviewer")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local Notification = require("ui/widget/notification")

local showChatGPTDialog = require("dialogs")
local UpdateChecker = require("update_checker")
local queryChatGPT = require("gpt_query")

local AskGPT = InputContainer:new {
  name = "askgpt",
  is_doc_only = true,
}

local updateMessageShown = false

function AskGPT:init()
  local success, result = pcall(function() return require("configuration") end)
  local CONFIGURATION
  if success then
    CONFIGURATION = result
  else
    print("configuration.lua not found, using default menu text")
  end

  self.ui.highlight:addToHighlightDialog("askgpt_ChatGPT_Prompt1", function(_reader_highlight_instance)
    return {
      text = CONFIGURATION and CONFIGURATION.menu_text1 or "AI概念解析",
      enabled = true,
      callback = function()
        self:handlePrompt(1, _reader_highlight_instance)
      end,
    }
  end)

  self.ui.highlight:addToHighlightDialog("askgpt_ChatGPT_Prompt2", function(_reader_highlight_instance)
    return {
      text = CONFIGURATION and CONFIGURATION.menu_text2 or "AI翻译",
      enabled = true,
      callback = function()
        self:handlePrompt(2, _reader_highlight_instance)
      end,
    }
  end)

  self.ui.highlight:addToHighlightDialog("askgpt_ChatGPT_Prompt3", function(_reader_highlight_instance)
    return {
      text = CONFIGURATION and CONFIGURATION.menu_text3 or "AI知识扩展",
      enabled = true,
      callback = function()
        self:handlePrompt(3, _reader_highlight_instance)
      end,
    }
  end)

  self.ui.highlight:addToHighlightDialog("askgpt_ChatGPT_Custom", function(_reader_highlight_instance)
    return {
      text = _("Ask AI"),
      enabled = true,
      callback = function()
        self:handleCustomPrompt(_reader_highlight_instance)
      end,
    }
  end)
end

function AskGPT:handleCustomPrompt(_reader_highlight_instance)
  NetworkMgr:runWhenOnline(function()
    if not updateMessageShown then
      UpdateChecker.checkForUpdates()
      updateMessageShown = true
    end
    showChatGPTDialog(self.ui, _reader_highlight_instance.selected_text.text)
  end)
end

function AskGPT:handlePrompt(prompt_number, _reader_highlight_instance)
  NetworkMgr:runWhenOnline(function()
    if not updateMessageShown then
      UpdateChecker.checkForUpdates()
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
      system_prompt = CONFIGURATION and CONFIGURATION.prompt1 or "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly. Answer as concisely as possible."
    elseif prompt_number == 2 then
      system_prompt = CONFIGURATION and CONFIGURATION.prompt2 or "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly. Answer as concisely as possible."
    elseif prompt_number == 3 then
      system_prompt = CONFIGURATION and CONFIGURATION.prompt3 or "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly. Answer as concisely as possible."
    end

    local highlightedText = _reader_highlight_instance.selected_text.text
    local message_history = {
      { role = "system", content = system_prompt },
      { role = "user", content = highlightedText }
    }

    local answer, error_msg
    success, error_msg = pcall(function()
      answer = queryChatGPT(message_history)
    end)

    if success and answer then
      table.insert(message_history, { role = "assistant", content = answer })

      local result_text = ""
      for i = 1, #message_history do
        if message_history[i].role == "user" then
          result_text = result_text .. _("User: ") .. message_history[i].content .. "\n\n"
        else
          result_text = result_text .. _("Assistant: ") .. message_history[i].content .. "\n\n"
        end
      end

      local chatgpt_viewer = ChatGPTViewer:new{
        title = _("AskGPT"),
        text = result_text,
        reader_highlight_instance = _reader_highlight_instance,
        latest_response = answer,  -- Pass the latest GPT response
        onAskQuestion = function(chatgpt_viewer, question)
          table.insert(message_history, { role = "user", content = question })

          local answer, error_msg
          success, error_msg = pcall(function()
            answer = queryChatGPT(message_history)
          end)

          if success and answer then
            table.insert(message_history, { role = "assistant", content = answer })

            local result_text = ""
            for i = 1, #message_history do
              if message_history[i].role == "user" then
                result_text = result_text .. _("User: ") .. message_history[i].content .. "\n\n"
              else
                result_text = result_text .. _("Assistant: ") .. message_history[i].content .. "\n\n"
              end
            end

            chatgpt_viewer:update(result_text, answer)  -- Pass the latest response when updating
          else
            local error_text = error_msg and tostring(error_msg) or "Unknown error occurred"
            UIManager:show(InfoMessage:new{ text = _("Error querying AI: " .. error_text), timeout = 5 })
          end
        end
      }

      UIManager:show(chatgpt_viewer)
    else
      local error_text = error_msg and tostring(error_msg) or "Unknown error occurred"
      UIManager:show(InfoMessage:new{ text = _("Error querying AI: " .. error_text), timeout = 5 })
    end
  end)
end

return AskGPT
