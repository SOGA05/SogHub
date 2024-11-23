-- Script local à placer dans StarterPlayerScripts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables globales
local ESPEnabled = false
local UIVisible = true
local Skeletons = {}

-- Fonction pour créer une ligne de squelette
local function createSkeletonLine()
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Transparency = 1
    line.Color = Color3.new(1, 1, 1) -- Blanc
    return line
end

-- Fonction pour mettre à jour un squelette
local function updateSkeleton(character, skeletonLines)
    local parts = {
        {character:FindFirstChild("Head"), character:FindFirstChild("UpperTorso")},
        {character:FindFirstChild("UpperTorso"), character:FindFirstChild("LowerTorso")},
        {character:FindFirstChild("UpperTorso"), character:FindFirstChild("LeftUpperArm")},
        {character:FindFirstChild("LeftUpperArm"), character:FindFirstChild("LeftLowerArm")},
        {character:FindFirstChild("LeftLowerArm"), character:FindFirstChild("LeftHand")},
        {character:FindFirstChild("UpperTorso"), character:FindFirstChild("RightUpperArm")},
        {character:FindFirstChild("RightUpperArm"), character:FindFirstChild("RightLowerArm")},
        {character:FindFirstChild("RightLowerArm"), character:FindFirstChild("RightHand")},
        {character:FindFirstChild("LowerTorso"), character:FindFirstChild("LeftUpperLeg")},
        {character:FindFirstChild("LeftUpperLeg"), character:FindFirstChild("LeftLowerLeg")},
        {character:FindFirstChild("LeftLowerLeg"), character:FindFirstChild("LeftFoot")},
        {character:FindFirstChild("LowerTorso"), character:FindFirstChild("RightUpperLeg")},
        {character:FindFirstChild("RightUpperLeg"), character:FindFirstChild("RightLowerLeg")},
        {character:FindFirstChild("RightLowerLeg"), character:FindFirstChild("RightFoot")},
    }

    for i, partPair in ipairs(parts) do
        local partA, partB = partPair[1], partPair[2]
        if partA and partB then
            local posA = Camera:WorldToViewportPoint(partA.Position)
            local posB = Camera:WorldToViewportPoint(partB.Position)
            skeletonLines[i].From = Vector2.new(posA.X, posA.Y)
            skeletonLines[i].To = Vector2.new(posB.X, posB.Y)
            skeletonLines[i].Visible = ESPEnabled
        else
            skeletonLines[i].Visible = false
        end
    end
end

-- Ajoute un squelette au personnage d'un joueur
local function addSkeletonToPlayer(player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")
        character:WaitForChild("Head")

        -- Crée les lignes du squelette
        local skeletonLines = {}
        for i = 1, 14 do
            table.insert(skeletonLines, createSkeletonLine())
        end
        Skeletons[character] = skeletonLines

        -- Met à jour le squelette à chaque frame
        RunService.RenderStepped:Connect(function()
            if character and character:FindFirstChild("HumanoidRootPart") then
                updateSkeleton(character, skeletonLines)
            else
                for _, line in ipairs(skeletonLines) do
                    line.Visible = false
                end
            end
        end)
    end)
end

-- Configure les squelettes pour tous les joueurs
local function setupSkeletons()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            addSkeletonToPlayer(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            addSkeletonToPlayer(player)
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
setupSkeletons()
createUI()
