--==========================================================================
-- Core_Output_ToggleUI.lua
-- Draggable mini bar + click-to-open picker flyout, styled after
-- ForeverBlessings' assignment window (one shared picker, reused per slot,
-- real spell icons instead of text). AddOverrideSlot() is the reusable
-- piece: give it a delphi.override.<key>, a tooltip label, and a choice
-- list, and it wires up the icon slot + picker + state update. Bar order:
-- handle, Context, Mode, Healing, Role, Aura, Blessing, Seal, Debuff Seal. Slot size (36px) matches ForeverBlessings' mini bar
-- (MINI = 36, "same size as an action button" per its own comment).
--
-- Aura and Blessing also offer an "Inherit (ForeverBlessings)" choice
-- (value "__FB__") that reads your assignment out of the ForeverBlessings
-- addon at cast time - see ForeverBlessings_Aura()/ForeverBlessings_Blessing()
-- in Class_Paladin.lua for the read side. FB_ICON (Spell_Holy_SummonChampion)
-- marks that choice here.
--==========================================================================

delphi.override = delphi.override or {}
if delphi.override.context == nil then delphi.override.context = "pve" end
if delphi.override.role == nil then delphi.override.role = "dps_dd" end
if delphi.override.healing == nil then delphi.override.healing = true end
delphi.db = delphi.db or {}
delphi.db.ui = delphi.db.ui or {}

local FLAT = "Interface\\Buttons\\WHITE8x8"
local AUTO_ICON = 136243 -- Trade_Engineering, used for "Auto" (not a real spell)
local DISABLED_ICON = "Interface\\RaidFrame\\ReadyCheck-NotReady" -- red X, used for "Disabled"
local FB_ICON = 135979 -- Spell_Holy_SummonChampion, used for "Inherit (ForeverBlessings)"
local FB_INHERIT = "__FB__"

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
local CELL, GAP = 36, 6 -- CELL matches ForeverBlessings' mini bar (MINI = 36)
local HANDLEW = 30 -- ForeverBlessings' handle is narrower than its slots too

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
    if type(choices) == "function" then choices = choices() end
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
    s:SetSize(CELL, CELL)
    Skin(s, C.cell, C.border)
    s.icon = s:CreateTexture(nil, "ARTWORK")
    s.icon:SetPoint("TOPLEFT", 2, -2)
    s.icon:SetPoint("BOTTOMRIGHT", -2, 2)
    s.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    s.icon:SetTexture(initialIcon)
    return s
end

-- Reusable slot wiring: key is the delphi.override.<key> this slot edits,
-- tooltipLabel is shown on hover, choices is the picker's option list
-- (see ShowPicker above for the shape). Returns the created slot frame so
-- the next slot can anchor off it.
local function AddOverrideSlot(parent, anchor, key, tooltipLabel, choices, changed)
    local initialIcon = AUTO_ICON
    for _, c in ipairs(type(choices) == "function" and choices() or choices) do
        if c.value == delphi.override[key] then
            initialIcon = c.icon
            break
        end
    end

    local slot = CreateSlot(parent, initialIcon)
    slot:SetPoint("LEFT", anchor, "RIGHT", GAP, 0)

    slot:SetScript("OnClick", function(self)
        ShowPicker(self, choices, function(value, icon)
            delphi.override[key] = value
            self.icon:SetTexture(icon)
            if changed then changed(value) end
        end)
    end)
    slot:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:AddLine(tooltipLabel)
        local v = delphi.override[key]
        if v == false then
            GameTooltip:AddLine("Disabled", 0.8, 0.8, 0.8)
        elseif v == 0 or v == nil then
            GameTooltip:AddLine("Auto", 0.8, 0.8, 0.8)
        elseif v == FB_INHERIT then
            GameTooltip:AddLine("Inherit (ForeverBlessings)", 0.8, 0.8, 0.8)
        else
            GameTooltip:AddLine(tostring(v), 0.8, 0.8, 0.8)
        end
        GameTooltip:Show()
    end)
    slot:SetScript("OnLeave", function() GameTooltip:Hide() end)
    slot.Sync = function(self)
        local list = type(choices) == "function" and choices() or choices
        for _, c in ipairs(list) do
            if c.value == delphi.override[key] then
                self.icon:SetTexture(c.icon)
                return
            end
        end
        self.icon:SetTexture(AUTO_ICON)
    end
    return slot
end

-- Full seal list - used by the Seal (buff-maintenance) slot, where any
-- seal is a valid choice regardless of whether it leaves a debuff.
local SEAL_CHOICES = {
    {label = "Auto",                 value = 0,     icon = AUTO_ICON},
    {label = "Seal of Righteousness", value = "Seal of Righteousness", icon = GetSpellIcon("Seal of Righteousness")},
    {label = "Seal of Command",       value = "Seal of Command",       icon = GetSpellIcon("Seal of Command")},
    {label = "Seal of the Crusader",  value = "Seal of the Crusader",  icon = GetSpellIcon("Seal of the Crusader")},
    {label = "Seal of Fury",          value = "Seal of Fury",          icon = GetSpellIcon("Seal of Fury")},
    {label = "Seal of Justice",       value = "Seal of Justice",       icon = GetSpellIcon("Seal of Justice")},
    {label = "Seal of Light",         value = "Seal of Light",         icon = GetSpellIcon("Seal of Light")},
    {label = "Seal of Wisdom",        value = "Seal of Wisdom",        icon = GetSpellIcon("Seal of Wisdom")},
    {label = "Disabled",              value = false, icon = DISABLED_ICON},
}

-- Debuff-only seal list - used by the Debuff Seal (Judgement twist) slot.
-- Seal of Righteousness and Seal of Command are deliberately excluded:
-- neither leaves a debuff when judged (Righteousness is a flat melee
-- proc, Command is a bonus-damage proc) - they're DPS seals used as part
-- of the normal Judgement rotation, not seals worth twisting for a debuff.
local DEBUFF_SEAL_CHOICES = {
    {label = "Auto",                 value = 0,     icon = AUTO_ICON},
    {label = "Seal of the Crusader",  value = "Seal of the Crusader",  icon = GetSpellIcon("Seal of the Crusader")},
    {label = "Seal of Fury",          value = "Seal of Fury",          icon = GetSpellIcon("Seal of Fury")},
    {label = "Seal of Justice",       value = "Seal of Justice",       icon = GetSpellIcon("Seal of Justice")},
    {label = "Seal of Light",         value = "Seal of Light",         icon = GetSpellIcon("Seal of Light")},
    {label = "Seal of Wisdom",        value = "Seal of Wisdom",        icon = GetSpellIcon("Seal of Wisdom")},
    {label = "Disabled",              value = false, icon = DISABLED_ICON},
}

local CONTEXT_CHOICES = {
    {label="PvE", value="pve", icon=136235},
    {label="PvP", value="pvp", icon=132486},
}
local HEALING_CHOICES = {
    {label="Healing On", value=true, icon=135920},
    {label="Healing Off", value=false, icon=DISABLED_ICON},
}
local ROLE_PVE = {
    {label="Main Tank", value="main_tank", icon=135880},
    {label="Off Tank", value="off_tank", icon=134952},
    {label="DPS DD", value="dps_dd", icon=236304},
    {label="DPS AoE", value="dps_aoe", icon=1387356},
    {label="Role Off", value="off", icon=DISABLED_ICON},
}
local ROLE_PVP = {ROLE_PVE[1], ROLE_PVE[3], ROLE_PVE[4], ROLE_PVE[5]}
local MODE_CHOICES = {
    {label="DD", value="dd", icon=589068},
    {label="AoE", value="aoe", icon=236303},
}
local function RoleChoices()
    return delphi.override.context == "pvp" and ROLE_PVP or ROLE_PVE
end
local function SelectMode(value)
    delphi.runtime.profile = value
    delphi.runtime.changedprofile = GetTime()
    if delphi.override.role == "dps_dd" or delphi.override.role == "dps_aoe" then
        delphi.override.role = value == "aoe" and "dps_aoe" or "dps_dd"
    end
end
local function AddModeSlot(parent, anchor)
    local slot = CreateSlot(parent, MODE_CHOICES[1].icon)
    slot:SetPoint("LEFT", anchor, "RIGHT", GAP, 0)
    slot:SetScript("OnClick", function(self)
        ShowPicker(self, MODE_CHOICES, function(value, icon)
            SelectMode(value)
            self.icon:SetTexture(icon)
        end)
    end)
    slot:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:AddLine("Mode: " .. tostring(delphi.runtime.profile))
        GameTooltip:AddLine("NUMPAD7 DD; NUMPAD8 AoE; NUMPAD9 disables role and healing")
        GameTooltip:Show()
    end)
    slot:SetScript("OnLeave", function() GameTooltip:Hide() end)
    slot.Sync = function(self)
        self.icon:SetTexture(delphi.runtime.profile == "aoe"
            and MODE_CHOICES[2].icon or MODE_CHOICES[1].icon)
    end
    return slot
end

local function CreateMini()
    mini = CreateFrame("Frame", "DelphiToggleBar", UIParent, "BackdropTemplate")
    mini:SetSize(6 + HANDLEW + 8 * (GAP + CELL) + 6, CELL + 27)
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
    handle:SetSize(HANDLEW, CELL)
    handle:SetPoint("LEFT", 6, 0)
    Skin(handle, C.cell, C.gold)
    handle.label = handle:CreateFontString(nil, "OVERLAY")
    handle.label:SetFont(STANDARD_TEXT_FONT, 7, "")
    handle.label:SetPoint("CENTER")
    handle.label:SetText("Delphi")

    local context = AddOverrideSlot(mini, handle, "context", "Context", CONTEXT_CHOICES,
        function(value)
            if value == "pvp" and delphi.override.role == "off_tank" then
                delphi.override.role = "off"
            end
        end)
    local mode = AddModeSlot(mini, context)
    local healing = AddOverrideSlot(mini, mode, "healing", "Healing", HEALING_CHOICES)
    local role = AddOverrideSlot(mini, healing, "role", "Role", RoleChoices,
        function(value)
            if value == "dps_dd" then SelectMode("dd")
            elseif value == "dps_aoe" then SelectMode("aoe") end
        end)
    local aura = AddOverrideSlot(mini, role, "aura", "Aura", {
        {label = "Auto",                    value = 0,     icon = AUTO_ICON},
        {label = "Inherit (ForeverBlessings)", value = FB_INHERIT, icon = FB_ICON},
        {label = "Devotion Aura",           value = "Devotion Aura",           icon = GetSpellIcon("Devotion Aura")},
        {label = "Retribution Aura",        value = "Retribution Aura",        icon = GetSpellIcon("Retribution Aura")},
        {label = "Concentration Aura",      value = "Concentration Aura",      icon = GetSpellIcon("Concentration Aura")},
        {label = "Shadow Resistance Aura",  value = "Shadow Resistance Aura",  icon = GetSpellIcon("Shadow Resistance Aura")},
        {label = "Frost Resistance Aura",   value = "Frost Resistance Aura",   icon = GetSpellIcon("Frost Resistance Aura")},
        {label = "Fire Resistance Aura",    value = "Fire Resistance Aura",    icon = GetSpellIcon("Fire Resistance Aura")},
        {label = "Disabled",                value = false, icon = DISABLED_ICON},
    })

    local blessing = AddOverrideSlot(mini, aura, "blessing", "Blessing", {
        {label = "Auto",                  value = 0,     icon = AUTO_ICON},
        {label = "Inherit (ForeverBlessings)", value = FB_INHERIT, icon = FB_ICON},
        {label = "Blessing of Might",     value = "Blessing of Might",     icon = GetSpellIcon("Blessing of Might")},
        {label = "Blessing of Kings",     value = "Blessing of Kings",     icon = GetSpellIcon("Blessing of Kings")},
        {label = "Blessing of Wisdom",    value = "Blessing of Wisdom",    icon = GetSpellIcon("Blessing of Wisdom")},
        {label = "Blessing of Salvation", value = "Blessing of Salvation", icon = GetSpellIcon("Blessing of Salvation")},
        {label = "Blessing of Sacrifice", value = "Blessing of Sacrifice", icon = GetSpellIcon("Blessing of Sacrifice")},
        {label = "Blessing of Light",     value = "Blessing of Light",     icon = GetSpellIcon("Blessing of Light")},
        {label = "Disabled",              value = false, icon = DISABLED_ICON},
    })

    local seal = AddOverrideSlot(mini, blessing, "seal", "Seal", SEAL_CHOICES)

    local debuffseal = AddOverrideSlot(mini, seal, "debuffseal", "Judgement seal (effect logic deferred)", DEBUFF_SEAL_CHOICES)

    mini.summary = mini:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    mini.summary:SetPoint("BOTTOMLEFT", mini, "BOTTOMLEFT", 8, 4)
    mini.summary:SetJustifyH("LEFT")
    mini:SetScript("OnUpdate", function(self)
        local current = delphi.runtime.profile
        if (delphi.override.role == "dps_dd" or delphi.override.role == "dps_aoe")
            and (current == "dd" or current == "aoe") then
            delphi.override.role = current == "aoe" and "dps_aoe" or "dps_dd"
        end
        if delphi.override.context == "pvp" and delphi.override.role == "off_tank" then
            delphi.override.role = "off"
        end
        context:Sync()
        mode:Sync()
        healing:Sync()
        role:Sync()
        aura:Sync()
        blessing:Sync()
        seal:Sync()
        debuffseal:Sync()
        self.summary:SetText(tostring(delphi.override.context) .. " | "
            .. tostring(current) .. " | Heal "
            .. (delphi.override.healing == false and "Off" or "On")
            .. " | " .. tostring(delphi.override.role))
    end)
    mini:Show()
end

CreateMini()
