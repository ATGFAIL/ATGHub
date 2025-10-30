-- สร้างตัวแปร UI ที่ต้องใช้ข้ามบล็อก (เพื่อให้ Settings เข้าถึง FileDropdown ได้)
local FilenameInput
local FileDropdown

-- ตัวแปรหลัก
local recording = false
local playing = false
local macroData = {}
local startTime = 0
local looping = false
local hookInstalled = false
local oldNamecall

-- ตัวแปรสำหรับแสดงสถานะ
local statusText = "🟢 พร้อมใช้งาน"
local eventsCount = 0
local durationTime = 0

-- พาธโฟลเดอร์สำหรับมาโคร
local BASE_FOLDER = "ATGHUB_Macro"
local SUB_FOLDER = BASE_FOLDER .. "/Anime Last Stand"

-- ตรวจสอบและสร้างโฟลเดอร์ (ถ้ามีฟังก์ชัน makefolder)
local function ensureMacroFolders()
    pcall(function()
        if makefolder then
            -- ถ้า isfolder มี ให้เช็คก่อนสร้าง (บาง exploit มีบางอันไม่มี)
            if isfolder then
                if not isfolder(BASE_FOLDER) then
                    makefolder(BASE_FOLDER)
                end
                if not isfolder(SUB_FOLDER) then
                    makefolder(SUB_FOLDER)
                end
            else
                -- ถ้าไม่มี isfolder แต่มี makefolder ให้เรียกสร้างเผื่อไว้
                makefolder(BASE_FOLDER)
                makefolder(SUB_FOLDER)
            end
        end
    end)
end

-- ฟังก์ชันแปลง Arguments
local function serializeArg(arg)
    local argType = typeof(arg)
    
    if argType == "Instance" then
        return {
            type = "Instance",
            path = arg:GetFullName(),
            className = arg.ClassName
        }
    elseif argType == "CFrame" then
        return {
            type = "CFrame",
            components = {arg:GetComponents()}
        }
    elseif argType == "Vector3" then
        return {
            type = "Vector3",
            x = arg.X, y = arg.Y, z = arg.Z
        }
    elseif argType == "Color3" then
        return {
            type = "Color3",
            r = arg.R, g = arg.G, b = arg.B
        }
    elseif argType == "table" then
        local serialized = {}
        for k, v in pairs(arg) do
            serialized[k] = serializeArg(v)
        end
        return {
            type = "table",
            data = serialized
        }
    else
        return {
            type = argType,
            value = arg
        }
    end
end

-- ฟังก์ชันแปลงกลับ
local function deserializeArg(data)
    if type(data) ~= "table" or not data.type then
        return data
    end
    
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
        for k, v in pairs(data.data) do
            result[k] = deserializeArg(v)
        end
        return result
    else
        return data.value
    end
end

-- ฟังก์ชันติดตั้ง Hook แบบ SimpleSpy
local function installHook()
    if hookInstalled then return true end
    
    local success, err = pcall(function()
        -- ใช้วิธีการ Hook แบบเดียวกับ SimpleSpy
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- จับ FireServer และ InvokeServer
            if (method == "FireServer" or method == "InvokeServer") and recording then
                if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
                    local currentTime = tick() - startTime
                    local serializedArgs = {}
                    
                    -- Serialize arguments
                    for i, arg in ipairs(args) do
                        serializedArgs[i] = serializeArg(arg)
                    end
                    
                    -- บันทึก
                    table.insert(macroData, {
                        time = currentTime,
                        remoteName = self.Name,
                        remotePath = self:GetFullName(),
                        remoteType = method,
                        args = serializedArgs
                    })
                    
                    -- อัพเดท UI
                    eventsCount = #macroData
                    durationTime = currentTime
                    
                    -- อัพเดท Paragraph (ถ้ามี)
                    if Tabs.Main then
                        local successSet = pcall(function()
                            Tabs.Main:GetChildren()[1]:GetChildren()[1]:GetChildren()[2]:SetValue(
                                string.format("📊 Events: %d\n⏱️ Duration: %.3fs\n🔗 Hook: Active ✓", eventsCount, durationTime)
                            )
                        end)
                    end
                end
            end
            
            -- ส่งต่อการเรียกไปยัง Server ตามปกติ
            return oldNamecall(self, ...)
        end)
        
        hookInstalled = true
        return true
    end)
    
    if not success then
        warn("⚠️ Hook installation failed: " .. tostring(err))
        return false
    end
    
    return true
end

-- ฟังก์ชันเล่นมาโคร
local function playMacro(loop)
    if #macroData == 0 then
        Fluent:Notify({
            Title = "Macro System",
            Content = "❌ ไม่มีมาโครให้เล่น!",
            Duration = 3
        })
        return
    end
    
    playing = true
    looping = loop or false
    
    task.spawn(function()
        repeat
            local playStart = tick()
            
            for i, action in ipairs(macroData) do
                if not playing then break end
                
                -- รอให้ถึงเวลา
                local targetTime = playStart + action.time
                local waitTime = targetTime - tick()
                if waitTime > 0 then
                    task.wait(waitTime)
                end
                
                if not playing then break end
                
                -- เล่น Remote
                local success, err = pcall(function()
                    local remote = game
                    for part in action.remotePath:gmatch("[^.]+") do
                        if part ~= "game" then
                            remote = remote:FindFirstChild(part) or remote:WaitForChild(part, 2)
                        end
                    end
                    
                    if remote then
                        local deserializedArgs = {}
                        for i, arg in ipairs(action.args) do
                            deserializedArgs[i] = deserializeArg(arg)
                        end
                        
                        if action.remoteType == "FireServer" then
                            remote:FireServer(unpack(deserializedArgs))
                        else
                            remote:InvokeServer(unpack(deserializedArgs))
                        end
                    end
                end)
            end
            
            if looping and playing then
                task.wait(0.5)
            end
        until not looping or not playing
        
        playing = false
    end)
end

-- ฟังก์ชันบันทึกไฟล์ (เก็บใน ATGHUB_Macro/Anime Last Stand/<filename>.json)
local function saveMacro(filename)
    if #macroData == 0 then
        Fluent:Notify({
            Title = "Macro System",
            Content = "❌ ไม่มีข้อมูลมาโครให้บันทึก!",
            Duration = 3
        })
        return false
    end
    
    if not filename or filename == "" then
        Fluent:Notify({
            Title = "Macro System",
            Content = "❌ กรุณากรอกชื่อไฟล์!",
            Duration = 3
        })
        return false
    end
    
    ensureMacroFolders()
    
    local success, result = pcall(function()
        local data = {
            macroData = macroData,
            timestamp = os.time(),
            totalEvents = #macroData,
            totalDuration = durationTime
        }
        
        local json = HttpService:JSONEncode(data)
        
        if writefile then
            -- บันทึกลงไฟล์
            local fullPath = SUB_FOLDER .. "/" .. filename .. ".json"
            writefile(fullPath, json)
            return true
        else
            -- แสดงข้อมูลให้คัดลอก
            setclipboard(json)
            return "clipboard"
        end
    end)
    
    if success then
        if result == "clipboard" then
            Fluent:Notify({
                Title = "Macro System",
                Content = "📋 บันทึกแล้ว! ข้อมูลถูกคัดลอกไปยังคลิปบอร์ด",
                Duration = 5
            })
        else
            Fluent:Notify({
                Title = "Macro System",
                Content = "💾 บันทึกไฟล์สำเร็จ!",
                Duration = 3
            })
        end
        return true
    else
        Fluent:Notify({
            Title = "Macro System",
            Content = "❌ การบันทึกล้มเหลว: " .. tostring(result),
            Duration = 5
        })
        return false
    end
end

-- ฟังก์ชันโหลดไฟล์
local function loadMacro(filename)
    if not filename or filename == "" then
        Fluent:Notify({
            Title = "Macro System",
            Content = "❌ กรุณาเลือกไฟล์!",
            Duration = 3
        })
        return false
    end
    
    local success, result = pcall(function()
        if readfile then
            local fullPath = SUB_FOLDER .. "/" .. filename .. ".json"
            if not isfile then
                -- ถ้าไม่มี isfile ให้ลอง readfile โดยจับ error แทน
                local content = readfile(fullPath)
                local data = HttpService:JSONDecode(content)
                return data
            else
                if not isfile(fullPath) then
                    return nil, "ไฟล์ไม่พบ"
                end
                local content = readfile(fullPath)
                local data = HttpService:JSONDecode(content)
                return data
            end
        else
            return nil, "ระบบไฟล์ไม่รองรับ"
        end
    end)
    
    if success and result then
        macroData = result.macroData or {}
        eventsCount = #macroData
        durationTime = result.totalDuration or 0
        
        -- อัพเดท UI
        if Tabs.Main then
            pcall(function()
                Tabs.Main:GetChildren()[1]:GetChildren()[1]:GetChildren()[2]:SetValue(
                    string.format("📊 Events: %d\n⏱️ Duration: %.3fs\n🔗 Hook: Active ✓", eventsCount, durationTime)
                )
            end)
        end
        
        Fluent:Notify({
            Title = "Macro System",
            Content = "✅ โหลดมาโครสำเร็จ!",
            Duration = 3
        })
        return true
    else
        Fluent:Notify({
            Title = "Macro System",
            Content = "❌ โหลดไฟล์ล้มเหลว: " .. tostring(result),
            Duration = 5
        })
        return false
    end
end

-- ฟังก์ชันรับรายการไฟล์จากโฟลเดอร์ ATGHUB_Macro/Anime Last Stand
local function getMacroFiles()
    ensureMacroFolders()
    if not listfiles then return {"ไม่มีระบบไฟล์"} end
    
    local files = {}
    local success, result = pcall(function()
        local all = listfiles(SUB_FOLDER)
        for _, file in pairs(all) do
            -- หาชื่อไฟล์สุดท้ายก่อน .json
            local name = file:match("([^/\\]+)%.json$")
            if name and name ~= "" then
                table.insert(files, name)
            end
        end
        return files
    end)
    
    if success and #files > 0 then
        return result
    else
        return {"ไม่มีไฟล์ที่บันทึกไว้"}
    end
end

-- สร้าง UI ในแท็บ Main
do
    -- Input สำหรับกรอกชื่อไฟล์
    local Section = Tabs.Macro:AddSection("Macro")
    FilenameInput = Tabs.Macro:AddInput("FilenameInput", {
        Title = "ชื่อไฟล์",
        Default = "",
        Placeholder = "กรอกชื่อไฟล์ (ไม่ต้องมี .json)",
        Numeric = false,
        Finished = false,
    })

    -- Dropdown สำหรับเลือกไฟล์
    FileDropdown = Tabs.Macro:AddDropdown("FileDropdown", {
        Title = "เลือกไฟล์มาโคร",
        Values = getMacroFiles(),
        Multi = false,
        Default = 1,
    })

    -- Button สร้างไฟล์
    Tabs.Macro:AddButton({
        Title = "💾 บันทึกมาโคร",
        Description = "บันทึกมาโครปัจจุบันลงไฟล์",
        Callback = function()
            local filename = Options.FilenameInput.Value
            if filename == "" then
                filename = os.date("macro_%Y%m%d_%H%M%S")
            end
            saveMacro(filename)
            
            -- อัพเดท dropdown
            pcall(function()
                FileDropdown:SetValues(getMacroFiles())
            end)
        end
    })

    -- Toggle บันทึกมาโคร
    local RecordToggle = Tabs.Macro:AddToggle("RecordToggle", {
        Title = "⏺️ บันทึกมาโคร",
        Description = "เริ่ม/หยุด การบันทึกมาโคร",
        Default = false
    })

    RecordToggle:OnChanged(function()
        if Options.RecordToggle.Value then
            -- เริ่มบันทึก
            if not hookInstalled then
                if not installHook() then
                    Fluent:Notify({
                        Title = "Macro System",
                        Content = "❌ ติดตั้ง Hook ไม่สำเร็จ!",
                        Duration = 3
                    })
                    RecordToggle:SetValue(false)
                    return
                end
            end
            
            recording = true
            macroData = {}
            startTime = tick()
            eventsCount = 0
            durationTime = 0
            
            Fluent:Notify({
                Title = "Macro System",
                Content = "🎬 เริ่มบันทึกมาโครแล้ว",
                Duration = 2
            })
        else
            -- หยุดบันทึก
            recording = false
            Fluent:Notify({
                Title = "Macro System",
                Content = string.format("✅ บันทึกเสร็จสิ้น: %d events", #macroData),
                Duration = 3
            })
        end
    end)

    -- Toggle เล่นมาโครอัตโนมัติ
    local AutoPlayToggle = Tabs.Macro:AddToggle("AutoPlayToggle", {
        Title = "🔁 เล่นมาโครอัตโนมัติ",
        Description = "เล่นมาโครวนลูปเมื่อเปิด",
        Default = false
    })

    AutoPlayToggle:OnChanged(function()
        if Options.AutoPlayToggle.Value then
            if not playing then
                playMacro(true)
                Fluent:Notify({
                    Title = "Macro System",
                    Content = "🔁 เริ่มเล่นมาโครแบบวนลูป",
                    Duration = 2
                })
            end
        else
            looping = false
            playing = false
            Fluent:Notify({
                Title = "Macro System",
                Content = "⏹️ หยุดเล่นมาโคร",
                Duration = 2
            })
        end
    end)

    -- Button เล่นมาโคร
    Tabs.Macro:AddButton({
        Title = "▶️ เล่นมาโคร",
        Description = "เล่นมาโครหนึ่งรอบ",
        Callback = function()
            if playing then
                Fluent:Notify({
                    Title = "Macro System",
                    Content = "⏸️ หยุดเล่นมาโครชั่วคราว",
                    Duration = 2
                })
                playing = false
                looping = false
                Options.AutoPlayToggle:SetValue(false)
            else
                playMacro(false)
                Fluent:Notify({
                    Title = "Macro System",
                    Content = "▶️ เริ่มเล่นมาโครหนึ่งรอบ",
                    Duration = 2
                })
            end
        end
    })

    -- Button โหลดไฟล์
    Tabs.Macro:AddButton({
        Title = "📂 โหลดมาโคร",
        Description = "โหลดมาโครจากไฟล์",
        Callback = function()
            local selectedFile = Options.FileDropdown.Value
            if selectedFile and selectedFile ~= "ไม่มีไฟล์ที่บันทึกไว้" and selectedFile ~= "ไม่มีระบบไฟล์" then
                loadMacro(selectedFile)
            else
                Fluent:Notify({
                    Title = "Macro System",
                    Content = "❌ กรุณาเลือกไฟล์ที่ถูกต้อง",
                    Duration = 3
                })
            end
        end
    })

    -- Button ล้างข้อมูล
    Tabs.Macro:AddButton({
        Title = "🗑️ ล้างข้อมูล",
        Description = "ล้างข้อมูลมาโครปัจจุบัน",
        Callback = function()
            macroData = {}
            eventsCount = 0
            durationTime = 0
        end
    })
end

do
    Tabs.Macro:AddButton({
        Title = "อัพเดทรายการไฟล์",
        Description = "รีเฟรชรายการไฟล์มาโคร (จากโฟลเดอร์ ATGHUB_Macro/Anime Last Stand)",
        Callback = function()
            pcall(function()
                FileDropdown:SetValues(getMacroFiles())
            end)
            Fluent:Notify({
                Title = "Macro System",
                Content = "🔄 อัพเดทรายการไฟล์แล้ว",
                Duration = 2
            })
        end
    })
end
