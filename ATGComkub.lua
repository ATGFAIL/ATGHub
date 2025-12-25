local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local allowedToRun = true

local allowedPlaces = {
    [127742093697776] = {
        name = "Plants-Vs-Brainrots",
        url = "https://api.luarmor.net/files/v3/loaders/059cb863ce855658c5a1b050dab6fbaf.lua"
    },
    [96114180925459] = {
        name = "Lasso-Animals",
        url = "https://api.luarmor.net/files/v3/loaders/49ef22e94528a49b6f1f7b0de2a98367.lua"
    },
    [135880624242201] = {name = "Cut-Tree", url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/cut-tree.lua"},
    [126509999114328] = {
        name = "99 Nights in the Forest",
        url = "https://api.luarmor.net/files/v3/loaders/3be199e8307561dc3cfb7855a31269dd.lua"
    },
    [79546208627805] = {
        name = "99 Nights in the Forest",
        url = "https://api.luarmor.net/files/v3/loaders/3be199e8307561dc3cfb7855a31269dd.lua"
    },
    [102181577519757] = {
        name = "DARK-DECEPTION-HUNTED",
        url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Dark-Deception-Hunted.lua"
    },
    [136431686349723] = {
        name = "DARK-DECEPTION-HUNTED",
        url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Dark-Deception-Hunted.lua"
    },
    [125591428878906] = {
        name = "DARK-DECEPTION-HUNTED",
        url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Dark-Deception-Hunted.lua"
    },
    [142823291] = {
        name = "Murder-Mystery-2",
        url = "https://api.luarmor.net/files/v3/loaders/d48b61ec237a114790c3a9346aa4bedf.lua"
    },
    [126884695634066] = {
        name = "Grow-a-Garden",
        url = "https://api.luarmor.net/files/v3/loaders/30c274d8989e8c01a8c8fa3511756d0b.lua"
    },
    [124977557560410] = {
        name = "Grow-a-Garden",
        url = "https://api.luarmor.net/files/v3/loaders/30c274d8989e8c01a8c8fa3511756d0b.lua"
    },
    [122826953758426] = {
        name = "Raise-Animals",
        url = "https://api.luarmor.net/files/v3/loaders/749053cd4c06e8101e5a1c37b05cda9a.lua"
    },
    [115317601829407] = {
        name = "Arise-Shadow-Hunt",
        url = "https://api.luarmor.net/files/v3/loaders/595828b9a7e9744b44904048c7337210.lua"
    },
    [93978595733734] = {
        name = "Violence-District",
        url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Violence-District.lua"
    },
    [118915549367482] = {
        name = "Dont-Wake-the-Brainrots",
        url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Dont-Wake-the-Brainrots.lua"
    },
    [10449761463] = {
        name = "The-Strongest-Battlegrounds",
        url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/The-Strongest-Battlegrounds.lua"
    },
    [105555311806207] = {
        name = "Build-a-Zoo",
        url = "https://api.luarmor.net/files/v3/loaders/046e27953e3d66c75a22c19370a9e02e.lua"
    },
    [90462358603255] = {
        name = "Anime-Eternal",
        url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Anime-Eternal.lua"
    },
    [12886143095] = {
        name = "Anime-Last-Stand",
        url = "https://api.luarmor.net/files/v3/loaders/a2108d6f9fdbf65098abbe425cb91150.lua"
    },
    [12900046592] = {
        name = "Anime-Last-Stand",
        url = "https://api.luarmor.net/files/v3/loaders/a2108d6f9fdbf65098abbe425cb91150.lua"
    },
    [18583778121] = {
        name = "Anime-Last-Stand",
        url = "https://api.luarmor.net/files/v3/loaders/a2108d6f9fdbf65098abbe425cb91150.lua"
    },
    [75812907038499] = {
        name = "Arise-Crossover",
        url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Arise-Crossover.lua"
    },
    [87039211657390] = {
        name = "Arise-Crossover",
        url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Arise-Crossover.lua"
    },
    [128336380114944] = {
        name = "Arise-Crossover",
        url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Arise-Crossover.lua"
    },
    [76558904092080] = {
        name = "The-Forge",
        url = "https://api.luarmor.net/files/v3/loaders/50cacceee6d476bea417de597cdb8f55.lua"
    },
    [129009554587176] = {
        name = "The-Forge",
        url = "https://api.luarmor.net/files/v3/loaders/50cacceee6d476bea417de597cdb8f55.lua"
    },
    [131884594917121] = {
        name = "The-Forge",
        url = "https://api.luarmor.net/files/v3/loaders/50cacceee6d476bea417de597cdb8f55.lua"
    },
    [2753915549] = {
        name = "Blox-Fruits",
        url = "https://api.luarmor.net/files/v3/loaders/45845b7f2bd89b59bb530d8c4e185ddc.lua"
    },
    [4442272183] = {
        name = "Blox-Fruits",
        url = "https://api.luarmor.net/files/v3/loaders/45845b7f2bd89b59bb530d8c4e185ddc.lua"
    },
    [7449423635] = {
        name = "Blox-Fruits",
        url = "https://api.luarmor.net/files/v3/loaders/45845b7f2bd89b59bb530d8c4e185ddc.lua"
    },
    [100744519298647] = {
        name = "Anime-Final-Quest",
        url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Anime-Final-Quest.lua"
    },
    [136683944064056] = {
        name = "Anime-Final-Quest",
        url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Anime-Final-Quest.lua"
    },
    [127707120843339] = {
        name = "Math-Murder",
        url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Math-Murder.lua"
    },
    [103754275310547] = {
        name = "Hunty-Zombie",
        url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Hunty-Zombie.lua"
    },
    [86076978383613] = {
        name = "Hunty-Zombie",
        url = "https://raw.githubusercontent.com/ATGFAIL/ATGHub/main/Hunty-Zombie.lua"
    },
}

local function logInfo(...)
    print("🟩 [Loader]", ...)
end

local function logWarn(...)
    warn("🟨 [Loader]", ...)
end

local function logError(...)
    warn("🛑 [Loader]", ...)
end

local function isValidLuaUrl(url)
    if type(url) ~= "string" then
        return false
    end

    if not url:match("^https?://") then
        return false
    end
    if not url:lower():match("%.lua$") then
        return false
    end
    return true
end

local placeConfig = allowedPlaces[game.PlaceId]
if not placeConfig then
    game.Players.LocalPlayer:Kick("[ ATG ] NOT SUPPORT")
    return
end

logInfo(("Script loaded for PlaceId %s (%s)"):format(tostring(game.PlaceId), tostring(placeConfig.name)))

if not HttpService.HttpEnabled then
    logError("HttpService.HttpEnabled = false. ไม่สามารถโหลดสคริปต์จาก URL ได้.")
end

local function fetchScript(url)
    local ok, result =
        pcall(
        function()
            return game:HttpGet(url, true)
        end
    )
    return ok, result
end

local function loadExtraScript(url, options)
    options = options or {}
    local retries = options.retries or 3
    local retryDelay = options.retryDelay or 1

    if not isValidLuaUrl(url) then
        return false, "Invalid URL (must be http(s) and end with .lua)"
    end

    for attempt = 1, retries do
        local ok, res = fetchScript(url)
        if ok and type(res) == "string" and #res > 0 then
            local execOk, execRes =
                pcall(
                function()
                    local f, loadErr = loadstring(res)
                    if not f then
                        error(("loadstring error: %s"):format(tostring(loadErr)))
                    end
                    return f()
                end
            )

            if execOk then
                return true, execRes
            else
                -- execution failed
                logWarn(("Attempt %d: failed to execute script from %s -> %s"):format(attempt, url, tostring(execRes)))
            end
        else
            logWarn(("Attempt %d: failed to fetch %s -> %s"):format(attempt, url, tostring(res)))
        end

        if attempt < retries then
            wait(retryDelay)
        end
    end

    return false, ("All %d attempts failed for %s"):format(retries, url)
end

coroutine.wrap(
    function()
        logInfo("เริ่มโหลดสคริปต์สำหรับแมพ:", placeConfig.name, placeConfig.url)
        local ok, result = loadExtraScript(placeConfig.url, {retries = 3, retryDelay = 1})

        if ok then
            logInfo("✅ Extra script loaded successfully for", placeConfig.name)
        else
            logError("❌ ไม่สามารถโหลดสคริปต์เพิ่มเติมได้:", result)
        end
    end
)()
