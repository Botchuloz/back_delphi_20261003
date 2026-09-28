--==========================================================================
-- Core_Output_ToggleUI.lua
-- Draggable mini bar + click-to-open picker flyout, styled after
-- ForeverBlessings' assignment window (one shared picker, reused per slot).
-- This is a first testable slice: just the Seal slot, wired to
-- delphi.override.seal (see Class_Paladin.lua / ResolveOverride()). Once
-- proven, the same CreateSlot()/picker plumbing gets reused for Aura,
-- Blessing, Debuff Seal, Role, and Healing.
--==========================================================================

delphi.override = delphi.override or {}
delphi.db = delphi.db or {}
delphi.db.ui = delphi.db.ui or {}

local FLAT = "Interface\\Buttons\\WHITE8x8"

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

--==========================================================================
-- Picker flyout - shared across every slot. Shows one button per choice.
-- Selecting one calls back into on_select(value), then closes.
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
    b.label = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.label:SetPoint("CENTER")
    b.label:SetWordWrap(false)
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
        picker.on_select(self.value)
        HidePicker()
    end)
    picker.buttons[i] = b
    return b
end

-- choices = { {label="Auto", value=0, short="A"}, {label="Seal of Command", value="Seal of Command", short="C"}, ... }
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
        b.label:SetText(choice.short or choice.label)
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

local function CreateSlot(parent, label)
    local s = CreateFrame("Button", nil, parent, "BackdropTemplate")
    s:SetSize(30, 30)
    Skin(s, C.cell, C.border)
    s.label = s:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    s.label:SetPoint("CENTER")
    s.label:SetText(label)
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
    handle.label = handle:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    handle.label:SetPoint("CENTER")
    handle.label:SetText("DEL")

    -- Seal slot: first testable slice, wired to the already-proven
    -- delphi.override.seal / ResolveOverride() mechanic.
    local seal = CreateSlot(mini, "SL")
    seal:SetPoint("LEFT", handle, "RIGHT", 6, 0)
    seal:SetScript("OnClick", function(self)
        ShowPicker(self, {
            {label = "Auto",                 value = 0,     short = "A"},
            {label = "Seal of Righteousness", value = "Seal of Righteousness", short = "R"},
            {label = "Seal of Command",       value = "Seal of Command",       short = "C"},
            {label = "Seal of the Crusader",  value = "Seal of the Crusader",  short = "Cr"},
            {label = "Seal of Fury",          value = "Seal of Fury",          short = "F"},
            {label = "Seal of Justice",       value = "Seal of Justice",       short = "J"},
            {label = "Seal of Light",         value = "Seal of Light",         short = "L"},
            {label = "Seal of Wisdom",        value = "Seal of Wisdom",        short = "W"},
            {label = "Disabled",              value = false, short = "X"},
        }, function(value)
            delphi.override.seal = value
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
