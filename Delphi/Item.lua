function ItemCooldownRemaining(slotNo)
    local cd_started, cd_duration, item_has_on_use = GetInventoryItemCooldown("player",slotNo)
    if(item_has_on_use ~= 1)then
        return false,9999
    end

    if(cd_started==nil)then -- safety catch for weird
        cd_started=0;
        cd_duration=0;
    end

    local cd_remaining = cd_started + cd_duration - _now
    local cd_available = cd_started==0

    return cd_available,cd_remaining
end

function TrinketStatus()
    local t1_cd = ItemCooldownRemaining(13)
    local t2_cd = ItemCooldownRemaining(14)

    return t1_cd or t2_cd
end

local item_slots = {
 ammo = 	0
,head = 	1
,neck =  	2
,shoulder =	3
,shirt =	4
,chest = 	5
,belt  = 	6
,leg   =  	7
,boot  = 	8
,wrist = 	9
,glove =  	10
,ring1 =  	11
,ring2 = 	12
,trinket1 =	13
,trinket2 =	14
,cloak    =	15
,mainhand =	16
,offhand = 	17
,wand   = 	18
,tabard = 	19
,bag1  =	20
,bag2   = 	21
,bag3 = 	22
,bag4 = 	23
}

function ItemEquipped(slot_number_or_string)
    if type(slot_number_or_string) == "string" then
        return GetInventoryItemID("player",item_slots[slot_number_or_string]) or 0
    end
    return GetInventoryItemID("player",slot_number_or_string) or 0
end

function ItemCD(itemID)
    local startTime,duration,enable = C_Container.GetItemCooldown()
    if enable == 1 and duration == 0 then
        return 0
    else 
        return 1
   end
end

-- function ItemCD(itemnumber)
--     local startTime,duration,enable = GetItemCooldown(itemnumber)
--     if(startTime==nil)then
--         return 0
--     elseif(enable == 0)then
--         return duration
--     else
--         return (start + duration) - GetTime()
--     end
--end

--177278 = phial
--171412 = "deadliest coil" chest
