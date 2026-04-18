--[[
    GNG Fail-safe v2 — Main Loader
    Author  : Ridho (Head of Cyber Team)
    GitHub  : https://github.com/Tiooprime2/BloxFruit

    HOW TO USE:
      Paste this script into your Roblox executor.
      It will auto-fetch UI.lua and Escape.lua from GitHub.
]]

local GITHUB_RAW = "https://raw.githubusercontent.com/Tiooprime2/BloxFruit/main/"

local FILES = {
    "UI.lua",
    "Escape.lua",
}

-- ════════════════════════════════════════════
--  LOADER
-- ════════════════════════════════════════════
local function fetchAndLoad(filename)
    local url = GITHUB_RAW .. filename
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or not result or result == "" then
        warn("[GNG] Failed to fetch: " .. filename)
        warn("[GNG] Error: " .. tostring(result))
        return false
    end

    local fn, err = loadstring(result)
    if not fn then
        warn("[GNG] Failed to compile: " .. filename)
        warn("[GNG] Error: " .. tostring(err))
        return false
    end

    local runOk, runErr = pcall(fn)
    if not runOk then
        warn("[GNG] Runtime error in: " .. filename)
        warn("[GNG] Error: " .. tostring(runErr))
        return false
    end

    print("[GNG] Loaded: " .. filename)
    return true
end

-- ════════════════════════════════════════════
--  MAIN
-- ════════════════════════════════════════════
print("[GNG] Starting loader...")
print("[GNG] Source: " .. GITHUB_RAW)

local allOk = true
for _, file in ipairs(FILES) do
    local success = fetchAndLoad(file)
    if not success then
        allOk = false
    end
end

if allOk then
    print("[GNG] All modules loaded successfully.")
else
    warn("[GNG] One or more modules failed to load. Check output above.")
end
