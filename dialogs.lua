local InputDialog = require("ui/widget/inputdialog")
local ChatGPTViewer = require("chatgptviewer")
local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local _ = require("gettext")

local queryChatGPT = require("gpt_query")

-- Helper function to normalize whitespace in AI responses
local function normalize_whitespace(text)
  if not text then return "" end
  -- Replace tabs with spaces, then multiple spaces with a single space
  text = text:gsub("\t", " "):gsub(" +", " ")
  -- Trim leading/trailing whitespace
  return text:match("^%s*(.-)%s*$")
end

local CONFIGURATION = nil
local buttons, input_dialog

local success, result = pcall(function() return require("configuration") end)
if success then
  CONFIGURATION = result
else
  print("configuration.lua not found, skipping...")
end

local function translateText(text, target_language)
  local translation_message = {
    role = "user",
    content = "Translate the following text to " .. target_language .. ": " .. text
  }
  local translation_history = {
    {
      role = "system",
      content = "You are a helpful translation assistant. Provide direct translations without additional commentary."
    },
    translation_message
  }
  local answer = queryChatGPT(translation_history)
  return normalize_whitespace(answer)
end

local function createResultText(message_history)
  local result_text = ""
  for i = 1, #message_history do
    if message_history[i].role == "user" then
      result_text = result_text .. _("User: ") .. message_history[i].content .. "\n\n"
    elseif message_history[i].role == "assistant" then
      result_text = result_text .. _("ChatGPT: ") .. message_history[i].content .. "\n\n"
    end
  end

  return result_text
end

local function showLoadingDialog()
  local loading = InfoMessage:new{
    text = _("Loading..."),
    timeout = 0.1
  }
  UIManager:show(loading)
end

local function showChatGPTDialog(ui, highlightedText, message_history)
  local title, author =
    ui.document:getProps().title or _("Unknown Title"),
    ui.document:getProps().authors or _("Unknown Author")
  local message_history = message_history or {{
    role = "system",
    content = "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly. Answer as concisely as possible.\n\n请返回纯文本，不要包含markdown格式符号"
  }}

  local function handleNewQuestion(chatgpt_viewer, question)
    table.insert(message_history, {
      role = "user",
      content = question
    })

    local answer = normalize_whitespace(queryChatGPT(message_history))

    table.insert(message_history, {
      role = "assistant",
      content = answer
    })

    local result_text = createResultText(message_history)

    chatgpt_viewer:update(result_text)
  end

  buttons = {
    {
      text = _("Cancel"),
      callback = function()
        UIManager:close(input_dialog)
      end
    },
    {
      text = _("Ask"),
      callback = function()
        local question = input_dialog:getInputText()
        UIManager:close(input_dialog)
        showLoadingDialog()

        UIManager:scheduleIn(0.1, function()
          local context_message = {
            role = "user",
            content = "I'm reading something titled '" .. title .. "' by " .. author ..
              ". I have a question about the following highlighted text: " .. highlightedText
          }
          table.insert(message_history, context_message)

          local question_message = {
            role = "user",
            content = question
          }
          table.insert(message_history, question_message)

          local answer = normalize_whitespace(queryChatGPT(message_history))
          local answer_message = {
            role = "assistant",
            content = answer
          }
          table.insert(message_history, answer_message)

          local result_text = createResultText(message_history)

          local chatgpt_viewer = ChatGPTViewer:new {
            title = _("AI伴读"),
            text = result_text,
            onAskQuestion = handleNewQuestion
          }

          UIManager:show(chatgpt_viewer)
        end)
      end
    }
  }

  if CONFIGURATION and CONFIGURATION.features and CONFIGURATION.features.translate_to then
    table.insert(buttons, {
      text = _("Translate"),
      callback = function()
        showLoadingDialog()

        UIManager:scheduleIn(0.1, function()
          local translated_text = translateText(highlightedText, CONFIGURATION.features.translate_to)

          table.insert(message_history, {
            role = "user",
            content = "Translate to " .. CONFIGURATION.features.translate_to .. ": " .. highlightedText
          })

          table.insert(message_history, {
            role = "assistant",
            content = translated_text
          })

          local result_text = createResultText(message_history)
          local chatgpt_viewer = ChatGPTViewer:new {
            title = _("Translation"),
            text = result_text,
            onAskQuestion = handleNewQuestion
          }

          UIManager:show(chatgpt_viewer)
        end)
      end
    })
  end

  input_dialog = InputDialog:new{
    title = _("Ask a question about the highlighted text"),
    input_hint = _("Type your question here..."),
    input_type = "text",
    buttons = {buttons}
  }
  UIManager:show(input_dialog)
end

return showChatGPTDialog
