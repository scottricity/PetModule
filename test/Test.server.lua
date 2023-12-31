local Replicated = game:GetService("ReplicatedStorage")
local PetModule = require(Replicated.PetModule)
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(2)
        PetModule:attachToPlayer(player, Replicated:FindFirstChild("Pet"))
        task.wait(1)
        print(PetModule:getCache())
    end)
end)