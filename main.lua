local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ================= UI =================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NoclipFlyUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 9999
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Texto de vida
local hpDisplay = Instance.new("TextLabel")
hpDisplay.Size = UDim2.new(0, 300, 0, 40)
hpDisplay.Position = UDim2.new(0.5, -150, 0, 10)
hpDisplay.BackgroundTransparency = 1
hpDisplay.TextColor3 = Color3.fromRGB(0, 255, 0)
hpDisplay.TextStrokeTransparency = 0
hpDisplay.Font = Enum.Font.GothamBlack
hpDisplay.TextSize = 24
hpDisplay.Visible = false
hpDisplay.Parent = screenGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 305)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Noclip & Fly"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

local function makeButton(text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 35)
    btn.Position = UDim2.new(0, 20, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = mainFrame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    return btn
end

local noclipBtn = makeButton("Noclip: OFF", 40)
local flyBtn = makeButton("Fly: OFF", 85)
local healthBtn = makeButton("Health Boost: OFF", 130)
local espBtn = makeButton("ESP: OFF", 260)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 65, 0, 30)
speedLabel.Position = UDim2.new(0, 20, 0, 175)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed:"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 14
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 115, 0, 30)
speedBox.Position = UDim2.new(0, 85, 0, 175)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
speedBox.Text = "100"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 14
speedBox.ClearTextOnFocus = false
speedBox.Parent = mainFrame
local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedBox

local hpLabel = Instance.new("TextLabel")
hpLabel.Size = UDim2.new(0, 65, 0, 30)
hpLabel.Position = UDim2.new(0, 20, 0, 220)
hpLabel.BackgroundTransparency = 1
hpLabel.Text = "Max HP:"
hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
hpLabel.Font = Enum.Font.Gotham
hpLabel.TextSize = 14
hpLabel.TextXAlignment = Enum.TextXAlignment.Left
hpLabel.Parent = mainFrame

local hpBox = Instance.new("TextBox")
hpBox.Size = UDim2.new(0, 115, 0, 30)
hpBox.Position = UDim2.new(0, 85, 0, 220)
hpBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
hpBox.Text = "500"
hpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
hpBox.Font = Enum.Font.Gotham
hpBox.TextSize = 14
hpBox.ClearTextOnFocus = false
hpBox.Parent = mainFrame
local hpCorner = Instance.new("UICorner")
hpCorner.CornerRadius = UDim.new(0, 6)
hpCorner.Parent = hpBox

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -25, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = mainFrame
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeBtn

-- ================= VARIABLES =================
local noclipEnabled = false
local flyEnabled = false
local healthBoostEnabled = false
local espEnabled = false
local flyConnection = nil
local bodyVelocity = nil
local bodyGyro = nil
local flySpeed = 100
local customMaxHealth = 500
local forwardLook = Vector3.new(0, 0, -1)
local espData = {} 

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local savedWalkSpeed = humanoid.WalkSpeed
local savedJumpPower = humanoid.JumpPower
local originalMaxHealth = humanoid.MaxHealth

-- Actualizar texto de vida
RunService.RenderStepped:Connect(function()
    if healthBoostEnabled and character then
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum then
            hpDisplay.Visible = true
            hpDisplay.Text = "HP: " .. math.floor(hum.Health) .. " / " .. math.floor(hum.MaxHealth)
            if hum.Health > (hum.MaxHealth / 2) then
                hpDisplay.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                hpDisplay.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        end
    else
        hpDisplay.Visible = false
    end
end)

-- Funciones de las cajas de texto
speedBox.FocusLost:Connect(function()
    local num = tonumber(speedBox.Text)
    if num then
        flySpeed = math.clamp(math.floor(num), 1, 1000)
        speedBox.Text = tostring(flySpeed)
    else
        speedBox.Text = tostring(flySpeed)
    end
end)

hpBox.FocusLost:Connect(function()
    local num = tonumber(hpBox.Text)
    if num then
        customMaxHealth = math.clamp(math.floor(num), 100, 1000000)
        hpBox.Text = tostring(customMaxHealth)
        if healthBoostEnabled and humanoid then
            humanoid.MaxHealth = customMaxHealth
            humanoid.Health = customMaxHealth
        end
    else
        hpBox.Text = tostring(customMaxHealth)
    end
end)

-- ======= HOOKS PARA MANTENER LA VIDA ALTA =======
if hookmetamethod and getnamecallmethod then
    pcall(function()
        local oldIndex = hookmetamethod(game, "__newindex", function(self, key, value)
            if healthBoostEnabled and character then
                local hum = character:FindFirstChildOfClass("Humanoid")
                if self == hum then
                    if key == "MaxHealth" and value < customMaxHealth then
                        return
                    end
                    if key == "Health" and value < hum.MaxHealth then
                        return
                    end
                end
            end
            return oldIndex(self, key, value)
        end)

        local oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            if healthBoostEnabled and character then
                local hum = character:FindFirstChildOfClass("Humanoid")
                local method = getnamecallmethod()
                if self == hum and (method == "TakeDamage" or method == "BreakJoints") then
                    return
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
end

-- ======= ANIMACIONES =======
local function disableAnimations()
    if not character then return end
    local animate = character:FindFirstChild("Animate")
    if animate then animate.Disabled = true end
    if humanoid then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop(0)
            end
        end
    end
end

local function enableAnimations()
    if not character then return end
    local animate = character:FindFirstChild("Animate")
    if animate then animate.Disabled = false end
end

local function hookAnimator()
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator") or humanoid:WaitForChild("Animator", 5)
    if animator then
        animator.AnimationPlayed:Connect(function(track)
            if flyEnabled then track:Stop(0) end
        end)
    end
end
hookAnimator()

-- ======= FLY =======
local function stopFly()
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
    if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
end

-- ======= HEALTH BOOST =======
local function applyHealthBoost()
    if not character then return end
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.MaxHealth = customMaxHealth
        hum.Health = customMaxHealth
    end
end

local function removeHealthBoost()
    if character then
        local hum = character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = originalMaxHealth
            hum.Health = originalMaxHealth
        end
    end
end

-- ======= ESP =======
local function rainbowColor()
    return Color3.fromHSV((os.clock() * 0.4) % 1, 1, 1)
end

local function cleanupESPForPlayer(plr)
    local data = espData[plr]
    if not data then return end
    if data.highlight then data.highlight:Destroy() end
    if data.billboard then data.billboard:Destroy() end
    if data.line then data.line:Destroy() end
    espData[plr] = nil
end

local function cleanupAllESP()
    for plr, _ in pairs(espData) do cleanupESPForPlayer(plr) end
    espData = {}
end

local function addESPForPlayer(plr)
    if plr == player or espData[plr] then return end
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = char
    highlight.FillTransparency = 1 
    highlight.OutlineTransparency = 0
    pcall(function() highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end)
    highlight.Parent = workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 30)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.Parent = billboard

    local healthBg = Instance.new("Frame")
    healthBg.Size = UDim2.new(0.8, 0, 0, 6)
    healthBg.Position = UDim2.new(0.1, 0, 1, -8)
    healthBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    healthBg.BorderSizePixel = 0
    healthBg.Parent = billboard
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 3)
    bgCorner.Parent = healthBg

    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthBg
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 3)
    barCorner.Parent = healthBar

    local line = Instance.new("Frame")
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.ZIndex = 2 
    line.Active = false
    line.Parent = screenGui

    espData[plr] = {
        highlight = highlight,
        nameLabel = nameLabel,
        healthBar = healthBar,
        line = line,
        character = char,
        billboard = billboard
    }
end

local function updateLine(line, fromV, toV, color)
    if not line or not line.Parent then return end
    local delta = toV - fromV
    local length = delta.Magnitude
    if length < 2 then
        line.Visible = false
        return
    end
    line.Visible = true
    line.Position = UDim2.new(0, fromV.X + delta.X / 2, 0, fromV.Y + delta.Y / 2)
    line.Size = UDim2.new(0, length, 0, 2)
    line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
    line.BackgroundColor3 = color
end

RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    local color = rainbowColor()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize

    local myChar = player.Character
    local myHead = myChar and myChar:FindFirstChild("Head")
    local fromV = Vector2.new(viewport.X / 2, viewport.Y)
    
    if myHead then
        local myPos = cam:WorldToViewportPoint(myHead.Position)
        if myPos.Z > 0 then
            fromV = Vector2.new(myPos.X, myPos.Y)
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            local head = char and char:FindFirstChild("Head")
            if head then
                local data = espData[plr]
                if not data or data.character ~= char then
                    cleanupESPForPlayer(plr)
                    addESPForPlayer(plr)
                    data = espData[plr]
                end
                
                if data then
                    data.highlight.OutlineColor = color
                    data.nameLabel.TextColor3 = color
                    
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and data.healthBar then
                        local hpRatio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        data.healthBar.Size = UDim2.new(hpRatio, 0, 1, 0)
                        if hpRatio > 0.5 then
                            data.healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                        elseif hpRatio > 0.25 then
                            data.healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                        else
                            data.healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        end
                    end

                    local screenPos, _ = cam:WorldToViewportPoint(head.Position)
                    local targetV = Vector2.new(screenPos.X, screenPos.Y)
                    local centerX = viewport.X / 2
                    local centerY = viewport.Y / 2

                    if screenPos.Z < 0 then
                        targetV = Vector2.new(
                            centerX - (targetV.X - centerX),
                            centerY - (targetV.Y - centerY)
                        )
                    end
                    
                    updateLine(data.line, fromV, targetV, color)
                end
            else
                cleanupESPForPlayer(plr)
            end
        end
    end
end)

-- ======= BOTONES =======
noclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipBtn.Text = "Noclip: " .. (noclipEnabled and "ON" or "OFF")
    noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 65)
end)

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 65)
    if espEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do addESPForPlayer(plr) end
    else
        cleanupAllESP()
    end
end)

flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyBtn.Text = "Fly: " .. (flyEnabled and "ON" or "OFF")
    flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 65)

    if flyEnabled then
        if not rootPart or not rootPart.Parent or not humanoid then return end
        local look = rootPart.CFrame.LookVector
        forwardLook = Vector3.new(look.X, 0, look.Z)
        if forwardLook.Magnitude < 0.01 then forwardLook = Vector3.new(0, 0, -1) end
        forwardLook = forwardLook.Unit

        savedWalkSpeed = humanoid.WalkSpeed
        savedJumpPower = humanoid.JumpPower
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        disableAnimations()

        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = rootPart

        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 100000
        bodyGyro.D = 1000
        bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + forwardLook)
        bodyGyro.Parent = rootPart

        flyConnection = RunService.RenderStepped:Connect(function()
            if not flyEnabled or not bodyVelocity or not bodyGyro then return end

            local cam = workspace.CurrentCamera
            if not cam then return end
            local camLook = cam.CFrame.LookVector
            local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
            if flatLook.Magnitude < 0.01 then
                flatLook = cam.CFrame.RightVector
                flatLook = Vector3.new(flatLook.X, 0, flatLook.Z)
            end
            flatLook = flatLook.Unit
            local flatRight = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z).Unit

            local moveDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + flatLook end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - flatLook end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - flatRight end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + flatRight end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - Vector3.new(0, 1, 0) end

            if moveDirection.Magnitude > 0 then
                moveDirection = moveDirection.Unit * flySpeed
            end

            bodyVelocity.Velocity = moveDirection
            bodyGyro.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + forwardLook)
        end)
    else
        stopFly()
        if humanoid then
            humanoid.WalkSpeed = savedWalkSpeed
            humanoid.JumpPower = savedJumpPower
        end
        enableAnimations()
    end
end)

healthBtn.MouseButton1Click:Connect(function()
    healthBoostEnabled = not healthBoostEnabled
    healthBtn.Text = "Health Boost: " .. (healthBoostEnabled and "ON" or "OFF")
    healthBtn.BackgroundColor3 = healthBoostEnabled and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(50, 50, 65)
    if healthBoostEnabled then applyHealthBoost() else removeHealthBoost() end
end)

closeBtn.MouseButton1Click:Connect(function()
    stopFly()
    if humanoid then
        humanoid.WalkSpeed = savedWalkSpeed
        humanoid.JumpPower = savedJumpPower
    end
    enableAnimations()
    healthBoostEnabled = false
    removeHealthBoost()
    cleanupAllESP()
    screenGui:Destroy()
end)

RunService.Stepped:Connect(function()
    if noclipEnabled and character and character.Parent then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

player.CharacterAdde