-- Script local à placer dans StarterPlayerScripts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()

-- Variables globales
local ESPEnabled = false -- Détermine si l'ESP est activé ou désactivé
local AimBotEnabled = false -- Détermine si l'AimBot est activé ou désactivé
local ESPObjects = {} -- Table pour stocker les ESP créés
local UIVisible = true -- Détermine si l'UI est visible ou non
local AimTarget = nil -- La cible actuelle de l'AimBot

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

-- Fonction pour l'AimBot
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

-- Détermine la cible la plus proche de la souris
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

-- Fonction pour créer l'interface utilisateur
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ESPControlUI"
    screenGui.Parent = game:GetService("CoreGui")

    local espButton = Instance.new("TextButton")
    espButton.Size = UDim2.new(0, 200, 0, 50)
    espButton.Position = UDim2.new(0, 10, 0, 10)
    espButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    espButton.TextColor3 = Color3.new(1, 1, 1)
    espButton.Font = Enum.Font.SourceSansBold
    espButton.TextSize = 20
    espButton.Text = "Toggle ESP (OFF)"
    espButton.Parent = screenGui

    local aimBotButton = Instance.new("TextButton")
    aimBotButton.Size = UDim2.new(0, 200, 0, 50)
    aimBotButton.Position = UDim2.new(0, 10, 0, 70)
    aimBotButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    aimBotButton.TextColor3 = Color3.new(1, 1, 1)
    aimBotButton.Font = Enum.Font.SourceSansBold
    aimBotButton.TextSize = 20
    aimBotButton.Text = "Toggle AimBot (OFF)"
    aimBotButton.Parent = screenGui

    espButton.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        espButton.Text = ESPEnabled and "Toggle ESP (ON)" or "Toggle ESP (OFF)"
    end)

    aimBotButton.MouseButton1Click:Connect(function()
        AimBotEnabled = not AimBotEnabled
        aimBotButton.Text = AimBotEnabled and "Toggle AimBot (ON)" or "Toggle AimBot (OFF)"
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

-- Met à jour la cible pour l'AimBot
RunService.RenderStepped:Connect(function()
    AimTarget = getClosestPlayerToMouse()
    aimAtTarget()
end)
