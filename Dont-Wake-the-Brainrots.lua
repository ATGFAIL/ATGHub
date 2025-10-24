-- ✅ Kick ถ้า PlaceId ไม่ตรงกับที่อนุญาต
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- รายการ Place ID ที่อนุญาตให้รันได้
local allowedPlaceIds = {
    118915549367482 -- ตัวแรก
}

-- ฟังก์ชันเช็กว่า ID ปัจจุบันอยู่ใน allowed หรือไม่
local function isAllowedPlace(id)
    for _, allowedId in ipairs(allowedPlaceIds) do
        if id == allowedId then
            return true
        end
    end
    return false
end

-- ถ้าไม่ตรงกับ ID ใด ๆ ใน allowed -> Kick แล้วหยุดรันต่อ
if not isAllowedPlace(game.PlaceId) then
    localPlayer:Kick("[ ATG ] NOT SUPPORT")
    return
end

repeat
    task.wait()
until game:IsLoaded()

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/ATGFAIL/ATGHub/Addons/autosave.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local camera = workspace.CurrentCamera

-- 🧠 ฟังก์ชันคำนวณขนาด UI ตามจอ
local function getWindowSize()
	local screen = camera.ViewportSize
	local width = math.clamp(screen.X * 0.6, 400, 600)
	local height = math.clamp(screen.Y * 0.6, 300, 500)
	return UDim2.fromOffset(width, height)
end

-- 🪟 สร้างหน้าต่าง Fluent
local Window = Fluent:CreateWindow({
	Title = "ATG Hub Freemium",
	SubTitle = "by ATGFAIL",
	TabWidth = 160,
	Size = getWindowSize(),
	Acrylic = true, -- ปิด/เปิด Blur
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.LeftControl
})

-- ⚡ ให้มันอัปเดตขนาดอัตโนมัติเมื่อขนาดจอเปลี่ยน
camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	task.wait(0.1) -- หน่วงนิดกัน error เวลาเปลี่ยนจอเร็ว
	Window:SetSize(getWindowSize())
end)

-- ตัวแปรยืนยันการอนุญาตให้สคริปต์ทำงานต่อ
local allowedToRun = false
local DISCORD_LINK = "https://discord.gg/uyRxC66fw6"
-- แสดง Dialog ให้ผู้เล่นกดปุ่มคัดลอกลิงก์เดียว
Window:Dialog({
    Title = "Join our Discord",
    Content = "Join Discord to Play",
    Buttons = {
        {
            Title = "Copy Link",
            Callback = function()
                -- พยายามคัดลอกลิงก์ (รองรับ exploit ที่มี setclipboard)
                local ok, err = pcall(function()
                    if setclipboard then
                        setclipboard(DISCORD_LINK)
                    end
                end)

                if ok then
                    -- แจ้งเตือนว่าคัดลอกเรียบร้อย (หรือแสดงลิงก์ ถ้า clipboard ไม่รองรับ)
                    Fluent:Notify({
                        Title = "Discord",
                        Content = "Copied" .. DISCORD_LINK,
                        Duration = 6
                    })
                end

                allowedToRun = true
            end
        }
    }
})

-- รอจนกว่าผู้เล่นจะกดปุ่ม (ถ้าไม่กด จะไม่ดำเนินโค้ดส่วนที่เหลือ)
-- ถ้า Fluent ถูก unload ให้หยุดทั้งหมดด้วย
while not allowedToRun do
    if Fluent.Unloaded then
        return
    end
    task.wait()
end

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "repeat" }),
    Humanoid = Window:AddTab({ Title = "Humanoid", Icon = "user" }),
    Players = Window:AddTab({ Title = "Players", Icon = "users" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "plane" }),
    Server = Window:AddTab({ Title = "Server", Icon = "server"}),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- -----------------------
-- Player Info Paragraph (Status Panel)
-- -----------------------

-- ประกาศตัวแปรที่ใช้
local startTime = tick() -- เวลาเริ่มสคริปต์
local infoParagraph = nil
local char = nil
local hum = nil
local content = ""

-- สร้าง Paragraph
infoParagraph = Tabs.Main:AddParagraph({
    Title = "Player Info",
    Content = "Loading player info..."
})

-- ฟังก์ชันช่วยเติมเลขให้เป็น 2 หลัก (เช่น 4 -> "04")
local function pad2(n)
    return string.format("%02d", tonumber(n) or 0)
end

-- ฟังก์ชันอัพเดทข้อมูล
local function updateInfo()
    -- รับตัวละคร / humanoid (ถ้ามี)
    char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    hum = char and char:FindFirstChildWhichIsA("Humanoid")

    -- เวลาที่เล่น (วินาที, ปัดลง)
    local playedSeconds = math.floor(tick() - startTime)

    -- แยกชั่วโมง นาที วินาที
    local hours = math.floor(playedSeconds / 3600)
    local minutes = math.floor((playedSeconds % 3600) / 60)
    local seconds = playedSeconds % 60

    -- วันที่ปัจจุบัน รูปแบบ DD/MM/YYYY
    local dateStr = os.date("%d/%m/%Y")

    -- สร้างข้อความที่จะโชว์ (เอา Health/WalkSpeed/JumpPower ออกแล้ว)
    content = string.format([[
Name: %s (@%s)
Date : %s

Played Time : %s : %s : %s
]],
        LocalPlayer.DisplayName or LocalPlayer.Name,
        LocalPlayer.Name or "Unknown",
        dateStr,
        pad2(hours),
        pad2(minutes),
        pad2(seconds)
    )

    -- อัปเดต Paragraph ใน UI
    pcall(function()
        infoParagraph:SetDesc(content)
    end)
end

-- loop update ทุกๆ 1 วิ
task.spawn(function()
    while true do
        if Fluent.Unloaded then break end
        pcall(updateInfo)
        task.wait(1)
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")
local lp = Players.LocalPlayer

local points = {
    Vector3.new(95.28, 25, -66.72),
    Vector3.new(96.42, 25, 63.51),
    Vector3.new(-101.88, 25, 62.47),
    Vector3.new(-103.72, 25, -63.54),
}

local idx = 1
local hbConn, charAddedConn
local locked = false
local originalCFrame

-- ตัวแปรสำหรับเก็บค่าที่เลือก
local selectedRarities = {}
local minCashValue = nil

local function getHRP(char) return char and char:FindFirstChild("HumanoidRootPart") end

-- ฟังก์ชันแปลง cash string เป็นตัวเลข (รองรับ k, m, b)
-- เช่น "$50/s" -> 50, "$2.36k/s" -> 2360, "$1.5m/s" -> 1500000
local function parseCashValue(cashText)
    if not cashText then return 0 end
    
    local text = tostring(cashText):lower()
    local num = string.match(text, "%$?([%d%.]+)")
    if not num then return 0 end
    
    local value = tonumber(num) or 0
    
    -- ตรวจสอบหน่วย k, m, b
    if string.find(text, "k") then
        value = value * 1000
    elseif string.find(text, "m") then
        value = value * 1000000
    elseif string.find(text, "b") then
        value = value * 1000000000
    end
    
    return value
end

-- ฟังก์ชันตรวจสอบว่า Model ตรงเงื่อนไขหรือไม่
local function checkModelConditions(model)
    if not model:IsA("Model") then return false end
    
    local rarityMatch = true
    local cashMatch = true
    
    -- ค้นหา TextLabel ใน Model
    local charRarityLabel = nil
    local charCashLabel = nil
    
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("TextLabel") then
            if descendant.Name == "CharRarity" then
                charRarityLabel = descendant
            elseif descendant.Name == "CharCash" then
                charCashLabel = descendant
            end
        end
    end
    
    -- ตรวจสอบ Rarity
    if next(selectedRarities) ~= nil then
        rarityMatch = false
        if charRarityLabel then
            local rarityText = charRarityLabel.Text
            for rarity, _ in pairs(selectedRarities) do
                if rarityText == rarity then
                    rarityMatch = true
                    break
                end
            end
        end
    end
    
    -- ตรวจสอบ Cash
    if minCashValue and minCashValue > 0 then
        cashMatch = false
        if charCashLabel then
            local cashValue = parseCashValue(charCashLabel.Text)
            if cashValue >= minCashValue then
                cashMatch = true
            end
        end
    end
    
    return rarityMatch and cashMatch
end

-- ฟังก์ชัน fire proximity prompt สำหรับ Model ที่ตรงเงื่อนไข (fire หลายรอบเพื่อความแน่ใจ)
local function fireProximityForModel(model, rounds)
    if not model:IsA("Model") then return false end
    
    rounds = rounds or 3 -- fire 3 รอบเป็นค่าเริ่มต้น
    local fired = false
    local promptCount = 0
    
    -- หา proximity prompts ทั้งหมดใน Model นี้
    local prompts = {}
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            table.insert(prompts, descendant)
            promptCount = promptCount + 1
        end
    end
    
    if promptCount > 0 then
        
        -- Fire หลายรอบเพื่อความแน่ใจ
        for round = 1, rounds do
            for _, prompt in ipairs(prompts) do
                pcall(function()
                    fireproximityprompt(prompt)
                    fired = true
                end)
                task.wait(0.05) -- delay เล็กน้อยระหว่าง prompt
            end
            
            if round < rounds then
                task.wait(0.2) -- รอก่อน fire รอบถัดไป
            end
        end
    end
    
    return fired
end

-- พยายามบังคับ workspace.<playerName>.Attributes.Ragdolled ให้เป็น false
local function enforceRagdollFalse()
    local w = workspace:FindFirstChild(lp.Name)
    if not w then return end
    if typeof(w.GetAttribute) == "function" then
        local ok, val = pcall(function() return w:GetAttribute("Ragdolled") end)
        if ok and val ~= false then
            pcall(function() w:SetAttribute("Ragdolled", false) end)
        end
        return
    end
    local attrs = w:FindFirstChild("Attributes")
    if attrs and attrs:IsA("Folder") then
        local rag = attrs:FindFirstChild("Ragdolled")
        if rag and (rag:IsA("BoolValue") or rag:IsA("ObjectValue")) then
            if rag.Value ~= false then
                pcall(function() rag.Value = false end)
            end
        end
    end
end

local function applyLockToCharacter(char)
    local hrp = getHRP(char)
    if hrp then
        local look = hrp.CFrame.LookVector
        pcall(function() hrp.CFrame = CFrame.new(points[idx], points[idx] + look) end)
    end
end

-- ฟังก์ชันวาปกลับฐานของผู้เล่น
local function teleportToBase()
    local b = workspace:FindFirstChild("Bases")
    if not b then return false end
    
    local c = lp.Character
    local hrp = getHRP(c)
    if not hrp then return false end
    
    for _, m in pairs(b:GetChildren()) do
        local s = m:FindFirstChild("Sign")
        local d = s and s:FindFirstChild("Display")
        local g = d and d:FindFirstChildOfClass("SurfaceGui")
        local l = g and g:FindFirstChild("PlayerName")
        if l and l:IsA("TextLabel") and l.Text == lp.Name then
            local cf = m.PrimaryPart and m.PrimaryPart.CFrame or
                      (m:FindFirstChildWhichIsA("BasePart", true) and
                       m:FindFirstChildWhichIsA("BasePart", true).CFrame)
            if cf then
                pcall(function()
                    hrp.CFrame = cf + Vector3.new(0, 5, 0)
                end)
                return true
            end
        end
    end
    return false
end

-- ฟังก์ชันวาปไปยัง Model และ fire proximity prompt
local function teleportAndFire(model)
    if not model:IsA("Model") or not model.PrimaryPart then return end
    
    local hrp = getHRP(lp.Character)
    if not hrp then return end
    
    -- วาปไปที่ Model
    pcall(function()
        hrp.CFrame = model.PrimaryPart.CFrame + Vector3.new(0, 3, 0)
    end)
    
    task.wait(0.4)
    
    -- Fire proximity prompt (3-5 รอบเพื่อความแน่ใจ)
    fireProximityForModel(model, 5)
    
    task.wait(0.1)
    teleportToBase()
    
    task.wait(1)
end

local function startLock()
    local hrp = getHRP(lp.Character)
    if hrp then originalCFrame = hrp.CFrame end
    locked = true

    if hbConn then hbConn:Disconnect() hbConn = nil end
    hbConn = RunService.Heartbeat:Connect(function()
        local hrpNow = getHRP(lp.Character)
        if hrpNow then
            local look = hrpNow.CFrame.LookVector
            pcall(function()
                hrpNow.CFrame = CFrame.new(points[idx], points[idx] + look)
                hrpNow.Velocity = Vector3.new(0,0,0)
                hrpNow.RotVelocity = Vector3.new(0,0,0)
            end)
        end
        pcall(enforceRagdollFalse)
    end)

    if charAddedConn then charAddedConn:Disconnect() charAddedConn = nil end
    charAddedConn = lp.CharacterAdded:Connect(function(char)
        task.delay(0.05, function() applyLockToCharacter(char); enforceRagdollFalse() end)
    end)

    applyLockToCharacter(lp.Character)
    enforceRagdollFalse()

    -- Loop วาปและตรวจสอบเงื่อนไข
    spawn(function()
        while locked do
            -- ตรวจสอบว่ามีการตั้งค่าฟิลเตอร์หรือไม่
            local hasFilter = (next(selectedRarities) ~= nil) or (minCashValue and minCashValue > 0)
            
            if hasFilter then
                -- เช็ค Model ทั้งหมดใน Brainrots
                local folder = workspace:FindFirstChild("Brainrots")
                if folder then
                    for _, model in ipairs(folder:GetChildren()) do
                        if not locked then break end
                        
                        -- เช็คเฉพาะ Model ที่ตรงเงื่อนไข
                        if checkModelConditions(model) then
                            
                            -- หยุด heartbeat ชั่วคราว
                            if hbConn then hbConn:Disconnect() hbConn = nil end
                            
                            -- วาปและ fire เฉพาะ Model นี้
                            teleportAndFire(model)
                            
                            -- เปิด heartbeat อีกครั้ง
                            if locked then
                                hbConn = RunService.Heartbeat:Connect(function()
                                    local hrpNow = getHRP(lp.Character)
                                    if hrpNow then
                                        local look = hrpNow.CFrame.LookVector
                                        pcall(function()
                                            hrpNow.CFrame = CFrame.new(points[idx], points[idx] + look)
                                            hrpNow.Velocity = Vector3.new(0,0,0)
                                            hrpNow.RotVelocity = Vector3.new(0,0,0)
                                        end)
                                    end
                                    pcall(enforceRagdollFalse)
                                end)
                            end
                        end
                    end
                end
            end
            
            -- เปลี่ยนจุดถัดไป
            task.wait(1)
            if not locked then break end
            idx = idx % #points + 1
        end
    end)
end

local function stopLock()
    locked = false
    if hbConn then hbConn:Disconnect() hbConn = nil end
    if charAddedConn then charAddedConn:Disconnect() charAddedConn = nil end
    if originalCFrame and lp.Character then
        local hrp = getHRP(lp.Character)
        if hrp then pcall(function() hrp.CFrame = originalCFrame end) end
    end
    originalCFrame = nil
end

-- UI Setup
local Section = Tabs.Main:AddSection("Auto Brainrots")

-- Multi Dropdown สำหรับ Rarity
local RarityDropdown = Tabs.Main:AddDropdown("RarityDropdown", {
    Title = "Select Rarity",
    Description = "เลือก Rarity",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"},
    Multi = true,
    Default = {},
})

RarityDropdown:OnChanged(function(Value)
    selectedRarities = {}
    for rarity, state in pairs(Value) do
        if state then
            selectedRarities[rarity] = true
        end
    end
    
    local selected = {}
    for rarity, _ in pairs(selectedRarities) do
        table.insert(selected, rarity)
    end
    
    if #selected > 0 then
    else
    end
end)

-- Input สำหรับ Cash
local CashInput = Tabs.Main:AddInput("CashInput", {
    Title = "Minimum Cash Value",
    Description = "เลือกจำนวนเงิน",
    Default = "",
    Placeholder = "เช่น 50 ($50/s ขึ้นไป)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            minCashValue = num
        else
            minCashValue = nil
        end
    end
})

-- Toggle สำหรับเปิด/ปิด Auto
local Toggle = Tabs.Main:AddToggle("PatrolToggle", { 
    Title = "Auto Brainrots",
    Description = "ออโต้เก็บเบนรอท",
    Default = false 
})

Toggle:OnChanged(function(on)
    if on then 
        startLock() 
    else 
        stopLock()
    end
end)

if Options.PatrolToggle then 
    Options.PatrolToggle:SetValue(false) 
end

local Players = game:GetService("Players")
local workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
if not player then return end

-- ฟังก์ชัน: แตะ (touch) ทุกรายการใน CandyPickups
local function touchCandyPickups()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return warn("No HumanoidRootPart") end

    local folder = workspace:FindFirstChild("CandyPickups")
    if not folder then
        warn("No CandyPickups folder found")
        return
    end

    local count = 0
    for _, model in ipairs(folder:GetChildren()) do
        if model:IsA("Model") then
            local target = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            if target and target:IsA("BasePart") then
                pcall(function()
                    -- touch
                    firetouchinterest(target, hrp, 0)
                    wait(0.02)
                    firetouchinterest(target, hrp, 1)
                end)
                count = count + 1
            end
        end
    end

    print(("Touched %d candy models"):format(count))
end

-- ฟังก์ชัน: แตะ (touch) ทุก Collect ใน Bases ที่เป็นของผู้เล่น
local function touchMyBaseCollects()
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return warn("No HumanoidRootPart") end

    local bases = workspace:FindFirstChild("Bases")
    if not bases then
        warn("No Bases folder found")
        return
    end

    local targets = {}
    for _, m in pairs(bases:GetChildren()) do
        local sign = m:FindFirstChild("Sign")
        local disp = sign and sign:FindFirstChild("Display")
        local gui = disp and disp:FindFirstChildOfClass("SurfaceGui")
        local lbl = gui and gui:FindFirstChild("PlayerName")
        if lbl and lbl:IsA("TextLabel") and lbl.Text == player.Name then
            local plats = m:FindFirstChild("Platforms")
            if plats then
                for _, f in pairs(plats:GetChildren()) do
                    if f:IsA("Folder") then
                        for _, part in pairs(f:GetChildren()) do
                            if part:IsA("BasePart") and part.Name == "Collect" then
                                table.insert(targets, part)
                            end
                        end
                    end
                end
            end
        end
    end

    if #targets == 0 then
        warn("No Collect targets found for player")
        return
    end

    for _, part in pairs(targets) do
        pcall(function()
            firetouchinterest(part, hrp, 0)
            wait(0.02)
            firetouchinterest(part, hrp, 1)
        end)
    end

    print(("Touched %d collect parts"):format(#targets))
end
local Section = Tabs.Main:AddSection("Auto Collect")
local CollectToggle = Tabs.Main:AddToggle("AutoCollect", {Title = "Auto Collect Money", Description = "ออโต้เก็บเงิน", Default = false})
local CollectLoopRunning = false
CollectToggle:OnChanged(function()
    local enabled = Options.AutoCollect and Options.AutoCollect.Value or false
    if enabled and not CollectLoopRunning then
        CollectLoopRunning = true
        spawn(function()
            while CollectLoopRunning do
                pcall(touchMyBaseCollects)
                -- รอ 2 วินาทีเพื่อลดแลค
                for i=1,4 do
                    if not CollectLoopRunning then break end
                    wait(0.5)
                end
            end
        end)
    else
        CollectLoopRunning = false
    end
end)
if Options.AutoCollect then Options.AutoCollect:SetValue(false) end
local CandyToggle = Tabs.Main:AddToggle("AutoCandy", {Title = "Auto Collect Candy", Description = "ออโต้เก็บลูกอม", Default = false})
local CandyLoopRunning = false
CandyToggle:OnChanged(function()
    local enabled = Options.AutoCandy and Options.AutoCandy.Value or false
    if enabled and not CandyLoopRunning then
        CandyLoopRunning = true
        spawn(function()
            while CandyLoopRunning do
                pcall(touchCandyPickups)
                for i=1,4 do
                    if not CandyLoopRunning then break end
                    wait(0.5)
                end
            end
        end)
    else
        CandyLoopRunning = false
    end
end)
if Options.AutoCandy then Options.AutoCandy:SetValue(false) end
Tabs.Main:AddButton({
    Title = "Collect Candy",
    Description = "เก็บลูกอม",
    Callback = function()
        touchCandyPickups()
    end
})
Tabs.Main:AddButton({
    Title = "Collect Money",
    Description = "เก็บเงิน",
    Callback = function()
        touchMyBaseCollects()
    end
})

local rs = game:GetService("ReplicatedStorage")
local remote = rs:WaitForChild("Remotes"):WaitForChild("AttemptRebirthRemote")

local running = false
local conn
local Section = Tabs.Main:AddSection("Auto Rebirth")
local Toggle = Tabs.Main:AddToggle("AutoRebirth", {Title = "Auto Rebirth", Description = "ออโต้รีเบิท", Default = false})
Toggle:OnChanged(function(on)
    running = on
    if running then
        conn = task.spawn(function()
            while running do
                pcall(function() remote:InvokeServer() end)
                task.wait(5)
            end
        end)
    else
        running = false
    end
end)
if Options.AutoRebirth then Options.AutoRebirth:SetValue(false) end

--==========================================================
--                 Teleport Zone
--==========================================================
Tabs.Teleport:AddButton(
    {
        Title = "Teleport To Base",
        Description = "วาปกลับบ้าน",
        Callback = function()
            local p = game.Players.LocalPlayer
            local b = workspace:FindFirstChild("Bases")
            if not b then
                return
            end
            local c = p.Character or p.CharacterAdded:Wait()
            local hrp = c:WaitForChild("HumanoidRootPart", 5)
            for _, m in pairs(b:GetChildren()) do
                local s = m:FindFirstChild("Sign")
                local d = s and s:FindFirstChild("Display")
                local g = d and d:FindFirstChildOfClass("SurfaceGui")
                local l = g and g:FindFirstChild("PlayerName")
                if l and l:IsA("TextLabel") and l.Text == p.Name then
                    local cf =
                        m.PrimaryPart and m.PrimaryPart.CFrame or
                        (m:FindFirstChildWhichIsA("BasePart", true) and
                            m:FindFirstChildWhichIsA("BasePart", true).CFrame)
                    if cf then
                        hrp.CFrame = cf + Vector3.new(0, 5, 0)
                    else
                    end
                end
            end
        end
    }
)


do
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local Workspace = workspace

    -- assume UI libs exist
    if not Tabs.Players then Tabs.Players = Window:AddTab({ Title = "Teleport" }) end
    local PlayerSection = Tabs.Players:AddSection("Player")
    local TeleportSection = Tabs.Players:AddSection("Teleport")

    -- UI
    local playerListDropdown = PlayerSection:AddDropdown("TeleportToPlayerDropdown", {
        Title = "Player", Values = {}, Multi = false, Default = 1
    })
    PlayerSection:AddButton({ Title = "Refresh list", Description = "รีเฟชรายชื่อผู้เล่น", Callback = function()
        local vals = {}
        for _, p in ipairs(Players:GetPlayers()) do if p ~= Players.LocalPlayer then table.insert(vals, p.Name) end end
        if #vals == 0 then vals = {"No players"} end
        playerListDropdown:SetValues(vals)
        playerListDropdown:SetValue(vals[1])
    end})

    local TeleportMethodDropdown = TeleportSection:AddDropdown("TeleportMethod", {
        Title = "Method", Description = "Instant / Tween / MoveTo",
        Values = {"Instant","Tween","MoveTo"}, Multi = false, Default = 1
    })
    TeleportSection:AddButton({ Title = "Teleport Now", Description = "วาปทันทีไปคนที่เลือก", Callback = function()
        local sel = playerListDropdown.Value
        if not sel or sel == "No players" then return end
        local target = Players:FindFirstChild(sel)
        if target then task.spawn(function() _G.TeleportToPlayerModule.TeleportTo(target) end) end
    end})
    local AutoFollowToggle = TeleportSection:AddToggle("TeleportAutoFollowToggle", { Title = "Auto-Follow", Description = "ติดตามผู้เล่น", Default = false })

    -- config (set here, not UI)
    local Y_OFFSET = 0
    local TWEEN_TIME = 0.001
    local COOLDOWN = 0.001
    local SAFE_GROUND_MAX_DIST = 20
    local TWEEN_TIMEOUT = 3
    local MOVETO_TIMEOUT = 4

    local LocalPlayer = Players.LocalPlayer
    local LastTeleport = 0
    local TeleportDebounce = false
    local ActiveTweens = {}
    local AutoFollowConn

    local function getHRP(p)
        if not p or not p.Character then return nil end
        return p.Character:FindFirstChild("HumanoidRootPart") or p.Character.PrimaryPart
    end
    local function getLocalHRP()
        if not LocalPlayer or not LocalPlayer.Character then return nil end
        return LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.PrimaryPart
    end

    local function raycastDown(fromPos, maxDist)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = { LocalPlayer.Character }
        params.IgnoreWater = true
        return Workspace:Raycast(fromPos, Vector3.new(0, -maxDist, 0), params)
    end
    local function isGroundBelow(pos, maxDist)
        local r = raycastDown(pos, maxDist or SAFE_GROUND_MAX_DIST)
        if r and r.Position then return true, r.Position end
        return false, nil
    end

    local function playTweenNonBlocking(instance, prop, time, cb)
        local info = TweenInfo.new(math.max(0.01, time), Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(instance, info, prop)
        ActiveTweens[tween] = true
        local done = false
        local con; con = tween.Completed:Connect(function() done=true; ActiveTweens[tween]=nil; con:Disconnect(); if cb then pcall(cb,true) end end)
        tween:Play()
        task.spawn(function()
            local t0 = tick()
            while not done and tick()-t0 < TWEEN_TIMEOUT do task.wait(0.05) end
            if not done then pcall(function() tween:Cancel() end) ActiveTweens[tween]=nil if con and con.Connected then con:Disconnect() end if cb then pcall(cb,false) end end
        end)
    end

    local function teleportToPlayer(player)
        if TeleportDebounce then return false end
        if not player or not player.Parent then return false end
        if tick() - LastTeleport < COOLDOWN then return false end
        LastTeleport = tick()
        TeleportDebounce = true
        task.delay(0.05, function() TeleportDebounce = false end)

        local targetHRP = getHRP(player)
        local localHRP = getLocalHRP()
        if not localHRP then return false end

        local baseCF = (targetHRP and targetHRP.CFrame) or (player.Character and player.Character:GetModelCFrame())
        if not baseCF then return false end
        local destPos = baseCF.Position + Vector3.new(0, Y_OFFSET, 0)

        local ok, gp = isGroundBelow(destPos, SAFE_GROUND_MAX_DIST)
        if not ok then
            local found = false
            local tryPos = destPos
            for i=1,6 do
                tryPos = tryPos - Vector3.new(0,2,0)
                local ok2, g2 = isGroundBelow(tryPos, 2.5)
                if ok2 then destPos = Vector3.new(destPos.X, g2.Y+1.2, destPos.Z); found = true; break end
            end
            if not found then return false end
        else
            destPos = Vector3.new(destPos.X, gp.Y+1.2, destPos.Z)
        end

        local method = TeleportMethodDropdown and TeleportMethodDropdown.Value or "Instant"
        if method == "Instant" then
            pcall(function() localHRP.CFrame = CFrame.new(destPos) end)
            return true
        elseif method == "Tween" then
            pcall(function() playTweenNonBlocking(localHRP, {CFrame = CFrame.new(destPos)}, TWEEN_TIME) end)
            return true
        elseif method == "MoveTo" then
            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and typeof(humanoid.MoveTo) == "function" then
                local done=false
                local con = humanoid.MoveToFinished:Connect(function() done=true; if con and con.Connected then con:Disconnect() end end)
                pcall(function() humanoid:MoveTo(destPos) end)
                task.spawn(function()
                    local t0=tick()
                    while not done and tick()-t0 < MOVETO_TIMEOUT do task.wait(0.05) end
                    if not done then pcall(function() localHRP.CFrame = CFrame.new(destPos) end) if con and con.Connected then con:Disconnect() end end
                end)
                return true
            else
                pcall(function() localHRP.CFrame = CFrame.new(destPos) end)
                return true
            end
        else
            pcall(function() localHRP.CFrame = CFrame.new(destPos) end)
            return true
        end
    end

    -- ===== new real-time sticky follow implementation =====
    local function startAutoFollow()
        if AutoFollowConn then return end
        AutoFollowConn = RunService.Heartbeat:Connect(function()
            local sel = playerListDropdown.Value
            if not sel or sel == "No players" then return end

            local target = Players:FindFirstChild(sel)
            if not target or not target.Parent then return end

            local targetHRP = getHRP(target)
            local localHRP = getLocalHRP()
            if not targetHRP or not localHRP then return end

            -- set local HRP CFrame to target HRP CFrame every frame (sticky)
            -- include Y_OFFSET if you want to offset vertically
            local ok, _ = pcall(function()
                localHRP.CFrame = targetHRP.CFrame * CFrame.new(0, Y_OFFSET, 0)
            end)
            -- if pcall fails (e.g., during respawn), just silently continue; next frame will re-check
        end)
    end

    local function stopAutoFollow()
        if AutoFollowConn then
            AutoFollowConn:Disconnect()
            AutoFollowConn = nil
        end
    end

    AutoFollowToggle:OnChanged(function(v) if v then startAutoFollow() else stopAutoFollow() end end)

    local function refreshPlayerDropdown()
        local vals = {}
        for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(vals, p.Name) end end
        if #vals == 0 then vals = {"No players"} end
        playerListDropdown:SetValues(vals)
        playerListDropdown:SetValue(vals[1])
    end

    -- initial fill (no continuous listeners)
    refreshPlayerDropdown()

    local function cleanup()
        stopAutoFollow()
        for t,_ in pairs(ActiveTweens) do pcall(function() t:Cancel() end) ActiveTweens[t]=nil end
    end

    _G.TeleportToPlayerModule = {
        TeleportTo = teleportToPlayer,
        RefreshPlayers = refreshPlayerDropdown,
        Cleanup = cleanup
    }
end



local Section = Tabs.Humanoid:AddSection("Speed & Jump")
-- wait for LocalPlayer if not ready (safe in LocalScript)
if not LocalPlayer or typeof(LocalPlayer) == "Instance" and LocalPlayer.ClassName == "" then
    LocalPlayer = Players.LocalPlayer
end

do
    -- config
    local enforcementRate = 0.1 -- วินาที (0.1 = 10 ครั้ง/วินาที) -> ตอบสนองดีขึ้น แต่ไม่เกินไป
    local WalkMin, WalkMax = 8, 200
    local JumpMin, JumpMax = 10, 300

    local DesiredWalkSpeed = 16
    local DesiredJumpPower = 50

    local WalkEnabled = false
    local JumpEnabled = false

    -- เก็บค่าเดิมของ humanoid (weak table ตาม instance)
    local originalValues = setmetatable({}, { __mode = "k" })

    local currentHumanoid = nil
    local heartbeatConn = nil
    local lastApplyTick = 0

    local function clamp(v, a, b)
        if v < a then return a end
        if v > b then return b end
        return v
    end

    local function findHumanoid()
        if not Players.LocalPlayer then return nil end
        local char = Players.LocalPlayer.Character
        if not char then return nil end
        return char:FindFirstChildWhichIsA("Humanoid")
    end

    local function saveOriginal(hum)
        if not hum then return end
        if not originalValues[hum] then
            local ok, ws, jp, usejp = pcall(function()
                return hum.WalkSpeed, hum.JumpPower, hum.UseJumpPower
            end)
            if ok then
                originalValues[hum] = { WalkSpeed = ws or 16, JumpPower = jp or 50, UseJumpPower = usejp }
            else
                originalValues[hum] = { WalkSpeed = 16, JumpPower = 50, UseJumpPower = true }
            end
        end
    end

    local function restoreOriginal(hum)
        if not hum then return end
        local orig = originalValues[hum]
        if orig then
            pcall(function()
                if orig.UseJumpPower ~= nil then
                    hum.UseJumpPower = orig.UseJumpPower
                end
                hum.WalkSpeed = orig.WalkSpeed or 16
                hum.JumpPower = orig.JumpPower or 50
            end)
            originalValues[hum] = nil
        end
    end

    local function applyToHumanoid(hum)
        if not hum then return end
        saveOriginal(hum)

        -- Walk
        if WalkEnabled then
            local desired = clamp(math.floor(DesiredWalkSpeed + 0.5), WalkMin, WalkMax)
            if hum.WalkSpeed ~= desired then
                pcall(function() hum.WalkSpeed = desired end)
            end
        end

        -- Jump: ensure UseJumpPower true, then set JumpPower
        if JumpEnabled then
            pcall(function()
                -- set UseJumpPower true to ensure JumpPower is respected
                if hum.UseJumpPower ~= true then
                    hum.UseJumpPower = true
                end
            end)

            local desiredJ = clamp(math.floor(DesiredJumpPower + 0.5), JumpMin, JumpMax)
            if hum.JumpPower ~= desiredJ then
                pcall(function() hum.JumpPower = desiredJ end)
            end
        end
    end

    local function startEnforcement()
        if heartbeatConn then return end
        local acc = 0
        heartbeatConn = RunService.Heartbeat:Connect(function(dt)
            acc = acc + dt
            if acc < enforcementRate then return end
            acc = 0

            local hum = findHumanoid()
            if hum then
                currentHumanoid = hum
                -- apply only when enabled; if both disabled, avoid applying
                if WalkEnabled or JumpEnabled then
                    applyToHumanoid(hum)
                end
            else
                -- no humanoid: clear currentHumanoid
                currentHumanoid = nil
            end
        end)
    end

    local function stopEnforcement()
        if heartbeatConn then
            heartbeatConn:Disconnect()
            heartbeatConn = nil
        end
    end

    -- Toggle handlers
    local function setWalkEnabled(v)
        WalkEnabled = not not v
        if WalkEnabled then
            -- immediately apply
            local hum = findHumanoid()
            if hum then
                applyToHumanoid(hum)
            end
            startEnforcement()
        else
            -- restore walk value on current humanoid if we recorded it
            if currentHumanoid then
                -- only restore WalkSpeed (not touching Jump here)
                local orig = originalValues[currentHumanoid]
                if orig and orig.WalkSpeed ~= nil then
                    pcall(function() currentHumanoid.WalkSpeed = orig.WalkSpeed end)
                end
            end

            -- if both disabled, we can stop enforcement and restore jump if needed
            if not JumpEnabled then
                if currentHumanoid then
                    restoreOriginal(currentHumanoid)
                end
                stopEnforcement()
            end
        end
    end

    local function setJumpEnabled(v)
        JumpEnabled = not not v
        if JumpEnabled then
            local hum = findHumanoid()
            if hum then
                applyToHumanoid(hum)
            end
            startEnforcement()
        else
            if currentHumanoid then
                -- restore JumpPower and UseJumpPower
                local orig = originalValues[currentHumanoid]
                if orig and (orig.JumpPower ~= nil or orig.UseJumpPower ~= nil) then
                    pcall(function()
                        if orig.UseJumpPower ~= nil then
                            currentHumanoid.UseJumpPower = orig.UseJumpPower
                        end
                        if orig.JumpPower ~= nil then
                            currentHumanoid.JumpPower = orig.JumpPower
                        end
                    end)
                end
            end

            if not WalkEnabled then
                if currentHumanoid then
                    restoreOriginal(currentHumanoid)
                end
                stopEnforcement()
            end
        end
    end

    -- sliders callbacks
    local function setWalkSpeed(v)
        DesiredWalkSpeed = clamp(v, WalkMin, WalkMax)
        if WalkEnabled then
            local hum = findHumanoid()
            if hum then applyToHumanoid(hum) end
            startEnforcement()
        end
    end

    local function setJumpPower(v)
        DesiredJumpPower = clamp(v, JumpMin, JumpMax)
        if JumpEnabled then
            local hum = findHumanoid()
            if hum then applyToHumanoid(hum) end
            startEnforcement()
        end
    end

    -- CharacterAdded handling to apply as soon as possible
    if Players.LocalPlayer then
        Players.LocalPlayer.CharacterAdded:Connect(function(char)
            -- small wait for humanoid to exist
            local hum = nil
            for i = 1, 20 do
                hum = char:FindFirstChildWhichIsA("Humanoid")
                if hum then break end
                task.wait(0.05)
            end
            if hum and (WalkEnabled or JumpEnabled) then
                applyToHumanoid(hum)
                startEnforcement()
            end
        end)
    end

    -- UI
    local speedSlider = Section:AddSlider("WalkSpeedSlider", {
        Title = "WalkSpeed",
        Default = DesiredWalkSpeed, Min = WalkMin, Max = WalkMax, Rounding = 0,
        Callback = function(Value) setWalkSpeed(Value) end
    })
    speedSlider:OnChanged(setWalkSpeed)

    local jumpSlider = Section:AddSlider("JumpPowerSlider", {
        Title = "JumpPower",
        Default = DesiredJumpPower, Min = JumpMin, Max = JumpMax, Rounding = 0,
        Callback = function(Value) setJumpPower(Value) end
    })
    jumpSlider:OnChanged(setJumpPower)

    local walkToggle = Section:AddToggle("EnableWalkToggle", {
        Title = "Enable Walk",
        Description = "เปิด/ปิดการบังคับ WalkSpeed",
        Default = WalkEnabled,
        Callback = function(value) setWalkEnabled(value) end
    })
    walkToggle:OnChanged(setWalkEnabled)

    local jumpToggle = Section:AddToggle("EnableJumpToggle", {
        Title = "Enable Jump",
        Description = "เปิด/ปิดการบังคับ JumpPower",
        Default = JumpEnabled,
        Callback = function(value) setJumpEnabled(value) end
    })
    jumpToggle:OnChanged(setJumpEnabled)

    Section:AddButton({
        Title = "Reset to defaults",
        Description = "คืนค่า Walk/Jump ไปค่าเริ่มต้น (16, 50)",
        Callback = function()
            DesiredWalkSpeed = 16
            DesiredJumpPower = 50
            speedSlider:SetValue(DesiredWalkSpeed)
            jumpSlider:SetValue(DesiredJumpPower)
            if WalkEnabled or JumpEnabled then
                local hum = findHumanoid()
                if hum then applyToHumanoid(hum) end
            end
        end
    })

    -- start enforcement if either is enabled initially
    if WalkEnabled or JumpEnabled then startEnforcement() end
end
-- -----------------------
-- Setup
-- -----------------------
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- state table
local state = {
    flyEnabled = false,
    noclipEnabled = false,
    espEnabled = false,
    espTable = {}
}

-- ใช้ Fluent:Notify แทน
local function notify(title, content, duration)
    Fluent:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3
    })
end

-- ============================
-- Fly & Noclip (รองรับมือถือ) - เวอร์ชันแก้บั๊ก
-- ============================

local Section = Tabs.Humanoid:AddSection("Fly & Noclip")
do
    local state = {flyEnabled = false, noclipEnabled = false}
    local bindName = "ATG_FlyStep"
    local fly = {bv = nil, bg = nil, speed = 60, smoothing = 0.35, bound = false, conn = nil}
    local savedCanCollide = {}

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local ContextActionService = game:GetService("ContextActionService")

    local function getHRP()
        local char = LocalPlayer.Character
        if not char then
            char = LocalPlayer.CharacterAdded:Wait()
        end
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function createForces(hrp)
        if not hrp then
            return
        end
        if not fly.bv then
            fly.bv = Instance.new("BodyVelocity")
            fly.bv.Name = "ATG_Fly_BV"
            fly.bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            fly.bv.P = 1250
        end
        if not fly.bg then
            fly.bg = Instance.new("BodyGyro")
            fly.bg.Name = "ATG_Fly_BG"
            fly.bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            fly.bg.D = 1000
        end
        fly.bv.Parent = hrp
        fly.bg.Parent = hrp
    end

    local function destroyForces()
        if fly.bv then
            pcall(
                function()
                    fly.bv:Destroy()
                end
            )
            fly.bv = nil
        end
        if fly.bg then
            pcall(
                function()
                    fly.bg:Destroy()
                end
            )
            fly.bg = nil
        end
    end

    -- API สำหรับปุ่มมือถือ (ให้ GUI เรียกใช้)
    local ascendPressed, descendPressed = false, false
    local flyControls = {}
    function flyControls.SetAscend(v)
        ascendPressed = v and true or false
    end
    function flyControls.SetDescend(v)
        descendPressed = v and true or false
    end

    -- Bind keyboard keys via ContextActionService แต่ไม่ "กิน" input ถ้า Fly ปิดอยู่
    ContextActionService:BindAction(
        "ATG_Fly_AscendKey",
        function(name, inputState, inputObj)
            -- ถ้า Fly ปิด ให้คืน pass เพื่อไม่ขัดการกระโดดปกติของเกม
            if not state.flyEnabled then
                return Enum.ContextActionResult.Pass
            end
            ascendPressed = (inputState == Enum.UserInputState.Begin)
            return Enum.ContextActionResult.Sink
        end,
        false,
        Enum.KeyCode.Space
    )

    ContextActionService:BindAction(
        "ATG_Fly_DescendKey",
        function(name, inputState, inputObj)
            if not state.flyEnabled then
                return Enum.ContextActionResult.Pass
            end
            descendPressed = (inputState == Enum.UserInputState.Begin)
            return Enum.ContextActionResult.Sink
        end,
        false,
        Enum.KeyCode.LeftControl
    )

    local function bindFlyStep()
        if fly.bound then
            return
        end
        fly.bound = true

        -- ใช้ Heartbeat สำหรับ physics-consistent updates (ดีกว่า render step บนมือถือ)
        fly.conn =
            RunService.Heartbeat:Connect(
            function(delta)
                if Fluent and Fluent.Unloaded then
                    destroyForces()
                    if fly.conn then
                        fly.conn:Disconnect()
                        fly.conn = nil
                    end
                    fly.bound = false
                    return
                end
                if not state.flyEnabled then
                    return
                end
                local char = LocalPlayer.Character
                if not char then
                    return
                end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp or not fly.bv or not fly.bg then
                    return
                end
                local cam = workspace.CurrentCamera
                if not cam then
                    return
                end

                -- 1) พยายามใช้ Keyboard (ถ้ามี)
                local moveDir = Vector3.new()
                local isKeyboard = UserInputService.KeyboardEnabled

                if isKeyboard then
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDir = moveDir + cam.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDir = moveDir - cam.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDir = moveDir - cam.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDir = moveDir + cam.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or ascendPressed then
                        moveDir = moveDir + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or descendPressed then
                        moveDir = moveDir - Vector3.new(0, 1, 0)
                    end
                else
                    -- 2) มือถือ/จอย: ใช้ Humanoid.MoveDirection เป็นหลัก (joystick ของ Roblox จะกรอกค่านี้)
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        local hd = humanoid.MoveDirection -- Vector3 in world space
                        if hd and hd.Magnitude > 0 then
                            -- เก็บเฉพาะแกน XZ เป็นการเคลื่อนที่แนวนอน
                            local horizontal = Vector3.new(hd.X, 0, hd.Z)
                            if horizontal.Magnitude > 0 then
                                -- แก้: Lua ไม่มี += -> ใช้ assignment เต็ม
                                moveDir = moveDir + horizontal.Unit * horizontal.Magnitude
                            end
                        end
                        -- ขึ้น: ใช้ทั้ง Jump และปุ่ม GUI ascend
                        if humanoid.Jump or ascendPressed then
                            moveDir = moveDir + Vector3.new(0, 1, 0)
                        end
                        -- ลง: ถ้ามีปุ่ม descend (GUI) ให้ใช้ก่อน
                        if descendPressed then
                            moveDir = moveDir - Vector3.new(0, 1, 0)
                        else
                            -- ถ้าผู้เล่นผลักจอย "ถอยหลัง" ต่อกล้อง (backwards) ให้ตีความเป็น descend (มือถือจะลงง่ายขึ้น)
                            if humanoid.MoveDirection and humanoid.MoveDirection.Magnitude > 0 then
                                local camForward = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
                                if camForward.Magnitude > 0 then
                                    local forwardDot = humanoid.MoveDirection.Unit:Dot(camForward.Unit)
                                    -- forwardDot < -0.5 => กำลังผลักย้อนกลับ (ถอยหลัง) относительноกล้อง
                                    if forwardDot < -0.5 then
                                        moveDir = moveDir - Vector3.new(0, 1, 0)
                                    end
                                end
                            end
                        end
                    else
                        -- fallback: ถ้ามือถือแต่ไม่มี Humanoid (แปลว่ามีปัญหา) ให้ใช้ ascend/descend ที่ผูกด้วยปุ่ม
                        if ascendPressed then
                            moveDir = moveDir + Vector3.new(0, 1, 0)
                        end
                        if descendPressed then
                            moveDir = moveDir - Vector3.new(0, 1, 0)
                        end
                    end
                end

                -- 3) Normalize และปรับความเร็ว
                local targetVel = Vector3.new()
                if moveDir.Magnitude > 0 then
                    targetVel = moveDir.Unit * fly.speed
                end
                -- Lerp velocity ให้ smooth
                fly.bv.Velocity = fly.bv.Velocity:Lerp(targetVel, math.clamp(fly.smoothing, 0, 1))

                -- จัดทิศทาง BodyGyro ให้หันไปตามกล้อง แต่รักษาจุดอ้างอิงเป็นตำแหน่ง HRP
                -- ป้องกันการเปลี่ยน CFrame แบบกระโดด
                fly.bg.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
            end
        )
    end

    local function unbindFlyStep()
        if fly.conn then
            pcall(
                function()
                    fly.conn:Disconnect()
                end
            )
            fly.conn = nil
        end
        fly.bound = false
    end

    local function enableFly(enable)
        state.flyEnabled = enable and true or false
        if enable then
            local hrp = getHRP()
            if not hrp then
                notify("Fly", "ไม่พบ HumanoidRootPart", 3)
                state.flyEnabled = false
                return
            end
            createForces(hrp)
            bindFlyStep()
            notify("Fly", "Fly enabled", 3)
        else
            destroyForces()
            unbindFlyStep()
            notify("Fly", "Fly disabled", 2)
        end
    end

    -- ===========================
    -- Noclip (เดิม) - ทำงานได้บนมือถือ
    -- ===========================
    local noclipConn = nil

    local function setNoclip(enable)
        if enable == state.noclipEnabled then
            return
        end
        state.noclipEnabled = enable

        local char = LocalPlayer.Character
        if not char or not char:FindFirstChildOfClass("Humanoid") then
            warn("[Noclip] Character not ready")
            return
        end

        if enable then
            savedCanCollide = {}
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    savedCanCollide[part] = part.CanCollide
                    part.CanCollide = false
                end
            end

            noclipConn =
                RunService.Stepped:Connect(
                function()
                    local c = LocalPlayer.Character
                    if c then
                        for _, part in ipairs(c:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            )

            notify("Noclip", "✅ Enabled", 2.5)
        else
            if noclipConn then
                noclipConn:Disconnect()
                noclipConn = nil
            end

            for part, val in pairs(savedCanCollide) do
                if part and part.Parent then
                    part.CanCollide = val
                end
            end
            savedCanCollide = {}
            notify("Noclip", "❌ Disabled", 2)
        end
    end

    -- Auto reapply on respawn
    LocalPlayer.CharacterAdded:Connect(
        function(char)
            task.wait(0.2)
            if state.noclipEnabled then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                notify("Noclip", "Re-enabled after respawn", 2)
            end
            -- Reapply fly forces after respawn if needed
            if state.flyEnabled then
                task.wait(0.1)
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    createForces(hrp)
                end
            end
        end
    )

    -- UI controls (Tab bindings)
    local flyToggle = Tabs.Humanoid:AddToggle("FlyToggle", {Title = "Fly", Default = false})
    flyToggle:OnChanged(
        function(v)
            enableFly(v)
        end
    )

    local flySpeedSlider =
        Tabs.Humanoid:AddSlider(
        "FlySpeedSlider",
        {
            Title = "Fly Speed",
            Description = "ปรับความเร็วการบิน",
            Default = fly.speed,
            Min = 10,
            Max = 350,
            Rounding = 0,
            Callback = function(v)
                fly.speed = v
            end
        }
    )
    flySpeedSlider:SetValue(fly.speed)

    local noclipToggle = Tabs.Humanoid:AddToggle("NoclipToggle", {Title = "Noclip", Default = false})
    noclipToggle:OnChanged(
        function(v)
            setNoclip(v)
        end
    )

    Tabs.Humanoid:AddKeybind(
        "FlyKey",
        {
            Title = "Fly Key (Toggle)",
            Mode = "Toggle",
            Default = "None",
            Callback = function(val)
                enableFly(val)
                pcall(
                    function()
                        flyToggle:SetValue(val)
                    end
                )
            end
        }
    )

    -- expose flyControls so GUI script สามารถใช้ได้ (ตัวอย่าง: สคริปต์ GUI จะเรียก flyControls.SetAscend(true) ตอน touch begin)
    _G.ATG_FlyControls = flyControls

    task.spawn(
        function()
            while true do
                if Fluent and Fluent.Unloaded then
                    enableFly(false)
                    setNoclip(false)
                    break
                end
                task.wait(0.5)
            end
        end
    )
end


Tabs.Server:AddButton({
    Title = "Find Private Server",
    Description = "หาเซิฟ VIP ฟรี",
    Callback = function()
        Window:Dialog({
            Title = "ยืนยันการทำงาน",
            Content = "แน่ใจนะว่าจะหาเซิฟวี?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()   
                        loadstring(game:HttpGet("https://raw.githubusercontent.com/caomod2077/Script/refs/heads/main/Free%20Private%20Server.lua"))()
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                    end
                }
            }
        })
    end
})

-- ============================
-- Server Hop (unchanged logic, but minimal calls)
-- ============================
do
    local function findServer()
        local servers = {}
        local cursor = ""
        local placeId = game.PlaceId
        repeat
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
            local success, response = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
            if success and response and response.data then
                for _, server in ipairs(response.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        table.insert(servers, server.id)
                    end
                end
                cursor = response.nextPageCursor or ""
            else break end
        until cursor == ""
        if #servers > 0 then return servers[math.random(1,#servers)] end
        return nil
    end

    Tabs.Server:AddButton({
    Title = "Server Hop",
    Description = "Join a different random server instance.",
    Callback = function()
        Window:Dialog({
            Title = "Server Hop?",
            Content = "คุณต้องการเข้าร่วมเซิร์ฟเวอร์สุ่มใหม่หรือไม่?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        local ok, err = pcall(function()
                            local serverId = findServer()
                            if serverId then
                                TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, LocalPlayer)
                            else
                                warn("No available servers found!")
                                Window:Dialog({
                                    Title = "Server Hop Failed",
                                    Content = "ไม่พบเซิร์ฟเวอร์ว่างสำหรับ Hop!",
                                    Buttons = { { Title = "OK", Callback = function() end } }
                                })
                            end
                        end)

                        if not ok then
                            Window:Dialog({
                                Title = "Error!",
                                Content = "เกิดข้อผิดพลาด: " .. tostring(err),
                                Buttons = { { Title = "OK", Callback = function() end } }
                            })
                        end
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function() end
                }
            }
        })
    end
})



    Tabs.Server:AddButton({
    Title = "Rejoin",
    Description = "Rejoin This Server",
    Callback = function()
        -- ถ้า LocalPlayer ยังไม่พร้อม ให้แจ้ง
        if not LocalPlayer then
            Window:Dialog({
                Title = "ไม่พร้อม",
                Content = "ไม่สามารถดึง LocalPlayer ได้ตอนนี้",
                Buttons = { { Title = "OK", Callback = function() end } }
            })
            return
        end

        -- ยืนยันก่อน
        Window:Dialog({
            Title = "Rejoin?",
            Content = "ต้องการกลับเข้าเซิร์ฟเวอร์นี้อีกครั้งหรือไม่? (จะโหลดใหม่)",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        -- เรียก teleport ใน pcall เผื่อเกิด error
                        local ok, err = pcall(function()
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                        end)

                        -- ปกติถ้า teleport สำเร็จ client จะโหลดออกไปและไม่มาถึงบรรทัดนี้
                        if not ok then
                            Window:Dialog({
                                Title = "Error!",
                                Content = "เกิดข้อผิดพลาดขณะพยายาม Rejoin:\n" .. tostring(err),
                                Buttons = { { Title = "OK", Callback = function() end } }
                            })
                        end
                    end
                },
                { Title = "Cancel", Callback = function() end }
            }
        })
    end
})


    local function findLowestServer()
        local lowestServer, lowestPlayers = nil, math.huge
        local cursor = ""
        local placeId = game.PlaceId
        repeat
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
            local success, response = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
            if success and response and response.data then
                for _, server in ipairs(response.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        if server.playing < lowestPlayers then lowestPlayers = server.playing; lowestServer = server.id end
                    end
                end
                cursor = response.nextPageCursor or ""
            else break end
        until cursor == ""
        return lowestServer
    end

    Tabs.Server:AddButton({
    Title = "Lower Server",
    Description = "Join the server with the least number of players.",
    Callback = function()
        Window:Dialog({
            Title = "Lower Server?",
            Content = "คุณต้องการเข้าร่วมเซิร์ฟเวอร์ที่มีผู้เล่นน้อยที่สุดหรือไม่?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        local ok, err = pcall(function()
                            local serverId = findLowestServer()
                            if serverId then
                                TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, LocalPlayer)
                            else
                                warn("No available servers found!")
                                Window:Dialog({
                                    Title = "Failed",
                                    Content = "ไม่พบเซิร์ฟเวอร์ว่าง!",
                                    Buttons = { { Title = "OK", Callback = function() end } }
                                })
                            end
                        end)

                        if not ok then
                            Window:Dialog({
                                Title = "Error!",
                                Content = "เกิดข้อผิดพลาด: " .. tostring(err),
                                Buttons = { { Title = "OK", Callback = function() end } }
                            })
                        end
                    end
                },
                { Title = "Cancel", Callback = function() end }
            }
        })
    end
})
end

local Section = Tabs.Server:AddSection("Job ID")

-- เก็บค่าจาก Input
local jobIdInputValue = ""

-- สร้าง Input (ใช้ของเดิมที่ให้มา ปรับ Default ให้ว่าง)
local Input = Tabs.Server:AddInput("Input", {
    Title = "Input Job ID",
    Default = "",
    Placeholder = "วาง Job ID ที่นี่",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        jobIdInputValue = tostring(Value or "")
    end
})

-- อัปเดตค่าแบบ realtime เวลาเปลี่ยน
Input:OnChanged(function(Value)
    jobIdInputValue = tostring(Value or "")
end)

-- ปุ่ม Teleport
Tabs.Server:AddButton({
    Title = "Teleport to Job",
    Description = "Teleport ไปยัง Job ID ที่ใส่ข้างบน",
    Callback = function()
        -- validation เบื้องต้น
        if jobIdInputValue == "" or jobIdInputValue == "Default" then
            Window:Dialog({
                Title = "กรอกก่อน!!",
                Content = "กรอก Job ID ก่อนนะ จิ้มปุ่มอีกทีจะ teleport ให้",
                Buttons = {
                    { Title = "OK", Callback = function() end }
                }
            })
            return
        end

        -- เช็คว่าเป็น Job เดียวกับที่เราอยู่หรือยัง
        if tostring(game.JobId) == jobIdInputValue then
            Window:Dialog({
                Title = "อยู่แล้วนะ",
                Content = "คุณอยู่ในเซิร์ฟเวอร์นี้อยู่แล้ว (same Job ID).",
                Buttons = { { Title = "OK", Callback = function() end } }
            })
            return
        end

        -- ยืนยันก่อน teleport
        Window:Dialog({
            Title = "ยืนยันการย้าย",
            Content = "จะย้ายไปเซิร์ฟเวอร์ Job ID:\n" .. jobIdInputValue .. "\nยืนยันไหม?",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        -- เรียก Teleport ใน pcall กัน error
                        local ok, err = pcall(function()
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, jobIdInputValue)
                        end)

                        if ok then
                            -- ปกติจะไม่มาถึงบรรทัดนี้เพราะ client จะโหลดหน้า teleport แต่เผื่อ error
                            print("Teleport เริ่มแล้ว — ถ้ามีปัญหาจะมี log ขึ้น")
                        else
                            Window:Dialog({
                                Title = "Teleport ล้มเหลว",
                                Content = "เกิดข้อผิดพลาด: " .. tostring(err),
                                Buttons = { { Title = "OK", Callback = function() end } }
                            })
                        end
                    end
                },
                { Title = "Cancel", Callback = function() end }
            }
        })
    end
})

-- ปุ่มคัดลอก Job ID ปัจจุบัน
Tabs.Server:AddButton({
    Title = "Copy Current Job ID",
    Description = "คัดลอก Job ID ที่คุณอยู่ตอนนี้",
    Callback = function()
        local currentJobId = tostring(game.JobId or "")
        if currentJobId == "" then
            Window:Dialog({
                Title = "ไม่พบ Job ID",
                Content = "ไม่สามารถดึง Job ID ปัจจุบันได้",
                Buttons = { { Title = "OK", Callback = function() end } }
            })
            return
        end

        -- คัดลอกเข้าคลิปบอร์ด
        pcall(function()
            setclipboard(currentJobId)
        end)

        Window:Dialog({
            Title = "สำเร็จ!",
            Content = "คัดลอก Job ID ปัจจุบันเรียบร้อย:\n" .. currentJobId,
            Buttons = { { Title = "OK", Callback = function() end } }
        })
    end
})

-- -----------------------
-- Anti-AFK
-- -----------------------
do
    local vu = nil
    -- VirtualUser trick: works in many environments (Roblox default)
    local function enableAntiAFK(enable)
        if enable then
            if not vu then
                -- VirtualUser exists only in Roblox client; we get via game:GetService("VirtualUser") (works in studio / client)
                pcall(function() vu = game:GetService("VirtualUser") end)
            end
            if vu then
                Players.LocalPlayer.Idled:Connect(function()
                    pcall(function()
                        vu:Button2Down(Vector2.new(0,0))
                        task.wait(1)
                        vu:Button2Up(Vector2.new(0,0))
                    end)
                end)
            end
            notify("Anti-AFK", "Anti-AFK enabled", 3)
        else
            -- Can't fully disconnect all Idled events if there are others, but setting to nil stops new ones
            notify("Anti-AFK", "Anti-AFK disabled (client may still have other handlers)", 3)
        end
    end

    local antiAFKToggle = Tabs.Settings:AddToggle("AntiAFKToggle", { Title = "Anti-AFK", Default = true })
    antiAFKToggle:OnChanged(function(v) enableAntiAFK(v) end)
    -- default on
    antiAFKToggle:SetValue(true)
    enableAntiAFK(true)
end

-- Addons
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

Fluent:Notify({
    Title = "ATG Hub Freemium",
    Content = "The script has been loaded.",
    Duration = 8
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig() 

-- Unified Fluent toggle + draggable imgButton (mobile / no-keyboard friendly)
-- เพิ่ม UIStroke ที่สีวิ่งตลอดเวลา (RGB hue cycle)
-- LocalScript (StarterPlayerScripts หรือ PlayerGui)

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- 💡 ตั้งค่า
local FORCE_SHOW_IMG_BUTTON = true  -- ถ้าอยากให้โชว์ปุ่มเสมอ
local START_Y = 0.005                -- ความสูงจากขอบบน (น้อย = อยู่สูง)

-- 🌈 เอฟเฟกต์เส้น
local STROKE_THICKNESS_BASE = 1
local STROKE_THICKNESS_PULSE = 1.5
local STROKE_PULSE_SPEED = 1.0
local STROKE_HUE_SPEED = 0.09
local STROKE_SATURATION = 0.95
local STROKE_VALUE = 1.0
local STROKE_TRANSP_BASE = 0.05
local STROKE_TRANSP_PULSE = 0.12

-- 🔎 ตรวจอุปกรณ์
local hasKeyboard = UserInputService.KeyboardEnabled
local hasTouch = UserInputService.TouchEnabled
local hasGamepad = UserInputService.GamepadEnabled
local shouldCreateImgButton =
	FORCE_SHOW_IMG_BUTTON
	or (not hasKeyboard)
	or (hasTouch and not hasKeyboard)
	or (hasGamepad and not hasKeyboard)

-- 🪟 ScreenGui
local toggleGui = playerGui:FindFirstChild("Fluent_ToggleGui")
if shouldCreateImgButton and not toggleGui then
	toggleGui = Instance.new("ScreenGui")
	toggleGui.Name = "Fluent_ToggleGui"
	toggleGui.ResetOnSpawn = false
	toggleGui.DisplayOrder = 9999
	toggleGui.Parent = playerGui
end

-- 🎨 ฟังก์ชันคำนวณขนาดปุ่มตามจอ
local function getButtonSize()
	local screen = Camera.ViewportSize
	local width = math.clamp(screen.X * 0.045, 40, 40)
	local height = math.clamp(screen.Y * 0.08, 40, 40)
	return UDim2.fromOffset(width, height)
end

-- 🎯 ฟังก์ชันปรับตำแหน่งให้อยู่กลางจอแนวดิ่ง
local function getButtonPosition()
	return UDim2.new(0.5, 0, 0, Camera.ViewportSize.Y * START_Y)
end

-- 🧱 หา/สร้างปุ่ม
local imgButton = (shouldCreateImgButton and toggleGui)
	and toggleGui:FindFirstChild("FluentToggleButton")
	or nil

if shouldCreateImgButton and not imgButton and toggleGui then
	imgButton = Instance.new("ImageButton")
	imgButton.Name = "FluentToggleButton"
	imgButton.Size = getButtonSize()
	imgButton.AnchorPoint = Vector2.new(0.5, 0.5)
	imgButton.Position = getButtonPosition()
	imgButton.BackgroundTransparency = 0
	imgButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	imgButton.BorderSizePixel = 0
	imgButton.Image = "rbxassetid://114090251469395"
	imgButton.Parent = toggleGui

	local uic = Instance.new("UICorner", imgButton)
	uic.CornerRadius = UDim.new(0, 8)

	-- 🟢 สร้างเส้นเรืองแสงรอบปุ่ม
	local stroke = Instance.new("UIStroke", imgButton)
	stroke.Thickness = STROKE_THICKNESS_BASE
	stroke.Transparency = STROKE_TRANSP_BASE
	stroke.LineJoinMode = Enum.LineJoinMode.Round

	-- 🌈 Pulse & RGB Effect
	task.spawn(function()
		local startTime = tick()
		while imgButton and imgButton.Parent do
			local t = tick() - startTime
			local hue = (t * STROKE_HUE_SPEED) % 1
			local pulse = math.sin(t * math.pi * 2 * STROKE_PULSE_SPEED)
			stroke.Color = Color3.fromHSV(hue, STROKE_SATURATION, STROKE_VALUE)
			stroke.Thickness = STROKE_THICKNESS_BASE + (pulse * STROKE_THICKNESS_PULSE)
			stroke.Transparency = STROKE_TRANSP_BASE + math.abs(pulse) * STROKE_TRANSP_PULSE
			RunService.RenderStepped:Wait()
		end
	end)

	-- ✋ ระบบลากปุ่ม (เมาส์/มือถือ)
	local dragging = false
	local dragStart, startPos
	imgButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			dragStart = input.Position
			startPos = imgButton.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging
			and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch)
		then
			local delta = input.Position - dragStart
			imgButton.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	-- 📱 Auto Resize เมื่อเปลี่ยนขนาดจอ
	Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		task.wait(0.1)
		imgButton.Size = getButtonSize()
		imgButton.Position = getButtonPosition()
	end)
end


-- helper: หาผู้สมัคร UI แบบ "Fluent" (เหมือนเดิม)
local function findFluentCandidates()
    local found = {}
    local function pushOnce(obj)
        for _, v in ipairs(found) do if v == obj then return end end
        table.insert(found, obj)
    end

    for _, sg in pairs(playerGui:GetChildren()) do
        if sg:IsA("ScreenGui") and tostring(sg.Name):lower():find("fluent") then
            pushOnce(sg)
        end
    end

    local markers = {"TabDisplay", "ContainerCanvas", "AcrylicPaint", "TitleBar", "TabHolder", "Fluent"}
    local function scan(parent)
        for _, obj in pairs(parent:GetDescendants()) do
            if obj:IsA("GuiObject") then
                local n = tostring(obj.Name):lower()
                for _, m in ipairs(markers) do
                    if n:find(m:lower()) then
                        local ancestor = obj
                        while ancestor.Parent and not ancestor.Parent:IsA("PlayerGui") and not ancestor.Parent:IsA("CoreGui") and ancestor.Parent ~= workspace do
                            ancestor = ancestor.Parent
                        end
                        local sg = ancestor
                        while sg and not sg:IsA("ScreenGui") do sg = sg.Parent end
                        if sg then pushOnce(sg) else pushOnce(ancestor) end
                    end
                end

                if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) and obj.Text then
                    local t = tostring(obj.Text):lower()
                    if t:find("fluent") or t:find("interface") or t:find("by dawid") then
                        local ancestor = obj
                        while ancestor.Parent and not ancestor.Parent:IsA("PlayerGui") and not ancestor.Parent:IsA("CoreGui") and ancestor.Parent ~= workspace do
                            ancestor = ancestor.Parent
                        end
                        local sg = ancestor
                        while sg and not sg:IsA("ScreenGui") do sg = sg.Parent end
                        if sg then pushOnce(sg) else pushOnce(ancestor) end
                    end
                end
            end
        end
    end

    scan(playerGui)
    pcall(function() scan(coreGui) end)

    if #found == 0 then
        for _, sg in pairs(playerGui:GetChildren()) do
            if sg:IsA("ScreenGui") then
                for _, d in pairs(sg:GetDescendants()) do
                    if d:IsA("GuiObject") then
                        pushOnce(sg)
                        break
                    end
                end
            end
        end
    end

    return found
end

local function shouldSkipInstance(inst)
    if not inst then return false end
    if toggleGui and inst == toggleGui then return true end
    if imgButton and (inst == imgButton or imgButton:IsDescendantOf(inst) or (toggleGui and inst:IsDescendantOf(toggleGui))) then return true end
    return false
end

-- unified toggle (ยังใช้เดิม)
local debounce = false
local function unifiedToggle()
    if debounce then return end
    debounce = true
    task.defer(function() task.wait(0.18); debounce = false end)

    local usedWindow = false
    if typeof(Window) == "table" and type(Window.Minimize) == "function" then
        pcall(function() Window:Minimize() end)
        usedWindow = true
    end

    if not usedWindow then
        local candidates = findFluentCandidates()
        if #candidates == 0 then
            for _, sg in pairs(playerGui:GetChildren()) do
                if sg:IsA("ScreenGui") and not shouldSkipInstance(sg) then
                    pcall(function()
                        if sg.Enabled ~= nil then
                            sg.Enabled = not sg.Enabled
                        else
                            for _, v in pairs(sg:GetDescendants()) do
                                if v:IsA("GuiObject") then v.Visible = not v.Visible end
                            end
                        end
                    end)
                end
            end
            return
        end

        for _, c in ipairs(candidates) do
            if not shouldSkipInstance(c) then
                pcall(function()
                    if c:IsA("ScreenGui") and c.Enabled ~= nil then
                        c.Enabled = not c.Enabled
                    elseif c:IsA("GuiObject") and c.Visible ~= nil then
                        c.Visible = not c.Visible
                    else
                        for _, v in pairs(c:GetDescendants()) do
                            if not shouldSkipInstance(v) and v:IsA("GuiObject") and v.Visible ~= nil then
                                v.Visible = not v.Visible
                            end
                        end
                    end
                end)
            end
        end
    end
end

-- Activated สำหรับ touch / mouse / controller
if imgButton then
    imgButton.Activated:Connect(function()
        local ok, err = pcall(unifiedToggle)
        if not ok then warn("[FluentToggle] error:", err) end
    end)
end

-- keybind (keyboard) - ถ้ามี keyboard
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.M and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            if typeof(Window) == "table" and type(Window.Minimize) == "function" then
                pcall(function() Window:Minimize() end)
            else
                pcall(unifiedToggle)
            end
        end
    end
end)

-- ========== Dragging (center-based, mobile friendly) ==========
if imgButton then
    do
        -- state
        local dragging = false
        local dragInput = nil
        local dragStart = Vector2.new(0, 0)     -- input start pos (absolute)
        local startCenter = Vector2.new(0, 0)   -- button center absolute at start
        local currentVpSize = Vector2.new(0, 0)

        local function getViewport()
            if Camera and Camera.ViewportSize then
                return Camera.ViewportSize
            elseif workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize then
                return workspace.CurrentCamera.ViewportSize
            else
                local root = playerGui
                if root and root.AbsoluteSize then
                    return root.AbsoluteSize
                end
                return Vector2.new(0, 0)
            end
        end

        local function updateVpSize()
            local vs = getViewport()
            currentVpSize = Vector2.new(vs.X or 0, vs.Y or 0)
        end

        updateVpSize()

        -- clamp center coordinate so that button center stays onscreen (can reach edges)
        local function clampCenter(cx, cy)
            local absSize = imgButton.AbsoluteSize
            updateVpSize()
            local vpW, vpH = currentVpSize.X, currentVpSize.Y
            if vpW <= 0 or vpH <= 0 then
                return cx, cy
            end
            local halfW = absSize.X * 0.5
            local halfH = absSize.Y * 0.5
            local minX = halfW * 0.5 -- tiny allowance (avoid fully offscreen)
            local maxX = math.max(halfW, vpW - halfW)
            local minY = halfH * 0.5
            local maxY = math.max(halfH, vpH - halfH)
            local ncx = math.clamp(cx, minX, maxX)
            local ncy = math.clamp(cy, minY, maxY)
            return ncx, ncy
        end

        -- Start drag
        imgButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragInput = input
                dragStart = input.Position

                -- compute current center absolute (AbsolutePosition is top-left)
                local absPos = imgButton.AbsolutePosition
                local absSize = imgButton.AbsoluteSize
                startCenter = Vector2.new(absPos.X + absSize.X * 0.5, absPos.Y + absSize.Y * 0.5)
            end
        end)

        -- Record movement input (mouse movement / touch move)
        imgButton.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        -- Global InputChanged to get positions (this works for touch/mouse movement)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and dragInput and input == dragInput and input.Position then
                local delta = input.Position - dragStart
                local newCenter = startCenter + delta
                local cx, cy = clampCenter(newCenter.X, newCenter.Y)
                -- set Position using center coordinates (AnchorPoint = 0.5,0.5)
                imgButton.Position = UDim2.fromOffset(cx, cy)
            end
        end)

        -- Release when input ends
        UserInputService.InputEnded:Connect(function(input)
            if dragging and dragInput and input == dragInput then
                dragging = false
                dragInput = nil
            end
        end)

        -- viewport change: ensure button stays onscreen (re-clamp)
        if Camera then
            Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                updateVpSize()
                local absPos = imgButton.AbsolutePosition
                local absSize = imgButton.AbsoluteSize
                local centerX = absPos.X + absSize.X * 0.5
                local centerY = absPos.Y + absSize.Y * 0.5
                local cx, cy = clampCenter(centerX, centerY)
                imgButton.Position = UDim2.fromOffset(cx, cy)
            end)
        else
            RunService.RenderStepped:Wait()
            local absPos = imgButton.AbsolutePosition
            local absSize = imgButton.AbsoluteSize
            local centerX = absPos.X + absSize.X * 0.5
            local centerY = absPos.Y + absSize.Y * 0.5
            local cx, cy = clampCenter(centerX, centerY)
            imgButton.Position = UDim2.fromOffset(cx, cy)
        end

        -- --- Stroke animation (RenderStepped) ---
        local stroke = imgButton:FindFirstChild("FluentStroke")
        local animateConn
        if stroke then
            -- ensure initial settings
            stroke.Thickness = STROKE_THICKNESS_BASE
            stroke.Transparency = STROKE_TRANSP_BASE

            local function animate(dt)
                local t = tick()
                -- hue cycles 0..1
                local h = (t * STROKE_HUE_SPEED) % 1
                -- slightly vary saturation/value if desired
                local s = STROKE_SATURATION
                local v = STROKE_VALUE
                -- set color from HSV
                stroke.Color = Color3.fromHSV(h, s, v)

                -- pulse thickness
                local pulse = (math.sin(t * STROKE_PULSE_SPEED * math.pi * 2) + 1) / 2 -- 0..1
                stroke.Thickness = STROKE_THICKNESS_BASE + pulse * STROKE_THICKNESS_PULSE

                -- optional subtle transparency pulse for shimmer
                stroke.Transparency = STROKE_TRANSP_BASE + pulse * STROKE_TRANSP_PULSE
            end

            animateConn = RunService.RenderStepped:Connect(animate)

            -- cleanup if button removed
            imgButton.AncestryChanged:Connect(function(child, parent)
                if not parent and animateConn then
                    animateConn:Disconnect()
                    animateConn = nil
                end
            end)
        end
    end
end

-- End of script
loadstring(game:HttpGet('https://raw.githubusercontent.com/atghub-sys/djwdjw0303/main/feiohwfhoiasda.lua'))()
