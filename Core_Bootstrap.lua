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


CreateButton("vendor","F4",[[
/run for bag=0,4,1 do for slot=1,GetContainerNumSlots(bag),1 do local name=GetContainerItemLink(bag,slot) if name and string.find(name,"ff9d9d9d") then DEFAULT_CHAT_FRAME:AddMessage("- Selling "..name) UseContainerItem(bag,slot) end end end
]])
CreateButton("rlui","F5","/script ReloadUI()")

print("Core_Bootstrap.lua")
