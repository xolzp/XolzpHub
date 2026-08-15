-- XolzpHub: The Lost Front for Xeno (Aimbot & Triggerbot Fixed)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Config = {
    ESP_Enabled = true,
    ESP_Boxes = true,
    ESP_Names = true,
    ESP_Distance = true,
    ESP_Skeleton = true,
    ESP_Health = true,
    ESP_TeamCheck = true,
    ESP_MaxDist = 2000,
    ESP_AimDir = true,
    ESP_LookingAtYou = true,
    ESP_Tracers = false,
    ESP_FPV = false,
    
    RADAR_Enabled = true,
    RADAR_Size = 120,
    
    AIM_Enabled = false,
    AIM_FOV = 150,
    AIM_Smooth = 15,
    AIM_ShowFOV = true,
    AIM_TeamCheck = true,
    AIM_FPV = false,
    
    DESYNC_Enabled = false,
    DESYNC_Amount = 2,
    
    TRIGGER_Enabled = false,
    TRIGGER_Delay = 50,
    TRIGGER_TeamCheck = true,
    
    MENU_Open = false,
    MENU_Tab = 1
}

local Tuning = {
    TargetRefreshRate = 0.3,
    VisibilityRefreshRate = 0.2,
    TeamRefreshRate = 3.0,
    FPVRefreshRate = 2.0,
    BoxWidthRatio = 0.6,
    HealthBarWidth = 4,
    HealthBarOffset = 6,
    NameOffset = 18,
    DistOffset = 4,
    AimLineLength = 15,
    LookingThreshold = 0.85,
    FPVClusterDist = 100,
    RadarRange = 150,
    RadarDotSize = 6,
    TriggerRadius = 50
}

-- [ BLACK & WHITE COSMIC PALETTE ] --
local Palette = {
    Enemy = Color3.fromRGB(200, 200, 200),
    EnemyVisible = Color3.fromRGB(255, 255, 255),
    Team = Color3.fromRGB(80, 80, 80),
    Skeleton = Color3.fromRGB(150, 150, 150),
    SkeletonVisible = Color3.fromRGB(255, 255, 255),
    LookingAtYou = Color3.fromRGB(255, 255, 255),
    AimDir = Color3.fromRGB(180, 180, 180),
    FPV = Color3.fromRGB(255, 255, 255),
    Tracer = Color3.fromRGB(100, 100, 100),
    HealthHigh = Color3.fromRGB(255, 255, 255),
    HealthMid = Color3.fromRGB(150, 150, 150),
    HealthLow = Color3.fromRGB(80, 80, 80),
    HealthBg = Color3.fromRGB(10, 10, 10),
    
    MenuBg = Color3.fromRGB(12, 12, 14),
    MenuPanel = Color3.fromRGB(20, 20, 23),
    MenuBorder = Color3.fromRGB(255, 255, 255),
    MenuAccent = Color3.fromRGB(255, 255, 255),
    MenuText = Color3.fromRGB(240, 240, 240),
    MenuTextDim = Color3.fromRGB(130, 130, 140),
    MenuOn = Color3.fromRGB(255, 255, 255),
    MenuOff = Color3.fromRGB(35, 35, 40),
    MenuTab = Color3.fromRGB(15, 15, 18),
    
    FOV_Circle = Color3.fromRGB(150, 150, 150),
    FOV_Active = Color3.fromRGB(255, 255, 255)
}

local Cache = { targets = {}, humanoids = {}, teamStatus = {}, visibility = {}, lookingAtYou = {}, drones = {}, names = {}, myRoot = nil }
local Bones = {{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
local Connections = {}
local Unloaded = false

local UI = {}
UI.ScreenGui = Instance.new("ScreenGui")
UI.ScreenGui.Name = "XolzpHubUI"
UI.ScreenGui.ResetOnSpawn = false
UI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UI.ScreenGui.DisplayOrder = 999
UI.ScreenGui.IgnoreGuiInset = true

pcall(function() UI.ScreenGui.Parent = game:GetService("CoreGui") end)
if not UI.ScreenGui.Parent then UI.ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Team = {}
function Team.isTeammate(char)
    if not LocalPlayer.Character then return false end
    if not char or not char.Parent then return false end
    return LocalPlayer.Character.Parent == char.Parent
end
function Team.isSpectator(char)
    if not char or not char.Parent then return true end
    local pName = char.Parent.Name:lower()
    return pName:find("spectator") or pName:find("dead") or pName:find("observer")
end

local Util = {}
function Util.isVisible(character)
    if not character then return false end
    local cam = Workspace.CurrentCamera
    if not cam then return false end
    local origin = cam.CFrame.Position
    local parts = {"Head", "Torso", "HumanoidRootPart"}
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local filter = {cam}
    if LocalPlayer.Character then table.insert(filter, LocalPlayer.Character) end
    table.insert(filter, character)
    rayParams.FilterDescendantsInstances = filter
    for _, partName in pairs(parts) do
        local part = character:FindFirstChild(partName)
        if part then
            local dir = (part.Position - origin)
            local result = Workspace:Raycast(origin, dir.Unit * dir.Magnitude, rayParams)
            if not result or (result.Position - part.Position).Magnitude < 5 then return true end
        end
    end
    return false
end

function Util.isLookingAtYou(char)
    if not LocalPlayer.Character then return false end
    local myHead = LocalPlayer.Character:FindFirstChild("Head")
    local head = char:FindFirstChild("Head")
    if not myHead or not head then return false end
    local toYou = (myHead.Position - head.Position).Unit
    return toYou:Dot(head.CFrame.LookVector) > Tuning.LookingThreshold
end

function Util.getName(char)
    if Cache.names[char] then return Cache.names[char] end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character == char then
            Cache.names[char] = p.Name
            return p.Name
        end
    end
    local name = (not char.Name:match("^[Il]+")) and char.Name or "Entity"
    Cache.names[char] = name
    return name
end

local Targets = {}
function Targets.refresh()
    local new, newTeam, newNames, newHum = {}, {}, {}, {}
    local myChar = LocalPlayer.Character
    Cache.myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            if Team.isSpectator(char) then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 and root.Position.Y > -50 then
                new[root] = char
                newHum[root] = hum
                newTeam[root] = Team.isTeammate(char)
                if Cache.names[char] then newNames[char] = Cache.names[char] end
            end
        end
    end
    Cache.targets = new; Cache.humanoids = newHum; Cache.teamStatus = newTeam; Cache.names = newNames
end

function Targets.refreshVisibility()
    for root, char in pairs(Cache.targets) do
        local vis = Util.isVisible(char)
        Cache.visibility[root] = vis
        Cache.lookingAtYou[root] = vis and Util.isLookingAtYou(char) or false
    end
end

task.spawn(function()
    while not Unloaded do Targets.refresh(); task.wait(Tuning.TargetRefreshRate) end
end)
task.spawn(function()
    while not Unloaded do Targets.refreshVisibility(); task.wait(Tuning.VisibilityRefreshRate) end
end)

local FPV = { cache = {}, partNames = {"Blade_BL", "Blade_BR", "Blade_FL", "Blade_FR", "Explosive", "Explosive1", "Rotator_BL", "Rotator_BR", "Rotator_FL", "Rotator_FR", "FPV"} }
local fpvNameSet = {}
for _, n in ipairs(FPV.partNames) do fpvNameSet[n] = true end

function FPV.Scan()
    if not Config.ESP_FPV then return Cache.drones or {} end
    local drones, seen, count, iter = {}, {}, 0, 0
    local camRef = Workspace.CurrentCamera
    local plrs = Players:GetPlayers()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        iter = iter + 1
        if iter % 1000 == 0 then task.wait() end
        if count >= 10 then break end
        if obj:IsA("BasePart") and fpvNameSet[obj.Name] then
            local model = obj.Parent
            if model and model:IsA("Model") and not seen[model] then
                local skip = false
                if camRef and model:IsDescendantOf(camRef) then skip = true end
                if not skip then
                    for i = 1, #plrs do
                        if plrs[i].Character and model:IsDescendantOf(plrs[i].Character) then skip = true; break end
                    end
                end
                if not skip then
                    seen[model] = true
                    local center = model:FindFirstChild("Explosive") or model:FindFirstChild("FPV") or obj
                    drones[model] = center
                    count = count + 1
                end
            end
        end
    end
    return drones
end

task.spawn(function()
    while not Unloaded do if Config.ESP_FPV then Cache.drones = FPV.Scan() end; task.wait(Tuning.FPVRefreshRate) end
end)

function FPV.Create(drone)
    if FPV.cache[drone] then return end
    local box = Instance.new("Frame")
    box.BackgroundTransparency = 1; box.BorderSizePixel = 0; box.Visible = false; box.Parent = UI.ScreenGui
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Thickness = 1; boxStroke.Color = Palette.FPV; boxStroke.Parent = box
    local name = Instance.new("TextLabel")
    name.BackgroundTransparency = 1; name.Font = Enum.Font.RobotoMono; name.TextSize = 13
    name.TextColor3 = Palette.FPV; name.Text = "DRONE"; name.Size = UDim2.new(0, 150, 0, 16)
    name.TextXAlignment = Enum.TextXAlignment.Center; name.Visible = false; name.Parent = UI.ScreenGui
    FPV.cache[drone] = {Box = box, BoxStroke = boxStroke, Name = name}
end

function FPV.Hide(esp)
    if not esp then return end
    esp.Box.Visible = false; esp.Name.Visible = false
end

function FPV.Destroy(esp)
    if not esp then return end
    pcall(function() esp.Box:Destroy() end); pcall(function() esp.Name:Destroy() end)
end

function FPV.Step(cam)
    if not Config.ESP_Enabled or not Config.ESP_FPV then
        for _, esp in pairs(FPV.cache) do FPV.Hide(esp) end
        return
    end
    local screenPos, toShow = {}, {}
    for drone, part in pairs(Cache.drones or {}) do
        if part and part.Parent then
            local sp, on = cam:WorldToViewportPoint(part.Position)
            if on and sp.Z > 0 then screenPos[drone] = sp; toShow[drone] = part end
        end
    end
    for drone, esp in pairs(FPV.cache) do
        if not toShow[drone] then FPV.Hide(esp); FPV.Destroy(esp); FPV.cache[drone] = nil end
    end
    local myRoot = Cache.myRoot
    for drone, part in pairs(toShow) do
        if not FPV.cache[drone] then FPV.Create(drone) end
        local esp = FPV.cache[drone]
        local sp = screenPos[drone]
        local dist = myRoot and (part.Position - myRoot.Position).Magnitude or 0
        if dist < Config.ESP_MaxDist then
            local size = math.clamp(1000 / sp.Z, 20, 100)
            esp.Box.Position = UDim2.new(0, sp.X - size/2, 0, sp.Y - size/2); esp.Box.Size = UDim2.new(0, size, 0, size); esp.Box.Visible = true
            esp.Name.Position = UDim2.new(0, sp.X - 75, 0, sp.Y - size/2 - 18); esp.Name.Visible = true
        else
            FPV.Hide(esp)
        end
    end
end

-- [ AIMBOT CORE ] --
local AIM = { FOVCircle = nil }

if Drawing then
    pcall(function()
        AIM.FOVCircle = Drawing.new("Circle")
        AIM.FOVCircle.Thickness = 1
        AIM.FOVCircle.NumSides = 60
        AIM.FOVCircle.Radius = Config.AIM_FOV
        AIM.FOVCircle.Filled = false
        AIM.FOVCircle.Visible = false
        AIM.FOVCircle.Color = Palette.FOV_Circle
    end)
end

function AIM.GetClosestTarget(cam, screenCenter)
    local closestPart = nil
    local shortestDist = Config.AIM_FOV

    -- Target Players
    for root, char in pairs(Cache.targets) do
        if Config.AIM_TeamCheck and Cache.teamStatus[root] then continue end
        local hum = Cache.humanoids[root]
        if not hum or hum.Health <= 0 then continue end

        local head = char:FindFirstChild("Head") or root
        local sp, onScreen = cam:WorldToViewportPoint(head.Position)
        if onScreen and sp.Z > 0 then
            local pos2D = Vector2.new(sp.X, sp.Y)
            local dist = (pos2D - screenCenter).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                closestPart = head
            end
        end
    end

    -- Target FPV Drones
    if Config.AIM_FPV and Cache.drones then
        for drone, part in pairs(Cache.drones) do
            if part and part.Parent then
                local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                if onScreen and sp.Z > 0 then
                    local pos2D = Vector2.new(sp.X, sp.Y)
                    local dist = (pos2D - screenCenter).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestPart = part
                    end
                end
            end
        end
    end

    return closestPart
end

function AIM.Step(cam, screenCenter)
    if AIM.FOVCircle then
        AIM.FOVCircle.Visible = Config.AIM_Enabled and Config.AIM_ShowFOV
        AIM.FOVCircle.Radius = Config.AIM_FOV
        AIM.FOVCircle.Position = screenCenter
        AIM.FOVCircle.Color = Config.AIM_Enabled and Palette.FOV_Active or Palette.FOV_Circle
    end

    if not Config.AIM_Enabled then return end

    -- Active on Right Mouse Click Hold
    local isAiming = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if not isAiming then return end

    local targetPart = AIM.GetClosestTarget(cam, screenCenter)
    if targetPart then
        local targetCFrame = CFrame.new(cam.CFrame.Position, targetPart.Position)
        if Config.AIM_Smooth > 0 then
            local alpha = math.clamp(1 - (Config.AIM_Smooth / 100), 0.01, 1)
            cam.CFrame = cam.CFrame:Lerp(targetCFrame, alpha)
        else
            cam.CFrame = targetCFrame
        end
    end
end

-- [ TRIGGERBOT CORE ] --
local TRIGGER = { lastShot = 0 }
function TRIGGER.Step(cam)
    if not Config.TRIGGER_Enabled then return end
    if os.clock() - TRIGGER.lastShot < (Config.TRIGGER_Delay / 1000) then return end

    local mousePos = UserInputService:GetMouseLocation()
    local ray = cam:ViewportPointToRay(mousePos.X, mousePos.Y)
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local filter = {cam}
    if LocalPlayer.Character then table.insert(filter, LocalPlayer.Character) end
    rayParams.FilterDescendantsInstances = filter

    local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, rayParams)
    if result and result.Instance then
        local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
        if hitChar then
            local hum = hitChar:FindFirstChild("Humanoid")
            local root = hitChar:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root then
                if Config.TRIGGER_TeamCheck and Team.isTeammate(hitChar) then return end
                if mouse1click then mouse1click() end
                TRIGGER.lastShot = os.clock()
            end
        end
    end
end

local ESP = { cache = {} }
local function DrawLine(frame, x1, y1, x2, y2, color, thickness)
    local dx = x2 - x1; local dy = y2 - y1
    local length = math.sqrt(dx * dx + dy * dy)
    if length < 1 then frame.Visible = false; return end
    local cx = (x1 + x2) / 2; local cy = (y1 + y2) / 2
    local angle = math.atan2(dy, dx) * (180 / math.pi)
    frame.AnchorPoint = Vector2.new(0.5, 0.5); frame.Position = UDim2.new(0, cx, 0, cy)
    frame.Size = UDim2.new(0, length, 0, thickness or 1); frame.Rotation = angle
    if color then frame.BackgroundColor3 = color end
    frame.Visible = true
end

function ESP.Create(root)
    if ESP.cache[root] then return end
    local box = Instance.new("Frame"); box.BackgroundTransparency = 1; box.BorderSizePixel = 0; box.Visible = false; box.Parent = UI.ScreenGui
    Instance.new("UIStroke", box).Thickness = 1
    
    local name = Instance.new("TextLabel"); name.BackgroundTransparency = 1; name.Font = Enum.Font.RobotoMono
    name.TextSize = 13; name.TextColor3 = Color3.new(1, 1, 1); name.Size = UDim2.new(0, 200, 0, 16)
    name.TextXAlignment = Enum.TextXAlignment.Center; name.Visible = false; name.Parent = UI.ScreenGui
    
    local dist = Instance.new("TextLabel"); dist.BackgroundTransparency = 1; dist.Font = Enum.Font.RobotoMono
    dist.TextSize = 11; dist.TextColor3 = Palette.MenuTextDim; dist.Size = UDim2.new(0, 200, 0, 14)
    dist.TextXAlignment = Enum.TextXAlignment.Center; dist.Visible = false; dist.Parent = UI.ScreenGui
    
    local healthBg = Instance.new("Frame"); healthBg.BackgroundColor3 = Palette.HealthBg; healthBg.BorderSizePixel = 0; healthBg.Visible = false; healthBg.Parent = UI.ScreenGui
    local healthBar = Instance.new("Frame"); healthBar.BackgroundColor3 = Palette.HealthHigh; healthBar.BorderSizePixel = 0; healthBar.Visible = false; healthBar.Parent = UI.ScreenGui
    
    local skel = {}
    for i = 1, 5 do
        local line = Instance.new("Frame"); line.BackgroundColor3 = Palette.Skeleton; line.BorderSizePixel = 0
        line.AnchorPoint = Vector2.new(0.5, 0.5); line.Visible = false; line.Parent = UI.ScreenGui; skel[i] = line
    end
    
    local aimLine = Instance.new("Frame"); aimLine.BackgroundColor3 = Palette.AimDir; aimLine.BorderSizePixel = 0
    aimLine.AnchorPoint = Vector2.new(0.5, 0.5); aimLine.Visible = false; aimLine.Parent = UI.ScreenGui
    
    local lookingText = Instance.new("TextLabel"); lookingText.BackgroundTransparency = 1; lookingText.Font = Enum.Font.RobotoMono
    lookingText.TextSize = 13; lookingText.TextColor3 = Palette.LookingAtYou; lookingText.Text = "» TARGETED «"
    lookingText.Size = UDim2.new(0, 150, 0, 16); lookingText.TextXAlignment = Enum.TextXAlignment.Center; lookingText.Visible = false; lookingText.Parent = UI.ScreenGui
    
    local tracer = Instance.new("Frame"); tracer.BackgroundColor3 = Palette.Tracer; tracer.BorderSizePixel = 0
    tracer.AnchorPoint = Vector2.new(0.5, 0.5); tracer.Visible = false; tracer.Parent = UI.ScreenGui
    
    ESP.cache[root] = { Box = box, BoxStroke = box:FindFirstChildOfClass("UIStroke"), Name = name, Dist = dist, HealthBg = healthBg, HealthBar = healthBar, Skel = skel, AimLine = aimLine, LookingText = lookingText, Tracer = tracer }
end

function ESP.Hide(esp)
    if not esp then return end
    esp.Box.Visible = false; esp.Name.Visible = false; esp.Dist.Visible = false
    esp.HealthBg.Visible = false; esp.HealthBar.Visible = false
    for _, l in ipairs(esp.Skel) do l.Visible = false end
    esp.AimLine.Visible = false; esp.LookingText.Visible = false; esp.Tracer.Visible = false
end

function ESP.Destroy(esp)
    if not esp then return end
    pcall(function() esp.Box:Destroy(); esp.Name:Destroy(); esp.Dist:Destroy(); esp.HealthBg:Destroy(); esp.HealthBar:Destroy() end)
    for _, l in ipairs(esp.Skel) do pcall(function() l:Destroy() end) end
    pcall(function() esp.AimLine:Destroy(); esp.LookingText:Destroy(); esp.Tracer:Destroy() end)
end

function ESP.Cleanup()
    local toRemove = {}
    for root, esp in pairs(ESP.cache) do
        if not Cache.targets[root] then ESP.Hide(esp); ESP.Destroy(esp); toRemove[#toRemove + 1] = root end
    end
    for _, root in ipairs(toRemove) do ESP.cache[root] = nil end
end

function ESP.Render(esp, root, char, hum, cam, screenSize, screenCenter, dist)
    local head = char:FindFirstChild("Head")
    local headPos = head and head.Position or (root.Position + Vector3.new(0, 2, 0))
    local feetPos = root.Position - Vector3.new(0, 3, 0)
    local topPos = headPos + Vector3.new(0, 0.5, 0)
    
    local rs, ron = cam:WorldToViewportPoint(root.Position)
    local hs = cam:WorldToViewportPoint(topPos)
    local fs = cam:WorldToViewportPoint(feetPos)
    
    local onScreen = ron and rs.Z > 0
    local isTeam = Cache.teamStatus[root] or false
    local visible = Cache.visibility[root] or false
    local col = isTeam and Palette.Team or (visible and Palette.EnemyVisible or Palette.Enemy)
    local skelCol = isTeam and Palette.Team or (visible and Palette.SkeletonVisible or Palette.Skeleton)
    local lookingAtYou = Cache.lookingAtYou[root] or false
    
    if onScreen then
        local boxTop, boxBottom = hs.Y, fs.Y
        local boxHeight = math.abs(boxBottom - boxTop)
        local boxWidth = boxHeight * Tuning.BoxWidthRatio
        local cx = rs.X
        
        if Config.ESP_Boxes then
            esp.Box.Position = UDim2.new(0, cx - boxWidth/2, 0, boxTop); esp.Box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
            esp.BoxStroke.Color = col; esp.Box.Visible = true
        else esp.Box.Visible = false end
        
        if Config.ESP_Names then
            esp.Name.Text = Util.getName(char); esp.Name.Position = UDim2.new(0, cx - 100, 0, hs.Y - Tuning.NameOffset)
            esp.Name.TextColor3 = col; esp.Name.Visible = true
        else esp.Name.Visible = false end
        
        if Config.ESP_Distance then
            esp.Dist.Text = math.floor(dist) .. "m"; esp.Dist.Position = UDim2.new(0, cx - 100, 0, fs.Y + Tuning.DistOffset); esp.Dist.Visible = true
        else esp.Dist.Visible = false end
        
        if Config.ESP_Health then
            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local barX = cx - boxWidth/2 - Tuning.HealthBarOffset
            esp.HealthBg.Position = UDim2.new(0, barX - 1, 0, boxTop - 1); esp.HealthBg.Size = UDim2.new(0, Tuning.HealthBarWidth + 2, 0, boxHeight + 2); esp.HealthBg.Visible = true
            local hh = boxHeight * pct
            esp.HealthBar.Position = UDim2.new(0, barX, 0, boxBottom - hh); esp.HealthBar.Size = UDim2.new(0, Tuning.HealthBarWidth, 0, hh)
            esp.HealthBar.BackgroundColor3 = pct > 0.6 and Palette.HealthHigh or pct > 0.3 and Palette.HealthMid or Palette.HealthLow; esp.HealthBar.Visible = true
        else esp.HealthBg.Visible = false; esp.HealthBar.Visible = false end
        
        if Config.ESP_Skeleton then
            for i, b in ipairs(Bones) do
                local p1, p2 = char:FindFirstChild(b[1]), char:FindFirstChild(b[2])
                if p1 and p2 then
                    local s1, o1 = cam:WorldToViewportPoint(p1.Position)
                    local s2, o2 = cam:WorldToViewportPoint(p2.Position)
                    if o1 and o2 and s1.Z > 0 and s2.Z > 0 then DrawLine(esp.Skel[i], s1.X, s1.Y, s2.X, s2.Y, skelCol, 1) else esp.Skel[i].Visible = false end
                else esp.Skel[i].Visible = false end
            end
        else for _, l in ipairs(esp.Skel) do l.Visible = false end end
        
        if Config.ESP_AimDir and head then
            local aimEnd = head.Position + head.CFrame.LookVector * Tuning.AimLineLength
            local headScreen, headOn = cam:WorldToViewportPoint(head.Position)
            local aimScreen, aimOn = cam:WorldToViewportPoint(aimEnd)
            if headOn and aimOn and headScreen.Z > 0 and aimScreen.Z > 0 then DrawLine(esp.AimLine, headScreen.X, headScreen.Y, aimScreen.X, aimScreen.Y, Palette.AimDir, 1) else esp.AimLine.Visible = false end
        else esp.AimLine.Visible = false end
        
        if Config.ESP_LookingAtYou and lookingAtYou then
            esp.LookingText.Position = UDim2.new(0, cx - 75, 0, hs.Y - 35); esp.LookingText.Visible = true
        else esp.LookingText.Visible = false end
        
        if Config.ESP_Tracers then
            local tracerCol = visible and Palette.EnemyVisible or Palette.Tracer
            DrawLine(esp.Tracer, screenCenter.X, screenSize.Y, cx, fs.Y, tracerCol, 1)
        else esp.Tracer.Visible = false end
    else ESP.Hide(esp) end
end

function ESP.Step(cam, screenSize, screenCenter)
    if not Config.ESP_Enabled then for _, esp in pairs(ESP.cache) do ESP.Hide(esp) end; return end
    ESP.Cleanup()
    local myRoot = Cache.myRoot
    for root, char in pairs(Cache.targets) do
        if not root or not root.Parent or not char then
            if ESP.cache[root] then ESP.Hide(ESP.cache[root]) end
        else
            local hum = Cache.humanoids[root]
            if not hum or not hum.Parent or hum.Health <= 0 then
                if ESP.cache[root] then ESP.Hide(ESP.cache[root]) end
            elseif Config.ESP_TeamCheck and Cache.teamStatus[root] then
                if ESP.cache[root] then ESP.Hide(ESP.cache[root]) end
            else
                if not ESP.cache[root] then ESP.Create(root) end
                local esp = ESP.cache[root]
                local dist = myRoot and (root.Position - myRoot.Position).Magnitude or 0
                if dist > Config.ESP_MaxDist then ESP.Hide(esp) else ESP.Render(esp, root, char, hum, cam, screenSize, screenCenter, dist) end
            end
        end
    end
end

-- [ UI FRAMEWORK ] --
local Tabs = {{name = "ESP"}, {name = "AIM"}, {name = "MISC"}}
local MenuItems = {
    {tab = 1, name = "VISUALS", type = "label"},
    {tab = 1, name = "Enable ESP", key = "ESP_Enabled", type = "toggle"},
    {tab = 1, name = "Boxes", key = "ESP_Boxes", type = "toggle"},
    {tab = 1, name = "Names", key = "ESP_Names", type = "toggle"},
    {tab = 1, name = "Distance", key = "ESP_Distance", type = "toggle"},
    {tab = 1, name = "Skeleton", key = "ESP_Skeleton", type = "toggle"},
    {tab = 1, name = "Health Bar", key = "ESP_Health", type = "toggle"},
    {tab = 1, name = "Aim Direction", key = "ESP_AimDir", type = "toggle"},
    {tab = 1, name = "Looking At You", key = "ESP_LookingAtYou", type = "toggle"},
    {tab = 1, name = "Tracers", key = "ESP_Tracers", type = "toggle"},
    {tab = 1, name = "FPV Drones", key = "ESP_FPV", type = "toggle"},
    {tab = 1, name = "Team Check", key = "ESP_TeamCheck", type = "toggle"},
    {tab = 1, name = "Max Distance", key = "ESP_MaxDist", type = "slider", min = 500, max = 5000, step = 100},
    
    {tab = 2, name = "AIMBOT", type = "label"},
    {tab = 2, name = "Enable Aimbot", key = "AIM_Enabled", type = "toggle"},
    {tab = 2, name = "FOV", key = "AIM_FOV", type = "slider", min = 50, max = 500, step = 25},
    {tab = 2, name = "Smooth", key = "AIM_Smooth", type = "slider", min = 0, max = 100, step = 5},
    {tab = 2, name = "Show FOV", key = "AIM_ShowFOV", type = "toggle"},
    {tab = 2, name = "Team Check", key = "AIM_TeamCheck", type = "toggle"},
    {tab = 2, name = "Target FPV", key = "AIM_FPV", type = "toggle"},
    
    {tab = 3, name = "DESYNC", type = "label"},
    {tab = 3, name = "Enable Desync", key = "DESYNC_Enabled", type = "toggle"},
    {tab = 3, name = "Strength", key = "DESYNC_Amount", type = "slider", min = 1, max = 10, step = 1},
    {tab = 3, name = "TRIGGERBOT", type = "label"},
    {tab = 3, name = "Enable Trigger", key = "TRIGGER_Enabled", type = "toggle"},
    {tab = 3, name = "Delay (ms)", key = "TRIGGER_Delay", type = "slider", min = 0, max = 200, step = 10},
    {tab = 3, name = "Team Check", key = "TRIGGER_TeamCheck", type = "toggle"}
}

local GUI = {
    Frame = nil, Position = nil, Dragging = false, DragOffset = Vector2.zero,
    Items = {}, TabButtons = {}, ContentFrame = nil, MinPopup = nil,
    TweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
}

local Unload -- forward declaration

function GUI.ShowLoadingScreen(callback)
    local loadBG = Instance.new("Frame")
    loadBG.Name = "LoadingScreen"
    -- Точний розмір головного меню
    loadBG.Size = UDim2.new(0, 340, 0, 420)
    -- Початкова позиція за екраном (для анімації)
    loadBG.Position = UDim2.new(0, -400, 0.5, -210)
    loadBG.BackgroundColor3 = Palette.MenuBg
    loadBG.BackgroundTransparency = 0.02
    loadBG.BorderSizePixel = 0
    loadBG.ZIndex = 100
    loadBG.Parent = UI.ScreenGui
    
    -- Дизайн вікна (рамка і закруглені кути)
    Instance.new("UICorner", loadBG).CornerRadius = UDim.new(0, 6)
    local loadStroke = Instance.new("UIStroke")
    loadStroke.Color = Palette.MenuBorder
    loadStroke.Thickness = 1
    loadStroke.Transparency = 0.5
    loadStroke.Parent = loadBG
    
    local centerContainer = Instance.new("Frame")
    centerContainer.Size = UDim2.new(1, 0, 1, 0)
    centerContainer.Position = UDim2.new(0, 0, 0, 0)
    centerContainer.BackgroundTransparency = 1
    centerContainer.Parent = loadBG
    
    local titleText = Instance.new("TextLabel")
    titleText.BackgroundTransparency = 1
    titleText.Size = UDim2.new(1, 0, 0, 50)
    titleText.Position = UDim2.new(0, 0, 0.35, 0)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 24
    titleText.TextColor3 = Palette.MenuAccent
    titleText.Text = "XOLZP HUB"
    titleText.Parent = centerContainer
    
    local statusText = Instance.new("TextLabel")
    statusText.BackgroundTransparency = 1
    statusText.Size = UDim2.new(1, 0, 0, 20)
    statusText.Position = UDim2.new(0, 0, 0.52, 0)
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = 12
    statusText.TextColor3 = Palette.MenuTextDim
    statusText.Text = "Preparing AFK bypass..."
    statusText.Parent = centerContainer
    
    local barTrack = Instance.new("Frame")
    barTrack.Size = UDim2.new(0, 260, 0, 6)
    barTrack.Position = UDim2.new(0.5, -130, 0.65, 0)
    barTrack.BackgroundColor3 = Palette.MenuOff
    barTrack.BorderSizePixel = 0
    barTrack.Parent = centerContainer
    Instance.new("UICorner", barTrack).CornerRadius = UDim.new(1, 0)
    
    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Palette.MenuAccent
    barFill.BorderSizePixel = 0
    barFill.Parent = barTrack
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
    
    local percentText = Instance.new("TextLabel")
    percentText.BackgroundTransparency = 1
    percentText.Size = UDim2.new(1, 0, 0, 20)
    percentText.Position = UDim2.new(0, 0, 0.72, 0)
    percentText.Font = Enum.Font.GothamBold
    percentText.TextSize = 14
    percentText.TextColor3 = Palette.MenuAccent
    percentText.Text = "0%"
    percentText.Parent = centerContainer

    -- Анімація виїзду екрану завантаження на екран
    TweenService:Create(loadBG, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0, 30, 0.5, -210)}):Play()

    task.spawn(function()
        local texts = {"Loading assets...", "Bypassing anti-cheat...", "Preparing AFK bypass...", "Injecting XolzpHub..."}
        for i = 1, 100 do
            TweenService:Create(barFill, TweenInfo.new(0.05), {Size = UDim2.new(i/100, 0, 1, 0)}):Play()
            percentText.Text = tostring(i) .. "%"
            
            if i == 20 then statusText.Text = texts[1]
            elseif i == 45 then statusText.Text = texts[2]
            elseif i == 70 then statusText.Text = texts[3]
            elseif i == 90 then statusText.Text = texts[4]
            end
            
            task.wait(0.02)
        end
        task.wait(0.4)
        
        -- Анімація зникнення
        local fadeTween = TweenService:Create(loadBG, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
        TweenService:Create(loadStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        TweenService:Create(titleText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(statusText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(barTrack, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(barFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(percentText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        fadeTween:Play()
        fadeTween.Completed:Wait()
        loadBG:Destroy()
        
        callback()
    end)
end

function GUI.Create()
    local menuW, menuH = 340, 420
    local titleH, tabH, footerH = 40, 32, 22
    
    local main = Instance.new("Frame")
    main.Name = "Menu"
    main.BackgroundColor3 = Palette.MenuBg
    main.BackgroundTransparency = 0.02
    main.BorderSizePixel = 0
    main.Size = UDim2.new(0, menuW, 0, menuH)
    main.Position = UDim2.new(0, 30, 0.5, -menuH/2) -- Починає відразу на потрібній позиції, бо екран завантаження був там же
    main.Active = true
    main.Parent = UI.ScreenGui
    main.BackgroundTransparency = 1 -- Початково прозорий для анімації появи
    GUI.Frame = main
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Palette.MenuBorder
    stroke.Thickness = 1
    stroke.Transparency = 1 -- Початково прозора
    stroke.Parent = main
    
    local title = Instance.new("Frame")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, titleH)
    title.Parent = main
    
    local mainTitleText = Instance.new("TextLabel")
    mainTitleText.BackgroundTransparency = 1
    mainTitleText.Position = UDim2.new(0, 15, 0, 5)
    mainTitleText.Size = UDim2.new(0, 80, 0, 20)
    mainTitleText.Font = Enum.Font.GothamBold
    mainTitleText.TextSize = 16
    mainTitleText.TextColor3 = Palette.MenuAccent
    mainTitleText.TextXAlignment = Enum.TextXAlignment.Left
    mainTitleText.Text = "XolzpHub"
    mainTitleText.Parent = title
    
    local subTitleText = Instance.new("TextLabel")
    subTitleText.BackgroundTransparency = 1
    subTitleText.Position = UDim2.new(0, 15, 0, 22)
    subTitleText.Size = UDim2.new(0, 200, 0, 12)
    subTitleText.Font = Enum.Font.Gotham
    subTitleText.TextSize = 10
    subTitleText.TextColor3 = Palette.MenuTextDim
    subTitleText.TextXAlignment = Enum.TextXAlignment.Left
    subTitleText.Text = "the lost front for xeno"
    subTitleText.Parent = title

    -- [ КНОПКИ У ВЕРХНЬОМУ ПРАВОМУ КУТІ ] --
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position = UDim2.new(1, -30, 0, 10)
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Text = "X"
    closeBtn.Parent = title
    
    -- Анімація повного закриття
    closeBtn.MouseButton1Click:Connect(function()
        if main then
            local slideOut = TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0, -400, 0.5, -menuH/2)})
            slideOut:Play()
            slideOut.Completed:Wait()
        end
        if Unload then Unload() end
    end)
    
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeButton"
    minBtn.BackgroundTransparency = 1
    minBtn.Position = UDim2.new(1, -60, 0, 10)
    minBtn.Size = UDim2.new(0, 20, 0, 20)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 16
    minBtn.TextColor3 = Palette.MenuAccent
    minBtn.Text = "-"
    minBtn.Parent = title
    
    local minPopup = Instance.new("Frame")
    minPopup.Name = "MinimizedPopup"
    minPopup.BackgroundColor3 = Palette.MenuBg
    minPopup.BorderSizePixel = 0
    minPopup.Size = UDim2.new(0, 220, 0, 40)
    minPopup.Position = UDim2.new(0, -250, 0.5, -20)
    minPopup.Visible = false
    minPopup.Parent = UI.ScreenGui
    Instance.new("UICorner", minPopup).CornerRadius = UDim.new(0, 6)
    
    local minPopupStroke = Instance.new("UIStroke")
    minPopupStroke.Color = Palette.MenuBorder
    minPopupStroke.Thickness = 1
    minPopupStroke.Transparency = 0.5
    minPopupStroke.Parent = minPopup

    local minPopupText = Instance.new("TextLabel")
    minPopupText.BackgroundTransparency = 1
    minPopupText.Size = UDim2.new(1, 0, 1, 0)
    minPopupText.Font = Enum.Font.GothamBold
    minPopupText.TextSize = 12
    minPopupText.TextColor3 = Palette.MenuAccent
    minPopupText.Text = "Press Ctrl + S to maximize"
    minPopupText.Parent = minPopup
    
    GUI.MinPopup = minPopup
    
    -- Анімація згортання (Minimize)
    minBtn.MouseButton1Click:Connect(function()
        Config.MENU_Open = false
        local tweenOut = TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0, -400, 0.5, -menuH/2)})
        tweenOut:Play()
        
        task.spawn(function()
            tweenOut.Completed:Wait()
            main.Visible = false
            minPopup.Position = UDim2.new(0, -250, 0.5, -20) -- починає з-за екрану
            minPopup.Visible = true
            TweenService:Create(minPopup, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 30, 0.5, -20)}):Play()
            
            -- ЗАТРИМКА 5 СЕКУНД ТА АНІМАЦІЯ ЗНИКНЕННЯ ПОВІДОМЛЕННЯ
            task.wait(5)
            if not Config.MENU_Open and minPopup.Visible then
                local hideTween = TweenService:Create(minPopup, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0, -250, 0.5, -20)})
                hideTween:Play()
                hideTween.Completed:Wait()
                if not Config.MENU_Open then
                    minPopup.Visible = false
                end
            end
        end)
    end)
    -- [ КІНЕЦЬ КНОПОК ] --
    
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = "Tabs"
    tabFrame.BackgroundTransparency = 1
    tabFrame.Position = UDim2.new(0, 0, 0, titleH)
    tabFrame.Size = UDim2.new(1, 0, 0, tabH)
    tabFrame.Parent = main
    
    local tabW = menuW / #Tabs
    for i, tab in ipairs(Tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = tab.name
        btn.BackgroundColor3 = Palette.MenuTab
        btn.BackgroundTransparency = i == 1 and 0 or 1
        btn.BorderSizePixel = 0
        btn.Position = UDim2.new(0, (i-1) * tabW, 0, 0)
        btn.Size = UDim2.new(0, tabW, 1, 0)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextColor3 = i == 1 and Palette.MenuAccent or Palette.MenuTextDim
        btn.Text = tab.name
        btn.AutoButtonColor = false
        btn.Parent = tabFrame
        
        local indicator = Instance.new("Frame")
        indicator.Name = "Indicator"
        indicator.BackgroundColor3 = Palette.MenuAccent
        indicator.BorderSizePixel = 0
        indicator.Position = UDim2.new(0, 0, 1, -2)
        indicator.Size = UDim2.new(1, 0, 0, 2)
        indicator.BackgroundTransparency = i == 1 and 0 or 1
        indicator.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            if Config.MENU_Tab == i then return end
            Config.MENU_Tab = i
            GUI.UpdateTabs()
            GUI.UpdateContentAnimated()
        end)
        GUI.TabButtons[i] = {Button = btn, Indicator = indicator}
    end
    
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "Content"
    contentFrame.BackgroundTransparency = 1
    contentFrame.Position = UDim2.new(0, 10, 0, titleH + tabH + 10)
    contentFrame.Size = UDim2.new(1, -20, 1, -titleH - tabH - footerH - 10)
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.ScrollBarThickness = 2
    contentFrame.ScrollBarImageColor3 = Palette.MenuAccent
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = main
    GUI.ContentFrame = contentFrame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = contentFrame
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            GUI.Dragging = true; GUI.DragOffset = UserInputService:GetMouseLocation() - Vector2.new(main.AbsolutePosition.X, main.AbsolutePosition.Y)
        end
    end)
    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then GUI.Dragging = false end
    end)
    
    GUI.UpdateContent(true)
    
    Config.MENU_Open = true
    
    -- Плавно проявляємо меню там, де тільки що пропав екран завантаження
    TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.02}):Play()
    TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 0.5}):Play()
end

function GUI.UpdateTabs()
    for i, tab in ipairs(GUI.TabButtons) do
        local isSelected = i == Config.MENU_Tab
        TweenService:Create(tab.Button, GUI.TweenInfo, {
            TextColor3 = isSelected and Palette.MenuAccent or Palette.MenuTextDim,
            BackgroundTransparency = isSelected and 0 or 1
        }):Play()
        TweenService:Create(tab.Indicator, GUI.TweenInfo, {BackgroundTransparency = isSelected and 0 or 1}):Play()
    end
end

function GUI.UpdateContent(isInitial)
    for _, child in ipairs(GUI.ContentFrame:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    GUI.Items = {}
    
    local order = 0
    for _, menuItem in ipairs(MenuItems) do
        if menuItem.tab == Config.MENU_Tab then
            order = order + 1
            local itemH = menuItem.type == "slider" and 38 or 28
            
            local item = Instance.new("Frame")
            item.Name = menuItem.name
            item.BackgroundColor3 = Palette.MenuPanel
            item.BackgroundTransparency = menuItem.type == "label" and 1 or 0
            item.BorderSizePixel = 0
            item.Size = UDim2.new(1, 0, 0, itemH)
            item.LayoutOrder = order
            item.Parent = GUI.ContentFrame
            Instance.new("UICorner", item).CornerRadius = UDim.new(0, 4)
            
            local label = Instance.new("TextLabel")
            label.BackgroundTransparency = 1; label.Position = UDim2.new(0, 10, 0, 0); label.Size = UDim2.new(0.6, 0, 0, 28)
            label.Font = Enum.Font.RobotoMono; label.TextSize = menuItem.type == "label" and 11 or 12
            label.TextColor3 = menuItem.type == "label" and Palette.MenuAccent or Palette.MenuText
            label.TextXAlignment = Enum.TextXAlignment.Left; label.Text = menuItem.name; label.Parent = item
            
            if menuItem.type == "toggle" then
                local toggle = Instance.new("Frame"); toggle.BackgroundColor3 = Config[menuItem.key] and Palette.MenuOn or Palette.MenuOff
                toggle.BorderSizePixel = 0; toggle.Position = UDim2.new(1, -40, 0.5, -7); toggle.Size = UDim2.new(0, 30, 0, 14); toggle.Parent = item
                Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
                
                local knob = Instance.new("Frame"); knob.BackgroundColor3 = Config[menuItem.key] and Color3.new(0,0,0) or Color3.new(1,1,1)
                knob.BorderSizePixel = 0; knob.Position = Config[menuItem.key] and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5); knob.Size = UDim2.new(0, 10, 0, 10); knob.Parent = toggle
                Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
                
                local btn = Instance.new("TextButton"); btn.BackgroundTransparency = 1; btn.Size = UDim2.new(1, 0, 1, 0); btn.Text = ""; btn.Parent = item
                btn.MouseButton1Click:Connect(function()
                    Config[menuItem.key] = not Config[menuItem.key]; local isON = Config[menuItem.key]
                    TweenService:Create(toggle, GUI.TweenInfo, {BackgroundColor3 = isON and Palette.MenuOn or Palette.MenuOff}):Play()
                    TweenService:Create(knob, GUI.TweenInfo, {Position = isON and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5), BackgroundColor3 = isON and Color3.new(0,0,0) or Color3.new(1,1,1)}):Play()
                end)
            elseif menuItem.type == "slider" then
                local val = Config[menuItem.key]
                local valText = menuItem.step < 1 and string.format("%.2f", val) or tostring(math.floor(val))
                local valLabel = Instance.new("TextLabel"); valLabel.BackgroundTransparency = 1; valLabel.Position = UDim2.new(1, -50, 0, 0); valLabel.Size = UDim2.new(0, 45, 0, 28)
                valLabel.Font = Enum.Font.RobotoMono; valLabel.TextSize = 11; valLabel.TextColor3 = Palette.MenuTextDim
                valLabel.TextXAlignment = Enum.TextXAlignment.Right; valLabel.Text = valText; valLabel.Parent = item
                
                local track = Instance.new("Frame"); track.BackgroundColor3 = Palette.MenuOff; track.BorderSizePixel = 0; track.Position = UDim2.new(0, 10, 0, 28); track.Size = UDim2.new(1, -20, 0, 4); track.Parent = item
                Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
                local pct = (val - menuItem.min) / (menuItem.max - menuItem.min)
                local fill = Instance.new("Frame"); fill.BackgroundColor3 = Palette.MenuAccent; fill.BorderSizePixel = 0; fill.Size = UDim2.new(pct, 0, 1, 0); fill.Parent = track
                Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
                
                local dragging = false
                track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
                track.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                
                Connections["slider_" .. menuItem.key] = RunService.RenderStepped:Connect(function()
                    if dragging then
                        local mx = UserInputService:GetMouseLocation().X; local tx = track.AbsolutePosition.X; local tw = track.AbsoluteSize.X
                        local p = math.clamp((mx - tx) / tw, 0, 1)
                        local v = menuItem.min + p * (menuItem.max - menuItem.min)
                        v = math.floor(v / menuItem.step + 0.5) * menuItem.step; Config[menuItem.key] = math.clamp(v, menuItem.min, menuItem.max)
                        TweenService:Create(fill, TweenInfo.new(0.05), {Size = UDim2.new((Config[menuItem.key] - menuItem.min) / (menuItem.max - menuItem.min), 0, 1, 0)}):Play()
                        valLabel.Text = menuItem.step < 1 and string.format("%.2f", Config[menuItem.key]) or tostring(math.floor(Config[menuItem.key]))
                    end
                end)
            end
            
            if not isInitial then
                item.Size = UDim2.new(0, 0, 0, itemH)
                TweenService:Create(item, TweenInfo.new(0.3 + (order * 0.05), Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, itemH)}):Play()
            end
            
            GUI.Items[#GUI.Items + 1] = item
        end
    end
    
    local totalH = 0
    for _, item in ipairs(GUI.Items) do totalH = totalH + (item:FindFirstChild("Track") and 38 or 28) + 4 end
    GUI.ContentFrame.CanvasSize = UDim2.new(0, 0, 0, totalH)
end

function GUI.UpdateContentAnimated()
    for _, child in ipairs(GUI.ContentFrame:GetChildren()) do
        if child:IsA("Frame") then
            TweenService:Create(child, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, child.Size.Y.Offset)}):Play()
        end
    end
    task.wait(0.15)
    GUI.UpdateContent(false)
end

function GUI.Step()
    if GUI.Dragging then
        TweenService:Create(GUI.Frame, TweenInfo.new(0.1), {Position = UDim2.new(0, (UserInputService:GetMouseLocation() - GUI.DragOffset).X, 0, (UserInputService:GetMouseLocation() - GUI.DragOffset).Y)}):Play()
    end
end

function Unload()
    if Unloaded then return end
    Unloaded = true; Config.DESYNC_Enabled = false; Config.TRIGGER_Enabled = false
    if AIM.FOVCircle then pcall(function() AIM.FOVCircle:Remove() end) end
    for _, c in pairs(Connections) do pcall(function() c:Disconnect() end) end
    for _, esp in pairs(ESP.cache) do ESP.Destroy(esp) end
    for _, esp in pairs(FPV.cache) do FPV.Destroy(esp) end
    pcall(function() UI.ScreenGui:Destroy() end)
end

Connections.input = UserInputService.InputBegan:Connect(function(input, gp)
    if input.KeyCode == Enum.KeyCode.Home then Unload(); return end
    if input.KeyCode == Enum.KeyCode.Insert and not gp then
        Config.MENU_Open = not Config.MENU_Open
        if GUI.Frame then
            TweenService:Create(GUI.Frame, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = Config.MENU_Open and UDim2.new(0, 30, 0.5, -210) or UDim2.new(0, -400, 0.5, -210)}):Play()
        end
    end
    
    -- [ ХОТКЕЙ CTRL + S ДЛЯ РОЗГОРТАННЯ ВІКНА З АНІМАЦІЄЮ ] --
    if input.KeyCode == Enum.KeyCode.S and not gp then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            -- ЗМІНА: Перевіряємо, чи меню закрите, щоб можна було відкрити навіть коли повідомлення вже сховалося
            if not Config.MENU_Open then
                if GUI.MinPopup and GUI.MinPopup.Visible then
                    local popupTween = TweenService:Create(GUI.MinPopup, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0, -250, 0.5, -20)})
                    popupTween:Play()
                    popupTween.Completed:Wait()
                    GUI.MinPopup.Visible = false
                end
                
                if GUI.Frame then
                    GUI.Frame.Visible = true
                    Config.MENU_Open = true
                    GUI.Frame.Position = UDim2.new(0, -400, 0.5, -210) -- починає зліва за екраном
                    TweenService:Create(GUI.Frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 30, 0.5, -210)}):Play()
                end
            end
        end
    end
end)

Connections.inputUp = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then GUI.Dragging = false end
end)

Connections.render = RunService.RenderStepped:Connect(function()
    if Unloaded then return end
    local cam = Workspace.CurrentCamera; if not cam then return end
    local screenSize = cam.ViewportSize; local screenCenter = Vector2.new(screenSize.X/2, screenSize.Y/2)
    
    -- СПОЧАТКУ відпрацьовує Aimbot (змінює позицію камери)
    pcall(function() AIM.Step(cam, screenCenter) end)
    
    -- ПОТІМ відпрацьовує ESP (малює бокси відносно НОВОЇ позиції камери)
    pcall(function() ESP.Step(cam, screenSize, screenCenter) end)
    pcall(function() FPV.Step(cam) end)
    pcall(function() TRIGGER.Step(cam) end)
    
    if GUI.Frame then pcall(GUI.Step) end
end)

-- Main Execution
GUI.ShowLoadingScreen(function()
    GUI.Create()
    GUI.UpdateTabs()
end)
