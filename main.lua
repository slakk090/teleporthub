-- =================================
-- TELEPORT HUB (SOLARA)
-- =================================

-- Serviços
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- Character utils
local function getChar()
	return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
	return getChar():WaitForChild("HumanoidRootPart")
end

-- =================================
-- FILE SYSTEM (workspace)
-- =================================
local ROOT = "workspace"
local FOLDER = ROOT .. "/TeleportHub"
local FILE = FOLDER .. "/teleports.json"

if not (writefile and readfile and isfile and isfolder and makefolder) then
	warn("Executor não suporta arquivos")
	return
end

if not isfolder(ROOT) then makefolder(ROOT) end
if not isfolder(FOLDER) then makefolder(FOLDER) end

-- =================================
-- DATA
-- =================================
local Teleports = {}
local SelectedTeleport = nil

local function loadTeleports()
	if isfile(FILE) then
		local ok, data = pcall(function()
			return HttpService:JSONDecode(readfile(FILE))
		end)
		if ok then Teleports = data end
	end
end

local function saveTeleports()
	writefile(FILE, HttpService:JSONEncode(Teleports))
end

loadTeleports()

-- =================================
-- TELEPORT (ANTI BUG)
-- =================================
local function teleport(cf)
	getHRP().CFrame = cf
end

-- =================================
-- GUI
-- =================================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

-- Toggle
local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.fromOffset(50,50)
toggle.Position = UDim2.new(0,10,0.5,-25)
toggle.Text = "OPEN"

-- Main
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromOffset(320,360)
main.Position = UDim2.new(0,70,0.5,-180)
main.Visible = false
main.Active = true
main.Draggable = true

-- Tabs
local tabTeleport = Instance.new("TextButton", main)
tabTeleport.Text = "TELEPORT"
tabTeleport.Size = UDim2.new(0.5,0,0,40)

local tabManage = Instance.new("TextButton", main)
tabManage.Text = "GERENCIAR"
tabManage.Position = UDim2.new(0.5,0,0,0)
tabManage.Size = UDim2.new(0.5,0,0,40)

-- Containers
local teleportFrame = Instance.new("Frame", main)
teleportFrame.Position = UDim2.new(0,0,0,40)
teleportFrame.Size = UDim2.new(1,0,1,-40)

local manageFrame = teleportFrame:Clone()
manageFrame.Parent = main
manageFrame.Visible = false

-- List
local list = Instance.new("UIListLayout", teleportFrame)
list.Padding = UDim.new(0,5)

local function refreshList()
	for _, v in ipairs(teleportFrame:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end

	for i, tp in ipairs(Teleports) do
		local btn = Instance.new("TextButton", teleportFrame)
		btn.Size = UDim2.new(1,-10,0,35)
		btn.Text = tp.nome
		btn.MouseButton1Click:Connect(function()
			SelectedTeleport = i
			teleport(CFrame.new(unpack(tp.cf)))
		end)
	end
end

refreshList()

-- Manage UI
local nameBox = Instance.new("TextBox", manageFrame)
nameBox.PlaceholderText = "Nome do local"
nameBox.Size = UDim2.new(1,-20,0,30)
nameBox.Position = UDim2.new(0,10,0,20)

local saveBtn = Instance.new("TextButton", manageFrame)
saveBtn.Text = "Salvar Local"
saveBtn.Size = UDim2.new(1,-20,0,30)
saveBtn.Position = UDim2.new(0,10,0,60)

local delBtn = Instance.new("TextButton", manageFrame)
delBtn.Text = "Excluir Selecionado"
delBtn.Size = UDim2.new(1,-20,0,30)
delBtn.Position = UDim2.new(0,10,0,100)

saveBtn.MouseButton1Click:Connect(function()
	if nameBox.Text ~= "" then
		table.insert(Teleports,{
			nome = nameBox.Text,
			cf = {getHRP().CFrame:GetComponents()}
		})
		nameBox.Text = ""
		saveTeleports()
		refreshList()
	end
end)

delBtn.MouseButton1Click:Connect(function()
	if SelectedTeleport then
		table.remove(Teleports, SelectedTeleport)
		SelectedTeleport = nil
		saveTeleports()
		refreshList()
	end
end)

-- Tabs logic
tabTeleport.MouseButton1Click:Connect(function()
	teleportFrame.Visible = true
	manageFrame.Visible = false
end)

tabManage.MouseButton1Click:Connect(function()
	teleportFrame.Visible = false
	manageFrame.Visible = true
end)

toggle.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
	toggle.Text = main.Visible and "CLOSE" or "OPEN"
end)
