--// ==========================================================
--// MERDEKA HUB V6 (FIXED): AUTO POINT COLLECTOR + PROMPT
--// ==========================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

--// ========== SETUP UI MOBILE ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MerdekaV6Hub"
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
Title.Text = "MERDEKA HUB V6 (PROMPT)"
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

--// ========== LOGIK UTAMA ==========
local AutoCollectOn = false
local VisitedObjects = {}

--// PENAPISAN KETAT: ELak Pemain Lain & Objek Rawak
local function IsValidPointObject(obj)
    -- Mesti BasePart
    if not obj:IsA("BasePart") then return false end
    if obj.Transparency >= 1 then return false end
    if obj.Name == "Baseplate" or obj.Name == "Terrain" then return false end

    -- //⚠️ KRITERIA PENTING: Buang SEMUA bahagian pemain (termasuk diri sendiri)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and obj:IsDescendantOf(player.Character) then
            return false
        end
    end

    -- // Ciri-ciri objek Point
    local objName = string.lower(obj.Name)
    local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""
    
    -- 1. Perlu ada TouchTransmitter (mesej sentuhan untuk ambil point)
    local hasTouchTrigger = obj:FindFirstChildOfClass("TouchTransmitter") ~= nil
    
    -- 2. Perlu ada nilai (IntValue, NumberValue) atau ProximityPrompt di dalamnya
    local hasValueOrPrompt = false
    for _, child in pairs(obj:GetChildren()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("StringValue") or child:IsA("ProximityPrompt") then
            hasValueOrPrompt = true
            break
        end
    end

    -- 3. Kata kunci event (Flag, Point, Event, Token, dll)
    local keywords = {"flag", "bendera", "point", "score", "event", "token", "coin", "merdeka"}
    local matchesKeyword = false
    for _, word in ipairs(keywords) do
        if string.find(objName, word) or string.find(parentName, word) then
            matchesKeyword = true
            break
        end
    end

    -- Objek dianggap valid jika: (Ada Touch + Kata Kunci) ATAU (Ada Value/Prompt)
    if (hasTouchTrigger and matchesKeyword) or hasValueOrPrompt then
        return true
    end

    return false
end

--// Ambil Senarai Objek Yang Sah
local function GetValidTargets()
    local targets = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if IsValidPointObject(obj) and not VisitedObjects[obj] then
            table.insert(targets, obj)
        end
    end
    return targets
end

--// Fungsi Auto-Load ProximityPrompt
local function AutoTriggerPrompt(targetPart)
    if not targetPart then return end
    
    -- Cari prompt di dalam objek itu sendiri atau anak-anaknya
    local prompt = targetPart:FindFirstChildOfClass("ProximityPrompt")
    
    if prompt then
        -- Paksa prompt untuk "tertekan" (selalunya dengan mengaktifkan fungsi trigger)
        prompt:PromptButtonHold() -- Jika perlu tahan
        -- ATAU
        prompt:Trigger() -- Jika hanya perlu klik
    else
        -- Jika tiada prompt di dalam objek, cuba cari di sekeliling yang tersembunyi
        -- Sesetengah game letak prompt di dalam Handle
        for _, child in pairs(targetPart:GetChildren()) do
            if child:IsA("ProximityPrompt") then
                child:Trigger()
                break
            end
        end
    end
end

--// Teleport Dan Interaksi
local function TeleportAndInteract(target)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp and target then
        -- Letakkan badan betul-betul di atas objek
        hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
        
        -- Sedikit jeda untuk memastikan teleport selesai
        task.wait(0.2)
        
        -- Panggil fungsi auto prompt
        AutoTriggerPrompt(target)
        
        -- Tandakan sebagai sudah diambil
        VisitedObjects[target] = true
    end
end

--// Auto Collect Loop
local function StartAutoLoop()
    task.spawn(function()
        while AutoCollectOn do
            local targets = GetValidTargets()
            
            -- Jika tiada objek, reset memori dan imbas semula
            if #targets == 0 then
                VisitedObjects = {}
                StatusLabel.Text = "Mengimbas semula..."
                task.wait(1)
            else
                -- Susun ikut jarak paling dekat
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    table.sort(targets, function(a, b)
                        return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
                    end)
                    
                    local nearest = targets[1]
                    if nearest then
                        StatusLabel.Text = "Kutip: " .. nearest.Name
                        TeleportAndInteract(nearest)
                    end
                end
            end
            
            task.wait(0.3) -- Mengelakkan lag pada telefon
        end
    end)
end

--// ========== BUTANG UI ==========
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

-- Butang Teleport Manual
CreateButton("KUTIP SATU OBJEK", 85, Color3.fromRGB(50, 120, 220), function()
    local targets = GetValidTargets()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp and #targets > 0 then
        table.sort(targets, function(a, b)
            return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
        end)
        TeleportAndInteract(targets[1])
        StatusLabel.Text = "Teleport ke: " .. targets[1].Name
    else
        StatusLabel.Text = "Tiada objek ditemui!"
    end
end)

-- Butang Auto Collect
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

-- Butang Reset Memori
CreateButton("RESET MEMORI", 185, Color3.fromRGB(120, 120, 120), function()
    VisitedObjects = {}
    StatusLabel.Text = "Memori telah dikosongkan"
end)
