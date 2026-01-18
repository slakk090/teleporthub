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
-- ARQUIVOS (SOLARA - WORKSPACE)
-- =========================
local ROOT_FOLDER = "workspace"
local folder = ROOT_FOLDER .. "/TeleportHub"
local filename = folder .. "/teleport_locais.json"

local supports_files =
	writefile and readfile and isfile and isfolder and makefolder

if not supports_files then
	warn("[TeleportHub] Executor não suporta arquivos")
	return
end

-- garantir workspace
if not isfolder(ROOT_FOLDER) then
	makefolder(ROOT_FOLDER)
end

-- garantir TeleportHub
if not isfolder(folder) then
	makefolder(folder)
end

-- =========================
-- LOCAIS
-- =========================
local locais = {}

-- Carregar locais
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

-- Salvar locais
local function salvarArquivo()
	local salvar = {}

	for _, v in ipairs(locais) do
		table.insert(salvar, {
			nome = v.nome,
			cf = { v.cf:GetComponents() }
		})
	end

	writefile(filename, HttpService:JSONEncode(salvar))
end

-- =========================
-- TELEPORTE ANTI-BUG
-- =========================
local function teleportTo(cf)
	local char = getChar()
	local humanoid = char:FindFirstChildOfClass("Humanoid")

	for _, seat in ipairs(workspace:GetDescendants()) do
		if seat:IsA("VehicleSeat") and seat.Occupant == humanoid then
			local model = seat:FindFirstAncestorOfClass("Model")

			if model then
				model.PrimaryPart = model.PrimaryPart or seat

				for _, part in ipairs(model:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Anchored = true
					end
				end

				model:SetPrimaryPartCFrame(cf)
				task.wait(0.15)

				for _, part in ipairs(model:GetDescendants()) do
					if part:IsA("BasePart") then
						part.AssemblyLinearVelocity = Vector3.zero
						part.AssemblyAngularVelocity = Vector3.zero
						part.Anchored = false
					end
				end
				return
			end
		end
	end

	getHRP().CFrame = cf
end

-- =========================
-- GUI
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "TeleportGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Botão flutuante
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -25)
toggleBtn.Text = "OPEN"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextScaled = true
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)

-- Main
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 260, 0, 360)
main.Position = UDim2.new(0, 70, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.Visible = false
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

-- Título
local titulo = Instance.new("TextLabel", main)
titulo.Size = UDim2.new(1,0,0,40)
titulo.Text = "Teleporte"
titulo.Font = Enum.Font.GothamBold
titulo.TextSize = 20
titulo.TextColor3 = Color3.new(1,1,1)
titulo.BackgroundTransparency = 1

-- Lista
local lista = Instance.new("ScrollingFrame", main)
lista.Size = UDim2.new(1,-20,0,220)
lista.Position = UDim2.new(0,10,0,50)
lista.ScrollBarThickness = 4
lista.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", lista)
layout.Padding = UDim.new(0,5)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	lista.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 5)
end)

local function criarBotao(data)
	local btn = Instance.new("TextButton", lista)
	btn.Size = UDim2.new(1,0,0,40)
	btn.Text = data.nome
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

	btn.MouseButton1Click:Connect(function()
		teleportTo(data.cf)
	end)
end

for _, v in ipairs(locais) do
	criarBotao(v)
end

-- Nome
local nomeBox = Instance.new("TextBox", main)
nomeBox.Size = UDim2.new(1,-20,0,30)
nomeBox.Position = UDim2.new(0,10,0,280)
nomeBox.PlaceholderText = "Nome do local"
nomeBox.TextScaled = true
nomeBox.Font = Enum.Font.Gotham
nomeBox.TextColor3 = Color3.new(1,1,1)
nomeBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", nomeBox).CornerRadius = UDim.new(0,6)

-- Salvar
local salvarBtn = Instance.new("TextButton", main)
salvarBtn.Size = UDim2.new(1,-20,0,30)
salvarBtn.Position = UDim2.new(0,10,0,320)
salvarBtn.Text = "Salvar Local"
salvarBtn.Font = Enum.Font.GothamBold
salvarBtn.TextScaled = true
salvarBtn.TextColor3 = Color3.new(1,1,1)
salvarBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
Instance.new("UICorner", salvarBtn).CornerRadius = UDim.new(0,6)

salvarBtn.MouseButton1Click:Connect(function()
	if nomeBox.Text ~= "" then
		local novo = {
			nome = nomeBox.Text,
			cf = getHRP().CFrame
		}

		table.insert(locais, novo)
		criarBotao(novo)
		nomeBox.Text = ""
		salvarArquivo()
	end
end)

toggleBtn.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
	toggleBtn.Text = main.Visible and "CLOSE" or "OPEN"
end)
