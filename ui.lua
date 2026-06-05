local UILib = {}

UILib.modules = {}

function UILib:CreateCategory(vape, name, icon)
    local category = vape:CreateCategory({
        Name = name,
        Icon = icon,
        Size = UDim2.fromOffset(13, 14)
    })
    return category
end

function UILib:AddToggle(category, name, callback)
    local module = category:CreateModule({
        Name = name,
        Function = callback
    })
    UILib.modules[name] = module
    return module
end

function UILib:AddSlider(category, name, min, max, default, suffix, callback)
    local slider = category:CreateSlider({
        Name = name,
        Min = min,
        Max = max,
        Default = default,
        Suffix = suffix,
        Function = callback
    })
    UILib.modules[name] = slider
    return slider
end

function UILib:AddDropdown(category, name, list, defaultValue, callback)
    local dropdown = category:CreateDropdown({
        Name = name,
        List = list,
        Value = defaultValue or list[1],
        Function = callback
    })
    UILib.modules[name] = dropdown
    return dropdown
end

function UILib:AddButton(category, name, callback)
    local button = category:CreateButton({
        Name = name,
        Function = callback
    })
    UILib.modules[name] = button
    return button
end

function UILib:AddInput(category, name, placeholder, defaultValue, callback)
    local input = category:CreateTextBox({
        Name = name,
        Placeholder = placeholder or "",
        Default = defaultValue or "",
        Function = function(enter)
            if enter and callback then
                callback(input.Value)
            end
        end
    })
    UILib.modules[name] = input
    return input
end

function UILib:AddColorPicker(category, name, defaultHue, callback)
    local color = category:CreateColorSlider({
        Name = name,
        DefaultHue = defaultHue or 0.44,
        Function = function(hue, sat, val)
            if callback then
                callback(Color3.fromHSV(hue, sat, val))
            end
        end
    })
    UILib.modules[name] = color
    return color
end

function UILib:AddTwoSlider(category, name, min, max, defaultMin, defaultMax, suffix, callback)
    local slider = category:CreateTwoSlider({
        Name = name,
        Min = min,
        Max = max,
        DefaultMin = defaultMin,
        DefaultMax = defaultMax,
        Suffix = suffix,
        Function = callback
    })
    UILib.modules[name] = slider
    return slider
end

function UILib:AddTargets(category, options)
    local targets = category:CreateTargets({
        Players = options.players or false,
        NPCs = options.npcs or false,
        Walls = options.walls or false,
        Invisible = options.invisible or false,
        Function = options.callback or function() end
    })
    return targets
end

function UILib:AddTextList(category, name, placeholder, callback)
    local list = category:CreateTextList({
        Name = name,
        Placeholder = placeholder or "添加条目...",
        Function = callback
    })
    return list
end

function UILib:AddFont(category, name, callback)
    local font = category:CreateFont({
        Name = name,
        Function = callback
    })
    return font
end

return UILib
