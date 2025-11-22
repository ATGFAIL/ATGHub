-- ============================================================
-- ATG HUB - Multi-Language System
-- Centralized Language Data & Management
-- Enhanced with full Unicode support, date/number formatting, and error handling
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
            main_instructions_title = "Instructions",
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
            main_instructions_title = "คำแนะนำ",
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
            main_instructions_title = "说明",
            main_instructions = "这是 Fluent UI 用法示例\n您可以根据需要自定义\n感谢使用 ATG HUB！",
        },
    },

    -- Japanese Language (日本語)
    ja = {
        code = "ja",
        name = "日本語",
        flag = "🇯🇵",

        -- Common UI Elements
        common = {
            loading = "読み込み中...",
            success = "成功",
            error = "エラー",
            warning = "警告",
            confirm = "確認",
            cancel = "キャンセル",
            ok = "OK",
            yes = "はい",
            no = "いいえ",
            close = "閉じる",
            save = "保存",
            delete = "削除",
            refresh = "更新",
            reset = "リセット",
            enable = "有効",
            disable = "無効",
            start = "開始",
            stop = "停止",
            pause = "一時停止",
            resume = "再開",
        },

        -- Main Tab
        main = {
            title = "メイン",
            player_info = "プレイヤー情報",
            name = "名前",
            date = "日付",
            played_time = "プレイ時間",
            auto_claim = "自動取得",
            auto_upgrade = "自動アップグレード",
            auto_equip = "自動装備",
            basic_features = "基本機能",
            test_notification = "🔔 テスト通知",
            confirmation_dialog = "❓ 確認ダイアログ",
        },

        -- Farm Tab
        farm = {
            title = "ファーム",
            auto_farm = "オートファーム",
            fast_attack = "高速攻撃",
            kill_aura = "キルオーラ",
            auto_collect = "自動収集",
            radius = "範囲",
            select_enemy = "敵を選択",
            select_target = "ターゲットを選択",
            weapons_abilities = "武器と能力",
            controls = "コントロール",
            select_weapon = "🗡️ 武器を選択",
            special_abilities = "✨ 特殊能力",
            attack_button = "⚡ 攻撃ボタン",
        },

        -- Settings Tab
        settings = {
            title = "設定",
            language = "言語",
            select_language = "言語を選択",
            theme = "テーマ",
            anti_afk = "アンチAFK",
            auto_rejoin = "自動再参加",
            save_config = "設定を保存",
            load_config = "設定を読み込み",
        },

        -- Server Tab
        server = {
            title = "サーバー",
            server_hop = "サーバーホップ",
            rejoin = "再参加",
            lower_server = "低人数サーバー",
            job_id = "ジョブID",
            input_job_id = "ジョブIDを入力",
            teleport_to_job = "ジョブにテレポート",
            copy_job_id = "現在のジョブIDをコピー",
        },

        -- Teleport Tab
        teleport = {
            title = "テレポート",
        },

        -- Players Tab
        players = {
            title = "プレイヤー",
            movement = "移動",
            player_info = "プレイヤー情報",
            speed_boost = "🏃 速度ブースト",
            jump_power = "🦘 ジャンプ力",
            player_name = "📝 プレイヤー名",
        },

        -- Humanoid Tab
        humanoid = {
            title = "キャラクター",
            walk_speed = "移動速度",
            jump_power = "ジャンプ力",
            fly = "飛行",
            noclip = "ノークリップ",
            fly_speed = "飛行速度",
            enable_walk = "速度を有効化",
            enable_jump = "ジャンプを有効化",
            reset_defaults = "デフォルトに戻す",
        },

        -- Notifications
        notifications = {
            script_loaded = "スクリプトが正常に読み込まれました！",
            feature_enabled = "機能が有効化されました",
            feature_disabled = "機能が無効化されました",
            no_target = "ターゲットが見つかりません",
            teleport_success = "テレポート成功",
            teleport_failed = "テレポート失敗",
            invalid_input = "無効な入力",
            please_wait = "お待ちください...",
            welcome = "ようこそ！",
            press_left_ctrl = "Left CtrlキーでUIを開閉",
            success = "成功！",
            button_pressed = "ボタンが押されました",
            confirm_action = "アクションを確認",
            want_to_continue = "続行しますか？",
            confirm = "✅ 確認",
            cancel = "❌ キャンセル",
            confirmed = "確認済み",
            action_completed = "アクション完了",
            enabled = "有効化",
            speed_set_50 = "速度を50に設定",
            disabled = "無効化",
            speed_reset = "速度を通常に戻す",
            weapon_switched = "武器が切り替わりました",
            using_weapon = "使用中: ",
            attack = "攻撃！",
            skill_used = "スキルが使用されました",
            loading = "読み込み中...",
            saved = "保存済み",
            your_name_is = "あなたの名前は: ",
        },

        -- Descriptions
        descriptions = {
            auto_farm_desc = "敵を自動でファーム",
            fast_attack_desc = "攻撃を高速化",
            kill_aura_desc = "周囲の敵を倒す",
            fly_desc = "飛行を有効化",
            noclip_desc = "壁を通り抜ける",
            anti_afk_desc = "AFKキックを防止",
            server_hop_desc = "ランダムサーバーに参加",
            test_notification_desc = "クリックして通知を表示",
            confirmation_dialog_desc = "選択ボタン付きダイアログを表示",
            speed_boost_desc = "より速く歩く",
            jump_power_desc = "ジャンプの高さを調整",
            select_weapon_desc = "使用する武器を選択",
            special_abilities_desc = "複数選択可能",
            player_name_desc = "名前を入力してください...",
            attack_button_desc = "攻撃ボタンを押す",
        },

        -- Instructions and paragraphs
        instructions = {
            main_instructions_title = "説明",
            main_instructions = "これはFluent UIの使用例です\n必要に応じてカスタマイズできます\nATG HUBをご利用いただきありがとうございます！",
        },
    },

    -- Korean Language (한국어)
    ko = {
        code = "ko",
        name = "한국어",
        flag = "🇰🇷",

        -- Common UI Elements
        common = {
            loading = "로딩 중...",
            success = "성공",
            error = "오류",
            warning = "경고",
            confirm = "확인",
            cancel = "취소",
            ok = "확인",
            yes = "예",
            no = "아니오",
            close = "닫기",
            save = "저장",
            delete = "삭제",
            refresh = "새로고침",
            reset = "초기화",
            enable = "활성화",
            disable = "비활성화",
            start = "시작",
            stop = "중지",
            pause = "일시정지",
            resume = "재개",
        },

        -- Main Tab
        main = {
            title = "메인",
            player_info = "플레이어 정보",
            name = "이름",
            date = "날짜",
            played_time = "플레이 시간",
            auto_claim = "자동 획득",
            auto_upgrade = "자동 업그레이드",
            auto_equip = "자동 장착",
            basic_features = "기본 기능",
            test_notification = "🔔 테스트 알림",
            confirmation_dialog = "❓ 확인 대화상자",
        },

        -- Farm Tab
        farm = {
            title = "팜",
            auto_farm = "오토팜",
            fast_attack = "빠른 공격",
            kill_aura = "킬 오라",
            auto_collect = "자동 수집",
            radius = "반경",
            select_enemy = "적 선택",
            select_target = "타겟 선택",
            weapons_abilities = "무기와 능력",
            controls = "컨트롤",
            select_weapon = "🗡️ 무기 선택",
            special_abilities = "✨ 특수 능력",
            attack_button = "⚡ 공격 버튼",
        },

        -- Settings Tab
        settings = {
            title = "설정",
            language = "언어",
            select_language = "언어 선택",
            theme = "테마",
            anti_afk = "안티 AFK",
            auto_rejoin = "자동 재참여",
            save_config = "설정 저장",
            load_config = "설정 불러오기",
        },

        -- Server Tab
        server = {
            title = "서버",
            server_hop = "서버 홉",
            rejoin = "재참여",
            lower_server = "적은 인원 서버",
            job_id = "잡 ID",
            input_job_id = "잡 ID 입력",
            teleport_to_job = "잡으로 텔레포트",
            copy_job_id = "현재 잡 ID 복사",
        },

        -- Teleport Tab
        teleport = {
            title = "텔레포트",
        },

        -- Players Tab
        players = {
            title = "플레이어",
            movement = "이동",
            player_info = "플레이어 정보",
            speed_boost = "🏃 속도 부스트",
            jump_power = "🦘 점프력",
            player_name = "📝 플레이어 이름",
        },

        -- Humanoid Tab
        humanoid = {
            title = "캐릭터",
            walk_speed = "이동 속도",
            jump_power = "점프력",
            fly = "비행",
            noclip = "노클립",
            fly_speed = "비행 속도",
            enable_walk = "속도 활성화",
            enable_jump = "점프 활성화",
            reset_defaults = "기본값으로 재설정",
        },

        -- Notifications
        notifications = {
            script_loaded = "스크립트가 성공적으로 로드되었습니다!",
            feature_enabled = "기능이 활성화되었습니다",
            feature_disabled = "기능이 비활성화되었습니다",
            no_target = "타겟을 찾을 수 없습니다",
            teleport_success = "텔레포트 성공",
            teleport_failed = "텔레포트 실패",
            invalid_input = "잘못된 입력",
            please_wait = "잠시 기다려주세요...",
            welcome = "환영합니다!",
            press_left_ctrl = "Left Ctrl로 UI 열기/닫기",
            success = "성공!",
            button_pressed = "버튼을 눌렀습니다",
            confirm_action = "액션 확인",
            want_to_continue = "계속하시겠습니까?",
            confirm = "✅ 확인",
            cancel = "❌ 취소",
            confirmed = "확인됨",
            action_completed = "액션 완료",
            enabled = "활성화됨",
            speed_set_50 = "속도를 50으로 설정",
            disabled = "비활성화됨",
            speed_reset = "속도를 정상으로 재설정",
            weapon_switched = "무기가 전환되었습니다",
            using_weapon = "사용 중: ",
            attack = "공격!",
            skill_used = "스킬이 사용되었습니다",
            loading = "로딩 중...",
            saved = "저장됨",
            your_name_is = "귀하의 이름은: ",
        },

        -- Descriptions
        descriptions = {
            auto_farm_desc = "적을 자동으로 팜",
            fast_attack_desc = "공격 속도 향상",
            kill_aura_desc = "주변 적 죽이기",
            fly_desc = "비행 활성화",
            noclip_desc = "벽 통과",
            anti_afk_desc = "AFK 킥 방지",
            server_hop_desc = "랜덤 서버 참여",
            test_notification_desc = "클릭하여 알림 표시",
            confirmation_dialog_desc = "선택 버튼이 있는 대화상자 표시",
            speed_boost_desc = "더 빨리 걷기",
            jump_power_desc = "점프 높이 조정",
            select_weapon_desc = "사용할 무기 선택",
            special_abilities_desc = "여러 개 선택 가능",
            player_name_desc = "이름을 입력하세요...",
            attack_button_desc = "공격 버튼 누르기",
        },

        -- Instructions and paragraphs
        instructions = {
            main_instructions_title = "설명",
            main_instructions = "Fluent UI 사용 예시입니다\n필요에 따라 사용자 정의할 수 있습니다\nATG HUB를 이용해 주셔서 감사합니다!",
        },
    },
}

-- ============================================================
-- ENHANCED FEATURES: Date/Number Formatting & Unicode Support
-- ============================================================

-- Unicode validation and normalization
local function validateUnicode(text)
    if not text or type(text) ~= "string" then return false end
    -- Basic Unicode validation (check for valid UTF-8)
    local success = pcall(function()
        return text:len() > 0 and utf8.len(text) ~= nil
    end)
    return success
end

local function normalizeUnicode(text)
    if not validateUnicode(text) then return text end
    -- Basic normalization (can be enhanced with proper Unicode libraries)
    return text:gsub("[\194-\244][\128-\191]*", function(c)
        return c -- Keep valid UTF-8 sequences
    end)
end

-- Date formatting for different locales
local function formatDate(locale, timestamp)
    timestamp = timestamp or os.time()
    local dateTable = os.date("*t", timestamp)

    if locale == "th" then
        -- Thai Buddhist calendar (add 543 years)
        local thaiYear = dateTable.year + 543
        return string.format("%02d/%02d/%d", dateTable.day, dateTable.month, thaiYear)
    elseif locale == "zh" then
        return string.format("%d年%02d月%02d日", dateTable.year, dateTable.month, dateTable.day)
    elseif locale == "ja" then
        return string.format("%d年%02d月%02d日", dateTable.year, dateTable.month, dateTable.day)
    elseif locale == "ko" then
        return string.format("%d년 %02d월 %02d일", dateTable.year, dateTable.month, dateTable.day)
    else -- en and others
        return string.format("%02d/%02d/%d", dateTable.month, dateTable.day, dateTable.year)
    end
end

-- Number formatting for different locales
local function formatNumber(locale, number)
    if type(number) ~= "number" then return tostring(number) end

    local str = string.format("%.2f", number)

    if locale == "th" or locale == "en" then
        -- Use comma as thousands separator, period as decimal
        return str:gsub("(%d)(%d%d%d)%.", "%1,%2.")
               :gsub("(%d)(%d%d%d),", "%1,%2,")
    elseif locale == "zh" or locale == "ja" then
        -- Chinese/Japanese: use comma for thousands, period for decimal
        return str:gsub("(%d)(%d%d%d)%.", "%1,%2.")
               :gsub("(%d)(%d%d%d),", "%1,%2,")
    elseif locale == "ko" then
        -- Korean: use comma for thousands, period for decimal
        return str:gsub("(%d)(%d%d%d)%.", "%1,%2.")
               :gsub("(%d)(%d%d%d),", "%1,%2,")
    else
        return str
    end
end

-- Time formatting
local function formatTime(locale, seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    if locale == "th" then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    elseif locale == "zh" then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    elseif locale == "ja" then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    elseif locale == "ko" then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    else -- en
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    end
end

-- ============================================================
-- CURRENT LANGUAGE STATE & ERROR HANDLING
-- ============================================================
LanguageSystem.currentLanguage = "en" -- Default language
LanguageSystem.supportedLanguages = {"en", "th", "zh", "ja", "ko"}
LanguageSystem.fallbackLanguage = "en"

-- ============================================================
-- CORE FUNCTIONS
-- ============================================================

-- Enhanced GetText with error handling and Unicode validation
function LanguageSystem:GetText(keyPath)
    -- Validate input
    if not keyPath or type(keyPath) ~= "string" then
        warn("[LanguageSystem] Invalid keyPath provided")
        return "INVALID_KEY"
    end

    -- Check if language is supported
    if not self:IsLanguageSupported(self.currentLanguage) then
        warn("[LanguageSystem] Current language '" .. self.currentLanguage .. "' is not supported, falling back to '" .. self.fallbackLanguage .. "'")
        self.currentLanguage = self.fallbackLanguage
    end

    local lang = self.Languages[self.currentLanguage]
    if not lang then
        warn("[LanguageSystem] Language data not found for '" .. self.currentLanguage .. "', using fallback")
        lang = self.Languages[self.fallbackLanguage]
        if not lang then
            return keyPath -- Ultimate fallback
        end
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
            -- Try fallback language
            local fallbackValue = self.Languages[self.fallbackLanguage]
            for _, k in ipairs(keys) do
                if type(fallbackValue) == "table" and fallbackValue[k] then
                    fallbackValue = fallbackValue[k]
                else
                    warn("[LanguageSystem] Translation key '" .. keyPath .. "' not found in any language")
                    return keyPath -- Return key path if not found anywhere
                end
            end
            value = fallbackValue
            break
        end
    end

    -- Validate Unicode and normalize if needed
    if type(value) == "string" then
        value = normalizeUnicode(value)
    end

    return value
end

-- Short alias for GetText
function LanguageSystem:T(keyPath)
    return self:GetText(keyPath)
end

-- Set current language with enhanced error handling
function LanguageSystem:SetLanguage(langCode)
    if not langCode or type(langCode) ~= "string" then
        warn("[LanguageSystem] Invalid language code provided")
        return false
    end

    -- Check if language is supported
    if not self:IsLanguageSupported(langCode) then
        warn("[LanguageSystem] Language '" .. langCode .. "' is not supported. Supported languages: " .. table.concat(self.supportedLanguages, ", "))
        return false
    end

    -- Check if language data exists
    if not self.Languages[langCode] then
        warn("[LanguageSystem] Language data not found for '" .. langCode .. "'")
        return false
    end

    local oldLanguage = self.currentLanguage
    self.currentLanguage = langCode

    -- Save to getgenv for persistence
    if getgenv then
        getgenv().ATG_Language = langCode
    end

    -- Trigger language change event
    if self.onLanguageChanged then
        pcall(function()
            self.onLanguageChanged(langCode, oldLanguage)
        end)
    end

    print("[LanguageSystem] Language changed from '" .. oldLanguage .. "' to '" .. langCode .. "'")
    return true
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

-- Check if language is supported
function LanguageSystem:IsLanguageSupported(langCode)
    for _, supported in ipairs(self.supportedLanguages) do
        if supported == langCode then
            return true
        end
    end
    return false
end

-- Add new language support (for dynamic language addition)
function LanguageSystem:AddLanguage(langCode, langData)
    if not langCode or not langData then
        warn("[LanguageSystem] Invalid language data provided")
        return false
    end

    -- Validate language data structure
    if not langData.code or not langData.name or not langData.flag then
        warn("[LanguageSystem] Language data missing required fields (code, name, flag)")
        return false
    end

    -- Validate Unicode in language data
    for sectionName, section in pairs(langData) do
        if type(section) == "table" then
            for key, value in pairs(section) do
                if type(value) == "string" and not validateUnicode(value) then
                    warn("[LanguageSystem] Invalid Unicode in language '" .. langCode .. "', section '" .. sectionName .. "', key '" .. key .. "'")
                    return false
                end
            end
        end
    end

    self.Languages[langCode] = langData
    table.insert(self.supportedLanguages, langCode)

    print("[LanguageSystem] Added new language: " .. langData.name .. " (" .. langCode .. ")")
    return true
end

-- Format date according to current language locale
function LanguageSystem:FormatDate(timestamp)
    return formatDate(self.currentLanguage, timestamp)
end

-- Format number according to current language locale
function LanguageSystem:FormatNumber(number)
    return formatNumber(self.currentLanguage, number)
end

-- Format time duration according to current language locale
function LanguageSystem:FormatTime(seconds)
    return formatTime(self.currentLanguage, seconds)
end

-- Get localized date and time string
function LanguageSystem:GetLocalizedDateTime()
    local now = os.time()
    local dateStr = self:FormatDate(now)
    local timeStr = os.date("%H:%M:%S", now)

    if self.currentLanguage == "th" then
        return dateStr .. " " .. timeStr
    elseif self.currentLanguage == "zh" then
        return dateStr .. " " .. timeStr
    elseif self.currentLanguage == "ja" then
        return dateStr .. " " .. timeStr
    elseif self.currentLanguage == "ko" then
        return dateStr .. " " .. timeStr
    else -- en
        return dateStr .. " " .. timeStr
    end
end

-- Validate and normalize text for Unicode compliance
function LanguageSystem:ValidateAndNormalizeText(text)
    if not validateUnicode(text) then
        warn("[LanguageSystem] Text contains invalid Unicode sequences")
        return text
    end
    return normalizeUnicode(text)
end

-- Get language info with error handling
function LanguageSystem:GetLanguageInfo(langCode)
    langCode = langCode or self.currentLanguage

    if not self:IsLanguageSupported(langCode) then
        warn("[LanguageSystem] Language '" .. langCode .. "' is not supported")
        return nil
    end

    local lang = self.Languages[langCode]
    if not lang then
        warn("[LanguageSystem] Language data not found for '" .. langCode .. "'")
        return nil
    end

    return {
        code = lang.code,
        name = lang.name,
        flag = lang.flag,
        display = string.format("%s %s", lang.flag, lang.name)
    }
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
