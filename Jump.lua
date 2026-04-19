--[[
    GNG Fail-safe v2.3 — Jump Module (Rework)
    Author : Ridho (Head of Cyber Team)
    Note   : Loaded by main.lua — do not run standalone
]]

local Players  = game:GetService("Players")
local UIS      = game:GetService("UserInputService")
local Debris   = game:GetService("Debris")
local RunSvc   = game:GetService("RunService")

local player   = Players.LocalPlayer
local conn     = nil
local connGrav = nil

local CONFIG = {
    BASE_VELOCITY    = 130,      -- 2.5x–3x dari standar Blox Fruits (~50)
    FLOATY_GRAVITY   = 75,       -- workspace.Gravity default = 196.2
    NORMAL_GRAVITY   = 196.2,
    FLOAT_DURATION   = 0.55,     -- detik gravitasi ringan saat naik
    DEBOUNCE_TIME    = 0.08,
    INFINITE_JUMP    = true,
}

-- ════════════════════════════════════════════
--  UTIL: Apply BodyVelocity singkat + floaty gravity
-- ════════════════════════════════════════════
local function smoothJump(root, hum)
    -- Inject BodyVelocity vertikal — smooth, tidak patah
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(0, math.huge, 0)
    bv.Velocity = Vector3.new(0, CONFIG.BASE_VELOCITY, 0)
    bv.Parent   = root
    Debris:AddItem(bv, 0.12)   -- singkat — cukup untuk impulse awal

    -- Floaty phase: turunkan gravity sementara saat karakter naik
    workspace.Gravity = CONFIG.FLOATY_GRAVITY
    hum:ChangeState(Enum.HumanoidStateType.Jumping)

    task.delay(CONFIG.FLOAT_DURATION, function()
        -- Kembalikan gravity normal setelah float phase
        workspace.Gravity = CONFIG.NORMAL_GRAVITY
    end)
end

-- ════════════════════════════════════════════
--  SAFETY: pastikan tidak stuck di udara
--  Jika karakter tidak landed dalam 4 detik, reset gravity
-- ════════════════════════════════════════════
local function safetyGravityReset(hum)
    local timeout = 4
    local elapsed = 0

    if connGrav then connGrav:Disconnect() end

    connGrav = RunSvc.Heartbeat:Connect(function(dt)
        elapsed += dt
        local state = hum:GetState()
        local landed = (state == Enum.HumanoidStateType.Landed
                     or state == Enum.HumanoidStateType.Running
                     or state == Enum.HumanoidStateType.Freefall)

        if elapsed >= timeout or (landed and elapsed > 0.3) then
            workspace.Gravity = CONFIG.NORMAL_GRAVITY
            connGrav:Disconnect()
            connGrav = nil
        end
    end)
end

-- ════════════════════════════════════════════
--  CORE JUMP LISTENER
-- ════════════════════════════════════════════
local lastJump = 0

local function start()
    if conn then conn:Disconnect() end

    conn = UIS.JumpRequest:Connect(function()
        local character = player.Character
        if not character then return end

        local root = character:FindFirstChild("HumanoidRootPart")
        local hum  = character:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        local now   = tick()
        local state = hum:GetState()

        -- Infinite jump: boleh lompat dari state apapun kecuali dead/seated
        local canJump = CONFIG.INFINITE_JUMP
            or state == Enum.HumanoidStateType.Landed
            or state == Enum.HumanoidStateType.Running

        if canJump and (now - lastJump >= CONFIG.DEBOUNCE_TIME) then
            lastJump = now
            smoothJump(root, hum)
            safetyGravityReset(hum)
        end
    end)

    -- ── Sync tombol UP dari UI ──
    -- UP button di UI.lua sudah teleport +2000,
    -- tapi kalau mau pakai smooth vertical dari Jump,
    -- bisa panggil UI.addFeatureButton di sini:
    if UI and UI.addFeatureButton then
        UI.addFeatureButton("JUMP BOOST  ON", Color3.fromRGB(217, 119, 83), function()
            CONFIG.INFINITE_JUMP = not CONFIG.INFINITE_JUMP
            print("[GNG] Infinite Jump: " .. tostring(CONFIG.INFINITE_JUMP))
        end)
    end

    print("[GNG] Jump Module V2.3 Activated")
    print(string.format("[GNG] Velocity=%.0f | FloatGrav=%.0f | InfJump=%s",
        CONFIG.BASE_VELOCITY, CONFIG.FLOATY_GRAVITY, tostring(CONFIG.INFINITE_JUMP)))
end

-- ════════════════════════════════════════════
--  CLEANUP saat karakter respawn
-- ════════════════════════════════════════════
player.CharacterRemoving:Connect(function()
    workspace.Gravity = CONFIG.NORMAL_GRAVITY
    if conn    then conn:Disconnect();    conn    = nil end
    if connGrav then connGrav:Disconnect(); connGrav = nil end
end)

start()
