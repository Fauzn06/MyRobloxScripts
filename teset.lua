--// ========================================== 
--// UI HUB V3: AUTO TOUCH & SMART SCAN (BENDERA/POINT)
--// ========================================== 
local Players = game:GetService("Players") 
local RunService = game:GetService("RunService") 
local LocalPlayer = Players.LocalPlayer 

--// Buat UI 
local ScreenGui = Instance.new("ScreenGui") 
ScreenGui.Name = "MerdekaHubV3" 
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
Title.Text = "AUTO TOUCH BENDERA/POINT" 
Title.TextColor3 = Color3.fromRGB(0, 0, 0) 
Title.Font = Enum.Font.GothamBold 
Title.TextSize = 14 
Title.Parent = MainFrame 

local InputBox = Instance.new("TextBox") 
InputBox.Size = UDim2.new(1, -20, 0, 35) 
InputBox.Position = UDim2.new(0, 10, 0, 50) 
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50) 
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255) 
InputBox.PlaceholderText = "Cari semua objek (Auto-Scan)" 
InputBox.Font = Enum.Font.Gotham 
InputBox.TextSize = 14 
InputBox.ClearTextOnFocus = false
InputBox.TextEditable = false -- Dimatikan kerana kita guna Smart Scan
InputBox.Parent = MainFrame 

local InputCorner = Instance.new("UICorner") 
InputCorner.CornerRadius = UDim.new(0, 5) 
InputCorner.Parent = InputBox 

--// Pemboleh Ubah 
local AutoTouchOn = false 

--// Fungsi untuk Cari Objek Berdasarkan TouchTransmitter
local function FindNearestCollectable() 
    local character = LocalPlayer.Character 
    if not character then return nil end 
     
    local charPos = character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position or Vector3.zero 
    local nearestObj, nearestDist = nil, math.huge 
     
    for _, obj in pairs(workspace:GetDescendants()) do 
        -- Tapis: Cari objek fizikal yang BUKAN sebahagian daripada pemain dan BUKAN baseplate
        if obj:IsA("BasePart") and obj.Name ~= "Baseplate" and obj.Name ~= "Terrain" and not obj:IsDescendantOf(character) then 
             
            -- Semak jika objek ini boleh disentuh (TouchTransmitter) atau namanya mencurigakan (flag/point)
            local hasTouch = obj:FindFirstChildWhichIsA("TouchTransmitter")
            local isFlagOrPoint = string.match(string.lower(obj.Name), "flag") or string.match(string.lower(obj.Name), "bendera") or string.match(string.lower(obj.Name), "point")
            
            if hasTouch or isFlagOrPoint then
                local dist = (obj.Position - charPos).Magnitude 
                 
                if dist < nearestDist and dist < 5000 then 
                    nearestDist = dist 
                    nearestObj = obj 
                end 
            end
        end 
    end 
     
    return nearestObj 
end 

--// Fungsi Sentuh (Teleport TEPAT ke objek) 
local function TouchObject(obj) 
    local Char = LocalPlayer.Character 
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart") 
     
    if HRP then 
        -- Teleport ke titik yang sangat dekat untuk mencetuskan 'Touch'
        HRP.CFrame = CFrame.new(obj.Position)
    end 
end 

--// Loop Auto Touch 
local function StartAutoTouch() 
    task.spawn(function() 
        while AutoTouchOn do 
            local target = FindNearestCollectable() 
            if target then 
                TouchObject(target) 
                task.wait(0.1) -- Cepatkan sedikit proses
            else
                task.wait(1) -- Jika tiada objek, tunggu lama sedikit sebelum scan semula
            end 
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
CreateButton("Teleport ke 1 Objek", 95, Color3.fromRGB(50, 130, 255), function() 
    local target = FindNearestCollectable() 
    if target then 
        TouchObject(target) 
    else 
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Info"; Text = "Tiada objek point/bendera dijumpai di map!"; Duration = 3}) 
    end 
end) 

CreateButton("AUTO COLLECT: OFF", 145, Color3.fromRGB(50, 200, 100), function(btn) 
    AutoTouchOn = not AutoTouchOn 
    if AutoTouchOn then 
        btn.Text = "AUTO COLLECT: ON" 
        btn.BackgroundColor3 = Color3.fromRGB(255, 80, 80) 
        StartAutoTouch() 
    else 
        btn.Text = "AUTO COLLECT: OFF" 
        btn.BackgroundColor3 = Color3.fromRGB(50, 200, 100) 
    end 
end) 

--// Fungsi Drag UI 
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
