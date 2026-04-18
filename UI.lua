--[[
    GNG Fail-safe v2 — UI Module
    Author  : Ridho (Head of Cyber Team)
    Theme   : Claude Code (#171717, #D97757, #E8E8E8)
    Handles : ScreenGui, dragging, status labels, all state visuals
]]

local UI = {}

local player = game:GetService("Players").LocalPlayer
local UIS    = game:GetService("UserInputService")

local gui, label, frame

-- ════════════════════════════════════════════
--  BUILD GUI
-- ════════════════════════════════════════════
function UI.build()
    local old = player.PlayerGui:FindFirstChild("GNG_FailSafe")
    if old then old:Destroy() end

    gui             = Instance.new("ScreenGui")
    gui.Name        = "GNG_FailSafe"
    gui.ResetOnSpawn = false
    gui.Parent      = player.PlayerGui

    frame                  = Instance.new("Frame", gui)
    frame.Name             = "MainFrame"
    frame.Size             = UDim2.new(0, 240, 0, 58)
    frame.Position         = UDim2.new(0.5, -120, 0.08, 0)
    frame.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
    frame.BorderSizePixel  = 0
    frame.ClipsDescendants = true
    frame.Active           = true  -- needed for drag input
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 7)

    -- Left accent bar (Claude Orange)
    local accent              = Instance.new("Frame", frame)
    accent.Size               = UDim2.new(0, 3, 1, 0)
    accent.Position           = UDim2.new(0, 0, 0, 0)
    accent.BackgroundColor3   = Color3.fromRGB(217, 119, 87)
    accent.BorderSizePixel    = 0

    -- Top separator line (subtle)
    local topLine             = Instance.new("Frame", frame)
    topLine.Size              = UDim2.new(1, 0, 0, 1)
    topLine.BackgroundColor3  = Color3.fromRGB(217, 119, 87)
    topLine.BackgroundTransparency = 0.7
    topLine.BorderSizePixel   = 0

    -- Status label
    label                      = Instance.new("TextLabel", frame)
    label.Name                 = "Status"
    label.Size                 = UDim2.new(1, -18, 1, 0)
    label.Position             = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3           = Color3.fromRGB(232, 232, 232)
    label.Text                 = "● FAIL-SAFE  ACTIVE"
    label.Font                 = Enum.Font.Code
    label.TextSize             = 13
    label.TextXAlignment       = Enum.TextXAlignment.Left

    -- Keybind hint (bottom-right)
    local hint                 = Instance.new("TextLabel", frame)
    hint.Size                  = UDim2.new(0, 60, 0, 14)
    hint.Position              = UDim2.new(1, -64, 1, -16)
    hint.BackgroundTransparency = 1
    hint.TextColor3            = Color3.fromRGB(100, 100, 100)
    hint.Text                  = "[F9] toggle"
    hint.Font                  = Enum.Font.Code
    hint.TextSize              = 10
    hint.TextXAlignment        = Enum.TextXAlignment.Right

    UI._attachDrag(frame)
end

-- ════════════════════════════════════════════
--  DRAG LOGIC
-- ════════════════════════════════════════════
function UI._attachDrag(f)
    local dragging  = false
    local dragStart = Vector2.new()
    local startPos  = UDim2.new()

    f.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = f.Position
        end
    end)

    f.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end

        local delta = input.Position - dragStart
        f.Position  = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end)
end

-- ════════════════════════════════════════════
--  STATE SETTERS  (called by Escape.lua)
-- ════════════════════════════════════════════
function UI.setActive()
    label.Text       = "● FAIL-SAFE  ACTIVE"
    label.TextColor3 = Color3.fromRGB(232, 232, 232)
end

function UI.setTriggered(tier)
    -- tier 1 = warning zone, tier 2 = critical zone
    if tier == 2 then
        label.Text       = "🔴 CRITICAL — ESCAPING"
        label.TextColor3 = Color3.fromRGB(255, 80, 80)
    else
        label.Text       = "⚡ SAFE-STATE TRIGGERED"
        label.TextColor3 = Color3.fromRGB(217, 119, 87)
    end
end

function UI.setCooling(secondsLeft)
    label.Text       = "◌ COOLDOWN  " .. tostring(secondsLeft) .. "s"
    label.TextColor3 = Color3.fromRGB(140, 140, 140)
end

function UI.setDisabled()
    label.Text       = "○ FAIL-SAFE  OFF"
    label.TextColor3 = Color3.fromRGB(90, 90, 90)
end

return UI
