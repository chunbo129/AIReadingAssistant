-- 终极方案：后期注入+拦截添加+全量ID覆盖
local ReaderHighlight = require("apps/reader/modules/readerhighlight")
local orig_ReaderHighlight_init = ReaderHighlight.init
local orig_addToHighlightDialog = ReaderHighlight.addToHighlightDialog
local UIManager = require("ui/uimanager")

-- 1. 拦截添加：防止插件或延迟加载项重新添加
ReaderHighlight.addToHighlightDialog = function(self, id, callback)
    if id then
        local lower_id = id:lower()
        if lower_id:find("wiki") or lower_id:find("encyclopedia") or
           lower_id:find("html") or lower_id:find("source") or lower_id:find("code") or
           lower_id:find("note") or lower_id:find("share") then
            return -- 拦截，不添加
        end
    end
    return orig_addToHighlightDialog(self, id, callback)
end

ReaderHighlight.init = function(self)
    orig_ReaderHighlight_init(self)  -- 执行官方初始化
    
    -- 2. 清理已存在的：等UI完全加载后（延迟0.5秒）再删除
    UIManager:scheduleIn(0.5, function()
        -- 遍历所有菜单项，通过关键词模糊匹配删除
        if self.highlight_dialog_items then
            for id, _ in pairs(self.highlight_dialog_items) do
                local lower_id = id:lower()
                
                -- 1. 维基百科
                if lower_id:find("wiki") or lower_id:find("encyclopedia") then
                    self:removeFromHighlightDialog(id)
                -- 2. 查看HTML
                elseif lower_id:find("html") or lower_id:find("source") or lower_id:find("code") then
                    self:removeFromHighlightDialog(id)
                -- 3. 添加笔记
                elseif lower_id:find("note") then
                    self:removeFromHighlightDialog(id)
                -- 4. 分享文本
                elseif lower_id:find("share") then
                    self:removeFromHighlightDialog(id)
                end
            end
        end

        -- 保留明确的ID删除作为备份
        local ids_to_remove = {
            "05_wikipedia", "wiki", "encyclopedia",
            "share_text", "share", "10_share", "qrcode",
            "view_html", "08_view_html", "view_source",
            "edit_note", "09_note", "note", "add_note", "create_note"
        }
        for _, id in ipairs(ids_to_remove) do
             self:removeFromHighlightDialog(id)
        end
        
        -- 用户提到的其他需要删除的项 (如果需要恢复，请注释掉)
        self:removeFromHighlightDialog("06_dictionary")
        self:removeFromHighlightDialog("dictionary")
        self:removeFromHighlightDialog("07_translate")
        self:removeFromHighlightDialog("translate")
        self:removeFromHighlightDialog("12_search")
        self:removeFromHighlightDialog("search")
    end)
end