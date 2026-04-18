--[[
    GNG Fail-safe v2 — Escape Logic Module
    Author : Ridho (Head of Cyber Team)
    Note   : Loaded by main.lua AFTER UI.lua — do not run standalone
    Add new escape features / tiers here freely
]]

local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local player  = Players.LocalPlayer

-- ════════════════════════════════════════════
--  CONFIGURATION
-- ════════════════════════════════════════════
local CONFIG = {
    TIER1_HP        = 3000,   -- Warning  threshold (HP)
    TIER2_HP        = 1200,   -- Critical threshold (HP)
    TIER1_HEIGHT    = 5000,   -- Escape height Tier 1 (studs)
    TIER2_HEIGHT    = 12000,  -- Escape height Tier 2 (studs)
    COOLDOWN        = 6,      -- Seconds before re-trigger
    TOGGLE_KEY      = Enum.KeyCode.F9,
}

-- ════════════════════════════════════════════
--  STATE
-- ════════════════════════════════════════════
local isEnabled   = true
local isCooling   = false
local connections = {}

-- ════════════════════════════════════════════
--  COOLDOWN
-- ════════════════════════════════════════════
local function runCooldown()
    isCooling = true
    local remaining = CONFIG.COOLDOWN
    task.spawn(function()
        while remaining > 0 do
            task.wait(1)
            remaining -= 1
            if isEnabled then UI.setCooling(remaining) end
        end
        isCooling = false
        if isEnabled then UI.setActive() end
    end)
end

-- ════════════════════════════════════════════
--  ESCAPE
-- ════════════════════════════════════════════
local function triggerEscape(rootPart, tier)
    local pos    = rootPart.Position
    local height = (tier == 2) and CONFIG.TIER2_HEIGHT or CONFIG.TIER1_HEIGHT
    rootPart.CFrame = CFrame.new(Vector3.new(pos.X, pos.Y + height, pos.Z))
    UI.setTriggered(tier)
    runCooldown()
end

-- ════════════════════════════════════════════
--  HEALTH LISTENER
-- ════════════════════════════════════════════
local function connectEscape(character)
    for _, c in ipairs(connections) do c:Disconnect() end
    table.clear(connections)

    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    local conn = humanoid.HealthChanged:Connect(function(hp)
            UI.updateHealth(hp, humanoid.MaxHealth)
        if not isEnabled then return end
        if isCooling    then return end
        if hp <= 0      then return end

        if hp <= CONFIG.TIER2_HP then
            triggerEscape(rootPart, 2)
        elseif hp <= CONFIG.TIER1_HP then
            triggerEscape(rootPart, 1)
        end
    end)

    table.insert(connections, conn)
end

-- ════════════════════════════════════════════
--  CHARACTER LIFECYCLE
-- ════════════════════════════════════════════
local function onCharacterAdded(character)
    isCooling = false
    UI.build()
    connectEscape(character)
    UI.setActive()
end

player.CharacterAdded:Connect(onCharacterAdded)

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
    if isEnabled then UI.setActive() else UI.setDisabled() end
end)

print("[GNG] Escape module ready.")
print(string.format("[GNG] Tiers: Warning=%d HP | Critical=%d HP", CONFIG.TIER1_HP, CONFIG.TIER2_HP))
