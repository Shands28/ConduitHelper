ConduitHelper = LibStub("AceAddon-3.0"):NewAddon("ConduitHelper", "AceHook-3.0")

local conduitsRanks = {}
local conduits = {}

function getConduitType(name)
    for k, v in pairs(conduits) do
        if v.name == name then
            local conduitData = C_Soulbinds.GetConduitCollectionData(v.id)
            if not conduitData then
                return
            end
            return conduitData.conduitType
        end
    end
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
        local conduitType = getConduitType(itemName)
        if not conduitType then
            tooltip:AddLine("Conduit not learned", 0, .35, .75)
            return
        end
        local conduit = isCounduitKnown(link, conduitType)
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
            conduits[i] = {name = name, id = i, spellid = x}
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
end
