local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Fonction pour créer un BillboardGui
local function createBillboard(player)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(4, 0, 1, 0)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Name = "PlayerInfo"

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1) -- Couleur blanche
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 16
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Parent = billboard

    return billboard, textLabel
end

-- Fonction pour attacher un affichage à un joueur
local function attachDisplay(player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")

        -- Vérifie si un affichage existe déjà
        if character:FindFirstChild("PlayerInfo") then
            character.PlayerInfo:Destroy()
        end

        -- Crée et attache le BillboardGui
        local billboard, textLabel = createBillboard(player)
        billboard.Parent = character
        billboard.Adornee = character.HumanoidRootPart

        -- Met à jour continuellement l'affichage
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not character or not character:FindFirstChild("HumanoidRootPart") then
                connection:Disconnect()
                return
            end

            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                textLabel.Text = string.format("%s\n%.1f studs", player.Name, distance)
            else
                textLabel.Text = player.Name
            end
        end)
    end)
end

-- Fonction principale pour gérer tous les joueurs
local function handlePlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            attachDisplay(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            attachDisplay(player)
        end
    end)
end

-- Exécute le script principal
handlePlayers()

