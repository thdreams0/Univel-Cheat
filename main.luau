--[[
    Cheat avançado para Roblox
    --------------------------------
    Cole em: StarterPlayer > StarterPlayerScripts
    Tipo: LocalScript

    Controles:
        RightShift  -> abrir/fechar menu
        N           -> toggle de speed
        C           -> toggle de noclip
        V           -> toggle de aimbot
        X           -> toggle de ESP

    Requisitos:
        - Funciona em Roblox Studio
        - GUI com menu
        - Speed
        - Noclip
        - Aimbot
        - ESP
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Configurações do cheat
local Settings = {
    SpeedEnabled = false,
    NoclipEnabled = false,
    AimbotEnabled = false,
    EspEnabled = false,

    WalkSpeed = 120,
    AimbotFOV = 220,
    AimbotSmoothness = 0.22,
}

-- Estado do menu
local MenuOpen = true
local AimbotActive = false

-- Referências da GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedCheatMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 310, 0, 270)
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local function MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart = nil
    local startPosition = nil

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = frame.Position
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "ADVANCED CHEAT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

MakeDraggable(MainFrame, Title)

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -20, 0, 1)
Divider.Position = UDim2.new(0, 10, 0, 42)
Divider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

local SpeedButton
local NoclipButton
local AimbotButton
local ESPButton
local SpeedInput
local UpdateESP

local function SetButtonState(button, enabled, enabledText, disabledText)
    if enabled then
        button.BackgroundColor3 = Color3.fromRGB(43, 196, 105)
        button.Text = enabledText
    else
        button.BackgroundColor3 = Color3.fromRGB(90, 90, 95)
        button.Text = disabledText
    end
end

local function MakeToggleButton(name, text, yPos, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -20, 0, 38)
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.AutoButtonColor = false
    button.BackgroundColor3 = Color3.fromRGB(90, 90, 95)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 15
    button.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    button.MouseButton1Click:Connect(callback)
    return button
end

local function MakeTextBox(name, placeholder, yPos)
    local box = Instance.new("TextBox")
    box.Name = name
    box.Size = UDim2.new(1, -20, 0, 32)
    box.Position = UDim2.new(0, 10, 0, yPos)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    box.BorderSizePixel = 0
    box.Text = placeholder
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderColor3 = Color3.fromRGB(170, 170, 170)
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.TextWrapped = true
    box.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = box

    return box
end

local function ApplySpeed()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        if Settings.SpeedEnabled then
            humanoid.WalkSpeed = Settings.WalkSpeed
        else
            humanoid.WalkSpeed = 16
        end
    end
end

local function ApplyNoclip()
    local character = LocalPlayer.Character
    if not character then return end

    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.CanCollide = not Settings.NoclipEnabled
        end
    end
end

-- Botões
SpeedButton = MakeToggleButton("SpeedButton", "Speed: OFF", 60, function()
    Settings.SpeedEnabled = not Settings.SpeedEnabled
    SetButtonState(SpeedButton, Settings.SpeedEnabled, "Speed: ON", "Speed: OFF")
    ApplySpeed()
end)

NoclipButton = MakeToggleButton("NoclipButton", "Noclip: OFF", 105, function()
    Settings.NoclipEnabled = not Settings.NoclipEnabled
    SetButtonState(NoclipButton, Settings.NoclipEnabled, "Noclip: ON", "Noclip: OFF")
    ApplyNoclip()
end)

AimbotButton = MakeToggleButton("AimbotButton", "Aimbot: OFF", 150, function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    SetButtonState(AimbotButton, Settings.AimbotEnabled, "Aimbot: ON", "Aimbot: OFF")
end)

ESPButton = MakeToggleButton("ESPButton", "ESP: OFF", 195, function()
    Settings.EspEnabled = not Settings.EspEnabled
    SetButtonState(ESPButton, Settings.EspEnabled, "ESP: ON", "ESP: OFF")
    UpdateESP()
end)

SpeedInput = MakeTextBox("SpeedInput", tostring(Settings.WalkSpeed), 230)
SpeedInput.FocusLost:Connect(function()
    local value = tonumber(SpeedInput.Text)
    if value then
        Settings.WalkSpeed = math.clamp(value, 16, 500)
    end
    SpeedInput.Text = tostring(Settings.WalkSpeed)
    if Settings.SpeedEnabled then
        ApplySpeed()
    end
end)

-- Aimbot
local function IsTargetVisible(targetPart)
    local camera = workspace.CurrentCamera
    if not camera or not targetPart then
        return false
    end

    local origin = camera.CFrame.Position
    local direction = targetPart.Position - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character }

    local result = workspace:Raycast(origin, direction, rayParams)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end

    return true
end

local function GetClosestTarget()
    local camera = workspace.CurrentCamera
    if not camera or not AimbotActive then return nil end

    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    local bestTarget = nil
    local bestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChildOfClass("Humanoid") and character.Humanoid.Health > 0 then
                local root = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
                if root and IsTargetVisible(root) then
                    local onScreenPosition, onScreen = camera:WorldToScreenPoint(root.Position)
                    if onScreen then
                        local screenVector = Vector2.new(onScreenPosition.X, onScreenPosition.Y)
                        local distance = (screenVector - screenCenter).Magnitude
                        if distance <= Settings.AimbotFOV and distance < bestDistance then
                            bestDistance = distance
                            bestTarget = root
                        end
                    end
                end
            end
        end
    end

    return bestTarget
end

-- ESP
local function RemoveESPForPlayer(player)
    if not player.Character then return end

    local highlight = player.Character:FindFirstChild("ESP_Highlight")
    if highlight then
        highlight:Destroy()
    end

    local nameTag = player.Character:FindFirstChild("ESP_NameTag")
    if nameTag then
        nameTag:Destroy()
    end
end

local function AddESPForPlayer(player)
    if player == LocalPlayer or not player.Character then return end

    local character = player.Character
    if character:FindFirstChild("ESP_Highlight") then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.new(255, 80, 80)  -- Updated line
    highlight.Adornee = character
    highlight.Parent = character
    local head = character:FindFirstChild("Head")
    if head then
        local nameTag = Instance.new("BillboardGui")
        nameTag.Name = "ESP_NameTag"
        nameTag.Adornee = head
        nameTag.Size = UDim2.new(0, 120, 0, 40)
        nameTag.StudsOffset = Vector3.new(0, 2.5, 0)
        nameTag.AlwaysOnTop = true
        nameTag.Parent = head

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = player.Name
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        label.TextStrokeTransparency = 0.3
        label.Parent = nameTag
    end
end

-- ESP
UpdateESP = function()
    if Settings.EspEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                AddESPForPlayer(player)
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            RemoveESPForPlayer(player)
        end
    end
end

-- Eventos de players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if Settings.EspEnabled and player ~= LocalPlayer then
            task.delay(0.25, function()
                AddESPForPlayer(player)
            end)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESPForPlayer(player)
end)

-- Atualização contínua
RunService.RenderStepped:Connect(function()
    -- Speed em tempo real
    if Settings.SpeedEnabled then
        ApplySpeed()
    end

    -- Noclip em tempo real
    if Settings.NoclipEnabled then
        ApplyNoclip()
    end

    -- Aimbot
    if Settings.AimbotEnabled then
        local target = GetClosestTarget()
        if target then
            local camera = workspace.CurrentCamera
            if camera then
                local targetPos = target.Position + Vector3.new(0, 1.2, 0)
                local current = camera.CFrame
                local desired = CFrame.new(current.Position, targetPos)
                camera.CFrame = current:Lerp(desired, Settings.AimbotSmoothness)
            end
        end
    end
end)

-- Atualizar ESP ao carregar personagens
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function()
            if Settings.EspEnabled then
                task.delay(0.25, function()
                    AddESPForPlayer(player)
                end)
            end
        end)
    end
end

-- Toggle do menu com tecla
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotActive = true
    end

    if input.KeyCode == Enum.KeyCode.RightShift then
        MenuOpen = not MenuOpen
        MainFrame.Visible = MenuOpen
    end

    if input.KeyCode == Enum.KeyCode.N then
        Settings.SpeedEnabled = not Settings.SpeedEnabled
        SetButtonState(SpeedButton, Settings.SpeedEnabled, "Speed: ON", "Speed: OFF")
        ApplySpeed()
    end

    if input.KeyCode == Enum.KeyCode.C then
        Settings.NoclipEnabled = not Settings.NoclipEnabled
        SetButtonState(NoclipButton, Settings.NoclipEnabled, "Noclip: ON", "Noclip: OFF")
        ApplyNoclip()
    end

    if input.KeyCode == Enum.KeyCode.V then
        Settings.AimbotEnabled = not Settings.AimbotEnabled
        SetButtonState(AimbotButton, Settings.AimbotEnabled, "Aimbot: ON", "Aimbot: OFF")
    end

    if input.KeyCode == Enum.KeyCode.X then
        Settings.EspEnabled = not Settings.EspEnabled
        SetButtonState(ESPButton, Settings.EspEnabled, "ESP: ON", "ESP: OFF")
        UpdateESP()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        AimbotActive = false
    end
end)

-- Ajustes iniciais
SetButtonState(SpeedButton, false, "Speed: ON", "Speed: OFF")
SetButtonState(NoclipButton, false, "Noclip: ON", "Noclip: OFF")
SetButtonState(AimbotButton, false, "Aimbot: ON", "Aimbot: OFF")
SetButtonState(ESPButton, false, "ESP: ON", "ESP: OFF")
SpeedInput.Text = tostring(Settings.WalkSpeed)
