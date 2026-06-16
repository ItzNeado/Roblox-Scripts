local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Library = {
    ActiveDropdown = nil,
    Flags = {}
}

-- Плавная анимация наведения
local function applyHover(instance, enterColor, leaveColor, property)
    instance.MouseEnter:Connect(function()
        TweenService:Create(instance, TweenInfo.new(0.15), {[property] = enterColor}):Play()
    end)
    instance.MouseLeave:Connect(function()
        TweenService:Create(instance, TweenInfo.new(0.15), {[property] = leaveColor}):Play()
    end)
end

-- Создание Главного Окна
function Library:CreateWindow(titleText, subtitleText)
    if _G.GUI_MAIN then _G.GUI_MAIN:Destroy() end
    local GUI = gethui() or game:GetService("CoreGui")

    local guiFolder = GUI:FindFirstChild("GuiFolder") or Instance.new("Folder", GUI)
    guiFolder.Name = "GuiFolder"

    local screen = Instance.new("ScreenGui", guiFolder)
    screen.Name = "CustomWeaponModifyLib"
    screen.ResetOnSpawn = false
    -- ИСПРАВЛЕНИЕ 1: Принудительный глобальный режим слоев, чтобы ZIndex работал честно
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Global 
    _G.GUI_MAIN = screen

    -- Главный Фрейм
    local main = Instance.new("Frame", screen)
    main.Name = "MainFrame"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = UDim2.new(0, 520, 0, 580)
    main.BackgroundColor3 = Color3.fromRGB(15, 16, 18)
    main.Active = true
    main.ZIndex = 10
    
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(35, 38, 43)

    -- Скрипт Перетаскивания (Drag)
    local dragging, dragInput, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Хедер (Шапка)
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 65)
    header.BackgroundTransparency = 1
    header.ZIndex = 11

    local title = Instance.new("TextLabel", header)
    title.Position = UDim2.new(0, 20, 0, 15)
    title.Size = UDim2.new(0.5, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = titleText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 12

    local subtitle = Instance.new("TextLabel", header)
    subtitle.Position = UDim2.new(0, 20, 0, 38)
    subtitle.Size = UDim2.new(0.5, 0, 0, 18)
    subtitle.BackgroundTransparency = 1
    subtitle.TextColor3 = Color3.fromRGB(0, 162, 255)
    subtitle.Text = subtitleText
    subtitle.Font = Enum.Font.GothamSemibold
    subtitle.TextSize = 13
         subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 12

    -- Контейнер со скроллом
    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -10, 1, -80)
    scroll.Position = UDim2.new(0, 5, 0, 70)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(45, 48, 53)
    -- ИСПРАВЛЕНИЕ 2: Отключаем ClipsDescendants, чтобы элементы не исчезали при прокрутке ниже границ экрана!
    scroll.ClipsDescendants = false 
    scroll.ZIndex = 15

    local uiList = Instance.new("UIListLayout", scroll)
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Padding = UDim.new(0, 8)

    local uiPad = Instance.new("UIPadding", scroll)
    uiPad.PaddingLeft = UDim.new(0, 15)
    uiPad.PaddingRight = UDim.new(0, 15)
    uiPad.PaddingTop = UDim.new(0, 5)
    uiPad.PaddingBottom = UDim.new(0, 15)

    local function updateScroll()
        scroll.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 40)
    end
    uiList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScroll)

    -- Свернуть на Insert
    UIS.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.Insert then
            screen.Enabled = not screen.Enabled
        end
    end)

    local WindowObj = {Scroll = scroll, Screen = screen, Subtitle = subtitle}

    -- МЕТОД: Добавление TextBox (Поле ввода)
    function WindowObj:AddTextBox(parent, labelText, defaultText, callback)
        local targetParent = parent or scroll
        local item = Instance.new("Frame", targetParent)
        item.Size = UDim2.new(1, 0, 0, 38)
        item.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
        item.ZIndex = 20
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
        
        local p = Instance.new("UIPadding", item)
        p.PaddingLeft = UDim.new(0, 12)
        p.PaddingRight = UDim.new(0, 12)

        local lbl = Instance.new("TextLabel", item)
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamSemibold
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(160, 165, 175)
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 21

        local align = Instance.new("Frame", item)
        align.Size = UDim2.new(0.4, 0, 1, 0)
        align.Position = UDim2.new(0.6, 0, 0, 0)
        align.BackgroundTransparency = 1
        align.ZIndex = 21
        
        local al = Instance.new("UIListLayout", align)
        al.FillDirection = Enum.FillDirection.Horizontal
        al.HorizontalAlignment = Enum.HorizontalAlignment.Right
        al.VerticalAlignment = Enum.VerticalAlignment.Center

        local box = Instance.new("TextBox", align)
        box.Size = UDim2.new(0, 90, 0, 28)
        box.BackgroundColor3 = Color3.fromRGB(24, 26, 30)
        box.Font = Enum.Font.Code
        box.Text = tostring(defaultText)
        box.TextColor3 = Color3.fromRGB(130, 220, 110)
        box.TextSize = 12
        box.ClearTextOnFocus = false
        box.ZIndex = 22
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        
        local s = Instance.new("UIStroke", box)
        s.Color = Color3.fromRGB(38, 42, 48)

        box.Focused:Connect(function() TweenService:Create(s, TweenInfo.new(0.15), {Color = Color3.fromRGB(0, 162, 255)}):Play() end)
        box.FocusLost:Connect(function()
            TweenService:Create(s, TweenInfo.new(0.15), {Color = Color3.fromRGB(38, 42, 48)}):Play()
            callback(box.Text)
        end)
        updateScroll()
    end

    -- МЕТОД: Добавление Тоггла (ON/OFF)
    function WindowObj:AddToggle(parent, labelText, defaultState, callback)
        local targetParent = parent or scroll
        local item = Instance.new("Frame", targetParent)
        item.Size = UDim2.new(1, 0, 0, 38)
        item.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
        item.ZIndex = 20
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
        
        local p = Instance.new("UIPadding", item)
        p.PaddingLeft = UDim.new(0, 12)
        p.PaddingRight = UDim.new(0, 12)

        local lbl = Instance.new("TextLabel", item)
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamSemibold
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(160, 165, 175)
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 21

        local align = Instance.new("Frame", item)
        align.Size = UDim2.new(0.4, 0, 1, 0)
        align.Position = UDim2.new(0.6, 0, 0, 0)
        align.BackgroundTransparency = 1
        align.ZIndex = 21
        
        local al = Instance.new("UIListLayout", align)
        al.FillDirection = Enum.FillDirection.Horizontal
        al.HorizontalAlignment = Enum.HorizontalAlignment.Right
        al.VerticalAlignment = Enum.VerticalAlignment.Center

        local state = defaultState
        local toggle = Instance.new("TextButton", align)
        toggle.Size = UDim2.new(0, 60, 0, 26)
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 150, 90) or Color3.fromRGB(40, 43, 48)
        toggle.Text = state and "ON" or "OFF"
        toggle.Font = Enum.Font.GothamBold
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextSize = 11
        toggle.ZIndex = 22
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 13)

        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.Text = state and "ON" or "OFF"
            TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(0, 150, 90) or Color3.fromRGB(40, 43, 48)}):Play()
            callback(state)
        end)
        updateScroll()
    end

    -- МЕТОД: Добавление Дропдауна - ИСПРАВЛЕН КЛИК И ОТОБРАЖЕНИЕ
    function WindowObj:AddDropdown(parent, labelText, defaultOption, optionsList, callback)
        local targetParent = parent or scroll
        local item = Instance.new("Frame", targetParent)
        item.Size = UDim2.new(1, 0, 0, 38)
        item.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
        item.ZIndex = 20
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 6)
        
        local p = Instance.new("UIPadding", item)
		p.PaddingLeft = UDim.new(0, 12)
		p.PaddingRight = UDim.new(0, 12)

		local lbl = Instance.new("TextLabel", item)
		lbl.Size = UDim2.new(0.6, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.GothamSemibold
		lbl.Text = labelText
		lbl.TextColor3 = Color3.fromRGB(160, 165, 175)
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.ZIndex = 21

		local align = Instance.new("Frame", item)
		align.Size = UDim2.new(0.4, 0, 1, 0)
		align.Position = UDim2.new(0.6, 0, 0, 0)
		align.BackgroundTransparency = 1
		align.ZIndex = 21

		local al = Instance.new("UIListLayout", align)
		al.FillDirection = Enum.FillDirection.Horizontal
		al.HorizontalAlignment = Enum.HorizontalAlignment.Right
		al.VerticalAlignment = Enum.VerticalAlignment.Center

		local dropBtn = Instance.new("TextButton", align)
		dropBtn.Size = UDim2.new(0, 120, 0, 28)
		dropBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 30)
		dropBtn.Font = Enum.Font.GothamSemibold
		dropBtn.Text = tostring(defaultOption)
		dropBtn.TextColor3 = Color3.fromRGB(230, 235, 240)
		dropBtn.TextSize = 12
		dropBtn.ZIndex = 22
		Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 6)

		local s = Instance.new("UIStroke", dropBtn)
		s.Color = Color3.fromRGB(38, 42, 48)
		applyHover(s, Color3.fromRGB(0, 162, 255), Color3.fromRGB(38, 42, 48), "Color")

		-- ИСПРАВЛЕНИЕ 3: Выпадающий список создается строго ВНУТРИ главного окна, но с максимальным ZIndex
		local dropList = Instance.new("Frame", main)
		dropList.Name = "DropdownWindow"
		dropList.BackgroundColor3 = Color3.fromRGB(24, 26, 30)
		dropList.Size = UDim2.new(0, 120, 0, #optionsList * 28)
		dropList.Visible = false
		dropList.Active = true -- Заставляет UI блокировать клики под ним
		dropList.ZIndex = 1000 -- Гарантирует рендеринг поверх всех текстбоксов и карточек
		Instance.new("UICorner", dropList).CornerRadius = UDim.new(0, 6)
		Instance.new("UIStroke", dropList).Color = Color3.fromRGB(45, 50, 58)
		Instance.new("UIListLayout", dropList)

		for _, opt in ipairs(optionsList) do
			local oBtn = Instance.new("TextButton", dropList)
			oBtn.Size = UDim2.new(1, 0, 0, 28)
			oBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 30)
			oBtn.BackgroundTransparency = 1
			oBtn.Font = Enum.Font.Gotham
			oBtn.Text = opt
			oBtn.TextColor3 = Color3.fromRGB(0, 162, 255)
			oBtn.TextSize = 12
			oBtn.ZIndex = 1001 -- Кнопки выбора внутри списка теперь тоже поверх всего
			
			oBtn.MouseButton1Click:Connect(function()
				dropBtn.Text = opt
				dropList.Visible = false
				Library.ActiveDropdown = nil
				callback(opt)
			end)
			
			applyHover(oBtn, Color3.fromRGB(30, 33, 38), Color3.fromRGB(24, 26, 30), "BackgroundColor3")
			oBtn.MouseEnter:Connect(function() oBtn.BackgroundTransparency = 0 end)
			oBtn.MouseLeave:Connect(function() oBtn.BackgroundTransparency = 1 end)
		end

		-- Точный расчет позиции выпадающего списка относительно главного фрейма (Без багов скролла)
		local function positionateList()
			local relX = dropBtn.AbsolutePosition.X - main.AbsolutePosition.X
			local relY = dropBtn.AbsolutePosition.Y - main.AbsolutePosition.Y + dropBtn.AbsoluteSize.Y + 2
			dropList.Position = UDim2.new(0, relX, 0, relY)
		end

		dropBtn.MouseButton1Click:Connect(function()
			if Library.ActiveDropdown and Library.ActiveDropdown ~= dropList then
				Library.ActiveDropdown.Visible = false
			end
			positionateList()
			dropList.Visible = not dropList.Visible
			Library.ActiveDropdown = dropList.Visible and dropList or nil
		end)

		-- Обновляем координаты при перетаскивании меню
		main:GetPropertyChangedSignal("Position"):Connect(function()
			if dropList.Visible then 
				positionateList() 
			end
		end)

		updateScroll()
	end

	-- МЕТОД: Создание Категории / Табличного Блока
	function WindowObj:AddTableBlock(titleText)
		local categoryBox = Instance.new("Frame", scroll)
		categoryBox.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
		categoryBox.ZIndex = 20
		Instance.new("UICorner", categoryBox).CornerRadius = UDim.new(0, 8)
		Instance.new("UIStroke", categoryBox).Color = Color3.fromRGB(32, 35, 40)

		local catTitle = Instance.new("TextLabel", categoryBox)
		catTitle.Position = UDim2.new(0, 15, 0, 12)
		catTitle.Size = UDim2.new(1, -30, 0, 20)
		catTitle.BackgroundTransparency = 1
		catTitle.Font = Enum.Font.GothamBold
		catTitle.Text = string.upper(titleText)
		catTitle.TextColor3 = Color3.fromRGB(0, 162, 255)
		catTitle.TextSize = 11
		catTitle.TextXAlignment = Enum.TextXAlignment.Left
		catTitle.ZIndex = 21

		local subContainer = Instance.new("Frame", categoryBox)
		subContainer.Position = UDim2.new(0, 0, 0, 36)
		subContainer.Size = UDim2.new(1, 0, 0, 0)
		subContainer.AutomaticSize = Enum.AutomaticSize.Y
		subContainer.BackgroundTransparency = 1
		subContainer.ZIndex = 21

		local subList = Instance.new("UIListLayout", subContainer)
		subList.Padding = UDim.new(0, 4)

		local subPad = Instance.new("UIPadding", subContainer)
		subPad.PaddingLeft = UDim.new(0, 15)
		subPad.PaddingRight = UDim.new(0, 15)
		subPad.PaddingBottom = UDim.new(0, 12)

		local function resizeBlock()
			local items = 0
			for _, child in ipairs(subContainer:GetChildren()) do
				if child:IsA("Frame") then 
					items = items + 1 
				end
			end
			categoryBox.Size = UDim2.new(1, 0, 0, 44 + (items * 38))
			updateScroll()
		end
		subList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resizeBlock)

		local BlockObj = {}

		function BlockObj:AddRowTextBox(subKey, subValue, subCallback)
			local subItem = Instance.new("Frame", subContainer)
			subItem.Size = UDim2.new(1, 0, 0, 34)
			subItem.BackgroundTransparency = 1
			subItem.ZIndex = 25

			local slbl = Instance.new("TextLabel", subItem)
			slbl.Size = UDim2.new(0.6, 0, 1, 0)
			slbl.BackgroundTransparency = 1
			slbl.Font = Enum.Font.Gotham -- Исправлена опечатка шрифта
			slbl.Text = tostring(subKey)
			slbl.TextColor3 = Color3.fromRGB(170, 175, 185)
			slbl.TextSize = 13
			slbl.TextXAlignment = Enum.TextXAlignment.Left
			slbl.ZIndex = 26

			local sAlign = Instance.new("Frame", subItem)
			sAlign.Size = UDim2.new(0.4, 0, 1, 0)
			sAlign.Position = UDim2.new(0.6, 0, 0, 0)
			sAlign.BackgroundTransparency = 1
			sAlign.ZIndex = 26

			local slist = Instance.new("UIListLayout", sAlign)
			slist.FillDirection = Enum.FillDirection.Horizontal
			slist.HorizontalAlignment = Enum.HorizontalAlignment.Right
			slist.VerticalAlignment = Enum.VerticalAlignment.Center

			WindowObj:AddTextBox(sAlign, "", subValue, subCallback)

			local generatedFrame = sAlign:FindFirstChild("Frame")
			if generatedFrame then
				generatedFrame.BackgroundTransparency = 1
				generatedFrame.ZIndex = 27
				local generatedLabel = generatedFrame:FindFirstChild("TextLabel")
				if generatedLabel then 
					generatedLabel.Visible = false 
				end
				local textboxObj = generatedFrame:FindFirstChild("TextBox")
				if textboxObj then
					textboxObj.Size = UDim2.new(1, 0, 0, 28)
					textboxObj.ZIndex = 28
				end
			end
			resizeBlock()
		end

		return BlockObj
	end

	return WindowObj
end

-- Закрытие дропдаунов при клике в любую пустую область экрана
UIS.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and Library.ActiveDropdown then
		local mousePos = UIS:GetMouseLocation()
		local db = Library.ActiveDropdown
		if mousePos.X < db.AbsolutePosition.X or mousePos.X > (db.AbsolutePosition.X + db.AbsoluteSize.X) or
		   mousePos.Y < db.AbsolutePosition.Y or mousePos.Y > (db.AbsolutePosition.Y + db.AbsoluteSize.Y) then
			db.Visible = false
			Library.ActiveDropdown = nil
		end
	end
end)

return Library
