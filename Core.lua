_G.BINDING_HEADER_NAMECOPY = 'NameCopy Addon'
_G.BINDING_NAME_NAMECOPY_COPY_ITEM = 'Copy item to clipboard'
local db

function _G.NAME_COPY_ITEM()
    if _G.GameTooltip:NumLines() > 0 then
        local text = _G['GameTooltipTextLeft1']:GetText()
        -- local d = {}
        -- d.text = text
        -- _G.StaticPopup_Show('ITEM_NAME_NAMECOPY', '', '', d)
        local e = DEFAULT_CHAT_FRAME.editBox
        ChatEdit_ActivateChat(e)
        e:SetText(text)
        e:HighlightText()
    end
end


local function tooltip_update(self)
    if db and db ~= nil then
        local command, _, _ = _G.GetBindingKey('NAMECOPY')
        if command then
            local tooltipNumLines = _G.GameTooltip:NumLines()
            local tooltipLine = 'Press |cFFFFFF4d' .. command .. '|r to copy the name'
            -- local found = false
            -- for line_count = 1, tooltipNumLines, 1 do
            --     if (_G['GameTooltipTextLeft' .. line_count]:GetText() == tooltipLine) then
            --         found = true
            --         break
            --     end
            -- end
            if tooltipNumLines > 0 then
                if (_G["GameTooltipTextLeft" .. tooltipNumLines]:GetText() ~=
                    tooltipLine) then
                    self:AddLine(tooltipLine, 0.56, 0.75, 0.99, 1)
                    self:Show()
                end
            end
        end
    end
end

local function hook_tooltips()
    local obj = _G.EnumerateFrames()
    while obj do
        if not obj.copyHook then
            if obj:IsObjectType('GameTooltip') then
                obj.copyHook = true
                obj:HookScript('OnUpdate', tooltip_update)
            end
        end
        obj = _G.EnumerateFrames(obj)
    end
end

local function addon_loaded()
    db = _G.NameCopyTooltipTextBool
    if db == nil then
        db = true
    end
    hook_tooltips()
end

--save & remove a binding
local function SafeSetBinding(key, action)
    if key == '' then
        local oldkey = _G.GetBindingKey(action)
        if oldkey then
            _G.SetBinding(oldkey, nil)
        end
    else
        _G.SetBinding(key, action)
    end
    _G.SaveBindings(_G.GetCurrentBindingSet())
end

--set a default binding if no one has it
local function SetDefaultBinding(key, action)
    --get our binding
    local ourkey1, ourkey2 = _G.GetBindingKey(action)
    --if we dont have it
    if (ourkey1 == nil) and (ourkey2 == nil) then
        --get possible action for this binding since CTRL-C or CTRL-SHIFT-C look the same
        local possibleAction = _G.GetBindingByKey(key)
        --by default we could set this binding
        local okToSet = true
        --if any action
        if possibleAction then
            --get the action keys
            local key1, key2 = _G.GetBindingKey(possibleAction)
            --if any key match our key
            if (key1 == key) or (key2 == key) then
                okToSet = false
            end
        end
        --if ok to set
        if okToSet then
            SafeSetBinding(key, action)
        end
    end
end

local function entering_world()
    SetDefaultBinding('CTRL-C', 'NAMECOPY')
end

local function save_variables()
    if db ~= _G.NameCopyTooltipTextBool then
        _G.NameCopyTooltipTextBool = db
    end
end

local frame = _G.CreateFrame('FRAME')
frame:RegisterEvent('ADDON_LOADED')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:RegisterEvent('PLAYER_LEAVING_WORLD')

local function eventHandler(_, event, arg1)
    if event == 'ADDON_LOADED' then
        if arg1 == 'NameCopy' then
            addon_loaded()
        end
    elseif event == 'PLAYER_ENTERING_WORLD' then
        entering_world()
        save_variables()
    elseif event == 'PLAYER_LEAVING_WORLD' then
        save_variables()
    end
end

frame:SetScript('OnEvent', eventHandler)

-- _G.StaticPopupDialogs['ITEM_NAME_NAMECOPY'] = {
--     text = 'Copy the name of the Item/NPC/Object',
--     button1 = 'Close',
--     OnAccept = function()
--     end,
--     timeout = 0,
--     whileDead = true,
--     hideOnEscape = true,
--     preferredIndex = 3,
--     OnShow = function(self, data)
--         self.editBox:SetText(data.text)
--         self.editBox:HighlightText()
--     end,
--     hasEditBox = true
-- }

_G.SLASH_NAMECOPY1 = "/nc"
function _G.SlashCmdList.NAMECOPY(_)
    db = not db
    if db then
        print("|cFF00FF96NameCopy|r will add a line to tooltips")
    else
        print("|cFF00FF96NameCopy|r won't add a line to tooltips anymore")
    end
end
