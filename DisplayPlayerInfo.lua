-- Script local à placer dans StarterPlayerScripts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables globales
local ESPEnabled = false -- Détermine si l'ESP est activé ou désactivé
local ESPObjects = {} -- Table pour stocker les ESP créés
local UIVisible = true -- Détermine si l'UI est visible ou non
local ToggleKey = Enum.KeyCode.E -- Touche par défaut pour activer/désactiver l'ESP

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
            table.insert(ESPObjects, billboard) -- Ajoute le Billboard à la table

            -- Met à jour l'ESP en continu
            RunService.RenderStepped:Connect(function()
                if ESPEnabled and character and character:FindFirstChild("HumanoidRootPart") then
                    updateESP(billboard, textLabel, character)
                    billboard.Enabled = true
                else
                    billboard.Enabled = false
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
            table.insert(ESPObjects, billboard) -- Ajoute le Billboard à la table

            -- Met à jour l'ESP en continu
            RunService.RenderStepped:Connect(function()
                if ESPEnabled and character and character:FindFirstChild("HumanoidRootPart") then
                    updateESP(billboard, textLabel, character)
                    billboard.Enabled = true
                else
                    billboard.Enabled = false
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

-- Fonction pour créer l'interface utilisateur
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESPControlUI"
    screenGui.Parent = game:GetService("CoreGui")

    local espButton = Instance.new("TextButton")
    espButton.Size = UDim2.new(0, 200, 0, 50)
    espButton.Position = UDim2.new(0, 10, 0, 10) -- Position dans le coin supérieur gauche
    espButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    espButton.TextColor3 = Color3.new(1, 1, 1)
    espButton.Font = Enum.Font.SourceSansBold
    espButton.TextSize = 20
    espButton.Text = "Toggle ESP (OFF)"
    espButton.Parent = screenGui

    espButton.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled -- Inverse l'état de l'ESP
        espButton.Text = ESPEnabled and "Toggle ESP (ON)" or "Toggle ESP (OFF)"
    end)

    -- Bouton pour lier une touche pour activer/désactiver l'ESP
    local keyButton = Instance.new("TextButton")
    keyButton.Size = UDim2.new(0, 200, 0, 50)
    keyButton.Position = UDim2.new(0, 220, 0, 10) -- Position juste à côté
    keyButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    keyButton.TextColor3 = Color3.new(1, 1, 1)
    keyButton.Font = Enum.Font.SourceSansBold
    keyButton.TextSize = 20
    keyButton.Text = "Toggle Key: E"
    keyButton.Parent = screenGui

    keyButton.MouseButton1Click:Connect(function()
        -- Demande à l'utilisateur d'entrer une nouvelle touche
        keyButton.Text = "Press any key..."
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    ToggleKey = input.KeyCode -- Met la nouvelle touche comme touche de basculement
                    keyButton.Text = "Toggle Key: " .. input.KeyCode.Name
                end
            end
        end)
    end)

    -- Écoute les entrées clavier pour afficher/masquer l'UI et activer/désactiver l'ESP
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            -- Afficher ou masquer l'UI avec CTRL droit
            if input.KeyCode == Enum.KeyCode.RightControl then
                UIVisible = not UIVisible
                screenGui.Enabled = UIVisible
            end

            -- Toggle ESP avec la touche choisie
            if input.KeyCode == ToggleKey then
                ESPEnabled = not ESPEnabled -- Inverse l'état de l'ESP
                espButton.Text = ESPEnabled and "Toggle ESP (ON)" or "Toggle ESP (OFF)"
            end
        end
    end)
end

-- Lancer le script
setupESP()
createUI()
