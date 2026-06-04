local Services = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Lmmrcsy/AlienX/refs/heads/main/Services.lua"
))()

local State = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Lmmrcsy/AlienX/refs/heads/main/State.lua"
))()

local Crate = {}
local failedCrates = {}

-- 获取所有箱子
function Crate.GetAll()
    local crates = {}
    local ws = Services.Workspace

    local collectibles = ws:FindFirstChild("Game Systems")
        and ws["Game Systems"]:FindFirstChild("Collectibles Workspace")

    if not collectibles then return crates end

    local folder = collectibles:FindFirstChild("PartCrate")
    if not folder then return crates end

    for _, m in ipairs(folder:GetChildren()) do
        if m:IsA("Model") then
            table.insert(crates, m)
        end
    end

    return crates
end

-- 获取箱子位置
function Crate.GetPosition(crate)
    local mp = crate:FindFirstChild("MainPart")
    return mp and mp.CFrame or crate:GetPivot()
end

-- 判断是否在移动
function Crate.IsMoving(crate)
    local mp = crate:FindFirstChild("MainPart")
    return mp and mp.AssemblyLinearVelocity.Magnitude > 0.5
end

-- 寻找最佳箱子（视角优先）
function Crate.FindBest()
    local lp = Services.LocalPlayer
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local cam = Services.Camera
    local camDir = cam.CFrame.LookVector

    local best, bestAngle

    for _, crate in ipairs(Crate.GetAll()) do
        if not failedCrates[crate] and not Crate.IsMoving(crate) then
            local pos = Crate.GetPosition(crate).Position
            local dir = (pos - hrp.Position).Unit
            local angle = math.acos(math.clamp(camDir:Dot(dir), -1, 1))

            if not best or angle < bestAngle then
                best, bestAngle = crate, angle
            end
        end
    end

    return best
end

-- 自动循环（只启动一次）
task.spawn(function()
    while true do
        if State.Auto.Crate then
            local crate = Crate.FindBest()
            if not crate then
                task.wait(0.3)
                continue
            end

            -- 这里只放占位，后面你可以接完整拾取逻辑
            print("[Crate] Target:", crate.Name)
        end

        task.wait(0.3)
    end
end)

return Crate