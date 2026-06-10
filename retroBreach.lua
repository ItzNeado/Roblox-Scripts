---------------------- Config -----------------------

_G.keyBindList = {
    ["disableRecoil"] = Enum.KeyCode.V;
    ["restoreStamina"] = Enum.KeyCode.C;
    ["infStamina"] = Enum.KeyCode.X;
    ["ESP"] = Enum.KeyCode.Z
}

getgenv().disableRecoilEnabled = false
getgenv().infStaminaEnabled = false
getgenv().ESPEnabled = false

--------------------- Service's ---------------------

local ReplicatedSotrage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

----------------------- Var's -----------------------

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local restoreStaminaEvent = ReplicatedSotrage.RemoteEvents.RestoreStamina

local highlightFolder = CoreGui:FindFirstChild("Highligt_Folder") or Instance.new("Folder", CoreGui)
local billboardFolder = CoreGui:FindFirstChild("Billboard_Folder") or Instance.new("Folder", CoreGui)

highlightFolder.Name = "Highligt_Folder"
billboardFolder.Name = "Billboard_Folder"

local colorTable = {
    Color3.fromRGB(0,200,0),
    Color3.fromRGB(230,255,25),
    Color3.fromRGB(255, 200, 25),
    Color3.fromRGB(255, 75, 20)
}

-------------------- Function's ---------------------

local function waitForCharacter(plr) -- Ожидает появление персонажа игрока и возрощает его
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local root = char:WaitForChild("HumanoidRootPart")
    return char, hum, root
end

local function createUICorner(cornerRadius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = cornerRadius
    c.Parent = parent
end

local function createUIStroke(thickness, transparency, parent)
    local s = Instance.new("UIStroke")
    s.Thickness = thickness
    s.Transparency = transparency
    s.Parent = parent
end

local function chaneDoorOpenDist(distance)
    for i, v in pairs(workspace.Systems.Doors:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.MaxActivationDistance = distance
        end
    end
end

local function disableRecoil()
    --if not getgenv().disableRecoilToggle then return end
    local char, _, _ = waitForCharacter(player)
    local targScript = char:FindFirstChild("WeaponSystem")

    for k,v in pairs(getgc()) do --перебирает сборку мусора для функций и локальных скриптов
        if type(v) == "function" and getfenv(v).script == (targScript) then --нацеливается на метод функции в пути скрипта
            if debug.getinfo(v).name == "recoil" then --нацеливается на имя нашей функции 
                hookfunction(v, function(...) end) --хуки этой функции и устанавливает ее на возврат ничего
                print("yes")
                break
            end
        end
    end
end

local function restoreStamina()
    getconnections(restoreStaminaEvent.OnClientEvent)[1]:Fire()
end

local function infStamina()
    task.spawn(function()
        while getgenv().infStaminaToggle do
            restoreStamina()
            print("update stamina")
            task.wait(10)
        end
    end)
end

local function getHealthColor(h, max) -- Возрощает цвет в зависимости от хп игрока
    if h <= max and h > max * 0.75 then
        return colorTable[1]
    elseif h <=max * 0.75 and h > max * 0.5 then
        return colorTable[2]
    elseif h <= max * 0.5 and h > max * 0.25 then
        return colorTable[3]
    elseif h <= max * 0.25 then
        return colorTable[4]
    end
end

local function applyHighlight(obj, fillColor, fillTransparency, outlineColor, outlineTransparency) -- Создаёт Highlight на выбранном объекте
    local h = highlightFolder:FindFirstChild(obj.Name) or Instance.new("Highlight", highlightFolder)
    
    h.Name = obj.Name
    h.FillColor = fillColor
    h.FillTransparency = fillTransparency
    h.OutlineColor = outlineColor
    h.OutlineTransparency = outlineTransparency
    h.Enabled = getgenv().ESPEnabled
    h.Adornee = obj
    
    if obj:IsA("Player") then
        h.Adornee = obj.Character
    end
end

local function createHPBar(plr) -- Создаёт хп-бар возле игрока
    local _, hum, root = waitForCharacter(plr)

    local HP_BAR = Instance.new("BillboardGui")
    HP_BAR.AlwaysOnTop = true
    HP_BAR.Enabled = getgenv().ESPEnabled
    HP_BAR.Name = "HP_BAR_" .. plr.Name
    HP_BAR.Size = UDim2.new(0.5, 0, 5, 0)
    HP_BAR.StudsOffset = Vector3.new(-2,0,0)
    HP_BAR.Parent = billboardFolder
    HP_BAR.Adornee = root
    
    local Frame = Instance.new("Frame")
    Frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Frame.BackgroundTransparency = 0.1
    Frame.BorderSizePixel = 0
    Frame.Rotation = 180
    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.Parent = HP_BAR
    
    createUICorner(UDim.new(0,8), Frame)
    createUIStroke(2, 0.1, Frame)
    
    local Fill = Instance.new("Frame")
    Fill.BackgroundTransparency = 0.1
    Fill.BorderSizePixel = 0
    Fill.Parent = Frame

    createUICorner(UDim.new(0, 8), Fill)

    local function updateHealth()
        local h = hum.Health
        local max = hum.MaxHealth
        Fill.Size = UDim2.new(1, 0, h/max, 0)
        Fill.BackgroundColor3 = getHealthColor(h,max)
    end

    updateHealth()
    hum.HealthChanged:Connect(updateHealth)

    plr.CharacterAdded:Connect(function()
        local _, newHum, newRoot = waitForCharacter(plr)
        hum = newHum
        HP_BAR.Adornee = newRoot

        applyHighlight(plr, plr.TeamColor.Color, 0.6, Color3.new(1, 1, 1), 0.3)
        
        updateHealth()
        hum.HealthChanged:Connect(updateHealth)
	end)
end

local function createInfoText(plr) -- Создаёт текст с информацией возле игрока
    local char, _, root = waitForCharacter(plr)

    local INFO = Instance.new("BillboardGui")
    INFO.AlwaysOnTop = true
    INFO.Enabled = getgenv().ESPEnabled
    INFO.Size = UDim2.new(5, 0, 7, 0)
    INFO.MaxDistance = 85
    INFO.Name = "INFO_TEXT_" .. plr.Name
    INFO.Parent = billboardFolder
    INFO.Adornee = root
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.LineHeight = 3
    TextLabel.TextScaled = true
    TextLabel.TextTransparency = 0.1
    TextLabel.Parent = INFO
    
    TextLabel.Text = plr.Name .. "\n\n\n\n"
    TextLabel.TextColor3 = plr.TeamColor.Color
    
    createUIStroke(1.5, 0, TextLabel)

    local function updateInfo(child)
        if child:IsA("Tool") then
            TextLabel.Text = plr.Name .. "\n\n\n\n" .. child.Name
        end
    end

    local function removeWeapon()
        TextLabel.Text = plr.Name .. "\n\n\n\n"
    end

    char.ChildAdded:Connect(updateInfo)
    char.ChildRemoved:Connect(removeWeapon)

    plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
        TextLabel.TextColor3 = plr.TeamColor.Color
        applyHighlight(plr, plr.TeamColor.Color, 0.6, Color3.new(1, 1, 1), 0.3)
	end)

    plr.CharacterAdded:Connect(function()
        local newChar, _, newRoot = waitForCharacter(plr)
        INFO.Adornee = newRoot

        newChar.ChildAdded:Connect(updateInfo)
        newChar.ChildRemoved:Connect(removeWeapon)
	end)
end

local function createBillboardText(obj, maxDistance, textColor, text)
    local Billboard = Instance.new("BillboardGui")
    Billboard.Size = UDim2.new(2, 0, 2, 0)
    Billboard.AlwaysOnTop = true
    Billboard.MaxDistance = maxDistance
    Billboard.Parent = billboardFolder
    Billboard.Adornee = obj

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 1, 0)
    t.TextScaled = true
    t.BackgroundTransparency = 1
    t.TextColor3 = textColor
    t.Parent = Billboard
    t.Text = obj.Name
end

----------------------- INIT ------------------------

local function setupPlayer(plr) -- Активирует все функции на игрока
    if plr == player then return end
    createHPBar(plr)
    createInfoText(plr)
    applyHighlight(plr, plr.TeamColor.Color, 0.6, Color3.new(1, 1, 1), 0.3)
end

for _, plr in ipairs(Players:GetPlayers()) do
    setupPlayer(plr)
end

--[[for _, obj in workspace.ItemSpawns:GetChildren() do
    if obj:IsA("Model") then
        createBillboardText(obj, 100, Color3.fromRGB(200,200,200))
    end
end]]

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Wait()
    task.wait(5)
    setupPlayer(plr)
end)

local function ESPUpdate()
    for _, obj in pairs(billboardFolder:GetChildren()) do
        obj.Enabled = getgenv().ESPEnabled
    end
    for _, obj in pairs(highlightFolder:GetChildren()) do
        obj.Enabled = getgenv().ESPEnabled
    end
end

workspace.Facility.PD.Teleports.ChildAdded:Connect(function(child)
    if child:IsA("Part") and child.Name ~= "TP" then
        child.Transparency = 0
    end
end)

for _, obj in pairs(workspace.Facility.PD.Teleports:GetChildren()) do
    if obj:IsA("Part") and obj.Name ~= "TP" then
        obj.Transparency = 0
    end
end

UIS.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Z then
        restoreStamina()
    elseif input.KeyCode == Enum.KeyCode.X then
        getgenv().infStaminaEnabled = not getgenv().infStaminaEnabled
        if getgenv().infStaminaEnabled then
            infStamina()
        end
    elseif input.KeyCode == Enum.KeyCode.C then
        getgenv().ESPEnabled = not getgenv().ESPEnabled
        ESPUpdate()
    elseif input.KeyCode == Enum.KeyCode.V then
        disableRecoil()
    end
end)

-- sex room - workspace.Facility.PD.Teleports

--[[local targScript = game:GetService("Players").LocalPlayer.Character:FindFirstChild("WeaponSystem")

local function test()
    for _, f in pairs(getgc(true)) do
        if type(f) == "function" then
            local ok_env, env = pcall(getfenv, f)
            if ok_env and env and env.script == targScript then
                local i = 1

                while true do
                    local ok, first = pcall(debug.getupvalue, f, i)
                    if not ok then break end
                    if first == nil then break end

                    local val = first
                    if type(val) == "table" then
                        for index, value in pairs(val) do
                            if index == "canFire" then
                                local k = val
                                --k.wepStats.Damage.Headshot = 10000
                                --k.wepStats.Damage.Body = 10000
                                --k.wepStats.StartDamageDropoff = 10000
                                --k.wepStats.MaxDamageDropOff = 10000
                                --k.wepStats.Spread = 0
                                --k.wepStats.MuzzleVelocity = 10000
                                --k.wepStats.BodyDamage = 10000
                                --k.wepStats.FireMode = "Auto"
                                _G.AIFJAEJF = val
                                debug.setupvalue(f, i, k)
                            end
                        end
                    end

                    i = i + 1
                end
            end
        end
    end
end

test()]]
