--[[
    GNG Fail-safe v2 — UI Module
    Author : Ridho (Head of Cyber Team)
    Note   : Loaded by main.lua — do not run standalone
    Add new UI features here freely
]]

local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local player  = Players.LocalPlayer

-- Global so Escape.lua (loaded after) can call UI.xxx()
UI = {}
local label = nil

function UI.build()
    local old = player.PlayerGui:FindFirstChild("GNG_FailSafe")
    if old then old:Destroy() end

    local gui             = Instance.new("ScreenGui")
    gui.Name              = "GNG_FailSafe"
    gui.ResetOnSpawn      = false
    gui.Parent            = player.PlayerGui

    local frame                  = Instance.new("Frame", gui)
    frame.Name                   = "MainFrame"
    frame.Size                   = UDim2.new(0, 240, 0, 58)
    frame.Position               = UDim2.new(0.5, -120, 0.08, 0)
    frame.BackgroundColor3       = Color3.fromRGB(23, 23, 23)
    frame.BorderSizePixel        = 0
    frame.ClipsDescendants       = true
    frame.Active                 = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 7)

    local accent                 = Instance.new("Frame", frame)
    accent.Size                  = UDim2.new(0, 3, 1, 0)
    accent.Position              = UDim2.new(0, 0, 0, 0)
    accent.BackgroundColor3      = Color3.fromRGB(217, 119, 87)
    accent.BorderSizePixel       = 0

    local topLine                = Instance.new("Frame", frame)
    topLine.Size                 = UDim2.new(1, 0, 0, 1)
    topLine.BackgroundColor3     = Color3.fromRGB(217, 119, 87)
    topLine.BackgroundTransparency = 0.7
    topLine.BorderSizePixel      = 0

    label                        = Instance.new("TextLabel", frame)
    label.Name                   = "Status"
    label.Size                   = UDim2.new(1, -18, 0.7, 0)
    label.Position               = UDim2.new(0, 16, 0.05, 0)
    label.BackgroundTransparency = 1
    label.TextColor3             = Color3.fromRGB(232, 232, 232)
    label.Text                   = "● FAIL-SAFE  ACTIVE"
    label.Font                   = Enum.Font.Code
    label.TextSize               = 13
    label.TextXAlignment         = Enum.TextXAlignment.Left

    local hint                   = Instance.new("TextLabel", frame)
    hint.Size                    = UDim2.new(0, 80, 0, 14)
    hint.Position                = UDim2.new(1, -84, 1, -16)
    hint.BackgroundTransparency  = 1
    hint.TextColor3              = Color3.fromRGB(100, 100, 100)
    hint.Text                    = "[F9] toggle"
    hint.Font                    = Enum.Font.Code
    hint.TextSize                = 10
    hint.TextXAlignment          = Enum.TextXAlignment.Right

    -- Drag
    local dragging  = false
    local dragStart = Vector2.new()
    local startPos  = UDim2.new()

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(input)
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
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end)
end

function UI.setActive()
    if not label then return end
    label.Text       = "● FAIL-SAFE  ACTIVE"
    label.TextColor3 = Color3.fromRGB(232, 232, 232)
end

function UI.setTriggered(tier)
    if not label then return end
    if tier == 2 then
        label.Text       = "🔴 CRITICAL — ESCAPING"
        label.TextColor3 = Color3.fromRGB(255, 80, 80)
    else
        label.Text       = "⚡ SAFE-STATE TRIGGERED"
        label.TextColor3 = Color3.fromRGB(217, 119, 87)
    end
end

function UI.setCooling(secondsLeft)
    if not label then return end
    label.Text       = "◌ COOLDOWN  " .. tostring(secondsLeft) .. "s"
    label.TextColor3 = Color3.fromRGB(140, 140, 140)
end

function UI.setDisabled()
    if not label then return end
    label.Text       = "○ FAIL-SAFE  OFF"
    label.TextColor3 = Color3.fromRGB(90, 90, 90)
end

print("[GNG] UI module ready.")
