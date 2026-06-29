-- FPS Booster GUI using OrionLib
-- Yêu cầu: OrionLib đã được load vào biến OrionLib (nếu chưa, script cố gắng load bằng pcall)
-- Dán vào LocalScript

-- === Orion loader (tùy chọn) ===
local OrionLib
do
    local ok, lib = pcall(function()
        return _G.OrionLib -- nếu đã load trước đó
    end)
    if ok and lib then
        OrionLib = lib
    else
        -- Thử load từ global hoặc user-provided; nếu không có thì báo lỗi nhẹ
        if _G.OrionLib then
            OrionLib = _G.OrionLib
        else
            -- Nếu bạn muốn tự động load từ URL, thay dòng dưới bằng loader phù hợp.
            -- Ở đây ta sẽ tạo một stub thông báo nếu không có Orion.
            warn("OrionLib không được tìm thấy. Vui lòng load OrionLib trước khi chạy script này.")
            return
        end
    end
end

-- === Services ===
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- === Lưu trạng thái gốc để khôi phục ===
local original = {
    Lighting = {
        GlobalShadows = Lighting.GlobalShadows,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        Effects = {}
    },
    Parts = {},
    ParticleEmitters = {},
    Effects = {},
    Sounds = {},
    Animations = {},
    Camera = {
        FieldOfView = camera and camera.FieldOfView or 70
    }
}

-- Lưu các post-processing effects ban đầu
for _, effect in ipairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
        original.Lighting.Effects[effect] = {
            Enabled = effect.Enabled
        }
    end
end

-- Helper: traverse workspace và lưu trạng thái ban đầu (một lần)
local function snapshotWorkspace()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            original.Parts[obj] = {
                Material = obj.Material,
                CastShadow = obj.CastShadow,
                Transparency = obj.Transparency
            }
        elseif obj:IsA("ParticleEmitter") then
            original.ParticleEmitters[obj] = {
                Enabled = obj.Enabled,
                Rate = obj.Rate
            }
        elseif obj:IsA("Sound") then
            original.Sounds[obj] = {
                Volume = obj.Volume,
                Playing = obj.IsPlaying or obj.Playing
            }
        elseif obj:IsA("AnimationController") or obj:IsA("Humanoid") then
            -- store humanoid playing tracks later when toggled
        end
    end
end

snapshotWorkspace()

-- === Các hàm tối ưu hóa ===

local function setShadows(enabled)
    Lighting.GlobalShadows = enabled
    -- tắt castshadow cho parts nếu cần
    for part, data in pairs(original.Parts) do
        if part and part:IsA("BasePart") then
            pcall(function() part.CastShadow = enabled end)
        end
    end
end

local function reduceMaterials(enable)
    -- chuyển vật liệu nặng sang SmoothPlastic và tăng transparency nhẹ
    for part, data in pairs(original.Parts) do
        if part and part:IsA("BasePart") then
            pcall(function()
                if enable then
                    part.Material = Enum.Material.SmoothPlastic
                    -- giảm texture/mesh cost bằng cách tăng transparency 0.0 -> 0.05 (tùy chọn)
                    -- part.Transparency = math.max(part.Transparency, 0)
                else
                    part.Material = data.Material
                    part.Transparency = data.Transparency
                end
            end)
        end
    end
end

local function toggleParticles(enable)
    for emitter, data in pairs(original.ParticleEmitters) do
        if emitter and emitter:IsA("ParticleEmitter") then
            pcall(function() emitter.Enabled = enable end)
        end
    end
end

local function togglePostProcessing(enable)
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
            pcall(function() effect.Enabled = enable end)
        end
    end
end

local function setFogDistance(shorten)
    if shorten then
        -- Thiết lập fog để giảm render distance
        original.Lighting.FogStart = Lighting.FogStart
        original.Lighting.FogEnd = Lighting.FogEnd
        Lighting.FogStart = 0
        Lighting.FogEnd = 2000 -- điều chỉnh theo nhu cầu; nhỏ hơn = ít render
    else
        Lighting.FogStart = original.Lighting.FogStart
        Lighting.FogEnd = original.Lighting.FogEnd
    end
end

local function muteSounds(mute)
    for sound, data in pairs(original.Sounds) do
        if sound and sound:IsA("Sound") then
            pcall(function()
                if mute then
                    sound.Volume = 0
                    sound:Stop()
                else
                    sound.Volume = data.Volume
                    if data.Playing then
                        sound:Play()
                    end
                end
            end)
        end
    end
end

local function disableAnimations(disable)
    -- Dừng các animation tracks trên humanoids
    for _, humanoid in ipairs(Workspace:GetDescendants()) do
        if humanoid:IsA("Humanoid") then
            pcall(function()
                if disable then
                    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                        original.Animations[track] = {Playing = true}
                        track:Stop()
                    end
                    -- disable Animate script nếu có
                    local animate = humanoid.Parent:FindFirstChild("Animate")
                    if animate and animate:IsA("LocalScript") or animate:IsA("Script") then
                        original.Animations[animate] = {Disabled = animate.Disabled}
                        animate.Disabled = true
                    end
                else
                    -- khôi phục: không thể khôi phục track cụ thể dễ dàng, nhưng bật lại script Animate
                    local animate = humanoid.Parent:FindFirstChild("Animate")
                    if animate and original.Animations[animate] then
                        animate.Disabled = original.Animations[animate].Disabled
                    elseif animate then
                        animate.Disabled = false
                    end
                end
            end)
        end
    end
end

-- Tùy chọn giảm FieldOfView để giảm workload render (tùy chọn)
local function setCameraFOV(reduce)
    if camera then
        if reduce then
            original.Camera.FieldOfView = camera.FieldOfView
            camera.FieldOfView = math.clamp(camera.FieldOfView - 10, 50, 70)
        else
            camera.FieldOfView = original.Camera.FieldOfView or 70
        end
    end
end

-- Hàm áp dụng tất cả tối ưu
local function applyAll(settings)
    if settings.Shadows ~= nil then setShadows(settings.Shadows) end
    if settings.Materials ~= nil then reduceMaterials(settings.Materials) end
    if settings.Particles ~= nil then toggleParticles(not settings.Particles) end -- settings.Particles = true nghĩa giữ particles
    if settings.PostProcessing ~= nil then togglePostProcessing(settings.PostProcessing) end
    if settings.Fog ~= nil then setFogDistance(settings.Fog) end
    if settings.MuteSounds ~= nil then muteSounds(settings.MuteSounds) end
    if settings.DisableAnimations ~= nil then disableAnimations(settings.DisableAnimations) end
    if settings.ReduceFOV ~= nil then setCameraFOV(settings.ReduceFOV) end
end

-- Khôi phục toàn bộ
local function restoreAll()
    -- Lighting
    Lighting.GlobalShadows = original.Lighting.GlobalShadows
    Lighting.FogStart = original.Lighting.FogStart
    Lighting.FogEnd = original.Lighting.FogEnd
    -- Effects
    for effect, data in pairs(original.Lighting.Effects) do
        if effect and effect.Parent then
            pcall(function() effect.Enabled = data.Enabled end)
        end
    end
    -- Parts
    for part, data in pairs(original.Parts) do
        if part and part.Parent then
            pcall(function()
                part.Material = data.Material
                part.CastShadow = data.CastShadow
                part.Transparency = data.Transparency
            end)
        end
    end
    -- Particles
    for emitter, data in pairs(original.ParticleEmitters) do
        if emitter and emitter.Parent then
            pcall(function()
                emitter.Enabled = data.Enabled
                emitter.Rate = data.Rate
            end)
        end
    end
    -- Sounds
    for sound, data in pairs(original.Sounds) do
        if sound and sound.Parent then
            pcall(function()
                sound.Volume = data.Volume
                if data.Playing then sound:Play() end
            end)
        end
    end
    -- Animations: bật lại animate scripts nếu có
    for obj, data in pairs(original.Animations) do
        if obj and obj.Parent and obj:IsA("Script") or obj:IsA("LocalScript") then
            pcall(function() obj.Disabled = data.Disabled end)
        end
    end
    -- Camera
    if camera then
        camera.FieldOfView = original.Camera.FieldOfView or 70
    end
end

-- === GUI bằng OrionLib ===
local Window = OrionLib:MakeWindow({
    Name = "FPS Booster",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "FPSBoosterConfig"
})

local Tab = Window:MakeTab({
    Name = "Tối ưu",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local settings = {
    Shadows = false,
    Materials = true,
    Particles = false,
    PostProcessing = false,
    Fog = true,
    MuteSounds = false,
    DisableAnimations = false,
    ReduceFOV = false
}

Tab:AddToggle({
    Name = "Tắt bóng đổ (GlobalShadows)",
    Default = settings.Shadows,
    Callback = function(value)
        settings.Shadows = value
        setShadows(value)
    end
})

Tab:AddToggle({
    Name = "Giảm chất lượng vật liệu",
    Default = settings.Materials,
    Callback = function(value)
        settings.Materials = value
        reduceMaterials(value)
    end
})

Tab:AddToggle({
    Name = "Tắt hiệu ứng hạt (Particles)",
    Default = settings.Particles,
    Callback = function(value)
        settings.Particles = value
        toggleParticles(not value)
    end
})

Tab:AddToggle({
    Name = "Tắt ánh sáng dư (Bloom, Blur, v.v.)",
    Default = settings.PostProcessing,
    Callback = function(value)
        settings.PostProcessing = value
        togglePostProcessing(value)
    end
})

Tab:AddToggle({
    Name = "Giảm render distance bằng Fog",
    Default = settings.Fog,
    Callback = function(value)
        settings.Fog = value
        setFogDistance(value)
    end
})

Tab:AddToggle({
    Name = "Tắt âm thanh không cần thiết",
    Default = settings.MuteSounds,
    Callback = function(value)
        settings.MuteSounds = value
        muteSounds(value)
    end
})

Tab:AddToggle({
    Name = "Vô hiệu hóa animation scripts không cần thiết",
    Default = settings.DisableAnimations,
    Callback = function(value)
        settings.DisableAnimations = value
        disableAnimations(value)
    end
})

Tab:AddToggle({
    Name = "Giảm FieldOfView (tùy chọn)",
    Default = settings.ReduceFOV,
    Callback = function(value)
        settings.ReduceFOV = value
        setCameraFOV(value)
    end
})

Tab:AddButton({
    Name = "Áp dụng tất cả",
    Callback = function()
        applyAll({
            Shadows = settings.Shadows,
            Materials = settings.Materials,
            Particles = settings.Particles,
            PostProcessing = settings.PostProcessing,
            Fog = settings.Fog,
            MuteSounds = settings.MuteSounds,
            DisableAnimations = settings.DisableAnimations,
            ReduceFOV = settings.ReduceFOV
        })
        OrionLib:MakeNotification({
            Name = "FPS Booster",
            Content = "Đã áp dụng các thiết lập tối ưu.",
            Time = 3
        })
    end
})

Tab:AddButton({
    Name = "Khôi phục mặc định",
    Callback = function()
        restoreAll()
        OrionLib:MakeNotification({
            Name = "FPS Booster",
            Content = "Đã khôi phục trạng thái ban đầu.",
            Time = 3
        })
    end
})

-- Tự động áp dụng một số tối ưu ban đầu nếu muốn
-- applyAll({Shadows = false, Materials = true, Particles = false, PostProcessing = false, Fog = true, MuteSounds = false, DisableAnimations = false, ReduceFOV = false})

OrionLib:Init()
