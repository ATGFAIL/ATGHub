-- ============================================================
-- ATG HUB - Multi-Language System
-- Centralized Language Data & Management
-- ============================================================

local LanguageSystem = {}
LanguageSystem.__index = LanguageSystem

-- ============================================================
-- LANGUAGE DATA STRUCTURE
-- ============================================================
LanguageSystem.Languages = {
    -- English Language
    en = {
        code = "en",
        name = "English",
        flag = "🇺🇸",
        
        -- Common UI Elements
        common = {
            loading = "Loading...",
            success = "Success",
            error = "Error",
            warning = "Warning",
            confirm = "Confirm",
            cancel = "Cancel",
            ok = "OK",
            yes = "Yes",
            no = "No",
            close = "Close",
            save = "Save",
            delete = "Delete",
            refresh = "Refresh",
            reset = "Reset",
            enable = "Enable",
            disable = "Disable",
            start = "Start",
            stop = "Stop",
            pause = "Pause",
            resume = "Resume",
        },
        
        -- Main Tab
        main = {
            title = "Main",
            player_info = "Player Info",
            name = "Name",
            date = "Date",
            played_time = "Played Time",
            auto_claim = "Auto Claim",
            auto_upgrade = "Auto Upgrade",
            auto_equip = "Auto Equip",
            basic_features = "Basic Features",
            test_notification = "🔔 Test Notification",
            confirmation_dialog = "❓ Confirmation Dialog",
        },
        
        -- Farm Tab
        farm = {
            title = "Farm",
            auto_farm = "Auto Farm",
            fast_attack = "Fast Attack",
            kill_aura = "Kill Aura",
            auto_collect = "Auto Collect",
            radius = "Radius",
            select_enemy = "Select Enemy",
            select_target = "Select Target",
            weapons_abilities = "Weapons and Abilities",
            controls = "Controls",
            select_weapon = "🗡️ Select Weapon",
            special_abilities = "✨ Special Abilities",
            attack_button = "⚡ Attack Button",
        },
        
        -- Settings Tab
        settings = {
            title = "Settings",
            language = "Language",
            select_language = "Select Language",
            theme = "Theme",
            anti_afk = "Anti-AFK",
            auto_rejoin = "Auto Rejoin",
            save_config = "Save Configuration",
            load_config = "Load Configuration",
        },
        
        -- Server Tab
        server = {
            title = "Server",
            server_hop = "Server Hop",
            rejoin = "Rejoin",
            lower_server = "Lower Server",
            job_id = "Job ID",
            input_job_id = "Input Job ID",
            teleport_to_job = "Teleport to Job",
            copy_job_id = "Copy Current Job ID",
        },

        -- Teleport Tab
        teleport = {
            title = "Teleport",
        },

        -- Players Tab
        players = {
            title = "Players",
            movement = "Movement",
            player_info = "Player Info",
            speed_boost = "🏃 Speed Boost",
            jump_power = "🦘 Jump Power",
            player_name = "📝 Player Name",
        },
        
        -- Humanoid Tab
        humanoid = {
            title = "Humanoid",
            walk_speed = "Walk Speed",
            jump_power = "Jump Power",
            fly = "Fly",
            noclip = "Noclip",
            fly_speed = "Fly Speed",
            enable_walk = "Enable Walk",
            enable_jump = "Enable Jump",
            reset_defaults = "Reset to Defaults",
        },
        
        -- Notifications
        notifications = {
            script_loaded = "Script has been loaded successfully!",
            feature_enabled = "Feature enabled",
            feature_disabled = "Feature disabled",
            no_target = "No target found",
            teleport_success = "Teleported successfully",
            teleport_failed = "Teleport failed",
            invalid_input = "Invalid input",
            please_wait = "Please wait...",
            welcome = "Welcome!",
            press_left_ctrl = "Press Left Ctrl to open/close UI",
            success = "Success!",
            button_pressed = "You pressed the button",
            confirm_action = "Confirm Action",
            want_to_continue = "Do you want to continue?",
            confirm = "✅ Confirm",
            cancel = "❌ Cancel",
            confirmed = "Confirmed",
            action_completed = "Action completed",
            enabled = "Enabled",
            speed_set_50 = "Speed set to 50",
            disabled = "Disabled",
            speed_reset = "Speed reset to normal",
            weapon_switched = "Weapon switched",
            using_weapon = "You are using: ",
            attack = "Attack!",
            skill_used = "Skill has been used",
            loading = "Loading...",
            saved = "Saved",
            your_name_is = "Your name is: ",
        },
        
        -- Descriptions
        descriptions = {
            auto_farm_desc = "Automatically farm enemies",
            fast_attack_desc = "Attack faster",
            kill_aura_desc = "Kill enemies around you",
            fly_desc = "Enable flying",
            noclip_desc = "Walk through walls",
            anti_afk_desc = "Prevent AFK kick",
            server_hop_desc = "Join a random server",
            test_notification_desc = "Click to show notification",
            confirmation_dialog_desc = "Show dialog box with selection buttons",
            speed_boost_desc = "Walk faster",
            jump_power_desc = "Adjust jump height",
            select_weapon_desc = "Choose weapon to use",
            special_abilities_desc = "Select multiple options",
            player_name_desc = "Type your name...",
            attack_button_desc = "Press to attack",
        },

        -- Instructions and paragraphs
        instructions = {
            main_instructions = "This is an example of Fluent UI usage\nYou can customize it as desired\nThank you for using ATG HUB!",
        },
    },
    
    -- Thai Language (ภาษาไทย)
    th = {
        code = "th",
        name = "ไทย",
        flag = "🇹🇭",
        
        -- Common UI Elements
        common = {
            loading = "กำลังโหลด...",
            success = "สำเร็จ",
            error = "ข้อผิดพลาด",
            warning = "คำเตือน",
            confirm = "ยืนยัน",
            cancel = "ยกเลิก",
            ok = "ตกลง",
            yes = "ใช่",
            no = "ไม่",
            close = "ปิด",
            save = "บันทึก",
            delete = "ลบ",
            refresh = "รีเฟรช",
            reset = "รีเซ็ต",
            enable = "เปิด",
            disable = "ปิด",
            start = "เริ่ม",
            stop = "หยุด",
            pause = "พัก",
            resume = "ดำเนินการต่อ",
        },
        
        -- Main Tab
        main = {
            title = "หลัก",
            player_info = "ข้อมูลผู้เล่น",
            name = "ชื่อ",
            date = "วันที่",
            played_time = "เวลาที่เล่น",
            auto_claim = "รับของอัตโนมัติ",
            auto_upgrade = "อัพเกรดอัตโนมัติ",
            auto_equip = "สวมใส่อัตโนมัติ",
            basic_features = "ฟีเจอร์พื้นฐาน",
            test_notification = "🔔 ทดสอบการแจ้งเตือน",
            confirmation_dialog = "❓ กล่องยืนยัน",
        },
        
        -- Farm Tab
        farm = {
            title = "ฟาร์ม",
            auto_farm = "ออโต้ฟาร์ม",
            fast_attack = "โจมตีเร็ว",
            kill_aura = "ฆ่ารอบตัว",
            auto_collect = "เก็บอัตโนมัติ",
            radius = "รัศมี",
            select_enemy = "เลือกศัตรู",
            select_target = "เลือกเป้าหมาย",
            weapons_abilities = "อาวุธและความสามารถ",
            controls = "การควบคุม",
            select_weapon = "🗡️ เลือกอาวุธ",
            special_abilities = "✨ ความสามารถพิเศษ",
            attack_button = "⚡ ปุ่มโจมตี",
        },
        
        -- Settings Tab
        settings = {
            title = "ตั้งค่า",
            language = "ภาษา",
            select_language = "เลือกภาษา",
            theme = "ธีม",
            anti_afk = "ป้องกันถูกเตะ",
            auto_rejoin = "เข้าเกมใหม่อัตโนมัติ",
            save_config = "บันทึกการตั้งค่า",
            load_config = "โหลดการตั้งค่า",
        },
        
        -- Server Tab
        server = {
            title = "เซิร์ฟเวอร์",
            server_hop = "สุ่มเซิร์ฟ",
            rejoin = "เข้าใหม่",
            lower_server = "เซิร์ฟคนน้อย",
            job_id = "รหัสเซิร์ฟ",
            input_job_id = "ใส่รหัสเซิร์ฟ",
            teleport_to_job = "วาร์ปไปเซิร์ฟ",
            copy_job_id = "คัดลอกรหัสเซิร์ฟ",
        },

        -- Teleport Tab
        teleport = {
            title = "วาร์ป",
        },

        -- Players Tab
        players = {
            title = "ผู้เล่น",
            movement = "การเคลื่อนที่",
            player_info = "ข้อมูลผู้เล่น",
            speed_boost = "🏃 เพิ่มความเร็ว",
            jump_power = "🦘 พลังกระโดด",
            player_name = "📝 ชื่อผู้เล่น",
        },
        
        -- Humanoid Tab
        humanoid = {
            title = "ตัวละคร",
            walk_speed = "ความเร็ววิ่ง",
            jump_power = "พลังกระโดด",
            fly = "บิน",
            noclip = "ทะลุกำแพง",
            fly_speed = "ความเร็วบิน",
            enable_walk = "เปิดความเร็ว",
            enable_jump = "เปิดกระโดด",
            reset_defaults = "คืนค่าเริ่มต้น",
        },
        
        -- Notifications
        notifications = {
            script_loaded = "โหลดสคริปต์สำเร็จแล้ว!",
            feature_enabled = "เปิดฟีเจอร์แล้ว",
            feature_disabled = "ปิดฟีเจอร์แล้ว",
            no_target = "ไม่พบเป้าหมาย",
            teleport_success = "วาร์ปสำเร็จ",
            teleport_failed = "วาร์ปล้มเหลว",
            invalid_input = "ข้อมูลไม่ถูกต้อง",
            please_wait = "กรุณารอสักครู่...",
            welcome = "ยินดีต้อนรับ!",
            press_left_ctrl = "กด Left Ctrl เพื่อเปิด/ปิด UI",
            success = "สำเร็จ!",
            button_pressed = "คุณกดปุ่มแล้ว",
            confirm_action = "ยืนยันการทำงาน",
            want_to_continue = "คุณต้องการดำเนินการต่อหรือไม่?",
            confirm = "✅ ยืนยัน",
            cancel = "❌ ยกเลิก",
            confirmed = "ยืนยันแล้ว",
            action_completed = "ดำเนินการสำเร็จ",
            enabled = "เปิดใช้งาน",
            speed_set_50 = "เพิ่มความเร็วเป็น 50",
            disabled = "ปิดใช้งาน",
            speed_reset = "รีเซ็ตความเร็วเป็นปกติ",
            weapon_switched = "สลับอาวุธ",
            using_weapon = "คุณกำลังใช้: ",
            attack = "โจมตี!",
            skill_used = "สกิลถูกใช้แล้ว",
            loading = "กำลังโหลด...",
            saved = "บันทึกแล้ว",
            your_name_is = "ชื่อของคุณคือ: ",
        },
        
        -- Descriptions
        descriptions = {
            auto_farm_desc = "ฟาร์มศัตรูอัตโนมัติ",
            fast_attack_desc = "โจมตีเร็วขึ้น",
            kill_aura_desc = "ฆ่าศัตรูรอบตัว",
            fly_desc = "เปิดการบิน",
            noclip_desc = "เดินทะลุกำแพง",
            anti_afk_desc = "ป้องกันถูกเตะออก",
            server_hop_desc = "เข้าเซิร์ฟเวอร์สุ่ม",
            test_notification_desc = "กดเพื่อแสดงการแจ้งเตือน",
            confirmation_dialog_desc = "แสดงกล่องโต้ตอบพร้อมปุ่มเลือก",
            speed_boost_desc = "เดินเร็วขึ้น",
            jump_power_desc = "ปรับความสูงในการกระโดด",
            select_weapon_desc = "เลือกอาวุธที่ต้องการใช้",
            special_abilities_desc = "เลือกได้หลายอัน",
            player_name_desc = "พิมพ์ชื่อของคุณ...",
            attack_button_desc = "กดเพื่อโจมตี",
        },

        -- Instructions and paragraphs
        instructions = {
            main_instructions = "นี่คือตัวอย่างการใช้งาน Fluent UI\nคุณสามารถปรับแต่งได้ตามต้องการ\nขอบคุณที่ใช้ ATG HUB!",
        },
    },
    
    -- Chinese Simplified (简体中文)
    zh = {
        code = "zh",
        name = "中文",
        flag = "🇨🇳",
        
        -- Common UI Elements
        common = {
            loading = "加载中...",
            success = "成功",
            error = "错误",
            warning = "警告",
            confirm = "确认",
            cancel = "取消",
            ok = "确定",
            yes = "是",
            no = "否",
            close = "关闭",
            save = "保存",
            delete = "删除",
            refresh = "刷新",
            reset = "重置",
            enable = "启用",
            disable = "禁用",
            start = "开始",
            stop = "停止",
            pause = "暂停",
            resume = "继续",
        },
        
        -- Main Tab
        main = {
            title = "主页",
            player_info = "玩家信息",
            name = "名称",
            date = "日期",
            played_time = "游戏时间",
            auto_claim = "自动领取",
            auto_upgrade = "自动升级",
            auto_equip = "自动装备",
            basic_features = "基本功能",
            test_notification = "🔔 测试通知",
            confirmation_dialog = "❓ 确认对话框",
        },
        
        -- Farm Tab
        farm = {
            title = "刷怪",
            auto_farm = "自动刷怪",
            fast_attack = "快速攻击",
            kill_aura = "范围击杀",
            auto_collect = "自动收集",
            radius = "范围",
            select_enemy = "选择敌人",
            select_target = "选择目标",
            weapons_abilities = "武器和能力",
            controls = "控制",
            select_weapon = "🗡️ 选择武器",
            special_abilities = "✨ 特殊能力",
            attack_button = "⚡ 攻击按钮",
        },
        
        -- Settings Tab
        settings = {
            title = "设置",
            language = "语言",
            select_language = "选择语言",
            theme = "主题",
            anti_afk = "防挂机",
            auto_rejoin = "自动重连",
            save_config = "保存配置",
            load_config = "加载配置",
        },
        
        -- Server Tab
        server = {
            title = "服务器",
            server_hop = "换服",
            rejoin = "重新加入",
            lower_server = "低人数服务器",
            job_id = "服务器ID",
            input_job_id = "输入服务器ID",
            teleport_to_job = "传送到服务器",
            copy_job_id = "复制当前服务器ID",
        },

        -- Teleport Tab
        teleport = {
            title = "传送",
        },

        -- Players Tab
        players = {
            title = "玩家",
            movement = "移动",
            player_info = "玩家信息",
            speed_boost = "🏃 速度提升",
            jump_power = "🦘 跳跃力量",
            player_name = "📝 玩家名称",
        },
        
        -- Humanoid Tab
        humanoid = {
            title = "角色",
            walk_speed = "移动速度",
            jump_power = "跳跃力量",
            fly = "飞行",
            noclip = "穿墙",
            fly_speed = "飞行速度",
            enable_walk = "启用速度",
            enable_jump = "启用跳跃",
            reset_defaults = "恢复默认",
        },
        
        -- Notifications
        notifications = {
            script_loaded = "脚本加载成功！",
            feature_enabled = "功能已启用",
            feature_disabled = "功能已禁用",
            no_target = "未找到目标",
            teleport_success = "传送成功",
            teleport_failed = "传送失败",
            invalid_input = "无效输入",
            please_wait = "请稍候...",
            welcome = "欢迎！",
            press_left_ctrl = "按 Left Ctrl 打开/关闭 UI",
            success = "成功！",
            button_pressed = "您按下了按钮",
            confirm_action = "确认操作",
            want_to_continue = "您要继续吗？",
            confirm = "✅ 确认",
            cancel = "❌ 取消",
            confirmed = "已确认",
            action_completed = "操作完成",
            enabled = "已启用",
            speed_set_50 = "速度设置为 50",
            disabled = "已禁用",
            speed_reset = "速度重置为正常",
            weapon_switched = "武器已切换",
            using_weapon = "您正在使用: ",
            attack = "攻击！",
            skill_used = "技能已使用",
            loading = "加载中...",
            saved = "已保存",
            your_name_is = "您的名字是: ",
        },
        
        -- Descriptions
        descriptions = {
            auto_farm_desc = "自动刷怪",
            fast_attack_desc = "加快攻击速度",
            kill_aura_desc = "击杀周围敌人",
            fly_desc = "启用飞行",
            noclip_desc = "穿墙模式",
            anti_afk_desc = "防止被踢出",
            server_hop_desc = "加入随机服务器",
            test_notification_desc = "点击显示通知",
            confirmation_dialog_desc = "显示带有选择按钮的对话框",
            speed_boost_desc = "走得更快",
            jump_power_desc = "调整跳跃高度",
            select_weapon_desc = "选择要使用的武器",
            special_abilities_desc = "可以选择多个",
            player_name_desc = "输入您的名字...",
            attack_button_desc = "按下攻击",
        },

        -- Instructions and paragraphs
        instructions = {
            main_instructions = "这是 Fluent UI 用法示例\n您可以根据需要自定义\n感谢使用 ATG HUB！",
        },
    },
}

-- ============================================================
-- CURRENT LANGUAGE STATE
-- ============================================================
LanguageSystem.currentLanguage = "en" -- Default language

-- ============================================================
-- CORE FUNCTIONS
-- ============================================================

-- Get text by key path (e.g., "common.loading", "main.title")
function LanguageSystem:GetText(keyPath)
    local lang = self.Languages[self.currentLanguage]
    if not lang then
        lang = self.Languages.en -- Fallback to English
    end
    
    local keys = {}
    for key in string.gmatch(keyPath, "[^.]+") do
        table.insert(keys, key)
    end
    
    local value = lang
    for _, key in ipairs(keys) do
        if type(value) == "table" and value[key] then
            value = value[key]
        else
            -- Fallback to English if key not found
            local enValue = self.Languages.en
            for _, k in ipairs(keys) do
                if type(enValue) == "table" and enValue[k] then
                    enValue = enValue[k]
                else
                    return keyPath -- Return key path if not found
                end
            end
            return enValue
        end
    end
    
    return value
end

-- Short alias for GetText
function LanguageSystem:T(keyPath)
    return self:GetText(keyPath)
end

-- Set current language
function LanguageSystem:SetLanguage(langCode)
    if self.Languages[langCode] then
        self.currentLanguage = langCode
        
        -- Save to getgenv for persistence
        if getgenv then
            getgenv().ATG_Language = langCode
        end
        
        -- Trigger language change event
        if self.onLanguageChanged then
            pcall(function()
                self.onLanguageChanged(langCode)
            end)
        end
        
        return true
    end
    return false
end

-- Get current language
function LanguageSystem:GetCurrentLanguage()
    return self.currentLanguage
end

-- Get all available languages
function LanguageSystem:GetAvailableLanguages()
    local languages = {}
    for code, data in pairs(self.Languages) do
        table.insert(languages, {
            code = code,
            name = data.name,
            flag = data.flag,
            display = string.format("%s %s", data.flag, data.name)
        })
    end
    
    -- Sort by name
    table.sort(languages, function(a, b)
        return a.name < b.name
    end)
    
    return languages
end

-- Register language change callback
function LanguageSystem:OnLanguageChanged(callback)
    self.onLanguageChanged = callback
end

-- Initialize language system
function LanguageSystem:Initialize()
    -- Load saved language from getgenv
    if getgenv and getgenv().ATG_Language then
        local savedLang = getgenv().ATG_Language
        if self.Languages[savedLang] then
            self.currentLanguage = savedLang
        end
    end
    
    return self
end

-- ============================================================
-- GLOBAL INSTANCE
-- ============================================================
local instance = setmetatable({}, LanguageSystem)
instance:Initialize()

-- Expose globally
if getgenv then
    getgenv().ATG_Lang = instance
end
_G.ATG_Lang = instance

return instance
