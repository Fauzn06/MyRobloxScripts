local TargetName = "MerdekaPoint" -- Nama sebenar bendera/objek yang dicari
local TeleportSpeed = 25 -- Nilai lebih tinggi bermaksud bergerak lebih laju

--// Persediaan Asas
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")

print("Script Auto-Teleport MerdekaPoint Dimulakan!")

--// 1. Fungsi Mencari Objek Bendera di Seluruh Peta
local function FindTarget()
    local targetPart = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        -- Fokus pada objek yang dipanggil Part atau Model yang sepadan
        if obj.Name == TargetName then
            targetPart = obj
            break
        end
    end
    return targetPart
end

--// 2. Fungsi Teleport Diri (Auto-Move)
local function TeleportToPart(part)
    local cframe = part:IsA("Model") and part:GetPivot() or part.CFrame
    
    -- Set kelajuan bergerak untuk cepat sampai
    Humanoid.WalkSpeed = TeleportSpeed
    
    -- Set posisi badan terus ke koordinat objek
    RootPart.CFrame = cframe + Vector3.new(0, 3, 0) -- Naik sikit supaya tidak terbenam dalam tanah
    
    -- Kembalikan kelajuan asal jika perlu (optional)
    task.wait(0.1)
    Humanoid.WalkSpeed = 16 
end

--// 3. Loop Utama untuk Auto-Ambik Bendera
spawn(function()
    while true do
        local foundPart = FindTarget()
        
        if foundPart then
            -- Jika objek ditemui, terus teleport ke sana
            TeleportToPart(foundPart)
            print("Teleport ke: ", foundPart.Name)
        else
            -- Jika tiada objek, tunggu sebentar untuk mengelakkan lag
            print("Objek tidak ditemui, mencari semula...")
        end
        
        task.wait(0.5) -- Ulang carian setiap 0.5 saat
    end
end)

--// Nota: Jika permainan menggunakan mekanik "Sentuh" untuk mengautomasikan pengambilan,
--// Script ini sudah memadai kerana ia meletakkan anda terus di atas bendera.
--// Jika perlu, anda boleh tambah fungsi FireServer atau Touch di sini.
