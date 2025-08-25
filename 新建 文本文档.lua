-- XiPro UI 库 (完整版，带加载动画)
-- 支持: Window / Tab / Button / Toggle / Label / Dropdown

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local UI = {}
UI.__index = UI

-- 加载动画
local function ShowLoadingScreen(callback)
    local ScreenGui = Instance.new("ScreenGui", playerGui)
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false

    local BG = Instance.new("Frame", ScreenGui)
    BG.Size = UDim2.new(1, 0, 1, 0)
    BG.BackgroundColor3 = Color3.fromRGB(20, 25, 40)

    local LoadingFrame = Instance.new("Frame", BG)
    LoadingFrame.Size = UDim2.new(0, 400, 0, 200)
    LoadingFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    LoadingFrame.BorderSizePixel = 0
    local UICorner = Instance.new("UICorner", LoadingFrame)
    UICorner.CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel", LoadingFrame)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "欢迎回来, " .. player.Name
    Title.TextColor3 = Color3.fromRGB(200, 220, 255)
    Title.TextSize = 20
    Title.Font = Enum.Font.GothamBold

    local Status = Instance.new("TextLabel", LoadingFrame)
    Status.Size = UDim2.new(1, 0, 0, 30)
    Status.Position = UDim2.new(0, 0, 0, 50)
    Status.BackgroundTransparency = 1
    Status.Text = "正在加载 UI..."
    Status.TextColor3 = Color3.fromRGB(180, 200, 240)
    Status.TextSize = 16
    Status.Font = Enum.Font.Gotham

    local BarBG = Instance.new("Frame", LoadingFrame)
    BarBG.Size = UDim2.new(1, -40, 0, 20)
    BarBG.Position = UDim2.new(0, 20, 1, -50)
    BarBG.BackgroundColor3 = Color3.fromRGB(40, 50, 80)
    BarBG.BorderSizePixel = 0
    local Corner2 = Instance.new("UICorner", BarBG)
    Corner2.CornerRadius = UDim.new(0, 8)

    local BarFill = Instance.new("Frame", BarBG)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(70, 130, 210)
    BarFill.BorderSizePixel = 0
    local Corner3 = Instance.new("UICorner", BarFill)
    Corner3.CornerRadius = UDim.new(0, 8)

    -- 模拟加载进度
    task.spawn(function()
        for i = 1, 100 do
            BarFill:TweenSize(UDim2.new(i/100, 0, 1, 0), "Out", "Quad", 0.02, true)
            task.wait(0.02)
        end
        task.wait(0.3)
        ScreenGui:Destroy()
        if callback then callback() end
    end)
end

-- 创建窗口
function UI:CreateWindow(title)
    local MainFrame
    local Tabs = {}

    local function CreateCoreUI()
        local ScreenGui = Instance.new("ScreenGui", playerGui)
        ScreenGui.ResetOnSpawn = false

        MainFrame = Instance.new("Frame", ScreenGui)
        MainFrame.Size = UDim2.new(0, 520, 0, 340)
        MainFrame.Position = UDim2.new(0.5, -260, 0.5, -170)
        MainFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
        MainFrame.BorderSizePixel = 0
        MainFrame.Active = true
        MainFrame.Draggable = true

        local UICorner = Instance.new("UICorner", MainFrame)
        UICorner.CornerRadius = UDim.new(0, 12)

        local Title = Instance.new("TextLabel", MainFrame)
        Title.Size = UDim2.new(1, 0, 0, 40)
        Title.BackgroundTransparency = 1
        Title.Text = title or "XiPro UI"
        Title.TextColor3 = Color3.fromRGB(140, 200, 255)
        Title.TextSize = 20
        Title.Font = Enum.Font.GothamBold

        local TabHolder = Instance.new("Frame", MainFrame)
        TabHolder.Size = UDim2.new(0, 130, 1, -40)
        TabHolder.Position = UDim2.new(0, 0, 0, 40)
        TabHolder.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
        TabHolder.BorderSizePixel = 0

        local ContentFrame = Instance.new("Frame", MainFrame)
        ContentFrame.Size = UDim2.new(1, -130, 1, -40)
        ContentFrame.Position = UDim2.new(0, 130, 0, 40)
        ContentFrame.BackgroundTransparency = 1

        -- 创建标签页
        function Tabs:CreateTab(tabName)
            local TabButton = Instance.new("TextButton", TabHolder)
            TabButton.Size = UDim2.new(1, 0, 0, 35)
            TabButton.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
            TabButton.Text = tabName
            TabButton.TextColor3 = Color3.fromRGB(200, 220, 255)
            TabButton.TextSize = 16
            TabButton.Font = Enum.Font.Gotham

            local TabContent = Instance.new("ScrollingFrame", ContentFrame)
            TabContent.Size = UDim2.new(1, 0, 1, 0)
            TabContent.BackgroundTransparency = 1
            TabContent.Visible = false
            TabContent.ScrollBarThickness = 6

            local UIList = Instance.new("UIListLayout", TabContent)
            UIList.Padding = UDim.new(0, 6)

            TabButton.MouseButton1Click:Connect(function()
                for _, frame in ipairs(ContentFrame:GetChildren()) do
                    if frame:IsA("ScrollingFrame") then
                        frame.Visible = false
                    end
                end
                TabContent.Visible = true
            end)

            -- 默认显示第一个标签
            if #ContentFrame:GetChildren() == 1 then
                TabContent.Visible = true
            end

            -- 按钮
            function TabContent:CreateButton(text, callback)
                local Btn = Instance.new("TextButton", TabContent)
                Btn.Size = UDim2.new(1, -10, 0, 35)
                Btn.BackgroundColor3 = Color3.fromRGB(40, 55, 85)
                Btn.Text = text
                Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                Btn.Font = Enum.Font.GothamBold
                Btn.TextSize = 16
                Btn.MouseButton1Click:Connect(callback or function() end)
            end

            -- 开关
            function TabContent:CreateToggle(text, default, callback)
                local state = default or false
                local ToggleBtn = Instance.new("TextButton", TabContent)
                ToggleBtn.Size = UDim2.new(1, -10, 0, 35)
                ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(70, 130, 210) or Color3.fromRGB(40, 55, 85)
                ToggleBtn.Text = text .. " : " .. (state and "开" or "关")
                ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                ToggleBtn.Font = Enum.Font.GothamBold
                ToggleBtn.TextSize = 16

                ToggleBtn.MouseButton1Click:Connect(function()
                    state = not state
                    ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(70, 130, 210) or Color3.fromRGB(40, 55, 85)
                    ToggleBtn.Text = text .. " : " .. (state and "开" or "关")
                    if callback then callback(state) end
                end)
            end

            -- 标签
            function TabContent:CreateLabel(text)
                local Label = Instance.new("TextLabel", TabContent)
                Label.Size = UDim2.new(1, -10, 0, 30)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Color3.fromRGB(200, 220, 255)
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 16
            end

            -- 下拉框
            function TabContent:CreateDropdown(text, list, callback)
                local Dropdown = Instance.new("TextButton", TabContent)
                Dropdown.Size = UDim2.new(1, -10, 0, 35)
                Dropdown.BackgroundColor3 = Color3.fromRGB(40, 55, 85)
                Dropdown.Text = text .. " ▼"
                Dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
                Dropdown.Font = Enum.Font.GothamBold
                Dropdown.TextSize = 16

                local Open = false
                local OptionsFrame = Instance.new("Frame", TabContent)
                OptionsFrame.Size = UDim2.new(1, -10, 0, #list * 30)
                OptionsFrame.Visible = false
                OptionsFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 60)

                local UIList2 = Instance.new("UIListLayout", OptionsFrame)
                UIList2.Padding = UDim.new(0, 2)

                for _, option in ipairs(list) do
                    local OptBtn = Instance.new("TextButton", OptionsFrame)
                    OptBtn.Size = UDim2.new(1, -10, 0, 28)
                    OptBtn.BackgroundColor3 = Color3.fromRGB(50, 70, 100)
                    OptBtn.Text = option
                    OptBtn.TextColor3 = Color3.fromRGB(220, 230, 255)
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 14
                    OptBtn.MouseButton1Click:Connect(function()
                        Dropdown.Text = text .. " : " .. option
                        OptionsFrame.Visible = false
                        Open = false
                        if callback then callback(option) end
                    end)
                end

                Dropdown.MouseButton1Click:Connect(function()
                    Open = not Open
                    OptionsFrame.Visible = Open
                end)
            end

            return TabContent
        end
    end

    -- 先展示加载动画，再生成UI
    ShowLoadingScreen(function()
        CreateCoreUI()
    end)

    return Tabs
end

return UI
