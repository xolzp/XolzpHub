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
local activeLanguage = "UA" -- "UA", "EN", "RU"
local useVirtual = true
local usePhysical = true
local textScaleMultiplier = 1.0 -- Коефіцієнт масштабу тексту (від 0.8 до 1.5)
local isLoaded = false -- Прапор закінчення завантаження
local isMinimized = false -- Глобальний прапор згортання

-- Часові змінні
local lastJumpTime = 0
local startTime = 0

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
        notif_minimized = "Меню свернуто! Нажмите [Ctrl + S], чтобы открыть снова.",
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

-- Створення GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AntiAFK_Cosmic"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Головний Фрейм
local MainFrame = Instance.new("Frame")
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

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Size = UDim2.new(1, 0, 1, 0)

-- Верхня панель (Заголовок)
local Title = Instance.new("TextLabel")
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

local CloseBtn = Instance.new("TextButton")
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

local MinimizeBtn = Instance.new("TextButton")
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
local LangFrame = Instance.new("Frame")
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

local BtnUA = createLangBtn("BtnUA", "UA", 0)
local BtnEN = createLangBtn("BtnEN", "EN", 46)
local BtnRU = createLangBtn("BtnRU", "RU", 92)

-- Статус роботи
local StatusLabel = Instance.new("TextLabel")
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
local TimerLabel = Instance.new("TextLabel")
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

local BoxVirtual, LblVirtual = createCheckbox("Virtual", t[activeLanguage].cb_virtual, 124, useVirtual)
local BoxPhysical, LblPhysical = createCheckbox("Physical", t[activeLanguage].cb_physical, 152, usePhysical)

-- Адаптивна верстка елементів усередині меню
local function updateLayout()
    if not isLoaded or isMinimized or not MainFrame or not MainFrame:IsDescendantOf(game) then return end
    
    local w = MainFrame.AbsoluteSize.X
    local h = MainFrame.AbsoluteSize.Y
    
    local ResizeBtn = MainFrame:FindFirstChild("ResizeBtn")
    if ResizeBtn then
        ResizeBtn.Position = UDim2.new(1, -20, 1, -20)
    end
    
    Title.Size = UDim2.new(1, 0, 0, h * 0.1)
    LangFrame.Position = UDim2.new(0, 15, 0, h * 0.125)
    LangFrame.Size = UDim2.new(1, -30, 0, h * 0.055)
    
    StatusLabel.Position = UDim2.new(0, 15, 0, h * 0.2)
    TimerLabel.Position = UDim2.new(0, 15, 0, h * 0.25)
    
    local bypass1 = ContentFrame:FindFirstChild("VirtualFrame")
    local bypass2 = ContentFrame:FindFirstChild("PhysicalFrame")
    if bypass1 then bypass1.Position = UDim2.new(0, 15, 0, h * 0.32) end
    if bypass2 then bypass2.Position = UDim2.new(0, 15, 0, h * 0.39) end
    
    TextSizeLabel.Position = UDim2.new(0, 15, 0, h * 0.46)
    TextSliderFrame.Position = UDim2.new(0, 15, 0, h * 0.525)
    
    IntervalLabel.Position = UDim2.new(0, 15, 0, h * 0.59)
    SliderFrame.Position = UDim2.new(0, 15, 0, h * 0.655)
    
    local TestBtn = ContentFrame:FindFirstChild("TestBtn")
    if TestBtn then
        TestBtn.Position = UDim2.new(0, 15, 0, h * 0.72)
        TestBtn.Size = UDim2.new(1, -30, 0, h * 0.08)
    end
    
    local ToggleBtn = ContentFrame:FindFirstChild("ToggleBtn")
    if ToggleBtn then
        ToggleBtn.Position = UDim2.new(0, 15, 0, h * 0.83)
        ToggleBtn.Size = UDim2.new(1, -30, 0, h * 0.1)
    end
end

-- Функція динамічного масштабування шрифтів
local function updateTextSizes()
    Title.TextSize = math.round(baseFontSizes.Title * textScaleMultiplier)
    StatusLabel.TextSize = math.round(baseFontSizes.StatusLabel * textScaleMultiplier)
    TimerLabel.TextSize = math.round(baseFontSizes.TimerLabel * textScaleMultiplier)
    
    LblVirtual.TextSize = math.round(baseFontSizes.Checkbox * textScaleMultiplier)
    LblPhysical.TextSize = math.round(baseFontSizes.Checkbox * textScaleMultiplier)
    
    local intervalLbl = ContentFrame:FindFirstChild("IntervalLabel")
    if intervalLbl then intervalLbl.TextSize = math.round(baseFontSizes.SliderLabel * textScaleMultiplier) end
    
    local textSizeLbl = ContentFrame:FindFirstChild("TextSizeLabel")
    if textSizeLbl then textSizeLbl.TextSize = math.round(baseFontSizes.SliderLabel * textScaleMultiplier) end
    
    local testBtn = ContentFrame:FindFirstChild("TestBtn")
    if testBtn then testBtn.TextSize = math.round(baseFontSizes.TestBtn * textScaleMultiplier) end
    
    local toggleBtn = ContentFrame:FindFirstChild("ToggleBtn")
    if toggleBtn then toggleBtn.TextSize = math.round(baseFontSizes.ToggleBtn * textScaleMultiplier) end
    
    BtnUA.TextSize = math.round(baseFontSizes.LangBtn * textScaleMultiplier)
    BtnEN.TextSize = math.round(baseFontSizes.LangBtn * textScaleMultiplier)
    BtnRU.TextSize = math.round(baseFontSizes.LangBtn * textScaleMultiplier)
    
    updateLayout() -- Обов'язково оновлюємо верстку, щоб уникнути зсувів
end

-- Слайдер масштабу тексту
local TextSizeLabel = Instance.new("TextLabel")
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

local TextSliderFrame = Instance.new("Frame")
local TextSliderFrameCorner = Instance.new("UICorner")
local TextSliderButton = Instance.new("TextButton")
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
TextSliderButton.MouseButton1Down:Connect(function() draggingTextSlider = true end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingTextSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingTextSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
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

-- Слайдер інтервалу (Від 5 до 1140 секунд)
local IntervalLabel = Instance.new("TextLabel")
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

local SliderFrame = Instance.new("Frame")
local SliderFrameCorner = Instance.new("UICorner")
local SliderButton = Instance.new("TextButton")
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
local TestBtn = Instance.new("TextButton")
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
local ToggleBtn = Instance.new("TextButton")
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
local InfoLabel = Instance.new("TextLabel")
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

-- Завантажувальний екран (Loading Screen)
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Parent = MainFrame
LoadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 17)
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.Position = UDim2.new(0, 0, 0, 0)
LoadingFrame.ZIndex = 20

local LoadingCorner = Instance.new("UICorner")
LoadingCorner.CornerRadius = UDim.new(0, 10)
LoadingCorner.Parent = LoadingFrame

local LogoLabel = Instance.new("TextLabel")
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

local LoadStatus = Instance.new("TextLabel")
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

local ProgressBarBackground = Instance.new("Frame")
ProgressBarBackground.Name = "ProgressBarBG"
ProgressBarBackground.Parent = LoadingFrame
ProgressBarBackground.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
ProgressBarBackground.Position = UDim2.new(0.15, 0, 0.6, 0)
ProgressBarBackground.Size = UDim2.new(0.7, 0, 0, 4)
ProgressBarBackground.ZIndex = 21

local ProgBGCorner = Instance.new("UICorner")
ProgBGCorner.CornerRadius = UDim.new(1, 0)
ProgBGCorner.Parent = ProgressBarBackground

local ProgressBar = Instance.new("Frame")
ProgressBar.Name = "ProgressBar"
ProgressBar.Parent = ProgressBarBackground
ProgressBar.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.ZIndex = 21

local ProgCorner = Instance.new("UICorner")
ProgCorner.CornerRadius = UDim.new(1, 0)
ProgCorner.Parent = ProgressBar

local PercentLabel = Instance.new("TextLabel")
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


-- =======================================================
-- ПРОЦЕДУРНИЙ КУТОЧОК ЗМІНИ РОЗМІРУ (ВЕКТОРНИЙ)
-- =======================================================
local ResizeBtn = Instance.new("TextButton")
ResizeBtn.Name = "ResizeBtn"
ResizeBtn.Parent = MainFrame
ResizeBtn.BackgroundTransparency = 1
ResizeBtn.Text = ""
ResizeBtn.Size = UDim2.new(0, 20, 0, 20)
ResizeBtn.Position = UDim2.new(1, -20, 1, -20)
ResizeBtn.ZIndex = 16

local ResizeVisual = Instance.new("Frame")
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
local minWidth, minHeight = 220, 300
local maxWidth, maxHeight = 600, 800

ResizeBtn.MouseButton1Down:Connect(function()
    if isLoaded and not isMinimized then
        resizing = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local newWidth = mousePos.X - MainFrame.AbsolutePosition.X
        local newHeight = (mousePos.Y - 36) - MainFrame.AbsolutePosition.Y
        
        newWidth = math.clamp(newWidth, minWidth, maxWidth)
        newHeight = math.clamp(newHeight, minHeight, maxHeight)
        
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

-- Обробник зміни розміру з блокуванням під час завантаження
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
applyHoverAnimation(ToggleBtn, Color3.fromRGB(240, 240, 245), Color3.fromRGB(255, 255, 255))


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

-- Оновлення локалізації
local function updateLanguage(lang)
    activeLanguage = lang
    Title.Text = t[lang].title
    StatusLabel.Text = isRunning and t[lang].status_on or t[lang].status_off
    IntervalLabel.Text = formatIntervalText(jumpInterval, lang)
    TextSizeLabel.Text = string.format(t[lang].text_size, math.round(textScaleMultiplier * 100))
    
    local elapsed = isRunning and (tick() - startTime) or 0
    TimerLabel.Text = t[lang].timer .. formatTime(elapsed)
    
    if isRunning then
        ToggleBtn.Text = t[lang].btn_stop
    else
        ToggleBtn.Text = t[lang].btn_start
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
end

BtnUA.MouseButton1Click:Connect(function() updateLanguage("UA") end)
BtnEN.MouseButton1Click:Connect(function() updateLanguage("EN") end)
BtnRU.MouseButton1Click:Connect(function() updateLanguage("RU") end)

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
        
        IntervalLabel.Visible = usePhysical
        SliderFrame.Visible = usePhysical
        TestBtn.Visible = usePhysical
    end
end

BoxVirtual.MouseButton1Click:Connect(function() toggleCheckbox("Virtual") end)
BoxPhysical.MouseButton1Click:Connect(function() toggleCheckbox("Physical") end)

-- Обхід AFK через Idled (VirtualUser)
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

TestBtn.MouseButton1Click:Connect(function()
    makeJump()
end)

-- Слайдер інтервалу
local dragging = false
SliderButton.MouseButton1Down:Connect(function() dragging = true end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = input.Position.X
        local sliderPos = SliderFrame.AbsolutePosition.X
        local sliderWidth = SliderFrame.AbsoluteSize.X
        local percentage = math.clamp((mousePos - sliderPos) / sliderWidth, 0, 1)
        SliderButton.Position = UDim2.new(percentage, -9, -1, 0)
        
        -- Безпечне обмеження мінімуму: від 5 секунд до 1140 секунд (19 хвилин)
        jumpInterval = math.round(5 + (percentage * 1135))
        IntervalLabel.Text = formatIntervalText(jumpInterval, activeLanguage)
    end
end)

-- Основний цикл роботи (Heartbeat) із захистом від витоку пам'яті
local heartbeatConnection
heartbeatConnection = RunService.Heartbeat:Connect(function()
    -- Якщо GUI видалено, зупиняємо цикл та чистимо з'єднання
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

-- Кнопка запуску
ToggleBtn.MouseButton1Click:Connect(function()
    isRunning = not isRunning
    if isRunning then
        ToggleBtn.Text = t[activeLanguage].btn_stop
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        StatusLabel.Text = t[activeLanguage].status_on
        StatusLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
        startTime = tick()
        lastJumpTime = tick()
    else
        ToggleBtn.Text = t[activeLanguage].btn_start
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
        ToggleBtn.TextColor3 = Color3.fromRGB(15, 15, 17)
        StatusLabel.Text = t[activeLanguage].status_off
        StatusLabel.TextColor3 = Color3.fromRGB(180, 50, 50)
    end
end)

-- Логіка згортання (Minimize)
local function setMinimized(state)
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
    end
end

MinimizeBtn.MouseButton1Click:Connect(function()
    setMinimized(true)
end)

-- Кнопка повного закриття
CloseBtn.MouseButton1Click:Connect(function()
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

-- Згортання/розгортання на комбінацію клавіш Ctrl + S
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.S and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            setMinimized(not isMinimized)
        end
    end
end)

-- Запуск ініціалізації
task.spawn(triggerLaunchSequence)
