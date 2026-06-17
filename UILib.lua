--!strict
-- Weapon UI Library
-- A reusable Roblox UI library with the same visual language as the provided menu,
-- but written as a real component-based library.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Library = {}
Library.__index = Library

local DefaultTheme = {
	Background = Color3.fromRGB(22, 22, 28),
	Surface = Color3.fromRGB(32, 32, 40),
	Surface2 = Color3.fromRGB(38, 38, 47),
	Stroke = Color3.fromRGB(82, 82, 96),
	Text = Color3.fromRGB(245, 245, 245),
	MutedText = Color3.fromRGB(180, 180, 190),
	Accent = Color3.fromRGB(255, 120, 40),
	AccentHover = Color3.fromRGB(255, 145, 72),
	Danger = Color3.fromRGB(235, 78, 78),
	Success = Color3.fromRGB(82, 205, 126),
	Shadow = Color3.fromRGB(0, 0, 0),
}

local function getGuiParent()
	if typeof(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok and result then
			return result
		end
	end

	local okCore, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)
	if okCore and coreGui then
		return coreGui
	end

	return LocalPlayer:WaitForChild("PlayerGui")
end

local function create(className: string, props: {[string]: any}?)
	local obj = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			obj[k] = v
		end
	end
	return obj
end

local function applyCorner(parent: Instance, radius: number?)
	return create("UICorner", {
		Parent = parent,
		CornerRadius = UDim.new(0, radius or 12),
	})
end

local function applyStroke(parent: Instance, thickness: number?, color: Color3?, transparency: number?)
	return create("UIStroke", {
		Parent = parent,
		Thickness = thickness or 1,
		Color = color or DefaultTheme.Stroke,
		Transparency = transparency or 0.35,
	})
end

local function textLabel(parent: Instance, text: string?, size: number?, bold: boolean?, alpha: number?)
	return create("TextLabel", {
		Parent = parent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = text or "",
		Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextSize = size or 16,
		TextColor3 = DefaultTheme.Text,
		TextTransparency = alpha or 0,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		RichText = false,
	})
end

local function tween(inst: Instance, info: TweenInfo, goal: {[string]: any})
	local tw = TweenService:Create(inst, info, goal)
	tw:Play()
	return tw
end

local function safeDestroy(inst: Instance?)
	if inst and inst.Parent then
		inst:Destroy()
	end
end

local function clamp01(v: number): number
	return math.clamp(v, 0, 1)
end

function Library.new()
	local self = setmetatable({}, Library)
	self.Theme = table.clone(DefaultTheme)
	self.Windows = {}
	self._activeGui = nil
	return self
end

function Library:SetTheme(themeTable)
	for k, v in pairs(themeTable or {}) do
		if self.Theme[k] ~= nil then
			self.Theme[k] = v
		end
	end
end

function Library:Destroy()
	for _, window in ipairs(self.Windows) do
		if window.Gui then
			window.Gui:Destroy()
		end
	end
	table.clear(self.Windows)
	self._activeGui = nil
end

function Library:Notify(data)
	local gui = self._activeGui
	if not gui or not gui.Parent then
		return
	end

	local title = data and data.Title or "Notification"
	local content = data and data.Content or ""
	local duration = data and data.Duration or 3
	local theme = self.Theme

	local container = gui:FindFirstChild("NotifyContainer")
	if not container then
		container = create("Frame", {
			Name = "NotifyContainer",
			Parent = gui,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -18, 1, -18),
			Size = UDim2.fromOffset(340, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})

		create("UIListLayout", {
			Parent = container,
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
	end

	local card = create("Frame", {
		Parent = container,
		Size = UDim2.fromOffset(340, 74),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
	applyCorner(card, 14)
	applyStroke(card, 1, theme.Stroke, 0.45)

	local accent = create("Frame", {
		Parent = card,
		Position = UDim2.new(0, 0, 1, -3),
		Size = UDim2.new(1, 0, 0, 3),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
	})
	applyCorner(accent, 100)

	local t = textLabel(card, title, 16, true, 0)
	t.Position = UDim2.fromOffset(12, 10)
	t.Size = UDim2.new(1, -24, 0, 18)

	local c = textLabel(card, content, 13, false, 0.18)
	c.Position = UDim2.fromOffset(12, 31)
	c.Size = UDim2.new(1, -24, 0, 30)
	c.TextWrapped = true

	tween(card, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
	})

	task.delay(duration, function()
		if card and card.Parent then
			tween(card, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1,
			})
			task.wait(0.18)
			safeDestroy(card)
		end
	end)

	return card
end

local function buildButton(parent: Instance, theme, title: string, subtitle: string?, selected: boolean?)
	local btn = create("TextButton", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = selected and theme.Accent or theme.Surface2,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
	})
	applyCorner(btn, 12)
	applyStroke(btn, 1, theme.Stroke, 0.5)

	local titleLabel = textLabel(btn, title, 17, true, selected and 0 or 0.02)
	titleLabel.Name = "Title"
	titleLabel.Position = UDim2.fromOffset(12, 6)
	titleLabel.Size = UDim2.new(1, -24, 0, 18)

	local subLabel = textLabel(btn, subtitle or "", 13, false, 0.24)
	subLabel.Position = UDim2.fromOffset(12, 24)
	subLabel.Size = UDim2.new(1, -24, 0, 16)

	btn.MouseEnter:Connect(function()
		tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundColor3 = selected and theme.AccentHover or Color3.fromRGB(48, 48, 58),
		})
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundColor3 = selected and theme.Accent or theme.Surface2,
		})
	end)

	return btn, titleLabel, subLabel
end

local function buildSection(parent: Instance, theme, title: string)
	local frame = create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 10),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
	})
	applyCorner(frame, 14)
	applyStroke(frame, 1, theme.Stroke, 0.42)

	textLabel(frame, title, 17, true, 0).Position = UDim2.fromOffset(12, 10)
	local titleLbl = frame:FindFirstChildOfClass("TextLabel")
	if titleLbl then
		titleLbl.Size = UDim2.new(1, -24, 0, 18)
	end

	local content = create("Frame", {
		Parent = frame,
		Position = UDim2.fromOffset(12, 36),
		Size = UDim2.new(1, -24, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})

	create("UIListLayout", {
		Parent = content,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	return frame, content
end

local function makeValueRow(parent: Instance, theme, title: string, value: string)
	local row = create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = theme.Surface2,
		BorderSizePixel = 0,
	})
	applyCorner(row, 10)
	applyStroke(row, 1, theme.Stroke, 0.55)

	local titleLbl = textLabel(row, title, 15, true, 0)
	titleLbl.Position = UDim2.fromOffset(12, 5)
	titleLbl.Size = UDim2.new(1, -24, 0, 16)

	local valueLbl = textLabel(row, value, 13, false, 0.16)
	valueLbl.Position = UDim2.fromOffset(12, 21)
	valueLbl.Size = UDim2.new(1, -24, 0, 14)

	return row, valueLbl
end

local function makeBar(parent: Instance, theme, title: string, valueText: string, ratio: number)
	local row = create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = theme.Surface2,
		BorderSizePixel = 0,
	})
	applyCorner(row, 10)
	applyStroke(row, 1, theme.Stroke, 0.55)

	local titleLbl = textLabel(row, title, 15, true, 0)
	titleLbl.Position = UDim2.fromOffset(12, 5)
	titleLbl.Size = UDim2.new(1, -24, 0, 16)

	local valueLbl = textLabel(row, valueText, 13, false, 0.16)
	valueLbl.Position = UDim2.fromOffset(12, 22)
	valueLbl.Size = UDim2.new(1, -24, 0, 14)

	local bg = create("Frame", {
		Parent = row,
		Position = UDim2.fromOffset(12, 38),
		Size = UDim2.new(1, -24, 0, 5),
		BackgroundColor3 = Color3.fromRGB(58, 58, 68),
		BorderSizePixel = 0,
	})
	applyCorner(bg, 100)

	local fill = create("Frame", {
		Parent = bg,
		Size = UDim2.new(clamp01(ratio), 0, 1, 0),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
	})
	applyCorner(fill, 100)

	return row, fill
end

local function makeToggle(parent: Instance, theme, title: string, defaultValue: boolean, callback)
	local state = defaultValue

	local row = create("TextButton", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = theme.Surface2,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
	})
	applyCorner(row, 12)
	applyStroke(row, 1, theme.Stroke, 0.55)

	local titleLbl = textLabel(row, title, 15, true, 0)
	titleLbl.Position = UDim2.fromOffset(12, 6)
	titleLbl.Size = UDim2.new(1, -64, 0, 18)

	local stateLbl = textLabel(row, state and "Enabled" or "Disabled", 13, false, 0.22)
	stateLbl.Position = UDim2.fromOffset(12, 22)
	stateLbl.Size = UDim2.new(1, -64, 0, 14)

	local switch = create("Frame", {
		Parent = row,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(38, 20),
		BackgroundColor3 = state and theme.Accent or Color3.fromRGB(60, 60, 72),
		BorderSizePixel = 0,
	})
	applyCorner(switch, 100)

	local knob = create("Frame", {
		Parent = switch,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = state and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = theme.Text,
		BorderSizePixel = 0,
	})
	applyCorner(knob, 100)

	row.MouseEnter:Connect(function()
		tween(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(45, 45, 56)})
	end)
	row.MouseLeave:Connect(function()
		tween(row, TweenInfo.new(0.12), {BackgroundColor3 = theme.Surface2})
	end)

	local function set(value: boolean)
		state = value
		stateLbl.Text = state and "Enabled" or "Disabled"
		tween(switch, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundColor3 = state and theme.Accent or Color3.fromRGB(60, 60, 72),
		})
		tween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = state and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 10, 0.5, 0),
		})
		if callback then callback(state) end
	end

	row.MouseButton1Click:Connect(function()
		set(not state)
	end)

	return {
		Set = function(_, value)
			set(not not value)
		end,
		Get = function()
			return state
		end,
	}
end

local function makeSlider(parent: Instance, theme, title: string, minValue: number, maxValue: number, defaultValue: number, callback)
	local value = math.clamp(defaultValue, minValue, maxValue)
	local dragging = false

	local row = create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = theme.Surface2,
		BorderSizePixel = 0,
	})
	applyCorner(row, 12)
	applyStroke(row, 1, theme.Stroke, 0.55)

	local titleLbl = textLabel(row, title, 15, true, 0)
	titleLbl.Position = UDim2.fromOffset(12, 6)
	titleLbl.Size = UDim2.new(1, -24, 0, 16)

	local valueLbl = textLabel(row, tostring(value), 13, false, 0.16)
	valueLbl.Position = UDim2.fromOffset(12, 22)
	valueLbl.Size = UDim2.new(1, -24, 0, 14)

	local barBg = create("Frame", {
		Parent = row,
		Position = UDim2.fromOffset(12, 40),
		Size = UDim2.new(1, -24, 0, 6),
		BackgroundColor3 = Color3.fromRGB(58, 58, 68),
		BorderSizePixel = 0,
	})
	applyCorner(barBg, 100)

	local fill = create("Frame", {
		Parent = barBg,
		Size = UDim2.new((value - minValue) / math.max(maxValue - minValue, 1), 0, 1, 0),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
	})
	applyCorner(fill, 100)

	local function updateByX(xPos: number)
		local ratio = clamp01((xPos - barBg.AbsolutePosition.X) / math.max(barBg.AbsoluteSize.X, 1))
		value = math.floor((minValue + (maxValue - minValue) * ratio) + 0.5)
		valueLbl.Text = tostring(value)
		fill.Size = UDim2.new(ratio, 0, 1, 0)
		if callback then callback(value) end
	end

	barBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateByX(input.Position.X)
		end
	end)

	barBg.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateByX(input.Position.X)
		end
	end)

	return {
		Set = function(_, newValue)
			value = math.clamp(newValue, minValue, maxValue)
			local ratio = (value - minValue) / math.max(maxValue - minValue, 1)
			valueLbl.Text = tostring(value)
			fill.Size = UDim2.new(ratio, 0, 1, 0)
		end,
		Get = function()
			return value
		end,
	}
end

local function makeTextbox(parent: Instance, theme, title: string, placeholder: string, defaultValue: string, callback)
	local row = create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 64),
		BackgroundColor3 = theme.Surface2,
		BorderSizePixel = 0,
	})
	applyCorner(row, 12)
	applyStroke(row, 1, theme.Stroke, 0.55)

	local titleLbl = textLabel(row, title, 15, true, 0)
	titleLbl.Position = UDim2.fromOffset(12, 6)
	titleLbl.Size = UDim2.new(1, -24, 0, 16)

	local box = create("TextBox", {
		Parent = row,
		Position = UDim2.fromOffset(12, 28),
		Size = UDim2.new(1, -24, 0, 26),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Text = defaultValue or "",
		PlaceholderText = placeholder or "Enter text...",
		TextColor3 = theme.Text,
		PlaceholderColor3 = theme.MutedText,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		ClearTextOnFocus = false,
	})
	applyCorner(box, 8)
	applyStroke(box, 1, theme.Stroke, 0.7)

	box.FocusLost:Connect(function(enterPressed)
		if callback then callback(box.Text, enterPressed) end
	end)

	return {
		Set = function(_, text)
			box.Text = tostring(text)
		end,
		Get = function()
			return box.Text
		end,
	}
end

local function makeDropdown(parent: Instance, theme, title: string, options: {string}, defaultValue: string?, callback)
	local selected = defaultValue or options[1] or ""
	local opened = false
	local items = {}

	local row = create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 46),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Surface2,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	})
	applyCorner(row, 12)
	applyStroke(row, 1, theme.Stroke, 0.55)

	local titleLbl = textLabel(row, title, 15, true, 0)
	titleLbl.Position = UDim2.fromOffset(12, 6)
	titleLbl.Size = UDim2.new(1, -40, 0, 16)

	local selectedLbl = textLabel(row, selected, 13, false, 0.16)
	selectedLbl.Position = UDim2.fromOffset(12, 22)
	selectedLbl.Size = UDim2.new(1, -40, 0, 14)

	local arrow = textLabel(row, "▾", 18, true, 0.15)
	arrow.AnchorPoint = Vector2.new(1, 0.5)
	arrow.Position = UDim2.new(1, -12, 0.5, 0)
	arrow.Size = UDim2.fromOffset(16, 16)
	arrow.TextXAlignment = Enum.TextXAlignment.Center

	local list = create("Frame", {
		Parent = row,
		Position = UDim2.fromOffset(0, 46),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
	})

	create("UIListLayout", {
		Parent = list,
		Padding = UDim.new(0, 6),
	})

	local function rebuild()
		for _, child in ipairs(items) do
			safeDestroy(child)
		end
		table.clear(items)

		for _, option in ipairs(options) do
			local item = create("TextButton", {
				Parent = list,
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = option == selected and theme.Accent or theme.Surface,
				BorderSizePixel = 0,
				Text = option,
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = theme.Text,
				AutoButtonColor = false,
			})
			applyCorner(item, 10)
			applyStroke(item, 1, theme.Stroke, 0.7)

			item.MouseEnter:Connect(function()
				if option ~= selected then
					tween(item, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(45, 45, 56)})
				end
			end)
			item.MouseLeave:Connect(function()
				tween(item, TweenInfo.new(0.12), {
					BackgroundColor3 = option == selected and theme.Accent or theme.Surface,
				})
			end)
			item.MouseButton1Click:Connect(function()
				selected = option
				selectedLbl.Text = selected
				if callback then callback(selected) end
				rebuild()
			end)

			table.insert(items, item)
		end
	end

	local function setOpen(value: boolean)
		opened = value
		list.Visible = opened
		arrow.Text = opened and "▴" or "▾"
		if opened then
			rebuild()
		end
	end

	row.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setOpen(not opened)
		end
	end)

	row.MouseEnter:Connect(function()
		tween(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(45, 45, 56)})
	end)
	row.MouseLeave:Connect(function()
		if not opened then
			tween(row, TweenInfo.new(0.12), {BackgroundColor3 = theme.Surface2})
		end
	end)

	return {
		Set = function(_, value)
			selected = tostring(value)
			selectedLbl.Text = selected
			rebuild()
		end,
		Get = function()
			return selected
		end,
		Open = function()
			setOpen(true)
		end,
		Close = function()
			setOpen(false)
		end,
	}
end

function Library:CreateWindow(config)
	config = config or {}
	local theme = self.Theme
	local guiParent = config.Parent or getGuiParent()

	local gui = create("ScreenGui", {
		Name = config.Name or "WeaponUILibrary",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = guiParent,
	})

	local shadow = create("Frame", {
		Parent = gui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = config.Position or UDim2.fromScale(0.5, 0.5),
		Size = config.Size or UDim2.fromOffset(860, 580),
		BackgroundColor3 = theme.Shadow,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
	})
	applyCorner(shadow, 18)

	local main = create("Frame", {
		Parent = shadow,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, -8, 1, -8),
		BackgroundColor3 = theme.Background,
		BorderSizePixel = 0,
	})
	applyCorner(main, 18)
	applyStroke(main, 1, theme.Stroke, 0.28)

	local top = create("Frame", {
		Parent = main,
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
	})
	applyCorner(top, 18)

	create("Frame", {
		Parent = top,
		Position = UDim2.new(0, 0, 1, -2),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
	})

	local title = textLabel(top, config.Title or "Weapon Modify Menu", 23, true, 0)
	title.Position = UDim2.fromOffset(18, 10)
	title.Size = UDim2.new(1, -140, 0, 22)

	local subtitle = textLabel(top, config.Subtitle or "Weapon statistics overview", 13, false, 0.35)
	subtitle.Position = UDim2.fromOffset(18, 34)
	subtitle.Size = UDim2.new(1, -140, 0, 16)

	local closeBtn = create("TextButton", {
		Parent = top,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = theme.Surface2,
		BorderSizePixel = 0,
		Text = "×",
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		AutoButtonColor = false,
	})
	applyCorner(closeBtn, 8)
	applyStroke(closeBtn, 1, theme.Stroke, 0.6)

	local minimizeBtn = create("TextButton", {
		Parent = top,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -48, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		BackgroundColor3 = theme.Surface2,
		BorderSizePixel = 0,
		Text = "–",
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		AutoButtonColor = false,
	})
	applyCorner(minimizeBtn, 8)
	applyStroke(minimizeBtn, 1, theme.Stroke, 0.6)

	local body = create("Frame", {
		Parent = main,
		Position = UDim2.fromOffset(0, 62),
		Size = UDim2.new(1, 0, 1, -62),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})

	local sidebar = create("Frame", {
		Parent = body,
		Position = UDim2.fromOffset(16, 16),
		Size = UDim2.fromOffset(250, 486),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
	})
	applyCorner(sidebar, 16)
	applyStroke(sidebar, 1, theme.Stroke, 0.42)

	local sidebarTitle = textLabel(sidebar, "Tabs", 18, true, 0)
	sidebarTitle.Position = UDim2.fromOffset(14, 12)
	sidebarTitle.Size = UDim2.new(1, -28, 0, 20)

	local tabList = create("ScrollingFrame", {
		Parent = sidebar,
		Position = UDim2.fromOffset(10, 42),
		Size = UDim2.new(1, -20, 1, -52),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	})

	create("UIListLayout", {
		Parent = tabList,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local pages = create("Frame", {
		Parent = body,
		Position = UDim2.fromOffset(280, 16),
		Size = UDim2.fromOffset(564, 486),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})

	local pageHolder = create("Frame", {
		Parent = pages,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})

	local pageStack = {}
	local activeTabName: string? = nil
	local minimized = false
	local dragging = false
	local dragStart: Vector2? = nil
	local startPos: UDim2? = nil

	local window = {
		Gui = gui,
		Shadow = shadow,
		Main = main,
		Body = body,
		Theme = theme,
		Tabs = {},
	}

	function window:SelectTab(name: string)
		for _, tab in ipairs(self.Tabs) do
			local active = tab.Name == name
			tab.Page.Visible = active
			tween(tab.Button, TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundColor3 = active and theme.Accent or theme.Surface2,
			})
		end
		activeTabName = name
	end

	function window:SetMinimized(state: boolean)
		minimized = state
		body.Visible = not minimized
		tween(shadow, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			BackgroundTransparency = minimized and 0.58 or 0.35,
		})
	end

	function window:ToggleMinimized()
		self:SetMinimized(not minimized)
	end

	function window:Destroy()
		if gui then
			gui:Destroy()
		end
	end

	function window:CreateTab(tabConfig)
		tabConfig = tabConfig or {}
		local tabName = tabConfig.Name or "Tab"
		local tabDesc = tabConfig.Description or ""

		local btn = buildButton(tabList, theme, tabName, tabDesc, #self.Tabs == 0)
		btn.Name = "TabButton_" .. tabName

		local page = create("ScrollingFrame", {
			Parent = pageHolder,
			Name = "Page_" .. tabName,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ScrollBarThickness = 4,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = #self.Tabs == 0,
		})

		create("UIListLayout", {
			Parent = page,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})

		local tab = {
			Name = tabName,
			Description = tabDesc,
			Button = btn,
			Page = page,
		}

		function tab:AddSection(sectionTitle: string)
			local _, content = buildSection(page, theme, sectionTitle)
			local section = {}

			function section:AddLabel(text: string)
				local lbl = textLabel(content, text, 14, false, 0)
				lbl.Size = UDim2.new(1, 0, 0, 18)
				return lbl
			end

			function section:AddParagraph(text: string)
				local lbl = textLabel(content, text, 13, false, 0.15)
				lbl.Size = UDim2.new(1, 0, 0, 0)
				lbl.AutomaticSize = Enum.AutomaticSize.Y
				lbl.TextWrapped = true
				return lbl
			end

			function section:AddButton(buttonTitle: string, buttonDesc: string?, callback)
				local btnObj = buildButton(content, theme, buttonTitle, buttonDesc, false)
				btnObj.MouseButton1Click:Connect(function()
					if callback then callback() end
				end)
				return btnObj
			end

			function section:AddToggle(toggleTitle: string, defaultValue: boolean?, callback)
				return makeToggle(content, theme, toggleTitle, defaultValue == true, callback)
			end

			function section:AddSlider(sliderTitle: string, minValue: number, maxValue: number, defaultValue: number, callback)
				return makeSlider(content, theme, sliderTitle, minValue, maxValue, defaultValue, callback)
			end

			function section:AddTextbox(textboxTitle: string, placeholder: string?, defaultValue: string?, callback)
				return makeTextbox(content, theme, textboxTitle, placeholder or "Enter text...", defaultValue or "", callback)
			end

			function section:AddDropdown(dropdownTitle: string, options: {string}, defaultValue: string?, callback)
				return makeDropdown(content, theme, dropdownTitle, options, defaultValue, callback)
			end

			function section:AddValue(valueTitle: string, valueText: string)
				local _, valueLbl = makeValueRow(content, theme, valueTitle, valueText)
				return {
					Set = function(_, newText)
						valueLbl.Text = tostring(newText)
					end,
					Get = function()
						return valueLbl.Text
					end,
				}
			end

			function section:AddStat(statTitle: string, valueText: string, ratio: number)
				return makeBar(content, theme, statTitle, valueText, ratio)
			end

			return section
		end

		btn.MouseButton1Click:Connect(function()
			window:SelectTab(tabName)
		end)

		table.insert(self.Tabs, tab)
		if #self.Tabs == 1 then
			self:SelectTab(tabName)
		end

		return tab
	end

	closeBtn.MouseEnter:Connect(function()
		tween(closeBtn, TweenInfo.new(0.12), {BackgroundColor3 = theme.Danger})
	end)
	closeBtn.MouseLeave:Connect(function()
		tween(closeBtn, TweenInfo.new(0.12), {BackgroundColor3 = theme.Surface2})
	end)
	closeBtn.MouseButton1Click:Connect(function()
		window:Destroy()
	end)

	minimizeBtn.MouseEnter:Connect(function()
		tween(minimizeBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(48, 48, 58)})
	end)
	minimizeBtn.MouseLeave:Connect(function()
		tween(minimizeBtn, TweenInfo.new(0.12), {BackgroundColor3 = theme.Surface2})
	end)
	minimizeBtn.MouseButton1Click:Connect(function()
		window:ToggleMinimized()
	end)

	top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = shadow.Position
		end
	end)

	top.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and dragStart and startPos then
			local delta = input.Position - dragStart
			shadow.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	table.insert(self.Windows, window)
	self._activeGui = gui

	return window
end

return Library.new()
