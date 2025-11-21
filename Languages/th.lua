--[[
    Thai Language Pack for ATG Hub
    Language Code: TH
    Version: 1.0.0
]]

return {
    -- ==================== WINDOW & GENERAL ====================
    window_title = "ATG HUB พรีเมียม",
    window_subtitle = "[ เลี้ยงสัตว์ ]",

    language = "ภาษา",
    language_name = "ไทย",
    language_changed = "เปลี่ยนภาษาแล้ว",
    language_changed_desc = "UI จะรีโหลดเพื่อใช้ภาษาใหม่",

    -- ==================== TABS ====================
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

    -- ==================== PLAYER INFO ====================
    player_info = "ข้อมูลผู้เล่น",
    player_name = "ชื่อ",
    player_displayname = "ชื่อที่แสดง",
    player_userid = "รหัสผู้ใช้",
    player_health = "พลังชีวิต",
    player_speed = "ความเร็ว",
    player_jump = "พลังกระโดด",
    player_position = "ตำแหน่ง",

    -- ==================== MAIN TAB - AUTO FEATURES ====================
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

    -- ==================== SELECTION ====================
    select_items = "เลือกไอเทม",
    select_animals = "เลือกสัตว์",
    select_animals_feed = "เลือกสัตว์ที่จะให้อาหาร",
    select_animals_sell = "เลือกสัตว์ที่จะขาย",
    select_animals_place = "เลือกสัตว์ที่จะวาง",
    select_animals_pickup = "เลือกสัตว์ที่จะเก็บ",
    select_food = "เลือกอาหาร",
    select_all = "เลือกทั้งหมด",
    deselect_all = "ยกเลิกการเลือกทั้งหมด",

    -- ==================== EVENTS ====================
    event_desert = "อีเว้นท์ทะเลทราย",
    event_desert_items = "เลือกไอเทม Desert Event",
    auto_buy_event = "ซื้อไอเทมอีเว้นท์อัตโนมัติ",
    auto_buy_event_desc = "ซื้อไอเทมอีเว้นท์แบบอัตโนมัติ",

    -- ==================== AUTO PLAY ====================
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

    -- ==================== AVOIDANCE SETTINGS ====================
    avoidance_settings = "การตั้งค่าการหลบหลีก",
    avoid_distance = "ระยะหลบหลีก",
    avoid_distance_desc = "ระยะทางในการหลบหลีกสิ่งกีดขวาง",

    -- ==================== SCREEN & GUI ====================
    remove_gui = "ลบ GUI",
    remove_gui_desc = "ลบ GUI ทั้งหมดที่บังหน้าจอ",
    remove_notify = "ลบการแจ้งเตือน",
    remove_notify_desc = "ซ่อนการแจ้งเตือนทั้งหมด",
    hide_ui = "ซ่อน UI",
    show_ui = "แสดง UI",

    -- ==================== HUMANOID SETTINGS ====================
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

    -- ==================== PLAYERS TAB ====================
    teleport_to_player = "วาปไปหาผู้เล่น",
    spectate_player = "ดูผู้เล่น",
    refresh_players = "รีเฟรชรายชื่อผู้เล่น",

    -- ==================== SERVER TAB ====================
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

    -- ==================== NOTIFICATIONS ====================
    notification_success = "สำเร็จ",
    notification_error = "ข้อผิดพลาด",
    notification_warning = "คำเตือน",
    notification_info = "ข้อมูล",

    -- ==================== ACTIONS ====================
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

    -- ==================== STATUS ====================
    status_active = "ทำงานอยู่",
    status_inactive = "ไม่ทำงาน",
    status_running = "กำลังทำงาน",
    status_stopped = "หยุดแล้ว",
    status_loading = "กำลังโหลด...",
    status_success = "สำเร็จ",
    status_failed = "ล้มเหลว",

    -- ==================== COMMON ====================
    enabled = "เปิดใช้งาน",
    disabled = "ปิดใช้งาน",
    on = "เปิด",
    off = "ปิด",
    yes = "ใช่",
    no = "ไม่",
    ok = "ตกลง",
    close = "ปิด",

    -- ==================== NUMBERS & UNITS ====================
    count = "{count}",
    amount = "จำนวน: {amount}",
    total = "ทั้งหมด: {total}",
    seconds = "วินาที",
    minutes = "นาที",
    hours = "ชั่วโมง",

    -- ==================== ERRORS & WARNINGS ====================
    error_not_found = "ไม่พบ",
    error_failed = "การดำเนินการล้มเหลว",
    error_invalid = "ข้อมูลไม่ถูกต้อง",
    warning_confirm = "คุณแน่ใจหรือไม่?",
    warning_irreversible = "การกระทำนี้ไม่สามารถย้อนกลับได้!",

    -- ==================== MISC ====================
    credits = "สร้างโดย ATG Team",
    version = "เวอร์ชัน {version}",
    discord = "เข้าร่วม Discord",
    update_available = "มีอัปเดตใหม่",
    latest_version = "คุณใช้เวอร์ชันล่าสุดอยู่แล้ว",
}
