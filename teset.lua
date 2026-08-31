--// ==========================================
--// MERDEKA HUB V4: EVENT POINT & FLAG COLLECTOR
--// ==========================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// Cipta UI Utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EventPointCollectorHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 310, 0, 270)
MainFrame.Position = UDim2.new(0.5, -155, 0.5, -135)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
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
Title.Text = "EVENT POINT COLLECTOR V4"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 45)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Standby"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame

--// Kawalan
local AutoCollectActive = false
local VisitedObjects = {}

--// TAPISAN KETAT: Hanya cari Objek Event/Point
local function IsValidPointObject(obj)
    if not obj:IsA("BasePart") then return false end
    if obj.Transparency >= 1 then return false end
    if obj.Name == "Baseplate" or obj.Name == "Terrain" then return false end

    local char = LocalPlayer.Character
    if char and obj:IsDescendantOf(char) then return false end

    local objName = string.lower(obj.Name)
    local parentName = obj.Parent and string.lower(obj.Parent.Name) or ""

    -- 1. UTAMA: Mesti mempunyai pemicu TouchInterest (Sebab kena sentuh untuk dapat point)
    local hasTouchTrigger = obj:FindFirstChildOfClass("TouchTransmitter") ~= nil

    -- 2. UTAMA: Mempunyai nilai mata (Value) di dalamnya
    local hasPointValue = false
    for _, child in pairs(obj:GetChildren()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("StringValue") then
            hasPointValue = true
            break
        end
    end

    -- 3. Kata Kunci Khas Event / Point / Flag
    local keywords = {"flag", "bendera", "point", "score", "event", "token", "coin"}
    local matchesKeyword = false
    for _, word in ipairs(keywords) do
        if string.find(objName, word) or string.find(parentName, word) then
            matchesKeyword = true
            break
        end
    end

    -- Objek dianggap VALID jika: (Ada Touch + Kata Kunci) ATAU (Ada Value Mata)
    if (hasTouchTrigger and matchesKeyword) or hasPointValue then
        return true
    end

    return false
end

--// Dapatkan Senarai Objek Point Khas sahaja
local function GetPointTargets()
    local targets = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if IsValidPointObject(obj) and not VisitedObjects[obj] then
            table.insert(targets, obj)
        end
    end
    return targets
end

--// Loop Pergerakan
local function StartAutoCollect()
    task.spawn(function()
        while AutoCollectActive do
            local targets = GetPointTargets()

            if #targets == 0 then
                VisitedObjects = {} -- Reset memori jika semua sudah disentuh
                StatusLabel.Text = "Status: Mengimbas semula..."
                task.wait(1)
                targets = GetPointTargets()
            end

            if #targets > 0 then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if hrp then
                    -- Susun ikut yang paling dekat
                    table.sort(targets, function(a, b)
                        return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
                    end)

                    local target = targets[1]
                    if target and target:IsDescendantOf(workspace) then
                        StatusLabel.Text = "Kutip: " .. target.Name
                        
                        -- Teleport betul-betul di tengah objek
                        hrp.CFrame = target.CFrame
                        
                        -- Tandakan objek yang telah diambil
                        VisitedObjects[target] = true
                    end
                end
            else
                StatusLabel.Text = "Status: Objek Event Point tidak dijumpai"
            end

            task.wait(0.3)
        end
    end)
end

--// Fungsi Butang
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
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
end

-- Butang Control
CreateButton("KUTIP 1 EVENT POINT", 85, Color3.fromRGB(40, 120, 220), function()
    local targets = GetPointTargets()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if hrp and #targets > 0 then
        table.sort(targets, function(a, b)
            return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
        end)
        hrp.CFrame = targets[1].CFrame
        StatusLabel.Text = "Pergi ke: " .. targets[1].Name
    else
        StatusLabel.Text = "Tiada Point Event Ditemui"
    end
end)

CreateButton("AUTO EVENT POINT: OFF", 135, Color3.fromRGB(40, 180, 90), function(btn)
    AutoCollectActive = not AutoCollectActive
    if AutoCollectActive then
        btn.Text = "AUTO EVENT POINT: ON"
        btn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        StartAutoCollect()
    else
        btn.Text = "AUTO EVENT POINT: OFF"
        btn.BackgroundColor3 = Color3.fromRGB(40, 180, 90)
        StatusLabel.Text = "Status: OFF"
    end
end)

CreateButton("CLEAR MEMORI COLLECT", 185, Color3.fromRGB(100, 100, 110), function()
    VisitedObjects = {}
    StatusLabel.Text = "Status: Memori Diclear"
end)
