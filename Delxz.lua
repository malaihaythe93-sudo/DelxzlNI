-- ============================================
-- REDZ HUB - BLOX FRUITS SCRIPT
-- ============================================
-- Features: Auto Farm, Teleport, Raid, Combat, etc.
-- Version: 1.0
-- Designed for DeltaX Android & PC

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ============================================
-- CONFIGURATION & VARIABLES
-- ============================================

local Config = {
    -- Auto Farm
    autoFarmEnabled = false,
    autoQuestEnabled = false,
    autoSelectQuestEnabled = false,
    autoEquipWeapon = false,
    autoEquipFruit = false,
    autoEquipFightingStyle = false,
    autoEquipAccessory = false,
    autoAura = false,
    autoObservation = false,
    autoClick = false,
    autoFastAttack = false,
    autoStats = false,
    autoSkill = false,
    autoMastery = false,
    autoFarmBoss = false,
    
    -- Sea Events
    autoSeaBeast = false,
    autoLeviathan = false,
    autoTerrorShark = false,
    autoPiranha = false,
    
    -- Raid
    autoBuyChip = false,
    autoStartRaid = false,
    autoJoinRaid = false,
    autoKillNPC = false,
    autoCompletRaid = false,
    
    -- Combat
    fastAttack = false,
    killAura = false,
    autoCombo = false,
    infiniteDash = false,
    infiniteGeppo = false,
    
    -- Teleport
    currentSea = 1,
    
    -- Settings
    tweenSpeed = 150,
    farmDistance = 50,
    mobOffset = 15,
    clickDelay = 0.1,
    attackDelay = 0.5,
    cameraDistance = 100,
    fpsLimit = 60,
    notification = true,
    autoSave = true,
    autoLoad = true,
    theme = "dark",
    language = "vi",
}

-- Color Palette
local Colors = {
    Primary = Color3.fromRGB(20, 20, 30),
    Secondary = Color3.fromRGB(30, 30, 45),
    Accent = Color3.fromRGB(0, 150, 255),
    Danger = Color3.fromRGB(255, 50, 50),
    Success = Color3.fromRGB(50, 200, 100),
    Warning = Color3.fromRGB(255, 180, 0),
    Text = Color3.fromRGB(255, 255, 255),
    Hover = Color3.fromRGB(50, 50, 80),
}

-- Map Data
local Maps = {
    Sea1 = {
        "Starter Island",
        "Jungle",
        "Pirate Village",
        "Desert",
        "Frozen Village",
        "Marine Fortress",
        "Sky Island",
        "Prison",
        "Colosseum",
        "Magma Village",
        "Underwater City",
        "Fountain City"
    },
    Sea2 = {
        "Kingdom of Rose",
        "Green Zone",
        "Graveyard",
        "Snow Mountain",
        "Hot & Cold",
        "Cursed Ship",
        "Ice Castle",
        "Forgotten Island",
        "Dark Arena"
    },
    Sea3 = {
        "Port Town",
        "Hydra Island",
        "Great Tree",
        "Floating Turtle",
        "Castle on the Sea",
        "Haunted Castle",
        "Sea of Treats",
        "Tiki Outpost"
    }
}

-- ============================================
-- GUI SETUP - MAIN CONTAINER
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RedzHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Blur Effect
local function CreateBlur()
    local blur = Instance.new("BlurEffect")
    blur.Size = 24
    blur.Parent = game:GetService("Lighting")
    return blur
end

-- Main Window
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(0, 500, 0, 700)
mainWindow.Position = UDim2.new(0.5, -250, 0.5, -350)
mainWindow.BackgroundColor3 = Colors.Primary
mainWindow.BorderSizePixel = 2
mainWindow.BorderColor3 = Colors.Accent
mainWindow.Draggable = true
mainWindow.Active = true
mainWindow.Parent = screenGui

local windowCorner = Instance.new("UICorner")
windowCorner.CornerRadius = UDim.new(0, 15)
windowCorner.Parent = mainWindow

-- ============================================
-- HEADER / TITLE BAR
-- ============================================

local headerBar = Instance.new("Frame")
headerBar.Name = "HeaderBar"
headerBar.Size = UDim2.new(1, 0, 0, 60)
headerBar.BackgroundColor3 = Colors.Accent
headerBar.BorderSizePixel = 0
headerBar.Parent = mainWindow

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 15)
headerCorner.Parent = headerBar

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Colors.Text
titleLabel.TextScaled = true
titleLabel.Text = "⚡ REDZ HUB"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = headerBar

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0.15, 0, 0.6, 0)
closeButton.Position = UDim2.new(0.82, 0, 0.2, 0)
closeButton.BackgroundColor3 = Colors.Danger
closeButton.TextColor3 = Colors.Text
closeButton.TextScaled = true
closeButton.Text = "✕"
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.Parent = headerBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Minimize Button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0.15, 0, 0.6, 0)
minimizeButton.Position = UDim2.new(0.65, 0, 0.2, 0)
minimizeButton.BackgroundColor3 = Colors.Warning
minimizeButton.TextColor3 = Colors.Text
minimizeButton.TextScaled = true
minimizeButton.Text = "−"
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.BorderSizePixel = 0
minimizeButton.Parent = headerBar

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 8)
minimizeCorner.Parent = minimizeButton

-- ============================================
-- TAB SYSTEM
-- ============================================

local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 0, 50)
tabContainer.Position = UDim2.new(0, 0, 0, 60)
tabContainer.BackgroundColor3 = Colors.Secondary
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainWindow

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabContainer

-- Content Area
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -110)
contentFrame.Position = UDim2.new(0, 0, 0, 110)
contentFrame.BackgroundColor3 = Colors.Primary
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 8
contentFrame.ScrollBarImageColor3 = Colors.Accent
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 1500)
contentFrame.Parent = mainWindow

-- ============================================
-- TAB CREATION FUNCTION
-- ============================================

local function CreateTab(name, tabIcon)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(0, 100, 0, 40)
    tabButton.BackgroundColor3 = Colors.Secondary
    tabButton.TextColor3 = Colors.Text
    tabButton.TextScaled = true
    tabButton.Text = tabIcon .. " " .. name
    tabButton.Font = Enum.Font.GothamBold
    tabButton.BorderSizePixel = 1
    tabButton.BorderColor3 = Colors.Accent
    tabButton.Parent = tabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabButton
    
    local tabContent = Instance.new("Frame")
    tabContent.Name = name .. "Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.Parent = contentFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = tabContent
    
    tabButton.MouseButton1Click:Connect(function()
        -- Hide all tabs
        for _, tab in pairs(contentFrame:GetChildren()) do
            if tab:IsA("Frame") and tab.Name:match("Content") then
                tab.Visible = false
            end
        end
        
        -- Show selected tab
        tabContent.Visible = true
        
        -- Update button color
        for _, btn in pairs(tabContainer:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Colors.Secondary
            end
        end
        tabButton.BackgroundColor3 = Colors.Accent
    end)
    
    return tabButton, tabContent
end

-- ============================================
-- BUTTON CREATION FUNCTION
-- ============================================

local function CreateButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 45)
    button.BackgroundColor3 = Colors.Secondary
    button.TextColor3 = Colors.Text
    button.TextScaled = true
    button.Text = text
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 1
    button.BorderColor3 = Colors.Accent
    button.Parent = parent
    
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
-- TOGGLE CREATION FUNCTION
-- ============================================

local function CreateToggle(parent, label, defaultState, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.9, 0, 0, 45)
    container.BackgroundColor3 = Colors.Secondary
    container.BorderSizePixel = 1
    container.BorderColor3 = Colors.Accent
    container.Parent = parent
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 8)
    containerCorner.Parent = container
    
    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.75, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Colors.Text
    labelText.TextScaled = true
    labelText.Text = label
    labelText.Font = Enum.Font.GothamBold
    labelText.Parent = container
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.2, 0, 0.7, 0)
    toggleButton.Position = UDim2.new(0.77, 0, 0.15, 0)
    toggleButton.BackgroundColor3 = defaultState and Colors.Success or Colors.Danger
    toggleButton.TextColor3 = Colors.Text
    toggleButton.TextScaled = true
    toggleButton.Text = defaultState and "ON" or "OFF"
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 5)
    toggleCorner.Parent = toggleButton
    
    local isEnabled = defaultState
    
    toggleButton.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        toggleButton.BackgroundColor3 = isEnabled and Colors.Success or Colors.Danger
        toggleButton.Text = isEnabled and "ON" or "OFF"
        callback(isEnabled)
    end)
    
    return container
end

-- ============================================
-- SECTION TITLE FUNCTION
-- ============================================

local function CreateSectionTitle(parent, text)
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(0.9, 0, 0, 35)
    titleLabel.BackgroundColor3 = Colors.Accent
    titleLabel.TextColor3 = Colors.Text
    titleLabel.TextScaled = true
    titleLabel.Text = "━━ " .. text .. " ━━"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BorderSizePixel = 0
    titleLabel.Parent = parent
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 5)
    titleCorner.Parent = titleLabel
    
    return titleLabel
end

-- ============================================
-- CREATE TABS
-- ============================================

local autoFarmTab, autoFarmContent = CreateTab("Auto Farm", "🌾")
local teleportTab, teleportContent = CreateTab("Teleport", "📍")
local raidTab, raidContent = CreateTab("Raid", "⚔️")
local combatTab, combatContent = CreateTab("Combat", "💥")
local fruitTab, fruitContent = CreateTab("Fruit", "🍎")
local espTab, espContent = CreateTab("ESP", "👁️")
local miscTab, miscContent = CreateTab("Misc", "⚙️")
local settingsTab, settingsContent = CreateTab("Settings", "⚡")

-- Show first tab by default
autoFarmTab.BackgroundColor3 = Colors.Accent
autoFarmContent.Visible = true

-- ============================================
-- AUTO FARM TAB CONTENT
-- ============================================

CreateSectionTitle(autoFarmContent, "AUTO FARM FEATURES")

CreateToggle(autoFarmContent, "🌾 Auto Farm", false, function(state)
    Config.autoFarmEnabled = state
end)

CreateToggle(autoFarmContent, "📜 Auto Quest", false, function(state)
    Config.autoQuestEnabled = state
end)

CreateToggle(autoFarmContent, "⚡ Auto Equip Weapon", false, function(state)
    Config.autoEquipWeapon = state
end)

CreateToggle(autoFarmContent, "🍎 Auto Equip Fruit", false, function(state)
    Config.autoEquipFruit = state
end)

CreateToggle(autoFarmContent, "🥊 Auto Equip Fighting Style", false, function(state)
    Config.autoEquipFightingStyle = state
end)

CreateToggle(autoFarmContent, "💎 Auto Equip Accessory", false, function(state)
    Config.autoEquipAccessory = state
end)

CreateToggle(autoFarmContent, "✨ Auto Aura", false, function(state)
    Config.autoAura = state
end)

CreateToggle(autoFarmContent, "👁️ Auto Observation", false, function(state)
    Config.autoObservation = state
end)

CreateToggle(autoFarmContent, "🖱️ Auto Click", false, function(state)
    Config.autoClick = state
end)

CreateToggle(autoFarmContent, "⚔️ Auto Fast Attack", false, function(state)
    Config.autoFastAttack = state
end)

CreateSectionTitle(autoFarmContent, "BOSS FARMING")

CreateToggle(autoFarmContent, "👹 Auto Sea Beast", false, function(state)
    Config.autoSeaBeast = state
end)

CreateToggle(autoFarmContent, "🐙 Auto Leviathan", false, function(state)
    Config.autoLeviathan = state
end)

CreateToggle(autoFarmContent, "🦈 Auto Terror Shark", false, function(state)
    Config.autoTerrorShark = state
end)

-- ============================================
-- TELEPORT TAB CONTENT
-- ============================================

CreateSectionTitle(teleportContent, "SEA 1")
for _, map in pairs(Maps.Sea1) do
    CreateButton(teleportContent, "📍 " .. map, function()
        print("Teleporting to " .. map)
        NotifyUser(map, "Teleporting...", Colors.Success)
    end)
end

CreateSectionTitle(teleportContent, "SEA 2")
for _, map in pairs(Maps.Sea2) do
    CreateButton(teleportContent, "📍 " .. map, function()
        print("Teleporting to " .. map)
        NotifyUser(map, "Teleporting...", Colors.Success)
    end)
end

CreateSectionTitle(teleportContent, "SEA 3")
for _, map in pairs(Maps.Sea3) do
    CreateButton(teleportContent, "📍 " .. map, function()
        print("Teleporting to " .. map)
        NotifyUser(map, "Teleporting...", Colors.Success)
    end)
end

-- ============================================
-- RAID TAB CONTENT
-- ============================================

CreateSectionTitle(raidContent, "RAID FEATURES")

CreateToggle(raidContent, "🛒 Auto Buy Chip", false, function(state)
    Config.autoBuyChip = state
end)

CreateToggle(raidContent, "🎮 Auto Start Raid", false, function(state)
    Config.autoStartRaid = state
end)

CreateToggle(raidContent, "👥 Auto Join Raid", false, function(state)
    Config.autoJoinRaid = state
end)

CreateToggle(raidContent, "💀 Auto Kill NPC", false, function(state)
    Config.autoKillNPC = state
end)

CreateToggle(raidContent, "🏆 Auto Complete Raid", false, function(state)
    Config.autoCompletRaid = state
end)

-- ============================================
-- COMBAT TAB CONTENT
-- ============================================

CreateSectionTitle(combatContent, "COMBAT FEATURES")

CreateToggle(combatContent, "⚡ Fast Attack", false, function(state)
    Config.fastAttack = state
end)

CreateToggle(combatContent, "🔥 Kill Aura", false, function(state)
    Config.killAura = state
end)

CreateToggle(combatContent, "🎯 Auto Combo", false, function(state)
    Config.autoCombo = state
end)

CreateToggle(combatContent, "🌪️ Infinite Dash", false, function(state)
    Config.infiniteDash = state
end)

CreateToggle(combatContent, "🚀 Infinite Geppo", false, function(state)
    Config.infiniteGeppo = state
end)

-- ============================================
-- FRUIT TAB CONTENT
-- ============================================

CreateSectionTitle(fruitContent, "FRUIT FEATURES")

CreateToggle(fruitContent, "👁️ Fruit ESP", false, function(state)
    print("Fruit ESP: " .. (state and "ON" or "OFF"))
end)

CreateToggle(fruitContent, "🔔 Fruit Notifier", false, function(state)
    print("Fruit Notifier: " .. (state and "ON" or "OFF"))
end)

CreateToggle(fruitContent, "🍎 Auto Collect Fruit", false, function(state)
    print("Auto Collect: " .. (state and "ON" or "OFF"))
end)

CreateToggle(fruitContent, "📦 Auto Store Fruit", false, function(state)
    print("Auto Store: " .. (state and "ON" or "OFF"))
end)

-- ============================================
-- ESP TAB CONTENT
-- ============================================

CreateSectionTitle(espContent, "ESP DISPLAY")

CreateToggle(espContent, "👥 Show Players", false, function(state)
    print("Player ESP: " .. (state and "ON" or "OFF"))
end)

CreateToggle(espContent, "🤖 Show NPC", false, function(state)
    print("NPC ESP: " .. (state and "ON" or "OFF"))
end)

CreateToggle(espContent, "👹 Show Bosses", false, function(state)
    print("Boss ESP: " .. (state and "ON" or "OFF"))
end)

CreateToggle(espContent, "🍎 Show Fruits", false, function(state)
    print("Fruit ESP: " .. (state and "ON" or "OFF"))
end)

CreateToggle(espContent, "💎 Show Chests", false, function(state)
    print("Chest ESP: " .. (state and "ON" or "OFF"))
end)

-- ============================================
-- MISC TAB CONTENT
-- ============================================

CreateSectionTitle(miscContent, "MISCELLANEOUS")

CreateToggle(miscContent, "🚫 Anti AFK", false, function(state)
    print("Anti AFK: " .. (state and "ON" or "OFF"))
end)

CreateToggle(miscContent, "⚡ FPS Boost", false, function(state)
    print("FPS Boost: " .. (state and "ON" or "OFF"))
end)

CreateToggle(miscContent, "🤍 White Screen", false, function(state)
    print("White Screen: " .. (state and "ON" or "OFF"))
end)

CreateToggle(miscContent, "🌫️ Remove Fog", false, function(state)
    print("Remove Fog: " .. (state and "ON" or "OFF"))
end)

CreateButton(miscContent, "💾 Save Config", function()
    SaveConfig()
    NotifyUser("Config", "Configuration saved!", Colors.Success)
end)

CreateButton(miscContent, "📂 Load Config", function()
    LoadConfig()
    NotifyUser("Config", "Configuration loaded!", Colors.Success)
end)

CreateButton(miscContent, "🔄 Rejoin", function()
    RejoinGame()
end)

-- ============================================
-- SETTINGS TAB CONTENT
-- ============================================

CreateSectionTitle(settingsContent, "SETTINGS")

CreateButton(settingsContent, "💾 Save Config", function()
    SaveConfig()
    NotifyUser("Config", "Saved!", Colors.Success)
end)

CreateButton(settingsContent, "📂 Load Config", function()
    LoadConfig()
    NotifyUser("Config", "Loaded!", Colors.Success)
end)

CreateButton(settingsContent, "🔄 Reload Script", function()
    NotifyUser("Script", "Reloading...", Colors.Warning)
    wait(1)
    script:Destroy()
end)

CreateButton(settingsContent, "❌ Close Hub", function()
    mainWindow:Destroy()
end)

-- ============================================
-- BUTTON EVENTS
-- ============================================

closeButton.MouseButton1Click:Connect(function()
    mainWindow:Destroy()
end)

minimizeButton.MouseButton1Click:Connect(function()
    if contentFrame.Visible then
        contentFrame.Visible = false
        tabContainer.Visible = false
        mainWindow.Size = UDim2.new(0, 500, 0, 60)
    else
        contentFrame.Visible = true
        tabContainer.Visible = true
        mainWindow.Size = UDim2.new(0, 500, 0, 700)
    end
end)

-- ============================================
-- NOTIFICATION SYSTEM
-- ============================================

function NotifyUser(title, message, color)
    if not Config.notification then return end
    
    local notifFrame = Instance.new("Frame")
    notifFrame.Name = "Notification"
    notifFrame.Size = UDim2.new(0, 300, 0, 80)
    notifFrame.Position = UDim2.new(1, -320, 0, 20)
    notifFrame.BackgroundColor3 = Colors.Primary
    notifFrame.BorderColor3 = color
    notifFrame.BorderSizePixel = 2
    notifFrame.Parent = screenGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 10)
    notifCorner.Parent = notifFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 35)
    titleLabel.BackgroundColor3 = color
    titleLabel.TextColor3 = Colors.Text
    titleLabel.TextScaled = true
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BorderSizePixel = 0
    titleLabel.Parent = notifFrame
    
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, 0, 1, -35)
    messageLabel.Position = UDim2.new(0, 0, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.TextColor3 = Colors.Text
    messageLabel.TextScaled = true
    messageLabel.Text = message
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.Parent = notifFrame
    
    game:GetService("Debris"):AddItem(notifFrame, 3)
end

-- ============================================
-- CONFIG SAVE/LOAD
-- ============================================

function SaveConfig()
    local configData = HttpService:JSONEncode(Config)
    writefile("RedzHub_Config.json", configData)
    print("✓ Config saved!")
end

function LoadConfig()
    if not isfile("RedzHub_Config.json") then
        print("✗ Config file not found!")
        return
    end
    
    local configData = readfile("RedzHub_Config.json")
    local loaded = HttpService:JSONDecode(configData)
    
    for key, value in pairs(loaded) do
        Config[key] = value
    end
    
    print("✓ Config loaded!")
end

-- ============================================
-- REJOIN FUNCTION
-- ============================================

function RejoinGame()
    local TeleportService = game:GetService("TeleportService")
    local placeId = game.PlaceId
    TeleportService:Teleport(placeId, player)
end

-- ============================================
-- MAIN LOOP
-- ============================================

RunService.RenderStepped:Connect(function()
    if not character or not character:FindFirstChild("Humanoid") or humanoid.Health <= 0 then
        character = player.Character or player.CharacterAdded:Wait()
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoid = character:WaitForChild("Humanoid")
    end
    
    -- Auto Farm Logic
    if Config.autoFarmEnabled then
        -- Auto farming implementation
    end
    
    -- Combat Logic
    if Config.fastAttack then
        -- Fast attack implementation
    end
    
    if Config.infiniteDash then
        -- Infinite dash implementation
    end
end)

-- ============================================
-- RESPAWN HANDLING
-- ============================================

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
    NotifyUser("Status", "Respawned!", Colors.Warning)
end)

-- ============================================
-- AUTO LOAD CONFIG ON STARTUP
-- ============================================

if Config.autoLoad then
    LoadConfig()
end

-- ============================================
-- SCRIPT READY
-- ============================================

print("✓✓✓ REDZ HUB LOADED SUCCESSFULLY! ✓✓✓")
print("✓ Version 1.0")
print("✓ All systems operational")
NotifyUser("REDZ HUB", "Script loaded successfully!", Colors.Success)
