--[[
    TiooHub — MovementScaler.lua (Smart Dash FINAL)
    Author : Ridho (Head of Cyber Team)
]]

local Players  = game:GetService("Players")
local UIS      = game:GetService("UserInputService")
local Debris   = game:GetService("Debris")

local player   = Players.LocalPlayer

local CONFIG = {
    GIANT_SCALE_THRESHOLD = 1.5,
    GIANT_BOOST           = 1.75,
    BOOST_DURATION        = 0.18,
    DASH_COOLDOWN         = 0.6,
    DASH_KEY              = Enum.KeyCode.Q,
    BASE_DASH_SPEED       = 80,
}

local _lastDash = 0
local _dashConn = nil
local _enabled  = false

local MovementScaler = {}

local function isGiant(character, hum)
    local scale = 1.0

    local desc = hum:FindFirstChildOfClass("HumanoidDescription")
    if desc and desc.HeightScale > CONFIG.GIANT_SCALE_THRESHOLD then
        return true, desc.HeightScale
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        local ratio = root.Size.Y / 2
        if ratio > CONFIG.GIANT_SCALE_THRESHOLD then
            return true, ratio
        end
        scale = math.max(scale, ratio)
    end

    local bhs = hum:FindFirstChild("BodyHeightScale")
    if bhs and bhs:IsA("NumberValue") then
        if bhs.Value > CONFIG.GIANT_SCALE_THRESHOLD then
            return true, bhs.Value
        end
        scale = math.max(scale, bhs.Value)
    end

    return false, scale
end

local function applyGiantDash(root, hum, scale)
    local dir = hum.MoveDirection
    if dir.Magnitude < 0.1 then
        dir = root.CFrame.LookVector
    end
    dir = dir.Unit

    local speed = CONFIG.BASE_DASH_SPEED
                * CONFIG.GIANT_BOOST
                * math.min(scale, 3.0)

    local att = root:FindFirstChildOfClass("Attachment")
    if not att then
        att = Instance.new("Attachment", root)
        Debris:AddItem(att, CONFIG.BOOST_DURATION + 0.1)
    end

    local lv = Instance.new("LinearVelocity")
    lv.MaxForce               = math.huge
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.VectorVelocity         = dir * speed
    lv.RelativeTo             = Enum.ActuatorRelativeTo.World
    lv.Attachment0            = att
    lv.Parent                 = root
    Debris:AddItem(lv, CONFIG.BOOST_DURATION)
end

local function onDash()
    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    if hum:GetState() == Enum.HumanoidStateType.Dead then return end

    local now = tick()
    if now - _lastDash < CONFIG.DASH_COOLDOWN then return end
    _lastDash = now

    local giant, scale = isGiant(char, hum)
    if giant then
        applyGiantDash(root, hum, scale)
        print(string.format("[TiooHub] Giant Dash — Scale: %.2f", scale))
    else
        print("[TiooHub] Normal — default dash")
    end
end

function MovementScaler.start()
    if _dashConn then return end
    _enabled  = true
    _dashConn = UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == CONFIG.DASH_KEY then onDash() end
    end)
    print("[TiooHub] MovementScaler FINAL ON")
end

function MovementScaler.stop()
    _enabled = false
    if _dashConn then _dashConn:Disconnect(); _dashConn = nil end
end

local function registerUI()
    if not (UI and UI.addFeatureButton) then return end
    local btn
    btn = UI.addFeatureButton("SMART DASH  ON", Color3.fromRGB(217, 119, 83), function()
        if _enabled then
            MovementScaler.stop()
            btn.Text             = "SMART DASH  OFF"
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        else
            MovementScaler.start()
            btn.Text             = "SMART DASH  ON"
            btn.BackgroundColor3 = Color3.fromRGB(217, 119, 83)
        end
    end)
end

-- // Inisialisasi Lifecycle
task.spawn(function()
    player.CharacterAdded:Connect(function()
        _lastDash = 0
        if _enabled then MovementScaler.start() end
    end)

    player.CharacterRemoving:Connect(MovementScaler.stop)

    -- Jalankan fitur & munculkan tombol di UI TiooHub
    MovementScaler.start()
    registerUI()
end)

return MovementScaler
