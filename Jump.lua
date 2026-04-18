--[[
    GNG Fail-safe v2.2 — Jump Module
    Author : Ridho (Head of Cyber Team)
    Note   : Loaded by main.lua — do not run standalone
]]

-- ════════════════════════════════════════════
--  SERVICES & CACHE
-- ════════════════════════════════════════════
local Players  = game:GetService("Players")
local UIS      = game:GetService("UserInputService")
local Debris   = game:GetService("Debris")

local player   = Players.LocalPlayer
local conn     = nil
local lastJump = 0

local CONFIG = {
    JUMP_MULTIPLIER = 1.15,
    BASE_VELOCITY   = 50,
    DEBOUNCE_TIME   = 0.1,
}

-- ════════════════════════════════════════════
--  CORE LOGIC
-- ════════════════════════════════════════════
local function start()
    if conn then conn:Disconnect() end

    conn = UIS.JumpRequest:Connect(function()
        local character = player.Character
        if not character then return end

        local root = character:FindFirstChild("HumanoidRootPart")
        local hum  = character:FindFirstChildOfClass("Humanoid")

        local now = tick()
        if root and hum and (now - lastJump >= CONFIG.DEBOUNCE_TIME) then
            lastJump = now

            local bv        = Instance.new("BodyVelocity")
            bv.MaxForce     = Vector3.new(0, math.huge, 0)
            bv.Velocity     = Vector3.new(0, CONFIG.BASE_VELOCITY * CONFIG.JUMP_MULTIPLIER, 0)
            bv.Parent       = root
            Debris:AddItem(bv, 0.1)

            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    print("[GNG] Jump Module V2.2 Activated")
end

-- ════════════════════════════════════════════
--  AUTO START + UI LABEL UPDATE
-- ════════════════════════════════════════════
start()

-- Update UI if available
if UI and UI.setActive then
    UI.setActive()
end
