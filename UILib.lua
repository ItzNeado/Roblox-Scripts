-- GreyField UI Library v2
-- Roblox Luau

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

local Theme = {
    Background = Color3.fromRGB(125, 125, 125),
    Secondary = Color3.fromRGB(145, 145, 145),
    Sidebar = Color3.fromRGB(110, 110, 110),
    Accent = Color3.fromRGB(255, 120, 0),
    Text = Color3.fromRGB(255, 255, 255),
    DarkText = Color3.fromRGB(20, 20, 20)
}

local function MergeTheme(newTheme)
    if type(newTheme) ~= "table" then
        return
    end

    for k, v in pairs(newTheme) do
        if Theme[k] ~= nil then
            Theme[k] = v
        end
    end
end

local function Create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        Parent = parent,
        CornerRadius = radius or UDim.new(0, 8)
    })
end

local function AddStroke(parent, thickness, color, transparency)
    return Create("UIStroke", {
        Parent = parent,
        Thickness = thickness or 1,
        Color = color or Theme.Accent,
        Transparency = transparency or 0
    })
end

local function AddPadding(parent, px)
    return Create("UIPadding", {
        Parent = parent,
        PaddingTop = UDim.new(0, px or 8),
        PaddingBottom = UDim.new(0, px or 8),
        PaddingLeft = UDim.new(0, px or 8),
        PaddingRight = UDim.new(0, px or px or 8)
    })
end

function Library:SetTheme(newTheme)
    MergeTheme(newTheme)
end

function Library:CreateWindow(Settings)
    Settings = Settings or {}

    local Window = {}
    Window.Tabs = {}

    local GuiParent = (gethui and gethui()) or CoreGui

    local ScreenGui = Create("ScreenGui", {
        Name = "GreyField",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        Parent = GuiParent
    })

    local Main = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.fromOffset(750, 500),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    })

    AddCorner(Main, UDim.new(0, 10))
    AddStroke(Main, 5, Theme.Accent)

    local Topbar = Create("Frame", {
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })

    local Title = Create("TextLabel", {
        Parent = Topbar,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.fromOffset(10, 0),
        BackgroundTransparency = 1,
        Text = Settings.Name or "GreyField",
        Font = Enum.Font.SourceSansBold,
        TextSize = 28,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local SubTitle = Create("TextLabel", {
        Parent = Topbar,
        Size = UDim2.new(1, -20, 0, 16),
        Position = UDim2.fromOffset(10, 26),
        BackgroundTransparency = 1,
        Text = Settings.SubTitle or "",
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextTransparency = 0.2,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local Sidebar = Create("Frame", {
        Parent = Main,
        Position = UDim2.fromOffset(0, 40),
        Size = UDim2.new(0, 180, 1, -40),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0
    })

    AddCorner(Sidebar, UDim.new(0, 10))

    local TabList = Create("ScrollingFrame", {
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })

    AddPadding(TabList, 8)

    local TabLayout = Create("UIListLayout", {
        Parent = TabList,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local Content = Create("Frame", {
        Parent = Main,
        Position = UDim2.fromOffset(190, 50),
        Size = UDim2.new(1, -200, 1, -60),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    local Pages = {}

    local Dragging = false
    local DragInput
    local DragStart
    local StartPos

    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            Main.Position = UDim2.new(
                StartPos.X.Scale,
                StartPos.X.Offset + Delta.X,
                StartPos.Y.Scale,
                StartPos.Y.Offset + Delta.Y
            )
        end
    end)

    local function HideAllPages()
        for _, page in ipairs(Pages) do
            page.Visible = false
        end
    end

    local function ResetTabButtons()
        for _, child in ipairs(TabList:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Theme.Secondary
            end
        end
    end

    local function CreateElementBase(parent, height)
        local holder = Create("Frame", {
            Parent = parent,
            Size = UDim2.new(1, -10, 0, height or 44),
            BackgroundColor3 = Theme.Secondary,
            BorderSizePixel = 0
        })
        AddCorner(holder, UDim.new(0, 8))
        return holder
    end

    function Window:CreateTab(Name)
        local Tab = {}
        Tab.Sections = {}

        local Button = Create("TextButton", {
            Parent = TabList,
            Size = UDim2.new(1, 0, 0, 36),
            Text = Name,
            Font = Enum.Font.SourceSansBold,
            TextSize = 20,
            TextColor3 = Theme.Text,
            BackgroundColor3 = Theme.Secondary,
            AutoButtonColor = false,
            BorderSizePixel = 0
        })

        AddCorner(Button, UDim.new(0, 8))

        local Page = Create("ScrollingFrame", {
            Parent = Content,
            Visible = false,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ClipsDescendants = true
        })

        AddPadding(Page, 2)

        local Layout = Create("UIListLayout", {
            Parent = Page,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        local function SelectTab()
            HideAllPages()
            ResetTabButtons()
            Page.Visible = true
            Button.BackgroundColor3 = Theme.Accent
        end

        Button.MouseButton1Click:Connect(SelectTab)

        table.insert(Pages, Page)
        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            SelectTab()
        end

        function Tab:CreateSection(TitleText)
            local Section = {}
            Section.Elements = {}

            local Holder = CreateElementBase(Page, 150)
            Holder.AutomaticSize = Enum.AutomaticSize.Y

            local Header = Create("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -10, 0, 30),
                Position = UDim2.fromOffset(5, 2),
                BackgroundTransparency = 1,
                Text = TitleText,
                Font = Enum.Font.SourceSansBold,
                TextSize = 22,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Container = Create("Frame", {
                Parent = Holder,
                Position = UDim2.fromOffset(5, 35),
                Size = UDim2.new(1, -10, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0
            })

            local ElementsLayout = Create("UIListLayout", {
                Parent = Container,
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            AddPadding(Container, 0)

            local function RefreshHolder()
                task.defer(function()
                    Holder.Size = UDim2.new(1, -10, 0, Container.AbsoluteSize.Y + 45)
                end)
            end

            function Section:CreateButton(ButtonText, Callback)
                local Holder2 = CreateElementBase(Container, 40)

                local Btn = Create("TextButton", {
                    Parent = Holder2,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = ButtonText,
                    Font = Enum.Font.SourceSansBold,
                    TextSize = 20,
                    TextColor3 = Theme.Text,
                    AutoButtonColor = false,
                    BorderSizePixel = 0
                })

                Btn.MouseButton1Click:Connect(function()
                    if Callback then
                        task.spawn(Callback)
                    end
                end)

                RefreshHolder()
                return Btn
            end

            function Section:CreateToggle(ToggleText, Default, Callback)
                local Value = Default or false
                local Holder2 = CreateElementBase(Container, 40)

                local Label = Create("TextLabel", {
                    Parent = Holder2,
                    Size = UDim2.new(1, -60, 1, 0),
                    Position = UDim2.fromOffset(10, 0),
                    BackgroundTransparency = 1,
                    Text = ToggleText,
                    Font = Enum.Font.SourceSansBold,
                    TextSize = 20,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Button = Create("TextButton", {
                    Parent = Holder2,
                    Size = UDim2.fromOffset(36, 24),
                    Position = UDim2.new(1, -46, 0.5, -12),
                    BackgroundColor3 = Value and Theme.Accent or Theme.Background,
                    Text = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0
                })

                AddCorner(Button, UDim.new(1, 0))
                AddStroke(Button, 1, Theme.Text, 0.7)

                local Dot = Create("Frame", {
                    Parent = Button,
                    Size = UDim2.fromOffset(18, 18),
                    Position = Value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0
                })
                AddCorner(Dot, UDim.new(1, 0))

                local function SetState(newState)
                    Value = newState
                    TweenService:Create(Button, TweenInfo.new(0.15), {
                        BackgroundColor3 = Value and Theme.Accent or Theme.Background
                    }):Play()

                    TweenService:Create(Dot, TweenInfo.new(0.15), {
                        Position = Value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                    }):Play()

                    if Callback then
                        task.spawn(Callback, Value)
                    end
                end

                Button.MouseButton1Click:Connect(function()
                    SetState(not Value)
                end)

                RefreshHolder()
                return {
                    Set = SetState,
                    Get = function()
                        return Value
                    end
                }
            end

            function Section:CreateTextbox(Text, Placeholder, Callback)
                local Holder2 = CreateElementBase(Container, 48)

                local Label = Create("TextLabel", {
                    Parent = Holder2,
                    Size = UDim2.new(1, -20, 0, 18),
                    Position = UDim2.fromOffset(10, 4),
                    BackgroundTransparency = 1,
                    Text = Text,
                    Font = Enum.Font.SourceSansBold,
                    TextSize = 18,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Box = Create("TextBox", {
                    Parent = Holder2,
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.fromOffset(10, 24),
                    BackgroundColor3 = Theme.Background,
                    Text = "",
                    PlaceholderText = Placeholder or "",
                    Font = Enum.Font.SourceSans,
                    TextSize = 18,
                    TextColor3 = Theme.Text,
                    ClearTextOnFocus = false,
                    BorderSizePixel = 0
                })
                AddCorner(Box, UDim.new(0, 6))
                AddStroke(Box, 1, Theme.Text, 0.75)

                Box.FocusLost:Connect(function(enterPressed)
                    if enterPressed and Callback then
                        task.spawn(Callback, Box.Text)
                    end
                end)

                RefreshHolder()
                return Box
            end

            function Section:CreateSlider(Text, Min, Max, Default, Callback)
                local Value = Default or Min or 0
                local MinV = Min or 0
                local MaxV = Max or 100

                local Holder2 = CreateElementBase(Container, 60)

                local Label = Create("TextLabel", {
                    Parent = Holder2,
                    Size = UDim2.new(1, -20, 0, 18),
                    Position = UDim2.fromOffset(10, 4),
                    BackgroundTransparency = 1,
                    Text = Text .. " : " .. tostring(Value),
                    Font = Enum.Font.SourceSansBold,
                    TextSize = 18,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Bar = Create("Frame", {
                    Parent = Holder2,
                    Size = UDim2.new(1, -20, 0, 14),
                    Position = UDim2.fromOffset(10, 30),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0
                })
                AddCorner(Bar, UDim.new(1, 0))
                AddStroke(Bar, 1, Theme.Text, 0.8)

                local Fill = Create("Frame", {
                    Parent = Bar,
                    Size = UDim2.new((Value - MinV) / math.max(MaxV - MinV, 1), 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0
                })
                AddCorner(Fill, UDim.new(1, 0))

                local Drag = false

                local function SetValue(v)
                    Value = math.clamp(v, MinV, MaxV)
                    local alpha = (Value - MinV) / math.max(MaxV - MinV, 1)
                    Fill.Size = UDim2.new(alpha, 0, 1, 0)
                    Label.Text = Text .. " : " .. tostring(math.floor(Value * 100) / 100)

                    if Callback then
                        task.spawn(Callback, Value)
                    end
                end

                local function UpdateFromMouse(x)
                    local pos = (x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
                    SetValue(MinV + (MaxV - MinV) * math.clamp(pos, 0, 1))
                end

                Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Drag = true
                        UpdateFromMouse(input.Position.X)
                    end
                end)

                Bar.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Drag = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if Drag and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateFromMouse(input.Position.X)
                    end
                end)

                SetValue(Value)
                RefreshHolder()

                return {
                    Set = SetValue,
                    Get = function()
                        return Value
                    end
                }
            end

            function Section:CreateDropdown(Text, Options, Default, Callback)
                local Value = Default or (Options and Options[1]) or "None"
                local Expanded = false
                local Holder2 = CreateElementBase(Container, 46)

                local Top = Create("TextButton", {
                    Parent = Holder2,
                    Size = UDim2.new(1, 0, 0, 46),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0
                })

                local Label = Create("TextLabel", {
                    Parent = Holder2,
                    Size = UDim2.new(1, -20, 0, 18),
                    Position = UDim2.fromOffset(10, 4),
                    BackgroundTransparency = 1,
                    Text = Text,
                    Font = Enum.Font.SourceSansBold,
                    TextSize = 18,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ValueLabel = Create("TextLabel", {
                    Parent = Holder2,
                    Size = UDim2.new(1, -20, 0, 18),
                    Position = UDim2.fromOffset(10, 22),
                    BackgroundTransparency = 1,
                    Text = Value,
                    Font = Enum.Font.SourceSans,
                    TextSize = 18,
                    TextColor3 = Theme.Text,
                    TextTransparency = 0.15,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ListHolder = Create("Frame", {
                    Parent = Holder2,
                    Position = UDim2.fromOffset(0, 46),
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ClipsDescendants = true
                })

                local ListLayout = Create("UIListLayout", {
                    Parent = ListHolder,
                    Padding = UDim.new(0, 4)
                })

                local function ClearOptions()
                    for _, child in ipairs(ListHolder:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                end

                local function SetValue(v)
                    Value = v
                    ValueLabel.Text = tostring(v)
                    if Callback then
                        task.spawn(Callback, v)
                    end
                end

                local function ToggleExpand()
                    Expanded = not Expanded
                    if Expanded then
                        ClearOptions()
                        for _, option in ipairs(Options or {}) do
                            local Opt = Create("TextButton", {
                                Parent = ListHolder,
                                Size = UDim2.new(1, -20, 0, 32),
                                Position = UDim2.fromOffset(10, 0),
                                BackgroundColor3 = Theme.Background,
                                Text = tostring(option),
                                Font = Enum.Font.SourceSans,
                                TextSize = 18,
                                TextColor3 = Theme.Text,
                                AutoButtonColor = false,
                                BorderSizePixel = 0
                            })
                            AddCorner(Opt, UDim.new(0, 6))

                            Opt.MouseButton1Click:Connect(function()
                                SetValue(option)
                                ToggleExpand()
                            end)
                        end

                        Holder2.Size = UDim2.new(1, -10, 0, 46 + ((#(Options or {})) * 36))
                        ListHolder.Size = UDim2.new(1, 0, 0, (#(Options or {})) * 36)
                    else
                        ClearOptions()
                        Holder2.Size = UDim2.new(1, -10, 0, 46)
                        ListHolder.Size = UDim2.new(1, 0, 0, 0)
                    end
                end

                Top.MouseButton1Click:Connect(ToggleExpand)

                SetValue(Value)
                RefreshHolder()

                return {
                    Set = SetValue,
                    Get = function()
                        return Value
                    end
                }
            end

            table.insert(Tab.Sections, Section)
            RefreshHolder()
            return Section
        end

        return Tab
    end

    function Window:SetVisible(state)
        ScreenGui.Enabled = state
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

return Library
