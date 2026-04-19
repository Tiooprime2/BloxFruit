--[[
    TiooHub Security v2.1 — UI Module
    Author : Ridho (Head of Cyber Team)
    ScrollingFrame + UIListLayout auto-resize support
]]

local Players  = game:GetService("Players")
local UIS      = game:GetService("UserInputService")
local TweenSvc = game:GetService("TweenService")
local player   = Players.LocalPlayer

UI = {}

local ORANGE   = Color3.fromRGB(217, 119, 83)
local DARK_BG  = Color3.fromRGB(17, 17, 17)
local TEXT_PRI = Color3.fromRGB(240, 230, 222)
local TEXT_MUT = Color3.fromRGB(136, 136, 136)
local TWEEN    = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local BTN_H    = 34   -- tinggi tiap tombol fitur
local BTN_PAD  = 6    -- padding antar tombol
local SCROLL_MAX_H = 160  -- max visible height sebelum scroll aktif

local _frame, _label, _barFill, _hpText, _scrollFrame, _listLayout

-- ════════════════════════════════════════════
--  DRAG
-- ════════════════════════════════════════════
local function attachDrag(f)
    local drag, ds, sp = false, Vector2.zero, UDim2.new()
    f.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = i.Position; sp = f.Position
        end
    end)
    f.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement
        and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local d = i.Position - ds
        f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
    end)
end

-- ════════════════════════════════════════════
--  AUTO RESIZE SCROLL CANVAS
-- ════════════════════════════════════════════
local function refreshScrollCanvas()
    if not _listLayout or not _scrollFrame or not _frame then return end

    local contentH   = _listLayout.AbsoluteContentSize.Y
    local visibleH   = math.min(contentH, SCROLL_MAX_H)

    -- Update CanvasSize
    _scrollFrame.CanvasSize = UDim2.new(1, 0, 0, contentH)

    -- Resize ScrollFrame itu sendiri
    _scrollFrame.Size = UDim2.new(1, -28, 0, visibleH)

    -- Resize MainFrame sesuai konten
    local BASE_H = 105   -- header + statusbar + progress bar
    _frame.Size  = UDim2.new(0, 320, 0, BASE_H + visibleH + 8)
end

-- ════════════════════════════════════════════
--  BUILD
-- ════════════════════════════════════════════
function UI.build()
    local old = player.PlayerGui:FindFirstChild("GNG_UI")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name           = "GNG_UI"
    gui.ResetOnSpawn   = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent         = player.PlayerGui

    -- Main Frame
    local frame = Instance.new("Frame", gui)
    frame.Name             = "MainFrame"
    frame.Size             = UDim2.new(0, 320, 0, 105)
    frame.Position         = UDim2.new(0.5, -160, 0.05, 0)
    frame.BackgroundColor3 = DARK_BG
    frame.BorderSizePixel  = 0
    frame.Active           = true
    frame.ClipsDescendants = false
    _frame = frame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color           = ORANGE
    stroke.Thickness       = 1.5
    stroke.Transparency    = 0.2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- ── Close Button ──
    local closeBtn = Instance.new("TextButton", frame)
    closeBtn.Size             = UDim2.new(0, 24, 0, 24)
    closeBtn.Position         = UDim2.new(0, 10, 0, 9)
    closeBtn.BackgroundColor3 = ORANGE
    closeBtn.BorderSizePixel  = 0
    closeBtn.Text             = "×"
    closeBtn.Font             = Enum.Font.GothamBold
    closeBtn.TextSize         = 14
    closeBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- ── Title ──
    local title = Instance.new("TextLabel", frame)
    title.Size             = UDim2.new(0, 200, 0, 24)
    title.Position         = UDim2.new(0, 42, 0, 9)
    title.BackgroundTransparency = 1
    title.Font             = Enum.Font.GothamBold
    title.TextSize         = 12
    title.TextColor3       = TEXT_PRI
    title.TextXAlignment   = Enum.TextXAlignment.Left
    title.RichText         = true
    title.Text             = 'TiooHub  <font color="rgb(217,119,83)">|  SECURITY V2.1</font>'

    -- ── UP Button ──
    local upBtn = Instance.new("TextButton", frame)
    upBtn.Size             = UDim2.new(0, 52, 0, 26)
    upBtn.Position         = UDim2.new(1, -62, 0, 7)
    upBtn.BackgroundColor3 = ORANGE
    upBtn.BorderSizePixel  = 0
    upBtn.Text             = "UP"
    upBtn.Font             = Enum.Font.GothamBold
    upBtn.TextSize         = 13
    upBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 6)
    upBtn.MouseButton1Click:Connect(function()
        local char = player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = root.CFrame + Vector3.new(0, 2000, 0) end
    end)

    -- ── Divider 1 (bawah header) ──
    local div1 = Instance.new("Frame", frame)
    div1.Size               = UDim2.new(1, -24, 0, 1)
    div1.Position           = UDim2.new(0, 12, 0, 38)
    div1.BackgroundColor3   = ORANGE
    div1.BackgroundTransparency = 0.65
    div1.BorderSizePixel    = 0

    -- ════════════════════════════════════════
    --  SCROLLING FRAME (area fitur modul)
    -- ════════════════════════════════════════
    local scrollFrame = Instance.new("ScrollingFrame", frame)
    scrollFrame.Name              = "FeatureScroll"
    scrollFrame.Position          = UDim2.new(0, 14, 0, 44)
    scrollFrame.Size              = UDim2.new(1, -28, 0, 0)   -- tinggi diatur refreshScrollCanvas
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel   = 0
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = ORANGE
    scrollFrame.CanvasSize        = UDim2.new(1, 0, 0, 0)
    scrollFrame.ClipsDescendants  = true
    _scrollFrame = scrollFrame

    local listLayout = Instance.new("UIListLayout", scrollFrame)
    listLayout.SortOrder       = Enum.SortOrder.LayoutOrder
    listLayout.Padding         = UDim.new(0, BTN_PAD)
    listLayout.FillDirection   = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    _listLayout = listLayout

    -- Auto-resize setiap kali konten berubah
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshScrollCanvas)

    -- ── Divider 2 (bawah scroll, atas statusbar) ──
    -- Posisinya dinamis — pakai offset dari bawah frame
    local div2 = Instance.new("Frame", frame)
    div2.Name               = "Div2"
    div2.Size               = UDim2.new(1, -24, 0, 1)
    div2.Position           = UDim2.new(0, 12, 1, -40)  -- 40px dari bawah frame
    div2.BackgroundColor3   = ORANGE
    div2.BackgroundTransparency = 0.65
    div2.BorderSizePixel    = 0

    -- ── Status Dot + Label ──
    local dot = Instance.new("Frame", frame)
    dot.Size               = UDim2.new(0, 9, 0, 9)
    dot.Position           = UDim2.new(0, 14, 1, -28)
    dot.BackgroundColor3   = TEXT_PRI
    dot.BorderSizePixel    = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local statusLabel = Instance.new("TextLabel", frame)
    statusLabel.Name           = "Status"
    statusLabel.Size           = UDim2.new(1, -90, 0, 18)
    statusLabel.Position       = UDim2.new(0, 28, 1, -32)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text           = "FAIL-SAFE  ACTIVE"
    statusLabel.Font           = Enum.Font.Code
    statusLabel.TextSize       = 12
    statusLabel.TextColor3     = TEXT_PRI
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    _label = statusLabel

    local hpText = Instance.new("TextLabel", frame)
    hpText.Name           = "HpText"
    hpText.Size           = UDim2.new(0, 50, 0, 18)
    hpText.Position       = UDim2.new(1, -62, 1, -32)
    hpText.BackgroundTransparency = 1
    hpText.Text           = "100%"
    hpText.Font           = Enum.Font.Code
    hpText.TextSize       = 11
    hpText.TextColor3     = TEXT_MUT
    hpText.TextXAlignment = Enum.TextXAlignment.Right
    _hpText = hpText

    -- ── Progress Bar ──
    local track = Instance.new("Frame", frame)
    track.Size             = UDim2.new(1, -28, 0, 9)
    track.Position         = UDim2.new(0, 14, 1, -16)
    track.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
    track.BorderSizePixel  = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 5)

    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = ORANGE
    fill.BorderSizePixel  = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 5)
    _barFill = fill

    attachDrag(frame)
    refreshScrollCanvas()
    print("[GNG] UI V2.1 Built — TiooHub Style")
end

-- ════════════════════════════════════════════
--  ADD FEATURE BUTTON (dipanggil dari modul lain)
--  label  : string  — teks tombol
--  color  : Color3  — warna bg (opsional, default ORANGE)
--  onClick: function
-- ════════════════════════════════════════════
function UI.addFeatureButton(label, color, onClick)
    if not _scrollFrame then return end

    local btn = Instance.new("TextButton", _scrollFrame)
    btn.Size              = UDim2.new(1, 0, 0, BTN_H)
    btn.BackgroundColor3  = color or ORANGE
    btn.BorderSizePixel   = 0
    btn.Text              = label
    btn.Font              = Enum.Font.GothamBold
    btn.TextSize          = 12
    btn.TextColor3        = Color3.fromRGB(255, 255, 255)
    btn.AutoButtonColor   = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    if onClick then
        btn.MouseButton1Click:Connect(onClick)
    end

    -- refreshScrollCanvas dipanggil otomatis via AbsoluteContentSize signal
    return btn
end

-- ════════════════════════════════════════════
--  HEALTH BAR
-- ════════════════════════════════════════════
function UI.updateHealth(current, max)
    if not _barFill then return end
    local pct = math.clamp(current / max, 0, 1)
    local col = pct > 0.5 and ORANGE
             or pct > 0.25 and Color3.fromRGB(230, 80, 80)
             or Color3.fromRGB(255, 50, 50)
    TweenSvc:Create(_barFill, TWEEN, {
        Size             = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = col,
    }):Play()
    if _hpText then _hpText.Text = math.floor(pct * 100) .. "%" end
end

-- ════════════════════════════════════════════
--  STATE SETTERS
-- ════════════════════════════════════════════
function UI.setActive()
    if not _label then return end
    _label.Text       = "FAIL-SAFE  ACTIVE"
    _label.TextColor3 = TEXT_PRI
end

function UI.setTriggered(tier)
    if not _label then return end
    _label.Text       = tier == 2 and "CRITICAL — ESCAPING" or "TRIGGERED"
    _label.TextColor3 = tier == 2 and Color3.fromRGB(255, 60, 60) or ORANGE
end

function UI.setCooling(s)
    if not _label then return end
    _label.Text       = "COOLDOWN  " .. s .. "s"
    _label.TextColor3 = TEXT_MUT
end

function UI.setDisabled()
    if not _label then return end
    _label.Text       = "FAIL-SAFE  OFF"
    _label.TextColor3 = Color3.fromRGB(80, 80, 80)
end

print("[GNG] UI module ready.")
return UI
