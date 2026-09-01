--// ==========================================================
--// MERDEKA HUB V11 (SAFE MOVE + TARGET KHUSUS "1")
--// ==========================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// SETUP UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MerdekaV11Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 230)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -115)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

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
Title.Text = "MERDEKA HUB V11 (SAFE)"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

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

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 45)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Sedia"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

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

--// ========== LOGIK KETAT: HANYA CARI "1" ==========
local AutoCollectOn = false
local VisitedObjects = {}

local function IsValidTarget()
    -- Kita cari objek yang NAMANYA "1" sahaja. Dan ia mesti bukan pemain, bukan tool.
    return function(obj)
        if not obj:IsA("BasePart") then return false end
        if obj.Transparency >= 1 then return false end
        if obj.Name ~= "1" then return false end
        
        -- Buang yang bukan target
        if obj:FindFirstAncestorOfClass("Tool") or obj:FindFirstAncestorOfClass("Accessory") or obj:FindFirstAncestorOfClass("Hat") then return false end
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and obj:IsDescendantOf(player.Character) then return false end
        end
        
        return true
    end
end

local function GetValidTargets()
    local targets = {}
    local check = IsValidTarget()
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local prim = obj.PrimaryPart
            if prim and check(prim) and not VisitedObjects[prim] then
                table.insert(targets, prim)
            end
        elseif obj:IsA("BasePart") and check(obj) and not VisitedObjects[obj] then
            table.insert(targets, obj)
        end
    end
    return targets
end

--// ========== LOGIK SAFE MOVE (JALAN LAJU, BUKAN TELEPORT) ==========
local function SafeMoveAndCollect(target)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hrp and hum then
        -- Set kelajuan tinggi (jalan laju)
        hum.WalkSpeed = 250 
        
        -- Suruh karakter BERLARI ke lokasi (bukan terus teleport)
        hum:MoveTo(target.Position + Vector3.new(0, 3, 0))
        
        -- Tunggu sehingga sampai atau timeout 5 saat
        local start = tick()
        while (hrp.Position - target.Position).Magnitude > 5 and tick() - start < 5 do
            task.wait()
        end
        
        -- Kembalikan kelajuan normal
        hum.WalkSpeed = 16
        
        -- Cuba trigger prompt jika ada
        local prompt = target:FindFirstChildOfClass("ProximityPrompt")
        if prompt then prompt:Trigger() end
        
        -- Tandakan sebagai sudah dikutip
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
                        StatusLabel.Text = "Kutip: " .. nearest.Name
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

CreateButton("GERAK KE '1'", 80, Color3.fromRGB(50, 120, 220), function()
    local targets = GetValidTargets()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hrp and #targets > 0 then
        table.sort(targets, function(a, b)
            return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
        end)
        StatusLabel.Text = "Mula bergerak ke: " .. targets[1].Name
        SafeMoveAndCollect(targets[1])
    else
        StatusLabel.Text = "Objek '1' tidak dijumpai!"
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