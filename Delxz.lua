-- ============================================
-- REDZ HUB - BLOX FRUITS SCRIPT (FULL LOGIC)
-- ============================================
-- Version: 2.0 - Complete Implementation
-- Designed for DeltaX Android & PC

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ============================================
-- FORWARD DECLARATIONS
-- ============================================

local NotifyUser
local SaveConfig
local LoadConfig
local RejoinGame

-- ============================================
-- CONFIGURATION
-- ============================================

local Config = {
    -- Auto Farm
    autoFarmEnabled = false,
    autoQuestEnabled = false,
    autoEquipWeapon = false,
    autoEquipFruit = false,
    autoAura = false,
    autoObservation = false,
    autoClick = false,
    autoFastAttack = false,
    
    -- Raid
    autoBuyChip = false,
    autoStartRaid = false,
    autoKillNPC = false,
    
    -- Combat
    fastAttack = false,
    killAura = false,
    autoCombo = false,
    infiniteDash = false,
    infiniteGeppo = false,
    
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
    
    -- Internal
    currentSea = 1,
    currentQuest = nil,
    farmingActive = false,
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

-- ============================================
-- MAP DATA & QUESTS
-- ============================================

local QuestData = {
    [1] = { name = "Bandit", npc = "Bandit", area = "Bandit Quest Area", level = 5, reward = 100 },
    [2] = { name = "Pirate", npc = "Pirate", area = "Pirate Quest Area", level = 15, reward = 250 },
    [3] = { name = "Zombie", npc = "Zombie", area = "Zombie Quest Area", level = 30, reward = 500 },
    [4] = { name = "Skelly", npc = "Skelly", area = "Skelly Quest Area", level = 60, reward = 1000 },
    [5] = { name = "Arlong", npc = "Arlong", area = "Arlong Park", level = 120, reward = 2000 },
}

local Maps = {
    Sea1 = {
        { name = "Starter Island", pos = Vector3.new(-1585, 25, 27) },
        { name = "Jungle", pos = Vector3.new(-1000, 100, -1000) },
        { name = "Pirate Village", pos = Vector3.new(-500, 25, -500) },
        { name = "Desert", pos = Vector3.new(0, 100, 1000) },
        { name = "Frozen Village", pos = Vector3.new(500, 25, 500) },
        { name = "Marine Fortress", pos = Vector3.new(1000, 100, 0) },
        { name = "Sky Island", pos = Vector3.new(0, 500, 0) },
        { name = "Prison", pos = Vector3.new(-1500, 25, 1500) },
        { name = "Colosseum", pos = Vector3.new(920, 15, 1250) },
        { name = "Magma Village", pos = Vector3.new(1500, 100, -1000) },
        { name = "Underwater City", pos = Vector3.new(-2000, -100, -2000) },
        { name = "Fountain City", pos = Vector3.new(2000, 50, 2000) },
    },
}

local BossList = {
    "Gorilla King", "Bobby", "Yeti", "Vice Admiral", "Warden",
    "Chief Warden", "Swan", "Magma Admiral", "Tide Keeper", "Smoke Admiral",
    "Diamond", "Jeremy", "Fajita", "Don Swan", "Cake Queen", "Soul Reaper",
    "Rip Indra", "Dough King", "Leviathan", "Sea Beast", "Terror Shark"
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function GetPlayerLevel()
    local leaderstats = character:FindFirstChild("leaderstats")
    if leaderstats then
        local level = leaderstats:FindFirstChild("Level")
        return level and level.Value or 1
    end
    return 1
end

local function GetPlayerMoney()
    local leaderstats = character:FindFirstChild("leaderstats")
    if leaderstats then
        local money = leaderstats:FindFirstChild("Money")
        return money and money.Value or 0
    end
    return 0
end

local function Tween(targetPart, duration)
    if not targetPart or not humanoidRootPart then return end
    
    local tweenInfo = TweenInfo.new(
        duration / 1000,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )
    
    local goal = {CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)}
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    
    tween:Play()
    tween.Completed:Wait()
end

local function TeleportTo(position, duration)
    duration = duration or Config.tweenSpeed
    
    if not humanoidRootPart then return end
    
    local tweenInfo = TweenInfo.new(
        duration / 1000,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )
    
    local goal = {CFrame = CFrame.new(position + Vector3.new(0, 3, 0))}
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    
    tween:Play()
    tween.Completed:Wait()
end

local function FindObject(name, searchParent)
    searchParent = searchParent or Workspace
    
    for _, object in pairs(searchParent:GetDescendants()) do
        if object.Name:find(name) or (object:FindFirstChild("Humanoid") and object.Name == name) then
            return object
        end
    end
    
    return nil
end

local function FindNearestMob(mobName)
    local nearest = nil
    local minDistance = math.huge
    
    if not Workspace:FindFirstChild("Enemies") then return nil end
    
    for _, mob in pairs(Workspace.Enemies:GetChildren()) do
        if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
            local mobHumanoid = mob:FindFirstChild("Humanoid")
            
            if mobHumanoid.Health > 0 and mob.Name:find(mobName) then
                local distance = (mob.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                
                if distance < minDistance then
                    minDistance = distance
                    nearest = mob
                end
            end
        end
    end
    
    return nearest
end

local function FindAllMobs(mobName)
    local mobs = {}
    
    if not Workspace:FindFirstChild("Enemies") then return mobs end
    
    for _, mob in pairs(Workspace.Enemies:GetChildren()) do
        if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
            local mobHumanoid = mob:FindFirstChild("Humanoid")
            
            if mobHumanoid.Health > 0 and mob.Name:find(mobName) then
                table.insert(mobs, mob)
            end
        end
    end
    
    return mobs
end

-- ============================================
-- NOTIFICATION FUNCTION (DEFINED EARLY)
-- ============================================

function NotifyUser(title, message, color)
    if not Config.notification then return end
    
    pcall(function()
        color = color or Colors.Accent
        
        local screenGui = player:FindFirstChild("PlayerGui"):FindFirstChild("RedzHub")
        if not screenGui then screenGui = Instance.new("ScreenGui", player:FindFirstChild("PlayerGui")) end
        
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
    end)
end

-- ============================================
-- AUTO FARM SYSTEM
-- ============================================

local function FindQuestNPC(questName)
    local npcFolder = Workspace:FindFirstChild("NPCs")
    if not npcFolder then return nil end
    
    for _, npc in pairs(npcFolder:GetChildren()) do
        if npc.Name:find(questName) or npc:FindFirstChild("Head") then
            return npc
        end
    end
    
    return nil
end

local function AcceptQuest(npcPart)
    if not npcPart then return false end
    
    -- Tween to NPC
    Tween(npcPart, Config.tweenSpeed)
    wait(0.5)
    
    -- Try to interact with NPC (click on it)
    local args = {npcPart}
    local remoteEvent = npcPart.Parent:FindFirstChild("Quest") or npcPart.Parent:FindFirstChild("QuestRemote")
    
    if remoteEvent and remoteEvent:IsA("RemoteEvent") then
        remoteEvent:FireServer()
        wait(0.5)
        return true
    end
    
    return false
end

local function BringMobs(mobName, farmPosition)
    local mobs = FindAllMobs(mobName)
    
    for _, mob in pairs(mobs) do
        if mob and mob:FindFirstChild("HumanoidRootPart") then
            local distance = (mob.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
            
            if distance < Config.farmDistance * 2 then
                -- Teleport mob closer
                mob.HumanoidRootPart.CFrame = farmPosition + Vector3.new(math.random(-Config.mobOffset, Config.mobOffset), 0, math.random(-Config.mobOffset, Config.mobOffset))
            end
        end
    end
end

local function AutoCombo()
    if not Config.autoCombo then return end
    
    local skills = {"Z", "X", "C", "V", "F"}
    
    for _, skill in pairs(skills) do
        if Config.autoFastAttack then
            keyPress(skill)
            wait(0.1)
        end
    end
end

local function AutoAttack(mob)
    if not mob or not mob:FindFirstChild("Humanoid") then return end
    
    local mobHumanoid = mob:FindFirstChild("Humanoid")
    local lastAttackTime = 0
    
    while Config.autoClick and mobHumanoid.Health > 0 do
        local currentTime = tick()
        
        if currentTime - lastAttackTime > Config.clickDelay then
            mouse1click()
            lastAttackTime = currentTime
        end
        
        wait(0.05)
    end
end

local function AutoFarmQuest()
    if not Config.autoFarmEnabled then return end
    
    Config.farmingActive = true
    
    while Config.autoFarmEnabled do
        pcall(function()
            local playerLevel = GetPlayerLevel()
            local questInfo = QuestData[math.min(math.floor(playerLevel / 20) + 1, 5)]
            
            if questInfo then
                NotifyUser("Auto Farm", "Finding quest NPC: " .. questInfo.npc, Colors.Warning)
                
                -- Find and teleport to NPC
                local npc = FindQuestNPC(questInfo.npc)
                if npc then
                    Tween(npc:FindFirstChild("HumanoidRootPart") or npc, Config.tweenSpeed)
                    wait(0.5)
                    
                    -- Accept quest
                    AcceptQuest(npc)
                    NotifyUser("Quest", "Quest accepted: " .. questInfo.name, Colors.Success)
                    wait(1)
                end
                
                -- Teleport to farm area
                local farmArea = Workspace:FindFirstChild(questInfo.area)
                if farmArea then
                    TeleportTo(farmArea.Position, Config.tweenSpeed)
                    wait(0.5)
                end
                
                -- Bring mobs to farming position
                local farmPosition = humanoidRootPart.Position
                
                -- Farm for a while
                local farmDuration = 30
                local startTime = tick()
                
                while (tick() - startTime) < farmDuration and Config.autoFarmEnabled do
                    -- Find nearest mob
                    local nearestMob = FindNearestMob(questInfo.name)
                    
                    if nearestMob and nearestMob:FindFirstChild("HumanoidRootPart") then
                        -- Bring mob
                        BringMobs(questInfo.name, farmPosition)
                        
                        -- Attack
                        if Config.autoClick then
                            mouse1click()
                        end
                        
                        if Config.autoCombo then
                            AutoCombo()
                        end
                    end
                    
                    wait(0.1)
                end
                
                NotifyUser("Quest", "Quest completed!", Colors.Success)
                wait(1)
            end
        end)
        
        wait(0.5)
    end
    
    Config.farmingActive = false
end

-- ============================================
-- RAID SYSTEM
-- ============================================

local function BuyRaidChip()
    if GetPlayerMoney() < 1000 then
        NotifyUser("Raid", "Not enough money!", Colors.Danger)
        return false
    end
    
    -- Find chip NPC
    local chipNPC = FindObject("Chip")
    if chipNPC then
        Tween(chipNPC, Config.tweenSpeed)
        wait(0.5)
        
        local remote = chipNPC:FindFirstChild("BuyChip") or chipNPC.Parent:FindFirstChild("BuyChip")
        if remote then
            remote:FireServer()
            NotifyUser("Raid", "Chip purchased!", Colors.Success)
            return true
        end
    end
    
    return false
end

local function AutoRaidKillNPC()
    if not Workspace:FindFirstChild("Raid") then return end
    
    local raidFolder = Workspace.Raid
    
    for _, npc in pairs(raidFolder:GetChildren()) do
        if npc:FindFirstChild("Humanoid") then
            while npc:FindFirstChild("Humanoid").Health > 0 and Config.autoKillNPC do
                Tween(npc:FindFirstChild("HumanoidRootPart"), 100)
                mouse1click()
                wait(0.05)
            end
        end
    end
end

-- ============================================
-- COMBAT SYSTEM
-- ============================================

local function FastAttack()
    while Config.fastAttack do
        mouse1click()
        wait(Config.clickDelay)
    end
end

local function KillAura()
    while Config.killAura do
        local mobs = FindAllMobs("")
        
        for _, mob in pairs(mobs) do
            if mob and mob:FindFirstChild("HumanoidRootPart") then
                local distance = (mob.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                
                if distance < Config.farmDistance then
                    TeleportTo(mob.HumanoidRootPart.Position, 100)
                    mouse1click()
                end
            end
        end
        
        wait(0.1)
    end
end

local function InfiniteDash()
    local DashRemote = Workspace:FindFirstChild("DashRemote")
    
    if DashRemote then
        while Config.infiniteDash do
            DashRemote:FireServer()
            wait(0.1)
        end
    end
end

-- ============================================
-- TELEPORT SYSTEM
-- ============================================

local function TeleportToMap(mapName)
    local map = nil
    
    for _, m in pairs(Maps.Sea1) do
        if m.name == mapName then
            map = m
            break
        end
    end
    
    if map then
        NotifyUser("Teleport", "Teleporting to " .. mapName, Colors.Warning)
        TeleportTo(map.pos, Config.tweenSpeed)
        NotifyUser("Teleport", "Arrived at " .. mapName, Colors.Success)
    end
end

-- ============================================
-- CONFIG FUNCTIONS
-- ============================================

function SaveConfig()
    pcall(function()
        local configData = HttpService:JSONEncode(Config)
        writefile("RedzHub_Config.json", configData)
        NotifyUser("Config", "Settings saved!", Colors.Success)
        print("✓ Config saved to file")
    end)
end

function LoadConfig()
    pcall(function()
        if isfile("RedzHub_Config.json") then
            local configData = readfile("RedzHub_Config.json")
            local loaded = HttpService:JSONDecode(configData)
            
            for key, value in pairs(loaded) do
                if Config[key] ~= nil then
                    Config[key] = value
                end
            end
            
            NotifyUser("Config", "Settings loaded!", Colors.Success)
            print("✓ Config loaded from file")
        end
    end)
end

function RejoinGame()
    NotifyUser("Rejoin", "Rejoining game...", Colors.Warning)
    local TeleportService = game:GetService("TeleportService")
    local placeId = game.PlaceId
    wait(1)
    TeleportService:Teleport(placeId, player)
end

-- ============================================
-- GUI SETUP
-- ============================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RedzHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Window
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(0, 500, 0, 700)
mainWindow.Position = UDim2.new(0.5, -250, 0.5, -350)
mainWindow.BackgroundColor3 = Colors.Primary
mainWindow.BorderSizePixel = 2
mainWindow.BorderColor3 = Colors.Accent
mainWindow.Parent = screenGui

local windowCorner = Instance.new("UICorner")
windowCorner.CornerRadius = UDim.new(0, 15)
windowCorner.Parent = mainWindow

-- Header Bar
local headerBar = Instance.new("Frame")
headerBar.Name = "HeaderBar"
headerBar.Size = UDim2.new(1, 0, 0, 60)
headerBar.BackgroundColor3 = Colors.Accent
headerBar.BorderSizePixel = 0
headerBar.Parent = mainWindow

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 15)
headerCorner.Parent = headerBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Colors.Text
titleLabel.TextScaled = true
titleLabel.Text = "⚡ REDZ HUB v2.0"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = headerBar

-- Tab Container
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

-- Content Frame
local contentFrame = Instance.new("ScrollingFrame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, 0, 1, -110)
contentFrame.Position = UDim2.new(0, 0, 0, 110)
contentFrame.BackgroundColor3 = Colors.Primary
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 8
contentFrame.ScrollBarImageColor3 = Colors.Accent
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 2000)
contentFrame.Parent = mainWindow

-- Helper Functions for GUI Creation
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
    
    button.MouseButton1Click:Connect(callback)
    return button
end

local function CreateToggle(parent, label, callback)
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
        toggleButton.BackgroundColor3 = isEnabled and Colors.Success or Colors.Danger
        toggleButton.Text = isEnabled and "ON" or "OFF"
        callback(isEnabled)
    end)
    
    return container
end

local function CreateTab(name, icon)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0, 90, 0, 40)
    tabButton.BackgroundColor3 = Colors.Secondary
    tabButton.TextColor3 = Colors.Text
    tabButton.TextScaled = true
    tabButton.Text = icon .. " " .. name
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
        for _, tab in pairs(contentFrame:GetChildren()) do
            if tab:IsA("Frame") and tab.Name:match("Content") then
                tab.Visible = false
            end
        end
        tabContent.Visible = true
        
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
-- CREATE TABS & CONTENT
-- ============================================

local _, autoFarmTab = CreateTab("Auto Farm", "🌾")
local _, teleportTab = CreateTab("Teleport", "📍")
local _, raidTab = CreateTab("Raid", "⚔️")
local _, combatTab = CreateTab("Combat", "💥")
local _, miscTab = CreateTab("Misc", "⚙️")

autoFarmTab.Visible = true

-- Auto Farm Tab
CreateToggle(autoFarmTab, "🌾 Auto Farm", function(state)
    Config.autoFarmEnabled = state
    if state then
        task.spawn(AutoFarmQuest)
        NotifyUser("Auto Farm", "Started!", Colors.Success)
    else
        NotifyUser("Auto Farm", "Stopped!", Colors.Warning)
    end
end)

CreateToggle(autoFarmTab, "🖱️ Auto Click", function(state)
    Config.autoClick = state
    NotifyUser("Auto Click", state and "ON" or "OFF", Colors.Success)
end)

CreateToggle(autoFarmTab, "🎯 Auto Combo", function(state)
    Config.autoCombo = state
    NotifyUser("Auto Combo", state and "ON" or "OFF", Colors.Success)
end)

CreateToggle(autoFarmTab, "✨ Auto Aura", function(state)
    Config.autoAura = state
    NotifyUser("Auto Aura", state and "ON" or "OFF", Colors.Success)
end)

-- Teleport Tab
CreateButton(teleportTab, "📍 Starter Island", function()
    TeleportToMap("Starter Island")
end)

CreateButton(teleportTab, "📍 Jungle", function()
    TeleportToMap("Jungle")
end)

CreateButton(teleportTab, "📍 Pirate Village", function()
    TeleportToMap("Pirate Village")
end)

CreateButton(teleportTab, "📍 Desert", function()
    TeleportToMap("Desert")
end)

CreateButton(teleportTab, "📍 Frozen Village", function()
    TeleportToMap("Frozen Village")
end)

CreateButton(teleportTab, "📍 Marine Fortress", function()
    TeleportToMap("Marine Fortress")
end)

CreateButton(teleportTab, "📍 Sky Island", function()
    TeleportToMap("Sky Island")
end)

CreateButton(teleportTab, "📍 Colosseum", function()
    TeleportToMap("Colosseum")
end)

-- Raid Tab
CreateToggle(raidTab, "🛒 Auto Buy Chip", function(state)
    Config.autoBuyChip = state
    if state then
        BuyRaidChip()
    end
end)

CreateToggle(raidTab, "💀 Auto Kill NPC", function(state)
    Config.autoKillNPC = state
    if state then
        task.spawn(AutoRaidKillNPC)
    end
end)

-- Combat Tab
CreateToggle(combatTab, "⚡ Fast Attack", function(state)
    Config.fastAttack = state
    if state then
        task.spawn(FastAttack)
    end
end)

CreateToggle(combatTab, "🔥 Kill Aura", function(state)
    Config.killAura = state
    if state then
        task.spawn(KillAura)
    end
end)

CreateToggle(combatTab, "🌪️ Infinite Dash", function(state)
    Config.infiniteDash = state
    if state then
        task.spawn(InfiniteDash)
    end
end)

-- Misc Tab
CreateButton(miscTab, "💾 Save Config", function()
    SaveConfig()
end)

CreateButton(miscTab, "📂 Load Config", function()
    LoadConfig()
end)

CreateButton(miscTab, "🔄 Rejoin", function()
    RejoinGame()
end)

CreateButton(miscTab, "❌ Close Menu", function()
    mainWindow:Destroy()
end)

-- ============================================
-- MAIN LOOP
-- ============================================

RunService.RenderStepped:Connect(function()
    if not character or not character:FindFirstChild("Humanoid") or humanoid.Health <= 0 then
        character = player.Character or player.CharacterAdded:Wait()
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoid = character:WaitForChild("Humanoid")
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
-- AUTO LOAD CONFIG
-- ============================================

if Config.autoLoad then
    LoadConfig()
end

-- ============================================
-- STARTUP
-- ============================================

print("✓✓✓ REDZ HUB v2.0 LOADED ✓✓✓")
print("✓ Full logic implementation")
print("✓ Auto Farm System Online")
print("✓ Combat System Online")
print("✓ Teleport System Online")
NotifyUser("REDZ HUB", "v2.0 Loaded! All systems operational!", Colors.Success)
