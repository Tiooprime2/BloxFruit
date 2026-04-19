--[[
    TiooHub — CombatTuning v2 (Auto-Detection + Stacking Multiplier)
    Author : Ridho (Head of Cyber Team)
]]

local Players = game:GetService("Players")
local RunSvc  = game:GetService("RunService")

local player  = Players.LocalPlayer

local CONFIG = {
    SPEED_MULTIPLIER = 1.05,
    POLL_INTERVAL    = 0.2,
    BASELINE_CD      = 0.5,
}

local CHAR_KEYS = { "M1_Delay", "AttackSpeed", "M1Cooldown", "AttackCooldown" }
local TOOL_KEYS = { "Cooldown", "SwingDelay", "M1Cooldown", "AttackDelay"    }

local _conn = nil
local CombatTuning = {}

local function detectCooldown(hum, character)
    for _, key in ipairs(CHAR_KEYS) do
        local val = hum:GetAttribute(key) or character:GetAttribute(key)
        if val and type(val) == "number" and val > 0 then
            return val, "CharAttr:" .. key
        end
    end

    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        for _, key in ipairs(TOOL_KEYS) do
            local val = tool:GetAttribute(key)
            if val and type(val) == "number" and val > 0 then
                return val, "ToolAttr:" .. key
            end
        end
        for _, child in ipairs(tool:GetChildren()) do
            for _, key in ipairs(TOOL_KEYS) do
                local val = child:GetAttribute(key)
                if val and type(val) == "number" and val > 0 then
                    return val, "ToolChild:" .. key
                end
            end
        end
    end

    return CONFIG.BASELINE_CD, "Baseline"
end

local function writeBack(character, hum, newVal)
    for _, key in ipairs(CHAR_KEYS) do
        if hum:GetAttribute(key) then hum:SetAttribute(key, newVal) end
        if character:GetAttribute(key) then character:SetAttribute(key, newVal) end
    end

    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        for _, key in ipairs(TOOL_KEYS) do
            if tool:GetAttribute(key) then tool:SetAttribute(key, newVal) end
        end
    end
end

local function applyMultiplier(hum, character)
    local current, source = detectCooldown(hum, character)
    local newCooldown     = current / CONFIG.SPEED_MULTIPLIER
    writeBack(character, hum, newCooldown)
    return current, newCooldown, source
end

local function startPolling(hum, character)
    if _conn then _conn:Disconnect() end

    local elapsed = 0
    local logged  = false

    _conn = RunSvc.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed < CONFIG.POLL_INTERVAL then return end
        elapsed = 0

        if not (hum and hum.Parent) then
            _conn:Disconnect()
            _conn = nil
            return
        end

        local before, after, src = applyMultiplier(hum, character)

        if not logged and src ~= "Baseline" then
            print(string.format(
                "[TiooHub] CombatTuning — Source: %s | %.4f → %.4f (x%.2f)",
                src, before, after, CONFIG.SPEED_MULTIPLIER
            ))
            logged = true
        end
    end)
end

function CombatTuning.start(character)
    local hum = character:WaitForChild("Humanoid")
    startPolling(hum, character)
    print(string.format("[TiooHub] CombatTuning v2 ON — Multiplier x%.2f", CONFIG.SPEED_MULTIPLIER))
end

function CombatTuning.stop()
    if _conn then _conn:Disconnect(); _conn = nil end
    print("[TiooHub] CombatTuning OFF")
end

function CombatTuning.setMultiplier(val)
    CONFIG.SPEED_MULTIPLIER = val
    print(string.format("[TiooHub] Multiplier updated → x%.2f", val))
end

player.CharacterAdded:Connect(CombatTuning.start)
player.CharacterRemoving:Connect(CombatTuning.stop)

if player.Character then
    CombatTuning.start(player.Character)
end

return CombatTuning
