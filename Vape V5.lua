-- ═══════════════════════════════════════════════════════════════════
-- 📦 VAPEV5 UI LIBRARY - VERSÃO MELHORADA
-- ═══════════════════════════════════════════════════════════════════

local VapeV5 = {
    Version = "5.2.0",
    Author = "VapeV5 Team",
    
    -- Configurações Globais
    Settings = {
        -- 🎨 Tema Principal
        Theme = {
            Primary = Color3.fromRGB(26, 25, 26),
            Secondary = Color3.fromRGB(35, 34, 35),
            Accent = Color3.fromRGB(5, 134, 105),
            Text = Color3.fromRGB(200, 200, 200),
            TextDark = Color3.fromRGB(140, 140, 140),
            Success = Color3.fromRGB(90, 255, 90),
            Error = Color3.fromRGB(255, 90, 90),
            Warning = Color3.fromRGB(255, 170, 0),
        },
        
        -- 🔤 Fontes
        Fonts = {
            Regular = Font.fromEnum(Enum.Font.Gotham),
            Bold = Font.fromEnum(Enum.Font.GothamBold),
            SemiBold = Font.fromEnum(Enum.Font.GothamSemibold),
        },
        
        -- ⚡ Animações
        Animations = {
            Enabled = true,
            Speed = 0.16,
            Style = Enum.EasingStyle.Quart,
        },
        
        -- 🌈 Rainbow
        Rainbow = {
            Enabled = false,
            Speed = 1,
            UpdateRate = 30,
        },
        
        -- 🔧 Geral
        General = {
            Scale = 1,
            AutoScale = true,
            Blur = true,
            BlurSize = 14,
            Notifications = true,
            Tooltips = true,
            Sounds = true,
            Debug = false,
        },
        
        -- 🔑 Keybinds
        Keybind = {"RightShift"},
    },
    
    -- Storage interno
    _windows = {},
    _modules = {},
    _connections = {},
    _rainbowTable = {},
    _loaded = false,
    _blurEffect = nil,
    _overlay = nil,
}

-- ═══════════════════════════════════════════════════════════════════
-- 🔧 SERVIÇOS DO ROBLOX
-- ═══════════════════════════════════════════════════════════════════

local Services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    TextService = game:GetService("TextService"),
    GuiService = game:GetService("GuiService"),
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService"),
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    Lighting = game:GetService("Lighting"),
    SoundService = game:GetService("SoundService"),
}

local cloneref = cloneref or function(obj) return obj end
for name, service in pairs(Services) do
    Services[name] = cloneref(service)
end

local LocalPlayer = Services.Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════
-- 🐛 SISTEMA DE DEBUG
-- ═══════════════════════════════════════════════════════════════════

local Debug = {}

function Debug.Log(message, level)
    if not VapeV5.Settings.General.Debug then return end
    level = level or "INFO"
    warn(string.format("[VapeV5 %s] %s", level, tostring(message)))
end

function Debug.Error(message)
    Debug.Log(message, "ERROR")
end

function Debug.Warn(message)
    Debug.Log(message, "WARN")
end

VapeV5.Debug = Debug

-- ═══════════════════════════════════════════════════════════════════
-- 🛠️ UTILITÁRIOS
-- ═══════════════════════════════════════════════════════════════════

local Utils = {}

function Utils.RandomString(length)
    length = length or math.random(10, 20)
    local chars = {}
    for i = 1, length do
        chars[i] = string.char(math.random(65, 90))
    end
    return table.concat(chars)
end

function Utils.FileExists(path)
    local success, result = pcall(function()
        return readfile(path)
    end)
    return success and result ~= nil and result ~= ""
end

function Utils.FolderExists(path)
    local success = pcall(function()
        return isfolder(path) and isfolder(path)
    end)
    if success then
        return isfolder and isfolder(path)
    end
    return false
end

function Utils.EnsureFolder(path)
    if not Utils.FolderExists(path) then
        pcall(function()
            makefolder(path)
        end)
    end
end

function Utils.LoadJSON(path)
    local success, result = pcall(function()
        return Services.HttpService:JSONDecode(readfile(path))
    end)
    if not success then
        Debug.Error("Failed to load JSON: " .. path)
    end
    return success and type(result) == "table" and result or nil
end

function Utils.SaveJSON(path, data)
    local success = pcall(function()
        writefile(path, Services.HttpService:JSONEncode(data))
    end)
    if not success then
        Debug.Error("Failed to save JSON: " .. path)
    end
    return success
end

local TextBoundsParams = Instance.new("GetTextBoundsParams")
TextBoundsParams.Width = math.huge

function Utils.GetTextSize(text, size, font)
    local success, result = pcall(function()
        TextBoundsParams.Text = text or ""
        TextBoundsParams.Size = size or 14
        if typeof(font) == "Font" then
            TextBoundsParams.Font = font
        else
            TextBoundsParams.Font = VapeV5.Settings.Fonts.Regular
        end
        return Services.TextService:GetTextBoundsAsync(TextBoundsParams)
    end)
    
    if success then
        return result
    end
    return Vector2.new(100, 20)
end

function Utils.RemoveTags(str)
    if not str then return "" end
    str = str:gsub("<br%s*/>", "\n")
    return str:gsub("<[^<>]->", "")
end

function Utils.DeepClone(original)
    if type(original) ~= "table" then return original end
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = Utils.DeepClone(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function Utils.LerpColor(c1, c2, t)
    return Color3.new(
        c1.R + (c2.R - c1.R) * t,
        c1.G + (c2.G - c1.G) * t,
        c1.B + (c2.B - c1.B) * t
    )
end

function Utils.ValidateOptions(options, defaults)
    options = options or {}
    for k, v in pairs(defaults) do
        if options[k] == nil then
            options[k] = v
        end
    end
    return options
end

VapeV5.Utils = Utils

-- ═══════════════════════════════════════════════════════════════════
-- 🎨 SISTEMA DE CORES
-- ═══════════════════════════════════════════════════════════════════

local ColorSystem = {}

function ColorSystem.Dark(color, amount)
    if not color then return Color3.new(0, 0, 0) end
    local h, s, v = color:ToHSV()
    local mainV = select(3, VapeV5.Settings.Theme.Primary:ToHSV())
    if mainV > 0.5 then
        return Color3.fromHSV(h, s, math.clamp(v + amount, 0, 1))
    else
        return Color3.fromHSV(h, s, math.clamp(v - amount, 0, 1))
    end
end

function ColorSystem.Light(color, amount)
    if not color then return Color3.new(1, 1, 1) end
    local h, s, v = color:ToHSV()
    local mainV = select(3, VapeV5.Settings.Theme.Primary:ToHSV())
    if mainV > 0.5 then
        return Color3.fromHSV(h, s, math.clamp(v - amount, 0, 1))
    else
        return Color3.fromHSV(h, s, math.clamp(v + amount, 0, 1))
    end
end

function ColorSystem.GetRainbow(hue)
    local s = 0.75 + (0.15 * math.min(hue / 0.03, 1))
    if hue > 0.57 then
        s = 0.9 - (0.4 * math.min((hue - 0.57) / 0.09, 1))
    end
    if hue > 0.66 then
        s = 0.5 + (0.4 * math.min((hue - 0.66) / 0.16, 1))
    end
    if hue > 0.87 then
        s = 0.9 - (0.15 * math.min((hue - 0.87) / 0.13, 1))
    end
    return hue, s, 1
end

function ColorSystem.GetTextColor(h, s, v)
    if v >= 0.7 and (s < 0.6 or (h > 0.04 and h < 0.56)) then
        return Color3.fromRGB(48, 48, 48)
    end
    return Color3.fromRGB(255, 255, 255)
end

function ColorSystem.FromHex(hex)
    if not hex then return Color3.new(1, 1, 1) end
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16) or 255,
        tonumber(hex:sub(3, 4), 16) or 255,
        tonumber(hex:sub(5, 6), 16) or 255
    )
end

function ColorSystem.ToHex(color)
    if not color then return "#FFFFFF" end
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

VapeV5.Color = ColorSystem

-- ═══════════════════════════════════════════════════════════════════
-- 🎬 SISTEMA DE ANIMAÇÕES (TWEEN) - MELHORADO
-- ═══════════════════════════════════════════════════════════════════

local TweenSystem = {
    _activeTweens = {},
    _tweenCache = {},
}

function TweenSystem:Create(object, properties, duration, style, direction)
    if not object then 
        Debug.Warn("TweenSystem:Create - object is nil")
        return nil 
    end
    
    if not VapeV5.Settings.Animations.Enabled then
        for prop, value in pairs(properties) do
            pcall(function()
                object[prop] = value
            end)
        end
        return nil
    end
    
    -- Cancelar tween anterior do mesmo objeto
    if self._activeTweens[object] then
        pcall(function()
            self._activeTweens[object]:Cancel()
        end)
    end
    
    local tweenInfo = TweenInfo.new(
        duration or VapeV5.Settings.Animations.Speed,
        style or VapeV5.Settings.Animations.Style,
        direction or Enum.EasingDirection.Out
    )
    
    local success, tween = pcall(function()
        return Services.TweenService:Create(object, tweenInfo, properties)
    end)
    
    if not success or not tween then
        Debug.Warn("TweenSystem:Create - failed to create tween")
        return nil
    end
    
    self._activeTweens[object] = tween
    
    tween.Completed:Once(function()
        self._activeTweens[object] = nil
    end)
    
    tween:Play()
    return tween
end

function TweenSystem:CreateSequence(object, sequence)
    task.spawn(function()
        for _, step in ipairs(sequence) do
            local tween = self:Create(object, step.Properties, step.Duration, step.Style, step.Direction)
            if tween then
                tween.Completed:Wait()
            end
            if step.Delay then
                task.wait(step.Delay)
            end
        end
    end)
end

function TweenSystem:Cancel(object)
    if self._activeTweens[object] then
        pcall(function()
            self._activeTweens[object]:Cancel()
        end)
        self._activeTweens[object] = nil
    end
end

function TweenSystem:CancelAll()
    for object, tween in pairs(self._activeTweens) do
        pcall(function()
            tween:Cancel()
        end)
    end
    table.clear(self._activeTweens)
end

VapeV5.Tween = TweenSystem

-- ═══════════════════════════════════════════════════════════════════
-- 🖼️ SISTEMA DE ASSETS - MELHORADO
-- ═══════════════════════════════════════════════════════════════════

local AssetSystem = {
    _cache = {},
    _cacheFolder = "VapeV5/cache",
    
    Embedded = {
        Logo = "rbxassetid://14657521312",
        Close = "rbxassetid://14368309446",
        Expand = "rbxassetid://14368353032",
        Arrow = "rbxassetid://14368316544",
        Dots = "rbxassetid://14368314459",
        Search = "rbxassetid://14425646684",
        Settings = "rbxassetid://14368318994",
        Bind = "rbxassetid://14368304734",
        Rainbow = {
            "rbxassetid://14368344374",
            "rbxassetid://14368345149",
            "rbxassetid://14368345840",
            "rbxassetid://14368346696",
        },
        Categories = {
            Combat = "rbxassetid://14368312652",
            Blatant = "rbxassetid://14368306745",
            Render = "rbxassetid://14368350193",
            Utility = "rbxassetid://14368359107",
            World = "rbxassetid://14368362492",
            Player = "rbxassetid://14397462778",
        },
        Notification = {
            Info = "rbxassetid://14368324807",
            Warning = "rbxassetid://14368361552",
            Error = "rbxassetid://14368301329",
            Success = "rbxassetid://14368302000",
        },
    },
}

function AssetSystem:Init()
    Utils.EnsureFolder("VapeV5")
    Utils.EnsureFolder(self._cacheFolder)
end

function AssetSystem:LoadFromURL(source)
    if not source or source == "" then
        return ""
    end
    
    if type(source) == "table" then
        return self:LoadFromURL(source.url or source.rbx or source.fallback or "")
    end
    
    if type(source) ~= "string" then
        Debug.Warn("AssetSystem:LoadFromURL - source is not a string")
        return ""
    end
    
    if self._cache[source] then
        return self._cache[source]
    end
    
    if source:match("^rbxassetid://") then
        self._cache[source] = source
        return source
    end
    
    if source:match("^https?://") then
        local success, body = pcall(function()
            return game:HttpGet(source)
        end)
        
        if not success or not body or #body == 0 then
            Debug.Warn("AssetSystem:LoadFromURL - failed to fetch: " .. source)
            return ""
        end
        
        if writefile and getcustomasset then
            local fileName = "asset_" .. tostring(math.random(100000, 999999)) .. ".png"
            local filePath = self._cacheFolder .. "/" .. fileName
            
            local saveSuccess = pcall(function()
                writefile(filePath, body)
            end)
            
            if saveSuccess then
                local assetSuccess, customAsset = pcall(function()
                    return getcustomasset(filePath)
                end)
                
                if assetSuccess and customAsset then
                    self._cache[source] = customAsset
                    Debug.Log("Asset cached: " .. source)
                    return customAsset
                end
            end
        end
        
        self._cache[source] = source
        return source
    end
    
    return ""
end

function AssetSystem:Get(name)
    if not name then return "" end
    
    local parts = string.split(name, ".")
    local current = self.Embedded
    
    for _, part in ipairs(parts) do
        if current[part] then
            current = current[part]
        else
            Debug.Warn("AssetSystem:Get - asset not found: " .. name)
            return ""
        end
    end
    
    if type(current) == "string" then
        return current
    end
    
    return ""
end

function AssetSystem:IsEmoji(str)
    if not str or type(str) ~= "string" then return false end
    
    if str:match("^rbxassetid://") or str:match("^https?://") then
        return false
    end
    
    if #str <= 4 then
        return true
    end
    
    return false
end

VapeV5.Assets = AssetSystem

-- ═══════════════════════════════════════════════════════════════════
-- 🌫️ SISTEMA DE BLUR PROFISSIONAL
-- ═══════════════════════════════════════════════════════════════════

local BlurSystem = {
    _blur = nil,
    _overlay = nil,
    _overlayGui = nil,
    _enabled = false,
}

function BlurSystem:Init(parent)
    self._overlayGui = Instance.new("ScreenGui")
    self._overlayGui.Name = Utils.RandomString(8) .. "_Overlay"
    self._overlayGui.DisplayOrder = 999998
    self._overlayGui.IgnoreGuiInset = true
    self._overlayGui.ResetOnSpawn = false
    
    local success = pcall(function()
        self._overlayGui.Parent = Services.CoreGui
    end)
    
    if not success then
        self._overlayGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    self._overlay = Instance.new("Frame")
    self._overlay.Name = "BlurOverlay"
    self._overlay.Size = UDim2.fromScale(1, 1)
    self._overlay.Position = UDim2.new(0, 0, 0, 0)
    self._overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    self._overlay.BackgroundTransparency = 1
    self._overlay.BorderSizePixel = 0
    self._overlay.ZIndex = -1
    self._overlay.Parent = self._overlayGui
    
    self._overlayGui.Enabled = false
end

function BlurSystem:Enable(size, duration)
    if not VapeV5.Settings.General.Blur then return end
    if self._enabled then return end
    
    self._enabled = true
    size = size or VapeV5.Settings.General.BlurSize or 14
    duration = duration or 0.25
    
    if not self._blur then
        self._blur = Instance.new("BlurEffect")
        self._blur.Name = "VapeV5_Blur"
        self._blur.Size = 0
        self._blur.Parent = Services.Lighting
    end
    
    if self._overlayGui then
        self._overlayGui.Enabled = true
    end
    
    VapeV5.Tween:Create(self._blur, {Size = size}, duration, Enum.EasingStyle.Quad)
    
    if self._overlay then
        VapeV5.Tween:Create(self._overlay, {BackgroundTransparency = 0.4}, duration, Enum.EasingStyle.Quad)
    end
end

function BlurSystem:Disable(duration)
    if not self._enabled then return end
    
    self._enabled = false
    duration = duration or 0.2
    
    if self._blur then
        local tween = VapeV5.Tween:Create(self._blur, {Size = 0}, duration, Enum.EasingStyle.Quad)
        if tween then
            tween.Completed:Once(function()
                if self._blur and not self._enabled then
                    self._blur:Destroy()
                    self._blur = nil
                end
            end)
        end
    end
    
    if self._overlay then
        local tween = VapeV5.Tween:Create(self._overlay, {BackgroundTransparency = 1}, duration, Enum.EasingStyle.Quad)
        if tween then
            tween.Completed:Once(function()
                if self._overlayGui and not self._enabled then
                    self._overlayGui.Enabled = false
                end
            end)
        end
    end
end

function BlurSystem:Toggle()
    if self._enabled then
        self:Disable()
    else
        self:Enable()
    end
end

function BlurSystem:Destroy()
    if self._blur then
        self._blur:Destroy()
        self._blur = nil
    end
    if self._overlayGui then
        self._overlayGui:Destroy()
        self._overlayGui = nil
    end
    self._enabled = false
end

VapeV5.Blur = BlurSystem

-- ═══════════════════════════════════════════════════════════════════
-- 🔔 SISTEMA DE NOTIFICAÇÕES - MELHORADO (PREMIUM)
-- ═══════════════════════════════════════════════════════════════════

local NotificationSystem = {
    _container = nil,
    _queue = {},
    _active = {},
    _pool = {},
    _config = {
        MaxVisible = 5,
        Spacing = 10,
        DefaultDuration = 3,
        AnimationSpeed = 0.35,
        PoolSize = 10,
        EnableSounds = true,
        EnableHover = true,
        StackSimilar = true,
    },
    _sounds = {
        Info = "rbxassetid://6026984224",
        Success = "rbxassetid://6026984224",
        Warning = "rbxassetid://6026984224",
        Error = "rbxassetid://6026984224",
    },
}

function NotificationSystem:Init(parent)
    self._container = Instance.new("Frame")
    self._container.Name = "Notifications"
    self._container.Size = UDim2.new(1, 0, 1, 0)
    self._container.BackgroundTransparency = 1
    self._container.ClipsDescendants = false
    self._container.Parent = parent
    
    self:_InitPool()
    self:_StartQueueProcessor()
    
    return self
end

-- ═══════════════════════════════════════════════════════════════════
-- 🔧 SISTEMA DE POOL (Reutilização de Objetos)
-- ═══════════════════════════════════════════════════════════════════

function NotificationSystem:_InitPool()
    for i = 1, self._config.PoolSize do
        local notif = self:_CreateNotificationFrame()
        notif.Visible = false
        table.insert(self._pool, notif)
    end
end

function NotificationSystem:_GetFromPool()
    if #self._pool > 0 then
        local notif = table.remove(self._pool)
        notif.Visible = true
        return notif, false
    end
    return self:_CreateNotificationFrame(), true
end

function NotificationSystem:_ReturnToPool(notif)
    if #self._pool < self._config.PoolSize then
        notif.Visible = false
        notif.Position = UDim2.new(1, 20, 1, 0)
        table.insert(self._pool, notif)
    else
        notif:Destroy()
    end
end

-- ═══════════════════════════════════════════════════════════════════
-- 🎨 CRIAÇÃO DE UI DA NOTIFICAÇÃO
-- ═══════════════════════════════════════════════════════════════════

function NotificationSystem:_CreateNotificationFrame()
    local theme = VapeV5.Settings.Theme
    
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.fromOffset(320, 85)
    notif.BackgroundColor3 = theme.Primary
    notif.BackgroundTransparency = 0.02
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.Parent = self._container
    
    notif:SetAttribute("Duration", 0)
    notif:SetAttribute("IsPaused", false)
    notif:SetAttribute("ElapsedTime", 0)
    notif:SetAttribute("Type", "Info")
    
    -- Corner arredondado
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = notif
    
    -- Stroke premium
    local stroke = Instance.new("UIStroke")
    stroke.Name = "Stroke"
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.85
    stroke.Parent = notif
    
    -- Gradient de fundo sutil
    local bgGradient = Instance.new("UIGradient")
    bgGradient.Name = "BGGradient"
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
    })
    bgGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.98),
        NumberSequenceKeypoint.new(1, 1)
    })
    bgGradient.Rotation = 45
    bgGradient.Parent = notif
    
    -- Shadow melhorada (múltiplas camadas)
    for i = 1, 3 do
        local shadow = Instance.new("Frame")
        shadow.Name = "Shadow" .. i
        shadow.Size = UDim2.new(1, 8 * i, 1, 8 * i)
        shadow.Position = UDim2.fromOffset(-4 * i, -4 * i + (2 * i))
        shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        shadow.BackgroundTransparency = 0.85 + (i * 0.04)
        shadow.BorderSizePixel = 0
        shadow.ZIndex = -i
        shadow.Parent = notif
        
        local shadowCorner = Instance.new("UICorner")
        shadowCorner.CornerRadius = UDim.new(0, 10 + (i * 2))
        shadowCorner.Parent = shadow
    end
    
    -- Barra lateral colorida
    local sideBar = Instance.new("Frame")
    sideBar.Name = "SideBar"
    sideBar.Size = UDim2.new(0, 4, 1, -12)
    sideBar.Position = UDim2.fromOffset(6, 6)
    sideBar.BackgroundColor3 = theme.Accent
    sideBar.BorderSizePixel = 0
    sideBar.Parent = notif
    
    local sideCorner = Instance.new("UICorner")
    sideCorner.CornerRadius = UDim.new(1, 0)
    sideCorner.Parent = sideBar
    
    -- Glow na barra lateral
    local sideGlow = Instance.new("ImageLabel")
    sideGlow.Name = "SideGlow"
    sideGlow.Size = UDim2.new(0, 30, 1, 0)
    sideGlow.Position = UDim2.fromOffset(-13, 0)
    sideGlow.BackgroundTransparency = 1
    sideGlow.Image = "rbxassetid://5028857084"
    sideGlow.ImageColor3 = theme.Accent
    sideGlow.ImageTransparency = 0.7
    sideGlow.Parent = sideBar
    
    -- Container do ícone com fundo
    local iconContainer = Instance.new("Frame")
    iconContainer.Name = "IconContainer"
    iconContainer.Size = UDim2.fromOffset(36, 36)
    iconContainer.Position = UDim2.fromOffset(18, 24)
    iconContainer.BackgroundColor3 = theme.Accent
    iconContainer.BackgroundTransparency = 0.9
    iconContainer.Parent = notif
    
    local iconContainerCorner = Instance.new("UICorner")
    iconContainerCorner.CornerRadius = UDim.new(0, 8)
    iconContainerCorner.Parent = iconContainer
    
    -- Ícone
    local iconLabel = Instance.new("ImageLabel")
    iconLabel.Name = "Icon"
    iconLabel.Size = UDim2.fromOffset(24, 24)
    iconLabel.Position = UDim2.fromOffset(6, 6)
    iconLabel.BackgroundTransparency = 1
    iconLabel.ImageColor3 = theme.Accent
    iconLabel.Parent = iconContainer
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -80, 0, 22)
    titleLabel.Position = UDim2.fromOffset(62, 14)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Notification"
    titleLabel.TextColor3 = theme.Text
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.FontFace = VapeV5.Settings.Fonts.Bold
    titleLabel.Parent = notif
    
    -- Badge de contagem (para notificações agrupadas)
    local countBadge = Instance.new("Frame")
    countBadge.Name = "CountBadge"
    countBadge.Size = UDim2.fromOffset(24, 18)
    countBadge.Position = UDim2.new(1, -35, 0, 14)
    countBadge.BackgroundColor3 = theme.Accent
    countBadge.Visible = false
    countBadge.Parent = notif
    
    local countBadgeCorner = Instance.new("UICorner")
    countBadgeCorner.CornerRadius = UDim.new(1, 0)
    countBadgeCorner.Parent = countBadge
    
    local countLabel = Instance.new("TextLabel")
    countLabel.Name = "CountLabel"
    countLabel.Size = UDim2.fromScale(1, 1)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "1"
    countLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    countLabel.TextSize = 12
    countLabel.FontFace = VapeV5.Settings.Fonts.Bold
    countLabel.Parent = countBadge
    
    -- Mensagem
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -80, 0, 20)
    messageLabel.Position = UDim2.fromOffset(62, 38)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = ""
    messageLabel.TextColor3 = theme.TextDark
    messageLabel.TextSize = 13
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.FontFace = VapeV5.Settings.Fonts.Regular
    messageLabel.RichText = true
    messageLabel.TextTruncate = Enum.TextTruncate.AtEnd
    messageLabel.Parent = notif
    
    -- Container da barra de progresso
    local progressContainer = Instance.new("Frame")
    progressContainer.Name = "ProgressContainer"
    progressContainer.Size = UDim2.new(1, -20, 0, 4)
    progressContainer.Position = UDim2.new(0, 10, 1, -10)
    progressContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    progressContainer.BackgroundTransparency = 0.9
    progressContainer.BorderSizePixel = 0
    progressContainer.Parent = notif
    
    local progressContainerCorner = Instance.new("UICorner")
    progressContainerCorner.CornerRadius = UDim.new(1, 0)
    progressContainerCorner.Parent = progressContainer
    
    -- Barra de progresso
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.fromScale(1, 1)
    progressBar.BackgroundColor3 = theme.Accent
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressContainer
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = progressBar
    
    -- Gradient na barra de progresso
    local progressGradient = Instance.new("UIGradient")
    progressGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
    })
    progressGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.7, 0),
        NumberSequenceKeypoint.new(1, 0.3)
    })
    progressGradient.Parent = progressBar
    
    -- Botão de fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.fromOffset(20, 20)
    closeButton.Position = UDim2.new(1, -28, 0, 8)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "✕"
    closeButton.TextColor3 = theme.TextDark
    closeButton.TextSize = 14
    closeButton.FontFace = VapeV5.Settings.Fonts.Bold
    closeButton.Parent = notif
    
    -- Configurar interatividade
    self:_SetupInteractivity(notif)
    
    return notif
end

-- ═══════════════════════════════════════════════════════════════════
-- 🖱️ INTERATIVIDADE
-- ═══════════════════════════════════════════════════════════════════

function NotificationSystem:_SetupInteractivity(notif)
    local theme = VapeV5.Settings.Theme
    local closeButton = notif:FindFirstChild("CloseButton")
    local connections = {}
    
    -- Hover no container - pausa o timer
    if self._config.EnableHover then
        table.insert(connections, notif.MouseEnter:Connect(function()
            notif:SetAttribute("IsPaused", true)
            VapeV5.Tween:Create(notif, {BackgroundTransparency = 0}, 0.15)
            VapeV5.Tween:Create(notif:FindFirstChild("Stroke"), {Transparency = 0.7}, 0.15)
        end))
        
        table.insert(connections, notif.MouseLeave:Connect(function()
            notif:SetAttribute("IsPaused", false)
            VapeV5.Tween:Create(notif, {BackgroundTransparency = 0.02}, 0.15)
            VapeV5.Tween:Create(notif:FindFirstChild("Stroke"), {Transparency = 0.85}, 0.15)
        end))
    end
    
    -- Botão de fechar
    if closeButton then
        table.insert(connections, closeButton.MouseEnter:Connect(function()
            VapeV5.Tween:Create(closeButton, {
                TextColor3 = theme.Error,
                BackgroundTransparency = 0.9
            }, 0.15)
        end))
        
        table.insert(connections, closeButton.MouseLeave:Connect(function()
            VapeV5.Tween:Create(closeButton, {
                TextColor3 = theme.TextDark,
                BackgroundTransparency = 1
            }, 0.15)
        end))
        
        table.insert(connections, closeButton.MouseButton1Click:Connect(function()
            self:_DismissNotification(notif, true)
        end))
    end
    
    -- Click para efeito ripple
    table.insert(connections, notif.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:_CreateRippleEffect(notif, input.Position)
        end
    end))
end

function NotificationSystem:_CreateRippleEffect(notif, position)
    local theme = VapeV5.Settings.Theme
    local notifType = notif:GetAttribute("Type") or "Info"
    
    local typeColors = {
        Info = theme.Accent,
        Success = theme.Success,
        Warning = theme.Warning,
        Error = theme.Error,
    }
    
    local ripple = Instance.new("Frame")
    ripple.Size = UDim2.fromOffset(0, 0)
    ripple.Position = UDim2.fromOffset(
        position.X - notif.AbsolutePosition.X,
        position.Y - notif.AbsolutePosition.Y
    )
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = typeColors[notifType] or theme.Accent
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.ZIndex = 10
    ripple.Parent = notif
    
    local rippleCorner = Instance.new("UICorner")
    rippleCorner.CornerRadius = UDim.new(1, 0)
    rippleCorner.Parent = ripple
    
    VapeV5.Tween:Create(ripple, {
        Size = UDim2.fromOffset(200, 200),
        BackgroundTransparency = 1
    }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

-- ═══════════════════════════════════════════════════════════════════
-- 📤 PROCESSADOR DE FILA
-- ═══════════════════════════════════════════════════════════════════

function NotificationSystem:_StartQueueProcessor()
    task.spawn(function()
        while true do
            if #self._queue > 0 and self:_GetActiveCount() < self._config.MaxVisible then
                local options = table.remove(self._queue, 1)
                self:_DisplayNotification(options)
            end
            task.wait(0.1)
        end
    end)
end

function NotificationSystem:_GetActiveCount()
    local count = 0
    for _ in pairs(self._active) do
        count = count + 1
    end
    return count
end

-- ═══════════════════════════════════════════════════════════════════
-- 🔔 ENVIO DE NOTIFICAÇÕES
-- ═══════════════════════════════════════════════════════════════════

function NotificationSystem:Send(options)
    if not VapeV5.Settings.General.Notifications then return end
    if not self._container then return end
    
    options = Utils.ValidateOptions(options, {
        Title = "Notification",
        Message = "",
        Duration = self._config.DefaultDuration,
        Type = "Info",
        Icon = nil,
        Priority = 1,
        Callback = nil,
        Persistent = false,
        Sound = true,
    })
    
    -- Verificar agrupamento de notificações similares
    if self._config.StackSimilar then
        local existing = self:_FindSimilarNotification(options)
        if existing then
            self:_IncrementNotificationCount(existing)
            return existing
        end
    end
    
    -- Adicionar à fila ou exibir diretamente
    if self:_GetActiveCount() >= self._config.MaxVisible then
        table.insert(self._queue, options)
        table.sort(self._queue, function(a, b)
            return (a.Priority or 1) > (b.Priority or 1)
        end)
    else
        self:_DisplayNotification(options)
    end
end

function NotificationSystem:_FindSimilarNotification(options)
    for notif, data in pairs(self._active) do
        if data.Title == options.Title and data.Type == options.Type then
            return notif
        end
    end
    return nil
end

function NotificationSystem:_IncrementNotificationCount(notif)
    local data = self._active[notif]
    if not data then return end
    
    data.Count = (data.Count or 1) + 1
    
    local countBadge = notif:FindFirstChild("CountBadge")
    if countBadge then
        countBadge.Visible = true
        local countLabel = countBadge:FindFirstChild("CountLabel")
        if countLabel then
            countLabel.Text = tostring(data.Count)
        end
        
        -- Animação de bounce no badge
        VapeV5.Tween:Create(countBadge, {Size = UDim2.fromOffset(28, 22)}, 0.1)
        task.delay(0.1, function()
            VapeV5.Tween:Create(countBadge, {Size = UDim2.fromOffset(24, 18)}, 0.1)
        end)
    end
    
    -- Reset do timer
    notif:SetAttribute("ElapsedTime", 0)
    
    -- Animação de shake
    self:_ShakeNotification(notif)
end

function NotificationSystem:_ShakeNotification(notif)
    local originalPos = notif.Position
    
    for i = 1, 3 do
        VapeV5.Tween:Create(notif, {
            Position = originalPos + UDim2.fromOffset(i % 2 == 0 and 5 or -5, 0)
        }, 0.05)
        task.wait(0.05)
    end
    
    VapeV5.Tween:Create(notif, {Position = originalPos}, 0.05)
end

function NotificationSystem:_DisplayNotification(options)
    local theme = VapeV5.Settings.Theme
    
    task.spawn(function()
        local title = options.Title
        local message = options.Message
        local duration = options.Duration
        local notifType = options.Type
        local icon = options.Icon
        local callback = options.Callback
        local persistent = options.Persistent
        
        local typeColors = {
            Info = theme.Accent,
            Success = theme.Success or Color3.fromRGB(76, 175, 80),
            Warning = theme.Warning or Color3.fromRGB(255, 193, 7),
            Error = theme.Error or Color3.fromRGB(244, 67, 54),
        }
        
        local color = typeColors[notifType] or theme.Accent
        
        local yOffset = self:_CalculateYOffset()
        
        local notif, isNew = self:_GetFromPool()
        
        -- Calcular largura dinâmica
        local messageWidth = Utils.GetTextSize(
            Utils.RemoveTags(message), 
            13, 
            VapeV5.Settings.Fonts.Regular
        ).X
        local titleWidth = Utils.GetTextSize(
            title, 
            15, 
            VapeV5.Settings.Fonts.Bold
        ).X
        local contentWidth = math.max(messageWidth, titleWidth)
        local notifWidth = math.clamp(contentWidth + 100, 280, 450)
        
        notif.Size = UDim2.fromOffset(notifWidth, 85)
        notif.Position = UDim2.new(1, 20, 1, -(95 + yOffset))
        notif.BackgroundColor3 = theme.Primary
        notif:SetAttribute("Duration", duration)
        notif:SetAttribute("Type", notifType)
        notif:SetAttribute("ElapsedTime", 0)
        notif:SetAttribute("IsPaused", false)
        
        self._active[notif] = {
            Title = title,
            Type = notifType,
            Count = 1,
            StartTime = tick(),
            Callback = callback,
        }
        
        -- Atualizar elementos visuais
        local sideBar = notif:FindFirstChild("SideBar")
        if sideBar then
            sideBar.BackgroundColor3 = color
            local sideGlow = sideBar:FindFirstChild("SideGlow")
            if sideGlow then sideGlow.ImageColor3 = color end
        end
        
        local iconContainer = notif:FindFirstChild("IconContainer")
        if iconContainer then
            iconContainer.BackgroundColor3 = color
            local iconLabel = iconContainer:FindFirstChild("Icon")
            if iconLabel then
                iconLabel.Image = icon or AssetSystem:Get("Notification." .. notifType) or ""
                iconLabel.ImageColor3 = color
                iconLabel.ScaleType = Enum.ScaleType.Fit
            end
        end
        
        local titleLabel = notif:FindFirstChild("Title")
        if titleLabel then
            titleLabel.Text = title
            titleLabel.TextColor3 = theme.Text
        end
        
        local messageLabel = notif:FindFirstChild("Message")
        if messageLabel then
            messageLabel.Text = message
            messageLabel.TextColor3 = theme.TextDark
        end
        
        local countBadge = notif:FindFirstChild("CountBadge")
        if countBadge then
            countBadge.Visible = false
            countBadge.BackgroundColor3 = color
        end
        
        local progressContainer = notif:FindFirstChild("ProgressContainer")
        if progressContainer then
            local progressBar = progressContainer:FindFirstChild("ProgressBar")
            if progressBar then
                progressBar.Size = UDim2.fromScale(1, 1)
                progressBar.BackgroundColor3 = color
            end
        end
        
        -- Tocar som
        if self._config.EnableSounds and options.Sound and VapeV5.Settings.General.Sounds then
            self:_PlaySound(notifType)
        end
        
        -- Animação de entrada
        VapeV5.Tween:Create(notif, {
            Position = UDim2.new(1, -notifWidth - 20, 1, -(95 + yOffset))
        }, self._config.AnimationSpeed, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        -- Animação do ícone (bounce)
        task.delay(0.2, function()
            if iconContainer then
                VapeV5.Tween:Create(iconContainer, {
                    Size = UDim2.fromOffset(40, 40),
                    Position = UDim2.fromOffset(16, 22)
                }, 0.12, Enum.EasingStyle.Back)
                
                task.wait(0.12)
                
                VapeV5.Tween:Create(iconContainer, {
                    Size = UDim2.fromOffset(36, 36),
                    Position = UDim2.fromOffset(18, 24)
                }, 0.08, Enum.EasingStyle.Quad)
            end
        end)
        
        -- Animação da barra de progresso
        if not persistent then
            self:_StartProgressAnimation(notif, duration, color)
        end
    end)
end

function NotificationSystem:_CalculateYOffset()
    local offset = 0
    local spacing = self._config.Spacing
    
    local sorted = {}
    for notif, data in pairs(self._active) do
        table.insert(sorted, {notif = notif, start = data.StartTime or 0})
    end
    
    table.sort(sorted, function(a, b)
        return a.start < b.start
    end)
    
    for _, item in ipairs(sorted) do
        offset = offset + item.notif.Size.Y.Offset + spacing
    end
    
    return offset
end

function NotificationSystem:_StartProgressAnimation(notif, duration, color)
    local progressContainer = notif:FindFirstChild("ProgressContainer")
    if not progressContainer then return end
    
    local progressBar = progressContainer:FindFirstChild("ProgressBar")
    if not progressBar then return end
    
    task.spawn(function()
        local elapsed = 0
        local interval = 0.016
        
        while elapsed < duration do
            if not notif or not notif.Parent then break end
            if not self._active[notif] then break end
            
            if not notif:GetAttribute("IsPaused") then
                elapsed = elapsed + interval
                notif:SetAttribute("ElapsedTime", elapsed)
                
                local progress = 1 - (elapsed / duration)
                progressBar.Size = UDim2.new(progress, 0, 1, 0)
            end
            
            task.wait(interval)
        end
        
        if notif and notif.Parent and self._active[notif] then
            self:_DismissNotification(notif, false)
        end
    end)
end

function NotificationSystem:_DismissNotification(notif, instant)
    if not self._active[notif] then return end
    
    local data = self._active[notif]
    self._active[notif] = nil
    
    if data.Callback then
        pcall(data.Callback)
    end
    
    local animDuration = instant and 0.15 or 0.3
    
    VapeV5.Tween:Create(notif, {
        Position = UDim2.new(1, 30, notif.Position.Y.Scale, notif.Position.Y.Offset),
        BackgroundTransparency = 1
    }, animDuration, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    
    for _, child in pairs(notif:GetDescendants()) do
        if child:IsA("TextLabel") then
            VapeV5.Tween:Create(child, {TextTransparency = 1}, animDuration * 0.8)
        elseif child:IsA("ImageLabel") then
            VapeV5.Tween:Create(child, {ImageTransparency = 1}, animDuration * 0.8)
        elseif child:IsA("Frame") and not child.Name:match("Shadow") then
            VapeV5.Tween:Create(child, {BackgroundTransparency = 1}, animDuration * 0.8)
        end
    end
    
    task.delay(animDuration + 0.05, function()
        if notif and notif.Parent then
            self:_ResetNotificationVisual(notif)
            self:_ReturnToPool(notif)
        end
        
        self:_RepositionNotifications()
    end)
end

function NotificationSystem:_ResetNotificationVisual(notif)
    local theme = VapeV5.Settings.Theme
    
    notif.BackgroundTransparency = 0.02
    
    for _, child in pairs(notif:GetDescendants()) do
        if child:IsA("TextLabel") then
            child.TextTransparency = 0
        elseif child:IsA("ImageLabel") then
            child.ImageTransparency = 0
        elseif child:IsA("Frame") and child.Name ~= "Shadow1" and child.Name ~= "Shadow2" and child.Name ~= "Shadow3" then
            if child.Name == "ProgressBar" then
                child.Size = UDim2.fromScale(1, 1)
            end
            child.BackgroundTransparency = child:GetAttribute("OriginalTransparency") or 0
        end
    end
end

function NotificationSystem:_RepositionNotifications()
    local sorted = {}
    for notif, _ in pairs(self._active) do
        table.insert(sorted, notif)
    end
    
    table.sort(sorted, function(a, b)
        local dataA = self._active[a]
        local dataB = self._active[b]
        return (dataA.StartTime or 0) < (dataB.StartTime or 0)
    end)
    
    local yOffset = 0
    for i, notif in ipairs(sorted) do
        local targetY = -(95 + yOffset)
        
        VapeV5.Tween:Create(notif, {
            Position = UDim2.new(1, -notif.Size.X.Offset - 20, 1, targetY)
        }, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        yOffset = yOffset + notif.Size.Y.Offset + self._config.Spacing
    end
end

function NotificationSystem:_PlaySound(notifType)
    if not VapeV5.Settings.General.Sounds then return end
    
    local soundId = self._sounds[notifType] or self._sounds.Info
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 0.5
    sound.PlaybackSpeed = notifType == "Error" and 0.8 or 1
    sound.Parent = Services.SoundService
    sound:Play()
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

function NotificationSystem:ClearAll()
    for notif, _ in pairs(self._active) do
        self:_DismissNotification(notif, true)
    end
    self._queue = {}
end

function NotificationSystem:SetConfig(key, value)
    if self._config[key] ~= nil then
        self._config[key] = value
    end
end

function NotificationSystem:GetActiveCount()
    return self:_GetActiveCount()
end

-- Wrapper que aceita ambos : e .
local function CreateNotifyWrapper()
    local originalSend = function(title, message, duration, notifType)
        NotificationSystem:Send({
            Title = title,
            Message = message,
            Duration = duration,
            Type = notifType
        })
    end
    
    return function(self_or_title, maybe_title, maybe_message, maybe_duration, maybe_type)
        if type(self_or_title) == "table" and type(maybe_title) == "string" then
            return originalSend(maybe_title, maybe_message, maybe_duration, maybe_type)
        else
            return originalSend(self_or_title, maybe_title, maybe_message, maybe_duration)
        end
    end
end

VapeV5.Notify = CreateNotifyWrapper()
VapeV5.Notifications = NotificationSystem

-- ═══════════════════════════════════════════════════════════════════
-- 🧱 COMPONENTES BASE
-- ═══════════════════════════════════════════════════════════════════

local Components = {}

function Components.AddCorner(parent, radius)
    if not parent then return nil end
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 6)
    corner.Parent = parent
    return corner
end

function Components.AddShadow(parent, options)
    if not parent then return nil end
    options = options or {}
    
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, options.Expand or 16, 1, options.Expand or 16)
    shadow.Position = UDim2.fromOffset(-(options.Expand or 16) / 2, -(options.Expand or 16) / 2)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = options.Transparency or 0.6
    shadow.BorderSizePixel = 0
    shadow.ZIndex = -1
    shadow.Parent = parent
    
    Components.AddCorner(shadow, options.Radius or UDim.new(0, 10))
    
    return shadow
end

function Components.AddStroke(parent, options)
    if not parent then return nil end
    options = options or {}
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = options.Color or ColorSystem.Light(VapeV5.Settings.Theme.Primary, 0.1)
    stroke.Thickness = options.Thickness or 1
    stroke.Transparency = options.Transparency or 0
    stroke.Parent = parent
    
    return stroke
end

function Components.AddGradient(parent, options)
    if not parent then return nil end
    options = options or {}
    
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = options.Rotation or 90
    
    if options.Colors then
        local keypoints = {}
        for i, color in ipairs(options.Colors) do
            table.insert(keypoints, ColorSequenceKeypoint.new((i - 1) / (#options.Colors - 1), color))
        end
        gradient.Color = ColorSequence.new(keypoints)
    end
    
    gradient.Parent = parent
    return gradient
end

function Components.AddAspectRatio(parent, ratio)
    if not parent then return nil end
    local constraint = Instance.new("UIAspectRatioConstraint")
    constraint.AspectRatio = ratio or 1
    constraint.Parent = parent
    return constraint
end

function Components.CreateCloseButton(parent, callback)
    if not parent then return nil end
    local theme = VapeV5.Settings.Theme
    
    local button = Instance.new("ImageButton")
    button.Name = "CloseButton"
    button.Size = UDim2.fromOffset(24, 24)
    button.Position = UDim2.new(1, -35, 0, 10)
    button.BackgroundColor3 = Color3.new(1, 1, 1)
    button.BackgroundTransparency = 1
    button.AutoButtonColor = false
    button.Image = AssetSystem:Get("Close")
    button.ImageColor3 = ColorSystem.Light(theme.Text, 0.3)
    button.ImageTransparency = 0.5
    button.Parent = parent
    
    Components.AddCorner(button, UDim.new(1, 0))
    
    button.MouseEnter:Connect(function()
        button.ImageTransparency = 0.2
        VapeV5.Tween:Create(button, {BackgroundTransparency = 0.8}, 0.1)
    end)
    
    button.MouseLeave:Connect(function()
        button.ImageTransparency = 0.5
        VapeV5.Tween:Create(button, {BackgroundTransparency = 1}, 0.1)
    end)
    
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return button
end

function Components.AddTooltip(element, text)
    if not text or not element or not VapeV5.Settings.General.Tooltips then return end
    
    local tooltip = VapeV5._tooltip
    if not tooltip then return end
    
    local function updatePosition(x, y)
        local size = Utils.GetTextSize(text, 12, VapeV5.Settings.Fonts.Regular)
        tooltip.Size = UDim2.fromOffset(size.X + 16, size.Y + 12)
        tooltip.Text = text
        
        local gui = VapeV5._gui
        if not gui then return end
        
        local guiSize = gui.AbsoluteSize
        local scale = VapeV5._scale and VapeV5._scale.Scale or 1
        
        local posX = x + 16
        local posY = y - (tooltip.Size.Y.Offset / 2)
        
        if posX + tooltip.Size.X.Offset > guiSize.X then
            posX = x - tooltip.Size.X.Offset - 16
        end
        
        tooltip.Position = UDim2.fromOffset(posX / scale, posY / scale)
        tooltip.Visible = true
    end
    
    element.MouseEnter:Connect(function(x, y)
        updatePosition(x, y)
    end)
    
    element.MouseMoved:Connect(function(x, y)
        updatePosition(x, y)
    end)
    
    element.MouseLeave:Connect(function()
        tooltip.Visible = false
    end)
end

function Components.MakeDraggable(element, handle)
    if not element then return end
    handle = handle or element
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = element.Position
        end
    end)
    
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local scale = VapeV5._scale and VapeV5._scale.Scale or 1
            
            local newX = startPos.X.Offset + delta.X / scale
            local newY = startPos.Y.Offset + delta.Y / scale
            
            local gui = VapeV5._gui
            if gui then
                local guiSize = gui.AbsoluteSize / scale
                newX = math.clamp(newX, 0, guiSize.X - element.AbsoluteSize.X / scale)
                newY = math.clamp(newY, 0, guiSize.Y - element.AbsoluteSize.Y / scale)
            end
            
            element.Position = UDim2.fromOffset(newX, newY)
        end
    end)
end

function Components.AddHoverEffect(element, options)
    if not element then return end
    options = options or {}
    
    local originalColor = options.OriginalColor or element.BackgroundColor3
    local hoverColor = options.HoverColor or ColorSystem.Light(originalColor, 0.05)
    local duration = options.Duration or 0.1
    
    element.MouseEnter:Connect(function()
        VapeV5.Tween:Create(element, {BackgroundColor3 = hoverColor}, duration)
        
        if options.Lift then
            VapeV5.Tween:Create(element, {
                Position = UDim2.new(
                    element.Position.X.Scale,
                    element.Position.X.Offset,
                    element.Position.Y.Scale,
                    element.Position.Y.Offset - 2
                )
            }, duration)
        end
    end)
    
    element.MouseLeave:Connect(function()
        VapeV5.Tween:Create(element, {BackgroundColor3 = originalColor}, duration)
        
        if options.Lift then
            VapeV5.Tween:Create(element, {
                Position = UDim2.new(
                    element.Position.X.Scale,
                    element.Position.X.Offset,
                    element.Position.Y.Scale,
                    element.Position.Y.Offset + 2
                )
            }, duration)
        end
    end)
end

VapeV5.Components = Components

-- ═══════════════════════════════════════════════════════════════════
-- 📦 COMPONENTES DE INPUT
-- ═══════════════════════════════════════════════════════════════════

local InputComponents = {}

-- Toggle/Switch
function InputComponents.CreateToggle(parent, options)
    options = Utils.ValidateOptions(options, {
        Name = "Toggle",
        Default = false,
        Tooltip = nil,
        Darker = false,
        Callback = function() end
    })
    
    local theme = VapeV5.Settings.Theme
    
    local api = {
        Type = "Toggle",
        Enabled = options.Default,
        Callback = options.Callback,
    }
    
    local container = Instance.new("TextButton")
    container.Name = options.Name .. "Toggle"
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundColor3 = ColorSystem.Dark(parent.BackgroundColor3, options.Darker and 0.02 or 0)
    container.BackgroundTransparency = 0
    container.BorderSizePixel = 0
    container.AutoButtonColor = false
    container.Text = "          " .. options.Name
    container.TextXAlignment = Enum.TextXAlignment.Left
    container.TextColor3 = ColorSystem.Dark(theme.Text, 0.16)
    container.TextSize = 14
    container.FontFace = VapeV5.Settings.Fonts.Regular
    container.Parent = parent
    
    if options.Tooltip then
        Components.AddTooltip(container, options.Tooltip)
    end
    
    local knobHolder = Instance.new("Frame")
    knobHolder.Name = "KnobHolder"
    knobHolder.Size = UDim2.fromOffset(22, 12)
    knobHolder.Position = UDim2.new(1, -32, 0, 10)
    knobHolder.BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.14)
    knobHolder.Parent = container
    Components.AddCorner(knobHolder, UDim.new(1, 0))
    
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.fromOffset(8, 8)
    knob.Position = UDim2.fromOffset(2, 2)
    knob.BackgroundColor3 = theme.Primary
    knob.Parent = knobHolder
    Components.AddCorner(knob, UDim.new(1, 0))
    
    function api:SetValue(value, silent)
        self.Enabled = value
        
        VapeV5.Tween:Create(knobHolder, {
            BackgroundColor3 = value and theme.Accent or ColorSystem.Light(theme.Primary, 0.14)
        }, 0.15)
        
        VapeV5.Tween:Create(knob, {
            Position = UDim2.fromOffset(value and 12 or 2, 2),
            BackgroundColor3 = value and Color3.new(1, 1, 1) or theme.Primary
        }, 0.15)
        
        if not silent then
            self.Callback(value)
        end
    end
    
    function api:Toggle()
        self:SetValue(not self.Enabled)
    end
    
    function api:Save(data)
        data[options.Name] = {Enabled = self.Enabled}
    end
    
    function api:Load(data)
        if data and data.Enabled ~= nil and data.Enabled ~= self.Enabled then
            self:SetValue(data.Enabled)
        end
    end
    
    container.MouseEnter:Connect(function()
        if not api.Enabled then
            VapeV5.Tween:Create(knobHolder, {
                BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.25)
            }, 0.1)
        end
        VapeV5.Tween:Create(container, {
            BackgroundColor3 = ColorSystem.Light(container.BackgroundColor3, 0.02)
        }, 0.1)
    end)
    
    container.MouseLeave:Connect(function()
        if not api.Enabled then
            VapeV5.Tween:Create(knobHolder, {
                BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.14)
            }, 0.1)
        end
        VapeV5.Tween:Create(container, {
            BackgroundColor3 = ColorSystem.Dark(parent.BackgroundColor3, options.Darker and 0.02 or 0)
        }, 0.1)
    end)
    
    container.MouseButton1Click:Connect(function()
        api:Toggle()
    end)
    
    if options.Default then
        api:SetValue(true, true)
    end
    
    api.Object = container
    return api
end

-- Slider
function InputComponents.CreateSlider(parent, options)
    options = Utils.ValidateOptions(options, {
        Name = "Slider",
        Min = 0,
        Max = 100,
        Default = 0,
        Decimal = 1,
        Suffix = "",
        Tooltip = nil,
        Darker = false,
        Callback = function() end
    })
    
    local theme = VapeV5.Settings.Theme
    
    local api = {
        Type = "Slider",
        Value = options.Default,
        Min = options.Min,
        Max = options.Max,
        Decimal = options.Decimal,
        Callback = options.Callback,
    }
    
    local container = Instance.new("TextButton")
    container.Name = options.Name .. "Slider"
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundColor3 = ColorSystem.Dark(parent.BackgroundColor3, options.Darker and 0.02 or 0)
    container.BorderSizePixel = 0
    container.AutoButtonColor = false
    container.Text = ""
    container.Parent = parent
    
    if options.Tooltip then
        Components.AddTooltip(container, options.Tooltip)
    end
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 0, 20)
    title.Position = UDim2.fromOffset(10, 5)
    title.BackgroundTransparency = 1
    title.Text = options.Name
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = ColorSystem.Dark(theme.Text, 0.16)
    title.TextSize = 12
    title.FontFace = VapeV5.Settings.Fonts.Regular
    title.Parent = container
    
    local valueLabel = Instance.new("TextBox")
    valueLabel.Size = UDim2.new(0.4, -10, 0, 20)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(api.Value) .. options.Suffix
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.TextColor3 = theme.Accent
    valueLabel.TextSize = 12
    valueLabel.FontFace = VapeV5.Settings.Fonts.SemiBold
    valueLabel.ClearTextOnFocus = false
    valueLabel.Parent = container

    valueLabel.FocusLost:Connect(function()
        local rawText = valueLabel.Text:gsub(options.Suffix, "")
        local num = tonumber(rawText)
        if num then
            api:SetValue(num)
        else
            valueLabel.Text = tostring(api.Value) .. options.Suffix
        end
    end)
    
    local barBg = Instance.new("Frame")
    barBg.Name = "BarBackground"
    barBg.Size = UDim2.new(1, -20, 0, 6)
    barBg.Position = UDim2.fromOffset(10, 32)
    barBg.BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.08)
    barBg.BorderSizePixel = 0
    barBg.Parent = container
    Components.AddCorner(barBg, UDim.new(1, 0))
    
    local barFill = Instance.new("Frame")
    barFill.Name = "BarFill"
    barFill.Size = UDim2.fromScale(math.max((api.Value - api.Min) / (api.Max - api.Min), 0.02), 1)
    barFill.BackgroundColor3 = theme.Accent
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
    Components.AddCorner(barFill, UDim.new(1, 0))
    
    local fillGlow = Instance.new("Frame")
    fillGlow.Size = UDim2.new(1, 4, 1, 4)
    fillGlow.Position = UDim2.fromOffset(-2, -2)
    fillGlow.BackgroundColor3 = theme.Accent
    fillGlow.BackgroundTransparency = 0.7
    fillGlow.BorderSizePixel = 0
    fillGlow.ZIndex = -1
    fillGlow.Parent = barFill
    Components.AddCorner(fillGlow, UDim.new(1, 0))
    
    local knobHolder = Instance.new("Frame")
    knobHolder.Size = UDim2.fromOffset(16, 16)
    knobHolder.Position = UDim2.fromScale(1, 0.5)
    knobHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    knobHolder.BackgroundTransparency = 1
    knobHolder.Parent = barFill
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(12, 12)
    knob.Position = UDim2.fromScale(0.5, 0.5)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = theme.Accent
    knob.Parent = knobHolder
    Components.AddCorner(knob, UDim.new(1, 0))
    
    local knobBorder = Instance.new("UIStroke")
    knobBorder.Color = Color3.new(1, 1, 1)
    knobBorder.Thickness = 2
    knobBorder.Parent = knob
    
    function api:SetValue(value, silent)
        value = math.clamp(value, self.Min, self.Max)
        value = math.floor(value * self.Decimal) / self.Decimal
        
        self.Value = value
        valueLabel.Text = tostring(value) .. options.Suffix
        
        local percent = (value - self.Min) / (self.Max - self.Min)
        VapeV5.Tween:Create(barFill, {
            Size = UDim2.fromScale(math.max(percent, 0.02), 1)
        }, 0.1)
        
        if not silent then
            self.Callback(value)
        end
    end
    
    function api:Save(data)
        data[options.Name] = {Value = self.Value}
    end
    
    function api:Load(data)
        if data and data.Value ~= nil and self.Value ~= data.Value then
            self:SetValue(data.Value)
        end
    end
    
    local dragging = false
    
    local function updateFromInput(input)
        local percent = math.clamp((input.Position.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local value = api.Min + (api.Max - api.Min) * percent
        api:SetValue(value)
    end
    
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if input.Position.Y - container.AbsolutePosition.Y > 20 then
                dragging = true
                updateFromInput(input)
            end
        end
    end)
    
    container.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromInput(input)
        end
    end)
    
    container.MouseEnter:Connect(function()
        VapeV5.Tween:Create(knob, {Size = UDim2.fromOffset(14, 14)}, 0.1)
        VapeV5.Tween:Create(fillGlow, {BackgroundTransparency = 0.5}, 0.1)
    end)
    
    container.MouseLeave:Connect(function()
        VapeV5.Tween:Create(knob, {Size = UDim2.fromOffset(12, 12)}, 0.1)
        VapeV5.Tween:Create(fillGlow, {BackgroundTransparency = 0.7}, 0.1)
    end)
    
    api:SetValue(options.Default, true)
    
    api.Object = container
    return api
end

-- Dropdown
function InputComponents.CreateDropdown(parent, options)
    options = Utils.ValidateOptions(options, {
        Name = "Dropdown",
        List = {},
        Default = nil,
        Tooltip = nil,
        Darker = false,
        Callback = function() end
    })
    
    local theme = VapeV5.Settings.Theme
    
    if not options.Default and #options.List > 0 then
        options.Default = options.List[1]
    end
    
    local api = {
        Type = "Dropdown",
        Value = options.Default or "None",
        List = options.List,
        Callback = options.Callback,
        Expanded = false,
    }
    
    local container = Instance.new("TextButton")
    container.Name = options.Name .. "Dropdown"
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = ColorSystem.Dark(parent.BackgroundColor3, options.Darker and 0.02 or 0)
    container.BorderSizePixel = 0
    container.AutoButtonColor = false
    container.Text = ""
    container.ClipsDescendants = true
    container.Parent = parent
    
    if options.Tooltip then
        Components.AddTooltip(container, options.Tooltip)
    end
    
    local selectionBg = Instance.new("Frame")
    selectionBg.Size = UDim2.new(1, -20, 0, 30)
    selectionBg.Position = UDim2.fromOffset(10, 5)
    selectionBg.BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.03)
    selectionBg.Parent = container
    Components.AddCorner(selectionBg, UDim.new(0, 6))
    Components.AddStroke(selectionBg, {Color = ColorSystem.Light(theme.Primary, 0.08)})
    
    local currentText = Instance.new("TextLabel")
    currentText.Size = UDim2.new(1, -30, 1, 0)
    currentText.Position = UDim2.fromOffset(10, 0)
    currentText.BackgroundTransparency = 1
    currentText.Text = options.Name .. " - " .. api.Value
    currentText.TextXAlignment = Enum.TextXAlignment.Left
    currentText.TextColor3 = ColorSystem.Dark(theme.Text, 0.16)
    currentText.TextSize = 13
    currentText.TextTruncate = Enum.TextTruncate.AtEnd
    currentText.FontFace = VapeV5.Settings.Fonts.Regular
    currentText.Parent = selectionBg
    
    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.fromOffset(8, 8)
    arrow.Position = UDim2.new(1, -20, 0.5, -4)
    arrow.BackgroundTransparency = 1
    arrow.Image = AssetSystem:Get("Arrow")
    arrow.ImageColor3 = theme.TextDark
    arrow.Rotation = 90
    arrow.Parent = selectionBg
    
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(1, -20, 0, 0)
    optionsFrame.Position = UDim2.fromOffset(10, 38)
    optionsFrame.BackgroundTransparency = 1
    optionsFrame.ClipsDescendants = true
    optionsFrame.Parent = container
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = optionsFrame
    
    local function createOptions()
        for _, child in ipairs(optionsFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        for i, item in ipairs(api.List) do
            if item == api.Value then continue end
            
            local option = Instance.new("TextButton")
            option.Size = UDim2.new(1, 0, 0, 28)
            option.BackgroundColor3 = theme.Primary
            option.BackgroundTransparency = 1
            option.BorderSizePixel = 0
            option.AutoButtonColor = false
            option.Text = "    " .. item
            option.TextXAlignment = Enum.TextXAlignment.Left
            option.TextColor3 = ColorSystem.Dark(theme.Text, 0.2)
            option.TextSize = 13
            option.FontFace = VapeV5.Settings.Fonts.Regular
            option.LayoutOrder = i
            option.Parent = optionsFrame
            
            option.MouseEnter:Connect(function()
                VapeV5.Tween:Create(option, {BackgroundTransparency = 0.5}, 0.1)
            end)
            
            option.MouseLeave:Connect(function()
                VapeV5.Tween:Create(option, {BackgroundTransparency = 1}, 0.1)
            end)
            
            option.MouseButton1Click:Connect(function()
                api:SetValue(item)
            end)
        end
    end
    
    function api:SetValue(value, silent)
        if table.find(self.List, value) then
            self.Value = value
        elseif #self.List > 0 then
            self.Value = self.List[1]
        else
            self.Value = "None"
        end
        
        currentText.Text = options.Name .. " - " .. self.Value
        self:Collapse()
        
        if not silent then
            self.Callback(self.Value)
        end
    end
    
    function api:Expand()
        if self.Expanded then return end
        self.Expanded = true
        
        createOptions()
        
        arrow.Rotation = 270
        
        local itemCount = math.max(#self.List - 1, 0)
        local targetHeight = 40 + (itemCount * 28)
        
        VapeV5.Tween:Create(container, {
            Size = UDim2.new(1, 0, 0, targetHeight)
        }, 0.2)
        
        VapeV5.Tween:Create(optionsFrame, {
            Size = UDim2.new(1, -20, 0, itemCount * 28)
        }, 0.2)
    end
    
    function api:Collapse()
        if not self.Expanded then return end
        self.Expanded = false
        
        arrow.Rotation = 90
        
        VapeV5.Tween:Create(container, {
            Size = UDim2.new(1, 0, 0, 40)
        }, 0.2)
        
        VapeV5.Tween:Create(optionsFrame, {
            Size = UDim2.new(1, -20, 0, 0)
        }, 0.2)
    end
    
    function api:Toggle()
        if self.Expanded then
            self:Collapse()
        else
            self:Expand()
        end
    end
    
    function api:UpdateList(newList)
        self.List = newList
        if not table.find(self.List, self.Value) then
            self:SetValue(self.List[1], true)
        end
        if self.Expanded then
            createOptions()
        end
    end
    
    function api:Save(data)
        data[options.Name] = {Value = self.Value}
    end
    
    function api:Load(data)
        if data and data.Value ~= nil and self.Value ~= data.Value then
            self:SetValue(data.Value, true)
        end
    end
    
    selectionBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            api:Toggle()
        end
    end)
    
    container.MouseEnter:Connect(function()
        VapeV5.Tween:Create(selectionBg, {
            BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.08)
        }, 0.1)
    end)
    
    container.MouseLeave:Connect(function()
        VapeV5.Tween:Create(selectionBg, {
            BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.03)
        }, 0.1)
    end)
    
    api.Object = container
    return api
end

-- TextBox
function InputComponents.CreateTextBox(parent, options)
    options = Utils.ValidateOptions(options, {
        Name = "TextBox",
        Default = "",
        Placeholder = "Enter text...",
        Tooltip = nil,
        Darker = false,
        Callback = function() end
    })
    
    local theme = VapeV5.Settings.Theme
    
    local api = {
        Type = "TextBox",
        Value = options.Default,
        Callback = options.Callback,
    }
    
    local container = Instance.new("Frame")
    container.Name = options.Name .. "TextBox"
    container.Size = UDim2.new(1, 0, 0, 58)
    container.BackgroundColor3 = ColorSystem.Dark(parent.BackgroundColor3, options.Darker and 0.02 or 0)
    container.BorderSizePixel = 0
    container.Parent = parent
    
    if options.Tooltip then
        Components.AddTooltip(container, options.Tooltip)
    end
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 20)
    title.Position = UDim2.fromOffset(10, 5)
    title.BackgroundTransparency = 1
    title.Text = options.Name
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = theme.Text
    title.TextSize = 12
    title.FontFace = VapeV5.Settings.Fonts.Regular
    title.Parent = container
    
    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(1, -20, 0, 28)
    inputBg.Position = UDim2.fromOffset(10, 25)
    inputBg.BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.03)
    inputBg.Parent = container
    Components.AddCorner(inputBg, UDim.new(0, 4))
    Components.AddStroke(inputBg, {Color = ColorSystem.Light(theme.Primary, 0.08)})
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -16, 1, 0)
    input.Position = UDim2.fromOffset(8, 0)
    input.BackgroundTransparency = 1
    input.Text = api.Value
    input.PlaceholderText = options.Placeholder
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.TextColor3 = ColorSystem.Dark(theme.Text, 0.16)
    input.PlaceholderColor3 = ColorSystem.Dark(theme.Text, 0.4)
    input.TextSize = 12
    input.FontFace = VapeV5.Settings.Fonts.Regular
    input.ClearTextOnFocus = false
    input.Parent = inputBg
    
    function api:SetValue(value, silent)
        self.Value = value or ""
        input.Text = self.Value
        
        if not silent then
            self.Callback(self.Value)
        end
    end
    
    function api:Save(data)
        data[options.Name] = {Value = self.Value}
    end
    
    function api:Load(data)
        if data and data.Value ~= nil and self.Value ~= data.Value then
            self:SetValue(data.Value, true)
        end
    end
    
    input.Focused:Connect(function()
        VapeV5.Tween:Create(inputBg, {BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.08)}, 0.1)
    end)
    
    input.FocusLost:Connect(function(enterPressed)
        VapeV5.Tween:Create(inputBg, {BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.03)}, 0.1)
        api.Value = input.Text
        api.Callback(api.Value, enterPressed)
    end)
    
    input:GetPropertyChangedSignal("Text"):Connect(function()
        api.Value = input.Text
    end)
    
    api.Object = container
    return api
end

-- Color Picker
function InputComponents.CreateColorPicker(parent, options)
    options = Utils.ValidateOptions(options, {
        Name = "Color",
        DefaultHue = 0.44,
        DefaultSat = 1,
        DefaultValue = 1,
        Tooltip = nil,
        Darker = false,
        Callback = function() end
    })
    
    local theme = VapeV5.Settings.Theme
    
    local api = {
        Type = "ColorPicker",
        Hue = options.DefaultHue,
        Sat = options.DefaultSat,
        Value = options.DefaultValue,
        Rainbow = false,
        Callback = options.Callback,
    }
    
    local container = Instance.new("TextButton")
    container.Name = options.Name .. "ColorPicker"
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = ColorSystem.Dark(parent.BackgroundColor3, options.Darker and 0.02 or 0)
    container.BorderSizePixel = 0
    container.AutoButtonColor = false
    container.Text = ""
    container.Parent = parent
    
    if options.Tooltip then
        Components.AddTooltip(container, options.Tooltip)
    end
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.fromOffset(100, 20)
    title.Position = UDim2.fromOffset(10, 10)
    title.BackgroundTransparency = 1
    title.Text = options.Name
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = ColorSystem.Dark(theme.Text, 0.16)
    title.TextSize = 13
    title.FontFace = VapeV5.Settings.Fonts.Regular
    title.Parent = container
    
    local preview = Instance.new("Frame")
    preview.Size = UDim2.fromOffset(24, 24)
    preview.Position = UDim2.new(1, -34, 0, 8)
    preview.BackgroundColor3 = Color3.fromHSV(api.Hue, api.Sat, api.Value)
    preview.Parent = container
    Components.AddCorner(preview, UDim.new(0, 4))
    Components.AddStroke(preview, {Color = Color3.new(1, 1, 1), Thickness = 2})
    
    function api:SetValue(h, s, v, silent)
        self.Hue = h or self.Hue
        self.Sat = s or self.Sat
        self.Value = v or self.Value
        
        preview.BackgroundColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value)
        
        if not silent then
            self.Callback(self.Hue, self.Sat, self.Value)
        end
    end
    
    function api:GetColor()
        return Color3.fromHSV(self.Hue, self.Sat, self.Value)
    end
    
    function api:Save(data)
        data[options.Name] = {
            Hue = self.Hue,
            Sat = self.Sat,
            Value = self.Value,
            Rainbow = self.Rainbow
        }
    end
    
    function api:Load(data)
        if data then
            self.Rainbow = data.Rainbow or false
            self:SetValue(data.Hue, data.Sat, data.Value, true)
        end
    end
    
    container.MouseButton1Click:Connect(function()
        local clickGui = VapeV5._clickGui
        if not clickGui then return end
        
        local modalOverlay = Instance.new("TextButton")
        modalOverlay.Size = UDim2.fromScale(1, 1)
        modalOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        modalOverlay.BackgroundTransparency = 0.5
        modalOverlay.Text = ""
        modalOverlay.AutoButtonColor = false
        modalOverlay.ZIndex = 110
        modalOverlay.Parent = clickGui
        
        local pickerFrame = Instance.new("Frame")
        pickerFrame.Size = UDim2.fromOffset(260, 220)
        pickerFrame.Position = UDim2.fromScale(0.5, 0.5)
        pickerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        pickerFrame.BackgroundColor3 = theme.Primary
        pickerFrame.ZIndex = 111
        pickerFrame.Parent = modalOverlay
        Components.AddCorner(pickerFrame, UDim.new(0, 8))
        Components.AddShadow(pickerFrame)
        
        local pTitle = Instance.new("TextLabel")
        pTitle.Size = UDim2.new(1, -20, 0, 30)
        pTitle.Position = UDim2.fromOffset(10, 5)
        pTitle.BackgroundTransparency = 1
        pTitle.Text = options.Name .. " Picker"
        pTitle.TextColor3 = theme.Text
        pTitle.TextSize = 14
        pTitle.FontFace = VapeV5.Settings.Fonts.Bold
        pTitle.TextXAlignment = Enum.TextXAlignment.Left
        pTitle.ZIndex = 111
        pTitle.Parent = pickerFrame
        
        local colorDisplay = Instance.new("Frame")
        colorDisplay.Size = UDim2.new(1, -20, 0, 40)
        colorDisplay.Position = UDim2.fromOffset(10, 35)
        colorDisplay.BackgroundColor3 = Color3.fromHSV(api.Hue, api.Sat, api.Value)
        colorDisplay.ZIndex = 111
        colorDisplay.Parent = pickerFrame
        Components.AddCorner(colorDisplay, UDim.new(0, 4))
        
        local connections = {}
        
        modalOverlay.Destroying:Connect(function()
            for _, conn in ipairs(connections) do
                if conn.Disconnect then conn:Disconnect() end
            end
        end)
        
        local function createSlider(yPos, name, initialVal, updateFunc, isHue)
            local sliderBg = Instance.new("Frame")
            sliderBg.Size = UDim2.new(1, -20, 0, 30)
            sliderBg.Position = UDim2.fromOffset(10, yPos)
            sliderBg.BackgroundTransparency = 1
            sliderBg.ZIndex = 111
            sliderBg.Parent = pickerFrame
            
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.fromOffset(20, 20)
            lbl.Position = UDim2.fromOffset(0, 5)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = theme.TextDark
            lbl.TextSize = 12
            lbl.FontFace = VapeV5.Settings.Fonts.Regular
            lbl.ZIndex = 111
            lbl.Parent = sliderBg
            
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(1, -30, 0, 10)
            bar.Position = UDim2.fromOffset(30, 10)
            bar.BackgroundColor3 = Color3.new(1, 1, 1)
            bar.BorderSizePixel = 0
            bar.ZIndex = 111
            bar.Parent = sliderBg
            Components.AddCorner(bar, UDim.new(1, 0))
            
            if isHue then
                local grad = Instance.new("UIGradient")
                local kp = {}
                for i = 0, 1, 0.1 do table.insert(kp, ColorSequenceKeypoint.new(i, Color3.fromHSV(i, 1, 1))) end
                grad.Color = ColorSequence.new(kp)
                grad.Parent = bar
            else
                local grad = Instance.new("UIGradient")
                grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(api.Hue, api.Sat, api.Value))
                })
                grad.Parent = bar
                
                local function updateGrad()
                    if name == "S" then
                        grad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromHSV(api.Hue, 0, api.Value)),
                            ColorSequenceKeypoint.new(1, Color3.fromHSV(api.Hue, 1, api.Value))
                        })
                    else
                        grad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
                            ColorSequenceKeypoint.new(1, Color3.fromHSV(api.Hue, api.Sat, 1))
                        })
                    end
                end
                pickerFrame:SetAttribute("Update" .. name, true)
                pickerFrame:GetAttributeChangedSignal("Update" .. name):Connect(updateGrad)
            end
            
            local knobHolder = Instance.new("Frame")
            knobHolder.Size = UDim2.fromOffset(14, 14)
            knobHolder.Position = UDim2.fromScale(initialVal, 0.5)
            knobHolder.AnchorPoint = Vector2.new(0.5, 0.5)
            knobHolder.BackgroundTransparency = 1
            knobHolder.ZIndex = 112
            knobHolder.Parent = bar
            
            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(12, 12)
            knob.Position = UDim2.fromScale(0.5, 0.5)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            knob.ZIndex = 112
            knob.Parent = knobHolder
            Components.AddCorner(knob, UDim.new(1, 0))
            local knobStroke = Instance.new("UIStroke")
            knobStroke.Color = Color3.fromRGB(60, 60, 60)
            knobStroke.Thickness = 1
            knobStroke.Parent = knob
            
            local dragging = false
            local conn1 = sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local pct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    knobHolder.Position = UDim2.fromScale(pct, 0.5)
                    updateFunc(pct)
                end
            end)
            local conn2 = sliderBg.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            local conn3 = Services.UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    knobHolder.Position = UDim2.fromScale(pct, 0.5)
                    updateFunc(pct)
                end
            end)
            
            table.insert(connections, conn1)
            table.insert(connections, conn2)
            table.insert(connections, conn3)
        end
        
        local function updateAll()
            colorDisplay.BackgroundColor3 = Color3.fromHSV(api.Hue, api.Sat, api.Value)
            api:SetValue(api.Hue, api.Sat, api.Value)
            pickerFrame:SetAttribute("UpdateS", not pickerFrame:GetAttribute("UpdateS"))
            pickerFrame:SetAttribute("UpdateV", not pickerFrame:GetAttribute("UpdateV"))
        end
        
        createSlider(85, "H", api.Hue, function(val) api.Hue = val updateAll() end, true)
        createSlider(125, "S", api.Sat, function(val) api.Sat = val updateAll() end, false)
        createSlider(165, "V", api.Value, function(val) api.Value = val updateAll() end, false)
        
        modalOverlay.MouseButton1Click:Connect(function()
            modalOverlay:Destroy()
        end)
    end)
    
    container.MouseEnter:Connect(function()
        VapeV5.Tween:Create(preview, {Size = UDim2.fromOffset(26, 26)}, 0.1)
    end)
    
    container.MouseLeave:Connect(function()
        VapeV5.Tween:Create(preview, {Size = UDim2.fromOffset(24, 24)}, 0.1)
    end)
    
    api.Object = container
    return api
end

-- Keybind
function InputComponents.CreateKeybind(parent, options)
    options = Utils.ValidateOptions(options, {
        Name = "Keybind",
        Default = {},
        Tooltip = nil,
        Darker = false,
        Callback = function() end
    })
    
    local theme = VapeV5.Settings.Theme
    
    local api = {
        Type = "Keybind",
        Bind = type(options.Default) == "table" and options.Default or {options.Default},
        Callback = options.Callback,
        Listening = false,
    }
    
    local container = Instance.new("TextButton")
    container.Name = options.Name .. "Keybind"
    container.Size = UDim2.new(1, 0, 0, 32)
    container.BackgroundColor3 = ColorSystem.Dark(parent.BackgroundColor3, options.Darker and 0.02 or 0)
    container.BorderSizePixel = 0
    container.AutoButtonColor = false
    container.Text = "          " .. options.Name
    container.TextXAlignment = Enum.TextXAlignment.Left
    container.TextColor3 = ColorSystem.Dark(theme.Text, 0.16)
    container.TextSize = 14
    container.FontFace = VapeV5.Settings.Fonts.Regular
    container.Parent = parent
    
    if options.Tooltip then
        Components.AddTooltip(container, options.Tooltip)
    end
    
    local bindButton = Instance.new("TextButton")
    bindButton.Size = UDim2.fromOffset(60, 22)
    bindButton.Position = UDim2.new(1, -70, 0, 5)
    bindButton.BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.05)
    bindButton.BorderSizePixel = 0
    bindButton.AutoButtonColor = false
    bindButton.Text = #api.Bind > 0 and api.Bind[1] or "None"
    bindButton.TextColor3 = ColorSystem.Dark(theme.Text, 0.3)
    bindButton.TextSize = 11
    bindButton.FontFace = VapeV5.Settings.Fonts.Regular
    bindButton.Parent = container
    Components.AddCorner(bindButton, UDim.new(0, 4))
    
    function api:SetBind(keys, silent)
        if type(keys) == "string" then
            keys = {keys}
        end
        self.Bind = keys or {}
        
        local displayText = #self.Bind > 0 and table.concat(self.Bind, "+"):upper() or "None"
        bindButton.Text = displayText
        
        local size = Utils.GetTextSize(displayText, 11, VapeV5.Settings.Fonts.Regular)
        bindButton.Size = UDim2.fromOffset(math.max(size.X + 16, 40), 22)
        bindButton.Position = UDim2.new(1, -bindButton.Size.X.Offset - 10, 0, 5)
        
        if not silent then
            self.Callback(self.Bind)
        end
    end
    
    function api:StartListening()
        self.Listening = true
        bindButton.Text = "..."
        bindButton.TextColor3 = theme.Accent
        VapeV5._bindingTarget = self
    end
    
    function api:StopListening(key)
        self.Listening = false
        bindButton.TextColor3 = ColorSystem.Dark(theme.Text, 0.3)
        VapeV5._bindingTarget = nil
        
        if key then
            if key == Enum.KeyCode.Escape then
                self:SetBind({})
            else
                self:SetBind({key.Name})
            end
        end
    end
    
    function api:Save(data)
        data[options.Name] = {Bind = self.Bind}
    end
    
    function api:Load(data)
        if data and data.Bind then
            self:SetBind(data.Bind, true)
        end
    end
    
    bindButton.MouseButton1Click:Connect(function()
        api:StartListening()
    end)
    
    bindButton.MouseEnter:Connect(function()
        VapeV5.Tween:Create(bindButton, {BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.1)}, 0.1)
    end)
    
    bindButton.MouseLeave:Connect(function()
        VapeV5.Tween:Create(bindButton, {BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.05)}, 0.1)
    end)
    
    api:SetBind(api.Bind, true)
    
    api.Object = container
    return api
end

-- Button
function InputComponents.CreateButton(parent, options)
    options = Utils.ValidateOptions(options, {
        Name = "Button",
        Tooltip = nil,
        Darker = false,
        Callback = function() end
    })
    
    local theme = VapeV5.Settings.Theme
    
    local api = {
        Type = "Button",
        Callback = options.Callback,
    }
    
    local container = Instance.new("TextButton")
    container.Name = options.Name .. "Button"
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundColor3 = ColorSystem.Dark(parent.BackgroundColor3, options.Darker and 0.02 or 0)
    container.BorderSizePixel = 0
    container.AutoButtonColor = false
    container.Text = ""
    container.Parent = parent
    
    if options.Tooltip then
        Components.AddTooltip(container, options.Tooltip)
    end
    
    local button = Instance.new("Frame")
    button.Size = UDim2.new(1, -20, 0, 28)
    button.Position = UDim2.fromOffset(10, 4)
    button.BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.05)
    button.Parent = container
    Components.AddCorner(button, UDim.new(0, 6))
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.Text = options.Name
    text.TextColor3 = ColorSystem.Dark(theme.Text, 0.16)
    text.TextSize = 14
    text.FontFace = VapeV5.Settings.Fonts.Regular
    text.Parent = button
    
    container.MouseEnter:Connect(function()
        VapeV5.Tween:Create(button, {
            BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.1)
        }, 0.1)
    end)
    
    container.MouseLeave:Connect(function()
        VapeV5.Tween:Create(button, {
            BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.05)
        }, 0.1)
    end)
    
    container.MouseButton1Click:Connect(function()
        VapeV5.Tween:Create(button, {
            BackgroundColor3 = theme.Accent
        }, 0.05)
        
        task.delay(0.1, function()
            VapeV5.Tween:Create(button, {
                BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.05)
            }, 0.1)
        end)
        
        api.Callback()
    end)
    
    api.Object = container
    return api
end

VapeV5.Inputs = InputComponents

-- ═══════════════════════════════════════════════════════════════════
-- 📁 SISTEMA DE MÓDULOS
-- ═══════════════════════════════════════════════════════════════════

local function CreateModule(parent, options)
    options = Utils.ValidateOptions(options, {
        Name = "Module",
        Tooltip = nil,
        Bind = {},
        Icon = nil,
        Callback = function() end
    })
    
    local theme = VapeV5.Settings.Theme
    
    local api = {
        Type = "Module",
        Name = options.Name,
        Enabled = false,
        Options = {},
        Bind = type(options.Bind) == "table" and options.Bind or {options.Bind},
        Callback = options.Callback,
        _connections = {},
    }
    
    local container = Instance.new("TextButton")
    container.Name = options.Name .. "Module"
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = theme.Primary
    container.BorderSizePixel = 0
    container.AutoButtonColor = false
    container.Text = "            " .. options.Name
    container.TextXAlignment = Enum.TextXAlignment.Left
    container.TextColor3 = ColorSystem.Dark(theme.Text, 0.16)
    container.TextSize = 14
    container.FontFace = VapeV5.Settings.Fonts.Regular
    container.Parent = parent
    
    if options.Tooltip then
        Components.AddTooltip(container, options.Tooltip)
    end
    
    local textOffset = 12
    local moduleIcon
    if options.Icon and options.Icon ~= "" then
        if AssetSystem:IsEmoji(options.Icon) then
            moduleIcon = Instance.new("TextLabel")
            moduleIcon.Size = UDim2.fromOffset(20, 20)
            moduleIcon.Position = UDim2.fromOffset(10, 10)
            moduleIcon.BackgroundTransparency = 1
            moduleIcon.Text = options.Icon
            moduleIcon.TextSize = 14
            moduleIcon.Parent = container
            textOffset = 36
        else
            local imageSource = AssetSystem:LoadFromURL(options.Icon)
            if imageSource and imageSource ~= "" then
                moduleIcon = Instance.new("ImageLabel")
                moduleIcon.Size = UDim2.fromOffset(16, 16)
                moduleIcon.Position = UDim2.fromOffset(12, 12)
                moduleIcon.BackgroundTransparency = 1
                moduleIcon.Image = imageSource
                moduleIcon.ImageColor3 = ColorSystem.Dark(theme.Text, 0.16)
                moduleIcon.Parent = container
                textOffset = 36
            end
        end
    end
    container.Text = string.rep(" ", math.round(textOffset/3)) .. options.Name
    
    local dotsButton = Instance.new("TextButton")
    dotsButton.Name = "Dots"
    dotsButton.Size = UDim2.fromOffset(25, 40)
    dotsButton.Position = UDim2.new(1, -25, 0, 0)
    dotsButton.BackgroundTransparency = 1
    dotsButton.Text = ""
    dotsButton.Parent = container
    
    local dots = Instance.new("ImageLabel")
    dots.Size = UDim2.fromOffset(3, 16)
    dots.Position = UDim2.fromOffset(11, 12)
    dots.BackgroundTransparency = 1
    dots.Image = AssetSystem:Get("Dots")
    dots.ImageColor3 = ColorSystem.Light(theme.Primary, 0.37)
    dots.Parent = dotsButton
    
    local bindLabel = Instance.new("TextButton")
    bindLabel.Name = "Bind"
    bindLabel.Size = UDim2.fromOffset(40, 22)
    bindLabel.Position = UDim2.new(1, -70, 0, 9)
    bindLabel.BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.05)
    bindLabel.BorderSizePixel = 0
    bindLabel.AutoButtonColor = false
    bindLabel.Visible = false
    bindLabel.Text = ""
    bindLabel.TextColor3 = ColorSystem.Dark(theme.Text, 0.4)
    bindLabel.TextSize = 11
    bindLabel.FontFace = VapeV5.Settings.Fonts.Regular
    bindLabel.Parent = container
    Components.AddCorner(bindLabel, UDim.new(0, 4))
    
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = options.Name .. "Options"
    optionsContainer.Size = UDim2.new(1, 0, 0, 0)
    optionsContainer.BackgroundColor3 = ColorSystem.Dark(theme.Primary, 0.02)
    optionsContainer.BorderSizePixel = 0
    optionsContainer.ClipsDescendants = true
    optionsContainer.Visible = false
    optionsContainer.Parent = parent
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = optionsContainer
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 1, -1)
    divider.BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.1)
    divider.BorderSizePixel = 0
    divider.Visible = false
    divider.Parent = container
    
    local expanded = false
    
    function api:Toggle(silent)
        self.Enabled = not self.Enabled
        
        if self.Enabled then
            VapeV5.Tween:Create(container, {
                BackgroundColor3 = theme.Accent
            }, 0.15)
            container.TextColor3 = ColorSystem.GetTextColor(theme.Accent:ToHSV())
            dots.ImageColor3 = container.TextColor3
            divider.Visible = true
        else
            VapeV5.Tween:Create(container, {
                BackgroundColor3 = theme.Primary
            }, 0.15)
            container.TextColor3 = ColorSystem.Dark(theme.Text, 0.16)
            dots.ImageColor3 = ColorSystem.Light(theme.Primary, 0.37)
            divider.Visible = false
            
            for _, conn in pairs(self._connections) do
                if conn and conn.Disconnect then
                    pcall(function() conn:Disconnect() end)
                end
            end
            table.clear(self._connections)
        end
        
        if not silent then
            self.Callback(self.Enabled)
        end
    end
    
    function api:SetBind(keys)
        if type(keys) == "string" then
            keys = {keys}
        end
        self.Bind = keys or {}
        
        if #self.Bind > 0 then
            bindLabel.Visible = true
            bindLabel.Text = table.concat(self.Bind, "+"):upper()
            local size = Utils.GetTextSize(bindLabel.Text, 11, VapeV5.Settings.Fonts.Regular)
            bindLabel.Size = UDim2.fromOffset(math.max(size.X + 12, 30), 22)
            bindLabel.Position = UDim2.new(1, -bindLabel.Size.X.Offset - 30, 0, 9)
        else
            bindLabel.Visible = false
        end
    end
    
    function api:ExpandOptions()
        expanded = not expanded
        optionsContainer.Visible = expanded
        
        if expanded then
            local scale = VapeV5._scale and VapeV5._scale.Scale or 1
            local height = optionsLayout.AbsoluteContentSize.Y / scale
            
            VapeV5.Tween:Create(optionsContainer, {
                Size = UDim2.new(1, 0, 0, height)
            }, 0.2)
        else
            VapeV5.Tween:Create(optionsContainer, {
                Size = UDim2.new(1, 0, 0, 0)
            }, 0.2)
        end
    end
    
    function api:Clean(connection)
        if connection then
            table.insert(self._connections, connection)
        end
    end
    
    function api:CreateToggle(opts)
        local toggle = InputComponents.CreateToggle(optionsContainer, opts)
        self.Options[opts.Name] = toggle
        return toggle
    end
    
    function api:CreateSlider(opts)
        local slider = InputComponents.CreateSlider(optionsContainer, opts)
        self.Options[opts.Name] = slider
        return slider
    end
    
    function api:CreateDropdown(opts)
        local dropdown = InputComponents.CreateDropdown(optionsContainer, opts)
        self.Options[opts.Name] = dropdown
        return dropdown
    end
    
    function api:CreateTextBox(opts)
        local textbox = InputComponents.CreateTextBox(optionsContainer, opts)
        self.Options[opts.Name] = textbox
        return textbox
    end
    
    function api:CreateColorPicker(opts)
        local picker = InputComponents.CreateColorPicker(optionsContainer, opts)
        self.Options[opts.Name] = picker
        return picker
    end
    
    function api:CreateKeybind(opts)
        local keybind = InputComponents.CreateKeybind(optionsContainer, opts)
        self.Options[opts.Name] = keybind
        return keybind
    end
    
    function api:CreateButton(opts)
        local button = InputComponents.CreateButton(optionsContainer, opts)
        return button
    end
    
    function api:CreateDivider(text)
        local dividerFrame = Instance.new("Frame")
        dividerFrame.Size = UDim2.new(1, 0, 0, text and 25 or 1)
        dividerFrame.BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.03)
        dividerFrame.BackgroundTransparency = text and 1 or 0
        dividerFrame.BorderSizePixel = 0
        dividerFrame.Parent = optionsContainer
        
        if text then
            local label = Instance.new("TextLabel")
            label.Size = UDim2.fromScale(1, 1)
            label.Position = UDim2.fromOffset(10, 0)
            label.BackgroundTransparency = 1
            label.Text = text:upper()
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextColor3 = ColorSystem.Dark(theme.Text, 0.5)
            label.TextSize = 10
            label.FontFace = VapeV5.Settings.Fonts.Bold
            label.Parent = dividerFrame
        end
        
        return dividerFrame
    end
    
    local hovered = false
    
    container.MouseEnter:Connect(function()
        hovered = true
        if not api.Enabled then
            container.TextColor3 = theme.Text
            VapeV5.Tween:Create(container, {
                BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.03)
            }, 0.1)
        end
        bindLabel.Visible = #api.Bind > 0 or true
    end)
    
    container.MouseLeave:Connect(function()
        hovered = false
        if not api.Enabled and not expanded then
            container.TextColor3 = ColorSystem.Dark(theme.Text, 0.16)
            VapeV5.Tween:Create(container, {
                BackgroundColor3 = theme.Primary
            }, 0.1)
        end
        bindLabel.Visible = #api.Bind > 0
    end)
    
    container.MouseButton1Click:Connect(function()
        api:Toggle()
    end)
    
    container.MouseButton2Click:Connect(function()
        api:ExpandOptions()
    end)
    
    dotsButton.MouseButton1Click:Connect(function()
        api:ExpandOptions()
    end)
    
    dotsButton.MouseEnter:Connect(function()
        if not api.Enabled then
            dots.ImageColor3 = theme.Text
        end
    end)
    
    dotsButton.MouseLeave:Connect(function()
        if not api.Enabled then
            dots.ImageColor3 = ColorSystem.Light(theme.Primary, 0.37)
        end
    end)
    
    bindLabel.MouseButton1Click:Connect(function()
        VapeV5._bindingTarget = {
            SetBind = function(_, keys)
                api:SetBind(keys)
            end,
            StopListening = function(_, key)
                if key then
                    api:SetBind({key.Name})
                end
                VapeV5._bindingTarget = nil
            end,
            Bind = api.Bind
        }
    end)
    
    optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if expanded then
            local scale = VapeV5._scale and VapeV5._scale.Scale or 1
            optionsContainer.Size = UDim2.new(1, 0, 0, optionsLayout.AbsoluteContentSize.Y / scale)
        end
    end)
    
    if #api.Bind > 0 then
        api:SetBind(api.Bind)
    end
    
    api.Object = container
    api.OptionsContainer = optionsContainer
    
    return api
end

-- ═══════════════════════════════════════════════════════════════════
-- 📂 SISTEMA DE CATEGORIAS/TABS
-- ═══════════════════════════════════════════════════════════════════

local function CreateCategory(parent, options)
    options = Utils.ValidateOptions(options, {
        Name = "Category",
        Icon = "",
        IconSize = nil,
        Position = UDim2.fromOffset(240, 60)
    })
    
    local theme = VapeV5.Settings.Theme
    
    local api = {
        Type = "Category",
        Name = options.Name,
        Expanded = false,
        Modules = {},
    }
    
    local window = Instance.new("TextButton")
    window.Name = options.Name .. "Category"
    window.Size = UDim2.fromOffset(220, 42)
    window.Position = options.Position
    window.BackgroundColor3 = theme.Primary
    window.BorderSizePixel = 0
    window.AutoButtonColor = false
    window.Visible = false
    window.Text = ""
    window.Parent = parent
    
    Components.AddShadow(window, {Expand = 12, Transparency = 0.7})
    Components.AddCorner(window)
    Components.MakeDraggable(window)
    
    local iconElement
    local iconOffset = 12
    
    if options.Icon and options.Icon ~= "" then
        if AssetSystem:IsEmoji(options.Icon) then
            iconElement = Instance.new("TextLabel")
            iconElement.Size = UDim2.fromOffset(20, 20)
            iconElement.Position = UDim2.fromOffset(10, 11)
            iconElement.BackgroundTransparency = 1
            iconElement.Text = options.Icon
            iconElement.TextSize = 16
            iconElement.Parent = window
            iconOffset = 34
        else
            local imageSource = AssetSystem:LoadFromURL(options.Icon)
            if imageSource and imageSource ~= "" then
                iconElement = Instance.new("ImageLabel")
                iconElement.Size = options.IconSize or UDim2.fromOffset(16, 16)
                iconElement.Position = UDim2.fromOffset(12, 13)
                iconElement.BackgroundTransparency = 1
                iconElement.Image = imageSource
                iconElement.ImageColor3 = theme.Text
                iconElement.Parent = window
                iconOffset = 36
            end
        end
    end
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 0, 42)
    title.Position = UDim2.fromOffset(iconOffset, 0)
    title.BackgroundTransparency = 1
    title.Text = options.Name
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = theme.Text
    title.TextSize = 14
    title.FontFace = VapeV5.Settings.Fonts.Regular
    title.Parent = window
    
    local arrowButton = Instance.new("TextButton")
    arrowButton.Size = UDim2.fromOffset(40, 42)
    arrowButton.Position = UDim2.new(1, -40, 0, 0)
    arrowButton.BackgroundTransparency = 1
    arrowButton.Text = ""
    arrowButton.Parent = window
    
    local arrow = Instance.new("ImageLabel")
    arrow.Size = UDim2.fromOffset(10, 6)
    arrow.Position = UDim2.fromOffset(15, 18)
    arrow.BackgroundTransparency = 1
    arrow.Image = AssetSystem:Get("Expand")
    arrow.ImageColor3 = theme.TextDark
    arrow.Rotation = 180
    arrow.Parent = arrowButton
    
    local modulesContainer = Instance.new("ScrollingFrame")
    modulesContainer.Name = "Modules"
    modulesContainer.Size = UDim2.new(1, 0, 1, -42)
    modulesContainer.Position = UDim2.fromOffset(0, 38)
    modulesContainer.BackgroundTransparency = 1
    modulesContainer.BorderSizePixel = 0
    modulesContainer.ScrollBarThickness = 3
    modulesContainer.ScrollBarImageColor3 = theme.Accent
    modulesContainer.ScrollBarImageTransparency = 0.5
    modulesContainer.CanvasSize = UDim2.new()
    modulesContainer.Visible = false
    modulesContainer.Parent = window
    
    local modulesLayout = Instance.new("UIListLayout")
    modulesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    modulesLayout.Parent = modulesContainer
    
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.fromOffset(0, 38)
    divider.BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.05)
    divider.BorderSizePixel = 0
    divider.Visible = false
    divider.Parent = window
    
    function api:Expand()
        self.Expanded = not self.Expanded
        
        modulesContainer.Visible = self.Expanded
        divider.Visible = self.Expanded
        
        VapeV5.Tween:Create(arrow, {
            Rotation = self.Expanded and 0 or 180
        }, 0.2)
        
        if self.Expanded then
            local scale = VapeV5._scale and VapeV5._scale.Scale or 1
            local height = math.min(42 + modulesLayout.AbsoluteContentSize.Y / scale, 500)
            
            VapeV5.Tween:Create(window, {
                Size = UDim2.fromOffset(220, height)
            }, 0.25, Enum.EasingStyle.Back)
        else
            VapeV5.Tween:Create(window, {
                Size = UDim2.fromOffset(220, 42)
            }, 0.2)
        end
    end
    
    function api:CreateModule(opts)
        if not opts or not opts.Name then
            Debug.Error("CreateModule requires a Name")
            opts = opts or {}
            opts.Name = opts.Name or "UnnamedModule"
        end
        
        local module = CreateModule(modulesContainer, opts)
        self.Modules[opts.Name] = module
        VapeV5._modules[opts.Name] = module
        
        local sorted = {}
        for name, mod in pairs(self.Modules) do
            table.insert(sorted, {name = name, mod = mod})
        end
        table.sort(sorted, function(a, b)
            return a.name < b.name
        end)
        
        for i, data in ipairs(sorted) do
            data.mod.Object.LayoutOrder = i * 2
            data.mod.OptionsContainer.LayoutOrder = i * 2 + 1
        end
        
        return module
    end
    
    arrowButton.MouseButton1Click:Connect(function()
        api:Expand()
    end)
    
    arrowButton.MouseEnter:Connect(function()
        arrow.ImageColor3 = theme.Text
    end)
    
    arrowButton.MouseLeave:Connect(function()
        arrow.ImageColor3 = theme.TextDark
    end)
    
    window.MouseButton2Click:Connect(function()
        api:Expand()
    end)
    
    modulesLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local scale = VapeV5._scale and VapeV5._scale.Scale or 1
        modulesContainer.CanvasSize = UDim2.fromOffset(0, modulesLayout.AbsoluteContentSize.Y / scale)
        
        if api.Expanded then
            local height = math.min(42 + modulesLayout.AbsoluteContentSize.Y / scale, 500)
            window.Size = UDim2.fromOffset(220, height)
        end
    end)
    
    api.Object = window
    api.Container = modulesContainer
    
    return api
end

-- ═══════════════════════════════════════════════════════════════════
-- 🪟 SISTEMA DE JANELA PRINCIPAL
-- ═══════════════════════════════════════════════════════════════════

function VapeV5:CreateWindow(options)
    options = Utils.ValidateOptions(options, {
        Title = "Vape V5",
        Subtitle = nil,
        Logo = nil,
        Theme = "Dark",
        AccentColor = nil,
        Keybind = "RightShift",
        BlurEnabled = true,
        ShowWelcome = true
    })
    
    local theme = self.Settings.Theme
    
    if type(options.Theme) == "string" and self.Themes and self.Themes[options.Theme] then
        for k, v in pairs(self.Themes[options.Theme]) do
            theme[k] = v
        end
    elseif type(options.Theme) == "table" then
        for k, v in pairs(options.Theme) do
            theme[k] = v
        end
    end
    
    if options.AccentColor then
        theme.Accent = options.AccentColor
    end
    
    if options.Keybind then
        self.Settings.Keybind = type(options.Keybind) == "table" and options.Keybind or {options.Keybind}
    end
    
    self.Settings.General.Blur = options.BlurEnabled
    
    local windowAPI = {
        Categories = {},
        Options = {},
        Visible = true,
        Settings = VapeV5.Settings,
    }
    
    AssetSystem:Init()
    
    local gui = Instance.new("ScreenGui")
    gui.Name = Utils.RandomString()
    gui.DisplayOrder = 999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    
    local success = pcall(function()
        gui.Parent = Services.CoreGui
    end)
    
    if not success then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    self._gui = gui
    
    local scaledContainer = Instance.new("Frame")
    scaledContainer.Name = "ScaledContainer"
    scaledContainer.Size = UDim2.fromScale(1, 1)
    scaledContainer.BackgroundTransparency = 1
    scaledContainer.Parent = gui
    
    local scale = Instance.new("UIScale")
    scale.Scale = self.Settings.General.AutoScale and math.max(gui.AbsoluteSize.X / 1920, 0.6) or self.Settings.General.Scale
    scale.Parent = scaledContainer
    self._scale = scale
    
    gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if self.Settings.General.AutoScale then
            scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
        end
        scaledContainer.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)
    end)
    
    scaledContainer.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)
    
    local clickGui = Instance.new("Frame")
    clickGui.Name = "ClickGui"
    clickGui.Size = UDim2.fromScale(1, 1)
    clickGui.BackgroundTransparency = 1
    clickGui.Visible = false
    clickGui.Parent = scaledContainer
    
    local modal = Instance.new("TextButton")
    modal.Size = UDim2.fromScale(1, 1)
    modal.BackgroundTransparency = 1
    modal.Text = ""
    modal.Modal = true
    modal.Parent = clickGui
    
    self._clickGui = clickGui
    
    NotificationSystem:Init(scaledContainer)
    BlurSystem:Init(scaledContainer)
    
    local tooltip = Instance.new("TextLabel")
    tooltip.Name = "Tooltip"
    tooltip.Size = UDim2.fromOffset(100, 30)
    tooltip.Position = UDim2.fromScale(-1, -1)
    tooltip.ZIndex = 100
    tooltip.BackgroundColor3 = ColorSystem.Dark(theme.Primary, 0.05)
    tooltip.Visible = false
    tooltip.Text = ""
    tooltip.TextColor3 = ColorSystem.Dark(theme.Text, 0.16)
    tooltip.TextSize = 12
    tooltip.FontFace = self.Settings.Fonts.Regular
    tooltip.Parent = scaledContainer
    Components.AddCorner(tooltip)
    Components.AddStroke(tooltip)
    self._tooltip = tooltip
    
    -- ═══════════════════════════════════════════════════════════════
    -- 📋 JANELA PRINCIPAL DO MENU
    -- ═══════════════════════════════════════════════════════════════
    
    local mainWindow = Instance.new("TextButton")
    mainWindow.Name = "MainWindow"
    mainWindow.Size = UDim2.fromOffset(220, 100)
    mainWindow.Position = UDim2.fromOffset(10, 60)
    mainWindow.BackgroundColor3 = ColorSystem.Dark(theme.Primary, 0.02)
    mainWindow.BorderSizePixel = 0
    mainWindow.AutoButtonColor = false
    mainWindow.Text = ""
    mainWindow.Parent = clickGui
    
    Components.AddShadow(mainWindow, {Expand = 12, Transparency = 0.7})
    Components.AddCorner(mainWindow)
    Components.MakeDraggable(mainWindow)
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundTransparency = 1
    header.Parent = mainWindow
    
    local logoElement
    local logoWidth = 0
    
    if options.Logo then
        local logoSource = AssetSystem:LoadFromURL(options.Logo)
        if logoSource and logoSource ~= "" then
            logoElement = Instance.new("ImageLabel")
            logoElement.Size = UDim2.fromOffset(80, 24)
            logoElement.Position = UDim2.fromOffset(12, 6)
            logoElement.BackgroundTransparency = 1
            logoElement.Image = logoSource
            logoElement.ScaleType = Enum.ScaleType.Fit
            logoElement.Parent = header
            
            Components.AddAspectRatio(logoElement, 80/24)
            logoWidth = 92
        end
    end
    
    if not logoElement then
        logoElement = Instance.new("TextLabel")
        logoElement.Size = UDim2.fromOffset(100, 24)
        logoElement.Position = UDim2.fromOffset(12, 6)
        logoElement.BackgroundTransparency = 1
        logoElement.Text = options.Title
        logoElement.TextXAlignment = Enum.TextXAlignment.Left
        logoElement.TextColor3 = theme.Text
        logoElement.TextSize = 16
        logoElement.FontFace = self.Settings.Fonts.Bold
        logoElement.Parent = header
        logoWidth = Utils.GetTextSize(options.Title, 16, self.Settings.Fonts.Bold).X + 20
    end
    
    local subSize = 0
    if options.Subtitle then
        subSize = Utils.GetTextSize(options.Subtitle, 12, self.Settings.Fonts.SemiBold).X
        local subtitle = Instance.new("TextLabel")
        subtitle.Size = UDim2.fromOffset(subSize, 16)
        subtitle.Position = UDim2.fromOffset(logoWidth, 10)
        subtitle.BackgroundTransparency = 1
        subtitle.Text = options.Subtitle
        subtitle.TextColor3 = theme.Accent
        subtitle.TextSize = 12
        subtitle.FontFace = self.Settings.Fonts.SemiBold
        subtitle.Parent = header
    end
    
    local totalHeaderWidth = logoWidth + subSize + 45
    local mainWindowWidth = math.max(220, totalHeaderWidth)
    mainWindow.Size = UDim2.fromOffset(mainWindowWidth, 100)
    
    local settingsButton = Instance.new("TextButton")
    settingsButton.Size = UDim2.fromOffset(30, 30)
    settingsButton.Position = UDim2.new(1, -35, 0, 3)
    settingsButton.BackgroundTransparency = 1
    settingsButton.Text = ""
    settingsButton.Parent = header
    
    local settingsIcon = Instance.new("ImageLabel")
    settingsIcon.Size = UDim2.fromOffset(16, 16)
    settingsIcon.Position = UDim2.fromOffset(7, 7)
    settingsIcon.BackgroundTransparency = 1
    settingsIcon.Image = AssetSystem:Get("Settings")
    settingsIcon.ImageColor3 = ColorSystem.Light(theme.Primary, 0.37)
    settingsIcon.Parent = settingsButton
    
    settingsButton.MouseEnter:Connect(function()
        VapeV5.Tween:Create(settingsIcon, {ImageColor3 = theme.Text}, 0.1)
    end)
    
    settingsButton.MouseLeave:Connect(function()
        VapeV5.Tween:Create(settingsIcon, {ImageColor3 = ColorSystem.Light(theme.Primary, 0.37)}, 0.1)
    end)
    
    settingsButton.MouseButton1Click:Connect(function()
        local modalOverlay = Instance.new("TextButton")
        modalOverlay.Size = UDim2.fromScale(1, 1)
        modalOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        modalOverlay.BackgroundTransparency = 0.5
        modalOverlay.Text = ""
        modalOverlay.AutoButtonColor = false
        modalOverlay.ZIndex = 100
        modalOverlay.Parent = clickGui
        
        local bindFrame = Instance.new("Frame")
        bindFrame.Size = UDim2.fromOffset(240, 110)
        bindFrame.Position = UDim2.fromScale(0.5, 0.5)
        bindFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        bindFrame.BackgroundColor3 = theme.Primary
        bindFrame.ZIndex = 101
        bindFrame.Parent = modalOverlay
        Components.AddCorner(bindFrame)
        Components.AddShadow(bindFrame)
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0, 30)
        titleLabel.Position = UDim2.fromOffset(0, 5)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = "Settings"
        titleLabel.TextColor3 = theme.Text
        titleLabel.TextSize = 16
        titleLabel.FontFace = VapeV5.Settings.Fonts.Bold
        titleLabel.ZIndex = 101
        titleLabel.Parent = bindFrame
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -20, 0, 20)
        lbl.Position = UDim2.fromOffset(10, 35)
        lbl.BackgroundTransparency = 1
        lbl.Text = "Main UI Keybind:"
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextColor3 = theme.TextDark
        lbl.TextSize = 13
        lbl.FontFace = VapeV5.Settings.Fonts.Regular
        lbl.ZIndex = 101
        lbl.Parent = bindFrame
        
        local bindBtn = Instance.new("TextButton")
        bindBtn.Size = UDim2.new(1, -20, 0, 30)
        bindBtn.Position = UDim2.fromOffset(10, 60)
        bindBtn.BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.05)
        bindBtn.Text = #VapeV5.Settings.Keybind > 0 and table.concat(VapeV5.Settings.Keybind, "+") or "None"
        bindBtn.TextColor3 = theme.Text
        bindBtn.TextSize = 14
        bindBtn.FontFace = VapeV5.Settings.Fonts.SemiBold
        bindBtn.ZIndex = 101
        bindBtn.Parent = bindFrame
        Components.AddCorner(bindBtn, UDim.new(0, 4))
        
        bindBtn.MouseButton1Click:Connect(function()
            bindBtn.Text = "..."
            bindBtn.TextColor3 = theme.Accent
            VapeV5._bindingTarget = {
                StopListening = function(_, key)
                    if key then
                        if key == Enum.KeyCode.Escape then
                            VapeV5.Settings.Keybind = {}
                        else
                            VapeV5.Settings.Keybind = {key.Name}
                        end
                    end
                    bindBtn.Text = #VapeV5.Settings.Keybind > 0 and table.concat(VapeV5.Settings.Keybind, "+") or "None"
                    bindBtn.TextColor3 = theme.Text
                    VapeV5._bindingTarget = nil
                end
            }
        end)
        
        modalOverlay.MouseButton1Click:Connect(function()
            if not VapeV5._bindingTarget then
                modalOverlay:Destroy()
            end
        end)
    end)
    
    local tabsContainer = Instance.new("ScrollingFrame")
    tabsContainer.Name = "Tabs"
    tabsContainer.Size = UDim2.new(1, 0, 1, -42)
    tabsContainer.Position = UDim2.fromOffset(0, 38)
    tabsContainer.BackgroundTransparency = 1
    tabsContainer.BorderSizePixel = 0
    tabsContainer.ScrollBarThickness = 2
    tabsContainer.ScrollBarImageColor3 = theme.Accent
    tabsContainer.ScrollBarImageTransparency = 0.5
    tabsContainer.CanvasSize = UDim2.new()
    tabsContainer.Parent = mainWindow
    
    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Parent = tabsContainer
    
    local topDivider = Instance.new("Frame")
    topDivider.Size = UDim2.new(1, 0, 0, 1)
    topDivider.Position = UDim2.fromOffset(0, 36)
    topDivider.BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.05)
    topDivider.BorderSizePixel = 0
    topDivider.Parent = mainWindow
    
    -- ═══════════════════════════════════════════════════════════════
    -- 🔍 BARRA DE PESQUISA
    -- ═══════════════════════════════════════════════════════════════
    
    local mainWindowWidth = mainWindow.Size.X.Offset
    local searchBar = Instance.new("Frame")
    searchBar.Name = "SearchBar"
    searchBar.Size = UDim2.fromOffset(mainWindowWidth, 38)
    searchBar.Position = UDim2.new(0.5, -mainWindowWidth / 2, 0, 12)
    searchBar.BackgroundColor3 = ColorSystem.Dark(theme.Primary, 0.02)
    searchBar.Parent = clickGui
    
    Components.AddShadow(searchBar, {Expand = 10, Transparency = 0.75})
    Components.AddCorner(searchBar)
    
    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Size = UDim2.fromOffset(14, 14)
    searchIcon.Position = UDim2.new(1, -24, 0, 12)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = AssetSystem:Get("Search")
    searchIcon.ImageColor3 = ColorSystem.Light(theme.Primary, 0.37)
    searchIcon.Parent = searchBar
    
    local searchInput = Instance.new("TextBox")
    searchInput.Size = UDim2.new(1, -50, 1, 0)
    searchInput.Position = UDim2.fromOffset(12, 0)
    searchInput.BackgroundTransparency = 1
    searchInput.Text = ""
    searchInput.PlaceholderText = "Search modules..."
    searchInput.TextXAlignment = Enum.TextXAlignment.Left
    searchInput.TextColor3 = theme.Text
    searchInput.PlaceholderColor3 = theme.TextDark
    searchInput.TextSize = 13
    searchInput.FontFace = self.Settings.Fonts.Regular
    searchInput.ClearTextOnFocus = false
    searchInput.Parent = searchBar
    
    searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local searchText = searchInput.Text:lower()
        
        for name, module in pairs(self._modules) do
            if searchText == "" then
                module.Object.Visible = true
                module.OptionsContainer.Visible = false
            else
                local matches = name:lower():find(searchText, 1, true) ~= nil
                module.Object.Visible = matches
                module.OptionsContainer.Visible = false
            end
        end
    end)
    
    -- ═══════════════════════════════════════════════════════════════
    -- 📁 MÉTODOS DA JANELA
    -- ═══════════════════════════════════════════════════════════════
    
    local categoryPositionX = 240
    local categoryPositionY = 60
    
    function windowAPI:CreateCategory(catOptions)
        catOptions = catOptions or {}
        
        local category = CreateCategory(clickGui, {
            Name = catOptions.Name or "Category",
            Icon = catOptions.Icon or "",
            IconSize = catOptions.IconSize,
            Position = UDim2.fromOffset(categoryPositionX, categoryPositionY),
        })
        
        self.Categories[catOptions.Name] = category
        
        categoryPositionX = categoryPositionX + 230
        if categoryPositionX > 700 then
            categoryPositionX = 240
            categoryPositionY = categoryPositionY + 50
        end
        
        local tabButton = Instance.new("TextButton")
        tabButton.Name = catOptions.Name .. "Tab"
        tabButton.Size = UDim2.new(1, 0, 0, 40)
        tabButton.BackgroundColor3 = theme.Primary
        tabButton.BorderSizePixel = 0
        tabButton.AutoButtonColor = false
        tabButton.Text = ""
        tabButton.Parent = tabsContainer
        
        local tabIconOffset = 12
        
        if catOptions.Icon and catOptions.Icon ~= "" then
            if AssetSystem:IsEmoji(catOptions.Icon) then
                local tabIconText = Instance.new("TextLabel")
                tabIconText.Size = UDim2.fromOffset(20, 20)
                tabIconText.Position = UDim2.fromOffset(10, 10)
                tabIconText.BackgroundTransparency = 1
                tabIconText.Text = catOptions.Icon
                tabIconText.TextSize = 16
                tabIconText.Parent = tabButton
                tabIconOffset = 34
            else
                local imageSource = AssetSystem:LoadFromURL(catOptions.Icon)
                if imageSource and imageSource ~= "" then
                    local tabIconImage = Instance.new("ImageLabel")
                    tabIconImage.Size = catOptions.IconSize or UDim2.fromOffset(16, 16)
                    tabIconImage.Position = UDim2.fromOffset(12, 12)
                    tabIconImage.BackgroundTransparency = 1
                    tabIconImage.Image = imageSource
                    tabIconImage.ImageColor3 = ColorSystem.Dark(theme.Text, 0.16)
                    tabIconImage.Parent = tabButton
                    tabIconOffset = 36
                    
                    category._tabIcon = tabIconImage
                end
            end
        end
        
        local tabText = Instance.new("TextLabel")
        tabText.Size = UDim2.new(1, -tabIconOffset - 30, 1, 0)
        tabText.Position = UDim2.fromOffset(tabIconOffset, 0)
        tabText.BackgroundTransparency = 1
        tabText.Text = catOptions.Name
        tabText.TextXAlignment = Enum.TextXAlignment.Left
        tabText.TextColor3 = ColorSystem.Dark(theme.Text, 0.16)
        tabText.TextSize = 14
        tabText.FontFace = VapeV5.Settings.Fonts.Regular
        tabText.Parent = tabButton
        
        local tabArrow = Instance.new("ImageLabel")
        tabArrow.Size = UDim2.fromOffset(6, 10)
        tabArrow.Position = UDim2.new(1, -20, 0, 15)
        tabArrow.BackgroundTransparency = 1
        tabArrow.Image = AssetSystem:Get("Arrow")
        tabArrow.ImageColor3 = ColorSystem.Light(theme.Primary, 0.37)
        tabArrow.Parent = tabButton
        
        local tabEnabled = false
        
        local function toggleTab()
            tabEnabled = not tabEnabled
            category.Object.Visible = tabEnabled
            
            VapeV5.Tween:Create(tabArrow, {
                Position = UDim2.new(1, tabEnabled and -14 or -20, 0, 15)
            }, 0.15)
            
            if tabEnabled then
                tabText.TextColor3 = theme.Accent
                if category._tabIcon then
                    category._tabIcon.ImageColor3 = theme.Accent
                end
                VapeV5.Tween:Create(tabButton, {
                    BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.03)
                }, 0.1)
            else
                tabText.TextColor3 = ColorSystem.Dark(theme.Text, 0.16)
                if category._tabIcon then
                    category._tabIcon.ImageColor3 = ColorSystem.Dark(theme.Text, 0.16)
                end
                VapeV5.Tween:Create(tabButton, {
                    BackgroundColor3 = theme.Primary
                }, 0.1)
            end
        end
        
        tabButton.MouseEnter:Connect(function()
            if not tabEnabled then
                tabText.TextColor3 = theme.Text
                if category._tabIcon then
                    category._tabIcon.ImageColor3 = theme.Text
                end
                VapeV5.Tween:Create(tabButton, {
                    BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.03)
                }, 0.1)
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if not tabEnabled then
                tabText.TextColor3 = ColorSystem.Dark(theme.Text, 0.16)
                if category._tabIcon then
                    category._tabIcon.ImageColor3 = ColorSystem.Dark(theme.Text, 0.16)
                end
                VapeV5.Tween:Create(tabButton, {
                    BackgroundColor3 = theme.Primary
                }, 0.1)
            end
        end)
        
        tabButton.MouseButton1Click:Connect(toggleTab)
        
        category.Toggle = toggleTab
        category.TabButton = tabButton
        
        return category
    end
    
    function windowAPI:CreateTab(tabOptions)
        return self:CreateCategory(tabOptions)
    end
    
    function windowAPI:CreateDivider(text)
        local dividerFrame = Instance.new("Frame")
        dividerFrame.Size = UDim2.new(1, 0, 0, text and 28 or 1)
        dividerFrame.BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.03)
        dividerFrame.BackgroundTransparency = text and 1 or 0
        dividerFrame.BorderSizePixel = 0
        dividerFrame.Parent = tabsContainer
        
        if text then
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 1, 0)
            label.Position = UDim2.fromOffset(10, 0)
            label.BackgroundTransparency = 1
            label.Text = text:upper()
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextColor3 = ColorSystem.Dark(theme.Text, 0.5)
            label.TextSize = 10
            label.FontFace = VapeV5.Settings.Fonts.Bold
            label.Parent = dividerFrame
            
            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, 0, 0, 1)
            line.Position = UDim2.new(0, 0, 1, -1)
            line.BackgroundColor3 = ColorSystem.Light(theme.Primary, 0.05)
            line.BorderSizePixel = 0
            line.Parent = dividerFrame
        end
        
        return dividerFrame
    end
    
    function windowAPI:Toggle()
        self.Visible = not self.Visible
        clickGui.Visible = self.Visible
        
        if self.Visible then
            BlurSystem:Enable()
        else
            BlurSystem:Disable()
            VapeV5._tooltip.Visible = false
        end
    end
    
    function windowAPI:Show()
        self.Visible = true
        clickGui.Visible = true
        BlurSystem:Enable()
    end
    
    function windowAPI:Hide()
        self.Visible = false
        clickGui.Visible = false
        BlurSystem:Disable()
        VapeV5._tooltip.Visible = false
    end
    
    function windowAPI:Notify(title, message, duration, notifType)
        VapeV5.Notify(title, message, duration, notifType)
    end
    
    -- ═══════════════════════════════════════════════════════════════
    -- 💾 SAVE / LOAD
    -- ═══════════════════════════════════════════════════════════════
    
    function windowAPI:Save(profileName)
        profileName = profileName or "default"
        
        local data = {
            Version = VapeV5.Version,
            Modules = {},
            Categories = {},
            Settings = {
                Theme = VapeV5.Settings.Theme,
                Rainbow = VapeV5.Settings.Rainbow,
            },
        }
        
        for name, module in pairs(VapeV5._modules) do
            data.Modules[name] = {
                Enabled = module.Enabled,
                Bind = module.Bind,
                Options = {},
            }
            
            for optName, option in pairs(module.Options) do
                if option.Save then
                    option:Save(data.Modules[name].Options)
                end
            end
        end
        
        for name, category in pairs(self.Categories) do
            data.Categories[name] = {
                Position = {
                    X = category.Object.Position.X.Offset,
                    Y = category.Object.Position.Y.Offset,
                },
                Expanded = category.Expanded,
            }
        end
        
        local success = pcall(function()
            Utils.EnsureFolder("VapeV5")
            Utils.EnsureFolder("VapeV5/profiles")
            local path = "VapeV5/profiles/" .. profileName .. "_" .. game.PlaceId .. ".json"
            Utils.SaveJSON(path, data)
        end)
        
        if success then
            self:Notify("Settings Saved", "Profile '" .. profileName .. "' saved!", 2, "Success")
        else
            self:Notify("Save Failed", "Could not save profile", 2, "Error")
        end
        
        return success
    end
    
    function windowAPI:Load(profileName)
        profileName = profileName or "default"
        local path = "VapeV5/profiles/" .. profileName .. "_" .. game.PlaceId .. ".json"
        
        if not Utils.FileExists(path) then
            Debug.Log("No saved profile found: " .. path)
            return false
        end
        
        local data = Utils.LoadJSON(path)
        if not data then
            Debug.Error("Failed to parse profile: " .. path)
            return false
        end
        
        for name, moduleData in pairs(data.Modules or {}) do
            local module = VapeV5._modules[name]
            if module then
                if moduleData.Enabled ~= nil and moduleData.Enabled ~= module.Enabled then
                    module:Toggle(true)
                end
                
                if moduleData.Bind then
                    module:SetBind(moduleData.Bind)
                end
                
                for optName, optData in pairs(moduleData.Options or {}) do
                    local option = module.Options[optName]
                    if option and option.Load then
                        option:Load(optData)
                    end
                end
            end
        end
        
        for name, catData in pairs(data.Categories or {}) do
            local category = self.Categories[name]
            if category and catData.Position then
                category.Object.Position = UDim2.fromOffset(catData.Position.X, catData.Position.Y)
                if catData.Expanded ~= category.Expanded then
                    category:Expand()
                end
            end
        end
        
        Debug.Log("Profile loaded: " .. profileName)
        return true
    end
    
    function windowAPI:Destroy()
        pcall(function()
            self:Save()
        end)
        
        for _, module in pairs(VapeV5._modules) do
            if module.Enabled then
                module:Toggle(true)
            end
        end
        
        for _, conn in pairs(VapeV5._connections) do
            if conn and conn.Disconnect then
                pcall(function() conn:Disconnect() end)
            end
        end
        
        BlurSystem:Destroy()
        
        if gui then
            gui:Destroy()
        end
        
        table.clear(VapeV5._modules)
        table.clear(VapeV5._windows)
        table.clear(VapeV5._connections)
        
        VapeV5._loaded = false
    end
    
    -- ═══════════════════════════════════════════════════════════════
    -- ⌨️ SISTEMA DE KEYBINDS
    -- ═══════════════════════════════════════════════════════════════

    local heldKeys = {}

    local function normalizeKeybind(keybind)
        if type(keybind) ~= "table" then
            return { tostring(keybind or "RightShift") }
        end
        return keybind
    end

    local function checkKeybind(keys, pressedKey)
        keys = normalizeKeybind(keys)

        if not table.find(keys, pressedKey) then
            return false
        end

        if #keys > 1 then
            for _, key in ipairs(keys) do
                if not table.find(heldKeys, key) then
                    return false
                end
            end
        end

        return true
    end

    local inputConnection = Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed and not VapeV5._bindingTarget then 
            if input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
                local keyName = input.KeyCode.Name
                if checkKeybind(VapeV5.Settings.Keybind, keyName) then
                    if windowAPI and type(windowAPI.Toggle) == "function" then
                        pcall(function() windowAPI:Toggle() end)
                    end
                end
            end
            return 
        end

        if not input.KeyCode or input.KeyCode == Enum.KeyCode.Unknown then
            return
        end

        local keyName = input.KeyCode.Name

        if not table.find(heldKeys, keyName) then
            table.insert(heldKeys, keyName)
        end

        if VapeV5._bindingTarget then
            pcall(function()
                VapeV5._bindingTarget:StopListening(input.KeyCode)
            end)
            return
        end

        if checkKeybind(VapeV5.Settings.Keybind, keyName) then
            if windowAPI and type(windowAPI.Toggle) == "function" then
                local success, err = pcall(function()
                    windowAPI:Toggle()
                end)
                if not success then
                    warn("[VapeV5] Toggle error:", err)
                end
            end
            return
        end

        if VapeV5._modules then
            for _, module in pairs(VapeV5._modules) do
                if module.Bind and #module.Bind > 0 and checkKeybind(module.Bind, keyName) then
                    local toggleSuccess = pcall(function()
                        module:Toggle()
                    end)

                    if toggleSuccess and VapeV5.Settings.General.Notifications then
                        pcall(function()
                            VapeV5.Notify(
                                "Module Toggled",
                                module.Name .. " " .. (module.Enabled 
                                    and "<font color='#5AFF5A'>Enabled</font>" 
                                    or "<font color='#FF5A5A'>Disabled</font>"),
                                1.5,
                                module.Enabled and "Success" or "Error"
                            )
                        end)
                    end
                end
            end
        end
    end)

    local inputEndConnection = Services.UserInputService.InputEnded:Connect(function(input)
        if not input.KeyCode or input.KeyCode == Enum.KeyCode.Unknown then
            return
        end

        local keyName = input.KeyCode.Name

        for i = #heldKeys, 1, -1 do
            if heldKeys[i] == keyName then
                table.remove(heldKeys, i)
            end
        end
    end)

    table.insert(VapeV5._connections, inputConnection)
    table.insert(VapeV5._connections, inputEndConnection)
    
    -- ═══════════════════════════════════════════════════════════════
    -- 🌈 SISTEMA RAINBOW
    -- ═══════════════════════════════════════════════════════════════
    
    local rainbowAccum = 0
    local rainbowRate = 1 / (VapeV5.Settings.Rainbow.UpdateRate or 30)
    
    local rainbowConnection = Services.RunService.Heartbeat:Connect(function(dt)
        if not VapeV5.Settings.Rainbow.Enabled then return end
        
        rainbowAccum = rainbowAccum + dt
        if rainbowAccum < rainbowRate then return end
        rainbowAccum = rainbowAccum - rainbowRate
        
        local hue = (tick() * 0.2 * VapeV5.Settings.Rainbow.Speed) % 1
        
        for _, item in ipairs(VapeV5._rainbowTable) do
            if item and item.SetValue then
                pcall(function()
                    item:SetValue(ColorSystem.GetRainbow(hue))
                end)
            end
        end
    end)
    
    table.insert(VapeV5._connections, rainbowConnection)
    
    -- ═══════════════════════════════════════════════════════════════
    -- 📐 ATUALIZAR TAMANHO DA JANELA PRINCIPAL
    -- ═══════════════════════════════════════════════════════════════
    
    tabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentHeight = tabsLayout.AbsoluteContentSize.Y / scale.Scale
        mainWindow.Size = UDim2.fromOffset(mainWindow.Size.X.Offset, math.max(42 + contentHeight, 100))
        tabsContainer.CanvasSize = UDim2.fromOffset(0, contentHeight)
    end)
    
    -- ═══════════════════════════════════════════════════════════════
    -- 🎯 FINALIZAÇÃO
    -- ═══════════════════════════════════════════════════════════════
    
    VapeV5._loaded = true
    table.insert(VapeV5._windows, windowAPI)
    
    task.spawn(function()
        task.wait(0.5)
        windowAPI:Load()
    end)
    
    if options.ShowWelcome then
        task.spawn(function()
            task.wait(1)
            VapeV5.Notify(
                options.Title,
                "Press <font color='#05C46B'>" .. table.concat(VapeV5.Settings.Keybind, " + "):upper() .. "</font> to toggle GUI",
                3,
                "Info"
            )
        end)
    end
    
    windowAPI.GUI = gui
    windowAPI.MainWindow = mainWindow
    
    return windowAPI
end

-- ═══════════════════════════════════════════════════════════════════
-- 🎨 TEMAS PRÉ-DEFINIDOS
-- ═══════════════════════════════════════════════════════════════════

VapeV5.Themes = {
    Dark = {
        Primary = Color3.fromRGB(26, 25, 26),
        Secondary = Color3.fromRGB(35, 34, 35),
        Accent = Color3.fromRGB(5, 134, 105),
        Text = Color3.fromRGB(200, 200, 200),
        TextDark = Color3.fromRGB(140, 140, 140),
        Success = Color3.fromRGB(90, 255, 90),
        Error = Color3.fromRGB(255, 90, 90),
        Warning = Color3.fromRGB(255, 170, 0),
    },
    
    Light = {
        Primary = Color3.fromRGB(245, 245, 245),
        Secondary = Color3.fromRGB(235, 235, 235),
        Accent = Color3.fromRGB(5, 134, 105),
        Text = Color3.fromRGB(40, 40, 40),
        TextDark = Color3.fromRGB(100, 100, 100),
        Success = Color3.fromRGB(46, 204, 113),
        Error = Color3.fromRGB(231, 76, 60),
        Warning = Color3.fromRGB(241, 196, 15),
    },
    
    Ocean = {
        Primary = Color3.fromRGB(20, 30, 48),
        Secondary = Color3.fromRGB(30, 45, 65),
        Accent = Color3.fromRGB(52, 152, 219),
        Text = Color3.fromRGB(200, 210, 220),
        TextDark = Color3.fromRGB(120, 140, 160),
        Success = Color3.fromRGB(46, 204, 113),
        Error = Color3.fromRGB(231, 76, 60),
        Warning = Color3.fromRGB(241, 196, 15),
    },
    
    Purple = {
        Primary = Color3.fromRGB(30, 25, 40),
        Secondary = Color3.fromRGB(45, 38, 58),
        Accent = Color3.fromRGB(155, 89, 182),
        Text = Color3.fromRGB(210, 200, 220),
        TextDark = Color3.fromRGB(140, 130, 150),
        Success = Color3.fromRGB(90, 255, 90),
        Error = Color3.fromRGB(255, 90, 90),
        Warning = Color3.fromRGB(255, 170, 0),
    },
    
    Red = {
        Primary = Color3.fromRGB(35, 25, 25),
        Secondary = Color3.fromRGB(50, 35, 35),
        Accent = Color3.fromRGB(231, 76, 60),
        Text = Color3.fromRGB(220, 200, 200),
        TextDark = Color3.fromRGB(160, 130, 130),
        Success = Color3.fromRGB(90, 255, 90),
        Error = Color3.fromRGB(255, 90, 90),
        Warning = Color3.fromRGB(255, 170, 0),
    },
    
    Midnight = {
        Primary = Color3.fromRGB(15, 15, 20),
        Secondary = Color3.fromRGB(25, 25, 32),
        Accent = Color3.fromRGB(99, 102, 241),
        Text = Color3.fromRGB(200, 200, 210),
        TextDark = Color3.fromRGB(120, 120, 140),
        Success = Color3.fromRGB(90, 255, 90),
        Error = Color3.fromRGB(255, 90, 90),
        Warning = Color3.fromRGB(255, 170, 0),
    },
    
    Forest = {
        Primary = Color3.fromRGB(25, 35, 25),
        Secondary = Color3.fromRGB(35, 50, 35),
        Accent = Color3.fromRGB(46, 204, 113),
        Text = Color3.fromRGB(200, 220, 200),
        TextDark = Color3.fromRGB(130, 160, 130),
        Success = Color3.fromRGB(90, 255, 90),
        Error = Color3.fromRGB(255, 90, 90),
        Warning = Color3.fromRGB(255, 170, 0),
    },
    
    Dracula = {
        Primary = Color3.fromRGB(40, 42, 54),
        Secondary = Color3.fromRGB(68, 71, 90),
        Accent = Color3.fromRGB(189, 147, 249),
        Text = Color3.fromRGB(248, 248, 242),
        TextDark = Color3.fromRGB(98, 114, 164),
        Success = Color3.fromRGB(80, 250, 123),
        Error = Color3.fromRGB(255, 85, 85),
        Warning = Color3.fromRGB(255, 184, 108),
    },
    
    Nord = {
        Primary = Color3.fromRGB(46, 52, 64),
        Secondary = Color3.fromRGB(59, 66, 82),
        Accent = Color3.fromRGB(136, 192, 208),
        Text = Color3.fromRGB(236, 239, 244),
        TextDark = Color3.fromRGB(216, 222, 233),
        Success = Color3.fromRGB(163, 190, 140),
        Error = Color3.fromRGB(191, 97, 106),
        Warning = Color3.fromRGB(235, 203, 139),
    },
    
    Monokai = {
        Primary = Color3.fromRGB(39, 40, 34),
        Secondary = Color3.fromRGB(49, 50, 44),
        Accent = Color3.fromRGB(166, 226, 46),
        Text = Color3.fromRGB(248, 248, 242),
        TextDark = Color3.fromRGB(117, 113, 94),
        Success = Color3.fromRGB(166, 226, 46),
        Error = Color3.fromRGB(249, 38, 114),
        Warning = Color3.fromRGB(230, 219, 116),
    },
}

function VapeV5:SetTheme(themeName)
    local themeData = self.Themes[themeName]
    if themeData then
        for k, v in pairs(themeData) do
            self.Settings.Theme[k] = v
        end
        Debug.Log("Theme applied: " .. themeName)
        return true
    end
    Debug.Warn("Theme not found: " .. tostring(themeName))
    return false
end

-- ═══════════════════════════════════════════════════════════════════
-- 🚀 RETORNAR BIBLIOTECA
-- ═══════════════════════════════════════════════════════════════════

Debug.Log("VapeV5 UI Library v" .. VapeV5.Version .. " loaded!")

return VapeV5
