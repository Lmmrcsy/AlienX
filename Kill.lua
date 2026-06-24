local KillTab = _G.KillTab or error("KillTab not found in _G")
local WhitelistManager = _G.WhitelistManager or error("WhitelistManager not found in _G")

do
    local GunKillEnabled = false
    local GunKillLoop = nil
    local GunKillWhitelist = {}
    
    local gunKillWhitelistDropdown = KillTab:Dropdown({
        Title = "枪械杀戮白名单",
        Values = {},
        Multi = true,
        AllowNone = true,
        Callback = function(selected)
            GunKillWhitelist = {}
            for _, v in pairs(selected) do
                table.insert(GunKillWhitelist, WhitelistManager:GetPlayerName(v))
            end
        end
    })
    
    WhitelistManager:RegisterRefreshCallback("GunKill", function(list)
        gunKillWhitelistDropdown:Refresh(list)
    end)
    
    local function getCurrentWeapon()
        local char = game.Players.LocalPlayer.Character
        if not char then return nil end
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                return child
            end
        end
        local backpack = game.Players.LocalPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, child in ipairs(backpack:GetChildren()) do
                if child:IsA("Tool") then
                    return child
                end
            end
        end
        return nil
    end
    
    local function getSecondaryWeapon(weaponName, character)
        local weapon2 = character:FindFirstChild("S" .. weaponName)
        if not weapon2 then
            local backpack = game.Players.LocalPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                weapon2 = backpack:FindFirstChild("S" .. weaponName)
            end
        end
        return weapon2 or Instance.new("Model")
    end
    
    local function attackPlayer(targetPlayer, weapon, weapon2, settings, fireGunEvent, bulletHitEvent)
        local localPlayer = game.Players.LocalPlayer
        local targetCharacter = targetPlayer.Character
        if not targetCharacter then return false end
        
        local targetHead = targetCharacter:FindFirstChild("Head")
        if not targetHead then return false end
        
        local currentChar = localPlayer.Character
        if not currentChar then return false end
        
        local origin = currentChar.HumanoidRootPart.Position
        local targetPos = targetHead.Position
        local direction = (targetPos - origin).Unit
        
        fireGunEvent:FireServer({ direction }, weapon, weapon2, origin, false)
        
        bulletHitEvent:FireServer(
            weapon,
            targetHead,
            targetPos,
            { { origin, direction, settings.Distance }, { origin, direction, settings.Distance } },
            Vector3.xAxis,
            {
                FireRate = settings.FireRate,
                MaxSpread = settings.MaxSpread,
                Mode = settings.Mode,
                MaxRecoilPower = settings.MaxRecoilPower,
                Distance = settings.Distance,
                BSpeed = settings.BSpeed
            }
        )
        return true
    end
    
    local function startGunKillLoop()
        if GunKillLoop then return end
        
        GunKillLoop = task.spawn(function()
            local replicatedStorage = game:GetService("ReplicatedStorage")
            local players = game:GetService("Players")
            local localPlayer = players.LocalPlayer
            
            local fireGunEvent = replicatedStorage:WaitForChild("BulletFireSystem"):WaitForChild("FireGun")
            local bulletHitEvent = replicatedStorage:WaitForChild("BulletFireSystem"):WaitForChild("BulletHit")
            
            local gunConfigs = replicatedStorage:WaitForChild("Configurations"):WaitForChild("ACS_Guns")
            
            while GunKillEnabled do
                pcall(function()
                    local weapon = getCurrentWeapon()
                    if not weapon then
                        task.wait(0.1)
                        return
                    end
                    
                    local config = gunConfigs:FindFirstChild(weapon.Name)
                    if not config then
                        task.wait(0.1)
                        return
                    end
                    
                    local settings = require(config:WaitForChild("Settings"))
                    
                    local character = localPlayer.Character
                    if not character then
                        task.wait(0.1)
                        return
                    end
                    
                    local weapon2 = getSecondaryWeapon(weapon.Name, character)
                    
                    local otherPlayers = {}
                    for _, player in ipairs(players:GetPlayers()) do
                        if player ~= localPlayer and not table.find(GunKillWhitelist, player.Name) then
                            table.insert(otherPlayers, player)
                        end
                    end
                    
                    if #otherPlayers == 0 then
                        task.wait(0.1)
                        return
                    end
                    
                    for _, targetPlayer in ipairs(otherPlayers) do
                        if not GunKillEnabled then break end
                        attackPlayer(targetPlayer, weapon, weapon2, settings, fireGunEvent, bulletHitEvent)
                        task.wait(0.000000000000000000000000000000000000000000000000001)
                    end
                end)
                task.wait(0.00000000000000005)
            end
        end)
    end
    
    local function stopGunKillLoop()
        if GunKillLoop then
            task.cancel(GunKillLoop)
            GunKillLoop = nil
        end
    end
    
    KillTab:Toggle({
        Title = "枪械杀戮",
        Value = false,
        Callback = function(state)
            GunKillEnabled = state
            if state then
                startGunKillLoop()
            else
                stopGunKillLoop()
            end
        end
    })
end

do
    local ShieldAttackEnabled = false
    local ShieldAttackLoop = nil
    
    local function getClosestShield()
        local lp = game:GetService("Players").LocalPlayer
        if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then
            return nil
        end
        
        local localPos = lp.Character.HumanoidRootPart.Position
        local currentTycoon = nil
        
        local tycoons = workspace:FindFirstChild("Tycoon") and workspace.Tycoon:FindFirstChild("Tycoons")
        if tycoons then
            for _, tycoon in ipairs(tycoons:GetChildren()) do
                local owner = tycoon:FindFirstChild("Owner")
                if owner and owner.Value == lp.Name then
                    currentTycoon = tycoon.Name
                    break
                end
            end
        end
        
        local closestShield = nil
        local shortestDistance = math.huge
        
        if not tycoons then return nil end
        
        for _, tycoon in ipairs(tycoons:GetChildren()) do
            if tycoon.Name == currentTycoon then continue end
            
            local owner = tycoon:FindFirstChild("Owner")
            if owner and owner.Value ~= lp.Name then
                local shield = tycoon:FindFirstChild("PurchasedObjects") and tycoon.PurchasedObjects:FindFirstChild("Base Shield")
                if shield then
                    local shieldPart = shield:FindFirstChild("Shield") and shield.Shield:FindFirstChildWhichIsA("BasePart")
                    if shieldPart then
                        local distance = (localPos - shieldPart.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestShield = shieldPart
                        end
                    end
                end
            end
        end
        
        return closestShield
    end
    
    local function getCurrentWeaponForShield()
        local char = game.Players.LocalPlayer.Character
        if not char then return nil end
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                return child
            end
        end
        local backpack = game.Players.LocalPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, child in ipairs(backpack:GetChildren()) do
                if child:IsA("Tool") then
                    return child
                end
            end
        end
        return nil
    end
    
    local function getSecondaryWeaponForShield(weaponName, character)
        local weapon2 = character:FindFirstChild("S" .. weaponName)
        if not weapon2 then
            local backpack = game.Players.LocalPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                weapon2 = backpack:FindFirstChild("S" .. weaponName)
            end
        end
        return weapon2 or Instance.new("Model")
    end
    
    local function startShieldAttackLoop()
        if ShieldAttackLoop then return end
        
        ShieldAttackLoop = task.spawn(function()
            local replicatedStorage = game:GetService("ReplicatedStorage")
            local players = game:GetService("Players")
            local localPlayer = players.LocalPlayer
            
            local fireGunEvent = replicatedStorage:WaitForChild("BulletFireSystem"):WaitForChild("FireGun")
            local bulletHitEvent = replicatedStorage:WaitForChild("BulletFireSystem"):WaitForChild("BulletHit")
            local gunConfigs = replicatedStorage:WaitForChild("Configurations"):WaitForChild("ACS_Guns")
            
            while ShieldAttackEnabled do
                pcall(function()
                    local shield = getClosestShield()
                    if not shield then
                        task.wait(0.1)
                        return
                    end
                    
                    local weapon = getCurrentWeaponForShield()
                    if not weapon then
                        task.wait(0.1)
                        return
                    end
                    
                    local config = gunConfigs:FindFirstChild(weapon.Name)
                    if not config then
                        task.wait(0.1)
                        return
                    end
                    
                    local settings = require(config:WaitForChild("Settings"))
                    
                    local character = localPlayer.Character
                    if not character then
                        task.wait(0.1)
                        return
                    end
                    
                    local weapon2 = getSecondaryWeaponForShield(weapon.Name, character)
                    local origin = character.HumanoidRootPart.Position
                    local targetPos = shield.Position
                    local direction = (targetPos - origin).Unit
                    
                    fireGunEvent:FireServer({ direction }, weapon, weapon2, origin, false)
                    
                    bulletHitEvent:FireServer(
                        weapon,
                        shield,
                        targetPos,
                        { { origin, direction, settings.Distance }, { origin, direction, settings.Distance } },
                        Vector3.xAxis,
                        {
                            FireRate = settings.FireRate,
                            MaxSpread = settings.MaxSpread,
                            Mode = settings.Mode,
                            MaxRecoilPower = settings.MaxRecoilPower,
                            Distance = settings.Distance,
                            BSpeed = settings.BSpeed
                        }
                    )
                end)
                task.wait(0.000000000000000000000000000000000000000000000000000000000000005)
            end
        end)
    end
    
    local function stopShieldAttackLoop()
        if ShieldAttackLoop then
            task.cancel(ShieldAttackLoop)
            ShieldAttackLoop = nil
        end
    end
    
    KillTab:Toggle({
        Title = "护盾攻击",
        Value = false,
        Callback = function(state)
            ShieldAttackEnabled = state
            if state then
                startShieldAttackLoop()
            else
                stopShieldAttackLoop()
            end
        end
    })
end

do
    local AntiAirWhitelist = {}
    local antiAirEnabled = false
    local antiAirLoop = nil
    local shieldAttackEnabled = false
    local shieldLoop = nil

    local antiAirWhitelistDropdown = KillTab:Dropdown({
        Title = "防空杀戮白名单",
        Values = {},
        Multi = true,
        AllowNone = true,
        Callback = function(selected)
            AntiAirWhitelist = {}
            for _, v in pairs(selected) do
                table.insert(AntiAirWhitelist, WhitelistManager:GetPlayerName(v))
            end
        end
    })

    WhitelistManager:RegisterRefreshCallback("AntiAir", function(list)
        antiAirWhitelistDropdown:Refresh(list)
    end)

    local function getClosestShield()
        local lp = game:GetService("Players").LocalPlayer
        if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then
            return nil
        end
        local localPos = lp.Character.HumanoidRootPart.Position
        local currentTycoon = nil
        local tycoons = workspace:FindFirstChild("Tycoon") and workspace.Tycoon:FindFirstChild("Tycoons")
        if tycoons then
            for _, tycoon in ipairs(tycoons:GetChildren()) do
                local owner = tycoon:FindFirstChild("Owner")
                if owner and owner.Value == lp.Name then
                    currentTycoon = tycoon.Name
                    break
                end
            end
        end
        local closestShield = nil
        local shortestDistance = math.huge
        if not tycoons then return nil end
        for _, tycoon in ipairs(tycoons:GetChildren()) do
            if tycoon.Name == currentTycoon then continue end
            local owner = tycoon:FindFirstChild("Owner")
            if owner and owner.Value ~= lp.Name then
                local shield = tycoon:FindFirstChild("PurchasedObjects") and tycoon.PurchasedObjects:FindFirstChild("Base Shield")
                if shield then
                    local shieldPart = shield:FindFirstChild("Shield") and shield.Shield:FindFirstChildWhichIsA("BasePart")
                    if shieldPart then
                        local distance = (localPos - shieldPart.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestShield = shieldPart
                        end
                    end
                end
            end
        end
        return closestShield
    end

    local function getPlayerCRAM()
        local tycoons = workspace:FindFirstChild("Tycoon") and workspace.Tycoon:FindFirstChild("Tycoons")
        if not tycoons then return nil end
        local teamName = game.Players.LocalPlayer.Team and game.Players.LocalPlayer.Team.Name
        if not teamName then return nil end
        local tycoon = tycoons:FindFirstChild(teamName)
        if not tycoon then return nil end
        local purchased = tycoon:FindFirstChild("PurchasedObjects")
        if not purchased then return nil end
        local cram = purchased:FindFirstChild("CRAM")
        if not cram then return nil end
        local cramModel = cram:FindFirstChild("CRAM")
        if not cramModel then return nil end
        local smokePart = cramModel:FindFirstChild("SmokePart")
        if not smokePart then return nil end
        return { cram = cram, cramModel = cramModel, smokePart = smokePart }
    end

    local function getCramSettings(cramData)
        if not cramData then return nil end
        local settingsModule = cramData.cramModel:FindFirstChild("Settings")
        if settingsModule and settingsModule:IsA("ModuleScript") then
            local success, settings = pcall(require, settingsModule)
            if success then return settings end
        end
        return { FireRate = 1000, CooldownTime = 4, BulletSpread = 0.8, OverheatCount = 150 }
    end

    local function attackShield()
        local shield = getClosestShield()
        if not shield then return end
        local cramData = getPlayerCRAM()
        if not cramData then return end
        local settings = getCramSettings(cramData)
        if not settings then settings = { FireRate = 1000, CooldownTime = 4, BulletSpread = 0.8, OverheatCount = 150 } end
        local smokePart = cramData.smokePart
        if not smokePart or not smokePart.Parent then return end
        local origin = smokePart.Position
        local targetPos = shield.Position
        local direction = (targetPos - origin).Unit
        local normal = Vector3.new(-direction.Z, 0, direction.X).Unit
        if normal.Magnitude < 0.000000000000000000000000001 then normal = Vector3.new(0, 1, 0) end
        local registerTurretHit = game:GetService("ReplicatedStorage"):FindFirstChild("BulletFireSystem") and game:GetService("ReplicatedStorage").BulletFireSystem:FindFirstChild("RegisterTurretHit")
        if registerTurretHit then
            pcall(function()
                registerTurretHit:FireServer(
                    cramData.cramModel,
                    smokePart,
                    cramData.cram,
                    {
                        normal = normal,
                        hitPart = shield,
                        origin = origin,
                        hitPoint = targetPos,
                        direction = direction
                    },
                    settings
                )
            end)
        end
    end

    local function getEnemyTargets()
        local targets = {}
        local myTeam = game.Players.LocalPlayer.Team
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game.Players.LocalPlayer and not table.find(AntiAirWhitelist, player.Name) then
                local char = player.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if hrp and humanoid and humanoid.Health > 0 then
                        local targetTeam = player.Team
                        if myTeam and targetTeam and myTeam ~= targetTeam then
                            table.insert(targets, { hrp = hrp, position = hrp.Position })
                        end
                    end
                end
            end
        end
        return targets
    end

    local function attackTarget(cramData, target, settings)
        if not cramData or not target then return end
        local smokePart = cramData.smokePart
        if not smokePart or not smokePart.Parent then return end
        local origin = smokePart.Position
        local targetPos = target.position
        local direction = (targetPos - origin).Unit
        local normal = Vector3.new(-direction.Z, 0, direction.X).Unit
        if normal.Magnitude < 0.001 then normal = Vector3.new(0, 1, 0) end
        local registerTurretHit = game:GetService("ReplicatedStorage"):FindFirstChild("BulletFireSystem") and game:GetService("ReplicatedStorage").BulletFireSystem:FindFirstChild("RegisterTurretHit")
        if registerTurretHit then
            pcall(function()
                registerTurretHit:FireServer(
                    cramData.cramModel,
                    smokePart,
                    cramData.cram,
                    {
                        normal = normal,
                        hitPart = target.hrp,
                        origin = origin,
                        hitPoint = targetPos,
                        direction = direction
                    },
                    settings
                )
            end)
        end
    end

    local function startShieldLoop()
        if shieldLoop then return end
        shieldLoop = task.spawn(function()
            while shieldAttackEnabled do
                attackShield()
                task.wait(0.0000000000000000000001)
            end
        end)
    end

    local function stopShieldLoop()
        if shieldLoop then
            task.cancel(shieldLoop)
            shieldLoop = nil
        end
    end

    local function startAntiAirLoop()
        if antiAirLoop then return end
        antiAirLoop = task.spawn(function()
            local cramData = getPlayerCRAM()
            if not cramData then return end
            local settings = getCramSettings(cramData)
            if not settings then settings = { FireRate = 1000, CooldownTime = 4, BulletSpread = 0.8, OverheatCount = 150 } end
            while antiAirEnabled do
                local targets = getEnemyTargets()
                if #targets > 0 then
                    for _, target in ipairs(targets) do
                        attackTarget(cramData, target, settings)
                    end
                end
                task.wait(0.0000000000000000000000000000001)
            end
        end)
    end

    local function stopAntiAirLoop()
        if antiAirLoop then
            task.cancel(antiAirLoop)
            antiAirLoop = nil
        end
    end

    KillTab:Toggle({
        Title = "防空杀戮",
        Value = false,
        Callback = function(state)
            antiAirEnabled = state
            if state then
                startAntiAirLoop()
            else
                stopAntiAirLoop()
            end
        end
    })

    KillTab:Toggle({
        Title = "护盾攻击(CRAM)",
        Value = false,
        Callback = function(state)
            shieldAttackEnabled = state
            if state then
                startShieldLoop()
            else
                stopShieldLoop()
            end
        end
    })
end

do
    local vehicleKillEnabled = false
    local vehicleKillLastAttack = 0
    local vehicleKillInterval = 0.001
    local vehicleKillLoop = nil
    local vehicleKillWhitelist = {}
    local attackShieldsEnabled = false

    local vehicleKillWhitelistDropdown = KillTab:Dropdown({
        Title = "悍马杀戮白名单",
        Values = {},
        Multi = true,
        AllowNone = true,
        Callback = function(selected)
            vehicleKillWhitelist = {}
            for _, v in pairs(selected) do
                table.insert(vehicleKillWhitelist, WhitelistManager:GetPlayerName(v))
            end
        end
    })

    WhitelistManager:RegisterRefreshCallback("VehicleKill", function(list)
        vehicleKillWhitelistDropdown:Refresh(list)
    end)

    local function getVehicleTargets()
        local lp = game:GetService("Players").LocalPlayer
        local targets = {}
        
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player == lp then continue end
            if table.find(vehicleKillWhitelist, player.Name) then continue end
            
            local character = player.Character
            if not character then continue end
            
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            
            table.insert(targets, {
                player = player,
                position = hrp.Position,
                hrp = hrp
            })
        end
        
        return targets
    end

    local function getClosestShield()
        local lp = game:GetService("Players").LocalPlayer
        if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then
            return nil
        end
        
        local localPos = lp.Character.HumanoidRootPart.Position
        local currentTycoon = nil
        
        local tycoons = workspace:FindFirstChild("Tycoon") and workspace.Tycoon:FindFirstChild("Tycoons")
        if tycoons then
            for _, tycoon in ipairs(tycoons:GetChildren()) do
                local owner = tycoon:FindFirstChild("Owner")
                if owner and owner.Value == lp.Name then
                    currentTycoon = tycoon.Name
                    break
                end
            end
        end
        
        local closestShield = nil
        local shortestDistance = math.huge
        
        if not tycoons then return nil end
        
        for _, tycoon in ipairs(tycoons:GetChildren()) do
            if tycoon.Name == currentTycoon then continue end
            
            local owner = tycoon:FindFirstChild("Owner")
            if owner and owner.Value ~= lp.Name then
                local shield = tycoon:FindFirstChild("PurchasedObjects") and tycoon.PurchasedObjects:FindFirstChild("Base Shield")
                if shield then
                    local shieldPart = shield:FindFirstChild("Shield") and shield.Shield:FindFirstChildWhichIsA("BasePart")
                    if shieldPart then
                        local distance = (localPos - shieldPart.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestShield = shieldPart
                        end
                    end
                end
            end
        end
        
        return closestShield
    end

    local function fireVehicleTurret(target)
        local vehicleWorkspace = workspace:FindFirstChild("Game Systems") and workspace["Game Systems"]:FindFirstChild("Vehicle Workspace")
        if not vehicleWorkspace then return end
        
        local vehicle = vehicleWorkspace:FindFirstChild("Humvee TOW-II")
        if not vehicle then return end
        
        local misc = vehicle:FindFirstChild("Misc")
        if not misc then return end
        
        local turrets = misc:FindFirstChild("Turrets")
        if not turrets then return end
        
        local turret = turrets:FindFirstChild("Humvee TOW Weapons")
        if not turret then return end
        
        local midTurret = turret:FindFirstChild("Mid Turret")
        if not midTurret then return end
        
        local smokePart = midTurret:FindFirstChild("SmokePart")
        if not smokePart then return end
        
        local targetPos = target.position
        local originPos = smokePart.Position
        local direction = (targetPos - originPos).Unit
        
        local normal = Vector3.new(-direction.Z, 0, direction.X).Unit
        if normal.Magnitude < 0.001 then
            normal = Vector3.new(0, 1, 0)
        end
        
        local args = {
            midTurret,
            smokePart,
            vehicle,
            {
                normal = normal,
                hitPart = target.hrp,
                origin = originPos,
                hitPoint = targetPos,
                direction = direction
            },
            {
                FireRate = 600,
                CooldownTime = 3.5,
                BulletSpread = 0,
                OverheatCount = 70
            }
        }
        
        local bulletSystem = game:GetService("ReplicatedStorage"):FindFirstChild("BulletFireSystem")
        if not bulletSystem then return end
        
        local registerTurretHit = bulletSystem:FindFirstChild("RegisterTurretHit")
        if not registerTurretHit then return end
        
        pcall(function()
            registerTurretHit:FireServer(unpack(args))
        end)
    end

    local function fireVehicleTurretAtShield(shield)
        local vehicleWorkspace = workspace:FindFirstChild("Game Systems") and workspace["Game Systems"]:FindFirstChild("Vehicle Workspace")
        if not vehicleWorkspace then return end
        
        local vehicle = vehicleWorkspace:FindFirstChild("Humvee TOW-II")
        if not vehicle then return end
        
        local misc = vehicle:FindFirstChild("Misc")
        if not misc then return end
        
        local turrets = misc:FindFirstChild("Turrets")
        if not turrets then return end
        
        local turret = turrets:FindFirstChild("Humvee TOW Weapons")
        if not turret then return end
        
        local midTurret = turret:FindFirstChild("Mid Turret")
        if not midTurret then return end
        
        local smokePart = midTurret:FindFirstChild("SmokePart")
        if not smokePart then return end
        
        local targetPos = shield.Position
        local originPos = smokePart.Position
        local direction = (targetPos - originPos).Unit
        
        local normal = Vector3.new(-direction.Z, 0, direction.X).Unit
        if normal.Magnitude < 0.001 then
            normal = Vector3.new(0, 1, 0)
        end
        
        local args = {
            midTurret,
            smokePart,
            vehicle,
            {
                normal = normal,
                hitPart = shield,
                origin = originPos,
                hitPoint = targetPos,
                direction = direction
            },
            {
                FireRate = 600,
                CooldownTime = 3.5,
                BulletSpread = 0,
                OverheatCount = 70
            }
        }
        
        local bulletSystem = game:GetService("ReplicatedStorage"):FindFirstChild("BulletFireSystem")
        if not bulletSystem then return end
        
        local registerTurretHit = bulletSystem:FindFirstChild("RegisterTurretHit")
        if not registerTurretHit then return end
        
        pcall(function()
            registerTurretHit:FireServer(unpack(args))
        end)
    end

    local function vehicleKillMainLoop()
        while vehicleKillEnabled do
            local now = tick()
            
            if now - vehicleKillLastAttack >= vehicleKillInterval then
                local targets = getVehicleTargets()
                for _, target in ipairs(targets) do
                    task.spawn(function()
                        fireVehicleTurret(target)
                    end)
                end
                
                if attackShieldsEnabled then
                    local shield = getClosestShield()
                    if shield then
                        for i = 1, 99 do
                            task.spawn(function()
                                fireVehicleTurretAtShield(shield)
                            end)
                        end
                    end
                end
                
                vehicleKillLastAttack = now
            end
            
            task.wait(0.001)
        end
    end

    KillTab:Toggle({
        Title = "悍马杀戮",
        Value = false,
        Callback = function(state)
            vehicleKillEnabled = state
            
            if state then
                if vehicleKillLoop then
                    task.cancel(vehicleKillLoop)
                    vehicleKillLoop = nil
                end
                vehicleKillLoop = task.spawn(vehicleKillMainLoop)
            else
                if vehicleKillLoop then
                    task.cancel(vehicleKillLoop)
                    vehicleKillLoop = nil
                end
            end
        end
    })

    KillTab:Toggle({
        Title = "攻击护盾",
        Value = false,
        Callback = function(state)
            attackShieldsEnabled = state
        end
    })
end

do
    local rpgBombingEnabled = false
    local shieldAttackActive = false
    local ignoreShieldPlayers = false
    local rpgBombingWhitelist = {}
    local lastRpgFire = 0
    local heartbeatConnection = nil
    local baseBombingEnabled = false
    local currentTycoonName = nil

    local rpgWhitelistDropdown = KillTab:Dropdown({
        Title = "RPG白名单",
        Values = {},
        Multi = true,
        AllowNone = true,
        Callback = function(selected)
            rpgBombingWhitelist = {}
            for _, v in pairs(selected) do
                table.insert(rpgBombingWhitelist, WhitelistManager:GetPlayerName(v))
            end
        end
    })

    WhitelistManager:RegisterRefreshCallback("RPGBombing", function(list)
        rpgWhitelistDropdown:Refresh(list)
    end)

    local function hasShield(player)
        if not ignoreShieldPlayers then return false end
        local char = player.Character
        if not char then return false end
        local shieldNames = {"SpawnShield", "BaseShieldForceField", "StarterShield_ForceField"}
        for _, name in ipairs(shieldNames) do
            if char:FindFirstChild(name) then return true end
        end
        return false
    end

    local function getCurrentTycoonName()
        local lp = game:GetService("Players").LocalPlayer
        local tycoons = workspace:FindFirstChild("Tycoon") and workspace.Tycoon:FindFirstChild("Tycoons")
        if not tycoons then return nil end
        for _, tycoon in ipairs(tycoons:GetChildren()) do
            local owner = tycoon:FindFirstChild("Owner")
            if owner and owner.Value == lp.Name then
                return tycoon.Name
            end
        end
        return nil
    end

    local function getClosestShield()
        local lp = game:GetService("Players").LocalPlayer
        if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then
            return nil
        end
        
        local localPos = lp.Character.HumanoidRootPart.Position
        local currentTycoon = getCurrentTycoonName()
        local closestShield = nil
        local shortestDistance = math.huge
        
        local tycoons = workspace:FindFirstChild("Tycoon") and workspace.Tycoon:FindFirstChild("Tycoons")
        if not tycoons then return nil end
        
        for _, tycoon in ipairs(tycoons:GetChildren()) do
            if tycoon.Name == currentTycoon then continue end
            
            local owner = tycoon:FindFirstChild("Owner")
            if owner and owner.Value ~= lp.Name then
                local shield = tycoon:FindFirstChild("PurchasedObjects") and tycoon.PurchasedObjects:FindFirstChild("Base Shield")
                if shield then
                    local shieldPart = shield:FindFirstChild("Shield") and shield.Shield:FindFirstChildWhichIsA("BasePart")
                    if shieldPart then
                        local distance = (localPos - shieldPart.Position).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestShield = shieldPart
                        end
                    end
                end
            end
        end
        
        return closestShield
    end

    local function fireRocket(targetPlayer)
        local lp = game:GetService("Players").LocalPlayer
        local character = lp.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local rpg = lp.Backpack:FindFirstChild("RPG") or (character and character:FindFirstChild("RPG"))
        
        if not character or not hrp or not rpg then return end
        if not targetPlayer or not targetPlayer.Character then return end
        
        local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetHrp then return end
        
        local rs = game:GetService("ReplicatedStorage")
        local rocketEvent = rs:FindFirstChild("RocketSystem") and rs.RocketSystem:FindFirstChild("Events") and rs.RocketSystem.Events:FindFirstChild("RocketHit")
        if not rocketEvent then return end
        
        local args = {{
            Normal = Vector3.yAxis,
            Player = targetPlayer,
            HitPart = targetHrp,
            Origin = hrp.Position,
            Label = targetPlayer.Name .. "Rocket1",
            Vehicle = rpg,
            Position = targetHrp.Position,
            Weapon = rpg
        }}
        
        pcall(function()
            rocketEvent:FireServer(unpack(args))
        end)
        
        lastRpgFire = os.clock()
    end

    KillTab:Toggle({
        Title = "RPG轰炸(全员)",
        Callback = function(state)
            rpgBombingEnabled = state
            
            if state then
                task.spawn(function()
                    while rpgBombingEnabled do
                        local lp = game:GetService("Players").LocalPlayer
                        local players = game:GetService("Players"):GetPlayers()
                        
                        for _, targetPlayer in ipairs(players) do
                            if targetPlayer == lp then continue end
                            if table.find(rpgBombingWhitelist, targetPlayer.Name) then continue end
                            if hasShield(targetPlayer) then continue end
                            
                            local character = targetPlayer.Character
                            if not character then continue end
                            
                            local humanoid = character:FindFirstChildOfClass("Humanoid")
                            if not humanoid or humanoid.Health <= 0 then continue end
                            
                            fireRocket(targetPlayer)
                            task.wait(0.05)
                        end
                        
                        task.wait(0.0000000000000000000000000000000000000000000001)
                    end
                end)
            end
        end
    })

    KillTab:Toggle({
        Title = "护盾攻击(RPG)",
        Callback = function(state)
            shieldAttackActive = state
            
            if state and not rpgBombingEnabled then
                task.spawn(function()
                    while shieldAttackActive and not rpgBombingEnabled do
                        local shield = getClosestShield()
                        if shield then
                            local lp = game:GetService("Players").LocalPlayer
                            local character = lp.Character
                            local hrp = character and character:FindFirstChild("HumanoidRootPart")
                            local rpg = lp.Backpack:FindFirstChild("RPG") or (character and character:FindFirstChild("RPG"))
                            
                            if hrp and rpg then
                                local rs = game:GetService("ReplicatedStorage")
                                local rocketEvent = rs:FindFirstChild("RocketSystem") and rs.RocketSystem:FindFirstChild("Events") and rs.RocketSystem.Events:FindFirstChild("RocketHit")
                                if rocketEvent then
                                    local args = {{
                                        Normal = Vector3.yAxis,
                                        Player = lp,
                                        HitPart = shield,
                                        Origin = hrp.Position,
                                        Label = "ShieldRocket",
                                        Vehicle = rpg,
                                        Position = shield.Position,
                                        Weapon = rpg
                                    }}
                                    pcall(function()
                                        rocketEvent:FireServer(unpack(args))
                                    end)
                                end
                            end
                        end
                        task.wait(0.00000000000000000000000000000000000000000001)
                    end
                end)
            end
        end
    })
end
