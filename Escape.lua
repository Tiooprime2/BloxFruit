--[[
    GNG Fail-safe v2 — Escape Logic Module
    Author  : Ridho (Head of Cyber Team)
    Handles : Multi-tier health thresholds, teleport, cooldown, respawn, keybind

    HOW TO USE:
      Place UI.lua and Escape.lua both inside StarterPlayerScripts.
      Escape.lua will require() UI.lua automatically.

    TIERS:
      Tier 1 — Warning  : hp <= TIER1_HP  → teleport to mid-air hold position
      Tier 2 — Critical : hp <= TIER2_HP  → teleport to maximum escape height
]]

-- ════════════════════════════════════════════
--  LOAD UI MODULE
--  Adjust path if you nest scripts in folders
-- ════════════════════════════════════════════
local UI = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("UI"))

-- ════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local player  = Players.LocalPlayer

-- ════════════════════════════════════════════
--  CONFIGURATION
--  All tunable values live here — edit freely
-- ════════════════════════════════════════════
local CONFIG = {
    -- Health thresholds (flat HP values, not %)
    TIER1_HP        = 3000,   -- Warning  : moderate danger
    TIER2_HP        = 1200,   -- Critical : severe danger

    -- Escape heights above the character's current Y position (studs)
    TIER1_HEIGHT    = 5000,   -- Mid-air hold (Tier 1)
    TIER2_HEIGHT    = 12000,  -- Maximum escape (Tier 2)

    -- Cooldown in seconds before fail-safe can re-trigger
    COOLDOWN        = 6,

    -- How long "TRIGGERED" text stays before switching to "COOLING"
    TRIGGER_DISPLAY = 2,

    -- Keybind to toggle fail-safe on/off
    TOGGLE_KEY      = Enum.KeyCode.F9,
}

-- ════════════════════════════════════════════
--  STATE
-- ════════════════════════════════════════════
local isEnabled   = true
local isCooling   = false
local connections = {}   -- all RBXScriptConnections, cleared on respawn

-- ════════════════════════════════════════════
--  COOLDOWN TICKER
--  Updates UI label every second with time left
-- ════════════════════════════════════════════
local function runCooldown()
    isCooling = true
    local remaining = CONFIG.COOLDOWN

    task.spawn(function()
        while remaining > 0 do
            task.wait(1)
            remaining -= 1
            if isEnabled then
                UI.setCooling(remaining)
            end
        end
        isCooling = false
        if isEnabled then
            UI.setActive()
        end
    end)
end

-- ════════════════════════════════════════════
--  ESCAPE HANDLER
-- ════════════════════════════════════════════
local function triggerEscape(rootPart, tier)
    -- Snapshot position at the exact moment of trigger
    local pos    = rootPart.Position
    local height = (tier == 2) and CONFIG.TIER2_HEIGHT or CONFIG.TIER1_HEIGHT
    local dest   = Vector3.new(pos.X, pos.Y + height, pos.Z)

    rootPart.CFrame = CFrame.new(dest)

    UI.setTriggered(tier)

    task.delay(CONFIG.TRIGGER_DISPLAY, function()
        if isCooling and isEnabled then
            UI.setCooling(CONFIG.COOLDOWN - CONFIG.TRIGGER_DISPLAY)
        end
    end)

    runCooldown()
end

-- ════════════════════════════════════════════
--  CONNECT HEALTH LISTENER
-- ════════════════════════════════════════════
local function connectEscape(character)
    -- Clear previous connections (respawn safety)
    for _, c in ipairs(connections) do c:Disconnect() end
    table.clear(connections)

    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    local conn = humanoid.HealthChanged:Connect(function(hp)
        if not isEnabled then return end
        if isCooling    then return end
        if hp <= 0      then return end  -- already dead, skip

        if hp <= CONFIG.TIER2_HP then
            triggerEscape(rootPart, 2)   -- Critical
        elseif hp <= CONFIG.TIER1_HP then
            triggerEscape(rootPart, 1)   -- Warning
        end
    end)

    table.insert(connections, conn)
end

-- ════════════════════════════════════════════
--  CHARACTER LIFECYCLE  (handles respawns)
-- ════════════════════════════════════════════
local function onCharacterAdded(character)
    isCooling = false        -- reset cooldown state on respawn
    UI.build()               -- rebuild UI with fresh references
    connectEscape(character)
    UI.setActive()
end

player.CharacterAdded:Connect(onCharacterAdded)

-- Handle character that's already loaded when script runs
if player.Character then
    onCharacterAdded(player.Character)
end

-- ════════════════════════════════════════════
--  TOGGLE KEYBIND
-- ════════════════════════════════════════════
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode ~= CONFIG.TOGGLE_KEY then return end

    isEnabled = not isEnabled

    if isEnabled then
        UI.setActive()
    else
        UI.setDisabled()
    end
end)

print("[GNG] Escape v2 loaded for", player.Name)
print(string.format("[GNG] Tiers → Warning: %d HP | Critical: %d HP", CONFIG.TIER1_HP, CONFIG.TIER2_HP))
