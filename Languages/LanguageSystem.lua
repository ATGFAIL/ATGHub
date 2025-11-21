--[[
    ═══════════════════════════════════════════════════════════════
    ATG Hub Multi-Language System - All in One
    ═══════════════════════════════════════════════════════════════

    ระบบจัดการหลายภาษาแบบครบวงจร (All-in-One)
    เหมือนระบบธีม - ทุกอย่างอยู่ในไฟล์เดียว

    Author: ATG Team
    Version: 2.0.0

    Features:
    ✓ 4 ภาษา: EN, TH, JP, CN
    ✓ 100+ Translation Keys
    ✓ Auto-detection
    ✓ Variable Replacement
    ✓ Fallback System
    ✓ Easy Integration

    Usage:
    local Lang = loadstring(game:HttpGet("..."))()
    print(Lang:Get("window_title"))
]]

-- ═══════════════════════════════════════════════════════════════
-- TRANSLATION DATABASE - ฐานข้อมูลคำแปลทั้งหมด
-- ═══════════════════════════════════════════════════════════════

local TranslationDB = {
    -- ═══════════════════════════════════════════════════════════
    -- ENGLISH (EN) - ภาษาอังกฤษ
    -- ═══════════════════════════════════════════════════════════
    EN = {
        -- Window & General
        window_title = "ATG HUB Premium",
        window_subtitle = "[ Raise Animals ]",
        language = "Language",
        language_name = "English",
        language_changed = "Language Changed",
        language_changed_desc = "UI will reload to apply language changes",

        -- Tabs
        tab_main = "Main",
        tab_pen = "Pen",
        tab_egg = "Egg",
        tab_events = "Events",
        tab_autoplay = "Auto Play",
        tab_screen = "Screen",
        tab_humanoid = "Humanoid",
        tab_players = "Players",
        tab_server = "Server",
        tab_settings = "Settings",

        -- Player Info
        player_info = "Player Info",
        player_name = "Name",
        player_displayname = "Display Name",
        player_userid = "User ID",
        player_health = "Health",
        player_speed = "Speed",
        player_jump = "Jump Power",
        player_position = "Position",

        -- Auto Features
        auto_feed = "Auto Feed Animals",
        auto_feed_desc = "Automatically feed animals",
        auto_sell = "Auto Sell",
        auto_sell_desc = "Automatically sell animals",
        auto_sell_warn = "Auto Sell Warning",
        auto_sell_warn_desc = "This will sell all selected animals automatically!",
        auto_buy_food = "Auto Buy Food",
        auto_buy_food_desc = "Automatically purchase food for animals",
        auto_buy_animals = "Auto Buy Animals",
        auto_buy_animals_desc = "Automatically purchase animals",
        auto_place = "Auto Place Animals",
        auto_place_desc = "Automatically place animals in pen",
        auto_pickup = "Auto PickUp Animals",
        auto_pickup_desc = "Automatically pick up animals from pen",
        pickup_all = "PickUp All Animals",
        pickup_all_desc = "Pick up all animals at once",
        auto_exchange_dna = "Auto Exchange DNA",
        auto_exchange_dna_desc = "Automatically exchange DNA points",

        -- Selections
        select_items = "Select Items",
        select_animals = "Select Animals",
        select_animals_feed = "Select Animals to Feed",
        select_animals_sell = "Select Animals to Sell",
        select_animals_place = "Select Animals to Place",
        select_animals_pickup = "Select Animals to PickUp",
        select_food = "Select Food",
        select_all = "Select All",
        deselect_all = "Deselect All",

        -- Events
        event_desert = "Desert Event",
        event_desert_items = "Select Desert Event Items",
        auto_buy_event = "Auto Buy Event Items",
        auto_buy_event_desc = "Automatically purchase event items",

        -- Auto Play
        auto_retry = "Auto Retry",
        auto_retry_desc = "Automatically retry failed actions",
        auto_play = "Auto Play",
        auto_play_desc = "Enable automatic gameplay",
        auto_play_modes = "Auto Play Modes",
        swap_mode = "Swap Mode",
        swap_mode_desc = "Enable animal swapping mode",
        auto_swap = "Auto Swap Animal",
        auto_swap_desc = "Automatically swap animals",
        range_swap = "Range Swap",
        range_swap_desc = "Swap range distance",
        rebuild_caches = "Rebuild All Caches",
        rebuild_caches_desc = "Rebuild all cached data",
        caches_rebuilt = "Caches Rebuilt",
        caches_rebuilt_desc = "All caches have been successfully rebuilt",
        scan_interval = "Scan Interval",
        scan_interval_desc = "Set the scanning interval (seconds)",
        pathfind_interval = "Pathfind Interval",
        pathfind_interval_desc = "Set the pathfinding interval (seconds)",

        -- Avoidance
        avoidance_settings = "Avoidance Settings",
        avoid_distance = "Avoid Distance",
        avoid_distance_desc = "Distance to avoid obstacles",

        -- Screen & GUI
        remove_gui = "Remove GUI",
        remove_gui_desc = "Remove all GUI elements that block the screen",
        remove_notify = "Remove Notifications",
        remove_notify_desc = "Hide all notification popups",
        hide_ui = "Hide UI",
        show_ui = "Show UI",

        -- Humanoid Settings
        walkspeed = "Walk Speed",
        walkspeed_desc = "Set player walking speed",
        jumppower = "Jump Power",
        jumppower_desc = "Set player jump height",
        god_mode = "God Mode",
        god_mode_desc = "Enable invincibility",
        noclip = "NoClip",
        noclip_desc = "Walk through walls",
        fly = "Fly",
        fly_desc = "Enable flight mode",

        -- Players
        teleport_to_player = "Teleport to Player",
        spectate_player = "Spectate Player",
        refresh_players = "Refresh Players",

        -- Server
        server_info = "Server Information",
        server_jobid = "Job ID",
        server_maxplayers = "Max Players",
        server_players = "Current Players",
        server_ping = "Ping",
        server_fps = "FPS",
        rejoin = "Rejoin Server",
        rejoin_desc = "Rejoin current server",
        server_hop = "Server Hop",
        server_hop_desc = "Join a different server",

        -- Notifications
        notification_success = "Success",
        notification_error = "Error",
        notification_warning = "Warning",
        notification_info = "Information",

        -- Actions
        start = "Start",
        stop = "Stop",
        pause = "Pause",
        resume = "Resume",
        enable = "Enable",
        disable = "Disable",
        save = "Save",
        load = "Load",
        reset = "Reset",
        apply = "Apply",
        cancel = "Cancel",
        confirm = "Confirm",

        -- Status
        status_active = "Active",
        status_inactive = "Inactive",
        status_running = "Running",
        status_stopped = "Stopped",
        status_loading = "Loading...",
        status_success = "Success",
        status_failed = "Failed",

        -- Common
        enabled = "Enabled",
        disabled = "Disabled",
        on = "On",
        off = "Off",
        yes = "Yes",
        no = "No",
        ok = "OK",
        close = "Close",

        -- Numbers & Units
        count = "{count}",
        amount = "Amount: {amount}",
        total = "Total: {total}",
        seconds = "Seconds",
        minutes = "Minutes",
        hours = "Hours",

        -- Errors & Warnings
        error_not_found = "Not found",
        error_failed = "Operation failed",
        error_invalid = "Invalid input",
        warning_confirm = "Are you sure?",
        warning_irreversible = "This action cannot be undone!",

        -- Misc
        credits = "Created by ATG Team",
        version = "Version {version}",
        discord = "Join Discord",
        update_available = "Update Available",
        latest_version = "You have the latest version",
    },

    -- ═══════════════════════════════════════════════════════════
    -- THAI (TH) - ภาษาไทย
    -- ═══════════════════════════════════════════════════════════
    TH = {
        -- Window & General
        window_title = "ATG HUB พรีเมียม",
        window_subtitle = "[ เลี้ยงสัตว์ ]",
        language = "ภาษา",
        language_name = "ไทย",
        language_changed = "เปลี่ยนภาษาแล้ว",
        language_changed_desc = "UI จะรีโหลดเพื่อใช้ภาษาใหม่",

        -- Tabs
        tab_main = "หลัก",
        tab_pen = "คอกสัตว์",
        tab_egg = "ไข่",
        tab_events = "อีเว้นท์",
        tab_autoplay = "เล่นอัตโนมัติ",
        tab_screen = "หน้าจอ",
        tab_humanoid = "ตัวละคร",
        tab_players = "ผู้เล่น",
        tab_server = "เซิร์ฟเวอร์",
        tab_settings = "ตั้งค่า",

        -- Player Info
        player_info = "ข้อมูลผู้เล่น",
        player_name = "ชื่อ",
        player_displayname = "ชื่อที่แสดง",
        player_userid = "รหัสผู้ใช้",
        player_health = "พลังชีวิต",
        player_speed = "ความเร็ว",
        player_jump = "พลังกระโดด",
        player_position = "ตำแหน่ง",

        -- Auto Features
        auto_feed = "ให้อาหารสัตว์อัตโนมัติ",
        auto_feed_desc = "ให้อาหารสัตว์แบบอัตโนมัติ",
        auto_sell = "ขายอัตโนมัติ",
        auto_sell_desc = "ขายสัตว์แบบอัตโนมัติ",
        auto_sell_warn = "คำเตือนการขายอัตโนมัติ",
        auto_sell_warn_desc = "ระบบจะขายสัตว์ที่เลือกทั้งหมดแบบอัตโนมัติ!",
        auto_buy_food = "ซื้ออาหารอัตโนมัติ",
        auto_buy_food_desc = "ซื้ออาหารสำหรับสัตว์แบบอัตโนมัติ",
        auto_buy_animals = "ซื้อสัตว์อัตโนมัติ",
        auto_buy_animals_desc = "ซื้อสัตว์แบบอัตโนมัติ",
        auto_place = "วางสัตว์อัตโนมัติ",
        auto_place_desc = "วางสัตว์ในคอกแบบอัตโนมัติ",
        auto_pickup = "เก็บสัตว์อัตโนมัติ",
        auto_pickup_desc = "เก็บสัตว์จากคอกแบบอัตโนมัติ",
        pickup_all = "เก็บสัตว์ทั้งหมด",
        pickup_all_desc = "เก็บสัตว์ทั้งหมดพร้อมกัน",
        auto_exchange_dna = "แลก DNA อัตโนมัติ",
        auto_exchange_dna_desc = "แลกคะแนน DNA แบบอัตโนมัติ",

        -- Selections
        select_items = "เลือกไอเทม",
        select_animals = "เลือกสัตว์",
        select_animals_feed = "เลือกสัตว์ที่จะให้อาหาร",
        select_animals_sell = "เลือกสัตว์ที่จะขาย",
        select_animals_place = "เลือกสัตว์ที่จะวาง",
        select_animals_pickup = "เลือกสัตว์ที่จะเก็บ",
        select_food = "เลือกอาหาร",
        select_all = "เลือกทั้งหมด",
        deselect_all = "ยกเลิกการเลือกทั้งหมด",

        -- Events
        event_desert = "อีเว้นท์ทะเลทราย",
        event_desert_items = "เลือกไอเทม Desert Event",
        auto_buy_event = "ซื้อไอเทมอีเว้นท์อัตโนมัติ",
        auto_buy_event_desc = "ซื้อไอเทมอีเว้นท์แบบอัตโนมัติ",

        -- Auto Play
        auto_retry = "ลองใหม่อัตโนมัติ",
        auto_retry_desc = "ลองใหม่โดยอัตโนมัติเมื่อล้มเหลว",
        auto_play = "เล่นอัตโนมัติ",
        auto_play_desc = "เปิดใช้งานการเล่นอัตโนมัติ",
        auto_play_modes = "โหมดเล่นอัตโนมัติ",
        swap_mode = "โหมดสลับ",
        swap_mode_desc = "เปิดโหมดสลับสัตว์",
        auto_swap = "สลับสัตว์อัตโนมัติ",
        auto_swap_desc = "สลับสัตว์แบบอัตโนมัติ",
        range_swap = "ระยะสลับ",
        range_swap_desc = "ระยะทางในการสลับ",
        rebuild_caches = "สร้างแคชใหม่ทั้งหมด",
        rebuild_caches_desc = "สร้างข้อมูลแคชใหม่ทั้งหมด",
        caches_rebuilt = "สร้างแคชสำเร็จ",
        caches_rebuilt_desc = "สร้างแคชทั้งหมดสำเร็จแล้ว",
        scan_interval = "ช่วงเวลาสแกน",
        scan_interval_desc = "ตั้งค่าช่วงเวลาในการสแกน (วินาที)",
        pathfind_interval = "ช่วงเวลาหาเส้นทาง",
        pathfind_interval_desc = "ตั้งค่าช่วงเวลาในการหาเส้นทาง (วินาที)",

        -- Avoidance
        avoidance_settings = "การตั้งค่าการหลบหลีก",
        avoid_distance = "ระยะหลบหลีก",
        avoid_distance_desc = "ระยะทางในการหลบหลีกสิ่งกีดขวาง",

        -- Screen & GUI
        remove_gui = "ลบ GUI",
        remove_gui_desc = "ลบ GUI ทั้งหมดที่บังหน้าจอ",
        remove_notify = "ลบการแจ้งเตือน",
        remove_notify_desc = "ซ่อนการแจ้งเตือนทั้งหมด",
        hide_ui = "ซ่อน UI",
        show_ui = "แสดง UI",

        -- Humanoid Settings
        walkspeed = "ความเร็วเดิน",
        walkspeed_desc = "ตั้งค่าความเร็วในการเดินของผู้เล่น",
        jumppower = "พลังกระโดด",
        jumppower_desc = "ตั้งค่าความสูงในการกระโดดของผู้เล่น",
        god_mode = "โหมดอมตะ",
        god_mode_desc = "เปิดใช้งานความอมตะ",
        noclip = "ทะลุกำแพง",
        noclip_desc = "เดินทะลุกำแพงได้",
        fly = "บิน",
        fly_desc = "เปิดโหมดบิน",

        -- Players
        teleport_to_player = "วาปไปหาผู้เล่น",
        spectate_player = "ดูผู้เล่น",
        refresh_players = "รีเฟรชรายชื่อผู้เล่น",

        -- Server
        server_info = "ข้อมูลเซิร์ฟเวอร์",
        server_jobid = "รหัสเซิร์ฟเวอร์",
        server_maxplayers = "ผู้เล่นสูงสุด",
        server_players = "ผู้เล่นปัจจุบัน",
        server_ping = "ปิง",
        server_fps = "FPS",
        rejoin = "เข้าเซิร์ฟเวอร์อีกครั้ง",
        rejoin_desc = "เข้าเซิร์ฟเวอร์เดิมอีกครั้ง",
        server_hop = "เปลี่ยนเซิร์ฟเวอร์",
        server_hop_desc = "เข้าเซิร์ฟเวอร์อื่น",

        -- Notifications
        notification_success = "สำเร็จ",
        notification_error = "ข้อผิดพลาด",
        notification_warning = "คำเตือน",
        notification_info = "ข้อมูล",

        -- Actions
        start = "เริ่ม",
        stop = "หยุด",
        pause = "พัก",
        resume = "ดำเนินการต่อ",
        enable = "เปิดใช้งาน",
        disable = "ปิดใช้งาน",
        save = "บันทึก",
        load = "โหลด",
        reset = "รีเซ็ต",
        apply = "ใช้งาน",
        cancel = "ยกเลิก",
        confirm = "ยืนยัน",

        -- Status
        status_active = "ทำงานอยู่",
        status_inactive = "ไม่ทำงาน",
        status_running = "กำลังทำงาน",
        status_stopped = "หยุดแล้ว",
        status_loading = "กำลังโหลด...",
        status_success = "สำเร็จ",
        status_failed = "ล้มเหลว",

        -- Common
        enabled = "เปิดใช้งาน",
        disabled = "ปิดใช้งาน",
        on = "เปิด",
        off = "ปิด",
        yes = "ใช่",
        no = "ไม่",
        ok = "ตกลง",
        close = "ปิด",

        -- Numbers & Units
        count = "{count}",
        amount = "จำนวน: {amount}",
        total = "ทั้งหมด: {total}",
        seconds = "วินาที",
        minutes = "นาที",
        hours = "ชั่วโมง",

        -- Errors & Warnings
        error_not_found = "ไม่พบ",
        error_failed = "การดำเนินการล้มเหลว",
        error_invalid = "ข้อมูลไม่ถูกต้อง",
        warning_confirm = "คุณแน่ใจหรือไม่?",
        warning_irreversible = "การกระทำนี้ไม่สามารถย้อนกลับได้!",

        -- Misc
        credits = "สร้างโดย ATG Team",
        version = "เวอร์ชัน {version}",
        discord = "เข้าร่วม Discord",
        update_available = "มีอัปเดตใหม่",
        latest_version = "คุณใช้เวอร์ชันล่าสุดอยู่แล้ว",
    },

    -- ═══════════════════════════════════════════════════════════
    -- JAPANESE (JP) - ภาษาญี่ปุ่น
    -- ═══════════════════════════════════════════════════════════
    JP = {
        -- Window & General
        window_title = "ATG HUB プレミアム",
        window_subtitle = "[ 動物を育てる ]",
        language = "言語",
        language_name = "日本語",
        language_changed = "言語を変更しました",
        language_changed_desc = "UIは新しい言語を適用するために再読み込みされます",

        -- Tabs
        tab_main = "メイン",
        tab_pen = "ペン",
        tab_egg = "卵",
        tab_events = "イベント",
        tab_autoplay = "自動プレイ",
        tab_screen = "画面",
        tab_humanoid = "キャラクター",
        tab_players = "プレイヤー",
        tab_server = "サーバー",
        tab_settings = "設定",

        -- Player Info
        player_info = "プレイヤー情報",
        player_name = "名前",
        player_displayname = "表示名",
        player_userid = "ユーザーID",
        player_health = "体力",
        player_speed = "速度",
        player_jump = "ジャンプ力",
        player_position = "位置",

        -- Auto Features
        auto_feed = "自動餌やり",
        auto_feed_desc = "動物に自動的に餌を与えます",
        auto_sell = "自動販売",
        auto_sell_desc = "動物を自動的に販売します",
        auto_sell_warn = "自動販売警告",
        auto_sell_warn_desc = "選択したすべての動物を自動的に販売します！",
        auto_buy_food = "自動餌購入",
        auto_buy_food_desc = "動物用の餌を自動的に購入します",
        auto_buy_animals = "自動動物購入",
        auto_buy_animals_desc = "動物を自動的に購入します",
        auto_place = "自動配置",
        auto_place_desc = "動物をペンに自動的に配置します",
        auto_pickup = "自動ピックアップ",
        auto_pickup_desc = "ペンから動物を自動的にピックアップします",
        pickup_all = "すべての動物をピックアップ",
        pickup_all_desc = "すべての動物を一度にピックアップします",
        auto_exchange_dna = "自動DNA交換",
        auto_exchange_dna_desc = "DNAポイントを自動的に交換します",

        -- Selections
        select_items = "アイテムを選択",
        select_animals = "動物を選択",
        select_animals_feed = "餌を与える動物を選択",
        select_animals_sell = "販売する動物を選択",
        select_animals_place = "配置する動物を選択",
        select_animals_pickup = "ピックアップする動物を選択",
        select_food = "餌を選択",
        select_all = "すべて選択",
        deselect_all = "すべての選択を解除",

        -- Events
        event_desert = "砂漠イベント",
        event_desert_items = "砂漠イベントアイテムを選択",
        auto_buy_event = "イベントアイテム自動購入",
        auto_buy_event_desc = "イベントアイテムを自動的に購入します",

        -- Auto Play
        auto_retry = "自動リトライ",
        auto_retry_desc = "失敗したアクションを自動的にリトライします",
        auto_play = "自動プレイ",
        auto_play_desc = "自動ゲームプレイを有効にします",
        auto_play_modes = "自動プレイモード",
        swap_mode = "スワップモード",
        swap_mode_desc = "動物スワップモードを有効にします",
        auto_swap = "自動スワップ",
        auto_swap_desc = "動物を自動的にスワップします",
        range_swap = "スワップ範囲",
        range_swap_desc = "スワップ範囲距離",
        rebuild_caches = "すべてのキャッシュを再構築",
        rebuild_caches_desc = "すべてのキャッシュデータを再構築します",
        caches_rebuilt = "キャッシュ再構築完了",
        caches_rebuilt_desc = "すべてのキャッシュが正常に再構築されました",
        scan_interval = "スキャン間隔",
        scan_interval_desc = "スキャン間隔を設定します（秒）",
        pathfind_interval = "経路探索間隔",
        pathfind_interval_desc = "経路探索間隔を設定します（秒）",

        -- Avoidance
        avoidance_settings = "回避設定",
        avoid_distance = "回避距離",
        avoid_distance_desc = "障害物を回避する距離",

        -- Screen & GUI
        remove_gui = "GUIを削除",
        remove_gui_desc = "画面をブロックするすべてのGUI要素を削除します",
        remove_notify = "通知を削除",
        remove_notify_desc = "すべての通知ポップアップを非表示にします",
        hide_ui = "UIを非表示",
        show_ui = "UIを表示",

        -- Humanoid Settings
        walkspeed = "歩行速度",
        walkspeed_desc = "プレイヤーの歩行速度を設定します",
        jumppower = "ジャンプ力",
        jumppower_desc = "プレイヤーのジャンプの高さを設定します",
        god_mode = "無敵モード",
        god_mode_desc = "無敵を有効にします",
        noclip = "壁抜け",
        noclip_desc = "壁を通り抜けます",
        fly = "飛行",
        fly_desc = "飛行モードを有効にします",

        -- Players
        teleport_to_player = "プレイヤーにテレポート",
        spectate_player = "プレイヤーを観戦",
        refresh_players = "プレイヤーリストを更新",

        -- Server
        server_info = "サーバー情報",
        server_jobid = "ジョブID",
        server_maxplayers = "最大プレイヤー数",
        server_players = "現在のプレイヤー数",
        server_ping = "ピング",
        server_fps = "FPS",
        rejoin = "サーバーに再参加",
        rejoin_desc = "現在のサーバーに再参加します",
        server_hop = "サーバーホップ",
        server_hop_desc = "別のサーバーに参加します",

        -- Notifications
        notification_success = "成功",
        notification_error = "エラー",
        notification_warning = "警告",
        notification_info = "情報",

        -- Actions
        start = "開始",
        stop = "停止",
        pause = "一時停止",
        resume = "再開",
        enable = "有効化",
        disable = "無効化",
        save = "保存",
        load = "読み込み",
        reset = "リセット",
        apply = "適用",
        cancel = "キャンセル",
        confirm = "確認",

        -- Status
        status_active = "アクティブ",
        status_inactive = "非アクティブ",
        status_running = "実行中",
        status_stopped = "停止中",
        status_loading = "読み込み中...",
        status_success = "成功",
        status_failed = "失敗",

        -- Common
        enabled = "有効",
        disabled = "無効",
        on = "オン",
        off = "オフ",
        yes = "はい",
        no = "いいえ",
        ok = "OK",
        close = "閉じる",

        -- Numbers & Units
        count = "{count}",
        amount = "数量: {amount}",
        total = "合計: {total}",
        seconds = "秒",
        minutes = "分",
        hours = "時間",

        -- Errors & Warnings
        error_not_found = "見つかりません",
        error_failed = "操作に失敗しました",
        error_invalid = "無効な入力",
        warning_confirm = "よろしいですか？",
        warning_irreversible = "この操作は元に戻せません！",

        -- Misc
        credits = "ATG Teamによって作成",
        version = "バージョン {version}",
        discord = "Discordに参加",
        update_available = "アップデート利用可能",
        latest_version = "最新バージョンをお使いです",
    },

    -- ═══════════════════════════════════════════════════════════
    -- CHINESE (CN) - ภาษาจีนตัวย่อ
    -- ═══════════════════════════════════════════════════════════
    CN = {
        -- Window & General
        window_title = "ATG HUB 高级版",
        window_subtitle = "[ 饲养动物 ]",
        language = "语言",
        language_name = "简体中文",
        language_changed = "语言已更改",
        language_changed_desc = "UI将重新加载以应用语言更改",

        -- Tabs
        tab_main = "主要",
        tab_pen = "围栏",
        tab_egg = "蛋",
        tab_events = "活动",
        tab_autoplay = "自动播放",
        tab_screen = "屏幕",
        tab_humanoid = "角色",
        tab_players = "玩家",
        tab_server = "服务器",
        tab_settings = "设置",

        -- Player Info
        player_info = "玩家信息",
        player_name = "名称",
        player_displayname = "显示名称",
        player_userid = "用户ID",
        player_health = "生命值",
        player_speed = "速度",
        player_jump = "跳跃力",
        player_position = "位置",

        -- Auto Features
        auto_feed = "自动喂养动物",
        auto_feed_desc = "自动喂养动物",
        auto_sell = "自动出售",
        auto_sell_desc = "自动出售动物",
        auto_sell_warn = "自动出售警告",
        auto_sell_warn_desc = "这将自动出售所有选定的动物！",
        auto_buy_food = "自动购买食物",
        auto_buy_food_desc = "自动为动物购买食物",
        auto_buy_animals = "自动购买动物",
        auto_buy_animals_desc = "自动购买动物",
        auto_place = "自动放置动物",
        auto_place_desc = "自动将动物放置在围栏中",
        auto_pickup = "自动拾取动物",
        auto_pickup_desc = "自动从围栏拾取动物",
        pickup_all = "拾取所有动物",
        pickup_all_desc = "一次拾取所有动物",
        auto_exchange_dna = "自动兑换DNA",
        auto_exchange_dna_desc = "自动兑换DNA点数",

        -- Selections
        select_items = "选择物品",
        select_animals = "选择动物",
        select_animals_feed = "选择要喂养的动物",
        select_animals_sell = "选择要出售的动物",
        select_animals_place = "选择要放置的动物",
        select_animals_pickup = "选择要拾取的动物",
        select_food = "选择食物",
        select_all = "全选",
        deselect_all = "取消全选",

        -- Events
        event_desert = "沙漠活动",
        event_desert_items = "选择沙漠活动物品",
        auto_buy_event = "自动购买活动物品",
        auto_buy_event_desc = "自动购买活动物品",

        -- Auto Play
        auto_retry = "自动重试",
        auto_retry_desc = "自动重试失败的操作",
        auto_play = "自动游戏",
        auto_play_desc = "启用自动游戏",
        auto_play_modes = "自动游戏模式",
        swap_mode = "交换模式",
        swap_mode_desc = "启用动物交换模式",
        auto_swap = "自动交换动物",
        auto_swap_desc = "自动交换动物",
        range_swap = "交换范围",
        range_swap_desc = "交换范围距离",
        rebuild_caches = "重建所有缓存",
        rebuild_caches_desc = "重建所有缓存数据",
        caches_rebuilt = "缓存已重建",
        caches_rebuilt_desc = "所有缓存已成功重建",
        scan_interval = "扫描间隔",
        scan_interval_desc = "设置扫描间隔（秒）",
        pathfind_interval = "寻路间隔",
        pathfind_interval_desc = "设置寻路间隔（秒）",

        -- Avoidance
        avoidance_settings = "回避设置",
        avoid_distance = "回避距离",
        avoid_distance_desc = "回避障碍物的距离",

        -- Screen & GUI
        remove_gui = "移除GUI",
        remove_gui_desc = "移除所有阻挡屏幕的GUI元素",
        remove_notify = "移除通知",
        remove_notify_desc = "隐藏所有通知弹窗",
        hide_ui = "隐藏UI",
        show_ui = "显示UI",

        -- Humanoid Settings
        walkspeed = "行走速度",
        walkspeed_desc = "设置玩家行走速度",
        jumppower = "跳跃力",
        jumppower_desc = "设置玩家跳跃高度",
        god_mode = "无敌模式",
        god_mode_desc = "启用无敌",
        noclip = "穿墙",
        noclip_desc = "穿过墙壁",
        fly = "飞行",
        fly_desc = "启用飞行模式",

        -- Players
        teleport_to_player = "传送到玩家",
        spectate_player = "观察玩家",
        refresh_players = "刷新玩家列表",

        -- Server
        server_info = "服务器信息",
        server_jobid = "作业ID",
        server_maxplayers = "最大玩家数",
        server_players = "当前玩家数",
        server_ping = "延迟",
        server_fps = "帧率",
        rejoin = "重新加入服务器",
        rejoin_desc = "重新加入当前服务器",
        server_hop = "跳转服务器",
        server_hop_desc = "加入不同的服务器",

        -- Notifications
        notification_success = "成功",
        notification_error = "错误",
        notification_warning = "警告",
        notification_info = "信息",

        -- Actions
        start = "开始",
        stop = "停止",
        pause = "暂停",
        resume = "恢复",
        enable = "启用",
        disable = "禁用",
        save = "保存",
        load = "加载",
        reset = "重置",
        apply = "应用",
        cancel = "取消",
        confirm = "确认",

        -- Status
        status_active = "活动",
        status_inactive = "不活动",
        status_running = "运行中",
        status_stopped = "已停止",
        status_loading = "加载中...",
        status_success = "成功",
        status_failed = "失败",

        -- Common
        enabled = "已启用",
        disabled = "已禁用",
        on = "开",
        off = "关",
        yes = "是",
        no = "否",
        ok = "确定",
        close = "关闭",

        -- Numbers & Units
        count = "{count}",
        amount = "数量: {amount}",
        total = "总计: {total}",
        seconds = "秒",
        minutes = "分钟",
        hours = "小时",

        -- Errors & Warnings
        error_not_found = "未找到",
        error_failed = "操作失败",
        error_invalid = "无效输入",
        warning_confirm = "你确定吗？",
        warning_irreversible = "此操作无法撤销！",

        -- Misc
        credits = "由ATG团队创建",
        version = "版本 {version}",
        discord = "加入Discord",
        update_available = "有可用更新",
        latest_version = "您已使用最新版本",
    },
}

-- ═══════════════════════════════════════════════════════════════
-- LANGUAGE SYSTEM CLASS
-- ═══════════════════════════════════════════════════════════════

local LanguageSystem = {}
LanguageSystem.__index = LanguageSystem

-- Current Language
local CurrentLanguage = "EN"

-- Initialize
function LanguageSystem:Init()
    print("[ATG Language] Multi-Language System Initialized (All-in-One)")
    print("[ATG Language] Available Languages: EN, TH, JP, CN")
end

-- Get Translation
function LanguageSystem:Get(key, replacements)
    local translation = TranslationDB[CurrentLanguage]

    -- Fallback to English if language not found
    if not translation then
        translation = TranslationDB["EN"]
    end

    -- Return key if translation not found
    if not translation or not translation[key] then
        warn("[ATG Language] Translation key not found: " .. tostring(key))
        return key
    end

    local text = translation[key]

    -- Variable replacement
    if replacements and type(replacements) == "table" then
        for k, v in pairs(replacements) do
            text = text:gsub("{" .. k .. "}", tostring(v))
        end
    end

    return text
end

-- Shortcut for Get
function LanguageSystem:T(key, replacements)
    return self:Get(key, replacements)
end

-- Set Language
function LanguageSystem:SetLanguage(langCode)
    langCode = langCode:upper()

    if TranslationDB[langCode] then
        CurrentLanguage = langCode
        print("[ATG Language] Language changed to: " .. langCode)
        return true
    else
        warn("[ATG Language] Language not available: " .. langCode)
        return false
    end
end

-- Get Current Language
function LanguageSystem:GetCurrentLanguage()
    return CurrentLanguage
end

-- Get Current Language Name
function LanguageSystem:GetCurrentLanguageName()
    local names = {
        EN = "English",
        TH = "ไทย",
        JP = "日本語",
        CN = "简体中文"
    }
    return names[CurrentLanguage] or CurrentLanguage
end

-- Get Available Languages
function LanguageSystem:GetAvailableLanguages()
    local langs = {}
    for lang, _ in pairs(TranslationDB) do
        table.insert(langs, lang)
    end
    table.sort(langs)
    return langs
end

-- Get Available Languages with Names
function LanguageSystem:GetAvailableLanguagesWithNames()
    local langs = {}
    local names = {
        EN = "English",
        TH = "ไทย (Thai)",
        JP = "日本語 (Japanese)",
        CN = "简体中文 (Chinese)"
    }

    for lang, _ in pairs(TranslationDB) do
        table.insert(langs, {
            code = lang,
            name = names[lang] or lang
        })
    end

    table.sort(langs, function(a, b) return a.code < b.code end)
    return langs
end

-- Check if Language Available
function LanguageSystem:IsLanguageAvailable(langCode)
    return TranslationDB[langCode:upper()] ~= nil
end

-- Auto-detect Language from Player Locale
function LanguageSystem:AutoDetectLanguage()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    if LocalPlayer then
        local locale = LocalPlayer.LocaleId or ""

        -- Map locale to language code
        if locale:find("th") then
            return "TH"
        elseif locale:find("ja") then
            return "JP"
        elseif locale:find("zh") then
            return "CN"
        else
            return "EN"
        end
    end

    return "EN"
end

-- Load Custom Language (for extending)
function LanguageSystem:LoadLanguage(langCode, translationTable)
    langCode = langCode:upper()
    TranslationDB[langCode] = translationTable
    print("[ATG Language] Custom language loaded: " .. langCode)
end

-- Get Raw Translations (for debugging)
function LanguageSystem:GetRawTranslations()
    return TranslationDB
end

-- ═══════════════════════════════════════════════════════════════
-- CREATE AND EXPORT INSTANCE
-- ═══════════════════════════════════════════════════════════════

local Lang = setmetatable({}, LanguageSystem)
Lang:Init()

-- Export
return Lang
