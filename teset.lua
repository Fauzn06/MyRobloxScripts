--// ==========================================================
--// MERDEKA HUB V9 (FLAG HUNTER + OVERLAY TOGGLE)
--// ==========================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// SETUP UI MOBILE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MerdekaV9Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 260)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Bar Tajuk
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "MERDEKA HUB V9"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Butang Tutup (X)
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

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 45)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Sedia"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

-- Butang Buka Semula (Tersembunyi)
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

-- Fungsi Buka/Tutup
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenButton.Visible = false
end)

--// ========== LOGIK PENAPISAN KETAT ==========
local AutoCollectOn = false
local VisitedObjects = {}

local function IsValidFlagObject(obj)
    if not obj:IsA("BasePart") then return false end
    if obj.Transparency >= 1 then return false end
    if obj.Name == "Baseplate" or obj.Name == "Terrain" then return false end
    if string.lower(obj.Name) == "handle" then return false end
    
    -- Buang Tool, Topi, dan Pemain
    if obj:FindFirstAncestorOfClass("Tool") or obj:FindFirstAncestorOfClass("Accessory") or obj:FindFirstAncestorOfClass("Hat") then return false end
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and obj:IsDescendantOf(player.Character) then return false end
    end

    -- PENTING: Mesti ada TouchTransmitter atau ProximityPrompt (barulah boleh dikutip)
    local hasTrigger = (obj:FindFirstChildOfClass("TouchTransmitter") ~= nil) or (obj:FindFirstChildOfClass("ProximityPrompt") ~= nil)
    if not hasTrigger then return false end

    -- Semak nama objek (Flag, Event, dll) dan nama parent
    local objName = string.lower(obj.Name)
    local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
    
    local keywords = {"flag", "golden", "malaysia", "merdeka", "hidden", "event", "bendera", "spawn", "point"}
    local matchesKeyword = false
    for _, word in ipairs(keywords) do
        if string.find(objName, word) or string.find(parentName, word) then
            matchesKeyword = true
            break
        end
    end

    -- Jika nama objek adalah nombor (cth: "1", "2"), ia MESTI ada trigger untuk diterima
    local isNumbered = string.match(objName, "^%d+$") ~= nil
    if isNumbered and hasTrigger then
        return true
    end

    return matchesKeyword
end

--// Ambil Senarai Sasaran
local function GetValidTargets()
    local targets = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local prim = obj.PrimaryPart
            if prim and IsValidFlagObject(prim) and not VisitedObjects[prim] then
                table.insert(targets, prim)
            end
        elseif obj:IsA("BasePart") and IsValidFlagObject(obj) and not VisitedObjects[obj] then
            table.insert(targets, obj)
        end
    end
    return targets
end

--// Teleport & Ambil
local function TeleportAndCollect(target)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hrp and target then
        hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
        task.wait(0.2)

        local prompt = target:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            prompt:Trigger()
        end

        VisitedObjects[target] = true
    end
end

--// Auto Collect Loop
local function StartAutoLoop()
    task.spawn(function()
        while AutoCollectOn do
            local targets = GetValidTargets()

            if #targets == 0 then
                VisitedObjects = {}
                StatusLabel.Text = "Mengimbas semula (Reset)..."
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
                        StatusLabel.Text = "Cari Flag: " .. nearest.Name
                        TeleportAndCollect(nearest)
                    end
                end
            end
            task.wait(0.3)
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

CreateButton("KUTIP SATU FLAG", 80, Color3.fromRGB(50, 120, 220), function()
    local targets = GetValidTargets()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hrp and #targets > 0 then
        table.sort(targets, function(a, b)
            return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
        end)
        TeleportAndCollect(targets[1])
        StatusLabel.Text = "Pergi ke: " .. targets[1].Name
    else
        StatusLabel.Text = "Tiada Flag ditemui!"
    end
end)

CreateButton("AUTO COLLECT: OFF", 130, Color3.fromRGB(40, 180, 90), function(btn)
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

CreateButton("RESET MEMORI", 180, Color3.fromRGB(120, 120, 120), function()
    VisitedObjects = {}
    StatusLabel.Text = "Memori telah dikosongkan"
end)