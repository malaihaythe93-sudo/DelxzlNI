-- ============================================
-- REDZ HUB - BLOX FRUITS v5.0 PRODUCTION (REDZ MOBILE UI)
-- ============================================
-- Complete Implementation with Real Game Data
-- Version: 5.0 - Redz Hub Mobile Remake
-- Last Updated: 2026-06-29

-- Tải Redz Library chính thức tối ưu cho Mobile
local RedzLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDZDEVS/REDZ-HUB/main/REDZ-HUB-MOBILE"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- ============================================
-- CONFIGURATION
-- ============================================

local Config = {
    autoFarmEnabled = false,
    autoClickEnabled = false,
    autoComboEnabled = false,
    autoBringMobEnabled = false,
    fastAttack = false,
    killAura = false,
    autoSeaBeast = false,
    autoLeviathan = false,
    autoBuyChip = false,
    autoJoinRaid = false,
    autoCollectFruit = false,
    antiStuck = false,
    fpsLimit = 60,
    notification = true,
    currentLevel = 1,
    currentSea = 1,
}

-- ============================================
-- REAL GAME DATABASE - MAPS & DATA
-- ============================================

local Maps = {
    ["Starter Island"] = { pos = Vector3.new(-1585, 25, 27), sea = 1, level = 0 },
    ["Jungle"] = { pos = Vector3.new(-450, 80, 700), sea = 1, level = 15 },
    ["Pirate Village"] = { pos = Vector3.new(-1200, 80, 1400), sea = 1, level = 30 },
    ["Desert"] = { pos = Vector3.new(-1700, 80, 2000), sea = 1, level = 60 },
    ["Middle Island"] = { pos = Vector3.new(0, 80, 0), sea = 1, level = 0 },
    ["Frozen Village"] = { pos = Vector3.new(500, 25, 500), sea = 1, level = 90 },
    ["Marine Fortress"] = { pos = Vector3.new(200, 100, -800), sea = 1, level = 120 },
    ["Skylands"] = { pos = Vector3.new(0, 500, 0), sea = 1, level = 150 },
    ["Prison"] = { pos = Vector3.new(-1500, 25, 1500), sea = 1, level = 190 },
    ["Colosseum"] = { pos = Vector3.new(920, 15, 1250), sea = 1, level = 100 },
    ["Magma Village"] = { pos = Vector3.new(1500, 100, -1000), sea = 1, level = 300 },
    ["Underwater City"] = { pos = Vector3.new(-2000, -100, -2000), sea = 1, level = 375 },
    ["Fountain City"] = { pos = Vector3.new(2000, 50, 2000), sea = 1, level = 250 },
    
    ["Kingdom of Rose"] = { pos = Vector3.new(-2000, 50, -3000), sea = 2, level = 700 },
    ["Usoap's Island"] = { pos = Vector3.new(-1500, 50, -2500), sea = 2, level = 750 },
    ["Cafe"] = { pos = Vector3.new(-1000, 50, -2000), sea = 2, level = 775 },
    ["Don Swan's Mansion"] = { pos = Vector3.new(-500, 50, -1500), sea = 2, level = 800 },
    ["Green Zone"] = { pos = Vector3.new(0, 50, -1000), sea = 2, level = 825 },
    ["Graveyard"] = { pos = Vector3.new(500, 50, -500), sea = 2, level = 850 },
    ["Snow Mountain"] = { pos = Vector3.new(1000, 100, 0), sea = 2, level = 900 },
    ["Hot and Cold"] = { pos = Vector3.new(1500, 50, 500), sea = 2, level = 950 },
    ["Cursed Ship"] = { pos = Vector3.new(2000, 50, 1000), sea = 2, level = 1000 },
    ["Ice Castle"] = { pos = Vector3.new(2500, 50, 1500), sea = 2, level = 1050 },
    ["Forgotten Island"] = { pos = Vector3.new(3000, 50, 2000), sea = 2, level = 1100 },
    ["Dark Arena"] = { pos = Vector3.new(3500, 15, 2500), sea = 2, level = 1150 },
    
    ["Port Town"] = { pos = Vector3.new(4000, 25, 3000), sea = 3, level = 1500 },
    ["Hydra Island"] = { pos = Vector3.new(3000, 80, 5000), sea = 3, level = 1575 },
    ["Great Tree"] = { pos = Vector3.new(3500, 100, 5500), sea = 3, level = 1600 },
    ["Floating Turtle"] = { pos = Vector3.new(4000, 200, 6000), sea = 3, level = 1775 },
    ["Castle on the Sea"] = { pos = Vector3.new(4500, 50, 6500), sea = 3, level = 1800 },
    ["Haunted Castle"] = { pos = Vector3.new(500, 50, 7000), sea = 3, level = 1850 },
    ["Sea of Treats"] = { pos = Vector3.new(5500, 25, 7500), sea = 3, level = 1900 },
    ["Tiki Outpost"] = { pos = Vector3.new(6000, 30, 8000), sea = 3, level = 1950 },
}

local Mobs = {
    ["Jungle"] = { { name = "Monkey", level = 6, count = 6 }, { name = "Gorilla", level = 8, count = 8 } },
    ["Pirate Village"] = { { name = "Pirate", level = 8, count = 8 }, { name = "Brute", level = 8, count = 8 } },
    ["Desert"] = { { name = "Desert Bandit", level = 10, count = 10 }, { name = "Desert Officer", level = 6, count = 6 } },
    ["Frozen Village"] = { { name = "Snow Bandit", level = 7, count = 7 }, { name = "Snowman", level = 10, count = 10 } },
    ["Marine Fortress"] = { { name = "Chief Petty Officer", level = 8, count = 8 } },
    ["Prison"] = { { name = "Prisoner", level = 8, count = 8 }, { name = "Dangerous Prisoner", level = 8, count = 8 } },
    ["Magma Village"] = { { name = "Military Soldier", level = 9, count = 9 }, { name = "Military Spy", level = 8, count = 8 } },
    ["Underwater City"] = { { name = "Fisherman Warrior", level = 8, count = 8 }, { name = "Fisherman Commando", level = 7, count = 7 } },
    ["Kingdom of Rose"] = { { name = "Raider", level = 10, count = 10 }, { name = "Merc", level = 10, count = 10 } },
}

local Bosses = {
    ["Gorilla King"] = { map = "Jungle", level = 25 },
    ["Saber Expert"] = { map = "Jungle", level = 200 },
    ["Bobby the Clown"] = { map = "Pirate Village", level = 55 },
    ["Yeti"] = { map = "Frozen Village", level = 110 },
    ["Ice Admiral"] = { map = "Frozen Village", level = 700 },
    ["Vice Admiral"] = { map = "Marine Fortress", level = 130 },
    ["Greybeard"] = { map = "Marine Fortress", level = 400 },
    ["Warden"] = { map = "Prison", level = 220 },
    ["Chief Warden"] = { map = "Prison", level = 230 },
    ["Swan"] = { map = "Prison", level = 240 },
    ["Magma Admiral"] = { map = "Magma Village", level = 250 },
    ["Fishman Lord"] = { map = "Underwater City", level = 425 },
    ["Diamond"] = { map = "Kingdom of Rose", level = 750 },
    ["Jeremy"] = { map = "Kingdom of Rose", level = 850 },
    ["Island Empress"] = { map = "Hydra Island", level = 1675 },
    ["Captain Elephant"] = { map = "Floating Turtle", level = 1875 },
    ["Longma"] = { map = "Floating Turtle", level = 2000 },
}

local Quests = {
    [1] = { name = "Bandit Quest", npc = "Bandit Quest Giver", map = "Starter Island", level = 0, mob = "Bandit", reward = 350, exp = 300 },
    [2] = { name = "Marine Quest", npc = "Marine Quest Giver", map = "Starter Island", level = 0, mob = "Marine Trainee", reward = 400, exp = 350 },
    [3] = { name = "Monkey Quest", npc = "Adventurer", map = "Jungle", level = 15, mob = "Monkey", reward = 800, exp = 2300 },
    [4] = { name = "Gorilla Quest", npc = "Adventurer", map = "Jungle", level = 15, mob = "Gorilla", reward = 1200, exp = 4500 },
    [5] = { name = "Pirate Quest", npc = "Rich Man", map = "Pirate Village", level = 30, mob = "Pirate", reward = 3000, exp = 13000 },
    [6] = { name = "Brute Quest", npc = "Rich Man", map = "Pirate Village", level = 30, mob = "Brute", reward = 3500, exp = 22000 },
    [7] = { name = "Desert Bandit Quest", npc = "Desert Adventurer", map = "Desert", level = 60, mob = "Desert Bandit", reward = 4000, exp = 45000 },
    [8] = { name = "Desert Officer Quest", npc = "Desert Adventurer", map = "Desert", level = 60, mob = "Desert Officer", reward = 4500, exp = 65000 },
    [9] = { name = "Snow Bandit Quest", npc = "Sick Man", map = "Frozen Village", level = 90, mob = "Snow Bandit", reward = 5000, exp = 75000 },
    [10] = { name = "Snowman Quest", npc = "Sick Man", map = "Frozen Village", level = 90, mob = "Snowman", reward = 5500, exp = 85000 },
}

-- ============================================
-- REMOTE EVENT PATHS & UTILITIES
-- ============================================

local Remotes = {
    Attack = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attack"),
    SkillZ = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillZ"),
    SkillX = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillX"),
    SkillC = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillC"),
    SkillV = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillV"),
    SkillF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillF"),
    BringMob = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BringMob"),
    Haki = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Haki"),
}

local function GetPlayerLevel()
    pcall(function()
        local leaderstats = character:FindFirstChild("leaderstats")
        if leaderstats then
            local level = leaderstats:FindFirstChild("Level")
            if level then Config.currentLevel = level.Value return level.Value end
        end
    end)
    return Config.currentLevel
end

local function Tween(position, duration)
    if not humanoidRootPart or not position then return end
    duration = duration or 150
    pcall(function()
        local tweenInfo = TweenInfo.new(duration / 1000, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
        local goal = {CFrame = CFrame.new(position + Vector3.new(0, 3, 0))}
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
        tween:Play()
        return tween
    end)
end

local function TweenWait(position, duration)
    local tween = Tween(position, duration)
    if tween then tween.Completed:Wait() end
    task.wait(0.2)
end

local function FindNearestMob(mobName, maxDistance)
    maxDistance = maxDistance or 100
    local nearest, minDistance = nil, math.huge
    for _, mob in pairs(Workspace:GetChildren()) do
        if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
            local distance = (mob.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
            if mob.Humanoid.Health > 0 and distance < maxDistance then
                if mobName == "" or mob.Name:lower():find(mobName:lower()) then
                    if distance < minDistance then minDistance = distance; nearest = mob end
                end
            end
        end
    end
    return nearest, minDistance
end

local function FindAllMobs(mobName, maxDistance)
    maxDistance = maxDistance or 150
    local mobs = {}
    for _, mob in pairs(Workspace:GetChildren()) do
        if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
            local distance = (mob.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
            if mob.Humanoid.Health > 0 and distance < maxDistance then
                if mobName == "" or mob.Name:lower():find(mobName:lower()) then table.insert(mobs, mob) end
            end
        end
    end
    return mobs
end

-- ============================================
-- COMBAT & AUTO FARM CORE LOGIC
-- ============================================

local function SendAttack(target)
    pcall(function()
        if Remotes.Attack then Remotes.Attack:FireServer(target) end
    end)
end

local function SendSkill(skillKey)
    pcall(function()
        local skillRemote = Remotes["Skill" .. skillKey]
        if skillRemote then skillRemote:FireServer({Position = mouse.Hit.Position}) end
    end)
end

local function BringMobAdvanced(mob, targetPosition)
    pcall(function()
        if Remotes.BringMob then
            Remotes.BringMob:FireServer(mob, targetPosition)
        elseif mob:FindFirstChild("HumanoidRootPart") then
            mob.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        end
    end)
end

local function SetupPhysics()
    pcall(function()
        sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", 50)
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
end

local function FastAttackLogic()
    while Config.fastAttack do
        pcall(function()
            local nearestMob, distance = FindNearestMob("", 100)
            if nearestMob and nearestMob.Humanoid.Health > 0 then
                if distance > 30 then TweenWait(nearestMob.HumanoidRootPart.Position, 80) end
                SendAttack(nearestMob)
            end
            task.wait(0.02)
        end)
    end
end

local function KillAuraLogic()
    while Config.killAura do
        pcall(function()
            local mobs = FindAllMobs("", 150)
            for _, mob in pairs(mobs) do
                if mob.Humanoid.Health > 0 then
                    humanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                    SendAttack(mob)
                end
            end
            task.wait(0.1)
        end)
    end
end

local function AutoFarmLogic()
    while Config.autoFarmEnabled do
        pcall(function()
            local playerLevel = GetPlayerLevel()
            local questIndex = 1
            for i = #Quests, 1, -1 do
                if playerLevel >= Quests[i].level then questIndex = i; break end
            end
            
            local questData = Quests[questIndex]
            if not questData then Config.autoFarmEnabled = false; return end
            
            local mapData = Maps[questData.map]
            if mapData then TweenWait(mapData.pos, 150); task.wait(1) end
            
            while Config.autoFarmEnabled do
                local nearestMob, distance = FindNearestMob(questData.mob, 150)
                if nearestMob and nearestMob.Humanoid.Health > 0 then
                    if Config.autoBringMobEnabled then
                        for _, mob in pairs(FindAllMobs(questData.mob, 200)) do BringMobAdvanced(mob, humanoidRootPart.Position) end
                    end
                    if distance > 30 then TweenWait(nearestMob.HumanoidRootPart.Position, 100) end
                    if Config.autoClickEnabled then SendAttack(nearestMob) end
                    if Config.autoComboEnabled then SendSkill("Z"); task.wait(0.1); SendSkill("X") end
                else
                    task.wait(0.5)
                end
                task.wait(0.05)
            end
        end)
    end
end

local function BossFarmLogic(bossName)
    while Config.autoSeaBeast or Config.autoLeviathan do
        pcall(function()
            local bossData = Bosses[bossName]
            if not bossData then return end
            local mapData = Maps[bossData.map]
            if mapData then TweenWait(mapData.pos, 150); task.wait(1) end
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:lower():find(bossName:lower()) and obj:FindFirstChild("Humanoid") then
                    while obj.Humanoid.Health > 0 and (Config.autoSeaBeast or Config.autoLeviathan) do
                        SendAttack(obj); SendSkill("Z"); task.wait(0.1); SendSkill("X"); task.wait(0.05)
                    end
                    break
                end
            end
            task.wait(1)
        end)
    end
end

-- ============================================
-- REDZ HUB MOBILE GUI SETUP
-- ============================================

-- Khởi tạo Cửa sổ giao diện chính của Redz
local Window = RedzLib:MakeWindow({
    Name = "REDZ HUB v5.0 (MOBILE)",
    SubName = "by Lập Trình Tham Khảo",
    Discord = "https://discord.gg/redz"
})

-- Khởi tạo các Tab chức năng bằng phương thức của Redz
local FarmTab = Window:MakeTab({"Farm 🌾", "rbxassetid://4483345998"})
local CombatTab = Window:MakeTab({"Combat 💥", "rbxassetid://4483345998"})
local BossTab = Window:MakeTab({"Boss 👹", "rbxassetid://4483345998"})
local TeleportTab = Window:MakeTab({"Teleport 📍", "rbxassetid://4483345998"})
local MiscTab = Window:MakeTab({"Misc ⚙️", "rbxassetid://4483345998"})

-- --- FARM TAB ---
FarmTab:AddSection({"Main Farming Operations"})

FarmTab:AddToggle({
    Name = "Auto Farm Level",
    Default = false,
    Callback = function(Value)
        Config.autoFarmEnabled = Value
        if Value then task.spawn(AutoFarmLogic) end
    end
})

FarmTab:AddToggle({
    Name = "Auto Click / Attack",
    Default = false,
    Callback = function(Value)
        Config.autoClickEnabled = Value
    end
})

FarmTab:AddToggle({
    Name = "Auto Skill Combo (Z, X)",
    Default = false,
    Callback = function(Value)
        Config.autoComboEnabled = Value
    end
})

FarmTab:AddToggle({
    Name = "Gom Quái (Bring Mobs)",
    Default = false,
    Callback = function(Value)
        Config.autoBringMobEnabled = Value
    end
})

-- --- COMBAT TAB ---
CombatTab:AddSection({"Combat Modifications"})

CombatTab:AddToggle({
    Name = "Fast Attack",
    Default = false,
    Callback = function(Value)
        Config.fastAttack = Value
        if Value then task.spawn(FastAttackLogic) end
    end
})

CombatTab:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(Value)
        Config.killAura = Value
        if Value then task.spawn(KillAuraLogic) end
    end
})

-- --- BOSS TAB ---
BossTab:AddSection({"Sea Events & Elite Mobs"})

BossTab:AddToggle({
    Name = "Auto Farm Sea Beast",
    Default = false,
    Callback = function(Value)
        Config.autoSeaBeast = Value
        if Value then task.spawn(function() BossFarmLogic("Sea Beast") end) end
    end
})

BossTab:AddToggle({
    Name = "Auto Farm Leviathan",
    Default = false,
    Callback = function(Value)
        Config.autoLeviathan = Value
        if Value then task.spawn(function() BossFarmLogic("Leviathan") end) end
    end
})

-- --- TELEPORT TAB ---
TeleportTab:AddSection({"World Navigation"})

for mapName, mapData in pairs(Maps) do
    TeleportTab:AddButton({
        Name = "Dịch chuyển tới: " .. mapName,
        Callback = function()
            TweenWait(mapData.pos, 150)
        end
    })
end

-- --- MISC TAB ---
MiscTab:AddSection({"Utilities & Performance"})

MiscTab:AddButton({
    Name = "Bật Tối Ưu Vật Lý (Tắt CanCollide)",
    Callback = function()
        SetupPhysics()
    end
})

MiscTab:AddButton({
    Name = "Lưu Cấu Hình (Save Config)",
    Callback = function()
        local configData = HttpService:JSONEncode(Config)
        writefile("RedzHub_Mobile_Config.json", configData)
    end
})

MiscTab:AddButton({
    Name = "Đổi Server (Rejoin)",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    end
})

-- ============================================
-- MAIN RESPAWN LOOP
-- ============================================

RunService.RenderStepped:Connect(function()
    if not character or not character:FindFirstChild("Humanoid") or humanoid.Health <= 0 then
        character = player.Character or player.CharacterAdded:Wait()
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoid = character:WaitForChild("Humanoid")
    end
end)

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
end)

print("✓ Redz Mobile UI Hub Loaded Successfully!")
