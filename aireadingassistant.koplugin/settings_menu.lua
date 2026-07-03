local _ = require("gettext")
local UIManager = require("ui/uimanager")
local InputDialog = require("ui/widget/inputdialog")
local InfoMessage = require("ui/widget/infomessage")
local PRESETS = require("presets")

local SettingsMenu = {}

function SettingsMenu.getMenu(CONFIGURATION, on_change_callback)
  -- Helper to save changes and refresh touchmenu
  local function save_and_notify(updates, touchmenu)
    CONFIGURATION:update(updates)
    if on_change_callback then
      on_change_callback(touchmenu)
    end
    UIManager:show(InfoMessage:new{ text = _("设置已保存"), timeout = 1 })
    if touchmenu and touchmenu.updateItems then
      touchmenu:updateItems()
    end
  end

  -- Main menu structure
  local menu = {
    text = _("AI 阅读助手设置"),
    sub_item_table = {
      {
        text = _("划词常用菜单管理"),
        sub_item_table = (function()
          local sub = {}
          for i = 1, 5 do
            local enabled_key = "enabled" .. i
            local text_key = "menu_text" .. i
            local prompt_key = "prompt" .. i

            table.insert(sub, {
              text_func = function()
                local name = CONFIGURATION[text_key] or ("Prompt " .. i)
                local is_enabled = CONFIGURATION[enabled_key]
                if is_enabled == nil then is_enabled = true end
                return name .. (is_enabled and "" or " (" .. _("已禁用") .. ")")
              end,
              sub_item_table = {
                {
                  text_func = function()
                    local is_enabled = CONFIGURATION[enabled_key]
                    if is_enabled == nil then is_enabled = true end
                    return _("启用该菜单: ") .. (is_enabled and _("开启") or _("关闭"))
                  end,
                  checked_func = function()
                    local is_enabled = CONFIGURATION[enabled_key]
                    if is_enabled == nil then is_enabled = true end
                    return is_enabled
                  end,
                  keep_menu_open = true,
                  callback = function(touchmenu)
                    local is_enabled = CONFIGURATION[enabled_key]
                    if is_enabled == nil then is_enabled = true end
                    local updates = {}
                    updates[enabled_key] = not is_enabled
                    save_and_notify(updates, touchmenu)
                  end,
                },
                {
                  text_func = function()
                    return _("菜单名称: ") .. (CONFIGURATION[text_key] or "")
                  end,
                  callback = function(touchmenu)
                    local input_dialog
                    input_dialog = InputDialog:new {
                      title = _("修改菜单名称"),
                      input = CONFIGURATION[text_key] or "",
                      input_type = "text",
                      buttons = {
                        {
                          {
                            text = _("取消"),
                            callback = function()
                              UIManager:close(input_dialog)
                            end,
                          },
                          {
                            text = _("保存"),
                            is_enter_default = true,
                            callback = function()
                              local name = input_dialog:getInputText()
                              local updates = {}
                              updates[text_key] = name
                              save_and_notify(updates, touchmenu)
                              UIManager:close(input_dialog)
                            end,
                          },
                        },
                      },
                    }
                    UIManager:show(input_dialog)
                    input_dialog:onShowKeyboard()
                  end,
                },
                {
                  text_func = function()
                    local val = CONFIGURATION[prompt_key] or ""
                    if #val > 30 then
                      val = val:sub(1, 30) .. "..."
                    end
                    return _("Prompt 内容: ") .. val
                  end,
                  callback = function(touchmenu)
                    local input_dialog
                    input_dialog = InputDialog:new {
                      title = _("修改 Prompt 内容"),
                      input = CONFIGURATION[prompt_key] or "",
                      input_type = "text",
                      buttons = {
                        {
                          {
                            text = _("取消"),
                            callback = function()
                              UIManager:close(input_dialog)
                            end,
                          },
                          {
                            text = _("保存"),
                            is_enter_default = true,
                            callback = function()
                              local pr = input_dialog:getInputText()
                              local updates = {}
                              updates[prompt_key] = pr
                              save_and_notify(updates, touchmenu)
                              UIManager:close(input_dialog)
                            end,
                          },
                        },
                      },
                    }
                    UIManager:show(input_dialog)
                    input_dialog:onShowKeyboard()
                  end,
                }
              }
            })
          end
          return sub
        end)(),
      },
      {
        separator = true,
      },
      {
        text_func = function()
          local provider = CONFIGURATION.current_provider or "DeepSeek (官方)"
          return _("API 服务商: ") .. provider
        end,
        sub_item_table = (function()
          local sub = {}
          for _, preset in ipairs(PRESETS) do
            table.insert(sub, {
              text = preset.name,
              checked_func = function()
                return CONFIGURATION.current_provider == preset.name
              end,
              keep_menu_open = true,
              callback = function(touchmenu)
                save_and_notify({
                  current_provider = preset.name
                }, touchmenu)
              end,
            })
          end
          return sub
        end)(),
      },
      {
        text_func = function()
          local provider = CONFIGURATION.current_provider or "DeepSeek (官方)"
          local key = CONFIGURATION.provider_keys and CONFIGURATION.provider_keys[provider] or ""
          -- Fallback to global key if not set
          if key == "" and CONFIGURATION.api_key then
            key = CONFIGURATION.api_key
          end
          return _("API 密钥 (API Key): ") .. (key ~= "" and "已设置" or "未设置")
        end,
        callback = function(touchmenu)
          local provider = CONFIGURATION.current_provider or "DeepSeek (官方)"
          local current_key = CONFIGURATION.provider_keys and CONFIGURATION.provider_keys[provider] or ""
          local input_dialog
          input_dialog = InputDialog:new {
            title = _("输入 ") .. provider .. _(" API Key"),
            input = current_key,
            input_type = "text",
            buttons = {
              {
                {
                  text = _("取消"),
                  callback = function()
                    UIManager:close(input_dialog)
                  end,
                },
                {
                  text = _("保存"),
                  is_enter_default = true,
                  callback = function()
                    local key = input_dialog:getInputText()
                    local pk = CONFIGURATION.provider_keys or {}
                    pk[provider] = key
                    save_and_notify({ provider_keys = pk }, touchmenu)
                    UIManager:close(input_dialog)
                  end,
                },
              },
            },
          }
          UIManager:show(input_dialog)
          input_dialog:onShowKeyboard()
        end,
      },
      {
        text_func = function()
          local provider = CONFIGURATION.current_provider or "DeepSeek (官方)"
          local model_name = CONFIGURATION.provider_models and CONFIGURATION.provider_models[provider] or ""
          if model_name == "custom-model" and CONFIGURATION.model then
            model_name = CONFIGURATION.model
          end
          return _("当前模型: ") .. model_name
        end,
        sub_item_table = {}, -- Will populate dynamically in rebuild_models_submenu
      },
      {
        text_func = function()
          local endpoint = CONFIGURATION.custom_endpoint or ""
          if endpoint == "" and CONFIGURATION.api_endpoint then
            endpoint = CONFIGURATION.api_endpoint
          end
          return _("API 终点地址 (Endpoint): ") .. endpoint
        end,
        enabled_func = function()
          return CONFIGURATION.current_provider == "自定义"
        end,
        callback = function(touchmenu)
          local input_dialog
          input_dialog = InputDialog:new {
            title = _("修改自定义 API Endpoint"),
            input = CONFIGURATION.custom_endpoint or "",
            input_type = "text",
            buttons = {
              {
                {
                  text = _("取消"),
                  callback = function()
                    UIManager:close(input_dialog)
                  end,
                },
                {
                  text = _("保存"),
                  is_enter_default = true,
                  callback = function()
                    local endpoint = input_dialog:getInputText()
                    save_and_notify({ custom_endpoint = endpoint }, touchmenu)
                    UIManager:close(input_dialog)
                  end,
                },
              },
            },
          }
          UIManager:show(input_dialog)
          input_dialog:onShowKeyboard()
        end,
      },
      {
        separator = true,
      },
      {
        text_func = function()
          return _("自动扩展整句: ") .. (CONFIGURATION.auto_expand_to_sentence and _("开启") or _("关闭"))
        end,
        checked_func = function()
          return CONFIGURATION.auto_expand_to_sentence
        end,
        keep_menu_open = true,
        callback = function(touchmenu)
          save_and_notify({ auto_expand_to_sentence = not CONFIGURATION.auto_expand_to_sentence }, touchmenu)
        end,
      },
      {
        text_func = function()
          return _("AI 响应最大行数: ") .. (CONFIGURATION.max_ai_response_lines or 0)
        end,
        callback = function(touchmenu)
          local input_dialog
          input_dialog = InputDialog:new {
            title = _("最大显示行数 (0表示不限制)"),
            input = tostring(CONFIGURATION.max_ai_response_lines or 0),
            input_type = "number",
            buttons = {
              {
                {
                  text = _("取消"),
                  callback = function()
                    UIManager:close(input_dialog)
                  end,
                },
                {
                  text = _("保存"),
                  is_enter_default = true,
                  callback = function()
                    local val = tonumber(input_dialog:getInputText()) or 0
                    save_and_notify({ max_ai_response_lines = val }, touchmenu)
                    UIManager:close(input_dialog)
                  end,
                },
              },
            },
          }
          UIManager:show(input_dialog)
          input_dialog:onShowKeyboard()
        end,
      }
    }
  }

  -- Rebuild model list dynamically. Mutates the table in-place to preserve references.
  local models_menu = menu.sub_item_table[5] -- index is 5
  local function rebuild_models_submenu(touchmenu)
    local provider = CONFIGURATION.current_provider or "DeepSeek (官方)"
    local preset_models = {}
    for _, preset in ipairs(PRESETS) do
      if preset.name == provider then
        preset_models = preset.models
        break
      end
    end
    
    -- Clear current table elements (preserving reference)
    for k in pairs(models_menu.sub_item_table) do
      models_menu.sub_item_table[k] = nil
    end

    -- Insert updated preset models
    for _, model_name in ipairs(preset_models) do
      table.insert(models_menu.sub_item_table, {
        text = model_name,
        checked_func = function()
          return CONFIGURATION.provider_models and CONFIGURATION.provider_models[provider] == model_name
        end,
        keep_menu_open = true,
        callback = function(tm)
          local pm = CONFIGURATION.provider_models or {}
          pm[provider] = model_name
          save_and_notify({ provider_models = pm }, tm)
        end,
      })
    end

    -- Add Custom... option at the end
    table.insert(models_menu.sub_item_table, {
      text = _("自定义模型名称..."),
      callback = function(tm)
        local current_model = CONFIGURATION.provider_models and CONFIGURATION.provider_models[provider] or ""
        if current_model == "custom-model" and CONFIGURATION.model then
          current_model = CONFIGURATION.model
        end
        local input_dialog
        input_dialog = InputDialog:new {
          title = _("输入模型名称"),
          input = current_model,
          input_type = "text",
          buttons = {
            {
              {
                text = _("取消"),
                callback = function()
                  UIManager:close(input_dialog)
                end,
              },
              {
                text = _("保存"),
                is_enter_default = true,
                callback = function()
                  local model = input_dialog:getInputText()
                  local pm = CONFIGURATION.provider_models or {}
                  pm[provider] = model
                  save_and_notify({ provider_models = pm }, tm)
                  UIManager:close(input_dialog)
                end,
              },
            },
          },
        }
        UIManager:show(input_dialog)
        input_dialog:onShowKeyboard()
      end,
    })

    if touchmenu and touchmenu.updateItems then
      touchmenu:updateItems()
    end
  end

  rebuild_models_submenu()
  
  -- Hook into settings update to rebuild models list and pass touchmenu down
  local original_on_change = on_change_callback
  on_change_callback = function(touchmenu)
    rebuild_models_submenu(touchmenu)
    if original_on_change then
      original_on_change(touchmenu)
    end
  end

  return menu
end

return SettingsMenu
