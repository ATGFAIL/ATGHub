--[[
    Japanese Language Pack for ATG Hub
    Language Code: JP
    Version: 1.0.0
]]

return {
    -- ==================== WINDOW & GENERAL ====================
    window_title = "ATG HUB プレミアム",
    window_subtitle = "[ 動物を育てる ]",

    language = "言語",
    language_name = "日本語",
    language_changed = "言語を変更しました",
    language_changed_desc = "UIは新しい言語を適用するために再読み込みされます",

    -- ==================== TABS ====================
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

    -- ==================== PLAYER INFO ====================
    player_info = "プレイヤー情報",
    player_name = "名前",
    player_displayname = "表示名",
    player_userid = "ユーザーID",
    player_health = "体力",
    player_speed = "速度",
    player_jump = "ジャンプ力",
    player_position = "位置",

    -- ==================== MAIN TAB - AUTO FEATURES ====================
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

    -- ==================== SELECTION ====================
    select_items = "アイテムを選択",
    select_animals = "動物を選択",
    select_animals_feed = "餌を与える動物を選択",
    select_animals_sell = "販売する動物を選択",
    select_animals_place = "配置する動物を選択",
    select_animals_pickup = "ピックアップする動物を選択",
    select_food = "餌を選択",
    select_all = "すべて選択",
    deselect_all = "すべての選択を解除",

    -- ==================== EVENTS ====================
    event_desert = "砂漠イベント",
    event_desert_items = "砂漠イベントアイテムを選択",
    auto_buy_event = "イベントアイテム自動購入",
    auto_buy_event_desc = "イベントアイテムを自動的に購入します",

    -- ==================== AUTO PLAY ====================
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

    -- ==================== AVOIDANCE SETTINGS ====================
    avoidance_settings = "回避設定",
    avoid_distance = "回避距離",
    avoid_distance_desc = "障害物を回避する距離",

    -- ==================== SCREEN & GUI ====================
    remove_gui = "GUIを削除",
    remove_gui_desc = "画面をブロックするすべてのGUI要素を削除します",
    remove_notify = "通知を削除",
    remove_notify_desc = "すべての通知ポップアップを非表示にします",
    hide_ui = "UIを非表示",
    show_ui = "UIを表示",

    -- ==================== HUMANOID SETTINGS ====================
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

    -- ==================== PLAYERS TAB ====================
    teleport_to_player = "プレイヤーにテレポート",
    spectate_player = "プレイヤーを観戦",
    refresh_players = "プレイヤーリストを更新",

    -- ==================== SERVER TAB ====================
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

    -- ==================== NOTIFICATIONS ====================
    notification_success = "成功",
    notification_error = "エラー",
    notification_warning = "警告",
    notification_info = "情報",

    -- ==================== ACTIONS ====================
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

    -- ==================== STATUS ====================
    status_active = "アクティブ",
    status_inactive = "非アクティブ",
    status_running = "実行中",
    status_stopped = "停止中",
    status_loading = "読み込み中...",
    status_success = "成功",
    status_failed = "失敗",

    -- ==================== COMMON ====================
    enabled = "有効",
    disabled = "無効",
    on = "オン",
    off = "オフ",
    yes = "はい",
    no = "いいえ",
    ok = "OK",
    close = "閉じる",

    -- ==================== NUMBERS & UNITS ====================
    count = "{count}",
    amount = "数量: {amount}",
    total = "合計: {total}",
    seconds = "秒",
    minutes = "分",
    hours = "時間",

    -- ==================== ERRORS & WARNINGS ====================
    error_not_found = "見つかりません",
    error_failed = "操作に失敗しました",
    error_invalid = "無効な入力",
    warning_confirm = "よろしいですか？",
    warning_irreversible = "この操作は元に戻せません！",

    -- ==================== MISC ====================
    credits = "ATG Teamによって作成",
    version = "バージョン {version}",
    discord = "Discordに参加",
    update_available = "アップデート利用可能",
    latest_version = "最新バージョンをお使いです",
}
