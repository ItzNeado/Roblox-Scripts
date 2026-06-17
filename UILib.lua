-- GreyField UI Library v3
-- Redesigned visual style: darker premium look, soft shadows, cleaner spacing
-- Roblox Luau

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

local Theme = {
	Background = Color3.fromRGB(24, 24, 28),
	Background2 = Color3.fromRGB(31, 31, 36),
	Sidebar = Color3.fromRGB(28, 28, 33),
	Surface = Color3.fromRGB(38, 38, 45),
	SurfaceHover = Color3.fromRGB(45, 45, 53),
	Stroke = Color3.fromRGB(70, 70, 82),
	Accent = Color3.fromRGB(255, 120, 40),
	AccentSoft = Color3.fromRGB(255, 120, 40),
	Text = Color3.fromRGB(245, 245, 248),
	MutedText = Color3.fromRGB(170, 170, 178),
	Shadow = Color3.fromRGB(0, 0, 0)
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

local function Corner(parent, radius)
	return Create("UICorner", {
		Parent = parent,
		CornerRadius = radius or UDim.new(0, 12)
	})
end

local function Stroke(parent, thickness, color, transparency)
	return Create("UIStroke", {
		Parent = parent,
		Thickness = thickness or 1,
		Color = color or Theme.Stroke,
		Transparency = transparency or 0
	})
end

local function Padding(parent, px)
	return Create("UIPadding", {
		Parent = parent,
		PaddingTop = UDim.new(0, px or 10),
		PaddingBottom = UDim.new(0, px or 10),
		PaddingLeft = UDim.new(0, px or 10),
		PaddingRight = UDim.new(0, px or 10)
	})
end

local function Tween(obj, info, goal)
	local ok, t = pcall(function()
		return TweenService:Create(obj, info or TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
	end)
	if ok and t then t:Play() end
end

function Library:SetTheme(newTheme)
	MergeTheme(newTheme)
end

function Library:CreateWindow(settings)
	settings = settings or {}

	local Window = {}
	Window.Tabs = {}
	Window._pages = {}
	Window._tabButtons = {}

	local GuiParent = (gethui and gethui()) or CoreGui

	local ScreenGui = Create("ScreenGui", {
		Name = "GreyField",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = GuiParent
	})

	local ShadowFrame = Create("Frame", {
		Parent = ScreenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(770, 520),
		BackgroundColor3 = Theme.Shadow,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0
	})
	Corner(ShadowFrame, UDim.new(0, 18))

	local Main = Create("Frame", {
		Parent = ShadowFrame,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(760, 510),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true
	})
	Corner(Main, UDim.new(0, 18))
	Stroke(Main, 1, Theme.Stroke, 0.25)

	local Topbar = Create("Frame", {
		Parent = Main,
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundColor3 = Theme.Background2,
		BorderSizePixel = 0
	})

	local TopAccent = Create("Frame", {
		Parent = Topbar,
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0
	})

	local Title = Create("TextLabel", {
		Parent = Topbar,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 10),
		Size = UDim2.new(1, -36, 0, 24),
		Text = settings.Name or "GreyField",
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local Subtitle = Create("TextLabel", {
		Parent = Topbar,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 34),
		Size = UDim2.new(1, -36, 0, 18),
		Text = settings.SubTitle or "",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Theme.MutedText,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local Sidebar = Create("Frame", {
		Parent = Main,
		Position = UDim2.fromOffset(14, 76),
		Size = UDim2.fromOffset(190, 420),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0
	})
	Corner(Sidebar, UDim.new(0, 16))
	Stroke(Sidebar, 1, Theme.Stroke, 0.45)

	local SideInner = Create("Frame", {
		Parent = Sidebar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0)
	})
	Padding(SideInner, 10)

	local TabList = Create("ScrollingFrame", {
		Parent = SideInner,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.Y
	})

	local TabLayout = Create("UIListLayout", {
		Parent = TabList,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local Content = Create("Frame", {
		Parent = Main,
		Position = UDim2.fromOffset(220, 76),
		Size = UDim2.fromOffset(526, 420),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true
	})

	local Pages = {}
	local ActivePage

	local function HideAllPages()
		for _, page in ipairs(Pages) do
			page.Visible = false
		end
	end

	local function ResetTabButtons()
		for _, btn in ipairs(Window._tabButtons) do
			Tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Surface})
			local label = btn:FindFirstChild("Title")
			if label then
				Tween(label, TweenInfo.new(0.15), {TextColor3 = Theme.Text})
			end
		end
	end

	local function SetActiveTab(page, button)
		HideAllPages()
		ResetTabButtons()
		page.Visible = true
		ActivePage = page
		Tween(button, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent})
		local label = button:FindFirstChild("Title")
		if label then
			Tween(label, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(20, 20, 20)})
		end
	end

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

	function Window:CreateTab(name)
		local Tab = {}
		Tab.Sections = {}

		local Button = Create("TextButton", {
			Parent = TabList,
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = Theme.Surface,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			ClipsDescendants = true
		})
		Corner(Button, UDim.new(0, 12))
		Stroke(Button, 1, Theme.Stroke, 0.55)

		local AccentBar = Create("Frame", {
			Parent = Button,
			Size = UDim2.new(0, 4, 1, 0),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			BackgroundTransparency = 1
		})

		local TextLabel = Create("TextLabel", {
			Parent = Button,
			Name = "Title",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -18, 1, 0),
			Text = name,
			Font = Enum.Font.GothamSemibold,
			TextSize = 18,
			TextColor3 = Theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left
		})

		local Page = Create("ScrollingFrame", {
			Parent = Content,
			Visible = false,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(),
			ScrollingDirection = Enum.ScrollingDirection.Y
		})
		Padding(Page, 2)

		local PageLayout = Create("UIListLayout", {
			Parent = Page,
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		local function SelectTab()
			SetActiveTab(Page, Button)
			Tween(AccentBar, TweenInfo.new(0.2), {BackgroundTransparency = 0})
		end

		Button.MouseEnter:Connect(function()
			if ActivePage ~= Page then
				Tween(Button, TweenInfo.new(0.12), {BackgroundColor3 = Theme.SurfaceHover})
			end
		end)

		Button.MouseLeave:Connect(function()
			if ActivePage ~= Page then
				Tween(Button, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Surface})
			end
		end)

		Button.MouseButton1Click:Connect(SelectTab)

		table.insert(Window._pages, Page)
		table.insert(Window._tabButtons, Button)
		table.insert(Pages, Page)
		table.insert(Window.Tabs, Tab)

		if #Window.Tabs == 1 then
			SelectTab()
		end

		local function SectionBase(parent, titleText)
			local Holder = Create("Frame", {
				Parent = parent,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Theme.Background2,
				BorderSizePixel = 0
			})
			Corner(Holder, UDim.new(0, 16))
			Stroke(Holder, 1, Theme.Stroke, 0.45)
			Padding(Holder, 12)

			local Header = Create("TextLabel", {
				Parent = Holder,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 24),
				Text = titleText,
				Font = Enum.Font.GothamSemibold,
				TextSize = 19,
				TextColor3 = Theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left
			})

			local Line = Create("Frame", {
				Parent = Holder,
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = Theme.Stroke,
				BackgroundTransparency = 0.55,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 30)
			})

			local Container = Create("Frame", {
				Parent = Holder,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 42),
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y
			})

			local Layout = Create("UIListLayout", {
				Parent = Container,
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder
			})

			local function Row(height)
				local r = Create("Frame", {
					Parent = Container,
					Size = UDim2.new(1, 0, 0, height or 44),
					BackgroundColor3 = Theme.Surface,
					BorderSizePixel = 0
				})
				Corner(r, UDim.new(0, 12))
				Stroke(r, 1, Theme.Stroke, 0.6)
				return r
			end

			local Section = {}

			function Section:CreateButton(buttonText, callback)
				local Holder2 = Row(44)
				local Btn = Create("TextButton", {
					Parent = Holder2,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = buttonText,
					Font = Enum.Font.GothamSemibold,
					TextSize = 18,
					TextColor3 = Theme.Text,
					AutoButtonColor = false,
					BorderSizePixel = 0
				})
				Btn.MouseEnter:Connect(function()
					Tween(Holder2, TweenInfo.new(0.12), {BackgroundColor3 = Theme.SurfaceHover})
				end)
				Btn.MouseLeave:Connect(function()
					Tween(Holder2, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Surface})
				end)
				Btn.MouseButton1Click:Connect(function()
					if callback then task.spawn(callback) end
				end)
				return Btn
			end

			function Section:CreateToggle(toggleText, default, callback)
				local state = default and true or false
				local Holder2 = Row(46)

				local Label = Create("TextLabel", {
					Parent = Holder2,
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(14, 0),
					Size = UDim2.new(1, -80, 1, 0),
					Text = toggleText,
					Font = Enum.Font.GothamSemibold,
					TextSize = 18,
					TextColor3 = Theme.Text,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local Btn = Create("TextButton", {
					Parent = Holder2,
					Size = UDim2.fromOffset(46, 24),
					Position = UDim2.new(1, -58, 0.5, -12),
					BackgroundColor3 = state and Theme.Accent or Theme.Background,
					Text = "",
					AutoButtonColor = false,
					BorderSizePixel = 0
				})
				Corner(Btn, UDim.new(1, 0))
				Stroke(Btn, 1, Theme.Stroke, 0.55)

				local Knob = Create("Frame", {
					Parent = Btn,
					Size = UDim2.fromOffset(18, 18),
					Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
					BackgroundColor3 = Theme.Text,
					BorderSizePixel = 0
				})
				Corner(Knob, UDim.new(1, 0))

				local function Set(v)
					state = v and true or false
					Tween(Btn, TweenInfo.new(0.15), {BackgroundColor3 = state and Theme.Accent or Theme.Background})
					Tween(Knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)})
					if callback then task.spawn(callback, state) end
				end

				Btn.MouseButton1Click:Connect(function()
					Set(not state)
				end)

				return { Set = Set, Get = function() return state end }
			end

			function Section:CreateTextbox(labelText, placeholder, callback)
				local Holder2 = Row(56)
				local Label = Create("TextLabel", {
					Parent = Holder2,
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(14, 6),
					Size = UDim2.new(1, -28, 0, 18),
					Text = labelText,
					Font = Enum.Font.GothamSemibold,
					TextSize = 16,
					TextColor3 = Theme.Text,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local Box = Create("TextBox", {
					Parent = Holder2,
					BackgroundColor3 = Theme.Background,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(14, 28),
					Size = UDim2.new(1, -28, 0, 22),
					Text = "",
					PlaceholderText = placeholder or "",
					Font = Enum.Font.Gotham,
					TextSize = 16,
					TextColor3 = Theme.Text,
					ClearTextOnFocus = false
				})
				Corner(Box, UDim.new(0, 8))
				Stroke(Box, 1, Theme.Stroke, 0.65)

				Box.FocusLost:Connect(function(enterPressed)
					if enterPressed and callback then
						task.spawn(callback, Box.Text)
					end
				end)

				return Box
			end

			function Section:CreateSlider(text, min, max, default, callback)
				local minV = min or 0
				local maxV = max or 100
				local value = default or minV

				local Holder2 = Row(66)
				local Label = Create("TextLabel", {
					Parent = Holder2,
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(14, 6),
					Size = UDim2.new(1, -28, 0, 18),
					Text = text .. " : " .. tostring(value),
					Font = Enum.Font.GothamSemibold,
					TextSize = 16,
					TextColor3 = Theme.Text,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local Bar = Create("Frame", {
					Parent = Holder2,
					BackgroundColor3 = Theme.Background,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(14, 34),
					Size = UDim2.new(1, -28, 0, 14)
				})
				Corner(Bar, UDim.new(1, 0))
				Stroke(Bar, 1, Theme.Stroke, 0.65)

				local Fill = Create("Frame", {
					Parent = Bar,
					BackgroundColor3 = Theme.Accent,
					BorderSizePixel = 0,
					Size = UDim2.new((value - minV) / math.max(maxV - minV, 1), 0, 1, 0)
				})
				Corner(Fill, UDim.new(1, 0))

				local dragging = false

				local function Set(v)
					value = math.clamp(v, minV, maxV)
					local alpha = (value - minV) / math.max(maxV - minV, 1)
					Fill.Size = UDim2.new(alpha, 0, 1, 0)
					Label.Text = text .. " : " .. tostring(math.floor(value * 100) / 100)
					if callback then task.spawn(callback, value) end
				end

				local function UpdateFromX(x)
					local alpha = (x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
					Set(minV + (maxV - minV) * math.clamp(alpha, 0, 1))
				end

				Bar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						UpdateFromX(input.Position.X)
					end
				end)

				Bar.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						UpdateFromX(input.Position.X)
					end
				end)

				Set(value)
				return { Set = Set, Get = function() return value end }
			end

			function Section:CreateDropdown(text, options, default, callback)
				local current = default or (options and options[1]) or "None"
				local expanded = false
				local Holder2 = Create("Frame", {
					Parent = Container,
					Size = UDim2.new(1, 0, 0, 46),
					BackgroundColor3 = Theme.Surface,
					BorderSizePixel = 0,
					ClipsDescendants = true
				})
				Corner(Holder2, UDim.new(0, 12))
				Stroke(Holder2, 1, Theme.Stroke, 0.6)

				local HeaderBtn = Create("TextButton", {
					Parent = Holder2,
					Size = UDim2.new(1, 0, 0, 46),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false,
					BorderSizePixel = 0
				})

				local Label = Create("TextLabel", {
					Parent = Holder2,
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(14, 6),
					Size = UDim2.new(1, -36, 0, 18),
					Text = text,
					Font = Enum.Font.GothamSemibold,
					TextSize = 16,
					TextColor3 = Theme.Text,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local ValueLabel = Create("TextLabel", {
					Parent = Holder2,
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(14, 24),
					Size = UDim2.new(1, -36, 0, 16),
					Text = tostring(current),
					Font = Enum.Font.Gotham,
					TextSize = 14,
					TextColor3 = Theme.MutedText,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local Arrow = Create("TextLabel", {
					Parent = Holder2,
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -24, 0, 12),
					Size = UDim2.fromOffset(12, 12),
					Text = ">",
					Rotation = 90,
					Font = Enum.Font.GothamBold,
					TextSize = 18,
					TextColor3 = Theme.MutedText
				})

				local ListHolder = Create("Frame", {
					Parent = Holder2,
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(0, 46),
					Size = UDim2.new(1, 0, 0, 0),
					ClipsDescendants = true
				})

				local ListLayout = Create("UIListLayout", {
					Parent = ListHolder,
					Padding = UDim.new(0, 6),
					SortOrder = Enum.SortOrder.LayoutOrder
				})

				local function ClearOptions()
					for _, child in ipairs(ListHolder:GetChildren()) do
						if child:IsA("TextButton") then
							child:Destroy()
						end
					end
				end

				local function Set(v)
					current = v
					ValueLabel.Text = tostring(current)
					if callback then task.spawn(callback, current) end
				end

				local function Toggle()
					expanded = not expanded
					if expanded then
						ClearOptions()
						for _, option in ipairs(options or {}) do
							local Opt = Create("TextButton", {
								Parent = ListHolder,
								Size = UDim2.new(1, -28, 0, 34),
								Position = UDim2.fromOffset(14, 0),
								BackgroundColor3 = Theme.Background,
								Text = tostring(option),
								Font = Enum.Font.Gotham,
								TextSize = 15,
								TextColor3 = Theme.Text,
								AutoButtonColor = false,
								BorderSizePixel = 0
							})
							Corner(Opt, UDim.new(0, 10))
							Stroke(Opt, 1, Theme.Stroke, 0.7)
							Opt.MouseEnter:Connect(function()
								Tween(Opt, TweenInfo.new(0.12), {BackgroundColor3 = Theme.SurfaceHover})
							end)
							Opt.MouseLeave:Connect(function()
								Tween(Opt, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Background})
							end)
							Opt.MouseButton1Click:Connect(function()
								Set(option)
								Toggle()
							end)
						end
						local count = #((options or {}))
						Holder2.Size = UDim2.new(1, 0, 0, 46 + (count * 40))
						ListHolder.Size = UDim2.new(1, 0, 0, count * 40)
						Tween(Arrow, TweenInfo.new(0.12), {Rotation = 270})
					else
						ClearOptions()
						Holder2.Size = UDim2.new(1, 0, 0, 46)
						ListHolder.Size = UDim2.new(1, 0, 0, 0)
						Tween(Arrow, TweenInfo.new(0.12), {Rotation = 90})
					end
				end

				HeaderBtn.MouseButton1Click:Connect(Toggle)
				Set(current)

				return { Set = Set, Get = function() return current end }
			end

			return Section
		end

		function Tab:CreateSection(titleText)
			local Section = SectionBase(Page, titleText)
			table.insert(Tab.Sections, Section)
			return Section
		end

		return Tab
	end

	function Window:SetVisible(state)
		ScreenGui.Enabled = state and true or false
	end

	function Window:Destroy()
		ScreenGui:Destroy()
	end

	return Window
end

return Library
