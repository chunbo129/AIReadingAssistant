local _ = require("gettext")

local Utils = {}

function Utils.normalize_whitespace(text)
  if not text then return "" end
  -- Replace tabs with spaces, then multiple spaces with a single space
  text = text:gsub("\t", " "):gsub(" +", " ")
  -- Trim leading/trailing whitespace
  return text:match("^%s*(.-)%s*$")
end

function Utils.expand_to_sentence(text, prev_context, next_context)
    if not text then return "" end
    prev_context = prev_context or ""
    next_context = next_context or ""
    
    local separators = { "%.", "%?", "%!", "。", "？", "！", "\n" }
    
    -- Find last separator in prev_context
    local last_sep_end = 0
    for _, sep in ipairs(separators) do
        local current = 1
        while true do
            local s, e = prev_context:find(sep, current)
            if not s then break end
            if e > last_sep_end then
                last_sep_end = e
            end
            current = e + 1
        end
    end
    local prefix = prev_context:sub(last_sep_end + 1)
    
    -- Find first separator in next_context
    local first_sep_end = nil
    for _, sep in ipairs(separators) do
        local s, e = next_context:find(sep)
        if s then
            if not first_sep_end or e < first_sep_end then
                first_sep_end = e
            end
        end
    end
    
    local suffix
    if first_sep_end then
        suffix = next_context:sub(1, first_sep_end)
    else
        suffix = next_context
    end
    
    local expanded = prefix .. text .. suffix
    return Utils.normalize_whitespace(expanded)
end

function Utils.createResultText(message_history)
  local result_text = ""
  for i = 1, #message_history do
    if message_history[i].role == "user" then
      result_text = result_text .. _("原文: ") .. message_history[i].content .. "\n\n"
    elseif message_history[i].role == "assistant" then
      result_text = result_text .. _("AI助手: ") .. message_history[i].content .. "\n\n"
    end
  end
  return result_text
end

return Utils
