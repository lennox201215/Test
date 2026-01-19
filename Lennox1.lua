local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ESP_ENABLED = true
local ESPObjects = {}

-- GUI erstellen
local gui = Instance.new("ScreenGui")
gui.Name = "ESP_GUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0, 20, 0, 20)
button.Text = "ESP: ON"
button.TextScaled = true
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.fromRGB(255, 0, 0)
button.Parent = gui

-- ESP hinzufügen
local function addESP(character, player)
	if not ESP_ENABLED then return end
	if ESPObjects[player] then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESP_Highlight"
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 0
	highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.Parent = character

	ESPObjects[player] = highlight
end

-- ESP entfernen
local function removeESP(player)
	if ESPObjects[player] then
		ESPObjects[player]:Destroy()
		ESPObjects[player] = nil
	end
end

-- Spieler-Setup
local function setupPlayer(player)
	player.CharacterAdded:Connect(function(char)
		task.wait(1)
		if player ~= LocalPlayer then
			addESP(char, player)
		end
	end)

	if player.Character and player ~= LocalPlayer then
		addESP(player.Character, player)
	end
end

-- Button Logik
button.MouseButton1Click:Connect(function()
	ESP_ENABLED = not ESP_ENABLED
	if ESP_ENABLED then
		button.Text = "ESP: ON"
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				addESP(p.Character, p)
			end
		end
	else
		button.Text = "ESP: OFF"
		for p, _ in pairs(ESPObjects) do
			removeESP(p)
		end
	end
end)

-- Aktive Spieler
for _, player in pairs(Players:GetPlayers()) do
	setupPlayer(player)
end

-- Neue Spieler
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removeESP)
