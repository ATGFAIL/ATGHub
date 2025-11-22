-- ============================================================
-- ATG HUB Premium - Raise Animals (Multi-Language Edition)
-- ============================================================

repeat task.wait() until game:IsLoaded()

-- ============================================================
-- LANGUAGE SYSTEM INITIALIZATION
-- ============================================================
local LanguageSystem = {}
LanguageSystem.__index = LanguageSystem

LanguageSystem.Languages = {
    -- English Language
    en = {
        code = "en",
        name = "English",
        flag = "🇺🇸",
        
        common = {
            loading = "Loading...",
            success = "Success",
            error = "Error",
            confirm = "Confirm",
            cancel = "Cancel",
            enabled = "Enabled",
            disabled = "Disabled",
        },
        
        tabs = {
            main = "Main",
            farm = "Pen",
            egg = "Egg",
            event = "Events",
            autoplay = "Auto Play",
            screen = "Screen",
            humanoid = "Humanoid",
            players = "Players",
            server = "Server",
            settings = "Settings",
        },
        
        main = {
            player_info = "Player Info",
            name = "Name",
            date = "Date",
            played_time = "Played Time",
            auto_buy_food = "Auto Buy Food",
            auto_buy_animals = "Auto Buy Animals",
            auto_feed = "Auto Feed Animals",
            auto_sell = "Auto Sell Animals",
            pickup_all = "PickUp All Animals",
            auto_place = "Auto Place Animals",
            auto_pickup = "Auto Pick UP Animals",
        },
        
        farm = {
            animal_management = "Animal Management",
            auto_place_animals = "Auto Place Animals",
            auto_pickup_animals = "Auto Pick UP Animals",
            select_animals_place = "Select Animals to Place",
            select_animals_pickup = "Select Animals to PickUp",
            warning_area = "This will only work when you stand inside your animal area!",
        },
        
        egg = {
            dino_exchange = "Dinosaur Exchange",
            auto_exchange = "Auto Exchange DNA",
            exchange_desc = "Exchange dinosaur DNA automatically",
        },
        
        event = {
            desert_event = "Desert Event",
            auto_buy_event = "Auto Buy Desert Event",
            select_items = "Select Desert Event Items",
            buy_desc = "Auto buy event items",
        },
        
        autoplay = {
            play = "Play",
            auto_retry = "Auto Retry",
            auto_play = "Auto Play",
            auto_play_modes = "Auto Play Modes",
            swap_mode = "Swap Mode",
            swap_animal = "Swap Animal",
            auto_swap = "Auto Swap Animal",
            range_swap = "Range Swap",
            config = "Config",
            scan_interval = "Scan Interval",
            pathfind_interval = "Pathfind Interval",
            avoidance_settings = "Avoidance Settings",
            avoid_distance = "Avoid Distance",
            animal_safe_distance = "Animal Safe Distance",
            animal_critical_distance = "Animal Critical Distance",
            advanced = "Advanced",
            advanced_pathfinding = "Advanced Pathfinding",
            strict_avoidance = "Strict Avoidance",
            pathfind_rays = "Pathfind Rays",
            pathfind_distance = "Pathfind Distance",
            reset_defaults = "Reset to Defaults",
            rebuild_caches = "Rebuild All Caches",
        },
        
        screen = {
            remove_gui = "Remove GUI",
            remove_notify = "Remove Notify",
            remove_gui_desc = "Remove all screen blocking GUIs",
            remove_notify_desc = "Remove purchase notifications",
        },
        
        humanoid = {
            speed_jump = "Speed & Jump",
            walk_speed = "WalkSpeed",
            jump_power = "JumpPower",
            enable_walk = "Enable Walk",
            enable_jump = "Enable Jump",
            reset_defaults = "Reset to defaults",
            fly_noclip = "Fly & Noclip",
            fly = "Fly",
            noclip = "Noclip",
            fly_speed = "Fly Speed",
            fly_key = "Fly Key (Toggle)",
        },
        
        players = {
            player = "Player",
            teleport = "Teleport",
            refresh_list = "Refresh list",
            method = "Method",
            teleport_now = "Teleport Now",
            auto_follow = "Auto-Follow",
            refresh_desc = "Refresh player list",
            teleport_desc = "Teleport to selected player instantly",
            follow_desc = "Follow selected player",
        },
        
        server = {
            server_hop = "Server Hop",
            rejoin = "Rejoin",
            lower_server = "Lower Server",
            job_id = "Job ID",
            input_job_id = "Input Job ID",
            teleport_job = "Teleport to Job",
            copy_job_id = "Copy Current Job ID",
            hop_desc = "Join a Random server",
            rejoin_desc = "Rejoin this server",
            lower_desc = "Join the Lower server",
            input_desc = "Paste Job ID here",
            teleport_desc = "Teleport to the Job ID above",
            copy_desc = "Copy current server Job ID",
        },
        
        settings = {
            language = "Language",
            select_language = "Select Language",
            anti_afk = "Anti-AFK",
            auto_rejoin = "Auto Rejoin",
        },
        
        notifications = {
            loaded = "Script loaded successfully!",
            welcome = "Welcome to ATG HUB Premium",
            press_ctrl = "Press Left Ctrl to open/close UI",
            pickup_success = "PickUp %d animals",
            pickup_failed = "Animal folder not found in your Tycoon",
            no_items_selected = "No items selected!",
            please_select = "Please select the animal you want to sell first",
            caches_rebuilt = "All detection caches have been refreshed",
            auto_retry_desc = "Auto retry when dead",
            auto_play_desc = "Enable auto play",
            modes_desc = "Select play modes",
            swap_mode_desc = "Auto-interact behavior",
            animal_tween_desc = "Auto swap animals",
            range_desc = "Animal catch range",
            scan_desc = "Lower = more responsive, higher CPU",
            pathfind_desc = "How often to recalculate path",
            avoidance_desc = "Configure obstacle detection ranges",
            avoid_desc = "Base obstacle detection range",
            safe_desc = "Minimum distance from animals",
            critical_desc = "Emergency avoidance distance",
            advanced_desc = "Fine-tune AI behavior and pathfinding",
            advanced_path_desc = "Use multi-ray scanning for better paths",
            strict_desc = "Never allow collisions (safer but slower)",
            rays_desc = "More rays = better accuracy, higher CPU",
            distance_desc = "How far ahead to scan",
            defaults_desc = "Restore all settings to default",
            rebuild_desc = "Refresh obstacle detection",
        },
    },
    
    -- Thai Language
    th = {
        code = "th",
        name = "ไทย",
        flag = "🇹🇭",
        
        common = {
            loading = "กำลังโหลด...",
            success = "สำเร็จ",
            error = "ผิดพลาด",
            confirm = "ยืนยัน",
            cancel = "ยกเลิก",
            enabled = "เปิดใช้งาน",
            disabled = "ปิดใช้งาน",
        },
        
        tabs = {
            main = "หลัก",
            farm = "คอก",
            egg = "ไข่",
            event = "อีเว้นท์",
            autoplay = "เล่นออโต้",
            screen = "หน้าจอ",
            humanoid = "ตัวละคร",
            players = "ผู้เล่น",
            server = "เซิร์ฟเวอร์",
            settings = "ตั้งค่า",
        },
        
        main = {
            player_info = "ข้อมูลผู้เล่น",
            name = "ชื่อ",
            date = "วันที่",
            played_time = "เวลาเล่น",
            auto_buy_food = "ซื้ออาหารออโต้",
            auto_buy_animals = "ซื้อสัตว์ออโต้",
            auto_feed = "ให้อาหารออโต้",
            auto_sell = "ขายสัตว์ออโต้",
            pickup_all = "เก็บสัตว์ทั้งหมด",
            auto_place = "วางสัตว์ออโต้",
            auto_pickup = "เก็บสัตว์ออโต้",
        },
        
        farm = {
            animal_management = "จัดการสัตว์",
            auto_place_animals = "วางสัตว์ออโต้",
            auto_pickup_animals = "เก็บสัตว์ออโต้",
            select_animals_place = "เลือกสัตว์ที่จะวาง",
            select_animals_pickup = "เลือกสัตว์ที่จะเก็บ",
            warning_area = "จะใช้งานได้ต้องยืนในคอกสัตว์เท่านั้น!",
        },
        
        egg = {
            dino_exchange = "แลกดีเอ็นเอไดโน",
            auto_exchange = "แลกดีเอ็นเออัตโนมัติ",
            exchange_desc = "แลกดีเอ็นเอไดโนเสาร์อัตโนมัติ",
        },
        
        event = {
            desert_event = "อีเว้นท์ทะเลทราย",
            auto_buy_event = "ซื้อของอีเว้นท์ออโต้",
            select_items = "เลือกของอีเว้นท์",
            buy_desc = "ซื้อของอีเว้นท์อัตโนมัติ",
        },
        
        autoplay = {
            play = "เล่น",
            auto_retry = "ลองใหม่อัตโนมัติ",
            auto_play = "เล่นออโต้",
            auto_play_modes = "โหมดเล่นออโต้",
            swap_mode = "โหมดสลับ",
            swap_animal = "สลับสัตว์",
            auto_swap = "สลับสัตว์ออโต้",
            range_swap = "ระยะจับสัตว์",
            config = "ตั้งค่า",
            scan_interval = "ความถี่สแกน",
            pathfind_interval = "ความถี่หาเส้นทาง",
            avoidance_settings = "การหลีกหนี",
            avoid_distance = "ระยะหลีกเลี่ยง",
            animal_safe_distance = "ระยะปลอดภัยจากสัตว์",
            animal_critical_distance = "ระยะวิกฤติจากสัตว์",
            advanced = "ขั้นสูง",
            advanced_pathfinding = "หาเส้นทางขั้นสูง",
            strict_avoidance = "หลีกเลี่ยงเข้มงวด",
            pathfind_rays = "จำนวนรังสีสแกน",
            pathfind_distance = "ระยะสแกนเส้นทาง",
            reset_defaults = "คืนค่าเริ่มต้น",
            rebuild_caches = "สร้างแคชใหม่",
        },
        
        screen = {
            remove_gui = "ซ่อน UI",
            remove_notify = "ซ่อนการแจ้งเตือน",
            remove_gui_desc = "ลบ UI ที่บังหน้าจอทั้งหมด",
            remove_notify_desc = "เอาการแจ้งเตือนตอนซื้อของออก",
        },
        
        humanoid = {
            speed_jump = "ความเร็ว & กระโดด",
            walk_speed = "ความเร็ววิ่ง",
            jump_power = "พลังกระโดด",
            enable_walk = "เปิดความเร็ว",
            enable_jump = "เปิดกระโดด",
            reset_defaults = "คืนค่าเริ่มต้น",
            fly_noclip = "บิน & ทะลุกำแพง",
            fly = "บิน",
            noclip = "ทะลุกำแพง",
            fly_speed = "ความเร็วบิน",
            fly_key = "ปุ่มบิน (เปิด/ปิด)",
        },
        
        players = {
            player = "ผู้เล่น",
            teleport = "วาร์ป",
            refresh_list = "รีเฟรชรายชื่อ",
            method = "วิธีการ",
            teleport_now = "วาร์ปทันที",
            auto_follow = "ตามอัตโนมัติ",
            refresh_desc = "รีเฟรชรายชื่อผู้เล่น",
            teleport_desc = "วาร์ปไปหาผู้เล่นที่เลือก",
            follow_desc = "ติดตามผู้เล่นที่เลือก",
        },
        
        server = {
            server_hop = "สุ่มเซิร์ฟ",
            rejoin = "เข้าใหม่",
            lower_server = "เซิร์ฟคนน้อย",
            job_id = "รหัสเซิร์ฟ",
            input_job_id = "ใส่รหัสเซิร์ฟ",
            teleport_job = "วาร์ปไปเซิร์ฟ",
            copy_job_id = "คัดลอกรหัสเซิร์ฟ",
            hop_desc = "เข้าเซิร์ฟสุ่ม",
            rejoin_desc = "เข้าเซิร์ฟนี้ใหม่",
            lower_desc = "เข้าเซิร์ฟคนน้อย",
            input_desc = "วางรหัสเซิร์ฟที่นี่",
            teleport_desc = "วาร์ปไปรหัสเซิร์ฟที่ใส่",
            copy_desc = "คัดลอกรหัสเซิร์ฟปัจจุบัน",
        },
        
        settings = {
            language = "ภาษา",
            select_language = "เลือกภาษา",
            anti_afk = "ป้องกันถูกเตะ",
            auto_rejoin = "เข้าเกมใหม่อัตโนมัติ",
        },
        
        notifications = {
            loaded = "โหลดสคริปต์สำเร็จ!",
            welcome = "ยินดีต้อนรับสู่ ATG HUB Premium",
            press_ctrl = "กด Left Ctrl เพื่อเปิด/ปิด UI",
            pickup_success = "เก็บสัตว์ %d ตัว",
            pickup_failed = "ไม่พบโฟลเดอร์สัตว์ใน Tycoon ของคุณ",
            no_items_selected = "ยังไม่ได้เลือกอะไรเลย!",
            please_select = "กรุณาเลือกสัตว์ที่ต้องการขายก่อน",
            caches_rebuilt = "สร้างแคชการตรวจจับใหม่เรียบร้อย",
            auto_retry_desc = "ลองใหม่อัตโนมัติเมื่อตาย",
            auto_play_desc = "เปิดเล่นออโต้",
            modes_desc = "เลือกโหมดการเล่น",
            swap_mode_desc = "พฤติกรรมการโต้ตอบ",
            animal_tween_desc = "สลับสัตว์อัตโนมัติ",
            range_desc = "ระยะจับสัตว์",
            scan_desc = "ต่ำ = ตอบสนองเร็ว, สูง = ใช้ CPU น้อย",
            pathfind_desc = "ความถี่คำนวณเส้นทางใหม่",
            avoidance_desc = "ตั้งค่าระยะตรวจจับสิ่งกีดขวาง",
            avoid_desc = "ระยะตรวจจับพื้นฐาน",
            safe_desc = "ระยะห่างขั้นต่ำจากสัตว์",
            critical_desc = "ระยะหลีกเลี่ยงฉุกเฉิน",
            advanced_desc = "ปรับแต่ง AI และการหาเส้นทาง",
            advanced_path_desc = "ใช้การสแกนแบบหลายรังสี",
            strict_desc = "ไม่อนุญาตให้ชน (ปลอดภัยแต่ช้า)",
            rays_desc = "รังสีมาก = แม่นยำมาก, ใช้ CPU สูง",
            distance_desc = "ระยะสแกนไปข้างหน้า",
            defaults_desc = "คืนค่าทั้งหมดเป็นค่าเริ่มต้น",
            rebuild_desc = "รีเฟรชการตรวจจับสิ่งกีดขวาง",
        },
    },
    
    -- Chinese Language
    zh = {
        code = "zh",
        name = "中文",
        flag = "🇨🇳",
        
        common = {
            loading = "加载中...",
            success = "成功",
            error = "错误",
            confirm = "确认",
            cancel = "取消",
            enabled = "已启用",
            disabled = "已禁用",
        },
        
        tabs = {
            main = "主页",
            farm = "围栏",
            egg = "蛋",
            event = "活动",
            autoplay = "自动游玩",
            screen = "屏幕",
            humanoid = "角色",
            players = "玩家",
            server = "服务器",
            settings = "设置",
        },
        
        main = {
            player_info = "玩家信息",
            name = "名称",
            date = "日期",
            played_time = "游戏时间",
            auto_buy_food = "自动购买食物",
            auto_buy_animals = "自动购买动物",
            auto_feed = "自动喂养动物",
            auto_sell = "自动出售动物",
            pickup_all = "拾取所有动物",
            auto_place = "自动放置动物",
            auto_pickup = "自动拾取动物",
        },
        
        farm = {
            animal_management = "动物管理",
            auto_place_animals = "自动放置动物",
            auto_pickup_animals = "自动拾取动物",
            select_animals_place = "选择要放置的动物",
            select_animals_pickup = "选择要拾取的动物",
            warning_area = "仅在动物区域内有效！",
        },
        
        egg = {
            dino_exchange = "恐龙交换",
            auto_exchange = "自动交换DNA",
            exchange_desc = "自动交换恐龙DNA",
        },
        
        event = {
            desert_event = "沙漠活动",
            auto_buy_event = "自动购买活动物品",
            select_items = "选择活动物品",
            buy_desc = "自动购买活动物品",
        },
        
        autoplay = {
            play = "游玩",
            auto_retry = "自动重试",
            auto_play = "自动游玩",
            auto_play_modes = "自动游玩模式",
            swap_mode = "切换模式",
            swap_animal = "切换动物",
            auto_swap = "自动切换动物",
            range_swap = "切换范围",
            config = "配置",
            scan_interval = "扫描间隔",
            pathfind_interval = "寻路间隔",
            avoidance_settings = "避障设置",
            avoid_distance = "避让距离",
            animal_safe_distance = "动物安全距离",
            animal_critical_distance = "动物危险距离",
            advanced = "高级",
            advanced_pathfinding = "高级寻路",
            strict_avoidance = "严格避让",
            pathfind_rays = "寻路射线数",
            pathfind_distance = "寻路距离",
            reset_defaults = "恢复默认",
            rebuild_caches = "重建缓存",
        },
        
        screen = {
            remove_gui = "隐藏界面",
            remove_notify = "隐藏通知",
            remove_gui_desc = "移除挡住屏幕的界面",
            remove_notify_desc = "移除购买通知",
        },
        
        humanoid = {
            speed_jump = "速度与跳跃",
            walk_speed = "移动速度",
            jump_power = "跳跃力量",
            enable_walk = "启用速度",
            enable_jump = "启用跳跃",
            reset_defaults = "恢复默认",
            fly_noclip = "飞行与穿墙",
            fly = "飞行",
            noclip = "穿墙",
            fly_speed = "飞行速度",
            fly_key = "飞行键（切换）",
        },
        
        players = {
            player = "玩家",
            teleport = "传送",
            refresh_list = "刷新列表",
            method = "方法",
            teleport_now = "立即传送",
            auto_follow = "自动跟随",
            refresh_desc = "刷新玩家列表",
            teleport_desc = "传送到所选玩家",
            follow_desc = "跟随所选玩家",
        },
        
        server = {
            server_hop = "换服",
            rejoin = "重新加入",
            lower_server = "低人数服务器",
            job_id = "服务器ID",
            input_job_id = "输入服务器ID",
            teleport_job = "传送到服务器",
            copy_job_id = "复制当前服务器ID",
            hop_desc = "加入随机服务器",
            rejoin_desc = "重新加入此服务器",
            lower_desc = "加入低人数服务器",
            input_desc = "在此粘贴服务器ID",
            teleport_desc = "传送到上面的服务器ID",
            copy_desc = "复制当前服务器ID",
        },
        
        settings = {
            language = "语言",
            select_language = "选择语言",
            anti_afk = "防挂机",
            auto_rejoin = "自动重连",
        },
        
        notifications = {
            loaded = "脚本加载成功！",
            welcome = "欢迎使用 ATG HUB Premium",
            press_ctrl = "按 Left Ctrl 打开/关闭界面",
            pickup_success = "拾取 %d 只动物",
            pickup_failed = "在你的庄园中未找到动物文件夹",
            no_items_selected = "未选择任何物品！",
            please_select = "请先选择要出售的动物",
            caches_rebuilt = "所有检测缓存已刷新",
            auto_retry_desc = "死亡时自动重试",
            auto_play_desc = "启用自动游玩",
            modes_desc = "选择游玩模式",
            swap_mode_desc = "自动交互行为",
            animal_tween_desc = "自动切换动物",
            range_desc = "捕获动物的范围",
            scan_desc = "低 = 响应快, 高 = CPU占用少",
            pathfind_desc = "重新计算路径的频率",
            avoidance_desc = "配置障碍物检测范围",
            avoid_desc = "基础障碍物检测范围",
            safe_desc = "与动物的最小距离",
            critical_desc = "紧急避让距离",
            advanced_desc = "微调AI行为和寻路",
            advanced_path_desc = "使用多射线扫描获得更好的路径",
            strict_desc = "永不允许碰撞（更安全但更慢）",
            rays_desc = "射线越多 = 精度越高, CPU占用越高",
            distance_desc = "向前扫描的距离",
            defaults_desc = "恢复所有设置为默认值",
            rebuild_desc = "刷新障碍物检测",
        },
    },
}

-- Language System Core
LanguageSystem.currentLanguage = "en"
LanguageSystem.supportedLanguages = {"en", "th", "zh"}

function LanguageSystem:GetText(keyPath)
    if not keyPath or type(keyPath) ~= "string" then
        return "INVALID_KEY"
    end
    
    local lang = self.Languages[self.currentLanguage]
    if not lang then
        lang = self.Languages["en"]
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
            return keyPath
        end
    end
    
    return value
end

function LanguageSystem:T(keyPath)
    return self:GetText(keyPath)
end

function LanguageSystem:SetLanguage(langCode)
    if self.Languages[langCode] then
        self.currentLanguage = langCode
        if getgenv then
            getgenv().ATG_Language = langCode
        end
        return true
    end
    return false
end

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
    return languages
end

function LanguageSystem:Initialize()
    if getgenv and getgenv().ATG_Language then
        local savedLang = getgenv().ATG_Language
        if self.Languages[savedLang] then
            self.currentLanguage = savedLang
        end
    end
    return self
end

local Lang = setmetatable({}, LanguageSystem)
Lang:Initialize()

if getgenv then
    getgenv().ATG_Lang = Lang
end
_G.ATG_Lang = Lang

-- ============================================================
-- USAGE EXAMPLE
-- ============================================================
-- วิธีใช้งานระบบภาษา:
--
-- 1. เปลี่ยนภาษา:
--    Lang:SetLanguage("th")  -- เปลี่ยนเป็นภาษาไทย
--    Lang:SetLanguage("en")  -- เปลี่ยนเป็นภาษาอังกฤษ
--    Lang:SetLanguage("zh")  -- เปลี่ยนเป็นภาษาจีน
--
-- 2. ดึงข้อความ:
--    Lang:T("tabs.main")           -- "Main" หรือ "หลัก" หรือ "主页"
--    Lang:T("main.player_info")    -- "Player Info" หรือ "ข้อมูลผู้เล่น"
--    Lang:T("common.loading")      -- "Loading..." หรือ "กำลังโหลด..."
--
-- 3. ใช้ในการสร้าง UI:
--    local mainTab = Window:AddTab({Title = Lang:T("tabs.main"), Icon = "repeat"})
--    local button = mainTab:AddButton({
--        Title = Lang:T("main.pickup_all"),
--        Description = Lang:T("farm.warning_area")
--    })
--
-- 4. ดูภาษาที่มี:
--    local languages = Lang:GetAvailableLanguages()
--    for _, lang in ipairs(languages) do
--        print(lang.display)  -- 🇺🇸 English, 🇹🇭 ไทย, 🇨🇳 中文
--    end
--
-- ============================================================
