--[[
    NexusLib - Modern Roblox UI Library
    Version: 1.0.0
    
    Inspired by: Rayfield, Orion, Kavo UI
    
    USAGE EXAMPLE:
    
    local NexusLib = loadstring(game:HttpGet("..."))()
    
    local Window = NexusLib:CreateWindow({
        Title = "My Script",
        Subtitle = "v1.0",
        Theme = "Dark",       -- "Dark" | "Light" | "Midnight" | "Neon"
        Logo = "rbxassetid://...",
        Size = UDim2.new(0, 580, 0, 460),
        Position = UDim2.new(0.5, -290, 0.5, -230),
        MinimizeKey = Enum.KeyCode.RightControl,
    })
    
    local Tab = Window:CreateTab("Main", "rbxassetid://...")
    
    Tab:CreateButton({ Label = "Click Me", Callback = function() print("clicked") end })
    Tab:CreateToggle({ Label = "Enable Fly", Default = false, Callback = function(v) end })
    Tab:CreateSlider({ Label = "Speed", Min = 0, Max = 100, Default = 50, Callback = function(v) end })
    Tab:CreateDropdown({ Label = "Mode", Options = {"A","B","C"}, Default = "A", Callback = function(v) end })
    Tab:CreateInput({ Label = "Name", Placeholder = "Enter name...", Callback = function(v) end })
    Tab:CreateColorPicker({ Label = "Color", Default = Color3.fromRGB(255,100,50), Callback = function(c) end })
    Tab:CreateKeybind({ Label = "Toggle GUI", Default = Enum.KeyCode.RightShift, Callback = function(k) end })
    Tab:CreateLabel("Section Header")
    Tab:CreateDivider()
    
    NexusLib:Notify({ Title = "Loaded!", Text = "NexusLib initialized.", Duration = 3 })
]]

-- ════════════════════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════════════════════

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local TextService      = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ════════════════════════════════════════════════════════════════
--  THEMES
-- ════════════════════════════════════════════════════════════════

local Themes = {
    Dark = {
        Background       = Color3.fromRGB(18,  18,  22),
        Surface          = Color3.fromRGB(26,  26,  32),
        SurfaceAlt       = Color3.fromRGB(34,  34,  42),
        Border           = Color3.fromRGB(50,  50,  62),
        Accent           = Color3.fromRGB(99,  102, 241),  -- indigo
        AccentHover      = Color3.fromRGB(129, 132, 255),
        TextPrimary      = Color3.fromRGB(240, 240, 250),
        TextSecondary    = Color3.fromRGB(148, 148, 170),
        TextMuted        = Color3.fromRGB(90,  90,  110),
        Success          = Color3.fromRGB(52,  211, 153),
        Warning          = Color3.fromRGB(251, 191, 36),
        Error            = Color3.fromRGB(248, 113, 113),
        SliderTrack      = Color3.fromRGB(40,  40,  50),
        SliderFill       = Color3.fromRGB(99,  102, 241),
        ToggleOff        = Color3.fromRGB(60,  60,  75),
        ToggleOn         = Color3.fromRGB(99,  102, 241),
        ScrollBar        = Color3.fromRGB(60,  60,  75),
        TitleBar         = Color3.fromRGB(22,  22,  28),
        TabBar           = Color3.fromRGB(20,  20,  26),
        TabActive        = Color3.fromRGB(99,  102, 241),
        TabInactive      = Color3.fromRGB(0,   0,   0, 0),
    },
    Midnight = {
        Background       = Color3.fromRGB(8,   10,  20),
        Surface          = Color3.fromRGB(14,  16,  30),
        SurfaceAlt       = Color3.fromRGB(20,  24,  44),
        Border           = Color3.fromRGB(36,  40,  70),
        Accent           = Color3.fromRGB(139, 92,  246), -- violet
        AccentHover      = Color3.fromRGB(167, 139, 250),
        TextPrimary      = Color3.fromRGB(232, 232, 255),
        TextSecondary    = Color3.fromRGB(140, 140, 180),
        TextMuted        = Color3.fromRGB(80,  80,  120),
        Success          = Color3.fromRGB(52,  211, 153),
        Warning          = Color3.fromRGB(251, 191, 36),
        Error            = Color3.fromRGB(248, 113, 113),
        SliderTrack      = Color3.fromRGB(28,  30,  56),
        SliderFill       = Color3.fromRGB(139, 92,  246),
        ToggleOff        = Color3.fromRGB(50,  50,  80),
        ToggleOn         = Color3.fromRGB(139, 92,  246),
        ScrollBar        = Color3.fromRGB(50,  50,  80),
        TitleBar         = Color3.fromRGB(10,  12,  24),
        TabBar           = Color3.fromRGB(10,  12,  22),
        TabActive        = Color3.fromRGB(139, 92,  246),
        TabInactive      = Color3.fromRGB(0,   0,   0, 0),
    },
    Neon = {
        Background       = Color3.fromRGB(10,  10,  10),
        Surface          = Color3.fromRGB(16,  16,  16),
        SurfaceAlt       = Color3.fromRGB(22,  22,  22),
        Border           = Color3.fromRGB(40,  40,  40),
        Accent           = Color3.fromRGB(0,   255, 170),  -- neon teal
        AccentHover      = Color3.fromRGB(80,  255, 200),
        TextPrimary      = Color3.fromRGB(240, 255, 245),
        TextSecondary    = Color3.fromRGB(140, 170, 155),
        TextMuted        = Color3.fromRGB(80,  100, 90),
        Success          = Color3.fromRGB(0,   255, 100),
        Warning          = Color3.fromRGB(255, 220, 0),
        Error            = Color3.fromRGB(255, 60,  80),
        SliderTrack      = Color3.fromRGB(30,  30,  30),
        SliderFill       = Color3.fromRGB(0,   255, 170),
        ToggleOff        = Color3.fromRGB(50,  50,  50),
        ToggleOn         = Color3.fromRGB(0,   255, 170),
        ScrollBar        = Color3.fromRGB(40,  40,  40),
        TitleBar         = Color3.fromRGB(12,  12,  12),
        TabBar           = Color3.fromRGB(12,  12,  12),
        TabActive        = Color3.fromRGB(0,   255, 170),
        TabInactive      = Color3.fromRGB(0,   0,   0, 0),
    },
    Light = {
        Background       = Color3.fromRGB(248, 248, 252),
        Surface          = Color3.fromRGB(255, 255, 255),
        SurfaceAlt       = Color3.fromRGB(242, 242, 248),
        Border           = Color3.fromRGB(215, 215, 228),
        Accent           = Color3.fromRGB(99,  102, 241),
        AccentHover      = Color3.fromRGB(79,  70,  229),
        TextPrimary      = Color3.fromRGB(20,  20,  40),
        TextSecondary    = Color3.fromRGB(90,  90,  120),
        TextMuted        = Color3.fromRGB(160, 160, 180),
        Success          = Color3.fromRGB(16,  185, 129),
        Warning          = Color3.fromRGB(245, 158, 11),
        Error            = Color3.fromRGB(239, 68,  68),
        SliderTrack      = Color3.fromRGB(220, 220, 235),
        SliderFill       = Color3.fromRGB(99,  102, 241),
        ToggleOff        = Color3.fromRGB(200, 200, 215),
        ToggleOn         = Color3.fromRGB(99,  102, 241),
        ScrollBar        = Color3.fromRGB(200, 200, 215),
        TitleBar         = Color3.fromRGB(240, 240, 248),
        TabBar           = Color3.fromRGB(240, 240, 248),
        TabActive        = Color3.fromRGB(99,  102, 241),
        TabInactive      = Color3.fromRGB(0,   0,   0, 0),
    },
}

-- ════════════════════════════════════════════════════════════════
--  UTILITY
-- ════════════════════════════════════════════════════════════════

local function Tween(obj, props, t, style, dir)
    local ti = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, ti, props):Play()
end

local function Create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if type(k) == "string" then
            obj[k] = v
        end
    end
    for _, child in pairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function AddCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function AddPadding(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 8)
    p.PaddingBottom = UDim.new(0, b or 8)
    p.PaddingLeft   = UDim.new(0, l or 10)
    p.PaddingRight  = UDim.new(0, r or 10)
    p.Parent = parent
    return p
end

local function AddStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color     = color
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function AddListLayout(parent, dir, spacing, halign, valign)
    local l = Instance.new("UIListLayout")
    l.FillDirection     = dir     or Enum.FillDirection.Vertical
    l.Padding           = UDim.new(0, spacing or 6)
    l.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment   = valign or Enum.VerticalAlignment.Top
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Parent = parent
    return l
end

local function AddSizeConstraint(parent, min, max)
    local c = Instance.new("UISizeConstraint")
    c.MinSize = min or Vector2.new(0, 0)
    c.MaxSize = max or Vector2.new(math.huge, math.huge)
    c.Parent  = parent
    return c
end

-- Dragging logic
local function MakeDraggable(handle, target)
    local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            mousePos  = input.Position
            framePos  = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            target.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
--  NEXUSLIB CORE
-- ════════════════════════════════════════════════════════════════

local NexusLib = {}
NexusLib.__index = NexusLib

local ActiveWindows = {}
local NotifQueue    = {}

-- ── Window ──────────────────────────────────────────────────────

function NexusLib:CreateWindow(config)
    config = config or {}
    local theme   = Themes[config.Theme] or Themes.Dark
    local minKey  = config.MinimizeKey or Enum.KeyCode.RightControl
    local winSize = config.Size or UDim2.new(0, 580, 0, 460)
    local winPos  = config.Position or UDim2.new(0.5, -290, 0.5, -230)

    -- Root ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name            = "NexusLib_" .. (config.Title or "Window"),
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
        DisplayOrder    = 999,
        Parent          = (pcall(function() return CoreGui end) and CoreGui) or LocalPlayer.PlayerGui,
    })

    -- ── Main Frame ──────────────────────────────────────────────
    local MainFrame = Create("Frame", {
        Name            = "MainFrame",
        Size            = winSize,
        Position        = winPos,
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent          = ScreenGui,
    })
    AddCorner(MainFrame, 12)
    AddStroke(MainFrame, theme.Border, 1)
    AddSizeConstraint(MainFrame, Vector2.new(380, 300), Vector2.new(900, 700))

    -- Drop Shadow
    local Shadow = Create("ImageLabel", {
        Name              = "Shadow",
        AnchorPoint       = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position          = UDim2.new(0.5, 0, 0.5, 4),
        Size              = UDim2.new(1, 30, 1, 30),
        ZIndex            = 0,
        Image             = "rbxassetid://6015897843",
        ImageColor3       = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.55,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(49, 49, 450, 450),
        Parent            = MainFrame,
    })

    -- ── Title Bar ───────────────────────────────────────────────
    local TitleBar = Create("Frame", {
        Name            = "TitleBar",
        Size            = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = theme.TitleBar,
        BorderSizePixel = 0,
        ZIndex          = 5,
        Parent          = MainFrame,
    })
    AddCorner(TitleBar, 12)

    -- Fix bottom corners of title bar
    Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 12),
        Position        = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = theme.TitleBar,
        BorderSizePixel = 0,
        ZIndex          = 5,
        Parent          = TitleBar,
    })

    -- Logo
    local LogoImg = Create("ImageLabel", {
        Name              = "Logo",
        Size              = UDim2.new(0, 28, 0, 28),
        Position          = UDim2.new(0, 14, 0.5, -14),
        BackgroundTransparency = 1,
        Image             = config.Logo or "rbxassetid://10723407389",
        ImageColor3       = theme.Accent,
        ZIndex            = 6,
        Parent            = TitleBar,
    })

    local TitleLabel = Create("TextLabel", {
        Name            = "Title",
        Text            = config.Title or "NexusLib",
        Font            = Enum.Font.GothamBold,
        TextSize        = 16,
        TextColor3      = theme.TextPrimary,
        BackgroundTransparency = 1,
        Size            = UDim2.new(0, 200, 1, 0),
        Position        = UDim2.new(0, 50, 0, 0),
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 6,
        Parent          = TitleBar,
    })

    if config.Subtitle then
        local Sub = Create("TextLabel", {
            Text            = config.Subtitle,
            Font            = Enum.Font.Gotham,
            TextSize        = 11,
            TextColor3      = theme.TextSecondary,
            BackgroundTransparency = 1,
            Size            = UDim2.new(0, 200, 0, 14),
            Position        = UDim2.new(0, 50, 0.5, 2),
            TextXAlignment  = Enum.TextXAlignment.Left,
            ZIndex          = 6,
            Parent          = TitleBar,
        })
        TitleLabel.Position = UDim2.new(0, 50, 0, 8)
    end

    -- Window control buttons
    local BtnContainer = Create("Frame", {
        Size            = UDim2.new(0, 70, 1, 0),
        Position        = UDim2.new(1, -80, 0, 0),
        BackgroundTransparency = 1,
        ZIndex          = 6,
        Parent          = TitleBar,
    })
    AddListLayout(BtnContainer, Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)

    local function MakeCtrlBtn(color, icon, callback)
        local btn = Create("TextButton", {
            Size            = UDim2.new(0, 24, 0, 24),
            BackgroundColor3 = color,
            Text            = "",
            ZIndex          = 7,
            Parent          = BtnContainer,
        })
        AddCorner(btn, 12)
        local lbl = Create("TextLabel", {
            Text            = icon,
            Font            = Enum.Font.GothamBold,
            TextSize        = 13,
            TextColor3      = Color3.fromRGB(255,255,255),
            TextTransparency = 0.3,
            BackgroundTransparency = 1,
            Size            = UDim2.fromScale(1,1),
            ZIndex          = 8,
            Parent          = btn,
        })
        btn.MouseButton1Click:Connect(callback)
        btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency = 0.2}, 0.12) end)
        btn.MouseLeave:Connect(function() Tween(btn, {BackgroundTransparency = 0}, 0.12) end)
        return btn
    end

    local minimized = false
    MakeCtrlBtn(Color3.fromRGB(255,189,68), "–", function()
        minimized = not minimized
        if minimized then
            Tween(MainFrame, {Size = UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 52)}, 0.3)
        else
            Tween(MainFrame, {Size = winSize}, 0.3)
        end
    end)

    MakeCtrlBtn(Color3.fromRGB(255,95,87), "×", function()
        Tween(MainFrame, {BackgroundTransparency = 1, Size = UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 0)}, 0.25)
        task.wait(0.26)
        ScreenGui:Destroy()
    end)

    MakeDraggable(TitleBar, MainFrame)

    -- ── Tab Bar ─────────────────────────────────────────────────
    local TabBar = Create("Frame", {
        Name            = "TabBar",
        Size            = UDim2.new(0, 160, 1, -52),
        Position        = UDim2.new(0, 0, 0, 52),
        BackgroundColor3 = theme.TabBar,
        BorderSizePixel = 0,
        ZIndex          = 4,
        Parent          = MainFrame,
    })

    local TabListContainer = Create("ScrollingFrame", {
        Name            = "TabList",
        Size            = UDim2.new(1, -8, 1, -8),
        Position        = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.ScrollBar,
        CanvasSize      = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
        ZIndex          = 5,
        Parent          = TabBar,
    })
    AddListLayout(TabListContainer, Enum.FillDirection.Vertical, 4)
    AddPadding(TabListContainer, 4, 4, 4, 4)

    -- ── Content Area ────────────────────────────────────────────
    local ContentArea = Create("Frame", {
        Name            = "ContentArea",
        Size            = UDim2.new(1, -160, 1, -52),
        Position        = UDim2.new(0, 160, 0, 52),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        ZIndex          = 4,
        Parent          = MainFrame,
    })

    local TabSeparator = Create("Frame", {
        Size            = UDim2.new(0, 1, 1, 0),
        Position        = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = theme.Border,
        BorderSizePixel = 0,
        ZIndex          = 5,
        Parent          = ContentArea,
    })

    -- Entrance animation
    MainFrame.BackgroundTransparency = 1
    MainFrame.Size = UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 0)
    Tween(MainFrame, {BackgroundTransparency = 0, Size = winSize}, 0.35, Enum.EasingStyle.Back)

    -- Minimize keybind
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == minKey then
            minimized = not minimized
            if minimized then
                Tween(MainFrame, {Size = UDim2.new(winSize.X.Scale, winSize.X.Offset, 0, 52)}, 0.3)
            else
                Tween(MainFrame, {Size = winSize}, 0.3)
            end
        end
    end)

    -- ── Window Object ────────────────────────────────────────────
    local Window = {}
    Window._theme        = theme
    Window._tabList      = TabListContainer
    Window._contentArea  = ContentArea
    Window._activeTab    = nil
    Window._tabs         = {}
    Window._screenGui    = ScreenGui

    -- ── CreateTab ────────────────────────────────────────────────
    function Window:CreateTab(name, icon)
        local tabPage = Create("ScrollingFrame", {
            Name            = name .. "_Page",
            Size            = UDim2.new(1, -2, 1, 0),
            Position        = UDim2.new(0, 2, 0, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme.ScrollBar,
            CanvasSize      = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BorderSizePixel = 0,
            Visible         = false,
            ZIndex          = 5,
            Parent          = ContentArea,
        })
        AddListLayout(tabPage, Enum.FillDirection.Vertical, 6)
        AddPadding(tabPage, 10, 10, 12, 12)

        -- Tab button
        local TabBtn = Create("TextButton", {
            Name            = name .. "_Btn",
            Size            = UDim2.new(1, -4, 0, 36),
            BackgroundColor3 = theme.TabInactive,
            BackgroundTransparency = 1,
            Text            = "",
            ZIndex          = 6,
            Parent          = TabListContainer,
        })
        AddCorner(TabBtn, 8)

        if icon then
            local ico = Create("ImageLabel", {
                Size            = UDim2.new(0, 18, 0, 18),
                Position        = UDim2.new(0, 10, 0.5, -9),
                BackgroundTransparency = 1,
                Image           = icon,
                ImageColor3     = theme.TextSecondary,
                ZIndex          = 7,
                Parent          = TabBtn,
            })
        end

        local TabLabel = Create("TextLabel", {
            Text            = name,
            Font            = Enum.Font.GothamSemibold,
            TextSize        = 13,
            TextColor3      = theme.TextSecondary,
            BackgroundTransparency = 1,
            Size            = UDim2.new(1, icon and -36 or -14, 1, 0),
            Position        = UDim2.new(0, icon and 34 or 10, 0, 0),
            TextXAlignment  = Enum.TextXAlignment.Left,
            ZIndex          = 7,
            Parent          = TabBtn,
        })

        local ActiveIndicator = Create("Frame", {
            Size            = UDim2.new(0, 3, 0.6, 0),
            Position        = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex          = 7,
            Parent          = TabBtn,
        })
        AddCorner(ActiveIndicator, 4)

        local function Activate()
            -- Hide all pages
            for _, t in ipairs(Window._tabs) do
                t.page.Visible = false
                Tween(t.btn, {BackgroundTransparency = 1}, 0.15)
                Tween(t.label, {TextColor3 = theme.TextSecondary}, 0.15)
                Tween(t.indicator, {BackgroundTransparency = 1}, 0.15)
            end
            tabPage.Visible = true
            Tween(TabBtn, {BackgroundTransparency = 0.88}, 0.15)
            Tween(TabLabel, {TextColor3 = theme.TextPrimary}, 0.15)
            Tween(ActiveIndicator, {BackgroundTransparency = 0}, 0.15)
            Window._activeTab = name
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        TabBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= name then
                Tween(TabBtn, {BackgroundTransparency = 0.92}, 0.12)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= name then
                Tween(TabBtn, {BackgroundTransparency = 1}, 0.12)
            end
        end)

        local tabEntry = { page = tabPage, btn = TabBtn, label = TabLabel, indicator = ActiveIndicator }
        table.insert(Window._tabs, tabEntry)

        if #Window._tabs == 1 then Activate() end

        -- ── TAB ELEMENTS ────────────────────────────────────────

        local Tab = {}

        -- Helper: item container
        local function NewItem(height)
            local frame = Create("Frame", {
                Size            = UDim2.new(1, -4, 0, height or 46),
                BackgroundColor3 = theme.SurfaceAlt,
                BorderSizePixel = 0,
                ZIndex          = 6,
                Parent          = tabPage,
            })
            AddCorner(frame, 8)
            AddStroke(frame, theme.Border, 1)
            return frame
        end

        -- ── Button ───────────────────────────────────────────────
        function Tab:CreateButton(cfg)
            cfg = cfg or {}
            local frame = NewItem(44)

            local lbl = Create("TextLabel", {
                Text            = cfg.Label or "Button",
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 14,
                TextColor3      = theme.TextPrimary,
                BackgroundTransparency = 1,
                Size            = UDim2.new(1, -130, 1, 0),
                Position        = UDim2.new(0, 14, 0, 0),
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 7,
                Parent          = frame,
            })

            if cfg.Description then
                lbl.Font     = Enum.Font.Gotham
                lbl.TextSize = 12
                lbl.TextColor3 = theme.TextSecondary
                lbl.Position   = UDim2.new(0, 14, 0.5, 0)
                lbl.Text       = cfg.Description
                local mainLbl = Create("TextLabel", {
                    Text            = cfg.Label or "Button",
                    Font            = Enum.Font.GothamSemibold,
                    TextSize        = 14,
                    TextColor3      = theme.TextPrimary,
                    BackgroundTransparency = 1,
                    Size            = UDim2.new(1, -130, 0.5, 0),
                    Position        = UDim2.new(0, 14, 0, 0),
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    ZIndex          = 7,
                    Parent          = frame,
                })
            end

            local btn = Create("TextButton", {
                Text            = cfg.ButtonText or "Execute",
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 12,
                TextColor3      = Color3.fromRGB(255,255,255),
                BackgroundColor3 = theme.Accent,
                Size            = UDim2.new(0, 90, 0, 28),
                Position        = UDim2.new(1, -104, 0.5, -14),
                AutoButtonColor = false,
                ZIndex          = 7,
                Parent          = frame,
            })
            AddCorner(btn, 6)

            btn.MouseButton1Click:Connect(function()
                Tween(btn, {BackgroundColor3 = theme.AccentHover}, 0.1)
                task.delay(0.15, function() Tween(btn, {BackgroundColor3 = theme.Accent}, 0.15) end)
                if cfg.Callback then pcall(cfg.Callback) end
            end)
            btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = theme.AccentHover}, 0.12) end)
            btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = theme.Accent}, 0.12) end)

            local Element = {}
            function Element:SetLabel(text) lbl.Text = text end
            return Element
        end

        -- ── Toggle ───────────────────────────────────────────────
        function Tab:CreateToggle(cfg)
            cfg = cfg or {}
            local state = cfg.Default or false
            local frame = NewItem(44)

            local lbl = Create("TextLabel", {
                Text            = cfg.Label or "Toggle",
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 14,
                TextColor3      = theme.TextPrimary,
                BackgroundTransparency = 1,
                Size            = UDim2.new(1, -70, 1, 0),
                Position        = UDim2.new(0, 14, 0, 0),
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 7,
                Parent          = frame,
            })

            local track = Create("Frame", {
                Size            = UDim2.new(0, 44, 0, 24),
                Position        = UDim2.new(1, -58, 0.5, -12),
                BackgroundColor3 = state and theme.ToggleOn or theme.ToggleOff,
                ZIndex          = 7,
                Parent          = frame,
            })
            AddCorner(track, 12)

            local thumb = Create("Frame", {
                Size            = UDim2.new(0, 18, 0, 18),
                Position        = state and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                ZIndex          = 8,
                Parent          = track,
            })
            AddCorner(thumb, 9)

            local trackBtn = Create("TextButton", {
                Size            = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text            = "",
                ZIndex          = 9,
                Parent          = track,
            })

            local function SetState(v)
                state = v
                Tween(track, {BackgroundColor3 = state and theme.ToggleOn or theme.ToggleOff}, 0.18)
                Tween(thumb, {Position = state and UDim2.new(0, 23, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}, 0.18)
                if cfg.Callback then pcall(cfg.Callback, state) end
            end

            trackBtn.MouseButton1Click:Connect(function() SetState(not state) end)

            local Element = {}
            function Element:Set(v) SetState(v) end
            function Element:Get() return state end
            return Element
        end

        -- ── Slider ───────────────────────────────────────────────
        function Tab:CreateSlider(cfg)
            cfg = cfg or {}
            local min     = cfg.Min or 0
            local max     = cfg.Max or 100
            local value   = math.clamp(cfg.Default or min, min, max)
            local step    = cfg.Step or 1
            local frame   = NewItem(58)

            local topRow = Create("Frame", {
                Size            = UDim2.new(1, -14, 0, 26),
                Position        = UDim2.new(0, 14, 0, 6),
                BackgroundTransparency = 1,
                ZIndex          = 7,
                Parent          = frame,
            })

            local lbl = Create("TextLabel", {
                Text            = cfg.Label or "Slider",
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 14,
                TextColor3      = theme.TextPrimary,
                BackgroundTransparency = 1,
                Size            = UDim2.new(1, -60, 1, 0),
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 7,
                Parent          = topRow,
            })

            local valLbl = Create("TextLabel", {
                Text            = tostring(value),
                Font            = Enum.Font.GothamBold,
                TextSize        = 13,
                TextColor3      = theme.Accent,
                BackgroundTransparency = 1,
                Size            = UDim2.new(0, 55, 1, 0),
                Position        = UDim2.new(1, -55, 0, 0),
                TextXAlignment  = Enum.TextXAlignment.Right,
                ZIndex          = 7,
                Parent          = topRow,
            })

            local trackBg = Create("Frame", {
                Size            = UDim2.new(1, -28, 0, 6),
                Position        = UDim2.new(0, 14, 0, 40),
                BackgroundColor3 = theme.SliderTrack,
                ZIndex          = 7,
                Parent          = frame,
            })
            AddCorner(trackBg, 4)

            local fill = Create("Frame", {
                Size            = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = theme.SliderFill,
                ZIndex          = 8,
                Parent          = trackBg,
            })
            AddCorner(fill, 4)

            local knob = Create("Frame", {
                Size            = UDim2.new(0, 16, 0, 16),
                Position        = UDim2.new((value - min) / (max - min), -8, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                ZIndex          = 9,
                Parent          = trackBg,
            })
            AddCorner(knob, 8)
            AddStroke(knob, theme.Accent, 2)

            local slidBtn = Create("TextButton", {
                Size            = UDim2.new(1, 0, 0, 28),
                Position        = UDim2.new(0, 0, 0.5, -14),
                BackgroundTransparency = 1,
                Text            = "",
                ZIndex          = 10,
                Parent          = trackBg,
            })

            local sliding = false
            local function UpdateSlider(input)
                local trackPos  = trackBg.AbsolutePosition.X
                local trackWidth = trackBg.AbsoluteSize.X
                local rel = math.clamp((input.Position.X - trackPos) / trackWidth, 0, 1)
                local raw = min + rel * (max - min)
                local stepped = math.round(raw / step) * step
                value = math.clamp(stepped, min, max)
                local pct = (value - min) / (max - min)
                fill.Size     = UDim2.new(pct, 0, 1, 0)
                knob.Position = UDim2.new(pct, -8, 0.5, -8)
                valLbl.Text   = tostring(value)
                if cfg.Callback then pcall(cfg.Callback, value) end
            end

            slidBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    UpdateSlider(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)

            local Element = {}
            function Element:Set(v)
                value = math.clamp(v, min, max)
                local pct = (value - min) / (max - min)
                Tween(fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.15)
                Tween(knob, {Position = UDim2.new(pct, -8, 0.5, -8)}, 0.15)
                valLbl.Text = tostring(value)
            end
            function Element:Get() return value end
            return Element
        end

        -- ── Dropdown ─────────────────────────────────────────────
        function Tab:CreateDropdown(cfg)
            cfg = cfg or {}
            local options  = cfg.Options or {}
            local selected = cfg.Default or (options[1] or "")
            local open     = false
            local itemH    = 30
            local frame    = NewItem(44)

            local lbl = Create("TextLabel", {
                Text            = cfg.Label or "Dropdown",
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 14,
                TextColor3      = theme.TextPrimary,
                BackgroundTransparency = 1,
                Size            = UDim2.new(0.5, 0, 1, 0),
                Position        = UDim2.new(0, 14, 0, 0),
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 7,
                Parent          = frame,
            })

            local dropBtn = Create("TextButton", {
                Text            = "",
                Size            = UDim2.new(0, 140, 0, 30),
                Position        = UDim2.new(1, -154, 0.5, -15),
                BackgroundColor3 = theme.Background,
                ZIndex          = 7,
                Parent          = frame,
            })
            AddCorner(dropBtn, 7)
            AddStroke(dropBtn, theme.Border, 1)

            local selLabel = Create("TextLabel", {
                Text            = selected,
                Font            = Enum.Font.Gotham,
                TextSize        = 13,
                TextColor3      = theme.TextPrimary,
                BackgroundTransparency = 1,
                Size            = UDim2.new(1, -28, 1, 0),
                Position        = UDim2.new(0, 10, 0, 0),
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 8,
                Parent          = dropBtn,
            })

            local arrow = Create("TextLabel", {
                Text            = "▾",
                Font            = Enum.Font.GothamBold,
                TextSize        = 12,
                TextColor3      = theme.TextSecondary,
                BackgroundTransparency = 1,
                Size            = UDim2.new(0, 20, 1, 0),
                Position        = UDim2.new(1, -22, 0, 0),
                ZIndex          = 8,
                Parent          = dropBtn,
            })

            -- Dropdown list (shown over everything)
            local listFrame = Create("Frame", {
                Size            = UDim2.new(0, 140, 0, #options * itemH + 8),
                Position        = UDim2.new(1, -154, 1, 4),
                BackgroundColor3 = theme.SurfaceAlt,
                BorderSizePixel = 0,
                Visible         = false,
                ZIndex          = 20,
                Parent          = frame,
            })
            AddCorner(listFrame, 8)
            AddStroke(listFrame, theme.Border, 1)
            AddPadding(listFrame, 4, 4, 4, 4)
            AddListLayout(listFrame, Enum.FillDirection.Vertical, 2)

            for _, opt in ipairs(options) do
                local optBtn = Create("TextButton", {
                    Text            = opt,
                    Font            = Enum.Font.Gotham,
                    TextSize        = 13,
                    TextColor3      = opt == selected and theme.Accent or theme.TextPrimary,
                    BackgroundColor3 = theme.SurfaceAlt,
                    BackgroundTransparency = 1,
                    Size            = UDim2.new(1, -4, 0, itemH - 4),
                    AutoButtonColor = false,
                    ZIndex          = 21,
                    Parent          = listFrame,
                })
                AddCorner(optBtn, 5)

                optBtn.MouseEnter:Connect(function() Tween(optBtn, {BackgroundTransparency = 0.7}, 0.1) end)
                optBtn.MouseLeave:Connect(function() Tween(optBtn, {BackgroundTransparency = 1}, 0.1) end)
                optBtn.MouseButton1Click:Connect(function()
                    selected      = opt
                    selLabel.Text = opt
                    open          = false
                    Tween(arrow, {Rotation = 0}, 0.15)
                    listFrame.Visible = false
                    if cfg.Callback then pcall(cfg.Callback, selected) end
                end)
            end

            dropBtn.MouseButton1Click:Connect(function()
                open = not open
                listFrame.Visible = open
                Tween(arrow, {Rotation = open and 180 or 0}, 0.15)
            end)

            local Element = {}
            function Element:Set(v)
                selected = v
                selLabel.Text = v
            end
            function Element:Get() return selected end
            return Element
        end

        -- ── Input ────────────────────────────────────────────────
        function Tab:CreateInput(cfg)
            cfg = cfg or {}
            local frame = NewItem(44)

            local lbl = Create("TextLabel", {
                Text            = cfg.Label or "Input",
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 14,
                TextColor3      = theme.TextPrimary,
                BackgroundTransparency = 1,
                Size            = UDim2.new(0.4, 0, 1, 0),
                Position        = UDim2.new(0, 14, 0, 0),
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 7,
                Parent          = frame,
            })

            local inputBox = Create("TextBox", {
                PlaceholderText = cfg.Placeholder or "",
                Text            = cfg.Default or "",
                Font            = Enum.Font.Gotham,
                TextSize        = 13,
                TextColor3      = theme.TextPrimary,
                PlaceholderColor3 = theme.TextMuted,
                BackgroundColor3 = theme.Background,
                Size            = UDim2.new(0, 180, 0, 30),
                Position        = UDim2.new(1, -194, 0.5, -15),
                ClearTextOnFocus = cfg.ClearOnFocus ~= false,
                ZIndex          = 7,
                Parent          = frame,
            })
            AddCorner(inputBox, 7)
            AddStroke(inputBox, theme.Border, 1)
            AddPadding(inputBox, 0, 0, 8, 8)

            inputBox.Focused:Connect(function()
                Tween(inputBox, {}, 0.15)
                -- stroke highlight handled by UIStroke ref
            end)

            if cfg.Callback then
                inputBox.FocusLost:Connect(function(enter)
                    if enter or cfg.FireOnChange then
                        pcall(cfg.Callback, inputBox.Text)
                    end
                end)
            end
            if cfg.FireOnChange and cfg.Callback then
                inputBox:GetPropertyChangedSignal("Text"):Connect(function()
                    pcall(cfg.Callback, inputBox.Text)
                end)
            end

            local Element = {}
            function Element:Set(v) inputBox.Text = v end
            function Element:Get() return inputBox.Text end
            return Element
        end

        -- ── Keybind ──────────────────────────────────────────────
        function Tab:CreateKeybind(cfg)
            cfg = cfg or {}
            local key      = cfg.Default or Enum.KeyCode.Unknown
            local listening = false
            local frame     = NewItem(44)

            local lbl = Create("TextLabel", {
                Text            = cfg.Label or "Keybind",
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 14,
                TextColor3      = theme.TextPrimary,
                BackgroundTransparency = 1,
                Size            = UDim2.new(1, -150, 1, 0),
                Position        = UDim2.new(0, 14, 0, 0),
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 7,
                Parent          = frame,
            })

            local keyBtn = Create("TextButton", {
                Text            = key.Name,
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 12,
                TextColor3      = theme.TextPrimary,
                BackgroundColor3 = theme.Background,
                Size            = UDim2.new(0, 100, 0, 28),
                Position        = UDim2.new(1, -114, 0.5, -14),
                ZIndex          = 7,
                Parent          = frame,
            })
            AddCorner(keyBtn, 6)
            AddStroke(keyBtn, theme.Border, 1)

            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text = "..."
                Tween(keyBtn, {BackgroundColor3 = theme.Accent}, 0.12)
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    key = input.KeyCode
                    keyBtn.Text = key.Name
                    Tween(keyBtn, {BackgroundColor3 = theme.Background}, 0.12)
                    if cfg.Callback then pcall(cfg.Callback, key) end
                elseif not gpe and not listening and input.KeyCode == key then
                    if cfg.Callback then pcall(cfg.Callback, key) end
                end
            end)

            local Element = {}
            function Element:Set(k) key = k; keyBtn.Text = k.Name end
            function Element:Get() return key end
            return Element
        end

        -- ── Color Picker ─────────────────────────────────────────
        function Tab:CreateColorPicker(cfg)
            cfg = cfg or {}
            local color = cfg.Default or Color3.fromRGB(255, 100, 50)
            local frame = NewItem(44)

            local lbl = Create("TextLabel", {
                Text            = cfg.Label or "Color",
                Font            = Enum.Font.GothamSemibold,
                TextSize        = 14,
                TextColor3      = theme.TextPrimary,
                BackgroundTransparency = 1,
                Size            = UDim2.new(1, -130, 1, 0),
                Position        = UDim2.new(0, 14, 0, 0),
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 7,
                Parent          = frame,
            })

            local preview = Create("TextButton", {
                Text            = "",
                Size            = UDim2.new(0, 40, 0, 28),
                Position        = UDim2.new(1, -54, 0.5, -14),
                BackgroundColor3 = color,
                ZIndex          = 7,
                Parent          = frame,
            })
            AddCorner(preview, 7)
            AddStroke(preview, theme.Border, 1)

            -- Hex label
            local hexLbl = Create("TextLabel", {
                Text            = "#" .. string.format("%02X%02X%02X",
                    math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)),
                Font            = Enum.Font.Code,
                TextSize        = 11,
                TextColor3      = theme.TextSecondary,
                BackgroundTransparency = 1,
                Size            = UDim2.new(0, 70, 1, 0),
                Position        = UDim2.new(1, -128, 0, 0),
                TextXAlignment  = Enum.TextXAlignment.Right,
                ZIndex          = 7,
                Parent          = frame,
            })

            -- Color picker popup (H,S,V sliders)
            local popup = Create("Frame", {
                Size            = UDim2.new(0, 220, 0, 140),
                Position        = UDim2.new(1, -224, 1, 4),
                BackgroundColor3 = theme.SurfaceAlt,
                BorderSizePixel = 0,
                Visible         = false,
                ZIndex          = 25,
                Parent          = frame,
            })
            AddCorner(popup, 10)
            AddStroke(popup, theme.Border, 1)
            AddPadding(popup, 10, 10, 12, 12)
            AddListLayout(popup, Enum.FillDirection.Vertical, 8)

            local h, s, v = color:ToHSV()

            local function UpdateColor()
                color = Color3.fromHSV(h, s, v)
                preview.BackgroundColor3 = color
                hexLbl.Text = "#" .. string.format("%02X%02X%02X",
                    math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
                if cfg.Callback then pcall(cfg.Callback, color) end
            end

            local function MakeHSVSlider(label, getVal, setVal)
                local row = Create("Frame", {
                    Size            = UDim2.new(1, 0, 0, 26),
                    BackgroundTransparency = 1,
                    ZIndex          = 26,
                    Parent          = popup,
                })
                local rowLbl = Create("TextLabel", {
                    Text            = label,
                    Font            = Enum.Font.Gotham,
                    TextSize        = 11,
                    TextColor3      = theme.TextMuted,
                    BackgroundTransparency = 1,
                    Size            = UDim2.new(0, 14, 1, 0),
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    ZIndex          = 27,
                    Parent          = row,
                })
                local track = Create("Frame", {
                    Size            = UDim2.new(1, -24, 0, 6),
                    Position        = UDim2.new(0, 20, 0.5, -3),
                    BackgroundColor3 = theme.SliderTrack,
                    ZIndex          = 27,
                    Parent          = row,
                })
                AddCorner(track, 4)
                local fill = Create("Frame", {
                    Size            = UDim2.new(getVal(), 0, 1, 0),
                    BackgroundColor3 = theme.Accent,
                    ZIndex          = 28,
                    Parent          = track,
                })
                AddCorner(fill, 4)
                local slidBtn = Create("TextButton", {
                    Size            = UDim2.fromScale(1,1),
                    BackgroundTransparency = 1,
                    Text            = "",
                    ZIndex          = 29,
                    Parent          = track,
                })
                local sliding = false
                slidBtn.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = true
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local rel = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                        setVal(rel)
                        fill.Size = UDim2.new(rel, 0, 1, 0)
                        UpdateColor()
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                end)
            end

            MakeHSVSlider("H", function() return h end, function(v) h = v end)
            MakeHSVSlider("S", function() return s end, function(val) s = val end)
            MakeHSVSlider("V", function() return v end, function(val) v = val end)

            preview.MouseButton1Click:Connect(function()
                popup.Visible = not popup.Visible
            end)

            local Element = {}
            function Element:Set(c)
                color = c
                h, s, v = c:ToHSV()
                preview.BackgroundColor3 = c
                hexLbl.Text = "#" .. string.format("%02X%02X%02X",
                    math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
            end
            function Element:Get() return color end
            return Element
        end

        -- ── Label ────────────────────────────────────────────────
        function Tab:CreateLabel(text, textColor)
            local lbl = Create("TextLabel", {
                Text            = text or "",
                Font            = Enum.Font.GothamBold,
                TextSize        = 11,
                TextColor3      = textColor or theme.TextMuted,
                BackgroundTransparency = 1,
                Size            = UDim2.new(1, -4, 0, 22),
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 6,
                Parent          = tabPage,
            })
            AddPadding(lbl, 0, 0, 14, 0)
            return lbl
        end

        -- ── Divider ──────────────────────────────────────────────
        function Tab:CreateDivider()
            local div = Create("Frame", {
                Size            = UDim2.new(1, -28, 0, 1),
                BackgroundColor3 = theme.Border,
                BorderSizePixel = 0,
                ZIndex          = 6,
                Parent          = tabPage,
            })
            Create("UIPadding", { PaddingLeft = UDim.new(0, 14), Parent = div })
            return div
        end

        -- ── Paragraph ────────────────────────────────────────────
        function Tab:CreateParagraph(cfg)
            cfg = cfg or {}
            local frame = NewItem(60)
            frame.AutomaticSize = Enum.AutomaticSize.Y

            local title = Create("TextLabel", {
                Text            = cfg.Title or "",
                Font            = Enum.Font.GothamBold,
                TextSize        = 13,
                TextColor3      = theme.TextPrimary,
                BackgroundTransparency = 1,
                Size            = UDim2.new(1, -20, 0, 20),
                Position        = UDim2.new(0, 14, 0, 8),
                TextXAlignment  = Enum.TextXAlignment.Left,
                ZIndex          = 7,
                TextWrapped     = true,
                Parent          = frame,
            })

            local body = Create("TextLabel", {
                Text            = cfg.Content or "",
                Font            = Enum.Font.Gotham,
                TextSize        = 12,
                TextColor3      = theme.TextSecondary,
                BackgroundTransparency = 1,
                Size            = UDim2.new(1, -28, 0, 0),
                Position        = UDim2.new(0, 14, 0, 28),
                TextXAlignment  = Enum.TextXAlignment.Left,
                AutomaticSize   = Enum.AutomaticSize.Y,
                TextWrapped     = true,
                ZIndex          = 7,
                Parent          = frame,
            })
        end

        -- ── Image ────────────────────────────────────────────────
        function Tab:CreateImage(assetId, height)
            local frame = NewItem(height or 120)
            local img = Create("ImageLabel", {
                Size              = UDim2.new(1, -28, 1, -16),
                Position          = UDim2.new(0, 14, 0, 8),
                BackgroundTransparency = 1,
                Image             = assetId or "",
                ScaleType         = Enum.ScaleType.Fit,
                ZIndex            = 7,
                Parent            = frame,
            })
            AddCorner(img, 6)
            return img
        end

        return Tab
    end -- CreateTab

    -- ── SetTheme ─────────────────────────────────────────────────
    function Window:Destroy()
        ScreenGui:Destroy()
    end

    table.insert(ActiveWindows, Window)
    return Window
end

-- ════════════════════════════════════════════════════════════════
--  NOTIFICATIONS
-- ════════════════════════════════════════════════════════════════

local NotifGui = Create("ScreenGui", {
    Name            = "NexusLib_Notifs",
    ResetOnSpawn    = false,
    ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    DisplayOrder    = 1000,
    Parent          = (pcall(function() return CoreGui end) and CoreGui) or LocalPlayer.PlayerGui,
})

local NotifContainer = Create("Frame", {
    Size            = UDim2.new(0, 320, 1, 0),
    Position        = UDim2.new(1, -334, 0, 0),
    BackgroundTransparency = 1,
    Parent          = NotifGui,
})
AddListLayout(NotifContainer, Enum.FillDirection.Vertical, 8,
    Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Bottom)
AddPadding(NotifContainer, 0, 16, 0, 0)

local NotifTypeColor = {
    info    = Color3.fromRGB(99,  102, 241),
    success = Color3.fromRGB(52,  211, 153),
    warning = Color3.fromRGB(251, 191, 36),
    error   = Color3.fromRGB(248, 113, 113),
}

function NexusLib:Notify(cfg)
    cfg = cfg or {}
    local notifType = cfg.Type or "info"
    local accent    = NotifTypeColor[notifType] or NotifTypeColor.info
    local duration  = cfg.Duration or 4

    local card = Create("Frame", {
        Size            = UDim2.new(1, 0, 0, 72),
        BackgroundColor3 = Color3.fromRGB(22, 22, 28),
        BackgroundTransparency = 0.1,
        ClipsDescendants = true,
        ZIndex          = 30,
        Parent          = NotifContainer,
    })
    AddCorner(card, 10)
    AddStroke(card, accent, 1)

    -- Left accent bar
    Create("Frame", {
        Size            = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        ZIndex          = 31,
        Parent          = card,
    })

    Create("TextLabel", {
        Text            = cfg.Title or "Notification",
        Font            = Enum.Font.GothamBold,
        TextSize        = 14,
        TextColor3      = Color3.fromRGB(240, 240, 250),
        BackgroundTransparency = 1,
        Size            = UDim2.new(1, -20, 0, 20),
        Position        = UDim2.new(0, 16, 0, 10),
        TextXAlignment  = Enum.TextXAlignment.Left,
        ZIndex          = 31,
        Parent          = card,
    })

    Create("TextLabel", {
        Text            = cfg.Text or "",
        Font            = Enum.Font.Gotham,
        TextSize        = 12,
        TextColor3      = Color3.fromRGB(148, 148, 170),
        BackgroundTransparency = 1,
        Size            = UDim2.new(1, -20, 0, 34),
        Position        = UDim2.new(0, 16, 0, 32),
        TextXAlignment  = Enum.TextXAlignment.Left,
        TextWrapped     = true,
        ZIndex          = 31,
        Parent          = card,
    })

    -- Progress bar
    local prog = Create("Frame", {
        Size            = UDim2.new(1, -6, 0, 2),
        Position        = UDim2.new(0, 3, 1, -4),
        BackgroundColor3 = accent,
        ZIndex          = 32,
        Parent          = card,
    })
    AddCorner(prog, 2)

    -- Slide in
    card.Position = UDim2.new(0, 40, 0, 0)
    card.BackgroundTransparency = 1
    Tween(card, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.1}, 0.3, Enum.EasingStyle.Back)

    -- Countdown
    local ti = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    TweenService:Create(prog, ti, {Size = UDim2.new(0, 0, 0, 2)}):Play()

    task.delay(duration, function()
        Tween(card, {BackgroundTransparency = 1, Position = UDim2.new(0, 40, 0, 0)}, 0.25)
        task.delay(0.3, function() card:Destroy() end)
    end)

    return card
end

-- ════════════════════════════════════════════════════════════════
--  RETURN
-- ════════════════════════════════════════════════════════════════

return NexusLib
