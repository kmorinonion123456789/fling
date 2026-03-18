local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera 
local SpawnRemote = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")

-- 設定
local CONFIG = {
    Keybind = Enum.KeyCode.E, -- PC用のキー設定
    SpawnDistance = 5,        -- 目の前何メートルの位置に出すか
    ItemName = "PalletLightBrown",
    MainColor = Color3.fromRGB(45, 45, 45),
    AccentColor = Color3.fromRGB(0, 170, 255),
    ErrorColor = Color3.fromRGB(255, 60, 60)
}

-- UI作成
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernItaSpawner"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainButton = Instance.new("TextButton")
MainButton.Name = "ItaButton"
MainButton.Parent = ScreenGui
MainButton.BackgroundColor3 = CONFIG.MainColor
MainButton.Position = UDim2.new(0.05, 0, 0.4, 0)
MainButton.Size = UDim2.new(0, 180, 0, 50)
MainButton.Font = Enum.Font.GothamBold
MainButton.Text = "板を生成 ["..CONFIG.Keybind.Name.."]"
MainButton.TextColor3 = Color3.new(1, 1, 1)
MainButton.TextSize = 14
MainButton.AutoButtonColor = false
MainButton.ClipsDescendants = true

-- 装飾
local UICorner = Instance.new("UICorner", MainButton)
UICorner.CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke", MainButton)
UIStroke.Thickness = 2
UIStroke.Color = CONFIG.AccentColor
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- ドラッグ機能（簡易版）
local dragging, dragInput, dragStart, startPos
MainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainButton.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- 生成ロジック
local function spawnIta()
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end

    -- アニメーション（クリック感）
    local shrink = TweenService:Create(MainButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 170, 0, 45)})
    local expand = TweenService:Create(MainButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 180, 0, 50)})
    shrink:Play()
    task.wait(0.05)
    expand:Play()

    local spawnCFrame = Camera.CFrame * CFrame.new(0, 0, -CONFIG.SpawnDistance) 
    local args = {CONFIG.ItemName, spawnCFrame, Vector3.new(0, 0, 0)}

    local success, _ = pcall(function()
        return SpawnRemote:InvokeServer(table.unpack(args))
    end)

    if success then
        MainButton.Text = "SUCCESS"
        UIStroke.Color = Color3.fromRGB(0, 255, 150)
    else
        MainButton.Text = "FAILED"
        UIStroke.Color = CONFIG.ErrorColor
    end

    task.wait(0.8)
    MainButton.Text = "板を生成 ["..CONFIG.Keybind.Name.."]"
    UIStroke.Color = CONFIG.AccentColor
end

-- タッチ/クリックイベント
MainButton.MouseButton1Click:Connect(spawnIta)

-- キー入力イベント (PC用)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- チャット中などは反応しない
    if input.KeyCode == CONFIG.Keybind then
        spawnIta()
    end
end)

print("Modern Ita Spawner Loaded: Keyboard("..CONFIG.Keybind.Name..") & Touch supported.")
