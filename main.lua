-- Teleport Script Simples (Solara)
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local function getChar()
	return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
	return getChar():WaitForChild("HumanoidRootPart")
end

-- =========================
-- ARQUIVOS
-- =========================
local folder = "TeleportHub"
local filename = folder .. "/teleports.json"

if not (writefile and readfile and isfile and isfolder and makefolder) then
	warn("Executor não suporta arquivos")
	return
end

if not isfolder(folder) then
	makefolder(folder)
end

-- =========================
-- LOCAIS
-- =========================
local locais = {}

if isfile(filename) then
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(filename))
	end)

	if ok and type(data) == "table" then
		for _, v in ipairs(data) do
			table.insert(locais, {
				nome = v.nome,
				cf = CFrame.new(unpack(v.cf))
			})
		end
	end
end

local function salvar()
	local data = {}

	for _, v in ipairs(locais) do
		table.insert(data, {
			nome = v.nome,
			cf = { v.cf:GetComponents() }
		})
	end

	writefile(filename, HttpService:JSONEncode(data))
end

-- =========================
-- TELEPORTE
-- =========================
local function teleport(cf)
	getHRP().CFrame = cf
end

-- =========================
-- GUI
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "TeleportGui"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- Botão OPEN
local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0, 50, 0, 50)
toggle.Position = UDim2.new(0, 10, 0.5, -25)
toggle.Text = "OPEN"
toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.GothamBold
toggle.TextScaled = true
Instance.new("UICorner", toggle).CornerRadius = UDim.new(1,0)

-- Janela
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 260, 0, 360)
main.Position = UDim2.new(0, 70, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Visible = false
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

-- Lista
local lista = Instance.new("ScrollingFrame", main)
lista.Size = UDim2.new(1,-20,1,-120)
lista.Position = UDim2.new(0,10,0,10)
lista.ScrollBarThickness = 4
lista.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", lista)
layout.Padding = UDim.new(0,5)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	lista.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 5)
end)

local function criarBotao(localData)
	local btn = Instance.new("TextButton", lista)
	btn.Size = UDim2.new(1,0,0,40)
	btn.Text = localData.nome
	btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

	btn.MouseButton1Click:Connect(function()
		teleport(localData.cf)
	end)
end

for _, v in ipairs(locais) do
	criarBotao(v)
end

-- Salvar local
local salvarBtn = Instance.new("TextButton", main)
salvarBtn.Size = UDim2.new(1,-20,0,35)
salvarBtn.Position = UDim2.new(0,10,1,-45)
salvarBtn.Text = "Salvar posição"
salvarBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
salvarBtn.TextColor3 = Color3.new(1,1,1)
salvarBtn.Font = Enum.Font.GothamBold
salvarBtn.TextScaled = true
Instance.new("UICorner", salvarBtn).CornerRadius = UDim.new(0,8)

salvarBtn.MouseButton1Click:Connect(function()
	local novo = {
		nome = "Local " .. (#locais + 1),
		cf = getHRP().CFrame
	}

	table.insert(locais, novo)
	criarBotao(novo)
	salvar()
end)

toggle.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
	toggle.Text = main.Visible and "CLOSE" or "OPEN"
end)
