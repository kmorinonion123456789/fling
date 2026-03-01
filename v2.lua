local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local antiGrabEnabled = true

-- === UI作成 (モダンデザイン) ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModernAntiGrab"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- メインフレーム
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 110)
mainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- 深いグレー
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

-- ドロップシャドウ風の装飾
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 4, 1, 4)
shadow.Position = UDim2.new(0, -2, 0, -2)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.7
shadow.ZIndex = 0
shadow.Parent = mainFrame
Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 12)

-- タイトル
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "ANTI-GRAB"
title.TextColor3 = Color3.fromRGB(220, 220, 220)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.Parent = mainFrame

-- トグルボタン
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.85, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.075, 0, 0.45, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 100) -- 初期の緑
toggleBtn.Text = "Status: ACTIVE"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamSemibold
toggleBtn.TextSize = 13
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleBtn

-- === アニメーション関数 ===
local function animateColor(object, property, color)
    TweenService:Create(object, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {[property] = color}):Play()
end

-- === トグルロジック ===
toggleBtn.MouseButton1Click:Connect(function()
    antiGrabEnabled = not antiGrabEnabled
    if antiGrabEnabled then
        toggleBtn.Text = "Status: ACTIVE"
        animateColor(toggleBtn, "BackgroundColor3", Color3.fromRGB(40, 180, 100))
    else
        toggleBtn.Text = "Status: DISABLED"
        animateColor(toggleBtn, "BackgroundColor3", Color3.fromRGB(200, 60, 60))
    end
end)

-- === アンチ掴みロジック (Heartbeat) ===
RunService.Heartbeat:Connect(function()
    if not antiGrabEnabled then return end

    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        
        -- 強制ラグドールの即時解除
        if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum.PlatformStanding then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            hum.PlatformStanding = false
        end
        
        -- WeldやConstraintなどの拘束パーツを排除
        for _, obj in pairs(char:GetDescendants()) do
            if (obj:IsA("Constraint") or obj:IsA("Weld") or obj:IsA("RopeConstraint")) and not obj:IsA("Motor6D") then
                obj:Destroy()
            end
        end
    end
end)

-- リモートイベントへの自動抵抗 (軽量化版)
task.spawn(function()
    while task.wait(0.2) do
        if antiGrabEnabled then
            pcall(function()
                -- よくあるゲームのリモートイベント名をカバー
                if ReplicatedStorage:FindFirstChild("GrabEvents") then
                    ReplicatedStorage.GrabEvents.EndGrabEarly:FireServer()
                end
                if ReplicatedStorage:FindFirstChild("CharacterEvents") then
                    ReplicatedStorage.CharacterEvents.Struggle:FireServer()
                end
            end)
        end
    end
end)

print("Modern Anti-Grab Loaded.")
