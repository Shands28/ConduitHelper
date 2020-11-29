ConduitHelper = LibStub("AceAddon-3.0"):NewAddon("ConduitHelper", "AceHook-3.0")

local conduitsRanks = {}

function getConduitType(tooltip)
    local name = tooltip:GetName()
    for i = 1, tooltip:NumLines() do
        local left = _G[name .. "TextLeft" .. i]
        local text = left:GetText() or ""
        if string.match(text, "Finesse") then
            return 0
        elseif string.match(text, "Potency") then
            return 1
        elseif string.match(text, "Endurance") then
            return 2
        elseif string.match(text, "Flex") then
            return 3
        end
    end
    return nil
end

function isCounduitKnown(link, type)
    for _, conduit in pairs(C_Soulbinds.GetConduitCollection(type)) do
        local itemID = GetItemInfoInstant(link)
        if conduit.conduitItemID == itemID then
            return conduit
        end
    end
    return false
end

function tooltipCheck(tooltip)
    local link = select(2, tooltip:GetItem())
    if C_Soulbinds.IsItemConduitByItemInfo(link) then
        local itemLevel = select(4, GetItemInfo(link))
        tooltip:AddLine("\nRank: " .. conduitsRanks[itemLevel], 0, .75, 1)
        local type = getConduitType(tooltip)
        if type then
            local conduit = isCounduitKnown(link, type)
            if conduit then
                if conduit.conduitItemLevel < itemLevel then
                    tooltip:AddLine("+" .. (itemLevel - conduit.conduitItemLevel) .. " iLvl", 0, 1, 1)
                else
                    tooltip:AddLine("-" .. (itemLevel - conduit.conduitItemLevel) .. " iLvl", 1, 0, 0)
                end
            else
                tooltip:AddLine("Conduit not learned", 0, .35, .75)
            end
        end
    end
end

function getConduitRanks()
    for rank = 1, 15 do
        local iLvl = C_Soulbinds.GetConduitItemLevel(60, rank)
        conduitsRanks[rank] = iLvl
        conduitsRanks[iLvl] = rank
    end
end

function ConduitHelper:OnInitialize()
    getConduitRanks()
    GameTooltip:HookScript("OnTooltipSetItem", tooltipCheck)
end
