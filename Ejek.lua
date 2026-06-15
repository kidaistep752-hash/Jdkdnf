-- ====================================================================
--  BLOCK 1: UPDATED CONFIG & FULL SYSTEM CLEANUP
-- ====================================================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Жесткая зачистка старых интерфейсов и эффектов
if CoreGui:FindFirstChild("SimpleNeonSense") then
    CoreGui.SimpleNeonSense:Destroy()
end

local function cleanCharacter(char)
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        for _, child in pairs(root:GetChildren()) do
            if child:IsA("BodyVelocity") or child:IsA("BodyGyro") or child.Name == "FlyVelocity" or child.Name == "FlingForce" then
                child:Destroy()
            end
        end
    end
    for _, child in pairs(char:GetDescendants()) do
        if child:IsA("Highlight") and child.Name == "NeonESP" then
            child:Destroy()
        end
    end
end

cleanCharacter(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(cleanCharacter)

-- Расширенный конфиг под все ваши требования
_G.Config = {
    Speedhack = false, SpeedValue = 16,
    Noclip = false,
    SelectedPlayer = "",
    Target = false,
    GodModeToggle = false,
    GodModeType = "Loop",
    SpinBot = false, SpinSpeed = 30,
    FlyMode = false, FlySpeedValue = 40,
    XNeoFlyActive = false,
    OnePunchFling = false,
    ESPToggle = false,
    ESPColor = "WHITE",
    MM2Mod = false
}

local FILE_NAME = "SimpleNeon_Config.json"
function _G.saveSettings()
    if writefile then
        local success, encoded = pcall(function() return HttpService:JSONEncode(_G.Config) end)
        if success then writefile(FILE_NAME, encoded) end
    end
end

if readfile and isfile and isfile(FILE_NAME) then
    local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(FILE_NAME)) end)
    if success then 
        for k, v in pairs(decoded) do 
            _G.Config[k] = v 
        end
    end
end
-- ====================================================================
--  BLOCK 2: SYNCHRONIZED UI WINDOWS & MOBILE DRAG SYSTEM
-- ====================================================================
_G.ScreenGui = Instance.new("ScreenGui")
_G.ScreenGui.Name = "SimpleNeonSense"
_G.ScreenGui.Parent = game:GetService("CoreGui")
_G.ScreenGui.ResetOnSpawn = false
_G.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function makeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Мобильная кнопка-шестеренка
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 15, 0, 140)
OpenButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenButton.Text = "⚙️"
OpenButton.TextSize = 24
OpenButton.TextColor3 = Color3.fromRGB(186, 85, 211)
OpenButton.ZIndex = 11
OpenButton.Parent = _G.ScreenGui
makeDraggable(OpenButton)

Instance.new("UICorner", OpenButton).CornerRadius = UDim.new(1, 0)
local ButtonStroke = Instance.new("UIStroke", OpenButton)
ButtonStroke.Color = Color3.fromRGB(186, 85, 211)
ButtonStroke.Thickness = 1.5

-- Главное меню
_G.MainFrame = Instance.new("Frame")
_G.MainFrame.Size = UDim2.new(0, 410, 0, 260)
_G.MainFrame.Position = UDim2.new(0.5, -205, 0.5, -130)
_G.MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
_G.MainFrame.Visible = false
_G.MainFrame.ZIndex = 10
_G.MainFrame.Parent = _G.ScreenGui
makeDraggable(_G.MainFrame)

Instance.new("UICorner", _G.MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", _G.MainFrame)
MainStroke.Color = Color3.fromRGB(186, 85, 211)
MainStroke.Thickness = 1.5

_G.TopBar = Instance.new("Frame", _G.MainFrame)
_G.TopBar.Size = UDim2.new(1, 0, 0, 35)
_G.TopBar.BackgroundTransparency = 1
_G.TopBar.ZIndex = 11

local TopLayout = Instance.new("UIListLayout", _G.TopBar)
TopLayout.FillDirection = Enum.FillDirection.Horizontal
TopLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TopLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TopLayout.Padding = UDim.new(0, 12)

_G.Container = Instance.new("Frame", _G.MainFrame)
_G.Container.Size = UDim2.new(1, -20, 1, -50)
_G.Container.Position = UDim2.new(0, 10, 0, 40)
_G.Container.BackgroundTransparency = 1
_G.Container.ZIndex = 11

-- Отдельное окно MM2 (теперь намертво привязано к состоянию главного меню)
_G.MM2Window = Instance.new("Frame")
_G.MM2Window.Size = UDim2.new(0, 180, 0, 150)
_G.MM2Window.Position = UDim2.new(0.5, 215, 0.5, -75)
_G.MM2Window.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
_G.MM2Window.Visible = false
_G.MM2Window.ZIndex = 20
_G.MM2Window.Parent = _G.ScreenGui
makeDraggable(_G.MM2Window)

Instance.new("UICorner", _G.MM2Window).CornerRadius = UDim.new(0, 8)
local MM2Stroke = Instance.new("UIStroke", _G.MM2Window)
MM2Stroke.Color = Color3.fromRGB(255, 65, 65)
MM2Stroke.Thickness = 1.5

local MM2Title = Instance.new("TextLabel", _G.MM2Window)
MM2Title.Size = UDim2.new(1, 0, 0, 25)
MM2Title.BackgroundTransparency = 1
MM2Title.Text = "MM2 DASHBOARD"
MM2Title.TextColor3 = Color3.fromRGB(255, 65, 65)
MM2Title.Font = Enum.Font.SourceSansBold
MM2Title.TextSize = 12
MM2Title.ZIndex = 21

_G.MM2Content = Instance.new("Frame", _G.MM2Window)
_G.MM2Content.Size = UDim2.new(1, -10, 1, -35)
_G.MM2Content.Position = UDim2.new(0, 5, 0, 30)
_G.MM2Content.BackgroundTransparency = 1
_G.MM2Content.ZIndex = 21

local MM2Layout = Instance.new("UIListLayout", _G.MM2Content)
MM2Layout.Padding = UDim.new(0, 5)

-- Умный триггер переключения видимости окон одной кнопкой
OpenButton.MouseButton1Click:Connect(function()
    local newState = not _G.MainFrame.Visible
    _G.MainFrame.Visible = newState
    
    -- Окно MM2 открывается с меню, только если сам мод включен в чекбоксе
    if _G.Config.MM2Mod then
        _G.MM2Window.Visible = newState
    else
        _G.MM2Window.Visible = false
    end
end)
-- ====================================================================
--  BLOCK 3: TAB MANAGER & UI ELEMENT TEMPLATES
-- ====================================================================
local pages = {}
function _G.createTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 65, 0, 25)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(110, 110, 110)
    TabBtn.TextSize = 13
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.ZIndex = 12
    TabBtn.Parent = _G.TopBar

    local Page = Instance.new("ScrollingFrame", _G.Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.ScrollBarThickness = 0
    Page.ZIndex = 12

    local PageLayout = Instance.new("UIListLayout", Page)
    PageLayout.Padding = UDim.new(0, 6)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do
            p.Page.Visible = false
            p.Btn.TextColor3 = Color3.fromRGB(110, 110, 110)
        end
        Page.Visible = true
        TabBtn.TextColor3 = Color3.fromRGB(186, 85, 211)
    end)
    pages[name] = {Page = Page, Btn = TabBtn}
    return Page
end

_G.pPlayer = _G.createTab("Player")
_G.pVisual = _G.createTab("Visual")
_G.pGame = _G.createTab("Game")
_G.pOther = _G.createTab("Other")
_G.pSettings = _G.createTab("Settings")

pages["Player"].Page.Visible = true
pages["Player"].Btn.TextColor3 = Color3.fromRGB(186, 85, 211)

function _G.createFeatureWithLeftSlider(parent, configKey, speedKey, text, min, max)
    local BigWrapper = Instance.new("Frame", parent)
    BigWrapper.Size = UDim2.new(1, 0, 0, 30)
    BigWrapper.BackgroundTransparency = 1
    BigWrapper.ZIndex = 13

    local MainLine = Instance.new("Frame", BigWrapper)
    MainLine.Size = UDim2.new(1, 0, 0, 30)
    MainLine.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainLine.ZIndex = 14
    Instance.new("UICorner", MainLine).CornerRadius = UDim.new(0, 5)

    local ToggleBtn = Instance.new("TextButton", MainLine)
    ToggleBtn.Size = UDim2.new(0, 20, 0, 20)
    ToggleBtn.Position = UDim2.new(0, 5, 0, 5)
    ToggleBtn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(30, 30, 30)
    ToggleBtn.Text = ""
    ToggleBtn.ZIndex = 15
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)

    local Label = Instance.new("TextLabel", MainLine)
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 35, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.ZIndex = 15

    local GearBtn = Instance.new("TextButton", MainLine)
    GearBtn.Size = UDim2.new(0, 25, 0, 25)
    GearBtn.Position = UDim2.new(1, -30, 0, 2)
    GearBtn.BackgroundTransparency = 1
    GearBtn.Text = "⚙️"
    GearBtn.TextSize = 14
    GearBtn.ZIndex = 15

    local SliderPanel = Instance.new("Frame", BigWrapper)
    SliderPanel.Size = UDim2.new(1, 0, 0, 0)
    SliderPanel.Position = UDim2.new(0, 0, 0, 30)
    SliderPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SliderPanel.ClipsDescendants = true
    SliderPanel.ZIndex = 13
    Instance.new("UICorner", SliderPanel).CornerRadius = UDim.new(0, 5)

    local SliderBar = Instance.new("Frame", SliderPanel)
    SliderBar.Size = UDim2.new(1, -40, 0, 6)
    SliderBar.Position = UDim2.new(0, 10, 0, 12)
    SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SliderBar.ZIndex = 14

    local SliderFill = Instance.new("Frame", SliderBar)
    SliderFill.Size = UDim2.new((_G.Config[speedKey] - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(186, 85, 211)
    SliderFill.ZIndex = 15

    local ValueLabel = Instance.new("TextLabel", SliderPanel)
    ValueLabel.Size = UDim2.new(0, 30, 0, 20)
    ValueLabel.Position = UDim2.new(1, -35, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(_G.Config[speedKey])
    ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueLabel.Font = Enum.Font.SourceSansBold
    ValueLabel.TextSize = 12
    ValueLabel.ZIndex = 15

    local function updateSlider(input)
        local percentage = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (percentage * (max - min)))
        _G.Config[speedKey] = value
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        ValueLabel.Text = tostring(value)
        _G.saveSettings()
    end

    local sliding = false
    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            updateSlider(input)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    local panelOpen = false
    GearBtn.MouseButton1Click:Connect(function()
        panelOpen = not panelOpen
        SliderPanel:TweenSize(UDim2.new(1, 0, 0, panelOpen and 30 or 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
        BigWrapper:TweenSize(UDim2.new(1, 0, 0, panelOpen and 60 or 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
    end)

    local stateCallback = nil
    ToggleBtn.MouseButton1Click:Connect(function()
        _G.Config[configKey] = not _G.Config[configKey]
        ToggleBtn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(30, 30, 30)
        _G.saveSettings()
        if stateCallback then stateCallback(_G.Config[configKey]) end
    end)

    return { OnToggle = function(callback) stateCallback = callback end }
end

function _G.createCheckbox(parent, configKey, text)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 5)

    local ToggleBtn = Instance.new("TextButton", Frame)
    ToggleBtn.Size = UDim2.new(0, 20, 0, 20)
    ToggleBtn.Position = UDim2.new(0, 5, 0, 5)
    ToggleBtn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(30, 30, 30)
    ToggleBtn.Text = ""
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -35, 1, 0)
    Label.Position = UDim2.new(0, 35, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14

    local stateCallback = nil
    ToggleBtn.MouseButton1Click:Connect(function()
        _G.Config[configKey] = not _G.Config[configKey]
        ToggleBtn.BackgroundColor3 = _G.Config[configKey] and Color3.fromRGB(186, 85, 211) or Color3.fromRGB(30, 30, 30)
        _G.saveSettings()
        if stateCallback then stateCallback(_G.Config[configKey]) end
    end)
    return { OnToggle = function(callback) stateCallback = callback end }
end
-- ====================================================================
--  BLOCK 4: PLAYER CHEATS CORE & PHYSICS LOOP (MOBILE ENGINE)
-- ====================================================================
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local speedCheat = _G.createFeatureWithLeftSlider(_G.pPlayer, "Speedhack", "SpeedValue", " WalkSpeed Hack", 16, 250)
speedCheat.OnToggle(function(state)
    if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
    end
end)

local flyCheat = _G.createFeatureWithLeftSlider(_G.pPlayer, "FlyMode", "FlySpeedValue", " Fly Mode (Лететь по камере)", 10, 200)
flyCheat.OnToggle(function(state)
    if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
    end
end)

local spinCheat = _G.createFeatureWithLeftSlider(_G.pPlayer, "SpinBot", "SpinSpeed", " Spin Bot", 10, 150)
local noclipCheat = _G.createCheckbox(_G.pPlayer, "Noclip", "Noclip (Сквозь стены)")

-- Единый мобильный цикл физики движений
RunService.Stepped:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = LocalPlayer.Character.HumanoidRootPart
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

    -- 1. Безопасный Noclip для сенсорного экрана
    if _G.Config.Noclip then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then 
                part.CanCollide = false 
            end
        end
    end

    -- 2. Спидхак
    if hum and _G.Config.Speedhack and not _G.Config.FlyMode then
        hum.WalkSpeed = _G.Config.SpeedValue
    end

    -- 3. Спинбот
    if _G.Config.SpinBot then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(_G.Config.SpinSpeed), 0)
    end

    -- 4. Управление полетом джойстиком по направлению мобильной камеры
    if _G.Config.FlyMode then
        if not root:FindFirstChild("FlyVelocity") then
            local flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.Name = "FlyVelocity"
            flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyVelocity.Velocity = Vector3.new(0, 0, 0)
            flyVelocity.Parent = root
        end
        
        local camera = workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)
        
        if hum and hum.MoveDirection.Magnitude > 0 then
            moveDirection = hum.MoveDirection
            local look = camera.CFrame.LookVector
            moveDirection = Vector3.new(moveDirection.X, look.Y, moveDirection.Z)
        end
        
        if moveDirection.Magnitude > 0 then
            root.FlyVelocity.Velocity = moveDirection.Unit * _G.Config.FlySpeedValue
        else
            root.FlyVelocity.Velocity = Vector3.new(0, 0.05, 0)
        end
    else
        if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
    end
end)
-- ====================================================================
--  BLOCK 5: ADVANCED CHAMS ESP & COLOR-CODED MM2 RADAR
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local espCheat = _G.createCheckbox(_G.pVisual, "ESPToggle", "Включить Chams ESP (Заливка тела)")
local chamsObjects = {}

-- Определение роли игрока в MM2 для покраски ESP и Радара
local function getMM2Role(player)
    if not player.Character then return "Innocent", Color3.fromRGB(255, 255, 255) end
    
    if player.Character:FindFirstChild("Knife") or player.Backpack:FindFirstChild("Knife") then
        return "MURDERER 🔪", Color3.fromRGB(255, 50, 50) -- Красный
    elseif player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun") then
        return "SHERIFF 🔫", Color3.fromRGB(50, 150, 255) -- Синий
    end
    
    return "Innocent", Color3.fromRGB(255, 255, 255) -- Белый
end

-- Функция создания красивой заливки тела (Chams)
local function applyChams(player)
    if player == LocalPlayer then return end
    
    local function updateChams()
        if not player.Character then return end
        
        local highlight = player.Character:FindFirstChild("NeonESP")
        if _G.Config.ESPToggle then
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "NeonESP"
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Видно сквозь стены!
                highlight.FillTransparency = 0.5 -- Прозрачность заливки тела
                highlight.OutlineTransparency = 0.1 -- Прозрачность контура
                highlight.Parent = player.Character
            end
            
            -- Если включен мод MM2, красим Chams в цвет роли, иначе — в белый
            if _G.Config.MM2Mod then
                local _, roleColor = getMM2Role(player)
                highlight.FillColor = roleColor
                highlight.OutlineColor = roleColor
            else
                highlight.FillColor = Color3.fromRGB(186, 85, 211) -- Фирменный фиолетовый неон
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            end
        else
            if highlight then highlight:Destroy() end
        end
    end
    
    local conn = RunService.RenderStepped:Connect(updateChams)
    chamsObjects[player] = conn
end

-- Отслеживание игроков для ESP
Players.PlayerAdded:Connect(applyChams)
for _, p in pairs(Players:GetPlayers()) do applyChams(p) end
Players.PlayerRemoving:Connect(function(p)
    if chamsObjects[p] then
        chamsObjects[p]:Disconnect()
        chamsObjects[p] = nil
    end
    if p.Character and p.Character:FindFirstChild("NeonESP") then
        p.Character.NeonESP:Destroy()
    end
end)

-- Включение мода MM2
local mm2Cheat = _G.createCheckbox(_G.pGame, "MM2Mod", "Активировать Murder Mystery 2 Мод")
mm2Cheat.OnToggle(function(state)
    -- Окно открывается только если открыто главное меню читов
    if _G.MainFrame.Visible then
        _G.MM2Window.Visible = state
    end
end)

-- Обновление радара MM2 с цветными никами
local function updateMM2Radar()
    if not _G.Config.MM2Mod then return end
    _G.MM2Content:ClearAllChildren()
    
    local layout = Instance.new("UIListLayout", _G.MM2Content)
    layout.Padding = UDim.new(0, 4)

    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local roleName, roleColor = getMM2Role(p)

            -- Выводим на панель только важные роли (Убийцу и Шерифа)
            if roleName ~= "Innocent" then
                local lbl = Instance.new("TextLabel", _G.MM2Content)
                lbl.Size = UDim2.new(1, 0, 0, 18)
                lbl.BackgroundTransparency = 1
                lbl.Text = string.sub(p.Name, 1, 12) .. ": " .. roleName
                lbl.TextColor3 = roleColor -- Красим текст в цвет роли!
                lbl.Font = Enum.Font.SourceSansBold
                lbl.TextSize = 13
                lbl.ZIndex = 22
            end
        end
    end
end

-- Цикл проверки ролей раз в секунду
task.spawn(function()
    while task.wait(1) do
        if _G.Config.MM2Mod then pcall(updateMM2Radar) end
    end
end)

-- Кнопка сброса настроек во вкладке Settings
local ResetBtn = Instance.new("TextButton", _G.pSettings)
ResetBtn.Size = UDim2.new(1, 0, 0, 30)
ResetBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
ResetBtn.Text = "Сбросить конфигурацию читов"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.Font = Enum.Font.SourceSansBold
ResetBtn.TextSize = 14
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 5)

ResetBtn.MouseButton1Click:Connect(function()
    if delfile and isfile("SimpleNeon_Config.json") then
        delfile("SimpleNeon_Config.json")
    end
    if game:GetService("CoreGui"):FindFirstChild("SimpleNeonSense") then
        game:GetService("CoreGui").SimpleNeonSense:Destroy()
    end
end)
