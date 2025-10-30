-- MacroModule.lua
-- ModuleScript: แปลงมาโครระบบเป็นโมดูลที่สามารถ require ได้
local MacroModule = {}
MacroModule.__index = MacroModule

-- ภายใน state (ไม่ใช่ global)
local recording = false
local playing = false
local macroData = {}
local startTime = 0
local looping = false
local hookInstalled = false
local oldNamecall = nil

local eventsCount = 0
local durationTime = 0

local BASE_FOLDER = "ATGHUB_Macro"
local SUB_FOLDER = BASE_FOLDER .. "/Anime Last Stand"

-- dependencies (จะถูกเซ็ตโดย Init)
local Tabs, Fluent, HttpService, StatusUpdater

-- public: เก็บ UI objects ที่สร้างขึ้น (ให้สคริปต์เรียกอ่าน/แก้ได้)
MacroModule.Options = {}

-- ตรวจสอบ/สร้างโฟลเดอร์
local function ensureMacroFolders()
    pcall(function()
        if makefolder then
            if isfolder then
                if not isfolder(BASE_FOLDER) then
                    makefolder(BASE_FOLDER)
                end
                if not isfolder(SUB_FOLDER) then
                    makefolder(SUB_FOLDER)
                end
            else
                makefolder(BASE_FOLDER)
                makefolder(SUB_FOLDER)
            end
        end
    end)
end

-- ฟังก์ชันช่วยอัปเดท status (ใช้ StatusUpdater ถ้ามี, ถ้าไม่จะพยายามอัปเดท Tabs.Main แบบเดิมใน pcall)
local function updateStatus()
    local text = string.format("📊 Events: %d\n⏱️ Duration: %.3fs\n🔗 Hook: %s", eventsCount, durationTime, (hookInstalled and "Active ✓" or "Inactive ✗"))
    if StatusUpdater and type(StatusUpdater) == "function" then
        pcall(StatusUpdater, text)
        return
    end
    if Tabs and Tabs.Main then
        pcall(function()
            -- พยายามอัปเดทพื้นที่ตามโครงเดิม (ถ้ามี)
            Tabs.Main:GetChildren()[1]:GetChildren()[1]:GetChildren()[2]:SetValue(text)
        end)
    end
end

-- Serialize / Deserialize arguments
local function serializeArg(arg)
    local argType = typeof(arg)
    if argType == "Instance" then
        return { type = "Instance", path = arg:GetFullName(), className = arg.ClassName }
    elseif argType == "CFrame" then
        return { type = "CFrame", components = {arg:GetComponents()} }
    elseif argType == "Vector3" then
        return { type = "Vector3", x = arg.X, y = arg.Y, z = arg.Z }
    elseif argType == "Color3" then
        return { type = "Color3", r = arg.R, g = arg.G, b = arg.B }
    elseif argType == "table" then
        local serialized = {}
        for k, v in pairs(arg) do serialized[k] = serializeArg(v) end
        return { type = "table", data = serialized }
    else
        return { type = argType, value = arg }
    end
end

local function deserializeArg(data)
    if type(data) ~= "table" or not data.type then return data end
    if data.type == "Instance" then
        local success, result = pcall(function()
            local obj = game
            for part in data.path:gmatch("[^.]+") do
                if part ~= "game" then
                    obj = obj:WaitForChild(part, 3)
                end
            end
            return obj
        end)
        return success and result or nil
    elseif data.type == "CFrame" then
        return CFrame.new(unpack(data.components))
    elseif data.type == "Vector3" then
        return Vector3.new(data.x, data.y, data.z)
    elseif data.type == "Color3" then
        return Color3.new(data.r, data.g, data.b)
    elseif data.type == "table" then
        local result = {}
        for k, v in pairs(data.data) do result[k] = deserializeArg(v) end
        return result
    else
        return data.value
    end
end

-- ติดตั้ง Hook แบบ SimpleSpy
function MacroModule.InstallHook()
    if hookInstalled then return true end
    local ok, err = pcall(function()
        -- require hookmetamethod & getnamecallmethod ใน exploit environment
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if (method == "FireServer" or method == "InvokeServer") and recording then
                if (self and (self:IsA and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")))) then
                    local currentTime = tick() - startTime
                    local serializedArgs = {}
                    for i, arg in ipairs(args) do serializedArgs[i] = serializeArg(arg) end

                    table.insert(macroData, {
                        time = currentTime,
                        remoteName = self.Name,
                        remotePath = self:GetFullName(),
                        remoteType = method,
                        args = serializedArgs
                    })

                    eventsCount = #macroData
                    durationTime = currentTime
                    updateStatus()
                end
            end

            -- ส่งต่อการเรียก
            return oldNamecall(self, ...)
        end)

        hookInstalled = true
        return true
    end)
    if not ok then
        warn("⚠️ Hook installation failed: " .. tostring(err))
        return false
    end
    updateStatus()
    return true
end

-- เล่นมาโคร (loop ถ้า loop = true)
function MacroModule.PlayMacro(loop)
    if #macroData == 0 then
        if Fluent then
            pcall(function()
                Fluent:Notify({ Title = "Macro System", Content = "❌ ไม่มีมาโครให้เล่น!", Duration = 3 })
            end)
        end
        return
    end

    playing = true
    looping = loop or false

    task.spawn(function()
        repeat
            local playStart = tick()
            for _, action in ipairs(macroData) do
                if not playing then break end

                local targetTime = playStart + action.time
                local waitTime = targetTime - tick()
                if waitTime > 0 then task.wait(waitTime) end
                if not playing then break end

                pcall(function()
                    local remote = game
                    for part in action.remotePath:gmatch("[^.]+") do
                        if part ~= "game" then
                            remote = remote:FindFirstChild(part) or remote:WaitForChild(part, 2)
                        end
                    end
                    if remote then
                        local deserializedArgs = {}
                        for i, arg in ipairs(action.args) do deserializedArgs[i] = deserializeArg(arg) end
                        if action.remoteType == "FireServer" and remote.FireServer then
                            remote:FireServer(unpack(deserializedArgs))
                        elseif action.remoteType == "InvokeServer" and remote.InvokeServer then
                            remote:InvokeServer(unpack(deserializedArgs))
                        end
                    end
                end)
            end

            if looping and playing then task.wait(0.5) end
        until not looping or not playing

        playing = false
    end)
end

function MacroModule.StopPlaying()
    looping = false
    playing = false
    MacroModule.Options.AutoPlayToggle and MacroModule.Options.AutoPlayToggle:SetValue(false)
end

-- Save macro ลงไฟล์หรือคัดลอกไป clipboard
function MacroModule.SaveMacro(filename)
    if #macroData == 0 then
        pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "❌ ไม่มีข้อมูลมาโครให้บันทึก!", Duration = 3 }) end end)
        return false
    end
    if not filename or filename == "" then
        pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "❌ กรุณากรอกชื่อไฟล์!", Duration = 3 }) end end)
        return false
    end

    ensureMacroFolders()
    local success, result = pcall(function()
        local data = { macroData = macroData, timestamp = os.time(), totalEvents = #macroData, totalDuration = durationTime }
        local json = HttpService:JSONEncode(data)
        if writefile then
            local fullPath = SUB_FOLDER .. "/" .. filename .. ".json"
            writefile(fullPath, json)
            return true
        else
            setclipboard(json)
            return "clipboard"
        end
    end)

    if success then
        if result == "clipboard" then
            pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "📋 บันทึกแล้ว! ข้อมูลถูกคัดลอกไปยังคลิปบอร์ด", Duration = 5 }) end end)
        else
            pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "💾 บันทึกไฟล์สำเร็จ!", Duration = 3 }) end end)
        end
        return true
    else
        pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "❌ การบันทึกล้มเหลว: " .. tostring(result), Duration = 5 }) end end)
        return false
    end
end

-- Load macro จากไฟล์
function MacroModule.LoadMacro(filename)
    if not filename or filename == "" then
        pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "❌ กรุณาเลือกไฟล์!", Duration = 3 }) end end)
        return false
    end

    local success, result = pcall(function()
        if readfile then
            local fullPath = SUB_FOLDER .. "/" .. filename .. ".json"
            if isfile and not isfile(fullPath) then
                return nil, "ไฟล์ไม่พบ"
            end
            local content = readfile(fullPath)
            local data = HttpService:JSONDecode(content)
            return data
        else
            return nil, "ระบบไฟล์ไม่รองรับ"
        end
    end)

    if success and result then
        macroData = result.macroData or {}
        eventsCount = #macroData
        durationTime = result.totalDuration or 0
        updateStatus()
        pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "✅ โหลดมาโครสำเร็จ!", Duration = 3 }) end end)
        return true
    else
        pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "❌ โหลดไฟล์ล้มเหลว: " .. tostring(result), Duration = 5 }) end end)
        return false
    end
end

-- ดึงรายการไฟล์จากโฟลเดอร์
function MacroModule.GetMacroFiles()
    ensureMacroFolders()
    if not listfiles then return {"ไม่มีระบบไฟล์"} end
    local files = {}
    local ok, res = pcall(function()
        local all = listfiles(SUB_FOLDER)
        for _, file in pairs(all) do
            local name = file:match("([^/\\]+)%.json$")
            if name and name ~= "" then table.insert(files, name) end
        end
        return files
    end)
    if ok and #res > 0 then return res end
    return {"ไม่มีไฟล์ที่บันทึกไว้"}
end

-- สร้าง UI ใน Tabs.Macro และผูก callback (Init จะเรียก)
function MacroModule.SetupUI()
    assert(Tabs and Tabs.Macro, "MacroModule.Init: ต้องส่ง Tabs ที่มี Tabs.Macro")

    local Section = Tabs.Macro:AddSection("Macro")

    MacroModule.Options.FilenameInput = Tabs.Macro:AddInput("FilenameInput", {
        Title = "ชื่อไฟล์",
        Default = "",
        Placeholder = "กรอกชื่อไฟล์ (ไม่ต้องมี .json)",
        Numeric = false,
        Finished = false,
    })

    MacroModule.Options.FileDropdown = Tabs.Macro:AddDropdown("FileDropdown", {
        Title = "เลือกไฟล์มาโคร",
        Values = MacroModule.GetMacroFiles(),
        Multi = false,
        Default = 1,
    })

    Tabs.Macro:AddButton({
        Title = "💾 บันทึกมาโคร",
        Description = "บันทึกมาโครปัจจุบันลงไฟล์",
        Callback = function()
            local filename = MacroModule.Options.FilenameInput.Value
            if filename == "" or not filename then
                filename = os.date("macro_%Y%m%d_%H%M%S")
            end
            MacroModule.SaveMacro(filename)
            pcall(function() MacroModule.Options.FileDropdown:SetValues(MacroModule.GetMacroFiles()) end)
        end
    })

    MacroModule.Options.RecordToggle = Tabs.Macro:AddToggle("RecordToggle", {
        Title = "⏺️ บันทึกมาโคร",
        Description = "เริ่ม/หยุด การบันทึกมาโคร",
        Default = false
    })

    MacroModule.Options.RecordToggle:OnChanged(function()
        if MacroModule.Options.RecordToggle.Value then
            if not hookInstalled then
                if not MacroModule.InstallHook() then
                    pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "❌ ติดตั้ง Hook ไม่สำเร็จ!", Duration = 3 }) end end)
                    MacroModule.Options.RecordToggle:SetValue(false)
                    return
                end
            end
            recording = true
            macroData = {}
            startTime = tick()
            eventsCount = 0
            durationTime = 0
            updateStatus()
            pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "🎬 เริ่มบันทึกมาโครแล้ว", Duration = 2 }) end end)
        else
            recording = false
            pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = string.format("✅ บันทึกเสร็จสิ้น: %d events", #macroData), Duration = 3 }) end end)
            updateStatus()
        end
    end)

    MacroModule.Options.AutoPlayToggle = Tabs.Macro:AddToggle("AutoPlayToggle", {
        Title = "🔁 เล่นมาโครอัตโนมัติ",
        Description = "เล่นมาโครวนลูปเมื่อเปิด",
        Default = false
    })

    MacroModule.Options.AutoPlayToggle:OnChanged(function()
        if MacroModule.Options.AutoPlayToggle.Value then
            if not playing then
                MacroModule.PlayMacro(true)
                pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "🔁 เริ่มเล่นมาโครแบบวนลูป", Duration = 2 }) end end)
            end
        else
            MacroModule.StopPlaying()
            pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "⏹️ หยุดเล่นมาโคร", Duration = 2 }) end end)
        end
    end)

    Tabs.Macro:AddButton({
        Title = "▶️ เล่นมาโคร",
        Description = "เล่นมาโครหนึ่งรอบ",
        Callback = function()
            if playing then
                pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "⏸️ หยุดเล่นมาโครชั่วคราว", Duration = 2 }) end end)
                MacroModule.StopPlaying()
                MacroModule.Options.AutoPlayToggle:SetValue(false)
            else
                MacroModule.PlayMacro(false)
                pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "▶️ เริ่มเล่นมาโครหนึ่งรอบ", Duration = 2 }) end end)
            end
        end
    })

    Tabs.Macro:AddButton({
        Title = "📂 โหลดมาโคร",
        Description = "โหลดมาโครจากไฟล์",
        Callback = function()
            local selectedFile = MacroModule.Options.FileDropdown.Value
            if selectedFile and selectedFile ~= "ไม่มีไฟล์ที่บันทึกไว้" and selectedFile ~= "ไม่มีระบบไฟล์" then
                MacroModule.LoadMacro(selectedFile)
            else
                pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "❌ กรุณาเลือกไฟล์ที่ถูกต้อง", Duration = 3 }) end end)
            end
        end
    })

    Tabs.Macro:AddButton({
        Title = "🗑️ ล้างข้อมูล",
        Description = "ล้างข้อมูลมาโครปัจจุบัน",
        Callback = function()
            macroData = {}
            eventsCount = 0
            durationTime = 0
            updateStatus()
        end
    })

    Tabs.Macro:AddButton({
        Title = "อัพเดทรายการไฟล์",
        Description = "รีเฟรชรายการไฟล์มาโคร (จากโฟลเดอร์ ATGHUB_Macro/Anime Last Stand)",
        Callback = function()
            pcall(function() MacroModule.Options.FileDropdown:SetValues(MacroModule.GetMacroFiles()) end)
            pcall(function() if Fluent then Fluent:Notify({ Title = "Macro System", Content = "🔄 อัพเดทรายการไฟล์แล้ว", Duration = 2 }) end end)
        end
    })
end

-- เริ่มต้นโมดูล: ส่ง dependencies เป็น table
-- ตัวอย่าง dependencies: { Tabs = Tabs, Fluent = Fluent, HttpService = game:GetService("HttpService"), StatusUpdater = function(txt) ... end }
function MacroModule.Init(deps)
    assert(type(deps) == "table", "MacroModule.Init expects a table of dependencies")
    Tabs = deps.Tabs
    Fluent = deps.Fluent
    HttpService = deps.HttpService or game:GetService("HttpService")
    StatusUpdater = deps.StatusUpdater

    -- สร้าง UI
    MacroModule.SetupUI()
    updateStatus()

    -- คืนค่า module (พร้อม Options)
    return MacroModule
end

-- ผลักข้อมูลออก (ให้สคริปต์เรียกใช้ได้)
function MacroModule.GetState()
    return {
        recording = recording,
        playing = playing,
        macroData = macroData,
        eventsCount = eventsCount,
        durationTime = durationTime,
        hookInstalled = hookInstalled
    }
end

-- expose เพิ่มเติม (ถ้าต้องการเรียกตรงๆ)
MacroModule.StartRecording = function() if not hookInstalled then MacroModule.InstallHook() end; MacroModule.Options.RecordToggle:SetValue(true) end
MacroModule.StopRecording  = function() MacroModule.Options.RecordToggle:SetValue(false) end
MacroModule.GetMacroFiles = MacroModule.GetMacroFiles
MacroModule.SaveMacro = MacroModule.SaveMacro
MacroModule.LoadMacro = MacroModule.LoadMacro
MacroModule.PlayOnce = function() MacroModule.PlayMacro(false) end
MacroModule.PlayLoop = function() MacroModule.PlayMacro(true) end
MacroModule.Stop = MacroModule.StopPlaying
MacroModule.InstallHook = MacroModule.InstallHook
MacroModule.UpdateStatus = updateStatus

return MacroModule
