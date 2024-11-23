-- Script local à placer dans StarterPlayerScripts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables globales
local ESPEnabled = false
local UIVisible = true
local Boxes = {}

-- Crée une boîte de dessin
local function createBoundingBox()
    local box = Drawing.new("Square")
    box.Color = Color3.new(1, 1, 1) -- Blanc
    box.Thickness = 1.5
    box.Filled = false
    box.Transparency = 1
    return box
end

-- Met à jour la boîte de dessin autour d'un joueur
local function updateBoundingBox(character, box)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local size = Vector3.new(4, 6, 0) -- Taille approximative pour encadrer le joueur
        local corners = {
            humanoidRootPart.Position + Vector3.new(-size.X, size.Y, 0), -- Haut-gauche
            humanoidRootPart.Position + Vector3.new(size.X, size.Y, 0),  -- Haut-droit
            humanoidRootPart.Position + Vector3.new(size.X, -size.Y, 0), -- Bas-droit
            humanoidRootPart.Position + Vector3.new(-size.X, -size.Y, 0) -- Bas-gauche
        }

        local screenCorners = {}
        local isVisible = true

        -- Convertit les positions en espace-écran
        for _, corner in ipairs(corners) do
            local screenPos, onScreen = Camera:WorldToViewportPoint(corner)
            if not onScreen then
                isVisible = false
                break
            end
            table.insert(screenCorners, Vector2.new(screenPos.X, screenPos.Y))
        end

        if isVisible and #screenCorners == 4 then
            -- Dessine le carré
            box.Visible = ESPEnabled
            box.Size = Vector2.new(
                screenCorners[2].X - screenCorners[1].X,
                screenCorners[3].Y - screenCorners[1].Y
            )
            box.Position = Vector2.new(
                screenCorners[1].X,
                screenCorners[1].Y
            )
        else
            box.Visible = false
        end
    else
        box.Visible = false
    end
end

-- Ajoute un carré autour du joueur
local function addBoxToPlayer(player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")
        
        -- Crée une boîte pour ce joueur
        local box = createBoundingBox()
        Boxes[character] = box

        -- Met à jour la boîte à chaque frame
        RunService.RenderStepped:Connect(function()
            if character and character:FindFirstChild("HumanoidRootPart") then
                updateBoundingBox(character, box)
            else
                box.Visible = false
            end
        end)
    end)
end

-- Configure les boîtes pour tous les joueurs
local function setupBoundingBoxes()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            addBoxToPlayer(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            addBoxToPlayer(player)
        end
    end)
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

-- Lancer le script
setupBoundingBoxes()
createUI()
