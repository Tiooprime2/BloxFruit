--[[
    GNG Fail-safe v2 — Main Loader
    Author : Ridho (Head of Cyber Team)
    GitHub : https://github.com/Tiooprime2/BloxFruit

    HOW IT WORKS:
      Fetches UI.lua then Escape.lua from GitHub raw,
      joins them into one string, runs once with loadstring.
      No require() needed — works in all executors.

    EXECUTOR ONE-LINER:
      loadstring(game:HttpGet("https://raw.githubusercontent.com/Tiooprime2/BloxFruit/main/main.lua"))()
]]

local RAW = "https://raw.githubusercontent.com/Tiooprime2/BloxFruit/main/"

-- Order matters: UI must come before Escape
local FILES = {
    "UI.lua",
    "Escape.lua",
  --  "Jump.lua",
    "HighGravJump.lua",
    "CombatTuning.lua",
}

-- ════════════════════════════════════════════
--  FETCH EACH FILE
-- ════════════════════════════════════════════
local combined = ""

for _, filename in ipairs(FILES) do
    local url = RAW .. filename
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok or not result or result == "" then
        warn("[GNG] FAILED to fetch: " .. filename)
        warn("[GNG] " .. tostring(result))
        return  -- stop loader if any file fails
    end

    print("[GNG] Fetched: " .. filename)
    combined = combined .. "\n" .. result
end

-- ════════════════════════════════════════════
--  RUN ALL AT ONCE
-- ════════════════════════════════════════════
local fn, compileErr = loadstring(combined)

if not fn then
    warn("[GNG] Compile error: " .. tostring(compileErr))
    return
end

local ok, runErr = pcall(fn)

if not ok then
    warn("[GNG] Runtime error: " .. tostring(runErr))
    return
end

print("[GNG] All modules loaded successfully.")
