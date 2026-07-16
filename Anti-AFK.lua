-- Сервіси
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Змінні стану
local isRunning = false
local jumpInterval = 300 -- За замовчуванням 5 хвилин (300 секунд)
local activeLanguage = "EN" -- Встановлено "EN" за дефолтом
local useVirtual = true
local usePhysical = true
local textScaleMultiplier = 1.0 -- Коефіцієнт масштабу тексту (від 0.8 до 1.5)
local isLoaded = false -- Прапор закінчення завантаження
local isMinimized = false -- Глобальний прапор згортання
local setMinimized -- Форвард-декларація функції згортання

-- Часові змінні
local lastJumpTime = 0
local startTime = 0

-- Попереднє оголошення елементів інтерфейсу для уникнення багів області видимості (Scope)
local ScreenGui, MainFrame, ContentFrame, Title, CloseBtn, MinimizeBtn
local LangFrame, BtnUA, BtnEN, BtnRU
local StatusLabel, TimerLabel
local BoxVirtual, LblVirtual, BoxPhysical, LblPhysical
local TextSizeLabel, TextSliderFrame, TextSliderButton
local IntervalLabel, SliderFrame, SliderButton
local TestBtn, ToggleBtn, InfoLabel, RestoreBtn
local LoadingFrame, LogoLabel, LoadStatus, ProgressBarBackground, ProgressBar, PercentLabel
local ResizeBtn, ResizeVisual

-- Таблиця локалізації
local t = {
    UA = {
        title = "  🌌 XolzpHub | ANTI-AFK",
        status_on = "Статус: Працює",
        status_off = "Статус: Вимкнено",
        timer = "Час роботи: ",
        interval_sec = "Інтервал: %d сек",
        interval_min_sec = "Інтервал: %d хв %d сек",
        text_size = "Розмір тексту: %d%%",
        btn_start = "ЗАПУСТИТИ",
        btn_stop = "ЗУПИНИТИ",
        btn_test = "ТЕСТОВИЙ СТРИБОК",
        cb_virtual = "Емуляція кліків (VirtualUser)",
        cb_physical = "Фізичні стрибки (Клавіатура)",
        notif_minimized = "Меню згорнуто! Натисніть [Ctrl + S], щоб відкрити знову.",
        load_1 = "Завантаження бази даних...",
        load_2 = "Перевірка конфігурації...",
        load_3 = "Підготовка обходу AFK...",
        load_4 = "Готово до роботи!",
    },
    EN = {
        title = "  🌌 XolzpHub | ANTI-AFK",
        status_on = "Status: Running",
        status_off = "Status: Disabled",
        timer = "Running time: ",
        interval_sec = "Interval: %d sec",
        interval_min_sec = "Interval: %d min %d sec",
        text_size = "Text size: %d%%",
        btn_start = "START",
        btn_stop = "STOP",
        btn_test = "TEST JUMP",
        cb_virtual = "Emulate Clicks (VirtualUser)",
        cb_physical = "Physical Jumps (Keyboard)",
        notif_minimized = "Menu minimized! Press [Ctrl + S] to open again.",
        load_1 = "Loading database...",
        load_2 = "Checking configuration...",
        load_3 = "Preparing AFK bypass...",
        load_4 = "Ready to work!",
    },
    RU = {
        title = "  🌌 XolzpHub | ANTI-AFK",
        status_on = "Статус: Работает",
        status_off = "Статус: Выключено",
        timer = "Время работы: ",
        interval_sec = "Интервал: %d сек",
        interval_min_sec = "Интервал: %d мин %d сек",
        text_size = "Размер текста: %d%%",
        btn_start = "ЗАПУСТИТЬ",
        btn_stop = "ОСТАНОВИТЬ",
        btn_test = "ТЕСТОВЫЙ ПРЫЖОК",
        cb_virtual = "Эмуляция кликов (VirtualUser)",
        cb_physical = "Физические прыжки (Клавиатура)",
        notif_minimized = "Menu minimized! Press [Ctrl + S] to open again.",
        load_1 = "Загрузка базы данных...",
        load_2 = "Проверка конфигурации...",
        load_3 = "Подготовка обхода AFK...",
        load_4 = "Готово к работе!",
    }
}

-- Базові розміри шрифтів
local baseFontSizes = {
    Title = 12,
    StatusLabel = 12,
    TimerLabel = 12,
    Checkbox = 11,
    SliderLabel = 11,
    TestBtn = 11,
    ToggleBtn = 12,
    LangBtn = 10,
    CloseBtn = 16,
    MinimizeBtn = 12
}

-- Налаштування лімітів ресайзу
local minWidth, minHeight = 220, 320
local maxWidth, maxHeight = 600, 800

-- Створення GUI
ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AntiAFK_Cosmic"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Головний Фрейм
MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -135, 0.5, -190)
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1
MainStroke.Color = Color3.fromRGB(50, 50, 55)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Size = UDim2.new(1, 0, 1, 0)

-- Верхня панель (Заголовок)
Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = ContentFrame
Title.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 38)
Title.Font = Enum.Font.SciFi
Title.Text = t[activeLanguage].title
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = baseFontSizes.Title
Title.TextXAlignment = Enum.TextXAlignment.Left

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = Title
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.BorderSizePixel = 0
CloseBtn.Position = UDim2.new(1, -28, 0, 8)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = baseFontSizes.CloseBtn

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 6)
CloseBtnCorner.Parent = CloseBtn

MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Parent = Title
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Position = UDim2.new(1, -54, 0, 8)
MinimizeBtn.Size = UDim2.new(0, 22, 0, 22)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Text = "_"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = baseFontSizes.MinimizeBtn

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 6)
MinimizeCorner.Parent = MinimizeBtn

-- Панель вибору мови
LangFrame = Instance.new("Frame")
LangFrame.Name = "LangFrame"
LangFrame.Parent = ContentFrame
LangFrame.BackgroundTransparency = 1
LangFrame.Position = UDim2.new(0, 15, 0, 48)
LangFrame.Size = UDim2.new(1, -30, 0, 22)

local function createLangBtn(name, text, posX)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = LangFrame
    btn.BackgroundColor3 = (activeLanguage == text) and Color3.fromRGB(240, 240, 245) or Color3.fromRGB(25, 25, 28)
    btn.BorderSizePixel = 0
    btn.Position = UDim2.new(0, posX, 0, 0)
    btn.Size = UDim2.new(0, 42, 1, 0)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = (activeLanguage == text) and Color3.fromRGB(15, 15, 17) or Color3.fromRGB(180, 180, 185)
    btn.TextSize = baseFontSizes.LangBtn
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(60, 60, 65)
    stroke.Parent = btn

    return btn
end

BtnUA = createLangBtn("BtnUA", "UA", 0)
BtnEN = createLangBtn("BtnEN", "EN", 46)
BtnRU = createLangBtn("BtnRU", "RU", 92)

-- Статус роботи
StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = ContentFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 15, 0, 78)
StatusLabel.Size = UDim2.new(1, -30, 0, 20)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.Text = t[activeLanguage].status_off
StatusLabel.TextColor3 = Color3.fromRGB(180, 50, 50)
StatusLabel.TextSize = baseFontSizes.StatusLabel
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Форматування часу
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Форматування тексту інтервалу
local function formatIntervalText(seconds, lang)
    if seconds < 60 then
        return string.format(t[lang].interval_sec, seconds)
    else
        local minutes = math.floor(seconds / 60)
        local remainingSecs = seconds % 60
        if remainingSecs == 0 then
            return string.format(t[lang].interval_min_sec, minutes, 0):gsub(" 0 сек", ""):gsub(" 0 sec", ""):gsub(" 0 сек", "")
        else
            return string.format(t[lang].interval_min_sec, minutes, remainingSecs)
        end
    end
end

-- Таймер
TimerLabel = Instance.new("TextLabel")
TimerLabel.Name = "TimerLabel"
TimerLabel.Parent = ContentFrame
TimerLabel.BackgroundTransparency = 1
TimerLabel.Position = UDim2.new(0, 15, 0, 96)
TimerLabel.Size = UDim2.new(1, -30, 0, 20)
TimerLabel.Font = Enum.Font.GothamSemibold
TimerLabel.Text = t[activeLanguage].timer .. "00:00:00"
TimerLabel.TextColor3 = Color3.fromRGB(200, 200, 205)
TimerLabel.TextSize = baseFontSizes.TimerLabel
TimerLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Чекбокси методів обходу
local function createCheckbox(name, labelText, posY, defaultVal)
    local frame = Instance.new("Frame")
    frame.Name = name .. "Frame"
    frame.Parent = ContentFrame
    frame.BackgroundTransparency = 1
    frame.Position = UDim2.new(0, 15, 0, posY)
    frame.Size = UDim2.new(1, -30, 0, 22)

    local box = Instance.new("TextButton")
    box.Name = "Box"
    box.Parent = frame
    box.BackgroundColor3 = defaultVal and Color3.fromRGB(240, 240, 245) or Color3.fromRGB(25, 25, 28)
    box.BorderSizePixel = 0
    box.Size = UDim2.new(0, 18, 0, 18)
    box.Font = Enum.Font.GothamBold
    box.Text = defaultVal and "✓" or ""
    box.TextColor3 = Color3.fromRGB(15, 15, 17)
    box.TextSize = 12

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box
    
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Thickness = 1
    boxStroke.Color = Color3.fromRGB(60, 60, 65)
    boxStroke.Parent = box

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.Parent = frame
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 26, 0, 0)
    lbl.Size = UDim2.new(1, -26, 1, 0)
    lbl.Font = Enum.Font.Gotham
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(180, 180, 185)
    lbl.TextSize = baseFontSizes.Checkbox
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    return box, lbl
end

BoxVirtual, LblVirtual = createCheckbox("Virtual", t[activeLanguage].cb_virtual, 124, useVirtual)
BoxPhysical, LblPhysical = createCheckbox("Physical", t[activeLanguage].cb_physical, 152, usePhysical)

-- Послідовний движок верстки
local function updateLayout()
    if not isLoaded or isMinimized or not MainFrame or not MainFrame:IsDescendantOf(game) then return end
    
    local w = MainFrame.AbsoluteSize.X
    local h = MainFrame.AbsoluteSize.Y
    
    if ResizeBtn then
        ResizeBtn.Position = UDim2.new(1, -20, 1, -20)
    end
    
    local startX = 15
    local currentY = 0
    local verticalPadding = 8 * textScaleMultiplier
    
    local titleHeight = math.clamp(h * 0.1, 38, 50)
    Title.Size = UDim2.new(1, 0, 0, titleHeight)
    currentY = titleHeight + 10
    
    LangFrame.Position = UDim2.new(0, startX, 0, currentY)
    local langHeight = 22 * textScaleMultiplier
    LangFrame.Size = UDim2.new(1, -30, 0, langHeight)
    
    local btnWidth = math.clamp(w * 0.16, 42, 65)
    local btnGap = 4
    BtnUA.Size = UDim2.new(0, btnWidth, 1, 0)
    BtnUA.Position = UDim2.new(0, 0, 0, 0)
    BtnEN.Size = UDim2.new(0, btnWidth, 1, 0)
    BtnEN.Position = UDim2.new(0, btnWidth + btnGap, 0, 0)
    BtnRU.Size = UDim2.new(0, btnWidth, 1, 0)
    BtnRU.Position = UDim2.new(0, (btnWidth + btnGap) * 2, 0, 0)
    
    currentY = currentY + langHeight + verticalPadding
    
    StatusLabel.Position = UDim2.new(0, startX, 0, currentY)
    local statusHeight = 20 * textScaleMultiplier
    StatusLabel.Size = UDim2.new(1, -30, 0, statusHeight)
    currentY = currentY + statusHeight + 2
    
    TimerLabel.Position = UDim2.new(0, startX, 0, currentY)
    local timerHeight = 20 * textScaleMultiplier
    TimerLabel.Size = UDim2.new(1, -30, 0, timerHeight)
    currentY = currentY + timerHeight + verticalPadding
    
    local bypass1 = ContentFrame:FindFirstChild("VirtualFrame")
    if bypass1 then
        bypass1.Position = UDim2.new(0, startX, 0, currentY)
        local bypass1Height = 22 * textScaleMultiplier
        bypass1.Size = UDim2.new(1, -30, 0, bypass1Height)
        
        local box = bypass1:FindFirstChild("Box")
        local lbl = bypass1:FindFirstChild("Label")
        if box and lbl then
            local boxSize = math.clamp(18 * textScaleMultiplier, 14, 24)
            box.Size = UDim2.new(0, boxSize, 0, boxSize)
            box.Position = UDim2.new(0, 0, 0.5, -boxSize/2)
            lbl.Position = UDim2.new(0, boxSize + 8, 0, 0)
            lbl.Size = UDim2.new(1, -(boxSize + 8), 1, 0)
        end
        currentY = currentY + bypass1Height + verticalPadding
    end
    
    local bypass2 = ContentFrame:FindFirstChild("PhysicalFrame")
    if bypass2 then
        bypass2.Position = UDim2.new(0, startX, 0, currentY)
        local bypass2Height = 22 * textScaleMultiplier
        bypass2.Size = UDim2.new(1, -30, 0, bypass2Height)
        
        local box = bypass2:FindFirstChild("Box")
        local lbl = bypass2:FindFirstChild("Label")
        if box and lbl then
            local boxSize = math.clamp(18 * textScaleMultiplier, 14, 24)
            box.Size = UDim2.new(0, boxSize, 0, boxSize)
            box.Position = UDim2.new(0, 0, 0.5, -boxSize/2)
            lbl.Position = UDim2.new(0, boxSize + 8, 0, 0)
            lbl.Size = UDim2.new(1, -(boxSize + 8), 1, 0)
        end
        currentY = currentY + bypass2Height + verticalPadding
    end
    
    TextSizeLabel.Position = UDim2.new(0, startX, 0, currentY)
    local textSizeHeight = 20 * textScaleMultiplier
    TextSizeLabel.Size = UDim2.new(1, -30, 0, textSizeHeight)
    currentY = currentY + textSizeHeight + 4
    
    TextSliderFrame.Position = UDim2.new(0, startX, 0, currentY)
    TextSliderFrame.Size = UDim2.new(1, -30, 0, 6)
    currentY = currentY + 6 + verticalPadding + 4
    
    if usePhysical then
        IntervalLabel.Visible = true
        SliderFrame.Visible = true
        
        IntervalLabel.Position = UDim2.new(0, startX, 0, currentY)
        local intervalHeight = 20 * textScaleMultiplier
        IntervalLabel.Size = UDim2.new(1, -30, 0, intervalHeight)
        currentY = currentY + intervalHeight + 4
        
        SliderFrame.Position = UDim2.new(0, startX, 0, currentY)
        SliderFrame.Size = UDim2.new(1, -30, 0, 6)
        currentY = currentY + 6 + verticalPadding + 4
        
        if TestBtn then
            TestBtn.Visible = true
            TestBtn.Position = UDim2.new(0, startX, 0, currentY)
            local testBtnHeight = 32 * textScaleMultiplier
            TestBtn.Size = UDim2.new(1, -30, 0, testBtnHeight)
            currentY = currentY + testBtnHeight + verticalPadding
        end
    else
        IntervalLabel.Visible = false
        SliderFrame.Visible = false
        if TestBtn then TestBtn.Visible = false end
    end
    
    if ToggleBtn then
        ToggleBtn.Position = UDim2.new(0, startX, 0, currentY)
        local toggleBtnHeight = 40 * textScaleMultiplier
        ToggleBtn.Size = UDim2.new(1, -30, 0, toggleBtnHeight)
        currentY = currentY + toggleBtnHeight + verticalPadding
    end
    
    minHeight = currentY + 15
    if h < minHeight then
        MainFrame.Size = UDim2.new(0, w, 0, minHeight)
    end
end

-- Функція динамічного масштабування шрифтів
local function updateTextSizes()
    Title.TextSize = math.round(baseFontSizes.Title * textScaleMultiplier)
    StatusLabel.TextSize = math.round(baseFontSizes.StatusLabel * textScaleMultiplier)
    TimerLabel.TextSize = math.round(baseFontSizes.TimerLabel * textScaleMultiplier)
    
    LblVirtual.TextSize = math.round(baseFontSizes.Checkbox * textScaleMultiplier)
    LblPhysical.TextSize = math.round(baseFontSizes.Checkbox * textScaleMultiplier)
    
    if IntervalLabel then IntervalLabel.TextSize = math.round(baseFontSizes.SliderLabel * textScaleMultiplier) end
    if TextSizeLabel then TextSizeLabel.TextSize = math.round(baseFontSizes.SliderLabel * textScaleMultiplier) end
    if TestBtn then TestBtn.TextSize = math.round(baseFontSizes.TestBtn * textScaleMultiplier) end
    if ToggleBtn then ToggleBtn.TextSize = math.round(baseFontSizes.ToggleBtn * textScaleMultiplier) end
    
    BtnUA.TextSize = math.round(baseFontSizes.LangBtn * textScaleMultiplier)
    BtnEN.TextSize = math.round(baseFontSizes.LangBtn * textScaleMultiplier)
    BtnRU.TextSize = math.round(baseFontSizes.LangBtn * textScaleMultiplier)
    
    updateLayout()
end

-- Слайдер масштабу тексту
TextSizeLabel = Instance.new("TextLabel")
TextSizeLabel.Name = "TextSizeLabel"
TextSizeLabel.Parent = ContentFrame
TextSizeLabel.BackgroundTransparency = 1
TextSizeLabel.Position = UDim2.new(0, 15, 0, 180)
TextSizeLabel.Size = UDim2.new(1, -30, 0, 20)
TextSizeLabel.Font = Enum.Font.Gotham
TextSizeLabel.Text = string.format(t[activeLanguage].text_size, 100)
TextSizeLabel.TextColor3 = Color3.fromRGB(150, 150, 155)
TextSizeLabel.TextSize = baseFontSizes.SliderLabel
TextSizeLabel.TextXAlignment = Enum.TextXAlignment.Left

TextSliderFrame = Instance.new("Frame")
local TextSliderFrameCorner = Instance.new("UICorner")
TextSliderButton = Instance.new("TextButton")
local TextSliderButtonCorner = Instance.new("UICorner")

TextSliderFrame.Name = "TextSliderFrame"
TextSliderFrame.Parent = ContentFrame
TextSliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
TextSliderFrame.BorderSizePixel = 0
TextSliderFrame.Position = UDim2.new(0, 15, 0, 206)
TextSliderFrame.Size = UDim2.new(1, -30, 0, 6)

TextSliderFrameCorner.CornerRadius = UDim.new(1, 0)
TextSliderFrameCorner.Parent = TextSliderFrame

TextSliderButton.Name = "TextSliderButton"
TextSliderButton.Parent = TextSliderFrame
TextSliderButton.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
TextSliderButton.BorderSizePixel = 0
TextSliderButton.Position = UDim2.new(0.28, 0, -1, 0)
TextSliderButton.Size = UDim2.new(0, 18, 0, 18)
TextSliderButton.Text = ""

TextSliderButtonCorner.CornerRadius = UDim.new(1, 0)
TextSliderButtonCorner.Parent = TextSliderButton

local TextSliderStroke = Instance.new("UIStroke")
TextSliderStroke.Color = Color3.fromRGB(60, 60, 65)
TextSliderStroke.Thickness = 1
TextSliderStroke.Parent = TextSliderButton

local draggingTextSlider = false
TextSliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingTextSlider = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingTextSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingTextSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = input.Position.X
        local sliderPos = TextSliderFrame.AbsolutePosition.X
        local sliderWidth = TextSliderFrame.AbsoluteSize.X
        local percentage = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
        TextSliderButton.Position = UDim2.new(percentage, -9, -1, 0)
        
        textScaleMultiplier = 0.8 + (percentage * 0.7)
        TextSizeLabel.Text = string.format(t[activeLanguage].text_size, math.round(textScaleMultiplier * 100))
        updateTextSizes()
    end
end)

-- Слайдер інтервалу
IntervalLabel = Instance.new("TextLabel")
IntervalLabel.Name = "IntervalLabel"
IntervalLabel.Parent = ContentFrame
IntervalLabel.BackgroundTransparency = 1
IntervalLabel.Position = UDim2.new(0, 15, 0, 230)
IntervalLabel.Size = UDim2.new(1, -30, 0, 20)
IntervalLabel.Font = Enum.Font.Gotham
IntervalLabel.Text = formatIntervalText(jumpInterval, activeLanguage)
IntervalLabel.TextColor3 = Color3.fromRGB(150, 150, 155)
IntervalLabel.TextSize = baseFontSizes.SliderLabel
IntervalLabel.TextXAlignment = Enum.TextXAlignment.Left

SliderFrame = Instance.new("Frame")
local SliderFrameCorner = Instance.new("UICorner")
SliderButton = Instance.new("TextButton")
local SliderButtonCorner = Instance.new("UICorner")

SliderFrame.Name = "SliderFrame"
SliderFrame.Parent = ContentFrame
SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
SliderFrame.BorderSizePixel = 0
SliderFrame.Position = UDim2.new(0, 15, 0, 256)
SliderFrame.Size = UDim2.new(1, -30, 0, 6)

SliderFrameCorner.CornerRadius = UDim.new(1, 0)
SliderFrameCorner.Parent = SliderFrame

SliderButton.Name = "SliderButton"
SliderButton.Parent = SliderFrame
SliderButton.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
SliderButton.BorderSizePixel = 0
SliderButton.Position = UDim2.new(0.26, 0, -1, 0)
SliderButton.Size = UDim2.new(0, 18, 0, 18)
SliderButton.Text = ""

SliderButtonCorner.CornerRadius = UDim.new(1, 0)
SliderButtonCorner.Parent = SliderButton

local SliderStroke = Instance.new("UIStroke")
SliderStroke.Color = Color3.fromRGB(60, 60, 65)
SliderStroke.Thickness = 1
SliderStroke.Parent = SliderButton

-- Кнопка тестового стрибка
TestBtn = Instance.new("TextButton")
local TestBtnCorner = Instance.new("UICorner")

TestBtn.Name = "TestBtn"
TestBtn.Parent = ContentFrame
TestBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
TestBtn.BorderSizePixel = 0
TestBtn.Position = UDim2.new(0, 15, 0, 282)
TestBtn.Size = UDim2.new(1, -30, 0, 32)
TestBtn.Font = Enum.Font.GothamBold
TestBtn.Text = t[activeLanguage].btn_test
TestBtn.TextColor3 = Color3.fromRGB(220, 220, 225)
TestBtn.TextSize = baseFontSizes.TestBtn

TestBtnCorner.CornerRadius = UDim.new(0, 6)
TestBtnCorner.Parent = TestBtn

local TestStroke = Instance.new("UIStroke")
TestStroke.Color = Color3.fromRGB(50, 50, 55)
TestStroke.Thickness = 1
TestStroke.Parent = TestBtn

-- Кнопка Запустити / Зупинити
ToggleBtn = Instance.new("TextButton")
local ToggleBtnCorner = Instance.new("UICorner")

ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ContentFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Position = UDim2.new(0, 15, 0, 324)
ToggleBtn.Size = UDim2.new(1, -30, 0, 40)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = t[activeLanguage].btn_start
ToggleBtn.TextColor3 = Color3.fromRGB(15, 15, 17)
ToggleBtn.TextSize = baseFontSizes.ToggleBtn

ToggleBtnCorner.CornerRadius = UDim.new(0, 8)
ToggleBtnCorner.Parent = ToggleBtn

-- Текст-сповіщення при згортанні
InfoLabel = Instance.new("TextLabel")
InfoLabel.Name = "InfoLabel"
InfoLabel.Parent = ScreenGui
InfoLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
InfoLabel.BackgroundTransparency = 0.1
InfoLabel.Position = UDim2.new(0.5, -160, 0.05, 0)
InfoLabel.Size = UDim2.new(0, 320, 0, 36)
InfoLabel.Font = Enum.Font.GothamSemibold
InfoLabel.TextColor3 = Color3.fromRGB(220, 220, 225)
InfoLabel.TextSize = 10
InfoLabel.Text = t[activeLanguage].notif_minimized
InfoLabel.Visible = false

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 8)
InfoCorner.Parent = InfoLabel

local InfoStroke = Instance.new("UIStroke")
InfoStroke.Color = Color3.fromRGB(60, 60, 65)
InfoStroke.Thickness = 1
InfoStroke.Parent = InfoLabel

-- Кнопка відновлення
RestoreBtn = Instance.new("TextButton")
local RestoreBtnCorner = Instance.new("UICorner")
local RestoreBtnStroke = Instance.new("UIStroke")

RestoreBtn.Name = "RestoreBtn"
RestoreBtn.Parent = ScreenGui
RestoreBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
RestoreBtn.BorderSizePixel = 0
RestoreBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
RestoreBtn.Size = UDim2.new(0, 35, 0, 35)
RestoreBtn.Font = Enum.Font.GothamBold
RestoreBtn.Text = "🌌"
RestoreBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
RestoreBtn.TextSize = 16
RestoreBtn.Visible = false
RestoreBtn.Active = true

RestoreBtnCorner.CornerRadius = UDim.new(0, 8)
RestoreBtnCorner.Parent = RestoreBtn

RestoreBtnStroke.Color = Color3.fromRGB(60, 60, 65)
RestoreBtnStroke.Thickness = 1
RestoreBtnStroke.Parent = RestoreBtn

local dragStartPos = nil
local startUIPos = nil
local isDraggingRestore = false
local dragLimit = 8

RestoreBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingRestore = true
        dragStartPos = input.Position
        startUIPos = RestoreBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingRestore and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStartPos
        RestoreBtn.Position = UDim2.new(startUIPos.X.Scale, startUIPos.X.Offset + delta.X, startUIPos.Y.Scale, startUIPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if isDraggingRestore then
            isDraggingRestore = false
            if dragStartPos then
                local delta = (input.Position - dragStartPos).Magnitude
                if delta < dragLimit then
                    setMinimized(false)
                end
            end
        end
    end
end)

-- Завантажувальний екран
LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Parent = MainFrame
LoadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.Position = UDim2.new(0, 0, 0, 0)
LoadingFrame.ZIndex = 20

local LoadingCorner = Instance.new("UICorner")
LoadingCorner.CornerRadius = UDim.new(0, 10)
LoadingCorner.Parent = LoadingFrame

LogoLabel = Instance.new("TextLabel")
LogoLabel.Name = "LogoLabel"
LogoLabel.Parent = LoadingFrame
LogoLabel.BackgroundTransparency = 1
LogoLabel.Position = UDim2.new(0, 0, 0.25, 0)
LogoLabel.Size = UDim2.new(1, 0, 0, 40)
LogoLabel.Font = Enum.Font.SciFi
LogoLabel.Text = "XOLZP HUB"
LogoLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
LogoLabel.TextSize = 24
LogoLabel.ZIndex = 21

task.spawn(function()
    while LoadingFrame and LoadingFrame.Parent and LoadingFrame.Visible do
        local t1 = TweenService:Create(LogoLabel, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(120, 120, 125)})
        t1:Play()
        t1.Completed:Wait()
        if not LoadingFrame or not LoadingFrame.Parent or not LoadingFrame.Visible then break end
        local t2 = TweenService:Create(LogoLabel, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(240, 240, 245)})
        t2:Play()
        t2.Completed:Wait()
    end
end)

LoadStatus = Instance.new("TextLabel")
LoadStatus.Name = "LoadStatus"
LoadStatus.Parent = LoadingFrame
LoadStatus.BackgroundTransparency = 1
LoadStatus.Position = UDim2.new(0, 0, 0.45, 0)
LoadStatus.Size = UDim2.new(1, 0, 0, 20)
LoadStatus.Font = Enum.Font.Gotham
LoadStatus.Text = t[activeLanguage].load_1
LoadStatus.TextColor3 = Color3.fromRGB(140, 140, 145)
LoadStatus.TextSize = 10
LoadStatus.ZIndex = 21

ProgressBarBackground = Instance.new("Frame")
ProgressBarBackground.Name = "ProgressBarBG"
ProgressBarBackground.Parent = LoadingFrame
ProgressBarBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
ProgressBarBackground.Position = UDim2.new(0.15, 0, 0.6, 0)
ProgressBarBackground.Size = UDim2.new(0.7, 0, 0, 4)
ProgressBarBackground.ZIndex = 21

local ProgBGCorner = Instance.new("UICorner")
ProgBGCorner.CornerRadius = UDim.new(1, 0)
ProgBGCorner.Parent = ProgressBarBackground

ProgressBar = Instance.new("Frame")
ProgressBar.Name = "ProgressBar"
ProgressBar.Parent = ProgressBarBackground
ProgressBar.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.ZIndex = 21

local ProgCorner = Instance.new("UICorner")
ProgCorner.CornerRadius = UDim.new(1, 0)
ProgCorner.Parent = ProgressBar

PercentLabel = Instance.new("TextLabel")
PercentLabel.Name = "PercentLabel"
PercentLabel.Parent = LoadingFrame
PercentLabel.BackgroundTransparency = 1
PercentLabel.Position = UDim2.new(0, 0, 0.68, 0)
PercentLabel.Size = UDim2.new(1, 0, 0, 20)
PercentLabel.Font = Enum.Font.GothamBold
PercentLabel.Text = "0%"
PercentLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
PercentLabel.TextSize = 12
PercentLabel.ZIndex = 21

-- Зміна розміру вікна
ResizeBtn = Instance.new("TextButton")
ResizeBtn.Name = "ResizeBtn"
ResizeBtn.Parent = MainFrame
ResizeBtn.BackgroundTransparency = 1
ResizeBtn.Text = ""
ResizeBtn.Size = UDim2.new(0, 20, 0, 20)
ResizeBtn.Position = UDim2.new(1, -20, 1, -20)
ResizeBtn.ZIndex = 16

ResizeVisual = Instance.new("Frame")
ResizeVisual.Name = "ResizeVisual"
ResizeVisual.Parent = ResizeBtn
ResizeVisual.BackgroundTransparency = 1
ResizeVisual.Size = UDim2.new(1, 0, 1, 0)

local function createLine(sizeX, posX, posY)
    local line = Instance.new("Frame")
    line.BackgroundColor3 = Color3.fromRGB(150, 150, 155)
    line.BorderSizePixel = 0
    line.Rotation = 45
    line.Size = UDim2.new(0, sizeX, 0, 1.5)
    line.Position = UDim2.new(0, posX, 0, posY)
    line.Parent = ResizeVisual
    
    ResizeBtn.MouseEnter:Connect(function()
        TweenService:Create(line, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(240, 240, 245)}):Play()
    end)
    ResizeBtn.MouseLeave:Connect(function()
        TweenService:Create(line, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(150, 150, 155)}):Play()
    end)
end

createLine(4, 13, 13)
createLine(7, 10, 10)
createLine(10, 7, 7)

local resizing = false

ResizeBtn.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isLoaded and not isMinimized then
        resizing = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = UserInputService:GetMouseLocation()
        local newWidth = mousePos.X - MainFrame.AbsolutePosition.X
        local newHeight = (mousePos.Y - 36) - MainFrame.AbsolutePosition.Y
        
        newWidth = math.clamp(newWidth, minWidth, maxWidth)
        newHeight = math.clamp(newHeight, minHeight, maxHeight)
        
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

MainFrame:GetPropertyChangedSignal("Size"):Connect(function()
    if isMinimized or not isLoaded then return end
    updateLayout()
end)

-- Анімація кнопок (Hover)
local function applyHoverAnimation(button, activeColor, hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = hoverColor
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = activeColor
        }):Play()
    end)
end

applyHoverAnimation(TestBtn, Color3.fromRGB(25, 25, 28), Color3.fromRGB(35, 35, 40))
applyHoverAnimation(RestoreBtn, Color3.fromRGB(15, 15, 17), Color3.fromRGB(25, 25, 28))

-- Динамічний Hover для Toggle-кнопки
ToggleBtn.MouseEnter:Connect(function()
    local targetColor = isRunning and Color3.fromRGB(170, 40, 40) or Color3.fromRGB(255, 255, 255)
    TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = targetColor
    }):Play()
end)

ToggleBtn.MouseLeave:Connect(function()
    local targetColor = isRunning and Color3.fromRGB(135, 30, 30) or Color3.fromRGB(240, 240, 245)
    TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = targetColor
    }):Play()
end)

-- Функція запуску
local savedWidth, savedHeight = 270, 380

local function triggerLaunchSequence()
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Visible = true
    
    local popInTween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, savedWidth, 0, savedHeight)
    })
    popInTween:Play()
    popInTween.Completed:Wait()

    local stages = {
        {percent = 0.30, label = "load_1"},
        {percent = 0.60, label = "load_2"},
        {percent = 0.85, label = "load_3"},
        {percent = 1.00, label = "load_4"},
    }

    for _, stage in ipairs(stages) do
        LoadStatus.Text = t[activeLanguage][stage.label]
        local tweenProgress = TweenService:Create(ProgressBar, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(stage.percent, 0, 1, 0)
        })
        tweenProgress:Play()
        
        local startP = tonumber(string.match(PercentLabel.Text, "%d+")) or 0
        local endP = math.round(stage.percent * 100)
        task.spawn(function()
            for i = startP, endP do
                PercentLabel.Text = tostring(i) .. "%"
                task.wait(0.008)
            end
        end)
        
        task.wait(0.7)
    end

    local fadeOut = TweenService:Create(LoadingFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    local fadeLogo = TweenService:Create(LogoLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1})
    local fadeStatus = TweenService:Create(LoadStatus, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1})
    local fadeBarBG = TweenService:Create(ProgressBarBackground, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    local fadeBar = TweenService:Create(ProgressBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    local fadePercent = TweenService:Create(PercentLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1})

    fadeOut:Play()
    fadeLogo:Play()
    fadeStatus:Play()
    fadeBarBG:Play()
    fadeBar:Play()
    fadePercent:Play()
    
    fadeOut.Completed:Wait()
    LoadingFrame.Visible = false
    
    isLoaded = true 
    updateLayout()
end

-- Оновлення локалізації та візуалу
local function updateLanguage(lang)
    activeLanguage = lang
    Title.Text = t[lang].title
    IntervalLabel.Text = formatIntervalText(jumpInterval, lang)
    TextSizeLabel.Text = string.format(t[lang].text_size, math.round(textScaleMultiplier * 100))
    
    local elapsed = isRunning and (tick() - startTime) or 0
    TimerLabel.Text = t[lang].timer .. formatTime(elapsed)
    
    if isRunning then
        ToggleBtn.Text = t[lang].btn_stop
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(135, 30, 30)
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        StatusLabel.Text = t[lang].status_on
        StatusLabel.TextColor3 = Color3.fromRGB(50, 180, 50)
    else
        ToggleBtn.Text = t[lang].btn_start
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
        ToggleBtn.TextColor3 = Color3.fromRGB(15, 15, 17)
        StatusLabel.Text = t[lang].status_off
        StatusLabel.TextColor3 = Color3.fromRGB(180, 50, 50)
    end
    
    TestBtn.Text = t[lang].btn_test
    LblVirtual.Text = t[lang].cb_virtual
    LblPhysical.Text = t[lang].cb_physical
    InfoLabel.Text = t[lang].notif_minimized

    for _, btn in ipairs({BtnUA, BtnEN, BtnRU}) do
        local isSelected = (btn.Text == lang)
        btn.BackgroundColor3 = isSelected and Color3.fromRGB(240, 240, 245) or Color3.fromRGB(25, 25, 28)
        btn.TextColor3 = isSelected and Color3.fromRGB(15, 15, 17) or Color3.fromRGB(180, 180, 185)
    end
    updateLayout()
end

BtnUA.Activated:Connect(function() updateLanguage("UA") end)
BtnEN.Activated:Connect(function() updateLanguage("EN") end)
BtnRU.Activated:Connect(function() updateLanguage("RU") end)

-- Перемикання чекбоксів
local function toggleCheckbox(typeBypass)
    if typeBypass == "Virtual" then
        useVirtual = not useVirtual
        BoxVirtual.BackgroundColor3 = useVirtual and Color3.fromRGB(240, 240, 245) or Color3.fromRGB(25, 25, 28)
        BoxVirtual.Text = useVirtual and "✓" or ""
    elseif typeBypass == "Physical" then
        usePhysical = not usePhysical
        BoxPhysical.BackgroundColor3 = usePhysical and Color3.fromRGB(240, 240, 245) or Color3.fromRGB(25, 25, 28)
        BoxPhysical.Text = usePhysical and "✓" or ""
        updateLayout()
    end
end

BoxVirtual.Activated:Connect(function() toggleCheckbox("Virtual") end)
BoxPhysical.Activated:Connect(function() toggleCheckbox("Physical") end)

-- Обхід AFK через Idled
Players.LocalPlayer.Idled:Connect(function()
    if isRunning and useVirtual then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

-- Симуляція стрибка
local function makeJump()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

TestBtn.Activated:Connect(function()
    makeJump()
end)

-- Слайдер інтервалу
local dragging = false
SliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = input.Position.X
        local sliderPos = SliderFrame.AbsolutePosition.X
        local sliderWidth = SliderFrame.AbsoluteSize.X
        local percentage = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
        SliderButton.Position = UDim2.new(percentage, -9, -1, 0)
        
        jumpInterval = math.round(5 + (percentage * 1135))
        IntervalLabel.Text = formatIntervalText(jumpInterval, activeLanguage)
    end
end)

-- Основний цикл роботи (Heartbeat)
local heartbeatConnection
heartbeatConnection = RunService.Heartbeat:Connect(function()
    if not ScreenGui or not ScreenGui.Parent then
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        end
        return
    end

    if isRunning then
        local currentTime = tick()
        TimerLabel.Text = t[activeLanguage].timer .. formatTime(currentTime - startTime)
        
        if usePhysical and (currentTime - lastJumpTime >= jumpInterval) then
            makeJump()
            lastJumpTime = currentTime
        end
    end
end)

-- Логіка тригеру та кольору кнопки запуску
ToggleBtn.Activated:Connect(function()
    isRunning = not isRunning
    
    if isRunning then
        ToggleBtn.Text = t[activeLanguage].btn_stop
        TweenService:Create(ToggleBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(135, 30, 30),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        
        StatusLabel.Text = t[activeLanguage].status_on
        StatusLabel.TextColor3 = Color3.fromRGB(50, 180, 50)
        startTime = tick()
        lastJumpTime = tick()
    else
        ToggleBtn.Text = t[activeLanguage].btn_start
        TweenService:Create(ToggleBtn, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Color3.fromRGB(240, 240, 245),
            TextColor3 = Color3.fromRGB(15, 15, 17)
        }):Play()
        
        StatusLabel.Text = t[activeLanguage].status_off
        StatusLabel.TextColor3 = Color3.fromRGB(180, 50, 50)
    end
    updateLayout()
end)

-- Логіка згортання (Minimize)
setMinimized = function(state)
    isMinimized = state
    
    if state then
        savedWidth = MainFrame.Size.X.Offset
        savedHeight = MainFrame.Size.Y.Offset
        
        local minimizeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, savedWidth, 0, 0)
        })
        minimizeTween:Play()
        minimizeTween.Completed:Wait()
        if isMinimized then
            MainFrame.Visible = false
        end
        
        InfoLabel.Visible = true
        RestoreBtn.Visible = true
        task.delay(4, function()
            if isMinimized then
                InfoLabel.Visible = false
            end
        end)
    else
        MainFrame.Visible = true
        local restoreTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, savedWidth, 0, savedHeight)
        })
        restoreTween:Play()
        InfoLabel.Visible = false
        RestoreBtn.Visible = false
    end
end

MinimizeBtn.Activated:Connect(function()
    setMinimized(true)
end)

-- Кнопка повного закриття
CloseBtn.Activated:Connect(function()
    isRunning = false
    isLoaded = false
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    closeTween:Play()
    closeTween.Completed:Wait()
    ScreenGui:Destroy()
end)

-- Згортання/розгортання на Ctrl + S
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.S and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            setMinimized(not isMinimized)
        end
    end
end)

-- Запуск ініціалізації
task.spawn(triggerLaunchSequence)
