-- Script local à placer dans StarterPlayerScripts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Crée un BillboardGui
local function createBillboard(player)
    -- Crée un ScreenGui attaché au personnage
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(4, 0, 1, 0) -- Ajuste la taille
    billboard.AlwaysOnTop = true
    billboard.Name = "PlayerInfo"
    billboard.StudsOffset = Vector3.new(0, 3, 0)

    -- Crée un TextLabel pour afficher le nom et la distance
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1) -- Blanc
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 16
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Parent = billboard

    return billboard, textLabel
end

-- Met à jour l'affichage
local function updateBillboard(billboard, textLabel, character)
    local distance = (character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    textLabel.Text = string.format("%s\n%.1f studs", character.Name, distance)
    billboard.Adornee = character.HumanoidRootPart
end

-- Ajoute les infos au personnage d'un joueur
local function addInfoToPlayer(player)
    player.CharacterAdded:Connect(function(character)
        -- Assure que le personnage est chargé
        character:WaitForChild("HumanoidRootPart")
        
        -- Crée le BillboardGui
        local billboard, textLabel = createBillboard(player)
        billboard.Parent = character

        -- Met à jour continuellement l'affichage
        game:GetService("RunService").RenderStepped:Connect(function()
            if character and character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                updateBillboard(billboard, textLabel, character)
            end
        end)
    end)
end

-- Ajoute le script à tous les joueurs existants et futurs
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        addInfoToPlayer(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        addInfoToPlayer(player)
    end
end)
