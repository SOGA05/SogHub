local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Fonction pour créer un Beam représentant un "os"
local function createBone(part0, part1, parent)
    local attachment0 = Instance.new("Attachment")
    local attachment1 = Instance.new("Attachment")
    attachment0.Parent = part0
    attachment1.Parent = part1

    local beam = Instance.new("Beam")
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Color = ColorSequence.new(Color3.new(1, 1, 1)) -- Couleur blanche
    beam.Width0 = 0.1
    beam.Width1 = 0.1
    beam.Parent = parent
end

-- Fonction pour créer le squelette
local function createSkeleton(character)
    if not character:FindFirstChild("HumanoidRootPart") then
        character:WaitForChild("HumanoidRootPart")
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    -- Liste des os à connecter (jointures principales)
    local bones = {
        {character:WaitForChild("HumanoidRootPart"), character:WaitForChild("UpperTorso")},
        {character:WaitForChild("UpperTorso"), character:WaitForChild("LowerTorso")},
        {character:WaitForChild("UpperTorso"), character:WaitForChild("LeftUpperArm")},
        {character:WaitForChild("UpperTorso"), character:WaitForChild("RightUpperArm")},
        {character:WaitForChild("LowerTorso"), character:WaitForChild("LeftUpperLeg")},
        {character:WaitForChild("LowerTorso"), character:WaitForChild("RightUpperLeg")},
        {character:WaitForChild("LeftUpperArm"), character:WaitForChild("LeftLowerArm")},
        {character:WaitForChild("RightUpperArm"), character:WaitForChild("RightLowerArm")},
        {character:WaitForChild("LeftUpperLeg"), character:WaitForChild("LeftLowerLeg")},
        {character:WaitForChild("RightUpperLeg"), character:WaitForChild("RightLowerLeg")},
        {character:WaitForChild("LeftLowerArm"), character:WaitForChild("LeftHand")},
        {character:WaitForChild("RightLowerArm"), character:WaitForChild("RightHand")},
        {character:WaitForChild("LeftLowerLeg"), character:WaitForChild("LeftFoot")},
        {character:WaitForChild("RightLowerLeg"), character:WaitForChild("RightFoot")},
    }

    -- Crée les "os" (Beams) pour chaque paire
    for _, bone in pairs(bones) do
        local part0, part1 = bone[1], bone[2]
        if part0 and part1 then
            createBone(part0, part1, character)
        end
    end
end

-- Fonction pour ajouter un squelette à un joueur
local function addSkeletonToPlayer(player)
    player.CharacterAdded:Connect(function(character)
        -- Ajoute un squelette une fois que le personnage est chargé
        createSkeleton(character)
    end)

    -- Si le personnage existe déjà, crée immédiatement le squelette
    if player.Character then
        createSkeleton(player.Character)
    end
end

-- Ajoute un squelette à tous les joueurs existants et futurs
local function setupAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        addSkeletonToPlayer(player)
    end

    Players.PlayerAdded:Connect(function(player)
        addSkeletonToPlayer(player)
    end)
end

setupAllPlayers()
