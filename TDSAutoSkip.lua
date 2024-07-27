local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StateReplica
local scriptPaused = false
local scriptDestroyed = false

getgenv().GetStateReplica = function()
    if StateReplica then
        return StateReplica
    end
    repeat
        for i,v in next, ReplicatedStorage.StateReplicators:GetChildren() do
            if v:GetAttribute("MaxVotes") then
                StateReplica = v
                return v
            end
        end
        task.wait()
    until StateReplica
end

local function onAttributeChanged()
    if not scriptPaused then
        ReplicatedStorage.RemoteFunction:InvokeServer("Voting", "Skip")
    end
end

local function onInputBegan(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.Comma then
        scriptPaused = not scriptPaused
        print("Script " .. (scriptPaused and "paused" or "unpaused"))
    elseif input.KeyCode == Enum.KeyCode.Period then
        scriptDestroyed = true
        print("Script destroyed")
        StateReplica:GetAttributeChangedSignal("Enabled"):Disconnect(onAttributeChanged)
        UserInputService.InputBegan:Disconnect(onInputBegan)
    end
end

GetStateReplica():GetAttributeChangedSignal("Enabled"):Connect(onAttributeChanged)
UserInputService.InputBegan:Connect(onInputBegan)
