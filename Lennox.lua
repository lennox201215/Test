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

-- WAIT UNTIL KEY IS CORRECT
repeat
	RunService.RenderStepped:Wait()
until accessGranted

-- ===========================
-- NEVERGAME MENU START
-- ===========================
-- VARIABLES
local espEnabled = false
local tracersEnabled = false
local flyEnabled = false
local flySpeed = 50
local keys = {}
local espBoxes = {}
local tracerLines = {}
local flyBV, flyBG

-- Remove old GUI if exists
local old = playerGui:FindFirstChild("NevergameGui")
if old then old:Destroy() end

-- GUI
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "NevergameGui"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0,500,0,360)
frame.Position = UDim2.new(0.5,-250,0.5,-180)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame)

-- DRAG
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

-- BUTTON HELPER
local function makeBtn(text,x,y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0,140,0,28)
	b.Position = UDim2.new(0,x,0,y)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(60,60,60)
	b.TextColor3 = Color3.new(1,1,1)
	return b
end

local espBtn = makeBtn("ESP: OFF",10,10)
local tracerBtn = makeBtn("TRACERS: OFF",160,10)
local flyBtn = makeBtn("FLY: OFF",310,10)

espBtn.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	espBtn.Text = "ESP: "..(espEnabled and "ON" or "OFF")
end)

tracerBtn.MouseButton1Click:Connect(function()
	tracersEnabled = not tracersEnabled
	tracerBtn.Text = "TRACERS: "..(tracersEnabled and "ON" or "OFF")
	if not tracersEnabled then
		for _,l in pairs(tracerLines) do pcall(function() l:Remove() end) end
		tracerLines = {}
	end
end)

flyBtn.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	flyBtn.Text = "FLY: "..(flyEnabled and "ON" or "OFF")
end)

-- CODE EXECUTOR
local codeBox = Instance.new("TextBox", frame)
codeBox.Size = UDim2.new(1,-20,0,100)
codeBox.Position = UDim2.new(0,10,0,50)
codeBox.PlaceholderText = "Paste Lua / loadstring / URL here..."
codeBox.TextWrapped = true
codeBox.ClearTextOnFocus = false
codeBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
codeBox.TextColor3 = Color3.new(1,1,1)
codeBox.TextYAlignment = Enum.TextYAlignment.Top

local runBtn = makeBtn("RUN CODE",10,160)

runBtn.MouseButton1Click:Connect(function()
	local src = codeBox.Text
	if not src or src == "" then return end
	pcall(function()
		if src:sub(1,4) == "http" then
			loadstring(game:HttpGet(src))()
		elseif src:find("loadstring") then
			loadstring(src)()
		else
			loadstring(src)()
		end
	end)
end)

-- INPUT HANDLING
UserInputService.InputBegan:Connect(function(i,gp)
	if not gp then keys[i.KeyCode]=true end
end)
UserInputService.InputEnded:Connect(function(i)
	keys[i.KeyCode]=false
end)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
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

	-- TRACERS
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

	-- FLY
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
end)
