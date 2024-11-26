local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ESPEnabled = false -- ESP désactivé par défaut
local ESPObjects = {}

-- Fonction pour créer l'effet rouge et le contour blanc
local function createHighlight(character)
    local highlight = Instance.new("Highlight")
    highlight.Name = "HighlightEffect"
    highlight.FillColor = Color3.new(1, 0, 0) -- Couleur de remplissage rouge
    highlight.FillTransparency = 0.5 -- Semi-transparent
    highlight.OutlineColor = Color3.new(1, 1, 1) -- Contour blanc
    highlight.OutlineTransparency = 0 -- Complètement visible
    highlight.Adornee = character
    highlight.Parent = character

    return highlight
end

-- Fonction pour créer l'ESP
local function createESP()
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
    textLabel.TextSize = 8
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Parent = billboard

    return billboard, textLabel
end

-- Met à jour l'ESP pour un joueur spécifique
local function updateESP(billboard, textLabel, character)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")

    if humanoidRootPart and humanoid then
        local distance = (humanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
        local health = humanoid.Health
        local maxHealth = humanoid.MaxHealth

        local healthText = string.format("%s\n%.1f studs\nHealth: %d/%d", character.Name, distance, health, maxHealth)
        textLabel.Text = healthText
        billboard.Adornee = humanoidRootPart
        billboard.Enabled = ESPEnabled -- Active ou désactive en fonction de l'état
    else
        billboard.Enabled = false
    end
end

-- Ajoute l'ESP à un joueur
local function addESPToPlayer(player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart", 10)

        if character and not character:FindFirstChild("PlayerESP") then
            local billboard, textLabel = createESP()
            billboard.Parent = character
            table.insert(ESPObjects, billboard)

            if not character:FindFirstChild("HighlightEffect") then
                createHighlight(character)
            end

            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not character:IsDescendantOf(workspace) then
                    billboard.Enabled = false
                    connection:Disconnect()
                else
                    updateESP(billboard, textLabel, character)
                end
            end)
        end
    end)

    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local character = player.Character
        if not character:FindFirstChild("PlayerESP") then
            local billboard, textLabel = createESP()
            billboard.Parent = character
            table.insert(ESPObjects, billboard)

            if not character:FindFirstChild("HighlightEffect") then
                createHighlight(character)
            end

            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not character:IsDescendantOf(workspace) then
                    billboard.Enabled = false
                    connection:Disconnect()
                else
                    updateESP(billboard, textLabel, character)
                end
            end)
        end
    end
end

-- Initialise l'ESP pour tous les joueurs
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

-- Gère l'activation/désactivation avec la touche "N"
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.N then
        ESPEnabled = not ESPEnabled -- Bascule l'état
        for _, obj in pairs(ESPObjects) do
            obj.Enabled = ESPEnabled -- Active ou désactive tous les objets ESP
        end
    end
end)

setupESP()
