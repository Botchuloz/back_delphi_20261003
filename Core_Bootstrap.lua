local GodlyEventFrame = CreateFrame("Frame");
local initialise = 0
local godly_tick = 0
local _event = delphi.event.register
local _class  = delphi.class
local print = DelphiPrint

function GodlyCore()
    UpdateStatusIcons()
    local combat = UnitAffectingCombat("player")
    local player_class = UnitClass("player") or "Unknown"

    if _class[player_class] then
        _class[player_class].SetBinds()
        _class[player_class].CoreLogic()
    else
        -- GCDPythiaOff()
        -- InstantPythiaOff()
        if(initialise<100)then
            print("I don't know how to handle you yet, "..player_class)
            initialise = initialise + 1
        end
    end

    if delphi.whisper_follow and delphi.whisper_follow.pending
        and delphi.bind.spellunit_to_keycombo.whisper_follow then
        delphi.pythia.global.SetSpellUnit("whisper_follow", "")
    end

    BindRareScannerMacro()

    if initialise == 0 then
        print("Free binds: ",FreeBindCount())
        initialise = 1
    end
end


function StartEvents()
	for k, v in pairs(_event) do
        GodlyEventFrame:RegisterEvent(k);
        print("registered "..k)
	end

	GodlyEventFrame:SetScript("OnEvent", function(self, event, ...)
		_event[event](self, event, ...); -- call one of the functions above
	end)

	GodlyEventFrame:SetScript("OnUpdate", function(self, elapsed)
		_now = GetTime()--_now + elapsed; 
		if(godly_tick + 0.2 < _now )then
			godly_tick = _now;
			GodlyCore(self,elapsed); 
		end
	
	end)
	print("Events Loaded")
end

StartEvents()

CreateButton("rlui","F5","/script ReloadUI()")

print("Core_Bootstrap.lua")
