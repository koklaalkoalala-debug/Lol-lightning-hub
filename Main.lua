local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

if playerGui:FindFirstChild("LightningHubGui") then
    playerGui.LightningHubGui:Destroy()
end

local COLORS = {
    bg      = Color3.fromRGB(8, 12, 24),
    panel   = Color3.fromRGB(15, 20, 35),
    accent  = Color3.fromRGB(0, 210, 255),
    gold    = Color3.fromRGB(255, 216, 74),
    text    = Color3.fromRGB(230, 240, 255),
    subtext = Color3.fromRGB(120, 140, 170),
    danger  = Color3.fromRGB(200, 60, 60),
}

local connections = {}
local function track(conn) table.insert(connections, conn); return conn end
local function disconnectAll()
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    connections = {}
end

local pulseAlive = true
local lightningAlive = true

--------------------------------------------------------------------
-- ScreenGui
--------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LightningHubGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

--------------------------------------------------------------------
-- Главная рамка
--------------------------------------------------------------------
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 520, 0, 400)
main.Position = UDim2.new(0.5, -260, 0.5, -200)
main.BackgroundColor3 = COLORS.bg
main.BorderSizePixel = 0
main.Active = false
main.Parent = screenGui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COLORS.accent
mainStroke.Thickness = 2
mainStroke.Transparency = 0.3
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = main

task.spawn(function()
    while pulseAlive and main.Parent do
        pcall(function()
            TweenService:Create(mainStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {Transparency = 0.0}):Play()
        end)
        task.wait(0.8)
        pcall(function()
            TweenService:Create(mainStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {Transparency = 0.6}):Play()
        end)
        task.wait(0.8)
    end
end)

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 15, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 8, 18)),
})
bgGradient.Rotation = 45
bgGradient.Parent = main

--------------------------------------------------------------------
-- ⚡ МОЛНИЕВЫЙ КОНТУР
--------------------------------------------------------------------
local lightningLayer = Instance.new("Frame")
lightningLayer.Name = "LightningLayer"
lightningLayer.Size = UDim2.new(1, 24, 1, 24)
lightningLayer.Position = UDim2.new(0, -12, 0, -12)
lightningLayer.BackgroundTransparency = 1
lightningLayer.ZIndex = 0
lightningLayer.ClipsDescendants = false
lightningLayer.Parent = main

local function makeBolt(parent, startPos, endPos, thickness, color, lifetime)
    local bolt = Instance.new("Frame")
    bolt.BackgroundColor3 = color
    bolt.BorderSizePixel = 0
    bolt.ZIndex = 1
    bolt.Parent = parent

    Instance.new("UICorner", bolt).CornerRadius = UDim.new(1, 0)

    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1
    stroke.Transparency = 0.3
    stroke.Parent = bolt

    local distance = (endPos - startPos).Magnitude
    bolt.Size = UDim2.new(0, distance, 0, thickness)
    bolt.Position = UDim2.new(0, startPos.X, 0, startPos.Y)
    bolt.Rotation = math.deg(math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X))
    bolt.AnchorPoint = Vector2.new(0, 0.5)

    bolt.BackgroundTransparency = 1
    stroke.Transparency = 1

    task.spawn(function()
        TweenService:Create(stroke, TweenInfo.new(lifetime * 0.15), {Transparency = 0}):Play()
        TweenService:Create(bolt, TweenInfo.new(lifetime * 0.15), {BackgroundTransparency = 0.2}):Play()
        task.wait(lifetime * 0.5)
        TweenService:Create(stroke, TweenInfo.new(lifetime * 0.5), {Transparency = 1}):Play()
        TweenService:Create(bolt, TweenInfo.new(lifetime * 0.5), {BackgroundTransparency = 1}):Play()
        task.wait(lifetime * 0.5)
        if bolt.Parent then bolt:Destroy() end
    end)
end

task.spawn(function()
    while lightningAlive and main.Parent do
        local w = main.AbsoluteSize.X + 24
        local h = main.AbsoluteSize.Y + 24
        if w > 0 and h > 0 then
            local edge = math.random(1, 4)
            local startPos, endPos
            local seg = math.random(30, 80)

            if edge == 1 then
                local x = math.random(10, math.max(11, w - seg - 10))
                startPos = Vector2.new(x, 0)
                endPos = Vector2.new(x + seg, 0)
            elseif edge == 2 then
                local x = math.random(10, math.max(11, w - seg - 10))
                startPos = Vector2.new(x, h)
                endPos = Vector2.new(x + seg, h)
            elseif edge == 3 then
                local y = math.random(10, math.max(11, h - seg - 10))
                startPos = Vector2.new(0, y)
                endPos = Vector2.new(0, y + seg)
            else
                local y = math.random(10, math.max(11, h - seg - 10))
                startPos = Vector2.new(w, y)
                endPos = Vector2.new(w, y + seg)
            end

            local color = math.random(1, 3) == 1 and COLORS.gold or COLORS.accent
            makeBolt(lightningLayer, startPos, endPos, math.random(2, 4), color, 0.4)
        end
        task.wait(math.random(8, 20) / 100)
    end
end)

local function makeCornerBolt(parent, pos, rotDeg, flip)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, 40, 0, 40)
    holder.Position = pos
    holder.BackgroundTransparency = 1
    holder.ZIndex = 1
    holder.Parent = parent

    for i = 1, 3 do
        local seg = Instance.new("Frame")
        seg.Size = UDim2.new(0, 14, 0, 3)
        seg.Position = UDim2.new(0, (i - 1) * 10, 0, (i - 1) * 6 * (flip and -1 or 1))
        seg.Rotation = rotDeg + (i % 2 == 0 and 20 or -20)
        seg.BackgroundColor3 = COLORS.accent
        seg.BorderSizePixel = 0
        seg.ZIndex = 1
        seg.Parent = holder

        Instance.new("UICorner", seg).CornerRadius = UDim.new(1, 0)

        local s = Instance.new("UIStroke")
        s.Color = COLORS.accent
        s.Thickness = 1
        s.Transparency = 0.2
        s.Parent = seg

        task.spawn(function()
            while holder.Parent and lightningAlive do
                TweenService:Create(seg, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
                    BackgroundColor3 = COLORS.gold
                }):Play()
                task.wait(0.4)
                TweenService:Create(seg, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
                    BackgroundColor3 = COLORS.accent
                }):Play()
                task.wait(0.4)
            end
        end)
    end
end

makeCornerBolt(lightningLayer, UDim2.new(0, 0, 0, 0), -45, false)
makeCornerBolt(lightningLayer, UDim2.new(1, -40, 0, 0), 45, true)
makeCornerBolt(lightningLayer, UDim2.new(0, 0, 1, -40), 45, true)
makeCornerBolt(lightningLayer, UDim2.new(1, -40, 1, -40), -45, false)

--------------------------------------------------------------------
-- Верхняя панель
--------------------------------------------------------------------
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 44)
topBar.BackgroundColor3 = COLORS.panel
topBar.BorderSizePixel = 0
topBar.Active = true
topBar.Draggable = true
topBar.ZIndex = 2
topBar.Parent = main

Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 12)
topFix.Position = UDim2.new(0, 0, 1, -12)
topFix.BackgroundColor3 = COLORS.panel
topFix.BorderSizePixel = 0
topFix.ZIndex = 1
topFix.Parent = topBar

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, -80, 1, 0)
logo.Position = UDim2.new(0, 16, 0, 0)
logo.BackgroundTransparency = 1
logo.Text = "⚡ LIGHTNING HUB"
logo.Font = Enum.Font.GothamBold
logo.TextSize = 20
logo.TextColor3 = COLORS.gold
logo.TextXAlignment = Enum.TextXAlignment.Left
logo.ZIndex = 3
logo.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0, 8)
closeBtn.BackgroundColor3 = COLORS.danger
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = COLORS.text
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 3
closeBtn.Parent = topBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

track(closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end))
track(closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.danger}):Play()
end))

local closing = false
track(closeBtn.MouseButton1Click:Connect(function()
    if closing then return end
    closing = true
    pulseAlive = false
    lightningAlive = false
    disconnectAll()
    TweenService:Create(main, TweenInfo.new(0.25), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    task.wait(0.3)
    screenGui:Destroy()
end))

--------------------------------------------------------------------
-- Счётчик яиц
--------------------------------------------------------------------
local eggCounter = Instance.new("TextLabel")
eggCounter.Size = UDim2.new(1, -32, 0, 30)
eggCounter.Position = UDim2.new(0, 16, 0, 54)
eggCounter.BackgroundColor3 = COLORS.panel
eggCounter.BorderSizePixel = 0
eggCounter.Text = "🥚 Eggs Stolen: 0"
eggCounter.Font = Enum.Font.GothamBold
eggCounter.TextSize = 16
eggCounter.TextColor3 = COLORS.gold
eggCounter.Parent = main
Instance.new("UICorner", eggCounter).CornerRadius = UDim.new(0, 8)

local counterStroke = Instance.new("UIStroke")
counterStroke.Color = COLORS.gold
counterStroke.Thickness = 1
counterStroke.Transparency = 0.4
counterStroke.Parent = eggCounter

--------------------------------------------------------------------
-- Вкладки
--------------------------------------------------------------------
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -32, 0, 32)
tabBar.Position = UDim2.new(0, 16, 0, 94)
tabBar.BackgroundTransparency = 1
tabBar.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabBar

local contentHolder = Instance.new("Frame")
contentHolder.Size = UDim2.new(1, -32, 1, -190)
contentHolder.Position = UDim2.new(0, 16, 0, 134)
contentHolder.BackgroundTransparency = 1
contentHolder.Parent = main

local pages = {}
local tabButtons = {}

local function switchTab(name)
    if not screenGui.Parent then return end
    for n, page in pairs(pages) do
        if page.Parent then page.Visible = (n == name) end
    end
    for n, btn in pairs(tabButtons) do
        if btn.Parent then
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = (n == name) and COLORS.accent or COLORS.panel
            }):Play()
            btn.TextColor3 = (n == name) and Color3.fromRGB(0, 0, 0) or COLORS.text
        end
    end
end

local function makeTab(name, label)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = COLORS.accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = contentHolder

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = page

    pages[name] = page

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 90, 1, 0)
    tabBtn.BackgroundColor3 = COLORS.panel
    tabBtn.Text = label
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 13
    tabBtn.TextColor3 = COLORS.text
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = tabBar
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

    track(tabBtn.MouseButton1Click:Connect(function()
        switchTab(name)
    end))

    tabButtons[name] = tabBtn
    return page
end

--------------------------------------------------------------------
-- Кнопка
--------------------------------------------------------------------
local function makeButton(parent, text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = COLORS.panel
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.TextColor3 = color or COLORS.text
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.accent
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = btn

    track(btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(25, 35, 55)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0}):Play()
    end))
    track(btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.panel}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Transparency = 0.5}):Play()
    end))
    track(btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = COLORS.accent}):Play()
        task.wait(0.12)
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.panel}):Play()
        pcall(callback)
    end))

    return btn
end

--------------------------------------------------------------------
-- Toggle
--------------------------------------------------------------------
local function makeToggle(parent, label, onChange)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 34)
    frame.BackgroundColor3 = COLORS.panel
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.accent
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -100, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextColor3 = COLORS.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 70, 0, 24)
    toggle.Position = UDim2.new(1, -82, 0.5, -12)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
    toggle.Text = "OFF"
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 12
    toggle.TextColor3 = COLORS.text
    toggle.AutoButtonColor = false
    toggle.Parent = frame
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)

    local state = false
    local api = {}

    local function apply(v, silent)
        state = v
        toggle.Text = v and "ON" or "OFF"
        TweenService:Create(toggle, TweenInfo.new(0.15), {
            BackgroundColor3 = v and COLORS.accent or Color3.fromRGB(40, 50, 70)
        }):Play()
        toggle.TextColor3 = v and Color3.fromRGB(0, 0, 0) or COLORS.text
        if not silent and onChange then onChange(v) end
    end

    track(toggle.MouseButton1Click:Connect(function()
        apply(not state)
    end))

    function api:Set(v) apply(v, false) end
    function api:Get() return state end

    return api
end

--------------------------------------------------------------------
-- Slider
--------------------------------------------------------------------
local activeSlider = nil
track(UserInputService.InputChanged:Connect(function(input)
    if activeSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        activeSlider(input)
    end
end))

local function makeSlider(parent, label, minV, maxV, default, onChange)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = COLORS.panel
    frame.BorderSizePixel = 0
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = COLORS.accent
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. default
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextColor3 = COLORS.text
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1, -24, 0, 8)
    bar.Position = UDim2.new(0, 12, 0, 32)
    bar.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    bar.Text = ""
    bar.AutoButtonColor = false
    bar.BorderSizePixel = 0
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

    local relDefault = (default - minV) / (maxV - minV)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(relDefault, 0, 1, 0)
    fill.BackgroundColor3 = COLORS.accent
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(relDefault, -7, 0.5, -7)
    knob.BackgroundColor3 = COLORS.gold
    knob.Text = ""
    knob.AutoButtonColor = false
    knob.ZIndex = 3
    knob.Parent = bar
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local function applyFromRel(rel, silent)
        rel = math.clamp(rel, 0, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -7, 0.5, -7)
        local val = minV + (maxV - minV) * rel
        val = math.floor(val * 10) / 10
        lbl.Text = label .. ": " .. val
        if not silent and onChange then onChange(val) end
    end

    local function relFromInput(input)
        return (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
    end

    local function startDrag(input)
        activeSlider = function(inp) applyFromRel(relFromInput(inp)) end
        applyFromRel(relFromInput(input))
    end

    track(knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
        end
    end))
    track(bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeSlider = nil
        end
    end))

    local api = {}
    function api:Set(v)
        local rel = (v - minV) / (maxV - minV)
        applyFromRel(rel, false)
    end
    return api
end

--------------------------------------------------------------------
-- Хелперы
--------------------------------------------------------------------
local function getChar()
    local char = player.Character
    if not char then return nil, nil end
    return char, char:FindFirstChildOfClass("Humanoid")
end

local function setWalkSpeed(speed)
    local _, hum = getChar()
    if hum then hum.WalkSpeed = speed end
end

local function teleportToBase()
    local char = getChar()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(0, 10, 0) end
end

--------------------------------------------------------------------
-- TP WALK
--------------------------------------------------------------------
local tpWalkEnabled = false
local tpWalkSpeed = 3
local tpConn = nil

local function stopTpWalk()
    if tpConn then
        pcall(function() tpConn:Disconnect() end)
        tpConn = nil
    end
end

local function startTpWalk()
    stopTpWalk()
    tpConn = RunService.Heartbeat:Connect(function()
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local dir = hum.MoveDirection
        if dir.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + dir * tpWalkSpeed
        end
    end)
    track(tpConn)
end

--------------------------------------------------------------------
-- MAIN TAB
--------------------------------------------------------------------
local mainPage = makeTab("main", "⚡ Main")

makeButton(mainPage, "⚡ Teleport to Base", teleportToBase)
makeButton(mainPage, "🔄 Reset Character", function()
    pcall(function()
        if player.Character then player.Character:BreakJoints() end
    end)
end)

local wsSlider = makeSlider(mainPage, "WalkSpeed", 16, 200, 16, function(v)
    setWalkSpeed(v)
end)

track(player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then wsSlider:Set(hum.WalkSpeed) end
end))

--------------------------------------------------------------------
-- TP WALK TAB
--------------------------------------------------------------------
local tpPage = makeTab("tpwalk", "⚡ TP Walk")

local tpToggle = makeToggle(tpPage, "TP Walk (клавиша T)", function(state)
    tpWalkEnabled = state
    if state then startTpWalk() else stopTpWalk() end
end)

makeSlider(tpPage, "TP Speed", 0.5, 15, 3, function(v)
    tpWalkSpeed = v
end)

track(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.T then
        tpToggle:Set(not tpToggle:Get())
    end
end))

track(player.CharacterAdded:Connect(function()
    if tpWalkEnabled then
        task.wait(1)
        startTpWalk()
    end
end))

--------------------------------------------------------------------
-- UTILITY TAB
--------------------------------------------------------------------
local utilPage = makeTab("utility", "🔧 Utility")

makeButton(utilPage, "☁ Fly toggle (заглушка)", function() end)
makeButton(utilPage, "👁 Noclip toggle (заглушка)", function() end)

--------------------------------------------------------------------
-- Стартовое состояние вкладок
--------------------------------------------------------------------
switchTab("main")

--------------------------------------------------------------------
-- Счётчик (демо)
--------------------------------------------------------------------
local eggs = 0
task.spawn(function()
    while screenGui.Parent do
        task.wait(3)
        eggs += 1
        eggCounter.Text = "🥚 Eggs Stolen: " .. eggs
    end
end)
