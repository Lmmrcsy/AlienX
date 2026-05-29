-- XA Hub UI Library (修复版)
-- 支持剑客就完事了

local UI = {}
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- UI 存储
UI.flags = {}
UI.windows = {}
UI.tabs = {}
UI.sections = {}
UI.elements = {}

-- 颜色常量
local Colors = {
    Primary = Color3.fromRGB(85, 170, 255),
    Secondary = Color3.fromRGB(31, 31, 31),
    Success = Color3.fromRGB(0, 255, 0),
    Danger = Color3.fromRGB(255, 0, 0),
    Warning = Color3.fromRGB(255, 170, 0),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(200, 200, 200),
    Background = Color3.fromRGB(20, 20, 20),
    Border = Color3.fromRGB(40, 40, 40)
}

-- 工具函数
local function CreateRoundedCorner(parent, radius)
    local corner = Instance.new("UICorner", parent)
    corner.CornerRadius = UDim.new(0, radius or 6)
    return corner
end

local function CreateStroke(parent, thickness, color)
    local stroke = Instance.new("UIStroke", parent)
    stroke.Thickness = thickness or 1
    stroke.Color = color or Colors.Border
    return stroke
end

-- 修复：正确的阴影创建函数
local function CreateShadow(parent)
    local corner = Instance.new("UICorner", parent)
    corner.CornerRadius = UDim.new(0, 8)
    
    local shadowEffect = Instance.new("UIShadow", parent)
    shadowEffect.Color = Color3.fromRGB(0, 0, 0)
    shadowEffect.Transparency = 0.5
    shadowEffect.BlurSize = 2  -- 修复：使用 BlurSize 而不是 Size
    return shadowEffect
end

-- 创建主窗口
function UI:CreateWindow(title, options)
    options = options or {}
    local window = {
        Title = title,
        Subtitle = options.Subtitle or "",
        Icon = options.Icon or "",
        Keybind = options.Keybind or Enum.KeyCode.RightControl,
        Visible = false,
        Tabs = {},
        ActiveTab = nil,
        Gui = nil
    }
    
    -- 创建 GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "XA_Hub_" .. title:gsub("%s+", "_")
    screenGui.Parent = CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    
    -- 主框架
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Main"
    mainFrame.Parent = screenGui
    mainFrame.BackgroundColor3 = Colors.Background
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Size = UDim2.new(0, 600, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
    mainFrame.Visible = false
    CreateRoundedCorner(mainFrame, 12)
    CreateStroke(mainFrame, 1, Colors.Border)
    CreateShadow(mainFrame)
    
    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Parent = mainFrame
    titleBar.BackgroundColor3 = Colors.Primary
    titleBar.BackgroundTransparency = 0.2
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    CreateRoundedCorner(titleBar, 12)
    
    -- 标题文字
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = titleBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Colors.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- 副标题
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Parent = titleBar
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.TextColor3 = Colors.TextDim
    subtitleLabel.Font = Enum.Font.Gotham
    subtitleLabel.TextSize = 11
    subtitleLabel.Text = options.Subtitle or ""
    subtitleLabel.Size = UDim2.new(0, 300, 1, 0)
    subtitleLabel.Position = UDim2.new(0, 220, 0, 0)
    subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- 关闭按钮
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = titleBar
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Colors.Text
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 20
    closeBtn.Text = "×"
    closeBtn.Size = UDim2.new(0, 35, 1, 0)
    closeBtn.Position = UDim2.new(1, -35, 0, 0)
    closeBtn.AutoButtonColor = false
    
    closeBtn.MouseButton1Click:Connect(function()
        window.Visible = false
        mainFrame.Visible = false
    end)
    
    -- 侧边栏
    local sideBar = Instance.new("Frame")
    sideBar.Name = "SideBar"
    sideBar.Parent = mainFrame
    sideBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    sideBar.BackgroundTransparency = 0.1
    sideBar.BorderSizePixel = 0
    sideBar.Size = UDim2.new(0, 150, 1, -45)
    sideBar.Position = UDim2.new(0, 0, 0, 45)
    
    local sideBarList = Instance.new("UIListLayout", sideBar)
    sideBarList.Padding = UDim.new(0, 5)
    sideBarList.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- 内容区域
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Parent = mainFrame
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.Size = UDim2.new(1, -155, 1, -55)
    contentFrame.Position = UDim2.new(0, 155, 0, 50)
    
    -- 存储窗口数据
    window.Gui = screenGui
    window.MainFrame = mainFrame
    window.ContentFrame = contentFrame
    window.TabButtons = {}
    window.SideBar = sideBar
    
    -- 切换标签页函数
    function window:SelectTab(tabName)
        for name, tabData in pairs(self.Tabs) do
            local visible = (name == tabName)
            if tabData.Frame then
                tabData.Frame.Visible = visible
            end
            if tabData.Button then
                tabData.Button.BackgroundColor3 = visible and Colors.Primary or Color3.fromRGB(30, 30, 30)
                tabData.Button.TextColor3 = visible and Colors.Text or Colors.TextDim
            end
        end
        self.ActiveTab = tabName
    end
    
    -- 显示/隐藏窗口
    function window:Toggle()
        self.Visible = not self.Visible
        mainFrame.Visible = self.Visible
    end
    
    -- 绑定快捷键
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == window.Keybind then
            window:Toggle()
        end
    end)
    
    table.insert(UI.windows, window)
    return window
end

-- 创建标签页
function UI:Tab(window, name, icon)
    local tab = {
        Window = window,
        Name = name,
        Icon = icon,
        Sections = {},
        Frame = nil,
        Button = nil
    }
    
    -- 创建标签页按钮
    local tabBtn = Instance.new("TextButton")
    tabBtn.Parent = window.SideBar
    tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabBtn.BackgroundTransparency = 0.5
    tabBtn.BorderSizePixel = 0
    tabBtn.Size = UDim2.new(1, -10, 0, 40)
    tabBtn.Position = UDim2.new(0, 5, 0, 0)
    tabBtn.Text = "  " .. name
    tabBtn.TextColor3 = Colors.TextDim
    tabBtn.TextSize = 14
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    CreateRoundedCorner(tabBtn, 8)
    
    -- 创建标签页内容框架
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Parent = window.ContentFrame
    tabFrame.BackgroundTransparency = 1
    tabFrame.BorderSizePixel = 0
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabFrame.ScrollBarThickness = 4
    tabFrame.ScrollBarImageColor3 = Colors.Primary
    tabFrame.Visible = false
    
    local tabLayout = Instance.new("UIListLayout", tabFrame)
    tabLayout.Padding = UDim.new(0, 10)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    tabBtn.MouseButton1Click:Connect(function()
        window:SelectTab(name)
    end)
    
    tab.Frame = tabFrame
    tab.Button = tabBtn
    window.Tabs[name] = tab
    
    if not window.ActiveTab then
        window:SelectTab(name)
    end
    
    return tab
end

-- 创建区块
function UI:Section(tab, title, collapsible)
    local section = {
        Tab = tab,
        Title = title,
        Elements = {},
        Frame = nil,
        Expanded = true,
        ContentHeight = 0
    }
    
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Parent = tab.Frame
    sectionFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    sectionFrame.BackgroundTransparency = 0.3
    sectionFrame.BorderSizePixel = 0
    sectionFrame.Size = UDim2.new(1, -20, 0, 40)
    sectionFrame.Position = UDim2.new(0, 10, 0, 0)
    CreateRoundedCorner(sectionFrame, 8)
    CreateStroke(sectionFrame, 1, Colors.Border)
    
    -- 标题栏
    local header = Instance.new("TextButton")
    header.Parent = sectionFrame
    header.BackgroundTransparency = 1
    header.TextColor3 = Colors.Text
    header.Font = Enum.Font.GothamBold
    header.TextSize = 14
    header.Text = "  " .. title
    header.Size = UDim2.new(1, 0, 0, 35)
    header.TextXAlignment = Enum.TextXAlignment.Left
    
    -- 内容容器
    local contentContainer = Instance.new("Frame")
    contentContainer.Parent = sectionFrame
    contentContainer.BackgroundTransparency = 1
    contentContainer.Size = UDim2.new(1, -10, 0, 0)
    contentContainer.Position = UDim2.new(0, 5, 0, 35)
    
    local contentLayout = Instance.new("UIListLayout", contentContainer)
    contentLayout.Padding = UDim.new(0, 5)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    section.Frame = sectionFrame
    section.Content = contentContainer
    section.Layout = contentLayout
    
    if collapsible then
        local expandIcon = Instance.new("TextLabel")
        expandIcon.Parent = header
        expandIcon.BackgroundTransparency = 1
        expandIcon.TextColor3 = Colors.TextDim
        expandIcon.Font = Enum.Font.Gotham
        expandIcon.TextSize = 14
        expandIcon.Text = "▼"
        expandIcon.Size = UDim2.new(0, 20, 1, 0)
        expandIcon.Position = UDim2.new(1, -25, 0, 0)
        
        header.MouseButton1Click:Connect(function()
            section.Expanded = not section.Expanded
            contentContainer.Visible = section.Expanded
            expandIcon.Text = section.Expanded and "▼" or "▶"
            sectionFrame.Size = UDim2.new(1, -20, 0, 35 + (section.Expanded and section.ContentHeight or 0))
        end)
    end
    
    function section:AddElement(element, height)
        element.Parent = contentContainer
        if height then
            section.ContentHeight = (section.ContentHeight or 0) + height
            sectionFrame.Size = UDim2.new(1, -20, 0, 35 + section.ContentHeight)
        end
        table.insert(self.Elements, element)
        return element
    end
    
    function section:UpdateCanvas()
        local totalHeight = 0
        for _, child in ipairs(contentContainer:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible then
                totalHeight = totalHeight + child.AbsoluteSize.Y + 5
            end
        end
        section.ContentHeight = totalHeight
        if section.Expanded then
            sectionFrame.Size = UDim2.new(1, -20, 0, 35 + totalHeight)
        end
        tab.Frame.CanvasSize = UDim2.new(0, 0, 0, tab.Frame.AbsoluteCanvasSize.Y)
    end
    
    table.insert(tab.Sections, section)
    return section
end

-- 创建标签 (只读文本)
function UI:Label(section, text)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.TextColor3 = Colors.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Text = text
    label.Size = UDim2.new(1, -20, 0, 20)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    section:AddElement(label, 20)
    
    local api = {
        Text = label,
        Update = function(self, newText)
            self.Text.Text = newText
        end
    }
    return api
end

-- 创建按钮
function UI:Button(section, text, callback)
    local button = Instance.new("TextButton")
    button.BackgroundColor3 = Colors.Primary
    button.BackgroundTransparency = 0.8
    button.TextColor3 = Colors.Text
    button.Font = Enum.Font.Gotham
    button.TextSize = 13
    button.Text = text
    button.Size = UDim2.new(1, -20, 0, 30)
    CreateRoundedCorner(button, 6)
    
    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.6}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundTransparency = 0.8}):Play()
    end)
    
    section:AddElement(button, 30)
    return button
end

-- 创建开关
function UI:Toggle(section, text, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, -20, 0, 30)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.TextColor3 = Colors.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Text = text
    label.Size = UDim2.new(1, -50, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("TextButton")
    toggle.Parent = frame
    toggle.BackgroundColor3 = defaultValue and Colors.Success or Colors.Danger
    toggle.BackgroundTransparency = 0.5
    toggle.TextColor3 = Colors.Text
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 11
    toggle.Text = defaultValue and "ON" or "OFF"
    toggle.Size = UDim2.new(0, 45, 0, 22)
    toggle.Position = UDim2.new(1, -50, 0.5, -11)
    CreateRoundedCorner(toggle, 11)
    
    local state = defaultValue or false
    
    local function updateToggle()
        toggle.BackgroundColor3 = state and Colors.Success or Colors.Danger
        toggle.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end
    
    toggle.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
    end)
    
    section:AddElement(frame, 30)
    
    return {
        SetState = function(self, newState)
            state = newState
            updateToggle()
        end,
        GetState = function()
            return state
        end
    }
end

-- 创建滑块
function UI:Slider(section, text, defaultValue, min, max, integer, callback)
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, -20, 0, 50)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.TextColor3 = Colors.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Text = text
    label.Size = UDim2.new(1, -80, 0, 20)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = frame
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Colors.Primary
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 13
    valueLabel.Text = tostring(defaultValue)
    valueLabel.Size = UDim2.new(0, 70, 0, 20)
    valueLabel.Position = UDim2.new(1, -75, 0, 0)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = frame
    sliderBg.BackgroundColor3 = Colors.Border
    sliderBg.BorderSizePixel = 0
    sliderBg.Size = UDim2.new(1, -10, 0, 4)
    sliderBg.Position = UDim2.new(0, 5, 0, 30)
    CreateRoundedCorner(sliderBg, 2)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBg
    sliderFill.BackgroundColor3 = Colors.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    CreateRoundedCorner(sliderFill, 2)
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Parent = sliderFill
    sliderKnob.BackgroundColor3 = Colors.Primary
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Size = UDim2.new(0, 12, 0, 12)
    sliderKnob.Position = UDim2.new(1, -6, 0.5, -6)
    CreateRoundedCorner(sliderKnob, 6)
    CreateStroke(sliderKnob, 1, Colors.Text)
    
    local value = defaultValue or min
    
    local function updateSlider(newValue)
        value = math.clamp(newValue, min, max)
        if integer then value = math.floor(value) end
        local percent = (value - min) / (max - min)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Text = tostring(value)
        if callback then callback(value) end
    end
    
    local dragging = false
    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = input.Position.X - sliderBg.AbsolutePosition.X
            local width = sliderBg.AbsoluteSize.X
            local percent = math.clamp(pos / width, 0, 1)
            updateSlider(min + percent * (max - min))
        end
    end)
    
    section:AddElement(frame, 50)
    
    return {
        SetValue = function(self, newValue)
            updateSlider(newValue)
        end,
        GetValue = function()
            return value
        end
    }
end

-- 创建下拉框
function UI:Dropdown(section, text, options, defaultIndex, callback)
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, -20, 0, 40)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.TextColor3 = Colors.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Text = text
    label.Size = UDim2.new(0, 120, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local dropdownBtn = Instance.new("TextButton")
    dropdownBtn.Parent = frame
    dropdownBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dropdownBtn.TextColor3 = Colors.Text
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.TextSize = 12
    dropdownBtn.Text = options[defaultIndex or 1] or options[1]
    dropdownBtn.Size = UDim2.new(1, -130, 0, 30)
    dropdownBtn.Position = UDim2.new(0, 125, 0.5, -15)
    CreateRoundedCorner(dropdownBtn, 6)
    
    local dropdownList = Instance.new("ScrollingFrame")
    dropdownList.Parent = frame
    dropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dropdownList.BorderSizePixel = 0
    dropdownList.Size = UDim2.new(1, -130, 0, 0)
    dropdownList.Position = UDim2.new(0, 125, 0, 15)
    dropdownList.Visible = false
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
    dropdownList.ScrollBarThickness = 3
    CreateRoundedCorner(dropdownList, 6)
    CreateStroke(dropdownList, 1, Colors.Border)
    
    local dropdownLayout = Instance.new("UIListLayout", dropdownList)
    dropdownLayout.Padding = UDim.new(0, 1)
    
    local expanded = false
    local selectedOption = options[defaultIndex or 1]
    
    local function updateDropdownHeight()
        local childCount = 0
        for _, child in ipairs(dropdownList:GetChildren()) do
            if child:IsA("TextButton") then
                childCount = childCount + 1
            end
        end
        local height = math.min(childCount * 30, 150)
        dropdownList.Size = UDim2.new(1, -130, 0, expanded and height or 0)
        frame.Size = UDim2.new(1, -20, 0, expanded and 40 + height or 40)
        if section.UpdateCanvas then section:UpdateCanvas() end
    end
    
    for i, option in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Parent = dropdownList
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Colors.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Text = option
        btn.Size = UDim2.new(1, 0, 0, 30)
        
        btn.MouseButton1Click:Connect(function()
            selectedOption = option
            dropdownBtn.Text = option
            expanded = false
            updateDropdownHeight()
            if callback then callback(option, i) end
        end)
    end
    
    dropdownBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        updateDropdownHeight()
    end)
    
    section:AddElement(frame, 40)
    
    return {
        SetOptions = function(self, newOptions)
            for _, child in ipairs(dropdownList:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            for i, option in ipairs(newOptions) do
                local btn = Instance.new("TextButton")
                btn.Parent = dropdownList
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                btn.TextColor3 = Colors.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                btn.Text = option
                btn.Size = UDim2.new(1, 0, 0, 30)
                
                btn.MouseButton1Click:Connect(function()
                    selectedOption = option
                    dropdownBtn.Text = option
                    expanded = false
                    updateDropdownHeight()
                    if callback then callback(option, i) end
                end)
            end
            updateDropdownHeight()
        end,
        GetValue = function()
            return selectedOption
        end
    }
end

-- 创建文本框
function UI:Textbox(section, text, placeholder, callback)
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, -20, 0, 40)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.TextColor3 = Colors.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Text = text
    label.Size = UDim2.new(0, 120, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local textbox = Instance.new("TextBox")
    textbox.Parent = frame
    textbox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    textbox.TextColor3 = Colors.Text
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 12
    textbox.PlaceholderText = placeholder or ""
    textbox.Text = ""
    textbox.Size = UDim2.new(1, -130, 0, 30)
    textbox.Position = UDim2.new(0, 125, 0.5, -15)
    textbox.ClearTextOnFocus = false
    CreateRoundedCorner(textbox, 6)
    
    textbox.FocusLost:Connect(function(enterPressed)
        if callback then callback(textbox.Text) end
    end)
    
    section:AddElement(frame, 40)
    return textbox
end

-- 创建键位绑定
function UI:Keybind(section, text, defaultKey, callback)
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, -20, 0, 40)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.TextColor3 = Colors.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Text = text
    label.Size = UDim2.new(1, -100, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local keyBtn = Instance.new("TextButton")
    keyBtn.Parent = frame
    keyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    keyBtn.TextColor3 = Colors.Text
    keyBtn.Font = Enum.Font.Gotham
    keyBtn.TextSize = 11
    keyBtn.Text = defaultKey and tostring(defaultKey):gsub("Enum.KeyCode.", "") or "未绑定"
    keyBtn.Size = UDim2.new(0, 80, 0, 30)
    keyBtn.Position = UDim2.new(1, -85, 0.5, -15)
    CreateRoundedCorner(keyBtn, 6)
    
    local listening = false
    local currentKey = defaultKey
    
    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "按下按键..."
        keyBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if listening then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                currentKey = input.KeyCode
                keyBtn.Text = tostring(currentKey):gsub("Enum.KeyCode.", "")
                if callback then callback(currentKey) end
                listening = false
                keyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                -- 忽略鼠标点击
            else
                listening = false
                keyBtn.Text = tostring(currentKey):gsub("Enum.KeyCode.", "")
                keyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            end
        end
    end)
    
    section:AddElement(frame, 40)
    
    return {
        GetKey = function()
            return currentKey
        end,
        SetKey = function(self, newKey)
            currentKey = newKey
            keyBtn.Text = tostring(currentKey):gsub("Enum.KeyCode.", "")
        end
    }
end

-- 创建分割线
function UI:Separator(section)
    local line = Instance.new("Frame")
    line.BackgroundColor3 = Colors.Border
    line.BorderSizePixel = 0
    line.Size = UDim2.new(1, -20, 0, 1)
    line.Position = UDim2.new(0, 10, 0, 0)
    
    section:AddElement(line, 5)
    return line
end

-- 通知系统
function UI:Notify(title, text, duration)
    local notification = Instance.new("Frame")
    notification.Parent = CoreGui
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notification.BackgroundTransparency = 0.1
    notification.BorderSizePixel = 0
    notification.Size = UDim2.new(0, 300, 0, 60)
    notification.Position = UDim2.new(1, -310, 0, 10)
    CreateRoundedCorner(notification, 8)
    CreateStroke(notification, 1, Colors.Border)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = notification
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Colors.Primary
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = notification
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Colors.Text
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 12
    textLabel.Text = text
    textLabel.Size = UDim2.new(1, -20, 0, 25)
    textLabel.Position = UDim2.new(0, 10, 0, 30)
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    TweenService:Create(notification, TweenInfo.new(0.3), {Position = UDim2.new(1, -310, 0, 10)}):Play()
    
    task.delay(duration or 3, function()
        TweenService:Create(notification, TweenInfo.new(0.3), {Position = UDim2.new(1, 0, 0, 10)}):Play()
        task.delay(0.3, function()
            notification:Destroy()
        end)
    end)
end

-- 全局 flags 存储
UI.flags = {}

return UI
