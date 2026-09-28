--==========================================================================
-- Core_Output_ToggleUI.lua
-- Draggable mini bar + click-to-open picker flyout, styled after
-- ForeverBlessings' assignment window (one shared picker, reused per slot,
-- real spell icons instead of text). This is a first testable slice: just
-- the Seal slot, wired to delphi.override.seal (see Class_Paladin.lua /
-- ResolveOverride()). Once proven, the same CreateSlot()/picker plumbing
-- gets reused for Aura, Blessing, Debuff Seal, Role, and Healing.
--==========================================================================

delphi.override = delphi.override or {}
delphi.db = delphi.db or {}
delphi.db.ui = delphi.db.ui or {}

local FLAT = "Interface\\Buttons\\WHITE8x8"
local AUTO_ICON = 136243 -- Trade_Engineering, used for "Auto" (not a real spell)
local DISABLED_ICON = "Interface\\RaidFrame\\ReadyCheck-NotReady" -- red X, used for "Disabled"

local C = {
    bg     = {0.07, 0.075, 0.09, 0.96},
    cell   = {0.16, 0.165, 0.19, 1},
    border = {0.24, 0.25, 0.29, 1},
    gold   = {0.96, 0.77, 0.31, 1},
}

local function Skin(f, bg, border)
    if not f.SetBackdrop then
        Mixin(f, BackdropTemplateMixin)
    end
    f:SetBackdrop({bgFile = FLAT, edgeFile = FLAT, edgeSize = 1})
    f:SetBackdropColor(unpack(bg or C.cell))
    f:SetBackdropBorderColor(unpack(border or C.border))
end

local function SavePos(frame, key)
    local point, _, rel, x, y = frame:GetPoint()
    delphi.db.ui[key] = {point, rel, x, y}
end

local function RestorePos(frame, key, default)
    local p = delphi.db.ui[key]
    frame:ClearAllPoints()
    if p then
        frame:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else
        frame:SetPoint(unpack(default))
    end
end

-- Looks up a spell's icon by name (same C_Spell.GetSpellInfo API already
-- used by SpellKnown() in Class_Paladin.lua). Falls back to a question-mark
-- icon if the spell can't be resolved, rather than erroring.
local function GetSpellIcon(spellName)
    if C_Spell and C_Spell.GetSpellInfo then
        local ok, info = pcall(C_Spell.GetSpellInfo, spellName)
        if ok and type(info) == "table" and info.iconID then
            return info.iconID
        end
    end
    return 134400
end

--==========================================================================
-- Picker flyout - shared across every slot. Shows one icon button per
-- choice. Selecting one calls back into on_select(value, icon), then closes.
--==========================================================================
local picker
local CELL, GAP = 30, 4

local function HidePicker()
    if picker then picker:Hide() end
end

local function CreatePicker()
    picker = CreateFrame("Frame", "DelphiTogglePicker", UIParent, "BackdropTemplate")
    picker:SetFrameStrata("DIALOG")
    picker:SetClampedToScreen(true)
    Skin(picker, C.bg, C.gold)
    picker.buttons = {}
    picker:Hide()
    picker:SetScript("OnUpdate", function(self, elapsed)
        if self:IsMouseOver() or (self.anchor and self.anchor:IsMouseOver()) then
            self.idle = 0
        else
            self.idle = (self.idle or 0) + elapsed
            if self.idle > 1.2 then
                self:Hide()
            end
        end
    end)
    table.insert(UISpecialFrames, "DelphiTogglePicker")
end

local function PickerButton(i)
    local b = picker.buttons[i]
    if b then return b end
    b = CreateFrame("Button", nil, picker, "BackdropTemplate")
    b:SetSize(CELL, CELL)
    Skin(b, C.cell, C.border)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("TOPLEFT", 2, -2)
    b.icon:SetPoint("BOTTOMRIGHT", -2, 2)
    b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    b:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(C.gold))
        if self.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine(self.tooltip)
            GameTooltip:Show()
        end
        picker.idle = 0
    end)
    b:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(C.border))
        GameTooltip:Hide()
    end)
    b:SetScript("OnClick", function(self)
        picker.on_select(self.value, self.icon_tex)
        HidePicker()
    end)
    picker.buttons[i] = b
    return b
end

-- choices = { {label="Auto", value=0, icon=AUTO_ICON}, {label="Seal of Command", value="Seal of Command", icon=1234}, ... }
-- on_select receives (value, icon) so the calling slot can update its own displayed icon.
local function ShowPicker(cell, choices, on_select)
    if not picker then CreatePicker() end
    if picker:IsShown() and picker.anchor == cell then
        HidePicker()
        return
    end
    picker.anchor = cell
    picker.on_select = on_select

    for i, choice in ipairs(choices) do
        local b = PickerButton(i)
        b.value = choice.value
        b.icon_tex = choice.icon
        b.icon:SetTexture(choice.icon)
        b.tooltip = choice.label
        b:ClearAllPoints()
        b:SetPoint("LEFT", picker, "LEFT", 6 + (i - 1) * (CELL + GAP), 0)
        b:Show()
    end
    for i = #choices + 1, #picker.buttons do
        picker.buttons[i]:Hide()
    end

    picker:SetSize(12 + #choices * (CELL + GAP) - GAP, CELL + 12)
    picker:ClearAllPoints()
    picker:SetPoint("TOPLEFT", cell, "BOTTOMLEFT", -6, -4)
    picker.idle = 0
    picker:Show()
end

--==========================================================================
-- Mini bar
--==========================================================================
local mini

local function CreateSlot(parent, initialIcon)
    local s = CreateFrame("Button", nil, parent, "BackdropTemplate")
    s:SetSize(30, 30)
    Skin(s, C.cell, C.border)
    s.icon = s:CreateTexture(nil, "ARTWORK")
    s.icon:SetPoint("TOPLEFT", 2, -2)
    s.icon:SetPoint("BOTTOMRIGHT", -2, 2)
    s.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    s.icon:SetTexture(initialIcon)
    return s
end

local function CreateMini()
    mini = CreateFrame("Frame", "DelphiToggleBar", UIParent, "BackdropTemplate")
    mini:SetSize(120, 42)
    mini:SetClampedToScreen(true)
    mini:SetMovable(true)
    mini:EnableMouse(true)
    mini:RegisterForDrag("LeftButton")
    mini:SetScript("OnDragStart", mini.StartMoving)
    mini:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePos(self, "miniPos")
    end)
    Skin(mini, C.bg, C.border)
    RestorePos(mini, "miniPos", {"TOP", UIParent, "TOP", 0, -140})

    local handle = CreateFrame("Button", nil, mini, "BackdropTemplate")
    handle:SetSize(30, 30)
    handle:SetPoint("LEFT", 6, 0)
    Skin(handle, C.cell, C.gold)
    handle.label = handle:CreateFontString(nil, "OVERLAY")
    handle.label:SetFont(STANDARD_TEXT_FONT, 7, "")
    handle.label:SetPoint("CENTER")
    handle.label:SetText("Delphi")

    -- Seal slot: first testable slice, wired to the already-proven
    -- delphi.override.seal / ResolveOverride() mechanic. Starts on the
    -- Auto icon since delphi.override.seal defaults to 0 at load.
    local seal = CreateSlot(mini, AUTO_ICON)
    seal:SetPoint("LEFT", handle, "RIGHT", 6, 0)
    seal:SetScript("OnClick", function(self)
        ShowPicker(self, {
            {label = "Auto",                 value = 0,     icon = AUTO_ICON},
            {label = "Seal of Righteousness", value = "Seal of Righteousness", icon = GetSpellIcon("Seal of Righteousness")},
            {label = "Seal of Command",       value = "Seal of Command",       icon = GetSpellIcon("Seal of Command")},
            {label = "Seal of the Crusader",  value = "Seal of the Crusader",  icon = GetSpellIcon("Seal of the Crusader")},
            {label = "Seal of Fury",          value = "Seal of Fury",          icon = GetSpellIcon("Seal of Fury")},
            {label = "Seal of Justice",       value = "Seal of Justice",       icon = GetSpellIcon("Seal of Justice")},
            {label = "Seal of Light",         value = "Seal of Light",         icon = GetSpellIcon("Seal of Light")},
            {label = "Seal of Wisdom",        value = "Seal of Wisdom",        icon = GetSpellIcon("Seal of Wisdom")},
            {label = "Disabled",              value = false, icon = DISABLED_ICON},
        }, function(value, icon)
            delphi.override.seal = value
            self.icon:SetTexture(icon)
        end)
    end)
    seal:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:AddLine("Seal")
        local v = delphi.override.seal
        if v == false then
            GameTooltip:AddLine("Disabled", 0.8, 0.8, 0.8)
        elseif v == 0 or v == nil then
            GameTooltip:AddLine("Auto", 0.8, 0.8, 0.8)
        else
            GameTooltip:AddLine(tostring(v), 0.8, 0.8, 0.8)
        end
        GameTooltip:Show()
    end)
    seal:SetScript("OnLeave", function() GameTooltip:Hide() end)

    mini:Show()
end

CreateMini()
