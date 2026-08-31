--// ==========================================================
--// MERDEKA HUB V8 (FLAG HUNTER) - AUTO COLLECT HIDDEN FLAGS
--// ==========================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// Setup UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MerdekaV8Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 230)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -115)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
Title.Text = "MERDEKA HUB V8 (FLAGS)"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 45)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Sedia"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

--// Kawalan
local AutoCollectOn = false
local VisitedObjects = {}

--// PENAPISAN KETAT: BUANG HANDLE, PEMAIN, DAN OBJEK RAWAK
local function IsValidFlagObject(obj)
    if not obj:IsA("BasePart") then return false end
    if obj.Transparency >= 1 then return false end
    if obj.Name == "Baseplate" or obj.Name == "Terrain" then return false end

    -- Buang Handle / Topi / Senjata
    if string.lower(obj.Name) == "handle" then return false end
    if obj:FindFirstAncestorOfClass("Tool") or obj:FindFirstAncestorOfClass("Accessory") or obj:FindFirstAncestorOfClass("Hat") then
        return false
    end

    -- Buang Pemain Lain
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and obj:IsDescendantOf(player.Character) then
            return false
        end
    end

    -- Cari Kata Kunci FLAG (Sangat Ketat)
    local objName = string.lower(obj.Name)
    local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
    
    local keywords = {"flag", "golden", "malaysia", "merdeka", "hidden", "bendera", "my"}
    local matchesKeyword = false
    for _, word in ipairs(keywords) do
        if string.find(objName, word) or string.find(parentName, word) then
            matchesKeyword = true
            break
        end
    end

    if matchesKeyword then
        return true
    end

    return false
end

--// Ambil Senarai Flag Yang Sah
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

--// Teleport Dan Kumpul
local function TeleportAndCollect(target)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp and target then
        hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
        
        task.wait(0.2)
        
        -- Auto trigger ProximityPrompt jika ada
        local prompt = target:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            prompt:Trigger()
        end
        
        -- Tandakan sebagai sudah dikutip
        VisitedObjects[target] = true
    end
end

--// Loop Auto Collect
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

--// Butang
local function CreateButton(text, yPos, color, func)
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
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(func)
end

CreateButton("KUTIP SATU FLAG", 85, Color3.fromRGB(50, 120, 220), function()
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

CreateButton("AUTO COLLECT: OFF", 135, Color3.fromRGB(40, 180, 90), function(btn)
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

CreateButton("RESET MEMORI", 185, Color3.fromRGB(120, 120, 120), function()
    VisitedObjects = {}
    StatusLabel.Text = "Memori telah dikosongkan"
end)