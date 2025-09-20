--// WhaleHub
--// By aoitempest

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Main UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WhaleHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0,950,0,600)
Main.Position = UDim2.new(0.03,0,0.05,0)
Main.BackgroundColor3 = Color3.fromRGB(10,10,10)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,220,1,0)
Sidebar.Position = UDim2.new(0,0,0,0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15,15,15)
Sidebar.Parent = Main

local TabHolder = Instance.new("Frame")
TabHolder.Size = UDim2.new(1,-220,1,0)
TabHolder.Position = UDim2.new(0,220,0,0)
TabHolder.BackgroundColor3 = Color3.fromRGB(20,20,20)
TabHolder.Parent = Main

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(0,900,0,150)
Header.Position = UDim2.new(0,0,0,0)
Header.BackgroundTransparency = 1
Header.Parent = Main

local MainTitle = Instance.new("TextLabel")
MainTitle.Text = "WhaleHub: Blox Fruit"
MainTitle.Font = Enum.Font.GothamBold
MainTitle.TextSize = 30
MainTitle.TextColor3 = Color3.fromRGB(255,255,255)
MainTitle.BackgroundTransparency = 1
MainTitle.Size = UDim2.new(1,0,0.6,0)
MainTitle.TextXAlignment = Enum.TextXAlignment.Left
MainTitle.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Text = "by aoitempest"
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 18
SubTitle.TextColor3 = Color3.fromRGB(200,200,200)
SubTitle.BackgroundTransparency = 1
SubTitle.Size = UDim2.new(1,0,0.4,0)
SubTitle.Position = UDim2.new(0,0,0.6,0)
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

-- Logo outside
local LogoButton = Instance.new("ImageButton")
LogoButton.Size = UDim2.new(0,70,0,70)
LogoButton.Position = UDim2.new(0,20,0,160)
LogoButton.Image = "rbxassetid://135937136167463"
LogoButton.BackgroundColor3 = Color3.fromRGB(30,30,30)
LogoButton.BorderSizePixel = 0
LogoButton.Parent = PlayerGui

-- Toggle UI
local Visible = true
LogoButton.MouseButton1Click:Connect(function()
    Visible = not Visible
    Main.Visible = Visible
end)

-- Drag UI
local dragging, dragStart, startPos
local function startDrag(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true
        dragStart=input.Position
        startPos=Main.Position
    end
end
local function drag(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-dragStart
        Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,
                                startPos.Y.Scale,startPos.Y.Offset+delta.Y)
    end
end
local function stopDrag(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=false
    end
end
Header.InputBegan:Connect(startDrag)
LogoButton.InputBegan:Connect(startDrag)
Header.InputChanged:Connect(drag)
LogoButton.InputChanged:Connect(drag)
UserInputService.InputEnded:Connect(stopDrag)

-- Hotkey toggle
local Hotkeys = {Enum.KeyCode.RightAlt, Enum.KeyCode.A}
UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    for _,key in ipairs(Hotkeys) do
        if input.KeyCode==key then
            Visible=not Visible
            Main.Visible=Visible
        end
    end
end)

-- Function to create Tabs with smooth Tween animation
local function AddTab(title,url)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1,-10,0,60)
    Button.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Button.Text = title
    Button.TextColor3 = Color3.fromRGB(255,255,255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 18
    Button.BorderSizePixel = 1
    Button.BorderColor3 = Color3.fromRGB(60,60,60)
    Button.Parent = Sidebar

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1,0,1,0)
    Frame.Position = UDim2.new(1,0,0,0) -- offscreen right
    Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    Frame.Visible = false
    Frame.Parent = TabHolder

    if url then
        local BtnExec = Instance.new("TextButton")
        BtnExec.Size = UDim2.new(0,300,0,50)
        BtnExec.Position = UDim2.new(0,10,0,10)
        BtnExec.BackgroundColor3 = Color3.fromRGB(50,50,50)
        BtnExec.BorderSizePixel = 1
        BtnExec.BorderColor3 = Color3.fromRGB(80,80,80)
        BtnExec.Text = "Execute "..title
        BtnExec.TextColor3 = Color3.fromRGB(255,255,255)
        BtnExec.Font = Enum.Font.GothamBold
        BtnExec.TextSize = 18
        BtnExec.Parent = Frame
        BtnExec.MouseButton1Click:Connect(function()
            loadstring(game:HttpGet(url))()
        end)
    end

    Button.MouseButton1Click:Connect(function()
        for _,tab in ipairs(TabHolder:GetChildren()) do
            if tab:IsA("Frame") then
                if tab.Visible then
                    local tweenOut = TweenService:Create(tab, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position=UDim2.new(1,0,0,0)})
                    tweenOut:Play()
                    tweenOut.Completed:Connect(function() tab.Visible=false end)
                end
            end
        end
        Frame.Visible=true
        TweenService:Create(Frame,TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position=UDim2.new(0,0,0,0)}):Play()
    end)

    -- Hover effect
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(50,50,50)}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(35,35,35)}):Play()
    end)
end

-- Tabs
local tabs = {
    {Title="Auto Farm",URL="https://raw.githubusercontent.com/tlredz/Scripts/refs/heads/main/main.luau"},
    {Title="Teleport",URL="https://raw.githubusercontent.com/tlredz/Scripts/refs/heads/main/main.luau"},
    {Title="Shop",URL="https://raw.githubusercontent.com/tlredz/Scripts/refs/heads/main/main.luau"},
    {Title="Stats",URL="https://raw.githubusercontent.com/tlredz/Scripts/refs/heads/main/main.luau"},
    {Title="Visual",URL="https://raw.githubusercontent.com/tlredz/Scripts/refs/heads/main/main.luau"},
    {Title="Misc",URL="https://raw.githubusercontent.com/tlredz/Scripts/refs/heads/main/main.luau"}
}

for _, tab in ipairs(tabs) do
    AddTab(tab.Title, tab.URL)
end
