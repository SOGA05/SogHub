local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local ESPEnabled = true 
local ESPObjects = {} 

-- Fonction pour créer l'effet rouge et le contour blanc
local function createHighlight(character)
    -- Créer le contour blanc
    local highlight = Instance.new("Highlight")
    highlight.Name = "HighlightEffect"
    highlight.FillColor = Color3.new(1, 0, 0) -- Couleur de remplissage rouge
    highlight.FillTransparency = 0.5 -- Semi-transparent
    highlight.OutlineColor = Color3.new(1, 1, 1) -- Contour blanc
    highlight.OutlineTransparency = 0 -- Complètement visible
    highlight.Parent = character

    return highlight
end

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
    end
end

local function addESPToPlayer(player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")

        if not character:FindFirstChild("PlayerESP") then
            local billboard, textLabel = createESP(player)
            billboard.Parent = character
            table.insert(ESPObjects, billboard)

            -- Ajouter l'effet rouge et le contour blanc
            if not character:FindFirstChild("HighlightEffect") then
                createHighlight(character)
            end

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

    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local character = player.Character
        if not character:FindFirstChild("PlayerESP") then
            local billboard, textLabel = createESP(player)
            billboard.Parent = character
            table.insert(ESPObjects, billboard)

            -- Ajouter l'effet rouge et le contour blanc
            if not character:FindFirstChild("HighlightEffect") then
                createHighlight(character)
            end

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
