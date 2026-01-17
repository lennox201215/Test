-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===========================
-- KEY SYSTEM
-- ===========================
local correctKey = "Nevergame"

local keyGui = Instance.new("ScreenGui", playerGui)
keyGui.Name = "NevergameKeyGui"

local frame = Instance.new("Frame", keyGui)
frame.Size = UDim2.new(0,300,0,150)
frame.Position = UDim2.new(0.5,-150,0.5,-75)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame)

local label = Instance.new("TextLabel", frame)
label.Size = UDim2.new(1,0,0,50)
label.Position = UDim2.new(0,0,0,10)
label.Text = "Enter Key:"
label.TextColor3 = Color3.new(1,1,1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextSize = 20

local keyBox = Instance.new("TextBox", frame)
keyBox.Size = UDim2.new(0.8,0,0,30)
keyBox.Position = UDim2.new(0.1,0,0,70)
keyBox.PlaceholderText = "Enter key here..."
keyBox.TextColor3 = Color3.new(1,1,1)
keyBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
keyBox.ClearTextOnFocus = true

local submitBtn = Instance.new("TextButton", frame)
submitBtn.Size = UDim2.new(0.6,0,0,30)
submitBtn.Position = UDim2.new(0.2,0,0,110)
submitBtn.Text = "Submit"
submitBtn.TextColor3 = Color3.new(1,1,1)
submitBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)

local accessGranted = false
submitBtn.MouseButton1Click:Connect(function()
	if keyBox.Text == correctKey then
		accessGranted = true
		keyGui:Destroy()
	else
		label.Text = "Wrong Key!"
	end
end)

repeat
	RunService.RenderStepped:Wait()
until accessGranted

-- ===========================
-- NEVERGAME MENU
-- ===========================
local espEnabled = false
local tracersEnabled = false
local flyEnabled = false
local flySpeed = 50
local spinbotEnabled = false
local spinbotSpeed = 360 -- Grad pro Sekunde
local keys = {}
local espBoxes = {}
local tracerLines = {}
local flyBV, flyBG

-- Remove old GUI
local old = playerGui:FindFirstChild("NevergameGui")
if old then old:Destroy() end

-- Main GUI
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "NevergameGui"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0,520,0,400)
frame.Position = UDim2.new(0.5,-260,0.5,-200)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame)

-- Drag
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = frame.Position
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = i.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ===========================
-- TABS
-- ===========================
local tabNames = {"ESP","Tracers","Fly","Spinbot","Run Code"}
local tabFrames = {}
local buttonY = 10

for i, name in ipairs(tabNames) do
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(0,100,0,28)
	btn.Position = UDim2.new(0, 10 + (i-1)*105, 0, buttonY)
	btn.Text = name
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)

	local tabFrame = Instance.new("Frame", frame)
	tabFrame.Size = UDim2.new(1,-20,1,-50)
	tabFrame.Position = UDim2.new(0,10,0,50)
	tabFrame.BackgroundTransparency = 1
	tabFrame.Visible = (i==1) -- only first tab visible
	tabFrames[name] = tabFrame

	btn.MouseButton1Click:Connect(function()
		for k,f in pairs(tabFrames) do f.Visible = false end
		tabFrame.Visible = true
	end)
end

-- ===========================
-- ESP TAB
-- ===========================
local espTab = tabFrames["ESP"]
local espToggle = Instance.new("TextButton", espTab)
espToggle.Size = UDim2.new(0,140,0,28)
espToggle.Position = UDim2.new(0,10,0,10)
espToggle.Text = "ESP: OFF"
espToggle.BackgroundColor3 = Color3.fromRGB(70,0,0)
espToggle.TextColor3 = Color3.new(1,1,1)
espToggle.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espToggle.Text = "ESP: "..(espEnabled and "ON" or "OFF")
end)

-- ===========================
-- TRACERS TAB
-- ===========================
local tracerTab = tabFrames["Tracers"]
local tracerToggle = Instance.new("TextButton", tracerTab)
tracerToggle.Size = UDim2.new(0,140,0,28)
tracerToggle.Position = UDim2.new(0,10,0,10)
tracerToggle.Text = "Tracers: OFF"
tracerToggle.BackgroundColor3 = Color3.fromRGB(0,70,0)
tracerToggle.TextColor3 = Color3.new(1,1,1)
tracerToggle.MouseButton1Click:Connect(function()
	tracersEnabled = not tracersEnabled
	tracerToggle.Text = "Tracers: "..(tracersEnabled and "ON" or "OFF")
	if not tracersEnabled then
		for _,l in pairs(tracerLines) do pcall(function() l:Remove() end) end
		tracerLines = {}
	end
end)

-- ===========================
-- FLY TAB
-- ===========================
local flyTab = tabFrames["Fly"]
local flyToggle = Instance.new("TextButton", flyTab)
flyToggle.Size = UDim2.new(0,140,0,28)
flyToggle.Position = UDim2.new(0,10,0,10)
flyToggle.Text = "Fly: OFF"
flyToggle.BackgroundColor3 = Color3.fromRGB(0,0,70)
flyToggle.TextColor3 = Color3.new(1,1,1)
flyToggle.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	flyToggle.Text = "Fly: "..(flyEnabled and "ON" or "OFF")
end)

local flySpeedBox = Instance.new("TextBox", flyTab)
flySpeedBox.Size = UDim2.new(0,100,0,28)
flySpeedBox.Position = UDim2.new(0,160,0,10)
flySpeedBox.PlaceholderText = tostring(flySpeed)
flySpeedBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
flySpeedBox.TextColor3 = Color3.new(1,1,1)
flySpeedBox.FocusLost:Connect(function()
	local val = tonumber(flySpeedBox.Text)
	if val then flySpeed = math.clamp(val,5,500) end
end)

-- ===========================
-- SPINBOT TAB
-- ===========================
local spinTab = tabFrames["Spinbot"]
local spinToggle = Instance.new("TextButton", spinTab)
spinToggle.Size = UDim2.new(0,140,0,28)
spinToggle.Position = UDim2.new(0,10,0,10)
spinToggle.Text = "Spinbot: OFF"
spinToggle.BackgroundColor3 = Color3.fromRGB(150,0,150)
spinToggle.TextColor3 = Color3.new(1,1,1)
spinToggle.MouseButton1Click:Connect(function()
	spinbotEnabled = not spinbotEnabled
	spinToggle.Text = "Spinbot: "..(spinbotEnabled and "ON" or "OFF")
end)

local spinSpeedBox = Instance.new("TextBox", spinTab)
spinSpeedBox.Size = UDim2.new(0,100,0,28)
spinSpeedBox.Position = UDim2.new(0,160,0,10)
spinSpeedBox.PlaceholderText = tostring(spinbotSpeed)
spinSpeedBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
spinSpeedBox.TextColor3 = Color3.new(1,1,1)
spinSpeedBox.FocusLost:Connect(function()
	local val = tonumber(spinSpeedBox.Text)
	if val then spinbotSpeed = math.clamp(val,10,2000) end
end)

-- ===========================
-- RUN CODE TAB
-- ===========================
local runTab = tabFrames["Run Code"]
local codeBox = Instance.new("TextBox", runTab)
codeBox.Size = UDim2.new(1,-20,0,100)
codeBox.Position = UDim2.new(0,10,0,10)
codeBox.PlaceholderText = "Paste Lua / loadstring / URL here..."
codeBox.TextWrapped = true
codeBox.ClearTextOnFocus = false
codeBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
codeBox.TextColor3 = Color3.new(1,1,1)
codeBox.TextYAlignment = Enum.TextYAlignment.Top

-- INJECT Button (Pop-up)
local injectBtn = Instance.new("TextButton", runTab)
injectBtn.Size = UDim2.new(0,140,0,28)
injectBtn.Position = UDim2.new(0,10,0,120)
injectBtn.Text = "INJECT"
injectBtn.BackgroundColor3 = Color3.fromRGB(70,70,0)
injectBtn.TextColor3 = Color3.new(1,1,1)
injectBtn.MouseButton1Click:Connect(function()
	local popup = Instance.new("Frame", screenGui)
	popup.Size = UDim2.new(0,200,0,100)
	popup.Position = UDim2.new(0.5,-100,0.5,-50)
	popup.BackgroundColor3 = Color3.fromRGB(30,30,30)
	popup.BorderSizePixel = 0
	Instance.new("UICorner", popup)
	local lbl = Instance.new("TextLabel", popup)
	lbl.Size = UDim2.new(1,0,1,0)
	lbl.Position = UDim2.new(0,0,0,0)
	lbl.BackgroundTransparency = 1
	lbl.Text = "Injected!"
	lbl.TextColor3 = Color3.fromRGB(0,255,0)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 24
	delay(2,function() popup:Destroy() end)
end)

-- RUN CODE Button
local runBtn = Instance.new("TextButton", runTab)
runBtn.Size = UDim2.new(0,140,0,28)
runBtn.Position = UDim2.new(0,160,0,120)
runBtn.Text = "RUN CODE"
runBtn.BackgroundColor3 = Color3.fromRGB(0,70,70)
runBtn.TextColor3 = Color3.new(1,1,1)
runBtn.MouseButton1Click:Connect(function()
	local src = codeBox.Text
	if not src or src == "" then return end
	pcall(function()
		if src:sub(1,4) == "http" then
			loadstring(game:HttpGet(src))()
		else
			loadstring(src)()
		end
	end)
end)

-- ===========================
-- INPUT HANDLING
-- ===========================
UserInputService.InputBegan:Connect(function(i,gp)
	if not gp then keys[i.KeyCode]=true end
end)
UserInputService.InputEnded:Connect(function(i)
	keys[i.KeyCode]=false
end)

-- ===========================
-- MAIN LOOP
-- ===========================
RunService.RenderStepped:Connect(function(deltaTime)
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")

	-- ESP
	if espEnabled then
		for _,plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				local boxes = espBoxes[plr] or {}
				for _,p in pairs(plr.Character:GetChildren()) do
					if p:IsA("BasePart") then
						if not boxes[p] then
							local box = Instance.new("BoxHandleAdornment", p)
							box.Adornee = p
							box.Size = p.Size
							box.Color3 = Color3.fromRGB(255,0,0)
							box.Transparency = 0.5
							box.AlwaysOnTop = true
							boxes[p] = box
						end
					end
				end
				espBoxes[plr] = boxes
			end
		end
	end

	-- Tracers
	if tracersEnabled and Drawing then
		local cam = workspace.CurrentCamera
		for _,plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local hrp2 = plr.Character.HumanoidRootPart
				local pos,onscreen = cam:WorldToViewportPoint(hrp2.Position)
				if onscreen then
					local line = tracerLines[plr]
					if not line then
						line = Drawing.new("Line")
						line.Thickness = 1
						line.Color = Color3.fromRGB(255,0,0)
						tracerLines[plr] = line
					end
					line.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y)
					line.To = Vector2.new(pos.X,pos.Y)
					line.Visible = true
				end
			end
		end
	end

	-- Fly
	if flyEnabled and hrp and hum then
		hum.PlatformStand = true
		if not flyBV then
			flyBV = Instance.new("BodyVelocity", hrp)
			flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
			flyBG = Instance.new("BodyGyro", hrp)
			flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
		end
		local cam = workspace.CurrentCamera.CFrame
		local move = Vector3.new()
		if keys[Enum.KeyCode.W] then move = move + cam.LookVector end
		if keys[Enum.KeyCode.S] then move = move - cam.LookVector end
		if keys[Enum.KeyCode.A] then move = move - cam.RightVector end
		if keys[Enum.KeyCode.D] then move = move + cam.RightVector end
		if keys[Enum.KeyCode.Space] then move = move + Vector3.new(0,1,0) end
		if keys[Enum.KeyCode.LeftShift] then move = move - Vector3.new(0,1,0) end
		flyBV.Velocity = move.Magnitude>0 and move.Unit*flySpeed or Vector3.new()
		flyBG.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.LookVector)
	elseif flyBV then
		flyBV:Destroy() flyBV=nil
		if flyBG then flyBG:Destroy() flyBG=nil end
		if hum then hum.PlatformStand=false end
	end

	-- Spinbot
	if spinbotEnabled and hrp then
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinbotSpeed)*deltaTime, 0)
	end
end)
