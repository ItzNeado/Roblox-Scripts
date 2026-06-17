-- Roblox UI Library
-- Dark modern theme inspired by the provided reference, with a cleaner and more flexible API.
-- Usage:
-- local UI = require(path.To.Module)
-- local Window = UI:CreateWindow({Title = "My Library", Subtitle = "Demo", Accent = Color3.fromRGB(255,120,40)})
-- local Tab = Window:AddTab("Main")
-- local Section = Tab:AddSection("Controls")
-- Section:AddButton("Test", function() print("Clicked") end)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local Library = {}
Library.__index = Library

Library.Theme = {
	BG = Color3.fromRGB(22, 22, 27),
	Panel = Color3.fromRGB(30, 30, 36),
	Panel2 = Color3.fromRGB(36, 36, 43),
	Stroke = Color3.fromRGB(88, 88, 102),
	Text = Color3.fromRGB(245, 245, 245),
	SubText = Color3.fromRGB(190, 190, 200),
	Muted = Color3.fromRGB(150, 150, 165),
	Accent = Color3.fromRGB(255, 120, 40),
	AccentHover = Color3.fromRGB(255, 140, 65),
	AccentDark = Color3.fromRGB(205, 92, 26),
	Success = Color3.fromRGB(80, 210, 120),
	Danger = Color3.fromRGB(235, 88, 88),
}

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
		CornerRadius = radius or UDim.new(0, 12),
	})
end

local function Stroke(parent, thickness, color, transparency)
	return Create("UIStroke", {
		Parent = parent,
		Thickness = thickness or 1,
		Color = color or Library.Theme.Stroke,
		Transparency = transparency or 0.35,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function Padding(parent, l, r, t, b)
	return Create("UIPadding", {
		Parent = parent,
		PaddingLeft = UDim.new(0, l or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingTop = UDim.new(0, t or 0),
		PaddingBottom = UDim.new(0, b or 0),
	})
end

local function Label(parent, text, size, bold, alpha, align)
	return Create("TextLabel", {
		Parent = parent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = text or "",
		Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextSize = size or 16,
		TextColor3 = Library.Theme.Text,
		TextTransparency = alpha or 0,
		TextXAlignment = align or Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		RichText = true,
	})
end

local function ButtonFx(button, accent)
	button.MouseEnter:Connect(function()
		if button.BackgroundColor3 == accent then
			TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = Library.Theme.AccentHover}):Play()
		else
			TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(44, 44, 52)}):Play()
		end
	end)
	button.MouseLeave:Connect(function()
		if button:GetAttribute("Selected") then
			TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = accent}):Play()
		else
			TweenService:Create(button, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(39, 39, 46)}):Play()
		end
	end)
end

local function MakeScrollable(parent)
	local scroll = Create("ScrollingFrame", {
		Parent = parent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Library.Theme.Accent,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
	})
	Create("UIListLayout", {
		Parent = scroll,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	return scroll
end

local function getRootGui()
	local ok, gui = pcall(function()
		if gethui then
			return gethui()
		end
		return game:GetService("CoreGui")
	end)
	if ok and gui then
		return gui
	end
	return game:GetService("CoreGui")
end

function Library:CreateWindow(opts)
	opts = opts or {}

	local self = setmetatable({}, Library)
	self.Options = opts
	self.Accent = opts.Accent or Library.Theme.Accent
	self.Tabs = {}
	self.CurrentTab = nil
	self.Alive = true

	local guiParent = getRootGui()

	local existing = guiParent:FindFirstChild(opts.Name or "RBXUILibrary")
	if existing then
		existing:Destroy()
	end

	local screen = Create("ScreenGui", {
		Name = opts.Name or "RBXUILibrary",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		Parent = guiParent,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	self.ScreenGui = screen

	local shadow = Create("Frame", {
		Parent = screen,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(920, 600),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.65,
		BorderSizePixel = 0,
	})
	Corner(shadow, UDim.new(0, 20))

	local main = Create("Frame", {
		Parent = shadow,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(910, 590),
		BackgroundColor3 = Library.Theme.BG,
		BorderSizePixel = 0,
	})
	Corner(main, UDim.new(0, 20))
	Stroke(main, 1, Library.Theme.Stroke, 0.3)

	local titleBar = Create("Frame", {
		Parent = main,
		Size = UDim2.new(1, 0, 0, 66),
		BackgroundColor3 = Library.Theme.Panel,
		BorderSizePixel = 0,
	})
	Corner(titleBar, UDim.new(0, 20))

	local accentBar = Create("Frame", {
		Parent = titleBar,
		Position = UDim2.new(0, 0, 1, -2),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = self.Accent,
		BorderSizePixel = 0,
	})

	local title = Label(titleBar, opts.Title or "UI Library", 24, true)
	title.Position = UDim2.fromOffset(18, 10)
	title.Size = UDim2.new(1, -36, 0, 24)

	local subtitle = Label(titleBar, opts.Subtitle or "Modern Roblox interface", 13, false, 0.35)
	subtitle.Position = UDim2.fromOffset(18, 35)
	subtitle.Size = UDim2.new(1, -36, 0, 16)

	local dragHandle = Create("TextButton", {
		Parent = titleBar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		AutoButtonColor = false,
		ZIndex = 1,
	})

	local dragging = false
	local dragStart, startPos
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	local sidebar = Create("Frame", {
		Parent = main,
		Position = UDim2.fromOffset(14, 82),
		Size = UDim2.fromOffset(210, 494),
		BackgroundColor3 = Library.Theme.Panel,
		BorderSizePixel = 0,
	})
	Corner(sidebar, UDim.new(0, 16))
	Stroke(sidebar, 1, Library.Theme.Stroke, 0.45)
	Padding(sidebar, 12, 12, 12, 12)

	local sidebarTitle = Label(sidebar, "Tabs", 18, true)
	sidebarTitle.Size = UDim2.new(1, 0, 0, 20)

	local tabList = MakeScrollable(sidebar)
	tabList.Position = UDim2.fromOffset(0, 28)
	tabList.Size = UDim2.new(1, 0, 1, -28)

	local contentHolder = Create("Frame", {
		Parent = main,
		Position = UDim2.fromOffset(236, 82),
		Size = UDim2.fromOffset(660, 494),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})

	local notificationHolder = Create("Frame", {
		Parent = screen,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 18),
		Size = UDim2.fromOffset(290, 500),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
	Create("UIListLayout", {
		Parent = notificationHolder,
		Padding = UDim.new(0, 10),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	})

	self.Gui = {
		Main = main,
		Shadow = shadow,
		TitleBar = titleBar,
		AccentBar = accentBar,
		Sidebar = sidebar,
		ContentHolder = contentHolder,
		Notifications = notificationHolder,
	}

	function self:Notify(titleText, bodyText, duration)
		duration = duration or 2.5
		local card = Create("Frame", {
			Parent = notificationHolder,
			Size = UDim2.fromOffset(290, 76),
			BackgroundColor3 = Library.Theme.Panel,
			BorderSizePixel = 0,
		})
		Corner(card, UDim.new(0, 14))
		Stroke(card, 1, Library.Theme.Stroke, 0.45)

		local bar = Create("Frame", {
			Parent = card,
			Size = UDim2.new(0, 4, 1, 0),
			BackgroundColor3 = self.Accent,
			BorderSizePixel = 0,
		})
		Corner(bar, UDim.new(0, 14))

		local nTitle = Label(card, titleText or "Notification", 16, true)
		nTitle.Position = UDim2.fromOffset(14, 10)
		nTitle.Size = UDim2.new(1, -22, 0, 18)

		local nBody = Label(card, bodyText or "", 13, false, 0.18)
		nBody.Position = UDim2.fromOffset(14, 31)
		nBody.Size = UDim2.new(1, -22, 0, 32)
		nBody.TextWrapped = true
		nBody.AutomaticSize = Enum.AutomaticSize.Y

		card.BackgroundTransparency = 1
		for _, child in ipairs(card:GetChildren()) do
			if child:IsA("GuiObject") then
				child.BackgroundTransparency = child.BackgroundTransparency or 0
			end
		end

		TweenService:Create(card, TweenInfo.new(0.18), {BackgroundTransparency = 0}):Play()
		task.delay(duration, function()
			if card and card.Parent then
				local tween = TweenService:Create(card, TweenInfo.new(0.18), {BackgroundTransparency = 1})
				tween:Play()
				tween.Completed:Wait()
				if card.Parent then card:Destroy() end
			end
		end)
	end

	function self:Destroy()
		self.Alive = false
		if self.ScreenGui then
			self.ScreenGui:Destroy()
		end
	end

	local function selectTab(tabObj)
		for _, t in ipairs(self.Tabs) do
			if t.Button then
				t.Button:SetAttribute("Selected", false)
				TweenService:Create(t.Button, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(39, 39, 46)}):Play()
				local stroke = t.Button:FindFirstChildOfClass("UIStroke")
				if stroke then
					stroke.Transparency = 0.55
				end
			end
			if t.Content then
				t.Content.Visible = false
			end
		end

		tabObj.Button:SetAttribute("Selected", true)
		TweenService:Create(tabObj.Button, TweenInfo.new(0.12), {BackgroundColor3 = self.Accent}):Play()
		local stroke = tabObj.Button:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Transparency = 0.2
		end
		tabObj.Content.Visible = true
		self.CurrentTab = tabObj
	end

	local window = self

	function self:AddTab(tabName, icon)
		local tab = { Name = tabName or "Tab", Window = window, Sections = {} }

		local button = Create("TextButton", {
			Parent = tabList,
			Size = UDim2.new(1, 0, 0, 42),
			BackgroundColor3 = Color3.fromRGB(39, 39, 46),
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
		})
		Corner(button, UDim.new(0, 12))
		Stroke(button, 1, Library.Theme.Stroke, 0.55)

		local txt = Label(button, tabName or "Tab", 16, true)
		txt.Position = UDim2.fromOffset(12, 0)
		txt.Size = UDim2.new(1, -24, 1, 0)

		if icon then
			local iconLabel = Label(button, icon, 16, true, 0)
			iconLabel.Position = UDim2.fromOffset(12, 0)
			iconLabel.Size = UDim2.fromOffset(20, 42)
			txt.Position = UDim2.fromOffset(36, 0)
			txt.Size = UDim2.new(1, -48, 1, 0)
		end

		ButtonFx(button, self.Accent)

		local content = Create("ScrollingFrame", {
			Parent = contentHolder,
			Visible = false,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Library.Theme.Panel,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = self.Accent,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(),
		})
		Corner(content, UDim.new(0, 16))
		Stroke(content, 1, Library.Theme.Stroke, 0.45)
		Padding(content, 12, 12, 12, 12)
		Create("UIListLayout", {
			Parent = content,
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})

		tab.Button = button
		tab.Content = content

		function tab:AddSection(sectionTitle)
			local section = {}
			local frame = Create("Frame", {
				Parent = content,
				Size = UDim2.new(1, 0, 0, 44),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Library.Theme.Panel2,
				BorderSizePixel = 0,
			})
			Corner(frame, UDim.new(0, 14))
			Stroke(frame, 1, Library.Theme.Stroke, 0.55)
			Padding(frame, 12, 12, 12, 12)

			local header = Label(frame, sectionTitle or "Section", 17, true)
			header.Size = UDim2.new(1, 0, 0, 18)

			local body = Create("Frame", {
				Parent = frame,
				Position = UDim2.fromOffset(0, 28),
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			})
			Create("UIListLayout", {
				Parent = body,
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
			})

			section.Frame = frame
			section.Body = body
			section.Window = window
			section.Tab = tab

			local function baseRow(height)
				local row = Create("Frame", {
					Parent = body,
					Size = UDim2.new(1, 0, 0, height or 44),
					BackgroundColor3 = Library.Theme.Panel,
					BorderSizePixel = 0,
				})
				Corner(row, UDim.new(0, 12))
				Stroke(row, 1, Library.Theme.Stroke, 0.6)
				return row
			end

			function section:AddLabel(text)
				local row = baseRow(36)
				local lbl = Label(row, text or "Label", 15, false)
				lbl.Position = UDim2.fromOffset(12, 0)
				lbl.Size = UDim2.new(1, -24, 1, 0)
				return {Frame = row, Label = lbl}
			end

			function section:AddParagraph(titleText, bodyText)
				local row = Create("Frame", {
					Parent = body,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Library.Theme.Panel,
					BorderSizePixel = 0,
				})
				Corner(row, UDim.new(0, 12))
				Stroke(row, 1, Library.Theme.Stroke, 0.6)
				Padding(row, 12, 12, 12, 12)

				local t = Label(row, titleText or "Paragraph", 15, true)
				t.Size = UDim2.new(1, 0, 0, 18)

				local b = Label(row, bodyText or "", 13, false, 0.18)
				b.Position = UDim2.fromOffset(0, 22)
				b.Size = UDim2.new(1, 0, 0, 0)
				b.AutomaticSize = Enum.AutomaticSize.Y
				b.TextWrapped = true

				return {Frame = row, Title = t, Body = b}
			end

			function section:AddButton(text, callback)
				local row = baseRow(42)
				local btn = Create("TextButton", {
					Parent = row,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Text = "",
					AutoButtonColor = false,
				})

				local lbl = Label(row, text or "Button", 15, true)
				lbl.Position = UDim2.fromOffset(12, 0)
				lbl.Size = UDim2.new(1, -24, 1, 0)

				btn.MouseEnter:Connect(function()
					TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Library.Theme.Panel2}):Play()
				end)
				btn.MouseLeave:Connect(function()
					TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Library.Theme.Panel}):Play()
				end)
				btn.MouseButton1Click:Connect(function()
					if callback then
						task.spawn(callback)
					end
				end)

				return {Frame = row, Button = btn, Label = lbl}
			end

			function section:AddToggle(text, default, callback)
				local state = default and true or false
				local row = baseRow(44)
				local btn = Create("TextButton", {
					Parent = row,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Text = "",
					AutoButtonColor = false,
				})

				local lbl = Label(row, text or "Toggle", 15, true)
				lbl.Position = UDim2.fromOffset(12, 0)
				lbl.Size = UDim2.new(1, -74, 1, 0)

				local switchBg = Create("Frame", {
					Parent = row,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -12, 0.5, 0),
					Size = UDim2.fromOffset(42, 22),
					BackgroundColor3 = state and self.Accent or Color3.fromRGB(58, 58, 68),
					BorderSizePixel = 0,
				})
				Corner(switchBg, UDim.new(1, 0))

				local knob = Create("Frame", {
					Parent = switchBg,
					Position = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
					Size = UDim2.fromOffset(16, 16),
					BackgroundColor3 = Color3.fromRGB(245, 245, 245),
					BorderSizePixel = 0,
				})
				Corner(knob, UDim.new(1, 0))

				local function set(v)
					state = v and true or false
					TweenService:Create(switchBg, TweenInfo.new(0.12), {
						BackgroundColor3 = state and self.Accent or Color3.fromRGB(58, 58, 68)
					}):Play()
					TweenService:Create(knob, TweenInfo.new(0.12), {
						Position = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
					}):Play()
					if callback then
						task.spawn(callback, state)
					end
				end

				btn.MouseButton1Click:Connect(function()
					set(not state)
				end)

				return {
					Frame = row,
					Value = function() return state end,
					Set = set,
				}
			end

			function section:AddTextbox(text, placeholder, callback)
				local row = Create("Frame", {
					Parent = body,
					Size = UDim2.new(1, 0, 0, 64),
					BackgroundColor3 = Library.Theme.Panel,
					BorderSizePixel = 0,
				})
				Corner(row, UDim.new(0, 12))
				Stroke(row, 1, Library.Theme.Stroke, 0.6)
				Padding(row, 12, 12, 10, 10)

				local lbl = Label(row, text or "Textbox", 15, true)
				lbl.Size = UDim2.new(1, 0, 0, 18)

				local box = Create("TextBox", {
					Parent = row,
					Position = UDim2.fromOffset(0, 28),
					Size = UDim2.new(1, 0, 0, 24),
					BackgroundColor3 = Library.Theme.Panel2,
					Text = "",
					PlaceholderText = placeholder or "",
					Font = Enum.Font.Gotham,
					TextSize = 14,
					TextColor3 = Library.Theme.Text,
					PlaceholderColor3 = Library.Theme.Muted,
					ClearTextOnFocus = false,
					BorderSizePixel = 0,
				})
				Corner(box, UDim.new(0, 8))
				Padding(box, 10, 10, 0, 0)

				box.FocusLost:Connect(function(enterPressed)
					if callback then
						task.spawn(callback, box.Text, enterPressed)
					end
				end)

				return {
					Frame = row,
					TextBox = box,
					Set = function(_, value) box.Text = tostring(value or "") end,
					Get = function() return box.Text end,
				}
			end

			function section:AddSlider(text, min, max, default, callback)
				min = tonumber(min) or 0
				max = tonumber(max) or 100
				local value = math.clamp(tonumber(default) or min, min, max)

				local row = Create("Frame", {
					Parent = body,
					Size = UDim2.new(1, 0, 0, 64),
					BackgroundColor3 = Library.Theme.Panel,
					BorderSizePixel = 0,
				})
				Corner(row, UDim.new(0, 12))
				Stroke(row, 1, Library.Theme.Stroke, 0.6)
				Padding(row, 12, 12, 10, 10)

				local top = Create("Frame", {
					Parent = row,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 18),
					BorderSizePixel = 0,
				})

				local lbl = Label(top, text or "Slider", 15, true)
				lbl.Size = UDim2.new(1, -50, 1, 0)

				local valLabel = Label(top, tostring(value), 14, false, 0.22, Enum.TextXAlignment.Right)
				valLabel.AnchorPoint = Vector2.new(1, 0)
				valLabel.Position = UDim2.new(1, 0, 0, 0)
				valLabel.Size = UDim2.fromOffset(50, 18)

				local track = Create("TextButton", {
					Parent = row,
					Position = UDim2.fromOffset(0, 34),
					Size = UDim2.new(1, 0, 0, 10),
					BackgroundColor3 = Color3.fromRGB(58, 58, 68),
					Text = "",
					AutoButtonColor = false,
					BorderSizePixel = 0,
				})
				Corner(track, UDim.new(1, 0))

				local fill = Create("Frame", {
					Parent = track,
					Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0),
					BackgroundColor3 = self.Accent,
					BorderSizePixel = 0,
				})
				Corner(fill, UDim.new(1, 0))

				local dragging = false

				local function setFromX(x)
					local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
					value = math.floor((min + (max - min) * alpha) * 100 + 0.5) / 100
					valLabel.Text = tostring(value)
					fill.Size = UDim2.new(alpha, 0, 1, 0)
					if callback then
						task.spawn(callback, value)
					end
				end

				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						setFromX(input.Position.X)
					end
				end)
				track.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						setFromX(input.Position.X)
					end
				end)

				return {
					Frame = row,
					Value = function() return value end,
					Set = function(_, v)
						v = math.clamp(tonumber(v) or min, min, max)
						value = v
						valLabel.Text = tostring(value)
						fill.Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0)
					end,
				}
			end

			function section:AddDropdown(text, options, default, callback)
				options = options or {}
				local selected = default or options[1]

				local row = Create("Frame", {
					Parent = body,
					Size = UDim2.new(1, 0, 0, 48),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = Library.Theme.Panel,
					BorderSizePixel = 0,
				})
				Corner(row, UDim.new(0, 12))
				Stroke(row, 1, Library.Theme.Stroke, 0.6)
				Padding(row, 12, 12, 8, 8)

				local lbl = Label(row, text or "Dropdown", 15, true)
				lbl.Size = UDim2.new(1, -24, 0, 18)

				local display = Create("TextButton", {
					Parent = row,
					Position = UDim2.fromOffset(0, 24),
					Size = UDim2.new(1, 0, 0, 18),
					BackgroundTransparency = 1,
					Text = "",
					AutoButtonColor = false,
				})

				local valueLabel = Label(display, tostring(selected or "Select"), 14, false, 0.22)
				valueLabel.Size = UDim2.new(1, -20, 1, 0)

				local arrow = Label(display, "⌄", 16, true, 0.15, Enum.TextXAlignment.Right)
				arrow.AnchorPoint = Vector2.new(1, 0)
				arrow.Position = UDim2.new(1, 0, 0, 0)
				arrow.Size = UDim2.fromOffset(18, 18)

				local listHolder = Create("Frame", {
					Parent = row,
					Visible = false,
					Position = UDim2.fromOffset(0, 48),
					Size = UDim2.new(1, 0, 0, 0),
					BackgroundColor3 = Library.Theme.Panel2,
					BorderSizePixel = 0,
					ZIndex = 20,
				})
				Corner(listHolder, UDim.new(0, 10))
				Stroke(listHolder, 1, Library.Theme.Stroke, 0.45)
				Padding(listHolder, 6, 6, 6, 6)

				local list = Create("ScrollingFrame", {
					Parent = listHolder,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					ScrollBarThickness = 4,
					ScrollBarImageColor3 = self.Accent,
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					CanvasSize = UDim2.new(),
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 20,
				})
				Create("UIListLayout", {
					Parent = list,
					Padding = UDim.new(0, 6),
				})

				local open = false

				local function refresh()
					for _, child in ipairs(list:GetChildren()) do
						if child:IsA("TextButton") then
							child:Destroy()
						end
					end

					for _, option in ipairs(options) do
						local opt = Create("TextButton", {
							Parent = list,
							Size = UDim2.new(1, 0, 0, 28),
							BackgroundColor3 = option == selected and self.Accent or Color3.fromRGB(44, 44, 52),
							BorderSizePixel = 0,
							Text = "",
							AutoButtonColor = false,
							ZIndex = 21,
						})
						Corner(opt, UDim.new(0, 8))

						local optLabel = Label(opt, tostring(option), 14, true, option == selected and 0.02 or 0.1)
						optLabel.Position = UDim2.fromOffset(10, 0)
						optLabel.Size = UDim2.new(1, -20, 1, 0)
						optLabel.ZIndex = 21

						opt.MouseEnter:Connect(function()
							if option ~= selected then
								TweenService:Create(opt, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 55, 64)}):Play()
							end
						end)
						opt.MouseLeave:Connect(function()
							if option ~= selected then
								TweenService:Create(opt, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(44, 44, 52)}):Play()
							end
						end)
						opt.MouseButton1Click:Connect(function()
							selected = option
							valueLabel.Text = tostring(selected)
							if callback then
								task.spawn(callback, selected)
							end
							refresh()
							open = false
							listHolder.Visible = false
						end)
					end
				end

				refresh()

				local function setOpen(state)
					open = state
					listHolder.Visible = open
					if open then
						local optionCount = math.min(#options, 6)
						listHolder.Size = UDim2.new(1, 0, 0, 12 + (optionCount * 34))
					else
						listHolder.Size = UDim2.new(1, 0, 0, 0)
					end
				end

				display.MouseButton1Click:Connect(function()
					setOpen(not open)
				end)

				return {
					Frame = row,
					Value = function() return selected end,
					Set = function(_, v)
						selected = v
						valueLabel.Text = tostring(selected)
						if callback then
							task.spawn(callback, selected)
						end
						refresh()
					end,
				}
			end

			table.insert(tab.Sections, section)
			return section
		end

		button.MouseButton1Click:Connect(function()
			selectTab(tab)
		end)

		table.insert(self.Tabs, tab)
		if #self.Tabs == 1 then
			selectTab(tab)
		end

		return tab
	end

	return self
end

return Library
