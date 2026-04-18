--[[
    GNG Security v2.1 — UI Module
    Author : Ridho (Head of Cyber Team)
]]

local Players  = game:GetService("Players")
local UIS      = game:GetService("UserInputService")
local TweenSvc = game:GetService("TweenService")
local player   = Players.LocalPlayer

UI = {}  -- global, accessible by Escape.lua

-- ══════════════════════════════════════
--  INTERNAL REFS
-- ══════════════════════════════════════
local _label, _barFill, _frame
local _tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- ══════════════════════════════════════
--  DRAG
-- ══════════════════════════════════════
local function attachDrag(f)
    local dragging, dragStart, startPos = false, Vector2.zero, UDim2.new()

    f.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = i.Position
            startPos  = f.Position
        end
    end)

    f.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement
        and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = i.Position - dragStart
        f.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end)
end

-- ══════════════════════════════════════
--  BUILD
-- ══════════════════════════════════════
function UI.build()
    local old = player.PlayerGui:FindFirstChild("GNG_UI")
    if old then old:Destroy() end

    local gui          = Instance.new("ScreenGui")
    gui.Name           = "GNG_UI"
    gui.ResetOnSpawn   = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent         = player.PlayerGui

    -- Main frame
    local frame            = Instance.new("Frame", gui)
    frame.Name             = "MainFrame"
    frame.Size             = UDim2.new(0, 260, 0, 90)
    frame.Position         = UDim2.new(0.5, -130, 0.06, 0)
    frame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
    frame.BorderSizePixel  = 0
    frame.Active           = true
    frame.ClipsDescendants = true
    _frame = frame

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    -- Gold glow stroke
    local stroke           = Instance.new("UIStroke", frame)
    stroke.Color           = Color3.fromRGB(217, 119, 87)
    stroke.Thickness       = 1.5
    stroke.Transparency    = 0.2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Left accent bar
    local accent            = Instance.new("Frame", frame)
    accent.Size             = UDim2.new(0, 3, 1, 0)
    accent.BackgroundColor3 = Color3.fromRGB(217, 119, 87)
    accent.BorderSizePixel  = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 8)

    -- Header
    local header               = Instance.new("TextLabel", frame)
    header.Size                = UDim2.new(1, -16, 0, 24)
    header.Position            = UDim2.new(0, 14, 0, 8)
    header.BackgroundTransparency = 1
    header.Text                = "GNG  |  SECURITY V2.1"
    header.Font                = Enum.Font.Code
    header.TextSize            = 12
    header.TextColor3          = Color3.fromRGB(217, 119, 87)
    header.TextXAlignment      = Enum.TextXAlignment.Left

    -- Divider line
    local div              = Instance.new("Frame", frame)
    div.Size               = UDim2.new(1, -14, 0, 1)
    div.Position           = UDim2.new(0, 14, 0, 34)
    div.BackgroundColor3   = Color3.fromRGB(217, 119, 87)
    div.BackgroundTransparency = 0.75
    div.BorderSizePixel    = 0

    -- Status label
    local statusLabel          = Instance.new("TextLabel", frame)
    statusLabel.Name           = "Status"
    statusLabel.Size           = UDim2.new(1, -70, 0, 18)
    statusLabel.Position       = UDim2.new(0, 14, 0, 40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text           = "● FAIL-SAFE  ACTIVE"
    statusLabel.Font           = Enum.Font.Code
    statusLabel.TextSize       = 12
    statusLabel.TextColor3     = Color3.fromRGB(232, 232, 232)
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    _label = statusLabel

    -- HP % label
    local hpText               = Instance.new("TextLabel", frame)
    hpText.Name                = "HpText"
    hpText.Size                = UDim2.new(0, 50, 0, 18)
    hpText.Position            = UDim2.new(1, -60, 0, 40)
    hpText.BackgroundTransparency = 1
    hpText.Text                = "100%"
    hpText.Font                = Enum.Font.Code
    hpText.TextSize            = 11
    hpText.TextColor3          = Color3.fromRGB(140, 140, 140)
    hpText.TextXAlignment      = Enum.TextXAlignment.Right

    -- Health bar track
    local barTrack              = Instance.new("Frame", frame)
    barTrack.Size               = UDim2.new(1, -28, 0, 8)
    barTrack.Position           = UDim2.new(0, 14, 0, 66)
    barTrack.BackgroundColor3   = Color3.fromRGB(40, 40, 40)
    barTrack.BorderSizePixel    = 0
    Instance.new("UICorner", barTrack).CornerRadius = UDim.new(0, 4)

    -- Health bar fill
    local barFill             = Instance.new("Frame", barTrack)
    barFill.Size              = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3  = Color3.fromRGB(217, 119, 87)
    barFill.BorderSizePixel   = 0
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 4)
    _barFill = barFill

    attachDrag(frame)
    print("[GNG] UI built.")
end

-- ══════════════════════════════════════
--  HEALTH BAR  (call from Escape.lua)
-- ══════════════════════════════════════
function UI.updateHealth(current, max)
    if not _barFill or not _frame then return end
    local pct = math.clamp(current / max, 0, 1)

    local colour
    if pct > 0.5 then
        colour = Color3.fromRGB(217, 119, 87)   -- gold (safe)
    elseif pct > 0.25 then
        colour = Color3.fromRGB(230, 80, 80)    -- orange-red (warning)
    else
        colour = Color3.fromRGB(255, 50, 50)    -- red (critical)
    end

    TweenSvc:Create(_barFill, _tweenInfo, {
        Size             = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = colour,
    }):Play()

    local hpText = _frame:FindFirstChild("HpText")
    if hpText then
        hpText.Text = math.floor(pct * 100) .. "%"
    end
end

-- ══════════════════════════════════════
--  STATE SETTERS
-- ══════════════════════════════════════
function UI.setActive()
    if not _label then return end
    _label.Text       = "● FAIL-SAFE  ACTIVE"
    _label.TextColor3 = Color3.fromRGB(232, 232, 232)
end

function UI.setTriggered(tier)
    if not _label then return end
    if tier == 2 then
        _label.Text       = "🔴 CRITICAL — ESCAPING"
        _label.TextColor3 = Color3.fromRGB(255, 60, 60)
    else
        _label.Text       = "⚡ TRIGGERED"
        _label.TextColor3 = Color3.fromRGB(217, 119, 87)
    end
end

function UI.setCooling(s)
    if not _label then return end
    _label.Text       = "◌ COOLDOWN  " .. s .. "s"
    _label.TextColor3 = Color3.fromRGB(140, 140, 140)
end

function UI.setDisabled()
    if not _label then return end
    _label.Text       = "○ FAIL-SAFE  OFF"
    _label.TextColor3 = Color3.fromRGB(80, 80, 80)
end

print("[GNG] UI module ready.")
