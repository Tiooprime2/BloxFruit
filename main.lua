--[[
    TiooHub V2.1 — Global Loader (Legacy Engine)
    Author : Ridho (Head of Cyber Team)
]]

local RAW = "https://raw.githubusercontent.com/Tiooprime2/BloxFruit/refs/heads/main/"

print("[TiooHub] Memulai Inisialisasi UI...")

-- 1. Load UI (Wajib Berhasil)
local UI_Success, UI_Module = pcall(function()
    return loadstring(game:HttpGet(RAW .. "UI.lua"))()
end)

if not UI_Success then
    warn("[TiooHub] ERROR KRITIKAL: UI gagal dimuat! | " .. tostring(UI_Module))
    return
end

-- 2. Fungsi Aman untuk Load Fitur
local function SafeLoad(name)
    task.spawn(function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet(RAW .. name))()
        end)
        if ok then
            print("[TiooHub] Fitur Aktif: " .. name)
        else
            warn("[TiooHub] Gagal memuat fitur: " .. name .. " | " .. tostring(err))
        end
    end)
end

-- 3. Eksekusi Fitur (Satu Per Satu)
SafeLoad("Escape.lua")
SafeLoad("HighGravJump.lua")
SafeLoad("CombatTuning.lua")
SafeLoad("MovementScaler.lua")

print("[TiooHub] System V2.1 Berjalan!")
