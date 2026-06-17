if _G.GUI_MAIN then
	_G.GUI_MAIN:Destroy()
end

local GUI = gethui and gethui() or game:GetService("CoreGui")

local guiFolder = GUI:FindFirstChild("GuiFolder")
if not guiFolder then
	guiFolder = Instance.new("Folder")
	guiFolder.Name = "GuiFolder"
	guiFolder.Parent = GUI
end

local weaponDataList = {
	{
		Name = "Assault Rifle",
		BurstAmount = 3,
		WeaponCategory = "Rifle",
		StartDamageDropOff = 60,
		Caliber = "Medium",
		FireRate = 650,
		MovingParts = { "Mag", "Mag2", "Bolt", "ChargingHandle" },
		Spread = 1,
		Damage = 14,
		CustomGrip = false,
		BulletsFired = 1,
		FireMode = "Auto",
		DamageMultipliers = { Other = 1, Head = 1.25 },
		ViewPunch = 2.5,
		ReloadAnimSpeed = 1,
		MaxDamageDropOff = 200,
		WeaponType = "Gun",
		Recoil = { Damping = 2, Vertical = 1.3, Speed = 20, Horizontal = 1.4, Punch = 1 }
	},
	{
		Name = "Pistol",
		BurstAmount = 3,
		WeaponCategory = "Pistol",
		StartDamageDropOff = 35,
		Caliber = "Light",
		FireRate = 425,
		MovingParts = { "Slide", "Mag", "Hammer" },
		Spread = 1.2,
		Damage = 12,
		CustomGrip = false,
		BulletsFired = 1,
		FireMode = "Semi",
		DamageMultipliers = { Other = 1, Head = 1.25 },
		ViewPunch = 1.2,
		ReloadAnimSpeed = 1,
		MaxDamageDropOff = 105,
		WeaponType = "Gun",
		Recoil = { Damping = 1.6, Vertical = 0.9, Speed = 16, Horizontal = 1.1, Punch = 0.8 }
	}
}

local function Create(className, props)
	local obj = Instance.new(className)
	for k, v in pairs(props or {}) do
		obj[k] = v
	end
	return obj
end

local function Corner(parent, radius)
	local c = Create("UICorner", { Parent = parent, CornerRadius = radius or UDim.new(0, 12) })
	return c
end

local function Stroke(parent, thickness, color, transparency)
	return Create("UIStroke", {
		Parent = parent,
		Thickness = thickness or 1,
		Color = color or Color3.fromRGB(80, 80, 90),
		Transparency = transparency or 0.2
	})
end

local function MakeLabel(parent, text, size, bold, alpha)
	return Create("TextLabel", {
		Parent = parent,
		BackgroundTransparency = 1,
		Text = text or "",
		Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextSize = size or 16,
		TextColor3 = Color3.fromRGB(245, 245, 245),
		TextTransparency = alpha or 0,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		BorderSizePixel = 0
	})
end

local function StatBar(parent, title, valueText, ratio)
	local row = Create("Frame", {
		Parent = parent,
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = Color3.fromRGB(42, 42, 50),
		BorderSizePixel = 0
	})
	Corner(row, UDim.new(0, 10))
	Stroke(row, 1, Color3.fromRGB(80, 80, 90), 0.55)

	local label = MakeLabel(row, title, 15, true)
	label.Position = UDim2.fromOffset(12, 5)
	label.Size = UDim2.new(1, -24, 0, 16)

	local value = MakeLabel(row, valueText, 13, false, 0.15)
	value.Position = UDim2.fromOffset(12, 20)
	value.Size = UDim2.new(1, -24, 0, 14)

	local barBack = Create("Frame", {
		Parent = row,
		Position = UDim2.fromOffset(12, 34),
		Size = UDim2.new(1, -24, 0, 4),
		BackgroundColor3 = Color3.fromRGB(58, 58, 66),
		BorderSizePixel = 0
	})
	Corner(barBack, UDim.new(1, 0))

	local barFill = Create("Frame", {
		Parent = barBack,
		Size = UDim2.new(math.clamp(ratio or 0, 0, 1), 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 120, 40),
		BorderSizePixel = 0
	})
	Corner(barFill, UDim.new(1, 0))

	return row
end

local screen = Create("ScreenGui", {
	Name = "WeaponModifyMenu",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	Parent = guiFolder
})

local shadow = Create("Frame", {
	Parent = screen,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(830, 560),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.7,
	BorderSizePixel = 0
})
Corner(shadow, UDim.new(0, 18))

local main = Create("Frame", {
	Parent = shadow,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(820, 550),
	BackgroundColor3 = Color3.fromRGB(28, 28, 34),
	BorderSizePixel = 0
})
Corner(main, UDim.new(0, 18))
Stroke(main, 1, Color3.fromRGB(85, 85, 98), 0.3)

local top = Create("Frame", {
	Parent = main,
	Size = UDim2.new(1, 0, 0, 64),
	BackgroundColor3 = Color3.fromRGB(36, 36, 42),
	BorderSizePixel = 0
})
Corner(top, UDim.new(0, 18))

local accent = Create("Frame", {
	Parent = top,
	Position = UDim2.new(0, 0, 1, -2),
	Size = UDim2.new(1, 0, 0, 2),
	BackgroundColor3 = Color3.fromRGB(255, 120, 40),
	BorderSizePixel = 0
})

local title = MakeLabel(top, "Weapon Modify Menu", 24, true)
title.Position = UDim2.fromOffset(18, 10)
title.Size = UDim2.new(1, -36, 0, 24)

local subtitle = MakeLabel(top, "Weapon statistics overview", 13, false, 0.35)
subtitle.Position = UDim2.fromOffset(18, 34)
subtitle.Size = UDim2.new(1, -36, 0, 16)

local leftPanel = Create("Frame", {
	Parent = main,
	Position = UDim2.fromOffset(16, 82),
	Size = UDim2.fromOffset(250, 452),
	BackgroundColor3 = Color3.fromRGB(35, 35, 41),
	BorderSizePixel = 0
})
Corner(leftPanel, UDim.new(0, 16))
Stroke(leftPanel, 1, Color3.fromRGB(80, 80, 92), 0.45)

local leftTitle = MakeLabel(leftPanel, "Weapons", 18, true)
leftTitle.Position = UDim2.fromOffset(14, 12)
leftTitle.Size = UDim2.new(1, -28, 0, 20)

local weaponList = Create("ScrollingFrame", {
	Parent = leftPanel,
	Position = UDim2.fromOffset(10, 42),
	Size = UDim2.new(1, -20, 1, -52),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 4,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y
})

local weaponLayout = Create("UIListLayout", {
	Parent = weaponList,
	Padding = UDim.new(0, 8)
})

local rightPanel = Create("Frame", {
	Parent = main,
	Position = UDim2.fromOffset(280, 82),
	Size = UDim2.fromOffset(524, 452),
	BackgroundColor3 = Color3.fromRGB(35, 35, 41),
	BorderSizePixel = 0
})
Corner(rightPanel, UDim.new(0, 16))
Stroke(rightPanel, 1, Color3.fromRGB(80, 80, 92), 0.45)

local infoTitle = MakeLabel(rightPanel, "Selected Weapon", 18, true)
infoTitle.Position = UDim2.fromOffset(14, 12)
infoTitle.Size = UDim2.new(1, -28, 0, 20)

local infoName = MakeLabel(rightPanel, "Assault Rifle", 26, true)
infoName.Position = UDim2.fromOffset(14, 38)
infoName.Size = UDim2.new(1, -28, 0, 28)

local infoCategory = MakeLabel(rightPanel, "Category: Rifle", 14, false, 0.2)
infoCategory.Position = UDim2.fromOffset(14, 66)
infoCategory.Size = UDim2.new(1, -28, 0, 16)

local statArea = Create("ScrollingFrame", {
	Parent = rightPanel,
	Position = UDim2.fromOffset(14, 98),
	Size = UDim2.new(1, -28, 0, 220),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 4,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y
})

local statLayout = Create("UIListLayout", {
	Parent = statArea,
	Padding = UDim.new(0, 8)
})

local detailsTitle = MakeLabel(rightPanel, "Details", 18, true)
detailsTitle.Position = UDim2.fromOffset(14, 330)
detailsTitle.Size = UDim2.new(1, -28, 0, 20)

local detailsBox = Create("Frame", {
	Parent = rightPanel,
	Position = UDim2.fromOffset(14, 356),
	Size = UDim2.new(1, -28, 0, 84),
	BackgroundColor3 = Color3.fromRGB(42, 42, 50),
	BorderSizePixel = 0
})
Corner(detailsBox, UDim.new(0, 12))
Stroke(detailsBox, 1, Color3.fromRGB(80, 80, 92), 0.55)

local movingPartsLabel = MakeLabel(detailsBox, "Moving Parts", 14, true)
movingPartsLabel.Position = UDim2.fromOffset(12, 10)
movingPartsLabel.Size = UDim2.new(1, -24, 0, 16)

local movingPartsValue = MakeLabel(detailsBox, "", 13, false, 0.1)
movingPartsValue.Position = UDim2.fromOffset(12, 30)
movingPartsValue.Size = UDim2.new(1, -24, 0, 18)

local recoilLabel = MakeLabel(detailsBox, "Recoil", 14, true)
recoilLabel.Position = UDim2.fromOffset(12, 50)
recoilLabel.Size = UDim2.new(1, -24, 0, 16)

local recoilValue = MakeLabel(detailsBox, "", 13, false, 0.1)
recoilValue.Position = UDim2.fromOffset(12, 68)
recoilValue.Size = UDim2.new(1, -24, 0, 14)

local selectedIndex = 1
local weaponButtons = {}

local function renderWeapon(weapon)
	infoName.Text = weapon.Name
	infoCategory.Text = "Category: " .. tostring(weapon.WeaponCategory)

	statArea:ClearAllChildren()
	Create("UIListLayout", {
		Parent = statArea,
		Padding = UDim.new(0, 8)
	})

	StatBar(statArea, "Damage", tostring(weapon.Damage), math.clamp(weapon.Damage / 25, 0, 1))
	StatBar(statArea, "Fire Rate", tostring(weapon.FireRate) .. " RPM", math.clamp(weapon.FireRate / 1000, 0, 1))
	StatBar(statArea, "Spread", tostring(weapon.Spread), 1 - math.clamp(weapon.Spread / 5, 0, 1))
	StatBar(statArea, "View Punch", tostring(weapon.ViewPunch), math.clamp(weapon.ViewPunch / 5, 0, 1))
	StatBar(statArea, "Reload Speed", tostring(weapon.ReloadAnimSpeed) .. "x", math.clamp(weapon.ReloadAnimSpeed / 2, 0, 1))
	StatBar(statArea, "Drop Off", tostring(weapon.StartDamageDropOff) .. " / " .. tostring(weapon.MaxDamageDropOff), math.clamp(weapon.StartDamageDropOff / math.max(weapon.MaxDamageDropOff, 1), 0, 1))

	local parts = table.concat(weapon.MovingParts or {}, ", ")
	movingPartsValue.Text = parts ~= "" and parts or "None"

	local recoil = weapon.Recoil or {}
	recoilValue.Text = string.format(
		"Damp %.1f | Vert %.1f | Speed %.1f | Horiz %.1f | Punch %.1f",
		recoil.Damping or 0,
		recoil.Vertical or 0,
		recoil.Speed or 0,
		recoil.Horizontal or 0,
		recoil.Punch or 0
	)
end

for i, weapon in ipairs(weaponDataList) do
	local btn = Create("TextButton", {
		Parent = weaponList,
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundColor3 = i == selectedIndex and Color3.fromRGB(255, 120, 40) or Color3.fromRGB(45, 45, 54),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false
	})
	Corner(btn, UDim.new(0, 12))
	Stroke(btn, 1, Color3.fromRGB(85, 85, 98), 0.55)

	local nameLabel = MakeLabel(btn, weapon.Name, 17, true, i == selectedIndex and 0.05 or 0)
	nameLabel.Position = UDim2.fromOffset(12, 6)
	nameLabel.Size = UDim2.new(1, -24, 0, 18)

	local modeLabel = MakeLabel(btn, weapon.FireMode .. " • " .. weapon.Caliber, 13, false, 0.25)
	modeLabel.Position = UDim2.fromOffset(12, 24)
	modeLabel.Size = UDim2.new(1, -24, 0, 16)

	btn.MouseButton1Click:Connect(function()
		selectedIndex = i
		for idx, b in ipairs(weaponButtons) do
			b.BackgroundColor3 = idx == selectedIndex and Color3.fromRGB(255, 120, 40) or Color3.fromRGB(45, 45, 54)
		end
		renderWeapon(weapon)
	end)

	table.insert(weaponButtons, btn)
end

renderWeapon(weaponDataList[selectedIndex])
_G.GUI_MAIN = screen
