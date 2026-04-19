--[[
    TiooHub — HighGravJump Module
    Author : Ridho (Head of Cyber Team)
    Note   : Standalone LocalScript atau load via main.lua
]]

local Players  = game:GetService("Players")
local UIS      = game:GetService("UserInputService")
local Debris   = game:GetService("Debris")
local RunSvc   = game:GetService("RunService")

local player   = Players.LocalPlayer

local CONFIG = {
    JUMP_POWER       = 150,
    LOCK_INTERVAL    = 0.1,   -- detik antar lock (Heartbeat terlalu greedy)
    INFINITE_JUMP    = true,
    BV_DURATION      = 0.10,  -- detik BodyVelocity aktif
}

local _lockConn  = nil
local _jumpConn  = nil
local _lastJump  = 0
local DEBOUNCE   = 0.08

-- ════════════════════════════════════════════
--  LOCK JUMPPOWER
--  Pakai task.delay loop — lebih hemat dari Heartbeat
-- ════════════════════════════════════════════
local function startLock(hum)
    if _lockConn then _lockConn:Disconnect() end

    -- Gunakan Heartbeat hanya jika benar-benar perlu (mis. game terus reset)
    _lockConn = RunSvc.Heartbeat:Connect(function()
        if hum and hum.Parent then
            if hum.JumpPower ~= CONFIG.JUMP_POWER then
                hum.JumpPower = CONFIG.JUMP_POWER
            end
        else
            _lockConn:Disconnect()
            _lockConn = nil
        end
    end)
end

-- ════════════════════════════════════════════
--  SMOOTH JUMP (tanpa patah / snap)
-- ════════════════════════════════════════════
local function doJump(root, hum)
    local bv      = Instance.new("BodyVelocity")
    bv.MaxForce   = Vector3.new(0, math.huge, 0)
    bv.Velocity   = Vector3.new(0, CONFIG.JUMP_POWER, 0)
    bv.Parent     = root
    Debris:AddItem(bv, CONFIG.BV_DURATION)

    hum:ChangeState(Enum.HumanoidStateType.Jumping)
end

-- ════════════════════════════════════════════
--  INFINITE JUMP LISTENER
-- ════════════════════════════════════════════
local function startJump()
    if _jumpConn then _jumpConn:Disconnect() end

    _jumpConn = UIS.JumpRequest:Connect(function()
        local char = player.Character
        if not char then return end

        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        if hum:GetState() == Enum.HumanoidStateType.Dead then return end

        local now = tick()
        if now - _lastJump < DEBOUNCE then return end

        -- Cek apakah infinite jump aktif atau hanya jump dari ground
        local state    = hum:GetState()
        local onGround = state == Enum.HumanoidStateType.Landed
                      or state == Enum.HumanoidStateType.Running

        if CONFIG.INFINITE_JUMP or onGround then
            _lastJump = now
            doJump(root, hum)
        end
    end)
end

-- ════════════════════════════════════════════
--  CHARACTER HANDLER
-- ════════════════════════════════════════════
local function onChar(char)
    local hum = char:WaitForChild("Humanoid")
    hum.JumpPower = CONFIG.JUMP_POWER
    startLock(hum)
    startJump()
end

player.CharacterAdded:Connect(onChar)
player.CharacterRemoving:Connect(function()
    if _lockConn then _lockConn:Disconnect(); _lockConn = nil end
    if _jumpConn then _jumpConn:Disconnect(); _jumpConn = nil end
end)

if player.Character then
    onChar(player.Character)
end

print(string.format("[TiooHub] HighGravJump — Power=%d | InfJump=%s",
    CONFIG.JUMP_POWER, tostring(CONFIG.INFINITE_JUMP)))
