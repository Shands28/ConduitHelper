ConduitHelper = LibStub("AceAddon-3.0"):NewAddon("ConduitHelper", "AceHook-3.0")

local conduitsRanks = {}
local conduits = {}
local conduitType
local conduit

function getConduitType(name)
    if not conduits[name] then
        return nil
    end
    local conduitData = C_Soulbinds.GetConduitCollectionData(conduits[name].id)
    if not conduitData then
        return nil
    end
    return conduitData.conduitType
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
    if link and C_Soulbinds.IsItemConduitByItemInfo(link) then
        local itemName, _, _, itemLevel = GetItemInfo(link)
        if not itemName or not itemLevel then
            return
        end
        tooltip:AddLine("Rank: " .. conduitsRanks[itemLevel], 0, .75, 1)
        conduitType = getConduitType(itemName)
        if not conduitType then
            conduitNameLast = itemName
            tooltip:AddLine("Conduit not learned", 0, .35, .75)
            return
        end
        if GameTooltip.conduitNameLast ~= itemName then
            conduit = isCounduitKnown(link, conduitType)
        end
        if not conduit then
            return
        end
        if conduit.conduitItemLevel < itemLevel then
            tooltip:AddLine("+" .. (itemLevel - conduit.conduitItemLevel) .. " iLvl", 0, 1, 1)
        elseif conduit.conduitItemLevel > itemLevel then
            tooltip:AddLine("-" .. (itemLevel - conduit.conduitItemLevel) .. " iLvl", 1, 0, 0)
        end
        GameTooltip.conduitNameLast = itemName
    end
end

function getConduits()
    for i = 1, 282 do
        local x = C_Soulbinds.GetConduitSpellID(i, 1)
        if x ~= 0 then
            local name = GetSpellInfo(x)
            conduits[name] = {name = name, id = i, spellid = x}
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
    getConduits()
    getConduitRanks()
    GameTooltip:HookScript("OnTooltipSetItem", tooltipCheck)
    ConduitHelper:SecureHook("TaskPOI_OnEnter")
end

function ConduitHelper:TaskPOI_OnEnter(self)
    if self and self.questID then
        local itemName, _, _, _, _, itemID, itemLevel = GetQuestLogRewardInfo(1, self.questID)
        if not itemName or not itemID or not itemLevel then
            return
        end
        local link = select(2, GetItemInfo(itemID))
        if not link then
            return
        end
        if not C_Soulbinds.IsItemConduitByItemInfo(link) then
            return
        end
        if not itemLevel then
            return
        end
        conduitType = getConduitType(itemName)
        GameTooltip:AddLine("Rank: " .. conduitsRanks[itemLevel], 0, .75, 1)
        if GameTooltip.conduitNameLast ~= itemName then
            if not conduitType then
                GameTooltip.conduitNameLast = itemName
                GameTooltip:AddLine("Conduit not learned", 0, .35, .75)
                GameTooltip:Show()
                return
            end
            conduit = isCounduitKnown(link, conduitType) or conduit
            if not conduit then
                return
            end
            GameTooltip.conduitNameLast = itemName
        end
        if not conduitType then
            GameTooltip.conduitNameLast = itemName
            GameTooltip:AddLine("Conduit not learned", 0, .35, .75)
            GameTooltip:Show()
            return
        end
        if conduit.conduitItemLevel < itemLevel then
            GameTooltip:AddLine("+" .. (itemLevel - conduit.conduitItemLevel) .. " iLvl", 0, 1, 1)
        elseif conduit.conduitItemLevel > itemLevel then
            GameTooltip:AddLine("-" .. (itemLevel - conduit.conduitItemLevel) .. " iLvl", 1, 0, 0)
        end
        GameTooltip:Show()
    end
end
