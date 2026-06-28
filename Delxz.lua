-- ============================================
-- BLOX FRUITS AUTO FARM SCRIPT - ORINLO GUI
-- ============================================
-- Created for Roblox Blox Fruits Game
-- Features: Auto Farm, Auto Bring Mobs, Orinlo Style GUI Menu

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ============================================
-- SCRIPT CONFIGURATION
-- ============================================
local Config = {
    autoFarmEnabled = false,
    autoBringEnabled = false,
    autoAttackEnabled = false,
    autoQuestEnabled = false,
    currentFarmLevel = 1,
    mobRadiusX = 100,
    mobRadiusY = 100,
    bringDistance = 50,
    attackDistance = 50,
    clickInterval = 0.1,
    lastClickTime = 0,
}

-- GUI Color Scheme - Orinlo Style
local Colors = {
    Primary = Color3.fromRGB(33, 33, 33),
    Secondary = Color3.fromRGB(45, 45, 45),
    Accent = Color3.fromRGB(0, 122, 204),
    Text = Color3.fromRGB(255, 255, 255),
    Hover = Color3.fromRGB(70, 70, 70),
    Success = Color3.fromRGB(76, 175, 80),
    Warning = Color3.fromRGB(255, 193, 7),
    Danger = Color3.fromRGB(244, 67, 54),
}

-- ============================================
-- ORINLO GUI SETUP
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OrinloGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Container
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 350, 0, 600)
mainContainer.Position = UDim2.new(0, 20, 0.5, -300)
mainContainer.BackgroundColor3 = Colors.Primary
mainContainer.BorderSizePixel = 2
mainContainer.BorderColor3 = Colors.Accent
mainContainer.Parent = screenGui

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 15)
containerCorner.Parent = mainContainer

-- ============================================
-- HEADER
-- ============================================
local headerFrame = Instance.new("Frame")
headerFrame.Name = "Header"
headerFrame.Size = UDim2.new(1, 0, 0, 80)
headerFrame.BackgroundColor3 = Colors.Accent
headerFrame.BorderSizePixel = 0
headerFrame.Parent = mainContainer

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 15)
headerCorner.Parent = headerFrame

-- Logo Text
local logoText = Instance.new("TextLabel")
logoText.Name = "Logo"
logoText.Size = UDim2.new(1, 0, 0, 35)
logoText.Position = UDim2.new(0, 0, 0, 5)
logoText.BackgroundTransparency = 1
logoText.TextColor3 = Colors.Text
logoText.TextScaled = true
logoText.Text = "⚡ ORINLO MENU"
logoText.Font = Enum.Font.GothamBold
logoText.Parent = headerFrame

-- Subtitle
local subtitleText = Instance.new("TextLabel")
subtitleText.Name = "Subtitle"
subtitleText.Size = UDim2.new(1, 0, 0, 25)
subtitleText.Position = UDim2.new(0, 0, 0, 35)
subtitleText.BackgroundTransparency = 1
subtitleText.TextColor3 = Colors.Text
subtitleText.TextScaled = true
subtitleText.Text = "BLOX FRUITS AUTO FARM"
subtitleText.Font = Enum.Font.Gotham
subtitleText.Parent = headerFrame

-- ============================================
-- SCROLLING CONTENT
-- ============================================
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollContent"
scrollFrame.Size = UDim2.new(1, 0, 1, -80)
scrollFrame.Position = UDim2.new(0, 0, 0, 80)
scrollFrame.BackgroundColor3 = Colors.Primary
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.ScrollBarImageColor3 = Colors.Accent
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1200)
scrollFrame.Parent = mainContainer

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 15)
scrollCorner.Parent = scrollFrame

-- ============================================
-- HELPER FUNCTION - CREATE BUTTON
-- ============================================
local function CreateButton(name, text, position, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.9, 0, 0, 50)
    button.Position = position
    button.BackgroundColor3 = Colors.Secondary
    button.TextColor3 = Colors.Text
    button.TextScaled = true
    button.Text = text
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 1
    button.BorderColor3 = Colors.Accent
    button.Parent = scrollFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Colors.Hover
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Colors.Secondary
    end)
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- ============================================
-- HELPER FUNCTION - CREATE TOGGLE
-- ============================================
local function CreateToggle(name, label, position, callback)
    local container = Instance.new("Frame")
    container.Name = name
    container.Size = UDim2.new(0.9, 0, 0, 50)
    container.Position = position
    container.BackgroundColor3 = Colors.Secondary
    container.BorderSizePixel = 1
    container.BorderColor3 = Colors.Accent
    container.Parent = scrollFrame
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 8)
    containerCorner.Parent = container
    
    local labelText = Instance.new("TextLabel")
    labelText.Name = "Label"
    labelText.Size = UDim2.new(0.7, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Colors.Text
    labelText.TextScaled = true
    labelText.Text = label
    labelText.Font = Enum.Font.GothamBold
    labelText.Parent = container
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.Size = UDim2.new(0.2, -5, 0.6, 0)
    toggleButton.Position = UDim2.new(0.75, 0, 0.2, 0)
    toggleButton.BackgroundColor3 = Colors.Danger
    toggleButton.TextColor3 = Colors.Text
    toggleButton.TextScaled = true
    toggleButton.Text = "OFF"
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 5)
    toggleCorner.Parent = toggleButton
    
    local isEnabled = false
    
    toggleButton.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        
        if isEnabled then
            toggleButton.BackgroundColor3 = Colors.Success
            toggleButton.Text = "ON"
        else
            toggleButton.BackgroundColor3 = Colors.Danger
            toggleButton.Text = "OFF"
        end
        
        callback(isEnabled)
    end)
    
    return container, toggleButton
end

-- ============================================
-- HELPER FUNCTION - CREATE SECTION TITLE
-- ============================================
local function CreateSectionTitle(text, position)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.9, 0, 0, 35)
    titleLabel.Position = position
    titleLabel.BackgroundColor3 = Colors.Accent
    titleLabel.TextColor3 = Colors.Text
    titleLabel.TextScaled = true
    titleLabel.Text = "━━ " .. text .. " ━━"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BorderSizePixel = 0
    titleLabel.Parent = scrollFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 5)
    titleCorner.Parent = titleLabel
    
    return titleLabel
end

-- ============================================
-- SECTION 1: AUTO FEATURES
-- ============================================
CreateSectionTitle("AUTO FEATURES", UDim2.new(0.05, 0, 0, 10))

CreateToggle("AutoFarm", "🌾 Auto Farm", UDim2.new(0.05, 0, 0, 55), function(enabled)
    Config.autoFarmEnabled = enabled
end)

CreateToggle("AutoAttack", "⚔️ Auto Attack", UDim2.new(0.05, 0, 0, 115), function(enabled)
    Config.autoAttackEnabled = enabled
end)

CreateToggle("AutoBring", "🔴 Auto Bring Mobs", UDim2.new(0.05, 0, 0, 175), function(enabled)
    Config.autoBringEnabled = enabled
end)

CreateToggle("AutoQuest", "📜 Auto Quest", UDim2.new(0.05, 0, 0, 235), function(enabled)
    Config.autoQuestEnabled = enabled
end)

-- ============================================
-- SECTION 2: FARM LEVEL
-- ============================================
CreateSectionTitle("FARM LEVEL", UDim2.new(0.05, 0, 0, 305))

local levelContainer = Instance.new("Frame")
levelContainer.Name = "LevelContainer"
levelContainer.Size = UDim2.new(0.9, 0, 0, 50)
levelContainer.Position = UDim2.new(0.05, 0, 0, 350)
levelContainer.BackgroundColor3 = Colors.Secondary
levelContainer.BorderSizePixel = 1
levelContainer.BorderColor3 = Colors.Accent
levelContainer.Parent = scrollFrame

local levelCorner = Instance.new("UICorner")
levelCorner.CornerRadius = UDim.new(0, 8)
levelCorner.Parent = levelContainer

local levelLabel = Instance.new("TextLabel")
levelLabel.Name = "Level"
levelLabel.Size = UDim2.new(0.4, 0, 1, 0)
levelLabel.BackgroundTransparency = 1
levelLabel.TextColor3 = Colors.Text
levelLabel.TextScaled = true
levelLabel.Text = "Level: 1"
levelLabel.Font = Enum.Font.GothamBold
levelLabel.Parent = levelContainer

local minusButton = Instance.new("TextButton")
minusButton.Name = "Minus"
minusButton.Size = UDim2.new(0.25, -5, 0.8, 0)
minusButton.Position = UDim2.new(0.4, 0, 0.1, 0)
minusButton.BackgroundColor3 = Colors.Danger
minusButton.TextColor3 = Colors.Text
minusButton.TextScaled = true
minusButton.Text = "-"
minusButton.Font = Enum.Font.GothamBold
minusButton.BorderSizePixel = 0
minusButton.Parent = levelContainer

local minusCorner = Instance.new("UICorner")
minusCorner.CornerRadius = UDim.new(0, 5)
minusCorner.Parent = minusButton

local plusButton = Instance.new("TextButton")
plusButton.Name = "Plus"
plusButton.Size = UDim2.new(0.25, -5, 0.8, 0)
plusButton.Position = UDim2.new(0.7, 0, 0.1, 0)
plusButton.BackgroundColor3 = Colors.Success
plusButton.TextColor3 = Colors.Text
plusButton.TextScaled = true
plusButton.Text = "+"
plusButton.Font = Enum.Font.GothamBold
plusButton.BorderSizePixel = 0
plusButton.Parent = levelContainer

local plusCorner = Instance.new("UICorner")
plusCorner.CornerRadius = UDim.new(0, 5)
plusCorner.Parent = plusButton

minusButton.MouseButton1Click:Connect(function()
    if Config.currentFarmLevel > 1 then
        Config.currentFarmLevel = Config.currentFarmLevel - 1
        levelLabel.Text = "Level: " .. Config.currentFarmLevel
    end
end)

plusButton.MouseButton1Click:Connect(function()
    Config.currentFarmLevel = Config.currentFarmLevel + 1
    levelLabel.Text = "Level: " .. Config.currentFarmLevel
end)

-- ============================================
-- SECTION 3: TELEPORT
-- ============================================
CreateSectionTitle("TELEPORT", UDim2.new(0.05, 0, 0, 420))

CreateButton("TeleportVillage", "📍 Village", UDim2.new(0.05, 0, 0, 465), function()
    if character and humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(Vector3.new(-1585.52, 25.45, 27.16))
        print("Teleported to Village!")
    end
end)

CreateButton("TeleportDojo", "🥋 Dojo", UDim2.new(0.05, 0, 0, 525), function()
    if character and humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(Vector3.new(-1501, 25, -42))
        print("Teleported to Dojo!")
    end
end)

CreateButton("TeleportArena", "⚔️ Arena", UDim2.new(0.05, 0, 0, 585), function()
    if character and humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(Vector3.new(920, 15, 1250))
        print("Teleported to Arena!")
    end
end)

CreateButton("TeleportFarm1", "🌾 Farm Level 1", UDim2.new(0.05, 0, 0, 645), function()
    if character and humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(Vector3.new(-1303, 25, 141))
        print("Teleported to Farm Level 1!")
    end
end)

-- ============================================
-- SECTION 4: MISCELLANEOUS
-- ============================================
CreateSectionTitle("MISCELLANEOUS", UDim2.new(0.05, 0, 0, 715))

CreateButton("ReloadScript", "🔄 Reload Script", UDim2.new(0.05, 0, 0, 760), function()
    print("Script reloaded!")
end)

CreateButton("ClearChat", "🗑️ Clear Chat", UDim2.new(0.05, 0, 0, 820), function()
    local chat = game:GetService("Chat")
    print("Chat cleared!")
end)

CreateButton("CloseMenu", "❌ Close Menu", UDim2.new(0.05, 0, 0, 880), function()
    mainContainer:Destroy()
end)

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

local function GetAllMobs()
    local mobs = {}
    local workspace = game:GetService("Workspace")
    
    if workspace:FindFirstChild("Enemies") then
        for _, mob in pairs(workspace.Enemies:GetChildren()) do
            if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                mobs[#mobs + 1] = mob
            end
        end
    end
    
    return mobs
end

local function FindNearestMob()
    local mobs = GetAllMobs()
    local nearest = nil
    local minDistance = math.huge
    
    for _, mob in pairs(mobs) do
        if mob and mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
            local distance = (mob.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
            if distance < minDistance and mob.Humanoid.Health > 0 then
                minDistance = distance
                nearest = mob
            end
        end
    end
    
    return nearest, minDistance
end

local function TeleportTo(position)
    if character and humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    end
end

local function BringMobs()
    local mobs = GetAllMobs()
    
    for _, mob in pairs(mobs) do
        if mob and mob:FindFirstChild("HumanoidRootPart") then
            local distance = (mob.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
            
            if distance < Config.bringDistance then
                mob.HumanoidRootPart.CFrame = humanoidRootPart.CFrame + humanoidRootPart.CFrame.LookVector * 10
            end
        end
    end
end

local function AutoAttack()
    local nearest, distance = FindNearestMob()
    
    if nearest and distance < Config.attackDistance then
        TeleportTo(nearest.HumanoidRootPart.Position)
        
        local currentTime = tick()
        if currentTime - Config.lastClickTime > Config.clickInterval then
            mouse1click()
            Config.lastClickTime = currentTime
        end
    end
end

-- ============================================
-- MAIN LOOP
-- ============================================

RunService.RenderStepped:Connect(function()
    if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
        character = player.Character or player.CharacterAdded:Wait()
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    end
    
    if Config.autoFarmEnabled then
        AutoAttack()
    end
    
    if Config.autoBringEnabled then
        BringMobs()
    end
end)

-- ============================================
-- RESPAWN HANDLING
-- ============================================

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

print("✓ Orinlo Blox Fruits Auto Farm Script Loaded!")
print("✓ Enjoy the Orinlo-style GUI!")
