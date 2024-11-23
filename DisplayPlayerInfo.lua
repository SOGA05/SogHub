-- Script local à placer dans StarterPlayerScripts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Crée un BillboardGui pour un joueur
local function createESP(player)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(4, 0, 1, 0)
    billboard.StudsOffset = Vector3.new(0, 3, 0)

    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.TextColor3 = Color3.new(1, 1, 1) -- Couleur blanche
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 16
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Parent = billboard

    return billboard, textLabel
end

-- Met à jour le BillboardGui d'un joueur
local function updateESP(billboard, textLabel, character)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local distance = (humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        textLabel.Text = string.format("%s\n%.1f studs", character.Name, distance)
        billboard.Adornee = humanoidRootPart
    end
end

-- Ajoute un ESP à un joueur
local function addESPToPlayer(player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart") -- Attend que le personnage soit chargé

        -- Vérifie si un ESP existe déjà
        if not character:FindFirstChild("PlayerESP") then
            local billboard, textLabel = createESP(player)
            billboard.Parent = character

            -- Met à jour l'ESP en continu
            RunService.RenderStepped:Connect(function()
                if character and character:FindFirstChild("HumanoidRootPart") then
                    updateESP(billboard, textLabel, character)
                end
            end)
        end
    end)

    -- Si le joueur a déjà un personnage chargé
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local character = player.Character
        if not character:FindFirstChild("PlayerESP") then
            local billboard, textLabel = createESP(player)
            billboard.Parent = character

            -- Met à jour l'ESP en continu
            RunService.RenderStepped:Connect(function()
                if character and character:FindFirstChild("HumanoidRootPart") then
                    updateESP(billboard, textLabel, character)
                end
            end)
        end
    end
end

-- Ajoute l'ESP à tous les joueurs actuels et futurs
local function setupESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            addESPToPlayer(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            addESPToPlayer(player)
        end
    end)
end

setupESP()
