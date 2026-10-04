-- Mini DEX Lite
-- Versão leve: não escaneia o jogo inteiro ao iniciar.
-- Mostra somente os filhos diretos e permite expandir sob demanda.
-- Inclui pesquisa e botão COPIAR.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Remove versões antigas
pcall(function()
    for _, parent in ipairs({
        player:FindFirstChildOfClass("PlayerGui"),
        game:GetService("CoreGui")
    }) do
        if parent then
            for _, v in ipairs(parent:GetChildren()) do
                if v:IsA("ScreenGui") and (
                    v.Name == "MiniDEX" or
                    v.Name == "MiniDEXLite"
                ) then
                    v:Destroy()
                end
            end
        end
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "MiniDEXLite"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(520, 360)
main.Position = UDim2.new(0.5, -260, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -170, 0, 35)
title.Position = UDim2.fromOffset(10, 0)
title.BackgroundTransparency = 1
title.Text = "Mini DEX Lite"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local copy = Instance.new("TextButton")
copy.Size = UDim2.fromOffset(70, 26)
copy.Position = UDim2.new(1, -105, 0, 5)
copy.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
copy.Text = "COPIAR"
copy.TextColor3 = Color3.new(1, 1, 1)
copy.TextSize = 11
copy.Font = Enum.Font.GothamBold
copy.Parent = main

Instance.new("UICorner", copy).CornerRadius = UDim.new(0, 5)

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(25, 26)
close.Position = UDim2.new(1, -30, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(170, 45, 45)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 13
close.Font = Enum.Font.GothamBold
close.Parent = main

Instance.new("UICorner", close).CornerRadius = UDim.new(0, 5)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local search = Instance.new("TextBox")
search.Size = UDim2.new(1, -20, 0, 30)
search.Position = UDim2.fromOffset(10, 40)
search.BackgroundColor3 = Color3.fromRGB(32, 32, 39)
search.PlaceholderText = "Pesquisar nos objetos carregados..."
search.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
search.Text = ""
search.TextColor3 = Color3.new(1, 1, 1)
search.TextSize = 12
search.Font = Enum.Font.Gotham
search.ClearTextOnFocus = false
search.Parent = main

Instance.new("UICorner", search).CornerRadius = UDim.new(0, 5)

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(0, 205, 1, -80)
list.Position = UDim2.fromOffset(10, 75)
list.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.Parent = main

Instance.new("UICorner", list).CornerRadius = UDim.new(0, 5)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 2)
layout.Parent = list

local info = Instance.new("ScrollingFrame")
info.Size = UDim2.new(1, -225, 1, -80)
info.Position = UDim2.fromOffset(215, 75)
info.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
info.BorderSizePixel = 0
info.ScrollBarThickness = 4
info.Parent = main

Instance.new("UICorner", info).CornerRadius = UDim.new(0, 5)

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -14, 0, 0)
infoText.Position = UDim2.fromOffset(7, 7)
infoText.BackgroundTransparency = 1
infoText.Text = "Selecione um objeto."
infoText.TextColor3 = Color3.fromRGB(220, 220, 220)
infoText.TextSize = 12
infoText.Font = Enum.Font.Code
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.TextWrapped = false
infoText.AutomaticSize = Enum.AutomaticSize.Y
infoText.Parent = info

local fullText = ""

local function copyText(text)
    for _, fn in ipairs({setclipboard, toclipboard, writeclipboard}) do
        if typeof(fn) == "function" then
            if pcall(fn, text) then
                return true
            end
        end
    end
    return false
end

copy.MouseButton1Click:Connect(function()
    if fullText == "" then return end

    if copyText(fullText) then
        copy.Text = "COPIADO!"
        task.delay(1, function()
            if copy.Parent then copy.Text = "COPIAR" end
        end)
    else
        copy.Text = "N/D"
        task.delay(1, function()
            if copy.Parent then copy.Text = "COPIAR" end
        end)
    end
end)

local function getInfo(obj)
    local t = {}

    table.insert(t, "Nome: " .. obj.Name)
    table.insert(t, "Classe: " .. obj.ClassName)

    pcall(function()
        table.insert(t, "Path: " .. obj:GetFullName())
    end)

    table.insert(t, "")
    table.insert(t, "--- ATRIBUTOS ---")

    local attrs = obj:GetAttributes()

    if next(attrs) then
        for name, value in pairs(attrs) do
            table.insert(t, name .. " = " .. tostring(value))
        end
    else
        table.insert(t, "Nenhum atributo.")
    end

    table.insert(t, "")
    table.insert(t, "--- FILHOS DIRETOS ---")

    local children = obj:GetChildren()

    if #children == 0 then
        table.insert(t, "Nenhum.")
    else
        for i, child in ipairs(children) do
            table.insert(
                t,
                string.format("%d. %s [%s]", i, child.Name, child.ClassName)
            )
        end
    end

    pcall(function()
        if obj:IsA("ValueBase") then
            table.insert(t, "")
            table.insert(t, "--- VALUE ---")
            table.insert(t, tostring(obj.Value))
        end
    end)

    pcall(function()
        if obj:IsA("BasePart") then
            table.insert(t, "")
            table.insert(t, "--- PART ---")
            table.insert(t, "Size: " .. tostring(obj.Size))
            table.insert(t, "Position: " .. tostring(obj.Position))
            table.insert(t, "Transparency: " .. tostring(obj.Transparency))
            table.insert(t, "Material: " .. tostring(obj.Material))
        end
    end)

    return table.concat(t, "\n")
end

local loaded = {}
local buttons = {}

local function clearList()
    for _, v in ipairs(list:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end
    buttons = {}
end

local function updateCanvas()
    list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 5)
end

local function showObject(obj)
    fullText = getInfo(obj)
    infoText.Text = fullText

    task.defer(function()
        info.CanvasSize = UDim2.fromOffset(
            0,
            infoText.AbsoluteSize.Y + 15
        )
    end)
end

local function addObject(obj)
    if loaded[obj] then return end
    loaded[obj] = true

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -6, 0, 26)
    button.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
    button.Text = "  " .. obj.Name
    button.TextColor3 = Color3.fromRGB(235, 235, 235)
    button.TextSize = 11
    button.Font = Enum.Font.Gotham
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Parent = list

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)

    buttons[#buttons + 1] = {
        button = button,
        object = obj
    }

    button.MouseButton1Click:Connect(function()
        showObject(obj)

        -- Carrega SOMENTE os filhos do objeto clicado.
        -- Não escaneia os descendentes inteiros.
        local children = obj:GetChildren()

        if #children > 0 then
            for _, child in ipairs(children) do
                addObject(child)
            end
        end

        updateCanvas()
    end)
end

-- Raiz inicial: somente ReplicatedStorage.
local root = game:GetService("ReplicatedStorage")
addObject(root)

-- Também adiciona alguns serviços principais sem escanear seus descendentes.
for _, serviceName in ipairs({
    "Workspace",
    "Players",
    "Lighting",
    "SoundService"
}) do
    pcall(function()
        local service = game:GetService(serviceName)
        addObject(service)
    end)
end

updateCanvas()

search:GetPropertyChangedSignal("Text"):Connect(function()
    local query = search.Text:lower()

    for _, data in ipairs(buttons) do
        local name = data.object.Name:lower()

        data.button.Visible =
            query == ""
            or name:find(query, 1, true) ~= nil
    end
end)

-- Arrastar no PC/mobile
local dragging = false
local dragStart
local startPos
local dragInput

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("Mini DEX Lite carregado.")
