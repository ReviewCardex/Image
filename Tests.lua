local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local owner = {
    ["FgHuJi29"] = true
}

local localPlayer = Players.LocalPlayer
local isOwner = owner[localPlayer.Name] == true

-- Check if legacy chat exists
local function isUsingLegacyChat()
    return ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") ~= nil
end

-- Command handler
local function handleOwnerCommand(msg)
    msg = string.lower(msg)

    if msg == ":kill" and not isOwner then
        local char = localPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
        end
    elseif msg == ":kick" and not isOwner then
        localPlayer:Kick("Kicked by owner command.")
    end
end

-- Use new chat system
if not isUsingLegacyChat() then
    local channel = TextChatService:WaitForChild("TextChannels"):FindFirstChild("RBXGeneral")

    if channel then
        channel.MessageReceived:Connect(function(message)
            local speaker = message.TextSource
            if not speaker then return end

            local sender = Players:GetPlayerByUserId(speaker.UserId)
            if sender and owner[sender.Name] then
                handleOwnerCommand(message.Text)
            end
        end)
    end

-- Use legacy chat system
else
    local events = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents", 10)
    if events then
        local onMsg = events:FindFirstChild("OnMessageDoneFiltering")
        if onMsg then
            onMsg.OnClientEvent:Connect(function(data)
                if owner[data.FromSpeaker] then
                    handleOwnerCommand(data.Message)
                end
            end)
        end
    end
end
