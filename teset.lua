--// ==========================================
--// UI HUB V2: AUTO TOUCH & SCAN (FIXED)
--// ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Buat UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MerdekaHubV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 230)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -115)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
Title.Text = "MERDEKA AUTO TOUCH"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

--// Kotak Taip (Untuk carian lebih spesifik)
local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -20, 0, 35)
InputBox.Position = UDim2.new(0, 10, 0, 50)
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.PlaceholderText = "Taip nama (kosongkan utk scan semua)"
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 14
InputBox.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 5)
InputCorner.Parent = InputBox

--// Pemboleh Ubah
local AutoTouchOn = false

--// Fungsi untuk Cari Objek Berdekatan (SCAN)
local function FindNearestTouched()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    local charPos = character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position or Vector3.zero
    local searchTerm = InputBox.Text
    local nearestObj, nearestDist = nil, math.huge
    
    -- Cari semua objek dalam Workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        -- Tapis: Hanya cari BasePart, jangan cari Character pemain lain atau Tanah
        if obj:IsA("BasePart") and obj.Name ~= "Baseplate" and obj.Name ~= "Terrain" and not obj:IsDescendantOf(character) and obj.Transparency < 1 then
            
            -- Kalau ada kata kunci, tapis lagi
            if searchTerm ~= "" then
                if not string.find(string.lower(obj.Name), string.lower(searchTerm)) then
                    continue -- Langkau jika nama tak sepadan
                end
            end
            
            -- Kira jarak
            local dist = (obj.Position - charPos).Magnitude
            
            -- Pilih yang paling dekat
            if dist < nearestDist and dist < 5000 then -- Had jarak cari 5000 stud
                nearestDist = dist
                nearestObj = obj
            end
        end
    end
    
    return nearestObj
end

--// Fungsi untuk "Sentuh" (Teleport TEPAT atas objek supaya Touch trigger)
local function TouchObject(obj)
    local Char = LocalPlayer.Character
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChild("Humanoid")
    
    if HRP and Hum then
        Hum.WalkSpeed = 100 -- Gerak laju sikit
        -- Letak 5 stud atas objek supaya jatuh menyentuh dia
        -- Ini jauh lebih berkesan daripada teleport terus ke tengah
        local targetPos = obj.Position + Vector3.new(0, 5, 0)
        HRP.CFrame = CFrame.new(targetPos)
    end
end

--// Loop Auto Touch
local function StartAutoTouch()
    task.spawn(function()
        while AutoTouchOn do
            local target = FindNearestTouched()
            if target then
                TouchObject(target)
            end
            task.wait(0.3) -- Jeda sikit supaya tak crash
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
    btn.TextSize = 14
    btn.Parent = MainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(func)
end

--// Pasang Butang
CreateButton("Teleport Sekarang", 95, Color3.fromRGB(50, 130, 255), function()
    local target = FindNearestTouched()
    if target then
        TouchObject(target)
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Info"; Text = "Tiada objek dijumpai! Cuba taip nama."; Duration = 3})
    end
end)

CreateButton("AUTO TOUCH: OFF", 145, Color3.fromRGB(50, 200, 100), function(btn)
    AutoTouchOn = not AutoTouchOn
    if AutoTouchOn then
        btn.Text = "AUTO TOUCH: ON"
        btn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        StartAutoTouch()
    else
        btn.Text = "AUTO TOUCH: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    end
end)

--// Fungsi Drag (Untuk gerakkan UI)
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)
