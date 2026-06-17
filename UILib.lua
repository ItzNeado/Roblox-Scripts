--!strict
-- ModuleScript: UI_Lib.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {}
Library.__index = Library

local function Create(className: string, props: {[string]: any}?)
	local obj = Instance.new(className)
	if props then
		for k, v in pairs(props) do
			obj[k] = v
		end
	end
	return obj
end

local function Round(instance: Instance, radius: number)
	local c = Create("UICorner", {
		CornerRadius = UDim.new(0, radius)
	})
	c.Parent = instance
	return c
end

local function Stroke(instance: Instance, color: Color3, thickness: number)
	local s = Create("UIStroke", {
		Color = color,
		Thickness = thickness,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Transparency = 0
	})
	s.Parent = instance
	return s
end

local function Padding(instance: Instance, left: number?, right: number?, top: number?, bottom: number?)
	local p = Create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
	})
	p.Parent = instance
	return p
end

local function Tween(instance: Instance, info: TweenInfo, goal: {[string]: any})
	return TweenService:Create(instance, info, goal)
end

Library.Theme = {
	Background = Color3.fromRGB(20, 20, 20),
	Panel = Color3.fromRGB(26, 26, 26),
	Panel2 = Color3.fromRGB(30, 30, 30),
	Topbar = Color3.fromRGB(18, 18, 18),
	Stroke = Color3.fromRGB(45, 45, 45),
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(200, 200, 200),
	Muted = Color3.fromRGB(160, 160, 160),
	Accent = Color3.fromRGB(57, 162, 232),
	Accent2 = Color3.fromRGB(35, 120, 200),
	Green = Color3.fromRGB(46, 139, 87),
	Red = Color3.fromRGB(178, 34, 34),
	Blue = Color3.fromRGB(57, 162, 232),
}

local function getParent()
	local lp = Players.LocalPlayer
	if lp then
		return lp:WaitForChild("PlayerGui")
	end
	return game:GetService("CoreGui")
end

function Library:Destroy()
	if self.Gui then
		self.Gui:Destroy()
	end
end

function Library:CreateWindow(options)
	options = options or {}

	local self = setmetatable({}, Library)
	self.Theme = options.Theme or Library.Theme
	self.Gui = Create("ScreenGui", {
		Name = options.Name or "UI_Lib",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		Parent = options.Parent or getParent(),
	})

	self.Tabs = {}
	self.ActiveTab = nil

	local width = options.Size and options.Size.X.Offset or 760
	local height = options.Size and options.Size.Y.Offset or 480

	local main = Create("Frame", {
		Name = "Main",
		Parent = self.Gui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = options.Size or UDim2.fromOffset(width, height),
		BackgroundColor3 = self.Theme.Background,
		BorderSizePixel = 0,
	})
	self.Main = main
	Round(main, 12)
	Stroke(main, self.Theme.Stroke, 2)

	local topbar = Create("Frame", {
		Name = "Topbar",
		Parent = main,
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundColor3 = self.Theme.Topbar,
		BorderSizePixel = 0,
	})
	Round(topbar, 12)
	Stroke(topbar, self.Theme.Stroke, 1)

	local topbarFix = Create("Frame", {
		Parent = topbar,
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		BackgroundColor3 = self.Theme.Topbar,
		BorderSizePixel = 0,
	})

	local title = Create("TextLabel", {
		Name = "Title",
		Parent = topbar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 18, 0, 6),
		Size = UDim2.new(1, -120, 0, 22),
		Font = Enum.Font.SourceSansBold,
		Text = options.Title or "UI Library",
		TextColor3 = self.Theme.Text,
		TextSize = 24,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	self.TitleLabel = title

	local subtitle = Create("TextLabel", {
		Name = "Subtitle",
		Parent = topbar,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 18, 0, 28),
		Size = UDim2.new(1, -120, 0, 16),
		Font = Enum.Font.SourceSansItalic,
		Text = options.Subtitle or "Modern Roblox UI",
		TextColor3 = self.Theme.Accent,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	self.SubtitleLabel = subtitle

	local close = Create("TextButton", {
		Name = "Close",
		Parent = topbar,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 10),
		Size = UDim2.new(0, 34, 0, 34),
		BackgroundColor3 = self.Theme.Panel2,
		BorderSizePixel = 0,
		Text = "×",
		Font = Enum.Font.SourceSansBold,
		TextSize = 26,
		TextColor3 = self.Theme.Text,
	})
	Round(close, 8)
	Stroke(close, self.Theme.Stroke, 1)
	close.MouseButton1Click:Connect(function()
		self:Destroy()
	end)

	local sidebar = Create("Frame", {
		Name = "Sidebar",
		Parent = main,
		Position = UDim2.new(0, 12, 0, 66),
		Size = UDim2.new(0, 170, 1, -78),
		BackgroundColor3 = self.Theme.Panel,
		BorderSizePixel = 0,
	})
	Round(sidebar, 10)
	Stroke(sidebar, self.Theme.Stroke, 1)
	Padding(sidebar, 10, 10, 10, 10)

	local tabList = Create("UIListLayout", {
		Parent = sidebar,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local pagesHolder = Create("Frame", {
		Name = "PagesHolder",
		Parent = main,
		Position = UDim2.new(0, 194, 0, 66),
		Size = UDim2.new(1, -206, 1, -78),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})
	self.PagesHolder = pagesHolder

	local function makeDraggable(frame: Frame, handle: GuiObject)
		local dragging = false
		local dragStart: Vector2?
		local startPos: UDim2?

		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = frame.Position
			end
		end)

		handle.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if not dragging or not dragStart or not startPos then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end)
	end

	makeDraggable(main, topbar)

	local function setActiveTab(tabName: string)
		for _, tabData in pairs(self.Tabs) do
			local isActive = tabData.Name == tabName
			tabData.Page.Visible = isActive
			tabData.Button.BackgroundColor3 = isActive and self.Theme.Accent or self.Theme.Panel2
		end
		self.ActiveTab = tabName
	end

	local function createPage()
		local page = Create("ScrollingFrame", {
			Name = "Page",
			Parent = pagesHolder,
			Visible = false,
			BackgroundColor3 = self.Theme.Panel,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 6,
			ScrollBarImageColor3 = self.Theme.Accent,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
		})
		Round(page, 10)
		Stroke(page, self.Theme.Stroke, 1)
		Padding(page, 12, 12, 12, 12)

		local layout = Create("UIListLayout", {
			Parent = page,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})

		return page
	end

	local function createSection(page: ScrollingFrame, sectionTitle: string)
		local section = Create("Frame", {
			Name = "Section",
			Parent = page,
			BackgroundColor3 = self.Theme.Background,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		})
		Round(section, 10)
		Stroke(section, self.Theme.Stroke, 1)
		Padding(section, 12, 12, 12, 12)

		local titleLabel = Create("TextLabel", {
			Parent = section,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 20),
			Font = Enum.Font.SourceSansBold,
			Text = sectionTitle,
			TextColor3 = self.Theme.Text,
			TextSize = 20,
			TextXAlignment = Enum.TextXAlignment.Left,
		})

		local inner = Create("Frame", {
			Parent = section,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 28),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		})

		local innerLayout = Create("UIListLayout", {
			Parent = inner,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})

		local api = {}

		local function row(height: number)
			local r = Create("Frame", {
				Parent = inner,
				BackgroundColor3 = self.Theme.Panel2,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, height),
			})
			Round(r, 8)
			Stroke(r, self.Theme.Stroke, 1)
			return r
		end

		function api:AddLabel(text: string)
			local r = row(34)
			local lbl = Create("TextLabel", {
				Parent = r,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -24, 1, 0),
				Font = Enum.Font.SourceSans,
				Text = text,
				TextColor3 = self.Theme.SubText,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
			})
			return lbl
		end

		function api:AddButton(text: string, callback)
			local r = row(38)
			local btn = Create("TextButton", {
				Parent = r,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Font = Enum.Font.SourceSansSemibold,
				Text = text,
				TextColor3 = self.Theme.Text,
				TextSize = 16,
			})
			btn.MouseButton1Click:Connect(function()
				if callback then
					task.spawn(callback)
				end
			end)
			return btn
		end

		function api:AddToggle(text: string, defaultValue: boolean, callback)
			local state = defaultValue and true or false
			local r = row(38)

			local lbl = Create("TextLabel", {
				Parent = r,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(1, -110, 1, 0),
				Font = Enum.Font.SourceSansSemibold,
				Text = text,
				TextColor3 = self.Theme.Text,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			local btn = Create("TextButton", {
				Parent = r,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.new(0, 78, 0, 24),
				BackgroundColor3 = state and self.Theme.Green or self.Theme.Red,
				BorderSizePixel = 0,
				Text = state and "ON" or "OFF",
				Font = Enum.Font.SourceSansBold,
				TextColor3 = self.Theme.Text,
				TextSize = 14,
			})
			Round(btn, 6)

			local function render()
				Tween(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = state and self.Theme.Green or self.Theme.Red
				}):Play()
				btn.Text = state and "ON" or "OFF"
			end

			btn.MouseButton1Click:Connect(function()
				state = not state
				render()
				if callback then
					task.spawn(callback, state)
				end
			end)

			return {
				Set = function(_, value: boolean)
					state = value and true or false
					render()
				end,
				Get = function()
					return state
				end,
			}
		end

		function api:AddTextbox(text: string, defaultValue: string, callback)
			local r = row(42)

			local lbl = Create("TextLabel", {
				Parent = r,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(0.45, 0, 1, 0),
				Font = Enum.Font.SourceSansSemibold,
				Text = text,
				TextColor3 = self.Theme.Text,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			local box = Create("TextBox", {
				Parent = r,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.new(0.48, 0, 0, 28),
				BackgroundColor3 = self.Theme.Background,
				BorderSizePixel = 0,
				Text = defaultValue or "",
				ClearTextOnFocus = false,
				Font = Enum.Font.Code,
				TextColor3 = self.Theme.Text,
				TextSize = 14,
				PlaceholderText = "",
			})
			Round(box, 6)
			Stroke(box, self.Theme.Stroke, 1)

			box.FocusLost:Connect(function()
				if callback then
					task.spawn(callback, box.Text)
				end
			end)

			return box
		end

		function api:AddDropdown(text: string, list: {string}, defaultValue: string, callback)
			local state = defaultValue or list[1] or ""
			local r = row(38)

			local lbl = Create("TextLabel", {
				Parent = r,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(0.45, 0, 1, 0),
				Font = Enum.Font.SourceSansSemibold,
				Text = text,
				TextColor3 = self.Theme.Text,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			local btn = Create("TextButton", {
				Parent = r,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.new(0.48, 0, 0, 26),
				BackgroundColor3 = self.Theme.Background,
				BorderSizePixel = 0,
				Text = state,
				Font = Enum.Font.SourceSans,
				TextColor3 = self.Theme.Text,
				TextSize = 14,
			})
			Round(btn, 6)
			Stroke(btn, self.Theme.Stroke, 1)

			local listFrame = Create("Frame", {
				Parent = section,
				Visible = false,
				BackgroundColor3 = self.Theme.Panel2,
				BorderSizePixel = 0,
				Size = UDim2.new(0.48, 0, 0, 0),
				ZIndex = 20,
			})
			Round(listFrame, 8)
			Stroke(listFrame, self.Theme.Stroke, 1)

			local listLayout = Create("UIListLayout", {
				Parent = listFrame,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
			})
			Padding(listFrame, 6, 6, 6, 6)

			for _, item in ipairs(list) do
				local opt = Create("TextButton", {
					Parent = listFrame,
					Size = UDim2.new(1, 0, 0, 24),
					BackgroundColor3 = self.Theme.Background,
					BorderSizePixel = 0,
					Text = item,
					Font = Enum.Font.SourceSans,
					TextColor3 = self.Theme.Text,
					TextSize = 14,
					ZIndex = 21,
				})
				Round(opt, 6)
				Stroke(opt, self.Theme.Stroke, 1)

				opt.MouseButton1Click:Connect(function()
					state = item
					btn.Text = item
					listFrame.Visible = false
					if callback then
						task.spawn(callback, item)
					end
				end)
			end

			btn.MouseButton1Click:Connect(function()
				listFrame.Position = UDim2.new(0.52, 0, 0, r.AbsolutePosition.Y - section.AbsolutePosition.Y + 38)
				listFrame.Size = UDim2.new(0.48, 0, 0, math.min(#list * 28 + 12, 180))
				listFrame.Visible = not listFrame.Visible
			end)

			return {
				Set = function(_, value: string)
					state = value
					btn.Text = value
				end,
				Get = function()
					return state
				end,
			}
		end

		function api:AddSlider(text: string, min: number, max: number, defaultValue: number, callback)
			local value = defaultValue or min
			local r = row(52)

			local lbl = Create("TextLabel", {
				Parent = r,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0, 4),
				Size = UDim2.new(1, -24, 0, 18),
				Font = Enum.Font.SourceSansSemibold,
				Text = string.format("%s: %d", text, value),
				TextColor3 = self.Theme.Text,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			local bar = Create("Frame", {
				Parent = r,
				Position = UDim2.new(0, 12, 0, 30),
				Size = UDim2.new(1, -24, 0, 10),
				BackgroundColor3 = self.Theme.Background,
				BorderSizePixel = 0,
			})
			Round(bar, 999)
			Stroke(bar, self.Theme.Stroke, 1)

			local fill = Create("Frame", {
				Parent = bar,
				Size = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = self.Theme.Accent,
				BorderSizePixel = 0,
			})
			Round(fill, 999)

			local dragging = false

			local function setValue(v: number)
				value = math.clamp(math.floor(v + 0.5), min, max)
				local alpha = (value - min) / math.max(max - min, 1)
				fill.Size = UDim2.new(alpha, 0, 1, 0)
				lbl.Text = string.format("%s: %d", text, value)
				if callback then
					task.spawn(callback, value)
				end
			end

			local function updateFromX(x: number)
				local alpha = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
				setValue(min + (max - min) * alpha)
			end

			bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					updateFromX(UserInputService:GetMouseLocation().X)
				end
			end)

			bar.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					updateFromX(UserInputService:GetMouseLocation().X)
				end
			end)

			setValue(value)

			return {
				Set = function(_, v: number)
					setValue(v)
				end,
				Get = function()
					return value
				end,
			}
		end

		function api:AddParagraph(titleText: string, bodyText: string)
			local r = Create("Frame", {
				Parent = inner,
				BackgroundColor3 = self.Theme.Panel2,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 72),
			})
			Round(r, 8)
			Stroke(r, self.Theme.Stroke, 1)
			Padding(r, 12, 12, 10, 10)

			local t = Create("TextLabel", {
				Parent = r,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 18),
				Font = Enum.Font.SourceSansBold,
				Text = titleText,
				TextColor3 = self.Theme.Text,
				TextSize = 16,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			local b = Create("TextLabel", {
				Parent = r,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 22),
				Size = UDim2.new(1, 0, 1, -22),
				Font = Enum.Font.SourceSans,
				Text = bodyText,
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextColor3 = self.Theme.SubText,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			})

			return r
		end

		return api
	end

	function self:CreateTab(tabName: string)
		local tabButton = Create("TextButton", {
			Name = tabName .. "_Button",
			Parent = sidebar,
			Size = UDim2.new(1, 0, 0, 34),
			BackgroundColor3 = self.Theme.Panel2,
			BorderSizePixel = 0,
			Text = tabName,
			Font = Enum.Font.SourceSansSemibold,
			TextColor3 = self.Theme.Text,
			TextSize = 15,
		})
		Round(tabButton, 8)
		Stroke(tabButton, self.Theme.Stroke, 1)

		local page = createPage()

		local tabAPI = {}
		tabAPI.Name = tabName
		tabAPI.Button = tabButton
		tabAPI.Page = page

		function tabAPI:AddSection(sectionTitle: string)
			return createSection(page, sectionTitle)
		end

		tabButton.MouseButton1Click:Connect(function()
			setActiveTab(tabName)
		end)

		table.insert(self.Tabs, tabAPI)

		if not self.ActiveTab then
			setActiveTab(tabName)
		end

		return tabAPI
	end

	return self
end

return Library
