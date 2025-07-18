local api_key = nil
local CONFIGURATION = nil

-- Attempt to load the api_key module. IN A LATER VERSION, THIS WILL BE REMOVED
local success, result = pcall(function() return require("api_key") end)
if success then
  api_key = result.key
else
  print("api_key.lua not found, skipping...")
end

-- Attempt to load the configuration module
success, result = pcall(function() return require("configuration") end)
if success then
  CONFIGURATION = result
else
  print("configuration.lua not found, skipping...")
end

-- Define your queryChatGPT function
local https = require("ssl.https")
local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("json")

local function isGeminiEndpoint(url)
  return url:match("generativelanguage%.googleapis%.com") ~= nil
end

local function formatGeminiRequest(message_history)
  -- Find system prompt and combine user messages
  local systemPrompt = ""
  local userContent = {}
  
  for _, msg in ipairs(message_history) do
    if msg.role == "system" then
      systemPrompt = msg.content
    elseif msg.role == "user" then
      table.insert(userContent, msg.content)
    end
  end

  -- Combine all user content with proper context
  local combinedPrompt = ""
  if systemPrompt ~= "" then
    combinedPrompt = "Instructions: " .. systemPrompt .. "\n\n"
  end
  
  -- Join all user messages with proper context
  combinedPrompt = combinedPrompt .. table.concat(userContent, "\n\nFollow-up: ")

  return {
    contents = {
      {
        parts = {
          { text = combinedPrompt }
        }
      }
    }
  }
end

local function formatOpenAIRequest(message_history, model)
  return {
    model = model,
    messages = message_history
  }
end

local function parseGeminiResponse(response)
  if response.candidates and response.candidates[1] and response.candidates[1].content then
    return response.candidates[1].content.parts[1].text
  end
  error("Invalid Gemini response format: " .. json.encode(response))
end

local function parseOpenAIResponse(response)
  if response.choices and response.choices[1] and response.choices[1].message then
    return response.choices[1].message.content
  end
  error("Invalid OpenAI response format: " .. json.encode(response))
end

local function queryChatGPT(message_history)
  -- Use api_key from CONFIGURATION or fallback to the api_key module
  local api_key_value = CONFIGURATION and CONFIGURATION.api_key or api_key
  local api_url = CONFIGURATION and CONFIGURATION.api_endpoint or "https://api.openai.com/v1/chat/completions"
  local model = CONFIGURATION and CONFIGURATION.model or "gpt-4-mini"

  -- Determine whether to use http or https
  local request_library = api_url:match("^https://") and https or http

  -- Determine if we're using Gemini API
  local isGemini = isGeminiEndpoint(api_url)
  
  -- Format request body based on API type
  local requestBodyTable
  if isGemini then
    requestBodyTable = formatGeminiRequest(message_history)
  else
    requestBodyTable = formatOpenAIRequest(message_history, model)
  end

  -- Encode the request body as JSON
  local requestBody = json.encode(requestBodyTable)

  -- Set up headers based on API type
  local headers = {
    ["Content-Type"] = "application/json",
  }
  
  if isGemini then
    -- For Gemini, append the API key as a URL parameter
    api_url = api_url .. "?key=" .. api_key_value
  else
    -- For OpenAI and compatible APIs, use Bearer token
    headers["Authorization"] = "Bearer " .. api_key_value
  end

  local responseBody = {}

  -- Make the HTTP/HTTPS request
  local res, code, responseHeaders = request_library.request {
    url = api_url,
    method = "POST",
    headers = headers,
    source = ltn12.source.string(requestBody),
    sink = ltn12.sink.table(responseBody),
  }

  if code ~= 200 then
    local errorResponse = table.concat(responseBody)
    error(string.format("Error querying API (Code %d): %s", code, errorResponse))
  end

  local response = json.decode(table.concat(responseBody))
  
  -- Parse response based on API type
  if isGemini then
    return parseGeminiResponse(response)
  else
    return parseOpenAIResponse(response)
  end
end

return queryChatGPT
