local httpService = game:GetService("HttpService")  -- 获取HTTP服务

local SaveManager = {} do
    -- 配置管理器初始化
    SaveManager.Folder = "FluentSettings"  -- 默认配置文件夹
    SaveManager.Ignore = {}  -- 忽略列表
    
    -- 配置解析器定义
    SaveManager.Parser = {
        -- 开关类型配置
        Toggle = {
            Save = function(idx, object) 
                return { type = "Toggle", idx = idx, value = object.Value } 
            end,
            Load = function(idx, data)
                if SaveManager.Options[idx] then 
                    SaveManager.Options[idx]:SetValue(data.value)
                end
            end,
        },
        
        -- 滑块类型配置
        Slider = {
            Save = function(idx, object)
                return { type = "Slider", idx = idx, value = tostring(object.Value) }
            end,
            Load = function(idx, data)
                if SaveManager.Options[idx] then 
                    SaveManager.Options[idx]:SetValue(data.value)
                end
            end,
        },
        
        -- 下拉框类型配置
        Dropdown = {
            Save = function(idx, object)
                return { type = "Dropdown", idx = idx, value = object.Value, mutli = object.Multi }
            end,
            Load = function(idx, data)
                if SaveManager.Options[idx] then 
                    SaveManager.Options[idx]:SetValue(data.value)
                end
            end,
        },
        
        -- 颜色选择器类型配置
        Colorpicker = {
            Save = function(idx, object)
                return { type = "Colorpicker", idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
            end,
            Load = function(idx, data)
                if SaveManager.Options[idx] then 
                    SaveManager.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
                end
            end,
        },
        
        -- 快捷键类型配置
        Keybind = {
            Save = function(idx, object)
                return { type = "Keybind", idx = idx, mode = object.Mode, key = object.Value }
            end,
            Load = function(idx, data)
                if SaveManager.Options[idx] then 
                    SaveManager.Options[idx]:SetValue(data.key, data.mode)
                end
            end,
        },

        -- 输入框类型配置
        Input = {
            Save = function(idx, object)
                return { type = "Input", idx = idx, text = object.Value }
            end,
            Load = function(idx, data)
                if SaveManager.Options[idx] and type(data.text) == "string" then
                    SaveManager.Options[idx]:SetValue(data.text)
                end
            end,
        },
    }

    -- 设置忽略的配置项
    function SaveManager:SetIgnoreIndexes(list)
        for _, key in next, list do
            self.Ignore[key] = true
        end
    end

    -- 设置配置文件夹路径
    function SaveManager:SetFolder(folder)
        self.Folder = folder;
        self:BuildFolderTree()  -- 创建文件夹结构
    end

    -- 保存配置到文件
    function SaveManager:Save(name)
        if (not name) then
            return false, "未选择配置文件"
        end

        local fullPath = self.Folder .. "/settings/" .. name .. ".json"

        local data = {
            objects = {}  -- 存储所有配置项
        }

        -- 遍历所有配置项并保存
        for idx, option in next, SaveManager.Options do
            if not self.Parser[option.Type] then continue end
            if self.Ignore[idx] then continue end

            table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
        end    

        -- 编码为JSON并写入文件
        local success, encoded = pcall(httpService.JSONEncode, httpService, data)
        if not success then
            return false, "数据编码失败"
        end

        writefile(fullPath, encoded)
        return true
    end

    -- 从文件加载配置
    function SaveManager:Load(name)
        if (not name) then
            return false, "未选择配置文件"
        end
        
        local file = self.Folder .. "/settings/" .. name .. ".json"
        if not isfile(file) then return false, "无效的文件" end

        -- 解码JSON文件
        local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
        if not success then return false, "解码错误" end

        -- 应用所有配置项
        for _, option in next, decoded.objects do
            if self.Parser[option.type] then
                -- 使用task.spawn避免阻塞
                task.spawn(function() self.Parser[option.type].Load(option.idx, option) end)
            end
        end

        return true
    end

    -- 忽略主题相关设置
    function SaveManager:IgnoreThemeSettings()
        self:SetIgnoreIndexes({ 
            "InterfaceTheme", "AcrylicToggle", "TransparentToggle", "MenuKeybind"
        })
    end

    -- 创建必要的文件夹结构
    function SaveManager:BuildFolderTree()
        local paths = {
            self.Folder,
            self.Folder .. "/settings"  -- 配置子文件夹
        }

        for i = 1, #paths do
            local str = paths[i]
            if not isfolder(str) then
                makefolder(str)
            end
        end
    end

    -- 刷新配置文件列表
    function SaveManager:RefreshConfigList()
        local list = listfiles(self.Folder .. "/settings")

        local out = {}
        for i = 1, #list do
            local file = list[i]
            if file:sub(-5) == ".json" then
                local pos = file:find(".json", 1, true)
                local start = pos

                -- 提取文件名
                local char = file:sub(pos, pos)
                while char ~= "/" and char ~= "\\" and char ~= "" do
                    pos = pos - 1
                    char = file:sub(pos, pos)
                end

                if char == "/" or char == "\\" then
                    local name = file:sub(pos + 1, start - 1)
                    if name ~= "options" then
                        table.insert(out, name)
                    end
                end
            end
        end
        
        return out
    end

    -- 设置UI库引用
    function SaveManager:SetLibrary(library)
        self.Library = library
        self.Options = library.Options  -- 获取所有配置项
    end

    -- 加载自动加载的配置
    function SaveManager:LoadAutoloadConfig()
        if isfile(self.Folder .. "/settings/autoload.txt") then
            local name = readfile(self.Folder .. "/settings/autoload.txt")

            local success, err = self:Load(name)
            if not success then
                return self.Library:Notify({
                    Title = "界面",
                    Content = "配置加载器",
                    SubContent = "自动加载配置失败: " .. err,
                    Duration = 7
                })
            end

            self.Library:Notify({
                Title = "界面",
                Content = "配置加载器",
                SubContent = string.format("已自动加载配置 %q", name),
                Duration = 7
            })
        end
    end

    -- 构建配置管理界面
    function SaveManager:BuildConfigSection(tab)
        assert(self.Library, "必须先设置SaveManager.Library")

        local section = tab:AddSection("配置管理")

        -- 配置名称输入框
        section:AddInput("SaveManager_ConfigName",    { Title = "配置名称" })
        -- 配置列表下拉框
        section:AddDropdown("SaveManager_ConfigList", { Title = "配置列表", Values = self:RefreshConfigList(), AllowNull = true })

        -- 创建配置按钮
        section:AddButton({
            Title = "创建配置",
            Callback = function()
                local name = SaveManager.Options.SaveManager_ConfigName.Value

                if name:gsub(" ", "") == "" then 
                    return self.Library:Notify({
                        Title = "界面",
                        Content = "配置加载器",
                        SubContent = "无效的配置名称(空)",
                        Duration = 7
                    })
                end

                local success, err = self:Save(name)
                if not success then
                    return self.Library:Notify({
                        Title = "界面",
                        Content = "配置加载器",
                        SubContent = "保存配置失败: " .. err,
                        Duration = 7
                    })
                end

                self.Library:Notify({
                    Title = "界面",
                    Content = "配置加载器",
                    SubContent = string.format("已创建配置 %q", name),
                    Duration = 7
                })

                SaveManager.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
                SaveManager.Options.SaveManager_ConfigList:SetValue(nil)
            end
        })

        -- 加载配置按钮
        section:AddButton({Title = "加载配置", Callback = function()
            local name = SaveManager.Options.SaveManager_ConfigList.Value

            local success, err = self:Load(name)
            if not success then
                return self.Library:Notify({
                    Title = "界面",
                    Content = "配置加载器",
                    SubContent = "加载配置失败: " .. err,
                    Duration = 7
                })
            end

            self.Library:Notify({
                Title = "界面",
                Content = "配置加载器",
                SubContent = string.format("已加载配置 %q", name),
                Duration = 7
            })
        end})

        -- 覆盖配置按钮
        section:AddButton({Title = "覆盖配置", Callback = function()
            local name = SaveManager.Options.SaveManager_ConfigList.Value

            local success, err = self:Save(name)
            if not success then
                return self.Library:Notify({
                    Title = "界面",
                    Content = "配置加载器",
                    SubContent = "覆盖配置失败: " .. err,
                    Duration = 7
                })
            end

            self.Library:Notify({
                Title = "界面",
                Content = "配置加载器",
                SubContent = string.format("已覆盖配置 %q", name),
                Duration = 7
            })
        end})

        -- 刷新列表按钮
        section:AddButton({Title = "刷新列表", Callback = function()
            SaveManager.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
            SaveManager.Options.SaveManager_ConfigList:SetValue(nil)
        end})

        -- 设置自动加载按钮
        local AutoloadButton
        AutoloadButton = section:AddButton({
            Title = "设为自动加载",
            Description = "当前自动加载配置: 无",
            Callback = function()
                local name = SaveManager.Options.SaveManager_ConfigList.Value
                writefile(self.Folder .. "/settings/autoload.txt", name)
                AutoloadButton:SetDesc("当前自动加载配置: " .. name)
                self.Library:Notify({
                    Title = "界面",
                    Content = "配置加载器",
                    SubContent = string.format("已将 %q 设为自动加载", name),
                    Duration = 7
                })
            end
        })

        -- 显示当前自动加载配置
        if isfile(self.Folder .. "/settings/autoload.txt") then
            local name = readfile(self.Folder .. "/settings/autoload.txt")
            AutoloadButton:SetDesc("当前自动加载配置: " .. name)
        end

        -- 忽略配置管理相关的配置项
        SaveManager:SetIgnoreIndexes({ "SaveManager_ConfigList", "SaveManager_ConfigName" })
    end

    -- 初始化时创建文件夹结构
    SaveManager:BuildFolderTree()
end

return SaveManager