-- Script local à placer dans StarterPlayerScripts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables globales
local ESPEnabled = false
local UIVisible = true
local ESPObjects = {}

-- Crée un label 2D pour afficher les informations du joueur
local function createESPLabel()
    local label = Drawing.new("Text")
    label.Size = 18
    label.Color = Color3.new(1, 1, 1) -- Blanc
    label.Center = true
    label.Outline = true
    label.OutlineColor = Color3.new(0, 0, 0) -- Noir
    label.Visible = false
    return label
end

-- Met à jour les informations d'un joueur sur l'écran
local function updateESPLabel(character, label)
    if not character:FindFirstChild("HumanoidRootPart") then
        label.Visible = false
        return
    end

    local rootPart = character.HumanoidRootPart
    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

    -- Affiche le label même si le joueur est derrière un mur ou éloigné
    if ESPEnabled and onScreen then
        label.Visible = true
        label.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
        label.Text = string.format(
            "%s\n%.1f studs",
            character.Parent.Name,
            (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        )
    else
        label.Visible = false
    end
end

-- Ajoute un ESP pour un joueur
local function addESPToPlayer(player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")

        local label = createESPLabel()
        ESPObjects[character] = label

        RunService.RenderStepped:Connect(function()
            if character and ESPObjects[character] then
                updateESPLabel(character, label)
            end
        end)
    end)
end

-- Rafraîchit l'ESP pour tous les joueurs
local function refreshESP()
    -- Nettoie les anciens ESP
    for _, label in pairs(ESPObjects) do
        label:Remove()
    end
    ESPObjects = {}

    -- Ajoute des ESP pour tous les joueurs
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            addESPToPlayer(player)
        end
    end
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

    -- ESP Bouton logique
    espButton.MouseButton1Click:Connect(function()
        ESPEnabled = not ESPEnabled
        espButton.Text = ESPEnabled and "Toggle ESP (ON)" or "Toggle ESP (OFF)"
    end)

    -- Touche pour cacher/afficher l'UI
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
            UIVisible = not UIVisible
            screenGui.Enabled = UIVisible
        end
    end)
end

-- Relance périodiquement l'ESP pour s'assurer que tout le monde est affecté
local function startAutoRefresh()
    while true do
        task.wait(10) -- Rafraîchit toutes les 10 secondes
        refreshESP()
    end
end

-- Initialisation du script
createUI()
refreshESP()
task.spawn(startAutoRefresh)
