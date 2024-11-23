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

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Position = UDim2.new(0, 10, 0, 10) -- Position dans le coin supérieur gauche
    button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 20
    button.Text = "Toggle ESP (OFF)"
    button.Parent = screenGui

    button.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled -- Inverse l'état de l'ESP
        button.Text = ESPEnabled and "Toggle ESP (ON)" or "Toggle ESP (OFF)"
    end)

    -- Écoute les entrées clavier pour afficher/masquer l'UI
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
            UIVisible = not UIVisible
            screenGui.Enabled = UIVisible
        end
    end)
end

-- Lancer le script
setupESP()
createUI()
