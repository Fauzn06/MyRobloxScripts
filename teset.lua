local p = game.Players.LocalPlayer
local gui = p:WaitForChild("PlayerGui")
local mouse = p:GetMouse()
local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local rs = game:GetService("RunService")

local old = gui:FindFirstChild("UltraSmoothGui")
if old then old:Destroy() end

local sg = Instance.new("ScreenGui")
sg.Name = "UltraSmoothGui"
sg.ResetOnSpawn = false -- This is the line that keeps it on your screen after death
sg.Parent = gui

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 220, 0, 220)
f.Position = UDim2.new(0.5, -110, 0.5, -110)
f.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
f.BorderSizePixel = 0
f.ClipsDescendants = true
f.Active = true
f.Parent = sg

local corn = Instance.new("UICorner", f)
corn.CornerRadius = UDim.new(0, 15)

local cb = Instance.new("TextButton", f)
cb.Size = UDim2.new(0, 25, 0, 25)
cb.Position = UDim2.new(1, -35, 0, 10)
cb.Text = "×"
cb.TextColor3 = Color3.fromRGB(255, 80, 80)
cb.BackgroundTransparency = 1
cb.TextSize = 24
cb.Font = Enum.Font.GothamBold

local mb = Instance.new("TextButton", f)
mb.Size = UDim2.new(0, 25, 0, 25)
mb.Position = UDim2.new(1, -65, 0, 10)
mb.Text = "−"
mb.TextColor3 = Color3.new(1, 1, 1)
mb.BackgroundTransparency = 1
mb.TextSize = 24
mb.Font = Enum.Font.GothamBold

local cont = Instance.new("Frame", f)
cont.Size = UDim2.new(1, 0, 1, 0)
cont.BackgroundTransparency = 1

local function createL(txt, clr, y)
  local l = Instance.new("TextLabel", cont)
  l.Size = UDim2.new(1, 0, 0, 20)
  l.Position = UDim2.new(0, 0, y, 0)
  l.TextColor3 = clr
  l.Text = txt .. ": 0"
  l.Font = Enum.Font.Code
  l.TextSize = 18
  l.BackgroundTransparency = 1
  return l
end

local xl = createL("X", Color3.fromRGB(255, 80, 80), 0.15)
local yl = createL("Y", Color3.fromRGB(80, 255, 80), 0.25)
local zl = createL("Z", Color3.fromRGB(80, 180, 255), 0.35)

local function hov(b)
  b.MouseEnter:Connect(function()
    ts:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
  end)
  b.MouseLeave:Connect(function()
    ts:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
  end)
end

local function nb(txt, y)
  local b = Instance.new("TextButton", cont)
  b.Size = UDim2.new(0.8, 0, 0, 35)
  b.Position = UDim2.new(0.1, 0, y, 0)
  b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
  b.Text = txt
  b.TextColor3 = Color3.new(1, 1, 1)
  b.Font = Enum.Font.GothamBold
  Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
  hov(b)
  return b
end

local s_btn = nb("SAVE POSITION", 0.55)
local t_btn = nb("START TP LOOP", 0.75)

local mini = Instance.new("Frame", f)
mini.Size = UDim2.new(1, 0, 1, 0)
mini.BackgroundTransparency = 1
mini.Visible = false

local mt = Instance.new("TextLabel", mini)
mt.Size = UDim2.new(1, 0, 1, 0)
mt.Text = "XYZ"
mt.TextColor3 = Color3.new(1, 1, 1)
mt.Font = Enum.Font.GothamBold
mt.BackgroundTransparency = 1

local function boom()
  for i = 1, 15 do
    local part = Instance.new("Frame", sg)
    part.Size = UDim2.new(0, 6, 0, 6)
    part.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
    part.BackgroundColor3 = Color3.fromHSV(math.random(), 0.7, 1)
    Instance.new("UICorner", part).CornerRadius = UDim.new(1, 0)
    local tx, ty = math.random(-120, 120), math.random(-120, 120)
    ts:Create(part, TweenInfo.new(2.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
      Position = part.Position + UDim2.new(0, tx, 0, ty),
      BackgroundTransparency = 1,
      Rotation = math.random(0, 360)
    }):Play()
    task.delay(2.3, function() part:Destroy() end)
  end
end

local drag, dstart, spos, dinput
local tpos = f.Position
local ddist = 0
local is_m = false
