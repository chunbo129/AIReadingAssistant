local UIManager = require("ui/uimanager")
local InfoMessage = require("ui/widget/infomessage")
local _ = require("gettext")
local queryAI = require("ai_query")
local Utils = require("utils") -- Import new Utils module
local ConversationHandler = require("conversation_handler") -- Import new ConversationHandler

local function showAIDictionary(ui, word, highlight_instance)
  local system_prompt = "你是一个强大的AI词典。请为我解释以下单词或短语，提供详细的定义、音标（如果可能）、词性、1-3个带有中文翻译的例句，以及词源。请结合上下文进行解释。请返回不超过250字的纯文本，不要使用markdown格式。"

  local prev_context, next_context = "", ""
  if ui.highlight and ui.highlight.getSelectedWordContext then
    local success, prev, next = pcall(function()
        return ui.highlight:getSelectedWordContext(20) -- Get 20 words of context
    end)
    if success then
        prev_context = prev or ""
        next_context = next or ""
    end
  end

  local context_text = prev_context .. " [" .. word .. "] " .. next_context
  local user_content = "请在以下上下文中解释单词 ‘" .. word .. "’:\n\n" .. context_text

  local message_history = {
    { role = "system", content = system_prompt },
    { role = "user", content = user_content }
  }

  ConversationHandler.start(_("AI 词典"), message_history, highlight_instance, { disable_save_note = true })
end

return showAIDictionary
