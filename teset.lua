--// ==========================================
--// UI HUB MOBILE: MERDEKA AUTO COLLECT
--// ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Fungsi untuk Buat UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MerdekaHubMobile"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 220) -- Saiz kecil sesuai telefon
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
Title.Text = "MERDEKA HUB"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

--// Kotak Taip Nama Objek
local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(1, -20, 0, 35)
InputBox.Position = UDim2.new(0, 10, 0, 50)
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.PlaceholderText = "Taip nama objek (cth: Flag)"
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 14
InputBox.Parent = MainFrame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 5)
InputCorner.Parent = InputBox

--// Pemboleh Ubah Auto
local AutoTeleportOn = false
local NearestItem = nil

--// Fungsi Cari Objek
local function FindItems()
    local search = InputBox.Text
    local items = {}
    if search ~= "" then
        for _, obj in pairs(game.Workspace:GetDescendants()) do
            if (obj:IsA("BasePart") or obj:IsA("Model")) and string.find(string.lower(obj.Name), string.lower(search)) then
                table.insert(items, obj)
            end
        end
    end
    return items
end

--// Fungsi Teleport & Auto
local function TeleportToObject(obj)
    local Char = LocalPlayer.Character
    local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
    local Root = Char and Char:FindFirstChild("Humanoid") 
    if HRP then
        if Root then Root.WalkSpeed = 100 end
        local targetCFrame = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
        HRP.CFrame = targetCFrame + Vector3.new(0, 5, 0) 
    end
end

local function StartAutoLoop()
    task.spawn(function()
        while AutoTeleportOn do
            local items = FindItems()
            if #items > 0 then
                -- Cari yang paling dekat
                local nearest, dist = nil, math.huge
                local charPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.zero
                
                for _, item in pairs(items) do
                    local itemPos = item:IsA("Model") and item:GetPivot().Position or item.Position
                    local d = (itemPos - charPos).Magnitude
                    if d < dist then
                        dist = d
                        nearest = item
                    end
                end
                
                if nearest then
                    TeleportToObject(nearest)
                end
            end
            task.wait(0.5)
        end
    end)
end

--// Fungsi Butang
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
    local items = FindItems()
    if #items > 0 then
        TeleportToObject(items[1])
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Info"; Text = "Objek tak dijumpai!"; Duration = 3})
    end
end)

CreateButton("Auto Collect: OFF", 145, Color3.fromRGB(50, 200, 100), function(btn)
    AutoTeleportOn = not AutoTeleportOn
    if AutoTeleportOn then
        btn.Text = "Auto Collect: ON"
        btn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        StartAutoLoop()
    else
        btn.Text = "Auto Collect: OFF"
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
