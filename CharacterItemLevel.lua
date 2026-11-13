-- Character Item Level
-- Shows the item level at the top-left of each equipped item in the character frame.
-- Can be switched on/off from the AddOns settings page or with /cil.

local addonName = ...

local SLOT_NAMES = {
    "CharacterHeadSlot",
    "CharacterNeckSlot",
    "CharacterShoulderSlot",
    "CharacterBackSlot",
    "CharacterChestSlot",
    "CharacterWristSlot",
    "CharacterHandsSlot",
    "CharacterWaistSlot",
    "CharacterLegsSlot",
    "CharacterFeetSlot",
    "CharacterFinger0Slot",
    "CharacterFinger1Slot",
    "CharacterTrinket0Slot",
    "CharacterTrinket1Slot",
    "CharacterMainHandSlot",
    "CharacterSecondaryHandSlot",
    "CharacterRangedSlot",
}

local labels = {}
local checkbox -- options panel checkbox, created below

local function IsEnabled()
    return not CharacterItemLevelDB or CharacterItemLevelDB.enabled ~= false
end

local function GetLabel(button)
    local label = labels[button]
    if label then
        return label
    end

    label = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    local font, size = NumberFontNormal:GetFont()
    label:SetFont(font, size or 14, "OUTLINE")
    label:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
    label:SetJustifyH("LEFT")
    labels[button] = label
    return label
end

local function GetItemLevel(link)
    local ilvl
    if C_Item and C_Item.GetDetailedItemLevelInfo then
        ilvl = C_Item.GetDetailedItemLevelInfo(link)
    elseif GetDetailedItemLevelInfo then
        ilvl = GetDetailedItemLevelInfo(link)
    end
    if not ilvl then
        ilvl = select(4, GetItemInfo(link))
    end
    return ilvl
end

local function UpdateSlot(button)
    if not button then return end

    local label = GetLabel(button)

    if not IsEnabled() then
        label:Hide()
        return
    end

    local slotID = button:GetID()
    local link = GetInventoryItemLink("player", slotID)
    if not link then
        label:Hide()
        return
    end

    local ilvl = GetItemLevel(link)
    if not ilvl or ilvl <= 0 then
        label:Hide()
        return
    end

    local quality = GetInventoryItemQuality("player", slotID)
    local color = quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
    if color then
        label:SetTextColor(color.r, color.g, color.b)
    else
        label:SetTextColor(1, 1, 1)
    end

    label:SetText(ilvl)
    label:Show()
end

local function UpdateAll()
    for _, name in ipairs(SLOT_NAMES) do
        -- pcall so a client mismatch can never spam errors
        pcall(UpdateSlot, _G[name])
    end
end

local function SetEnabled(value)
    CharacterItemLevelDB.enabled = value and true or false
    if checkbox then
        checkbox:SetChecked(CharacterItemLevelDB.enabled)
    end
    UpdateAll()
end

---------------------------------------------------------------------------
-- Options panel (AddOns settings page)
---------------------------------------------------------------------------

local function CreateOptionsPanel()
    local panel = CreateFrame("Frame")
    panel.name = "Character Item Level"

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Character Item Level")

    local ok, cb = pcall(CreateFrame, "CheckButton", "CharacterItemLevelEnableCheck", panel, "InterfaceOptionsCheckButtonTemplate")
    if not ok then
        cb = CreateFrame("CheckButton", "CharacterItemLevelEnableCheck", panel, "UICheckButtonTemplate")
    end
    cb:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)

    local text = cb.Text or _G["CharacterItemLevelEnableCheckText"]
    if text then
        text:SetText("Show item level on equipped items in the character frame")
    end

    cb:SetScript("OnClick", function(self)
        SetEnabled(self:GetChecked())
    end)
    checkbox = cb

    local function Refresh()
        cb:SetChecked(IsEnabled())
    end
    panel:SetScript("OnShow", Refresh)
    panel.refresh = Refresh -- older Interface Options API

    -- Register with whichever settings system this client has
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
end

---------------------------------------------------------------------------
-- Events and slash command
---------------------------------------------------------------------------

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= addonName then return end
        CharacterItemLevelDB = CharacterItemLevelDB or {}
        if CharacterItemLevelDB.enabled == nil then
            CharacterItemLevelDB.enabled = true
        end
        pcall(CreateOptionsPanel)
        return
    end

    if event == "PLAYER_ENTERING_WORLD" and CharacterFrame and not frame.hooked then
        CharacterFrame:HookScript("OnShow", UpdateAll)
        frame.hooked = true
    end
    UpdateAll()
end)

SLASH_CHARACTERITEMLEVEL1 = "/cil"
SlashCmdList["CHARACTERITEMLEVEL"] = function()
    SetEnabled(not IsEnabled())
    print("Character Item Level: " .. (IsEnabled() and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
end
