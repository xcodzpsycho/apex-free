-- APEX HUB Utility-Script (Fly Safe Ground Drop Fixed)
-- Ausführen in einem LocalScript (z. B. StarterPlayerScripts oder StarterGui)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Statusvariablen
local espEnabled = false
local rolesEnabled = false
local speedEnabled = false
local infJumpEnabled = false
local noclipEnabled = false
local flyEnabled = false
local antiFlingEnabled = true
local currentSpeed = 50
local currentFlySpeed = 50
local currentMode = "Normal"

local savedPositionRed = nil
local savedPositionGreen = nil
local tpVisualPartRed = nil
local tpVisualPartGreen = nil

local registeredToggles = {}
local registeredSpeedInputs = {}

local themes = {
    Dark = {
        Primary = Color3.fromRGB(15, 15, 15),
        TopGrad1 = Color3.fromRGB(40, 40, 40),
        TopGrad2 = Color3.fromRGB(20, 20, 20),
        Stroke = Color3.fromRGB(70, 70, 70),
        ButtonOn = Color3.fromRGB(40, 160, 90),
        ButtonOff = Color3.fromRGB(25, 25, 25)
    },
    Purple = {
        Primary = Color3.fromRGB(20, 20, 25),
        TopGrad1 = Color3.fromRGB(90, 40, 180),
        TopGrad2 = Color3.fromRGB(40, 100, 220),
        Stroke = Color3.fromRGB(80, 50, 150),
        ButtonOn = Color3.fromRGB(60, 180, 110),
        ButtonOff = Color3.fromRGB(35, 35, 45)
    },
    Ocean = {
        Primary = Color3.fromRGB(15, 25, 35),
        TopGrad1 = Color3.fromRGB(0, 120, 210),
        TopGrad2 = Color3.fromRGB(0, 190, 160),
        Stroke = Color3.fromRGB(0, 150, 200),
        ButtonOn = Color3.fromRGB(0, 180, 130),
        ButtonOff = Color3.fromRGB(25, 40, 55)
    },
    Crimson = {
        Primary = Color3.fromRGB(25, 15, 15),
        TopGrad1 = Color3.fromRGB(180, 40, 40),
        TopGrad2 = Color3.fromRGB(220, 100, 40),
        Stroke = Color3.fromRGB(180, 60, 60),
        ButtonOn = Color3.fromRGB(50, 180, 100),
        ButtonOff = Color3.fromRGB(40, 25, 25)
    },
    Emerald = {
        Primary = Color3.fromRGB(15, 25, 20),
        TopGrad1 = Color3.fromRGB(30, 160, 80),
        TopGrad2 = Color3.fromRGB(20, 100, 120),
        Stroke = Color3.fromRGB(40, 180, 100),
        ButtonOn = Color3.fromRGB(40, 200, 120),
        ButtonOff = Color3.fromRGB(25, 40, 35)
    },
    Sunset = {
        Primary = Color3.fromRGB(30, 20, 25),
        TopGrad1 = Color3.fromRGB(220, 80, 120),
        TopGrad2 = Color3.fromRGB(240, 140, 60),
        Stroke = Color3.fromRGB(200, 90, 130),
        ButtonOn = Color3.fromRGB(80, 200, 120),
        ButtonOff = Color3.fromRGB(45, 30, 40)
    },
    Cyberpunk = {
        Primary = Color3.fromRGB(18, 18, 30),
        TopGrad1 = Color3.fromRGB(255, 0, 128),
        TopGrad2 = Color3.fromRGB(0, 240, 255),
        Stroke = Color3.fromRGB(255, 0, 128),
        ButtonOn = Color3.fromRGB(0, 255, 128),
        ButtonOff = Color3.fromRGB(30, 30, 50)
    },
    Matrix = {
        Primary = Color3.fromRGB(10, 20, 10),
        TopGrad1 = Color3.fromRGB(0, 200, 80),
        TopGrad2 = Color3.fromRGB(0, 100, 40),
        Stroke = Color3.fromRGB(0, 255, 100),
        ButtonOn = Color3.fromRGB(0, 255, 120),
        ButtonOff = Color3.fromRGB(20, 35, 20)
    },
    Midnight = {
        Primary = Color3.fromRGB(12, 15, 22),
        TopGrad1 = Color3.fromRGB(70, 90, 200),
        TopGrad2 = Color3.fromRGB(30, 40, 90),
        Stroke = Color3.fromRGB(90, 110, 220),
        ButtonOn = Color3.fromRGB(50, 200, 150),
        ButtonOff = Color3.fromRGB(22, 28, 40)
    }
}
local currentThemeName = "Dark"

if CoreGui:FindFirstChild("APEXHUBGui") then CoreGui.APEXHUBGui:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild("APEXHUBGui") then LocalPlayer.PlayerGui.APEXHUBGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "APEXHUBGui"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local function bindClick(button, callback)
    local debounce = false
    button.Activated:Connect(function()
        if debounce then return end
        debounce = true
        task.spawn(callback)
        task.wait(0.15)
        debounce = false
    end)
end

local DeviceSelectorGui = Instance.new("Frame")
DeviceSelectorGui.Name = "DeviceSelector"
DeviceSelectorGui.Size = UDim2.new(0, 300, 0, 270)
DeviceSelectorGui.Position = UDim2.new(0.5, -150, 0.5, -135)
DeviceSelectorGui.BackgroundColor3 = themes.Dark.Primary
DeviceSelectorGui.BorderSizePixel = 0
DeviceSelectorGui.Active = true
DeviceSelectorGui.Draggable = true
DeviceSelectorGui.Parent = ScreenGui

local dsCorner = Instance.new("UICorner", DeviceSelectorGui)
dsCorner.CornerRadius = UDim.new(0, 10)
local dsStroke = Instance.new("UIStroke", DeviceSelectorGui)
dsStroke.Color = themes.Dark.Stroke
dsStroke.Thickness = 1.5

local dsTitle = Instance.new("TextLabel", DeviceSelectorGui)
dsTitle.Size = UDim2.new(1, 0, 0, 40)
dsTitle.BackgroundTransparency = 1
dsTitle.Text = "Choose Your Device"
dsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
dsTitle.TextSize = 16
dsTitle.Font = Enum.Font.GothamBold

local dsWarning = Instance.new("TextLabel", DeviceSelectorGui)
dsWarning.Size = UDim2.new(1, -20, 0, 60)
dsWarning.Position = UDim2.new(0, 10, 0, 42)
dsWarning.BackgroundTransparency = 1
dsWarning.Text = "Warning: Choosing the wrong device will mess up your menu\nRejoin if you select the wrong device"
dsWarning.TextColor3 = Color3.fromRGB(255, 80, 80)
dsWarning.TextSize = 10
dsWarning.Font = Enum.Font.GothamMedium
dsWarning.TextWrapped = true

local dsListLayout = Instance.new("UIListLayout", DeviceSelectorGui)
dsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
dsListLayout.Padding = UDim.new(0, 6)
dsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local spacer = Instance.new("Frame", DeviceSelectorGui)
spacer.Size = UDim2.new(1, 0, 0, 95)
spacer.BackgroundTransparency = 1
spacer.LayoutOrder = 1

local function createSelectorButton(name, scaleValue)
    local btn = Instance.new("TextButton", DeviceSelectorGui)
    btn.Size = UDim2.new(0, 260, 0, 32)
    btn.BackgroundColor3 = themes.Dark.ButtonOff
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    bindClick(btn, function()
        DeviceSelectorGui:Destroy()
        loadMainHub(scaleValue)
    end)
end

createSelectorButton("Tablet", 0.85)
createSelectorButton("Phone", 0.7)
createSelectorButton("PC/Laptop", 1.0)

function loadMainHub(scale)
    local baseW = math.floor(210 * scale)
    local baseH = math.floor(420 * scale)
    local rightW = math.floor(140 * scale)
    local rightH = math.floor(640 * scale)
    local textSize = math.floor(12 * scale)
    local topBarH = math.floor(32 * scale)

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, baseW, 0, baseH)
    MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
    MainFrame.BackgroundColor3 = themes[currentThemeName].Primary
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, math.floor(10 * scale))
    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = themes[currentThemeName].Stroke
    UIStroke.Thickness = 1.5

    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, 0, 0, topBarH)
    TopBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TopBar.BorderSizePixel = 0
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, math.floor(10 * scale))

    local UIGradient = Instance.new("UIGradient", TopBar)
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, themes[currentThemeName].TopGrad1),
        ColorSequenceKeypoint.new(1, themes[currentThemeName].TopGrad2)
    })

    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(1, -math.floor(35 * scale), 1, 0)
    Title.Position = UDim2.new(0, math.floor(10 * scale), 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "APEX HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = math.floor(13 * scale)
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local MinimizeBtn = Instance.new("TextButton", TopBar)
    MinimizeBtn.Size = UDim2.new(0, math.floor(28 * scale), 0, math.floor(28 * scale))
    MinimizeBtn.Position = UDim2.new(1, -math.floor(32 * scale), 0, math.floor(2 * scale))
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "-"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize = math.floor(18 * scale)
    MinimizeBtn.Font = Enum.Font.GothamBold

    local ContentFrame = Instance.new("ScrollingFrame", MainFrame)
    ContentFrame.Size = UDim2.new(1, -math.floor(12 * scale), 1, -topBarH - 8)
    ContentFrame.Position = UDim2.new(0, math.floor(6 * scale), 0, topBarH + 4)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.BorderSizePixel = 0
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, math.floor(780 * scale))
    ContentFrame.ScrollBarThickness = math.floor(2 * scale)

    local UIListLayout = Instance.new("UIListLayout", ContentFrame)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, math.floor(6 * scale))

    local RightButtonsContainer = Instance.new("Frame", ScreenGui)
    RightButtonsContainer.Name = "RightButtonsContainer"
    RightButtonsContainer.Size = UDim2.new(0, rightW, 0, rightH)
    RightButtonsContainer.Position = UDim2.new(1, -rightW - math.floor(10 * scale), 0.005, 0)
    RightButtonsContainer.BackgroundTransparency = 1
    RightButtonsContainer.Visible = false

    local RightListLayout = Instance.new("UIListLayout", RightButtonsContainer)
    RightListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    RightListLayout.Padding = UDim.new(0, math.floor(6 * scale))

    local function teleportToPlayer(target)
        pcall(function()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                end
            end
        end)
    end

    local function flingPlayer(target)
        pcall(function()
            local targetChar = target and target.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            local myChar = LocalPlayer.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            
            if not targetRoot or not myRoot then return end

            local originalPos = myRoot.CFrame
            local oldGrav = workspace.Gravity
            workspace.Gravity = 0

            local tool = myChar:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end

            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = myRoot

            local connection
            connection = RunService.Heartbeat:Connect(function()
                pcall(function()
                    if targetRoot and myRoot then
                        myRoot.CFrame = targetRoot.CFrame
                        myRoot.AssemblyLinearVelocity = Vector3.new(999999, 999999, 999999)
                        myRoot.AssemblyAngularVelocity = Vector3.new(999999, 999999, 999999)
                    end
                end)
            end)

            task.wait(0.5)

            if connection then connection:Disconnect() end
            if bv then bv:Destroy() end
            workspace.Gravity = oldGrav

            if myRoot then
                myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                myRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                myRoot.CFrame = originalPos
            end
        end)
    end

    local function updateMode(modeName)
        currentMode = modeName
        if modeName == "Buttons" then
            RightButtonsContainer.Visible = true
            MainFrame.Visible = true
            for _, el in ipairs(ContentFrame:GetChildren()) do
                if el:IsA("GuiObject") then
                    el.Visible = (el.Name == "DropdownContainer" or el.Name == "FlingDropdownContainer")
                end
            end
        else
            RightButtonsContainer.Visible = false
            MainFrame.Visible = true
            for _, el in ipairs(ContentFrame:GetChildren()) do
                if el:IsA("GuiObject") then el.Visible = true end
            end
        end
    end

    local function applyTheme(themeName)
        local t = themes[themeName]
        if not t then return end
        currentThemeName = themeName

        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(MainFrame, tweenInfo, {BackgroundColor3 = t.Primary}):Play()
        TweenService:Create(UIStroke, tweenInfo, {Color = t.Stroke}):Play()

        UIGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, t.TopGrad1),
            ColorSequenceKeypoint.new(1, t.TopGrad2)
        })

        for text, data in pairs(registeredToggles) do
            for _, b in ipairs(data.buttons) do
                if b and b.Parent then
                    b.BackgroundColor3 = data.state and t.ButtonOn or t.ButtonOff
                end
            end
        end
    end

    local function registerToggle(identifier, defaultState, callback)
        if not registeredToggles[identifier] then
            registeredToggles[identifier] = {
                state = defaultState or false,
                buttons = {},
                callback = callback
            }
        end
        return registeredToggles[identifier]
    end

    local function setToggleState(identifier, newState)
        local data = registeredToggles[identifier]
        if not data then return end
        data.state = newState

        local t = themes[currentThemeName]
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local goalColor = data.state and t.ButtonOn or t.ButtonOff

        for _, b in ipairs(data.buttons) do
            if b and b.Parent then
                TweenService:Create(b, tweenInfo, {BackgroundColor3 = goalColor}):Play()
                b.Text = identifier .. (data.state and ": ON" or ": OFF")
            end
        end

        if data.callback then
            task.spawn(function()
                pcall(function()
                    data.callback(data.state)
                end)
            end)
        end
    end

    local function createButtonGen(parentContainer, text, callback, isToggle, defaultState, customSize, customTextSize)
        local btn = Instance.new("TextButton", parentContainer)
        btn.Size = customSize or UDim2.new(1, 0, 0, math.floor(32 * scale))
        
        local data
        if isToggle then
            data = registerToggle(text, defaultState, callback)
            table.insert(data.buttons, btn)
            btn.BackgroundColor3 = data.state and themes[currentThemeName].ButtonOn or themes[currentThemeName].ButtonOff
            btn.Text = text .. (data.state and ": ON" or ": OFF")
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = themes[currentThemeName].ButtonOff
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(170, 170, 170)
        end

        btn.BorderSizePixel = 0
        btn.TextSize = customTextSize or textSize
        btn.Font = Enum.Font.GothamMedium
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, math.floor(6 * scale))

        if isToggle then
            bindClick(btn, function()
                setToggleState(text, not data.state)
            end)
        else
            bindClick(btn, function()
                local oldColor = btn.BackgroundColor3
                local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(btn, tweenInfo, {BackgroundColor3 = themes[currentThemeName].Stroke}):Play()
                task.wait(0.1)
                TweenService:Create(btn, tweenInfo, {BackgroundColor3 = oldColor}):Play()
                pcall(callback)
            end)
        end
        return btn
    end

    local function createButton(text, callback, isToggle, defaultState)
        return createButtonGen(ContentFrame, text, callback, isToggle, defaultState)
    end

    local function createRightButton(text, callback, isToggle, defaultState)
        return createButtonGen(RightButtonsContainer, text, callback, isToggle, defaultState, UDim2.new(1, 0, 0, math.floor(30 * scale)), math.floor(11 * scale))
    end

    local function createDropdown(name, options, callback)
        local container = Instance.new("Frame", ContentFrame)
        container.Name = "DropdownContainer"
        container.Size = UDim2.new(1, 0, 0, math.floor(32 * scale))
        container.BackgroundColor3 = themes[currentThemeName].ButtonOff
        container.BorderSizePixel = 0
        container.ClipsDescendants = true
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, math.floor(6 * scale))

        local selectBtn = Instance.new("TextButton", container)
        selectBtn.Size = UDim2.new(1, 0, 1, 0)
        selectBtn.BackgroundTransparency = 1
        selectBtn.Text = " " .. name .. ": " .. tostring(options[1])
        selectBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        selectBtn.TextSize = textSize
        selectBtn.Font = Enum.Font.GothamMedium
        selectBtn.TextXAlignment = Enum.TextXAlignment.Left

        local arrow = Instance.new("TextLabel", container)
        arrow.Size = UDim2.new(0, math.floor(25 * scale), 1, 0)
        arrow.Position = UDim2.new(1, -math.floor(25 * scale), 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▼"
        arrow.TextColor3 = Color3.fromRGB(180, 180, 180)
        arrow.TextSize = math.floor(11 * scale)

        local listContainer = Instance.new("ScrollingFrame", container)
        listContainer.Size = UDim2.new(1, -4, 0, math.floor(120 * scale))
        listContainer.Position = UDim2.new(0, 2, 0, math.floor(34 * scale))
        listContainer.BackgroundTransparency = 1
        listContainer.BorderSizePixel = 0
        listContainer.CanvasSize = UDim2.new(0, 0, 0, #options * math.floor(32 * scale))
        listContainer.ScrollBarThickness = 2
        listContainer.Visible = false

        local listLayout = Instance.new("UIListLayout", listContainer)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 2)

        for _, optName in ipairs(options) do
            local optBtn = Instance.new("TextButton", listContainer)
            optBtn.Size = UDim2.new(1, 0, 0, math.floor(30 * scale))
            optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            optBtn.BorderSizePixel = 0
            optBtn.Text = tostring(optName)
            optBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
            optBtn.TextSize = math.floor(11 * scale)
            optBtn.Font = Enum.Font.Gotham
            Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 5)

            bindClick(optBtn, function()
                pcall(function() callback(optName) end)
                selectBtn.Text = " " .. name .. ": " .. tostring(optName)
                container.Size = UDim2.new(1, 0, 0, math.floor(32 * scale))
                listContainer.Visible = false
                arrow.Text = "▼"
            end)
        end

        local isOpen = false
        bindClick(selectBtn, function()
            isOpen = not isOpen
            local targetSize = isOpen and UDim2.new(1, 0, 0, math.floor(160 * scale)) or UDim2.new(1, 0, 0, math.floor(32 * scale))
            TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
            listContainer.Visible = isOpen
            arrow.Text = isOpen and "▲" or "▼"
        end)
    end

    local function createPlayerDropdown(parentContainer)
        local container = Instance.new("Frame", parentContainer)
        container.Name = "DropdownContainer"
        container.Size = UDim2.new(1, 0, 0, math.floor(32 * scale))
        container.BackgroundColor3 = themes[currentThemeName].ButtonOff
        container.BorderSizePixel = 0
        container.ClipsDescendants = true
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, math.floor(6 * scale))
        
        local selectBtn = Instance.new("TextButton", container)
        selectBtn.Size = UDim2.new(1, 0, 1, 0)
        selectBtn.BackgroundTransparency = 1
        selectBtn.Text = " TP to Player: [Choose]"
        selectBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        selectBtn.TextSize = math.floor(11 * scale)
        selectBtn.Font = Enum.Font.GothamMedium
        selectBtn.TextXAlignment = Enum.TextXAlignment.Left
        
        local arrow = Instance.new("TextLabel", container)
        arrow.Size = UDim2.new(0, math.floor(25 * scale), 1, 0)
        arrow.Position = UDim2.new(1, -math.floor(25 * scale), 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▼"
        arrow.TextColor3 = Color3.fromRGB(180, 180, 180)
        arrow.TextSize = math.floor(11 * scale)
        
        local listContainer = Instance.new("ScrollingFrame", container)
        listContainer.Size = UDim2.new(1, -4, 0, math.floor(120 * scale))
        listContainer.Position = UDim2.new(0, 2, 0, math.floor(34 * scale))
        listContainer.BackgroundTransparency = 1
        listContainer.BorderSizePixel = 0
        listContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        listContainer.ScrollBarThickness = 2
        listContainer.Visible = false
        
        local listLayout = Instance.new("UIListLayout", listContainer)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 3)
        
        local function refreshPlayers()
            for _, child in ipairs(listContainer:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            local count = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    count = count + 1
                    local pBtn = Instance.new("TextButton", listContainer)
                    pBtn.Size = UDim2.new(1, 0, 0, math.floor(28 * scale))
                    pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                    pBtn.BorderSizePixel = 0
                    pBtn.Text = p.Name
                    pBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
                    pBtn.TextSize = math.floor(11 * scale)
                    pBtn.Font = Enum.Font.Gotham
                    Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)
                    
                    bindClick(pBtn, function()
                        teleportToPlayer(p)
                        selectBtn.Text = " TP: " .. p.Name
                        container.Size = UDim2.new(1, 0, 0, math.floor(32 * scale))
                        listContainer.Visible = false
                        arrow.Text = "▼"
                    end)
                end
            end
            listContainer.CanvasSize = UDim2.new(0, 0, 0, count * math.floor(31 * scale))
        end
        
        local isOpen = false
        bindClick(selectBtn, function()
            isOpen = not isOpen
            if isOpen then refreshPlayers() end
            local targetSize = isOpen and UDim2.new(1, 0, 0, math.floor(155 * scale)) or UDim2.new(1, 0, 0, math.floor(32 * scale))
            TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
            listContainer.Visible = isOpen
            arrow.Text = isOpen and "▲" or "▼"
        end)
    end

    local function createFlingDropdown(parentContainer)
        local container = Instance.new("Frame", parentContainer)
        container.Name = "FlingDropdownContainer"
        container.Size = UDim2.new(1, 0, 0, math.floor(32 * scale))
        container.BackgroundColor3 = themes[currentThemeName].ButtonOff
        container.BorderSizePixel = 0
        container.ClipsDescendants = true
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, math.floor(6 * scale))
        
        local selectBtn = Instance.new("TextButton", container)
        selectBtn.Size = UDim2.new(1, 0, 1, 0)
        selectBtn.BackgroundTransparency = 1
        selectBtn.Text = " Dropkick Fling: [Choose]"
        selectBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        selectBtn.TextSize = math.floor(11 * scale)
        selectBtn.Font = Enum.Font.GothamMedium
        selectBtn.TextXAlignment = Enum.TextXAlignment.Left
        
        local arrow = Instance.new("TextLabel", container)
        arrow.Size = UDim2.new(0, math.floor(25 * scale), 1, 0)
        arrow.Position = UDim2.new(1, -math.floor(25 * scale), 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "▼"
        arrow.TextColor3 = Color3.fromRGB(180, 180, 180)
        arrow.TextSize = math.floor(11 * scale)
        
        local listContainer = Instance.new("ScrollingFrame", container)
        listContainer.Size = UDim2.new(1, -4, 0, math.floor(120 * scale))
        listContainer.Position = UDim2.new(0, 2, 0, math.floor(34 * scale))
        listContainer.BackgroundTransparency = 1
        listContainer.BorderSizePixel = 0
        listContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        listContainer.ScrollBarThickness = 2
        listContainer.Visible = false
        
        local listLayout = Instance.new("UIListLayout", listContainer)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 3)
        
        local function refreshPlayers()
            for _, child in ipairs(listContainer:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            local count = 0
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    count = count + 1
                    local pBtn = Instance.new("TextButton", listContainer)
                    pBtn.Size = UDim2.new(1, 0, 0, math.floor(28 * scale))
                    pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                    pBtn.BorderSizePixel = 0
                    pBtn.Text = p.Name
                    pBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
                    pBtn.TextSize = math.floor(11 * scale)
                    pBtn.Font = Enum.Font.Gotham
                    Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)
                    
                    bindClick(pBtn, function()
                        selectBtn.Text = " Hit: " .. p.Name
                        container.Size = UDim2.new(1, 0, 0, math.floor(32 * scale))
                        listContainer.Visible = false
                        arrow.Text = "▼"
                        flingPlayer(p)
                        task.wait(1)
                        selectBtn.Text = " Dropkick Fling: [Choose]"
                    end)
                end
            end
            listContainer.CanvasSize = UDim2.new(0, 0, 0, count * math.floor(31 * scale))
        end
        
        local isOpen = false
        bindClick(selectBtn, function()
            isOpen = not isOpen
            if isOpen then refreshPlayers() end
            local targetSize = isOpen and UDim2.new(1, 0, 0, math.floor(155 * scale)) or UDim2.new(1, 0, 0, math.floor(32 * scale))
            TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
            listContainer.Visible = isOpen
            arrow.Text = isOpen and "▲" or "▼"
        end)
    end

    local function createSpeedInputGen(parentContainer, labelText, defaultVal, min, max, callback, customSize, customTextSize)
        local container = Instance.new("Frame", parentContainer)
        container.Size = customSize or UDim2.new(1, 0, 0, math.floor(32 * scale))
        container.BackgroundColor3 = themes[currentThemeName].ButtonOff
        container.BorderSizePixel = 0
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, math.floor(6 * scale))

        local label = Instance.new("TextLabel", container)
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Position = UDim2.new(0, math.floor(8 * scale), 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = customTextSize or textSize
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left

        local textbox = Instance.new("TextBox", container)
        textbox.Size = UDim2.new(0, math.floor(50 * scale), 0, math.floor(22 * scale))
        textbox.Position = UDim2.new(1, -math.floor(56 * scale), 0.5, -math.floor(11 * scale))
        textbox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        textbox.BorderSizePixel = 0
        textbox.Text = tostring(defaultVal)
        textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
        textbox.TextSize = customTextSize or textSize
        textbox.Font = Enum.Font.GothamBold
        textbox.ClearTextOnFocus = true
        Instance.new("UICorner", textbox).CornerRadius = UDim.new(0, 4)

        if not registeredSpeedInputs[labelText] then registeredSpeedInputs[labelText] = {} end
        table.insert(registeredSpeedInputs[labelText], textbox)

        textbox.FocusLost:Connect(function()
            local num = tonumber(textbox.Text)
            if num then
                local clamped = math.clamp(num, min, max)
                local strVal = tostring(clamped)
                for _, tb in ipairs(registeredSpeedInputs[labelText]) do tb.Text = strVal end
                pcall(function() callback(clamped) end)
            else
                local defStr = tostring(defaultVal)
                for _, tb in ipairs(registeredSpeedInputs[labelText]) do tb.Text = defStr end
                pcall(function() callback(defaultVal) end)
            end
        end)
    end

    local function createSpeedInput(labelText, defaultVal, min, max, callback)
        createSpeedInputGen(ContentFrame, labelText, defaultVal, min, max, callback)
    end

    local function createRightSpeedInput(labelText, defaultVal, min, max, callback)
        createSpeedInputGen(RightButtonsContainer, labelText, defaultVal, min, max, callback, UDim2.new(1, 0, 0, math.floor(30 * scale)), math.floor(10 * scale))
    end

    local minimized = false
    bindClick(MinimizeBtn, function()
        minimized = not minimized
        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if minimized then
            ContentFrame.Visible = false
            TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, baseW, 0, topBarH)}):Play()
            MinimizeBtn.Text = "+"
        else
            TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, baseW, 0, baseH)}):Play()
            task.wait(0.1)
            ContentFrame.Visible = true
            MinimizeBtn.Text = "-"
        end
    end)

    local function getPlayerRole(player)
        local success, role, col = pcall(function()
            if not player.Character then return "Innocent", Color3.fromRGB(50, 255, 100) end
            local backpack = player:FindFirstChildOfClass("Backpack")
            local character = player.Character

            local function checkTool(item)
                if item:IsA("Tool") then
                    local name = item.Name:lower()
                    if name:find("knife") or name:find("murder") then
                        return "Murderer", Color3.fromRGB(255, 50, 50)
                    elseif name:find("gun") or name:find("revolver") or name:find("sheriff") then
                        return "Sheriff", Color3.fromRGB(50, 150, 255)
                    end
                end
                return nil
            end

            if backpack then
                for _, item in ipairs(backpack:GetChildren()) do
                    local r, c = checkTool(item)
                    if r then return r, c end
                end
            end
            for _, item in ipairs(character:GetChildren()) do
                local r, c = checkTool(item)
                if r then return r, c end
            end
            return "Innocent", Color3.fromRGB(50, 255, 100)
        end)
        if success then return role, col end
        return "Innocent", Color3.fromRGB(50, 255, 100)
    end

    local highlights = {}
    local billboards = {}

    local function cleanupPlayer(player)
        pcall(function()
            if highlights[player] then highlights[player]:Destroy(); highlights[player] = nil end
            if billboards[player] then billboards[player]:Destroy(); billboards[player] = nil end
        end)
    end

    local bodyGyro, bodyVelocity
    local keysPressed = {W = false, A = false, S = false, D = false, Space = false, LeftShift = false}

    local function startFly()
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            if not root or not hum then return end

            hum.PlatformStand = true

            if bodyGyro then bodyGyro:Destroy() end
            if bodyVelocity then bodyVelocity:Destroy() end

            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.P = 9e4
            bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.cframe = root.CFrame
            bodyGyro.Parent = root

            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.velocity = Vector3.new(0, 0, 0)
            bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Parent = root
        end)
    end

    local function stopFly()
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            
            if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
            if bodyVelocity then bodyVelocity:Destroy(); bodyVelocity = nil end

            if root and hum then
                -- Raycast nach unten um zu prüfen, ob Boden da ist (Länge: 5 Studs)
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {char}
                
                local rayResult = workspace:Raycast(root.Position, Vector3.new(0, -5, 0), rayParams)
                
                if rayResult then
                    -- Boden gefunden: Perfekt an exakt dieser Position stehen bleiben
                    hum.PlatformStand = false
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                else
                    -- In der Luft: Sanft nach unten sinken
                    hum.PlatformStand = false
                    hum:ChangeState(Enum.HumanoidStateType.Freefall)
                    root.AssemblyLinearVelocity = Vector3.new(0, -15, 0)
                    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    end

    local function placeTPRed()
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            savedPositionRed = root.Position
            if tpVisualPartRed then tpVisualPartRed:Destroy() end
            tpVisualPartRed = Instance.new("Part")
            tpVisualPartRed.Shape = Enum.PartType.Cylinder
            tpVisualPartRed.Material = Enum.Material.Neon
            tpVisualPartRed.Color = Color3.fromRGB(255, 0, 0)
            tpVisualPartRed.Size = Vector3.new(0.2, 4, 4)
            tpVisualPartRed.Anchored = true
            tpVisualPartRed.CanCollide = false
            tpVisualPartRed.Transparency = 0.2
            tpVisualPartRed.CFrame = CFrame.new(savedPositionRed - Vector3.new(0, 2.9, 0)) * CFrame.Angles(0, 0, math.rad(90))
            tpVisualPartRed.Parent = workspace
        end)
    end
    local function tpRed() pcall(function() local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if r and savedPositionRed then r.CFrame = CFrame.new(savedPositionRed + Vector3.new(0, .5, 0)) end end) end

    local function placeTPGreen()
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            savedPositionGreen = root.Position
            if tpVisualPartGreen then tpVisualPartGreen:Destroy() end
            tpVisualPartGreen = Instance.new("Part")
            tpVisualPartGreen.Shape = Enum.PartType.Cylinder
            tpVisualPartGreen.Material = Enum.Material.Neon
            tpVisualPartGreen.Color = Color3.fromRGB(0, 255, 0)
            tpVisualPartGreen.Size = Vector3.new(0.2, 4, 4)
            tpVisualPartGreen.Anchored = true
            tpVisualPartGreen.CanCollide = false
            tpVisualPartGreen.Transparency = 0.2
            tpVisualPartGreen.CFrame = CFrame.new(savedPositionGreen - Vector3.new(0, 2.9, 0)) * CFrame.Angles(0, 0, math.rad(90))
            tpVisualPartGreen.Parent = workspace
        end)
    end
    local function tpGreen() pcall(function() local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if r and savedPositionGreen then r.CFrame = CFrame.new(savedPositionGreen + Vector3.new(0, .5, 0)) end end) end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local code = input.KeyCode.Name
            if keysPressed[code] ~= nil then keysPressed[code] = true end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local code = input.KeyCode.Name
            if keysPressed[code] ~= nil then keysPressed[code] = false end
        end
    end)

    UserInputService.JumpRequest:Connect(function()
        if infJumpEnabled then
            pcall(function()
                local character = LocalPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end)

    -- Hauptschleife
    RunService.Stepped:Connect(function()
        pcall(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                        local role, roleColor = getPlayerRole(player)

                        if espEnabled then
                            if not highlights[player] or highlights[player].Parent ~= character then
                                if highlights[player] then highlights[player]:Destroy() end
                                local hl = Instance.new("Highlight", character)
                                hl.Adornee = character
                                hl.FillTransparency = 0.4
                                hl.OutlineTransparency = 0
                                highlights[player] = hl
                            end
                            highlights[player].FillColor = roleColor
                            highlights[player].OutlineColor = roleColor
                            highlights[player].Enabled = true
                        else
                            if highlights[player] then highlights[player]:Destroy(); highlights[player] = nil end
                        end

                        if rolesEnabled then
                            local head = character:FindFirstChild("Head")
                            if head then
                                local bgName = "ApexBillboard_" .. player.Name
                                if not billboards[player] or billboards[player].Adornee ~= head then
                                    if billboards[player] then billboards[player]:Destroy() end
                                    local bg = Instance.new("BillboardGui", character)
                                    bg.Name = bgName
                                    bg.Size = UDim2.new(0, 120, 0, 40)
                                    bg.StudsOffset = Vector3.new(0, 2.5, 0)
                                    bg.AlwaysOnTop = true
                                    bg.Adornee = head

                                    local tl = Instance.new("TextLabel", bg)
                                    tl.Size = UDim2.new(1, 0, 1, 0)
                                    tl.BackgroundTransparency = 1
                                    tl.TextScaled = true
                                    tl.Font = Enum.Font.GothamBold
                                    tl.TextStrokeTransparency = 0.2
                                    billboards[player] = bg
                                end
                                local tl = billboards[player]:FindFirstChildOfClass("TextLabel")
                                if tl then
                                    tl.Text = player.Name .. "\n[" .. role .. "]"
                                    tl.TextColor3 = roleColor
                                end
                                billboards[player].Enabled = true
                            end
                        else
                            if billboards[player] then billboards[player]:Destroy(); billboards[player] = nil end
                        end
                    else
                        cleanupPlayer(player)
                    end
                end
            end

            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if not hum or not root then return end

            if antiFlingEnabled and not flyEnabled then
                local vel = root.AssemblyLinearVelocity
                if vel.Magnitude > 250 then
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end

            if speedEnabled and not flyEnabled then
                hum.WalkSpeed = currentSpeed
            end

            if noclipEnabled then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end

            if flyEnabled then
                if not bodyGyro or not bodyVelocity or bodyGyro.Parent ~= root then
                    startFly()
                end
                if bodyGyro and bodyVelocity then
                    bodyGyro.cframe = Camera.CFrame
                    local moveDir = Vector3.new(0, 0, 0)
                    local camCF = Camera.CFrame
                    
                    -- PC Steuerung (WASD)
                    if keysPressed.W then moveDir += camCF.LookVector end
                    if keysPressed.S then moveDir -= camCF.LookVector end
                    if keysPressed.A then moveDir -= camCF.RightVector end
                    if keysPressed.D then moveDir += camCF.RightVector end
                    
                    -- Mobile Joystick Steuerung
                    local humMove = hum.MoveDirection
                    if humMove.Magnitude > 0 then
                        local localMove = camCF:VectorToObjectSpace(humMove)
                        moveDir += (camCF.LookVector * -localMove.Z) + (camCF.RightVector * localMove.X)
                    end

                    local verticalMove = 0
                    if keysPressed.Space or hum.Jump then verticalMove = 1 end
                    if keysPressed.LeftShift then verticalMove = -1 end
                    
                    if moveDir.Magnitude > 0 or verticalMove ~= 0 then
                        local finalVel = moveDir.Unit * currentFlySpeed
                        bodyVelocity.velocity = Vector3.new(finalVel.X, (verticalMove ~= 0 and verticalMove * currentFlySpeed or finalVel.Y), finalVel.Z)
                    else
                        bodyVelocity.velocity = Vector3.new(0, 0, 0)
                    end

                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
    end)

    -- Respawn-Handler
    LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(0.6)
        pcall(function()
            local hum = newChar:WaitForChild("Humanoid", 3)
            if hum then
                if speedEnabled then
                    hum.WalkSpeed = currentSpeed
                end
            end
            if flyEnabled then
                startFly()
            end
        end)
    end)

    -- ERSTELLUNG DER BUTTONS
    createButton("Body ESP", function(state) espEnabled = state end, true, espEnabled)
    createButton("Role Billboard", function(state) rolesEnabled = state end, true, rolesEnabled)
    createButton("Speed Boost", function(state)
        speedEnabled = state
        if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end, true, speedEnabled)
    createSpeedInput("Speed Boost:", currentSpeed, 1, 150, function(val) currentSpeed = val end)

    createButton("Fly", function(state)
        flyEnabled = state
        if state then startFly() else stopFly() end
    end, true, flyEnabled)
    createSpeedInput("Fly Speed:", currentFlySpeed, 1, 300, function(val) currentFlySpeed = val end)

    createButton("Inf Jump", function(state) infJumpEnabled = state end, true, infJumpEnabled)
    createButton("Noclip", function(state) 
        noclipEnabled = state 
        if not state and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end
            end
        end
    end, true, noclipEnabled)

    createButton("PLACE TP (RED)", function() placeTPRed() end, false)
    createButton("TP (RED)", function() tpRed() end, false)
    createButton("PLACE TP (GREEN)", function() placeTPGreen() end, false)
    createButton("TP (GREEN)", function() tpGreen() end, false)

    createPlayerDropdown(ContentFrame)
    createFlingDropdown(ContentFrame)

    createDropdown("Theme", {"Dark", "Purple", "Ocean", "Crimson", "Emerald", "Sunset", "Cyberpunk", "Matrix", "Midnight"}, function(name)
        applyTheme(name)
    end)

    createDropdown("Mode", {"Normal", "Buttons"}, function(name)
        updateMode(name)
    end)

    createRightButton("Body ESP", function(state) espEnabled = state end, true, espEnabled)
    createRightButton("Role Billboard", function(state) rolesEnabled = state end, true, rolesEnabled)
    createRightButton("Speed Boost", function(state)
        speedEnabled = state
        if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end, true, speedEnabled)
    createRightSpeedInput("Speed Boost:", currentSpeed, 1, 150, function(val) currentSpeed = val end)

    createRightButton("Fly", function(state)
        flyEnabled = state
        if state then startFly() else stopFly() end
    end, true, flyEnabled)
    createRightSpeedInput("Fly Speed:", currentFlySpeed, 1, 300, function(val) currentFlySpeed = val end)

    createRightButton("Inf Jump", function(state) infJumpEnabled = state end, true, infJumpEnabled)
    createRightButton("Noclip", function(state) 
        noclipEnabled = state 
        if not state and LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end
            end
        end
    end, true, noclipEnabled)

    createRightButton("PLACE TP (RED)", function() placeTPRed() end, false)
    createRightButton("TP (RED)", function() tpRed() end, false)
    createRightButton("PLACE TP (GREEN)", function() placeTPGreen() end, false)
    createRightButton("TP (GREEN)", function() tpGreen() end, false)

    createPlayerDropdown(RightButtonsContainer)
    createFlingDropdown(RightButtonsContainer)

    Players.PlayerRemoving:Connect(cleanupPlayer)
end

