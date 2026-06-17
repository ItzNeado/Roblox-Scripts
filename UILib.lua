-- GreyField UI Library (Core v1)

local TweenService = game("TweenService")
local UserInputService = game("UserInputService")

local Library = {}
Library.__index = Library

local Theme = {
Background = Color3.fromRGB(125,125,125),
Secondary = Color3.fromRGB(145,145,145),
Sidebar = Color3.fromRGB(110,110,110),
Accent = Color3.fromRGB(255,120,0),
Text = Color3.fromRGB(255,255,255),
DarkText = Color3.fromRGB(20,20,20)
}

local function Create(class, props)
local obj = Instance.new(class)

for i,v in pairs(props or {}) do
    obj[i] = v
end

return obj

end

function Library(newTheme)
for i,v in pairs(newTheme) do
Theme[i] = v
end
end

function Library(Settings)

Settings = Settings or {}

local Window = {}
Window.Tabs = {}

local GuiParent = gethui and gethui() or game:GetService("CoreGui")

local ScreenGui = Create("ScreenGui", {
    Name = "GreyField",
    ResetOnSpawn = false,
    Parent = GuiParent
})

local Main = Create("Frame", {
    Parent = ScreenGui,
    Size = UDim2.fromOffset(750, 500),
    Position = UDim2.fromScale(.5,.5),
    AnchorPoint = Vector2.new(.5,.5),
    BackgroundColor3 = Theme.Background
})

Create("UICorner", {
    CornerRadius = UDim.new(0,8),
    Parent = Main
})

Create("UIStroke", {
    Thickness = 5,
    Color = Theme.Accent,
    Parent = Main
})

local Topbar = Create("Frame", {
    Parent = Main,
    Size = UDim2.new(1,0,0,40),
    BackgroundTransparency = 1
})

local Title = Create("TextLabel", {
    Parent = Topbar,
    Size = UDim2.new(1,0,1,0),
    BackgroundTransparency = 1,
    Text = Settings.Name or "GreyField",
    Font = Enum.Font.SourceSansBold,
    TextSize = 28,
    TextColor3 = Theme.Text
})

local Sidebar = Create("Frame", {
    Parent = Main,
    Position = UDim2.fromOffset(0,40),
    Size = UDim2.new(0,180,1,-40),
    BackgroundColor3 = Theme.Sidebar
})

Create("UICorner", {
    Parent = Sidebar
})

local TabList = Create("ScrollingFrame", {
    Parent = Sidebar,
    Size = UDim2.new(1,0,1,0),
    CanvasSize = UDim2.new(),
    ScrollBarThickness = 0,
    BackgroundTransparency = 1
})

local TabLayout = Create("UIListLayout", {
    Parent = TabList,
    Padding = UDim.new(0,4)
})

local Content = Create("Frame", {
    Parent = Main,
    Position = UDim2.fromOffset(190,50),
    Size = UDim2.new(1,-200,1,-60),
    BackgroundTransparency = 1
})

-- Dragging

local Dragging = false
local DragInput
local DragStart
local StartPos

Topbar.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = Input.Position
        StartPos = Main.Position

        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

Topbar.InputChanged:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseMovement then
        DragInput = Input
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if Input == DragInput and Dragging then
        local Delta = Input.Position - DragStart

        Main.Position = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + Delta.Y
        )
    end
end)

function Window:CreateTab(Name)

    local Tab = {}
    Tab.Sections = {}

    local Button = Create("TextButton", {
        Parent = TabList,
        Size = UDim2.new(1,-8,0,35),
        Text = Name,
        Font = Enum.Font.SourceSansBold,
        TextSize = 20,
        TextColor3 = Theme.Text,
        BackgroundColor3 = Theme.Secondary,
        AutoButtonColor = false
    })

    Create("UICorner", {
        Parent = Button
    })

    local Page = Create("ScrollingFrame", {
        Parent = Content,
        Visible = false,
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new()
    })

    local Layout = Create("UIListLayout", {
        Parent = Page,
        Padding = UDim.new(0,10)
    })

    local function SelectTab()

        for _,v in pairs(Content:GetChildren()) do
            if v:IsA("ScrollingFrame") then
                v.Visible = false
            end
        end

        for _,v in pairs(TabList:GetChildren()) do
            if v:IsA("TextButton") then
                v.BackgroundColor3 = Theme.Secondary
            end
        end

        Page.Visible = true
        Button.BackgroundColor3 = Theme.Accent
    end

    Button.MouseButton1Click:Connect(SelectTab)

    if #Window.Tabs == 0 then
        SelectTab()
    end

    function Tab:CreateSection(TitleText)

        local Section = {}

        local Holder = Create("Frame", {
            Parent = Page,
            Size = UDim2.new(1,-10,0,150),
            BackgroundColor3 = Theme.Secondary
        })

        Create("UICorner", {
            Parent = Holder
        })

        local Stroke = Create("UIStroke", {
            Parent = Holder,
            Thickness = 2,
            Color = Theme.Accent
        })

        local Header = Create("TextLabel", {
            Parent = Holder,
            Size = UDim2.new(1,0,0,30),
            BackgroundTransparency = 1,
            Text = TitleText,
            Font = Enum.Font.SourceSansBold,
            TextSize = 22,
            TextColor3 = Theme.Text
        })

        local Container = Create("Frame", {
            Parent = Holder,
            Position = UDim2.fromOffset(5,35),
            Size = UDim2.new(1,-10,1,-40),
            BackgroundTransparency = 1
        })

        local Elements = Create("UIListLayout", {
            Parent = Container,
            Padding = UDim.new(0,4)
        })

        Section.Container = Container

        return Section
    end

    table.insert(Window.Tabs, Tab)

    return Tab
end

return Window

end

return Library
