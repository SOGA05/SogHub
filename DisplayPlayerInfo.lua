-- Script local à placer dans StarterPlayerScripts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()

-- Variables globales
local ESPEnabled = false
local AimBotEnabled = false
local ESPObjects = {}
local UIVisible = true
local AimTarget = nil

-- Crée un BillboardGui pour ESP
local function createESP(player)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(4, 0, 1, 0)
    billboard.StudsOffset = Vector3.new(0, 3, 0)

    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 16
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Parent = billboard

    return billboard, textLabel
end

-- Met à jour l'ESP
local function updateESP(billboard, textLabel, character)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local distance = (humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        textLabel.Text = string.format("%s\n%.1f studs", character.Name, distance)
        billboard.Adornee = humanoidRootPart
    end
end

-- Ajoute un ESP au joueur
local function addESPToPlayer(player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")

        if not character:FindFirstChild("PlayerESP") then
            local billboard, textLabel = createESP(player)
            billboard.Parent = character
            table.insert(ESPObjects, billboard)

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
end

-- Configure l'ESP pour tous les joueurs
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

-- Fonction AimBot
local function aimAtTarget()
    if AimBotEnabled and AimTarget then
        local targetCharacter = AimTarget.Character
        if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
            local targetPosition = targetCharacter.HumanoidRootPart.Position
            local aimPosition = Camera:WorldToScreenPoint(targetPosition)
            mousemoveabs(aimPosition.X, aimPosition.Y)
        end
    end
end

-- Trouve le joueur le plus proche de la souris
local function getClosestPlayerToMouse()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = player.Character.HumanoidRootPart.Position
            local screenPosition, onScreen = Camera:WorldToViewportPoint(targetPosition)
            if onScreen then
                local mousePosition = Vector2.new(Mouse.X, Mouse.Y)
                local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePosition).Magnitude
                if distance < closestDistance then
                    closestPlayer = player
                    closestDistance = distance
                end
            end
        end
    end

    return closestPlayer
end

-- Crée l'interface utilisateur
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESPControlUI"
    screenGui.Parent = game:GetService("CoreGui")

    -- Bouton ESP
    local espButton = Instance.new("TextButton")
    espButton.Size = UDim2.new(0, 200, 0, 50)
    espButton.Position = UDim2.new(0, 10, 0, 10)
    espButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    espButton.TextColor3 = Color3.new(1, 1, 1)
    espButton.Font = Enum.Font.SourceSansBold
    espButton.TextSize = 20
    espButton.Text = "Toggle ESP (OFF)"
    espButton.Parent = screenGui

    -- Bouton AimBot
    local aimBotButton = Instance.new("TextButton")
    aimBotButton.Size = UDim2.new(0, 200, 0, 50)
    aimBotButton.Position = UDim2.new(0, 10, 0, 70)
    aimBotButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    aimBotButton.TextColor3 = Color3.new(1, 1, 1)
    aimBotButton.Font = Enum.Font.SourceSansBold
    aimBotButton.TextSize = 20
    aimBotButton.Text = "Toggle AimBot (OFF)"
    aimBotButton.Parent = screenGui

    -- ESP Bouton logique
    espButton.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        espButton.Text = ESPEnabled and "Toggle ESP (ON)" or "Toggle ESP (OFF)"
    end)

    -- AimBot Bouton logique
    aimBotButton.MouseButton1Click:Connect(function()
        AimBotEnabled = not AimBotEnabled
        aimBotButton.Text = AimBotEnabled and "Toggle AimBot (ON)" or "Toggle AimBot (OFF)"
    end)

    -- Touche pour cacher/afficher l'UI
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

-- Met à jour la cible pour l'AimBot
RunService.RenderStepped:Connect(function()
    AimTarget = getClosestPlayerToMouse()
    aimAtTarget()
end)
