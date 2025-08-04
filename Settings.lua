local httpService = game:GetService("HttpService")  -- 获取HTTP服务

local InterfaceManager = {} do
    -- 界面管理器配置
    InterfaceManager.Folder = "FluentSettings"  -- 默认设置文件夹
    InterfaceManager.Settings = {  -- 默认设置
        Theme = "Dark",           -- 默认主题
        Acrylic = true,           -- 默认启用亚克力效果
        Transparency = true,       -- 默认启用透明度
        MenuKeybind = "LeftControl" -- 默认菜单快捷键
    }

    -- 设置文件夹路径
    function InterfaceManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()  -- 创建文件夹结构
    end

    -- 设置UI库引用
    function InterfaceManager:SetLibrary(library)
        self.Library = library
    end

    -- 创建文件夹结构
    function InterfaceManager:BuildFolderTree()
        local paths = {}  -- 存储所有需要创建的路径

        -- 分割路径并生成各级子路径
        local parts = self.Folder:split("/")
        for idx = 1, #parts do
            paths[#paths + 1] = table.concat(parts, "/", 1, idx)
        end

        -- 添加主文件夹和设置文件夹
        table.insert(paths, self.Folder)
        table.insert(paths, self.Folder .. "/settings")

        -- 创建所有需要的文件夹
        for i = 1, #paths do
            local str = paths[i]
            if not isfolder(str) then
                makefolder(str)
            end
        end
    end

    -- 保存设置到文件
    function InterfaceManager:SaveSettings()
        writefile(self.Folder .. "/options.json", httpService:JSONEncode(InterfaceManager.Settings))
    end

    -- 从文件加载设置
    function InterfaceManager:LoadSettings()
        local path = self.Folder .. "/options.json"
        if isfile(path) then
            local data = readfile(path)
            -- 安全地解码JSON数据
            local success, decoded = pcall(httpService.JSONDecode, httpService, data)

            if success then
                -- 更新设置
                for i, v in next, decoded do
                    InterfaceManager.Settings[i] = v
                end
            end
        end
    end

    -- 构建界面设置部分
    function InterfaceManager:BuildInterfaceSection(tab)
        assert(self.Library, "必须先设置InterfaceManager.Library")  -- 检查库是否设置
        local Library = self.Library
        local Settings = InterfaceManager.Settings

        -- 加载现有设置
        InterfaceManager:LoadSettings()

        -- 添加界面设置区域
        local section = tab:AddSection("界面设置")

        -- 主题选择下拉框
        local InterfaceTheme = section:AddDropdown("InterfaceTheme", {
            Title = "主题",
            Description = "更改界面主题",
            Values = Library.Themes,  -- 可用主题列表
            Default = Settings.Theme, -- 默认主题
            Callback = function(Value)
                Library:SetTheme(Value)  -- 应用新主题
                Settings.Theme = Value   -- 更新设置
                InterfaceManager:SaveSettings()  -- 保存设置
            end
        })

        InterfaceTheme:SetValue(Settings.Theme)  -- 设置当前值

        -- 亚克力效果开关（如果库支持）
        if Library.UseAcrylic then
            section:AddToggle("AcrylicToggle", {
                Title = "亚克力效果",
                Description = "模糊背景需要图形质量8以上",
                Default = Settings.Acrylic,
                Callback = function(Value)
                    Library:ToggleAcrylic(Value)  -- 切换亚克力效果
                    Settings.Acrylic = Value     -- 更新设置
                    InterfaceManager:SaveSettings()  -- 保存设置
                end
            })
        end

        -- 透明度开关
        section:AddToggle("TransparentToggle", {
            Title = "透明度",
            Description = "使界面透明",
            Default = Settings.Transparency,
            Callback = function(Value)
                Library:ToggleTransparency(Value)  -- 切换透明度
                Settings.Transparency = Value     -- 更新设置
                InterfaceManager:SaveSettings()  -- 保存设置
            end
        })

        -- 菜单快捷键设置
        local MenuKeybind = section:AddKeybind("MenuKeybind", { 
            Title = "最小化快捷键", 
            Default = Settings.MenuKeybind 
        })
        
        MenuKeybind:OnChanged(function()
            Settings.MenuKeybind = MenuKeybind.Value  -- 更新快捷键设置
            InterfaceManager:SaveSettings()          -- 保存设置
        end)
        
        Library.MinimizeKeybind = MenuKeybind  -- 设置库的最小化快捷键
    end
end

return InterfaceManager