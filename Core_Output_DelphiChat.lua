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
        local ok, text = pcall(tostring, select(i, ...))
        parts[i] = ok and text or "<unreadable>"
    end

    local message = "|cff66ccff[Delphi]|r " .. table.concat(parts, " ")

    if delphiChat then
        delphiChat:AddMessage(message)
    else
        pending[#pending + 1] = message
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

    -- Set the Delphi chat frame's scrollback before writing queued messages.
    -- Avoid resetting the frame on later reloads if it is already large enough.
    if delphiChat and delphiChat.SetMaxLines then
        local current = delphiChat.GetMaxLines
            and delphiChat:GetMaxLines()

        if not current or current < 5000 then
            delphiChat:SetMaxLines(5000)
        end
    end

    if delphiChat then
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
