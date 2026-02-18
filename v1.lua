local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera 
local SpawnRemote = ReplicatedStorage:WaitForChild("MenuToys"):WaitForChild("SpawnToyRemoteFunction")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomItaSpawnerV2"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainButton = Instance.new("TextButton")
MainButton.Name = "ItaButton"
MainButton.Parent = ScreenGui
MainButton.BackgroundColor3 = Color3.fromRGB(150, 110, 80)
MainButton.Position = UDim2.new(0.05, 0, 0.4, 0)
MainButton.Size = UDim2.new(0, 200, 0, 60)
MainButton.Font = Enum.Font.SourceSansBold
MainButton.Text = "視線の先に板を生成"
MainButton.TextColor3 = Color3.new(1, 1, 1)
MainButton.TextSize = 20
MainButton.Draggable = true

local UICorner = Instance.new("UICorner", MainButton)
UICorner.CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke", MainButton)
UIStroke.Thickness = 2
UIStroke.Color = Color3.new(1, 1, 1)

MainButton.MouseButton1Click:Connect(function()
    local Character = LocalPlayer.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    
    if not Root then 
        MainButton.Text = "キャラ未検出"
        return 
    end
    
    local spawnCFrame = Camera.CFrame * CFrame.new(0, 0, -5) 

    local args = {
        [1] = "PalletLightBrown",
        [2] = spawnCFrame, 
        [3] = Vector3.new(0, 0, 0),
    }

    local success, result = pcall(function()
        return SpawnRemote:InvokeServer(table.unpack(args))
    end)

    if success then
        MainButton.Text = "視線の先に生成！"
        MainButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    else
        MainButton.Text = "エラー！"
        MainButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end

    task.wait(0.5)
    MainButton.Text = "視線の先に板を生成"
    MainButton.BackgroundColor3 = Color3.fromRGB(150, 110, 80)
end)

print("板生成スクリプト（カメラ角度対応版）をロードしました。")
