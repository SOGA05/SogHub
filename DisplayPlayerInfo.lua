local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Fonction pour créer un BillboardGui
local function createBillboard(player)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(4, 0, 1, 0)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Name = "PlayerInfo"

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1) -- Couleur blanche
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextSize = 16
    textLabel.TextStrokeTransparency = 0.5
    textLabel.Parent = billboard

    return billboard, textLabel
end

-- Fonction pour attacher un affichage à un joueur
local function attachDisplayToCharacter(player, character)
    -- Assure que le personnage a bien un HumanoidRootPart
    if not character:FindFirstChild("HumanoidRootPart") then
        character:WaitForChild("HumanoidRootPart")
    end

    -- Vérifie si un affichage existe déjà, sinon le crée
    if character:FindFirstChild("PlayerInfo") then
        character.PlayerInfo:Destroy()
    end

    local billboard, textLabel = createBillboard(player)
    billboard.Parent = character
    billboard.Adornee = character.HumanoidRootPart

    -- Met à jour continuellement l'affichage
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            connection:Disconnect()
            return
        end

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            textLabel.Text = string.format("%s\n%.1f studs", player.Name, distance)
        else
            textLabel.Text = player.Name
        end
    end)
end

-- Fonction pour gérer un joueur et ses réapparitions
local function attachDisplayToPlayer(player)
    -- Si le joueur a déjà un personnage, on lui ajoute l'affichage
    if player.Character then
        attachDisplayToCharacter(player, player.Character)
    end

    -- Connecte pour chaque réapparition du joueur
    player.CharacterAdded:Connect(function(character)
        attachDisplayToCharacter(player, character)
    end)
end

-- Fonction principale pour gérer tous les joueurs
local function handleAllPlayers()
    -- Gérer tous les joueurs actuels dans le serveur
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            attachDisplayToPlayer(player)
        end
    end

    -- Gérer les nouveaux joueurs qui rejoignent
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            attachDisplayToPlayer(player)
        end
    end)
end

-- Exécute le script principal
handleAllPlayers()
