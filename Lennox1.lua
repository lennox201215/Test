local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Status
local BOX_ON = true
local SKELETON_ON = false
local AIM_ON = false

local Boxes = {}
local Skeletons = {}

-------------------------------------------------
-- GUI
-------------------------------------------------
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 230)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local function makeButton(text, y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(1,-20,0,40)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = text
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(50,50,50)
	b.TextColor3 = Color3.fromRGB(255,255,255)
	return b
end

local boxBtn = makeButton("Box ESP: ON", 10)
local skelBtn = makeButton("Skeleton ESP: OFF", 60)
local aimBtn = makeButton("Aim Assist: OFF", 110)

-------------------------------------------------
-- BOX ESP
-------------------------------------------------
local function addBox(player)
	if Boxes[player] or not player.Character then return end
	local box = Instance.new("SelectionBox")
	box.Adornee = player.Character
	box.LineThickness = 0.05
	box.Color3 = Color3.fromRGB(255,0,0)
	box.Parent = player.Character
	Boxes[player] = box
end

local function removeBox(player)
	if Boxes[player] then
		Boxes[player]:Destroy()
		Boxes[player] = nil
	end
end

-------------------------------------------------
-- SKELETON ESP (mit Beams)
-------------------------------------------------
local function makeBeam(p0, p1, parent)
	local a0 = Instance.new("Attachment", p0)
	local a1 = Instance.new("Attachment", p1)
	local beam = Instance.new("Beam", parent)
	beam.Attachment0 = a0
	beam.Attachment1 = a1
	beam.Width0 = 0.05
	beam.Width1 = 0.05
	beam.Color = ColorSequence.new(Color3.fromRGB(0,255,0))
	return {beam, a0, a1}
end

local function addSkeleton(player)
	if Skeletons[player] or not player.Character then return end
	local c = player.Character
	if not c:FindFirstChild("Humanoid") then return end

	local parts = {
		{"Head","UpperTorso"},
		{"UpperTorso","LowerTorso"},
		{"UpperTorso","LeftUpperArm"},
		{"LeftUpperArm","LeftLowerArm"},
		{"UpperTorso","RightUpperArm"},
		{"RightUpperArm","RightLowerArm"},
		{"LowerTorso","LeftUpperLeg"},
		{"LeftUpperLeg","LeftLowerLeg"},
		{"LowerTorso","RightUpperLeg"},
		{"RightUpperLeg","RightLowerLeg"},
	}

	local list = {}
	for _, pair in pairs(parts) do
		if c:FindFirstChild(pair[1]) and c:FindFirstChild(pair[2]) then
			table.insert(list, makeBeam(c[pair[1]], c[pair[2]], c))
		end
	end
	Skeletons[player] = list
end

local function removeSkeleton(player)
	if Skeletons[player] then
		for _, objs in pairs(Skeletons[player]) do
			for _, o in pairs(objs) do
				if o then o:Destroy() end
			end
		end
		Skeletons[player] = nil
	end
end

-------------------------------------------------
-- Refresh
-------------------------------------------------
local function refreshAll()
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			if BOX_ON then addBox(p) else removeBox(p) end
			if SKELETON_ON then addSkeleton(p) else removeSkeleton(p) end
		end
	end
end

-------------------------------------------------
-- Aim Assist
-------------------------------------------------
local function getClosestTarget()
	local best, dist = nil, 300
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
			local h = p.Character.Head
			local d = (Camera.CFrame.Position - h.Position).Magnitude
			if d < dist then
				dist = d
				best = h
			end
		end
	end
	return best
end

RunService.RenderStepped:Connect(function()
	if not AIM_ON then return end
	local t = getClosestTarget()
	if t then
		local pos = Camera.CFrame.Position
		Camera.CFrame = CFrame.new(pos, t.Position)
	end
end)

-------------------------------------------------
-- Buttons
-------------------------------------------------
boxBtn.MouseButton1Click:Connect(function()
	BOX_ON = not BOX_ON
	boxBtn.Text = BOX_ON and "Box ESP: ON" or "Box ESP: OFF"
	refreshAll()
end)

skelBtn.MouseButton1Click:Connect(function()
	SKELETON_ON = not SKELETON_ON
	skelBtn.Text = SKELETON_ON and "Skeleton ESP: ON" or "Skeleton ESP: OFF"
	refreshAll()
end)

aimBtn.MouseButton1Click:Connect(function()
	AIM_ON = not AIM_ON
	aimBtn.Text = AIM_ON and "Aim Assist: ON" or "Aim Assist: OFF"
end)

-------------------------------------------------
-- Spieler Setup
-------------------------------------------------
local function setupPlayer(player)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		refreshAll()
	end)
end

for _, p in pairs(Players:GetPlayers()) do
	setupPlayer(p)
end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(p)
	removeBox(p)
	removeSkeleton(p)
end)
