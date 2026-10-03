local delphiChat
local pending = {}


local function FindDelphiChat()
    if not GetChatWindowInfo or not NUM_CHAT_WINDOWS then
        return nil
    end

    for i = 1, NUM_CHAT_WINDOWS do
        if GetChatWindowInfo(i) == "Delphi" then
            return _G["ChatFrame" .. i]
        end
    end
end


function DelphiPrint(...)
    local parts = {}

    for i = 1, select("#", ...) do
        local value = select(i, ...)
        local secret = false
        if type(issecretvalue) == "function" then
            local secret_ok, is_secret = pcall(issecretvalue, value)
            secret = not secret_ok or is_secret == true
        end

        if secret then
            parts[i] = "<secret>"
        else
            local ok, text = pcall(tostring, value)
            if ok and type(issecretvalue) == "function" then
                local secret_ok, is_secret = pcall(issecretvalue, text)
                if not secret_ok or is_secret == true then
                    text = "<secret>"
                    ok = true
                end
            end
            parts[i] = ok and text or "<unreadable>"
        end
    end

    local message = "|cff66ccff[Delphi]|r " .. table.concat(parts, " ")

    if delphiChat then
        delphiChat:AddMessage(message)
    else
        pending[#pending + 1] = message
    end
end


-- Keep this saved chat window for Delphi output only. Message groups include
-- built-in chat/system/guild notices; channels include joined world channels.
-- Remove them only from the Delphi frame, never from General or other frames.
local function RemoveNonDelphiSubscriptions(frame)
    local id = frame:GetID()
    if not id then return end

    if GetChatWindowMessages and RemoveChatWindowMessages then
        local groups = { GetChatWindowMessages(id) }
        for _, group in ipairs(groups) do
            RemoveChatWindowMessages(id, group)
        end
    end

    if GetChatWindowChannels and RemoveChatWindowChannel then
        local channels = { GetChatWindowChannels(id) }
        for i = 1, #channels, 2 do
            if channels[i] then
                RemoveChatWindowChannel(id, channels[i])
            end
        end
    end
end


local function OpenDelphiChat()
    delphiChat = FindDelphiChat()

    if not delphiChat and type(FCF_OpenNewWindow) == "function" then
        local ok, frame = pcall(FCF_OpenNewWindow, "Delphi")
        if ok then
            delphiChat = frame or FindDelphiChat()
        end
    end

    if delphiChat then
        RemoveNonDelphiSubscriptions(delphiChat)

        -- Set scrollback before writing queued messages. Avoid resetting
        -- the frame if it already has a limit of at least 5,000 lines.
        if delphiChat.SetMaxLines then
            local current = delphiChat.GetMaxLines
                and delphiChat:GetMaxLines()

            if not current or current < 5000 then
                delphiChat:SetMaxLines(5000)
            end
        end

        for _, message in ipairs(pending) do
            delphiChat:AddMessage(message)
        end
        pending = {}
    end
end


local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:SetScript("OnEvent", function()
    -- Let the client's saved chat windows finish loading before searching.
    if C_Timer and C_Timer.After then
        C_Timer.After(1, OpenDelphiChat)
    else
        OpenDelphiChat()
    end
end)
