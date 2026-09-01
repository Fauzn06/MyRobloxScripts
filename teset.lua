--// ==========================================================
--// MERDEKA HUB V15 (INPUT BOX SEARCH + SAFE MOVE)
--// ==========================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

--// SETUP UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MerdekaV15Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 260) -- Tinggi sedikit untuk textbox
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Bar Tajuk
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
TopBar.BorderSizePixel = 0
TopBar.Active = true
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "MERDEKA HUB V15"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Butang Tutup
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 1, 0)
CloseButton.Position = UDim2.new(1, -35, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TopBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- KOTAK TEKS (InputBox) - Untuk taip nama objek
local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -20, 0, 35)
InputBox.Position = UDim2.new(0, 10, 0, 45)
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.PlaceholderText = "Taip nama objek (cth: 1 atau Flag)"
InputBox.Text = "1" -- Default kepada 1
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 14
InputBox.Parent = MainFrame
local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 5)
InputCorner.Parent = InputBox

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 85)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Sedia"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

-- Butang Buka Semula (Sembunyi)
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 50, 0, 50)
OpenButton.Position = UDim2.new(0, 10, 0.5, -25)
OpenButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
OpenButton.Text = "🏁"
OpenButton.TextColor3 = Color3.fromRGB(0, 0, 0)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 20
OpenButton.Visible = false
OpenButton.Parent = ScreenGui
local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

-- CUSTOM DRAG (Untuk seret UI)
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end
end)

--// ========== LOGIK CARIAN MENGIKUT INPUT ==========
local AutoCollectOn = false
local VisitedObjects = {}

local function IsValidTarget(obj)
    if not obj:IsA("BasePart") then return false end
    if obj.Transparency >= 1 then return false end
    if obj.Name == "Baseplate" or obj.Name == "Terrain" then return false end
    if string.lower(obj.Name) == "handle" then return false end
    
    -- Buang Tool, Topi, dan Pemain Lain
    if obj:FindFirstAncestorOfClass("Tool") or obj:FindFirstAncestorOfClass("Accessory") or obj:FindFirstAncestorOfClass("Hat") then return false end
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and obj:IsDescendantOf(player.Character) then return false end
    end

    -- Ambil Teks dari Kotak
    local searchTerm = InputBox.Text
    local objName = string.lower(obj.Name)
    local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""

    -- Jika nama objek atau parent mengandungi teks yang anda taip
    if string.find(objName, string.lower(searchTerm)) or string.find(parentName, string.lower(searchTerm)) then
        return true
    end

    return false
end

local function GetValidTargets()
    local targets = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local prim = obj.PrimaryPart
            if prim and IsValidTarget(prim) and not VisitedObjects[prim] then
                table.insert(targets, prim)
            end
        elseif obj:IsA("BasePart") and IsValidTarget(obj) and not VisitedObjects[obj] then
            table.insert(targets, obj)
        end
    end
    return targets
end

--// ========== LOGIK SAFE MOVE (JALAN LAJU KE OBJEK) ==========
local function SafeMoveAndCollect(target)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hrp and hum then
        StatusLabel.Text = "Mencari: " .. target.Name
        
        -- Set kelajuan tinggi (Jalan laju, bukan teleport terus)
        hum.WalkSpeed = 150 
        
        -- Suruh berjalan ke objek
        hum:MoveTo(target.Position + Vector3.new(0, 3, 0))
        
        -- Tunggu sampai sampai ATAU timeout 60 saat
        local start = tick()
        while (hrp.Position - target.Position).Magnitude > 5 and tick() - start < 60 do
            task.wait()
        end
        
        -- Kembalikan kelajuan normal
        hum.WalkSpeed = 16
        
        -- Auto trigger ProximityPrompt jika ada
        local prompt = target:FindFirstChildOfClass("ProximityPrompt")
        if prompt then prompt:Trigger() end
        
        VisitedObjects[target] = true
    end
end

--// AUTO COLLECT LOOP
local function StartAutoLoop()
    task.spawn(function()
        while AutoCollectOn do
            local targets = GetValidTargets()

            if #targets == 0 then
                VisitedObjects = {}
                StatusLabel.Text = "Cari semula..."
                task.wait(1)
            else
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    table.sort(targets, function(a, b)
                        return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
                    end)
                    local nearest = targets[1]
                    if nearest then
                        SafeMoveAndCollect(nearest)
                    end
                end
            end
            task.wait(0.5) 
        end
    end)
end

--// BUTANG UI
local function CreateButton(text, yPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = MainFrame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    btn.MouseButton1Click:Connect(function() callback(btn) end)
end

CreateButton("GERAK KE OBJEK", 115, Color3.fromRGB(50, 120, 220), function()
    local targets = GetValidTargets()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and #targets > 0 then
        table.sort(targets, function(a, b)
            return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
        end)
        SafeMoveAndCollect(targets[1])
    else
        StatusLabel.Text = "Objek tidak dijumpai! Cuba tukar nama."
    end
end)

CreateButton("AUTO COLLECT: OFF", 160, Color3.fromRGB(40, 180, 90), function(btn)
    AutoCollectOn = not AutoCollectOn
    if AutoCollectOn then
        btn.Text = "AUTO COLLECT: ON"
        btn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        StartAutoLoop()
    else
        btn.Text = "AUTO COLLECT: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
        StatusLabel.Text = "Status: Diberhentikan"
    end
end)

CreateButton("RESET MEMORI", 205, Color3.fromRGB(120, 120, 120), function()
    VisitedObjects = {}
    StatusLabel.Text = "Memori telah dikosongkan"
end)