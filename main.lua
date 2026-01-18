-- =================================
-- TELEPORT HUB + LOADER + CONFIG
-- =================================

if _G.TeleportHubLoaded then return end
_G.TeleportHubLoaded = true

-- =========================
-- SERVICES
-- =========================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- =========================
-- FILE SYSTEM
-- =========================
local ROOT = "workspace"
local FOLDER = ROOT .. "/TeleportHub"
local TELEPORT_FILE = FOLDER .. "/teleports.json"
local CONFIG_FILE = FOLDER .. "/config.json"

if not (writefile and readfile and isfile and isfolder and makefolder) then
	warn("Executor não suporta arquivos")
	return
end

if not isfolder(ROOT) then makefolder(ROOT) end
if not isfolder(FOLDER) then makefolder(FOLDER) end

-- =========================
-- CONFIG
-- =========================
local Config = {
	ToggleKey = "RightShift"
}

if isfile(CONFIG_FILE) then
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(CONFIG_FILE))
	end)
	if ok and data.ToggleKey then
		Config.ToggleKey = data.ToggleKey
	end
end

local function saveConfig()
	writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
end

-- =========================
-- UTILS
-- =========================
local function getChar()
	return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
	return getChar():WaitForChild("HumanoidRootPart")
end

-- =========================
-- LOADER UI
-- =========================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "TeleportHubGui"
gui.ResetOnSpawn = false

local loader = Instance.new("Frame", gui)
loader.Size = UDim2.fromOffset(300,150)
loader.Position = UDim2.new(0.5,-150,0.5,-75)
loader.BackgroundColor3 = Color3.fromRGB(20,20,20)
Instance.new("UICorner", loader).CornerRadius = UDim.new(0,14)

local title = Instance.new("TextLabel", loader)
title.Size = UDim2.new(1,0,0,50)
title.Text = "Teleport Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

local status = Instance.new("TextLabel", loader)
status.Position = UDim2.new(0,0,0,60)
status.Size = UDim2.new(1,0,0,40)
status.Text = "Loading..."
status.Font = Enum.Font.Gotham
status.TextColor3 = Color3.fromRGB(180,180,180)
status.BackgroundTransparency = 1

task.wait(1.5)
status.Text = "Ready!"
task.wait(0.6)
loader:Destroy()

-- =========================
-- MAIN HUB
-- =========================
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(360,380)
main.Position = UDim2.new(0.5,-180,0.5,-190)
main.Visible = false
main.Active = true
main.Draggable = true
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

-- =========================
-- TOGGLE BUTTON
-- =========================
local floating = Instance.new("TextButton", gui)
floating.Size = UDim2.fromOffset(50,50)
floating.Position = UDim2.new(0,10,0.5,-25)
floating.Text = "OPEN"
floating.Font = Enum.Font.GothamBold
floating.TextScaled = true
floating.BackgroundColor3 = Color3.fromRGB(40,40,40)
floating.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", floating).CornerRadius = UDim.new(1,0)

local function toggleHub()
	main.Visible = not main.Visible
	floating.Text = main.Visible and "CLOSE" or "OPEN"
end

floating.MouseButton1Click:Connect(toggleHub)

-- =========================
-- KEYBIND
-- =========================
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode.Name == Config.ToggleKey then
		toggleHub()
	end
end)

-- =========================
-- TABS
-- =========================
local tabTeleport = Instance.new("TextButton", main)
tabTeleport.Text = "TELEPORT"
tabTeleport.Size = UDim2.new(0.5,0,0,40)

local tabConfig = Instance.new("TextButton", main)
tabConfig.Text = "CONFIG"
tabConfig.Position = UDim2.new(0.5,0,0,0)
tabConfig.Size = UDim2.new(0.5,0,0,40)

local teleportTab = Instance.new("Frame", main)
teleportTab.Position = UDim2.new(0,0,0,40)
teleportTab.Size = UDim2.new(1,0,1,-40)

local configTab = teleportTab:Clone()
configTab.Parent = main
configTab.Visible = false

-- =========================
-- CONFIG TAB CONTENT
-- =========================
local keyLabel = Instance.new("TextLabel", configTab)
keyLabel.Text = "Tecla para abrir o menu:"
keyLabel.Position = UDim2.new(0,20,0,40)
keyLabel.Size = UDim2.new(1,-40,0,30)
keyLabel.TextColor3 = Color3.new(1,1,1)
keyLabel.BackgroundTransparency = 1
keyLabel.Font = Enum.Font.Gotham

local keyButton = Instance.new("TextButton", configTab)
keyButton.Text = Config.ToggleKey
keyButton.Position = UDim2.new(0,20,0,80)
keyButton.Size = UDim2.new(1,-40,0,35)
keyButton.Font = Enum.Font.GothamBold
keyButton.TextColor3 = Color3.new(1,1,1)
keyButton.BackgroundColor3 = Color3.fromRGB(45,45,45)
Instance.new("UICorner", keyButton).CornerRadius = UDim.new(0,8)

keyButton.MouseButton1Click:Connect(function()
	keyButton.Text = "Pressione uma tecla..."
	local conn
	conn = UIS.InputBegan:Connect(function(input)
		if input.KeyCode ~= Enum.KeyCode.Unknown then
			Config.ToggleKey = input.KeyCode.Name
			keyButton.Text = Config.ToggleKey
			saveConfig()
			conn:Disconnect()
		end
	end)
end)

-- =========================
-- TAB SWITCH
-- =========================
tabTeleport.MouseButton1Click:Connect(function()
	teleportTab.Visible = true
	configTab.Visible = false
end)

tabConfig.MouseButton1Click:Connect(function()
	teleportTab.Visible = false
	configTab.Visible = true
end)
