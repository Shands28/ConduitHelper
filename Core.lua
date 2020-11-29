ConduitHelper = LibStub("AceAddon-3.0"):NewAddon("ConduitHelper", "AceHook-3.0")

local conduitsRanks = {}
local conduits = {}
local conduitNameLast
local conduitType
local conduit

function getConduitType(name)
    if not conduits[name] then
        return
    end
    local conduitData = C_Soulbinds.GetConduitCollectionData(conduits[name].id)
    if not conduitData then
        return
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
    if C_Soulbinds.IsItemConduitByItemInfo(link) then
        local itemName, _, _, itemLevel = GetItemInfo(link)
        tooltip:AddLine("\nRank: " .. conduitsRanks[itemLevel], 0, .75, 1)
        if conduitNameLast ~= itemName then
            conduitType = getConduitType(itemName)
        end
        if not conduitType then
            tooltip:AddLine("Conduit not learned", 0, .35, .75)
            return
        end
        if conduitNameLast ~= itemName then
            conduit = isCounduitKnown(link, conduitType)
        end
        if not conduit then
            return
        end
        if conduit.conduitItemLevel < itemLevel then
            tooltip:AddLine("+" .. (itemLevel - conduit.conduitItemLevel) .. " iLvl", 0, 1, 1)
        else
            tooltip:AddLine("-" .. (itemLevel - conduit.conduitItemLevel) .. " iLvl", 1, 0, 0)
        end
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
        if not itemLevel then
            return
        end
        GameTooltip:AddLine("\nRank: " .. conduitsRanks[itemLevel], 0, .75, 1)
        if conduitNameLast ~= itemName then
            conduitType = getConduitType(itemName)
        end
        if not conduitType then
            GameTooltip:AddLine("Conduit not learned", 0, .35, .75)
            return
        end
        local link = select(2, GetItemInfo(itemID))
        if not link then
            return
        end
        if conduitNameLast ~= itemName then
            conduit = isCounduitKnown(link, conduitType)
        end
        if not conduit then
            return
        end
        if conduit.conduitItemLevel < itemLevel then
            GameTooltip:AddLine("+" .. (itemLevel - conduit.conduitItemLevel) .. " iLvl", 0, 1, 1)
        else
            GameTooltip:AddLine("-" .. (itemLevel - conduit.conduitItemLevel) .. " iLvl", 1, 0, 0)
        end
        conduitNameLast = itemName
        GameTooltip:Show()
    end
end
