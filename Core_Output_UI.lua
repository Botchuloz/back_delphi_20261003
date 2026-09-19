local _icons = {}

function CreateNewStatusIcon(icon_name,x,y,delegate)
    local _icon = {}

    _icon.pixel = CreateFrame("Frame", nil, UIParent)
    --[[dragonflight day zero]]
    --_icon.pixel:SetFrameStrata ("TOOLTIP")
    _icon.pixel:SetFrameStrata ("TOOLTIP")
    --[[/dragonflight day zero]]
    _icon.pixel:SetWidth (30)
    _icon.pixel:SetHeight (30)
    --[[dragonflight day zero]]
    _icon.colour = _icon.pixel:CreateTexture (nil, "OVERLAY")
    --[[/dragonflight day zero]]
    _icon.colour:SetColorTexture (0, 0, 0)
    _icon.colour:SetAllPoints (_icon.pixel)

    _icon.pixel.texture = _icon.colour 
    _icon.pixel:SetPoint ("CENTER", x, y) 
    _icon.pixel:Show ()
    --[[dragonflight day zero]]
    --_icon.label = _icon.pixel:CreateFontString("test","TOOLTIP","GameFontNormal")
    _icon.label = _icon.pixel:CreateFontString("test","OVERLAY","GameFontNormal")
    --[[/dragonflight day zero]]
    _icon.label:SetPoint("CENTER",0,-25)
    _icon.label:SetText(icon_name)
    --_icon.label:SetTextHeight(8)

    _icon.delegate = delegate   

    _icon.display_text = icon_name

    _icons[icon_name] = _icon
    return _icon
end


function CreateNewLabel(icon_name,x,y,delegate)
    local _icon = {}
    --base icon object
    _icon.pixel = CreateFrame("Frame", nil, UIParent)
    --[[dragonflight day zero]]
    --_icon.pixel:SetFrameStrata ("TOOLTIP")
    _icon.pixel:SetFrameStrata ("TOOLTIP")
    --[[/dragonflight day zero]]
    _icon.pixel:SetWidth (1)
    _icon.pixel:SetHeight (1)
    _icon.pixel:SetPoint ("CENTER", x, y) 
    _icon.pixel:Show ()
    --label
    --[[dragonflight day zero]]
    --_icon.label = _icon.pixel:CreateFontString("test","TOOLTIP","GameFontNormal")
    _icon.label = _icon.pixel:CreateFontString("test","OVERLAY","GameFontNormal")
    --[[/dragonflight day zero]]
    _icon.label:SetPoint("CENTER",0,-25)
    _icon.label:SetText(icon_name)
    --meta
    _icon.delegate = delegate   
    _icon.display_text = icon_name
    --push back
    _icons[icon_name] = _icon
    return _icon
end

-- this is where you change the colour, R G B
-- v.colour:SetColorTexture (0, colour, 0) 
-- 0 = black, 1 = 100% aka 255
function UpdateStatusIcons()
    for k,v in pairs(_icons) do
        --print(k,v)
        local colour,text = v.delegate()
        if v.colour then
            v.colour:SetColorTexture (0, colour, 0) -- 1 = 100% aka 255
        end
        v.label:SetText(text)
    end
end

function CreateIconAndButton(button_name,x,y,initial_label,max_state,optional_delegate_override)
    local max_float = max_state - 1.0
    CreateNewStatusIcon(button_name,x,y,optional_delegate_override or function() return (delphi.ui.icon[button_name].value or 0.0)/max_float,delphi.ui.icon[button_name].display_text end)
    CreateButton(button_name,button_name,"/run local current_state = delphi.ui.icon['"..button_name.."'].value or 0.0; local max_float = "..max_float.."; if current_state >= max_float then  delphi.ui.icon['"..button_name.."'].value = 0; print('reset state') else delphi.ui.icon['"..button_name.."'].value = current_state + 1 end;")
    _icons[button_name].display_text = initial_label
end


function TriStateCheck(setting,label0,label1,label2)
    local setting_state = delphi.ui.icon[setting].value or 0
    local state_0  = false
    local state_1  = false
    local state_2  = false

    if(setting_state == 0)then -- do we allow moves that cleave *at all* to be cast? (ie, permit/prevent WW)
        delphi.ui.icon[setting].display_text = label0
        state_0  = true
        state_1  = false
        state_2  = false
    elseif(setting_state == 1)then -- do we allow moves that cleave *at all* to be cast? (ie, permit/prevent WW)
        delphi.ui.icon[setting].display_text = label1
        state_0  = false
        state_1  = true
        state_2  = false
    elseif(setting_state == 2)then -- do we allow moves that cleave *at all* to be cast? (ie, permit/prevent WW)
        delphi.ui.icon[setting].display_text = label2
        state_0  = false
        state_1  = false
        state_2  = true
    else
        delphi.ui.icon[setting].display_text = "???"
        print(setting_state)
    end  
    return state_0, state_1, state_2
end

function BiStateCheck(setting,label0,label1)
    local setting_state = delphi.ui.icon[setting].value or 0
    local state_0  = false
    local state_1  = false

    if(setting_state == 0)then -- do we allow moves that cleave *at all* to be cast? (ie, permit/prevent WW)
        delphi.ui.icon[setting].display_text = label0
        state_0  = true
        state_1  = false
    elseif(setting_state == 1)then -- do we allow moves that cleave *at all* to be cast? (ie, permit/prevent WW)
        delphi.ui.icon[setting].display_text = label1
        state_0  = false
        state_1  = true
    else
        delphi.ui.icon[setting].display_text = "???"
        print(setting_state)
    end  
    return state_0, state_1
end

--[[ IF YOU WANT A CLASS SPECIFIC LABEL, USE THIS:

CreateNewLabel("class",350+300,100,function() return 0,"HERE GOES CLASS INFO" end)

]]

--[[dragonflight zero day]]
-- ------------------ UNIVERSAL CONTROLS -------------------------

--CreateIconAndButton("LastPress",210,-100,"n/a",false)
CreateIconAndButton("global",350+300,-150,"GCD",0,function() return 0,delphi.pythia.global.last_spellunit end)
CreateIconAndButton("instant",350+300,-250,"INST",0,function() return 0,delphi.pythia.instant.last_spellunit end)

CreateNewStatusIcon("NUMPAD7",170+300,-250,function() if(delphi.runtime.profile==_dd)then return 1,_dd else return 0,_dd end end)
     CreateButton(_dd,"NUMPAD7","/run delphi.runtime.profile = _dd; delphi.runtime.changedprofile = _now; print(_dd)\n/petassist")
CreateNewStatusIcon("NUMPAD8",210+300,-250,function() if(delphi.runtime.profile==_aoe)then return 1,_aoe else return 0,_aoe end end)
    CreateButton(_aoe,"NUMPAD8","/run delphi.runtime.profile = _aoe; delphi.runtime.changedprofile = _now; print(_aoe)")   
CreateNewStatusIcon("NUMPAD9",250+300,-250,function() if(delphi.runtime.profile==_off)then return 1,_off else return 0,_off end end)
    CreateButton(_off,"NUMPAD9","/run delphi.runtime.profile = _off\n/petpassive\n/stopattack\n/stopcasting\n/run print(_off)")
    delphi.runtime.profile = _off
    delphi.runtime.changedprofile = 0

    --CreateIconAndButton("NUMPAD1",170+300,-150,"burn",3)
--[[/dragonflight zero day]]

delphi.ui.icon = _icons
print("Core_Output_UI.lua")
