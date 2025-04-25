local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerControlUI"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Create Frame with slightly opaque background and rounded corners
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 300)
frame.Position = UDim2.new(0.5, -100, 0.5, -150)
frame.BackgroundTransparency = 0.7 -- Slightly opaque
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
frame.Parent = screenGui

-- Add rounded corners to frame
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = frame

-- Make the frame draggable
local dragging = false
local dragStart = nil
local startPos = nil

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

frame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Function to create a button with press effect and rounded corners
local function createButton(name, position, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 180, 0, 50)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.Parent = frame
    button.Name = name
    
    -- Add rounded corners to button
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    -- Press effect (scale down and back)
    local function onClick()
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local scaleDown = TweenService:Create(button, tweenInfo, {Size = UDim2.new(0, 170, 0, 45)})
        local scaleUp = TweenService:Create(button, tweenInfo, {Size = UDim2.new(0, 180, 0, 50)})
        
        scaleDown:Play()
        scaleDown.Completed:Connect(function()
            scaleUp:Play()
        end)
        
        callback()
    end
    
    button.MouseButton1Click:Connect(onClick)
    return button
end

-- Function to make player invisible
local function makeInvisible()
    if player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = 1
            end
        end
        -- Keep HumanoidRootPart visible to avoid physics issues
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Transparency = 0
        end
    end
end

-- Function to increase player speed
local function increaseSpeed()
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = humanoid.WalkSpeed * 100
        end
    end
end

-- Function to highlight all players
local highlighting = false
local highlightConnection = nil
local function highlightPlayers()
    if highlighting then
        return -- Prevent multiple highlight loops
    end
    highlighting = true
    
    -- Function to apply highlights
    local function applyHighlights()
        -- Clear existing highlights
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                for _, child in ipairs(p.Character:GetChildren()) do
                    if child:IsA("Highlight") then
                        child:Destroy()
                    end
                end
            end
        end
        
        -- Add new highlights
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.fromRGB(255, 255, 0) -- Yellow highlight
                highlight.OutlineColor = Color3.fromRGB(255, 0, 0) -- Red outline
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = p.Character
                highlight.Parent = p.Character
            end
        end
    end
    
    applyHighlights() -- Initial highlight
    
    -- Refresh highlights every 5 seconds
    highlightConnection = spawn(function()
        while highlighting and screenGui.Parent do
            applyHighlights()
            wait(5)
        end
    end)
end

-- Function to stop highlighting
local function stopHighlighting()
    highlighting = false
    if highlightConnection then
        highlightConnection = nil
    end
    -- Clear all highlights
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            for _, child in ipairs(p.Character:GetChildren()) do
                if child:IsA("Highlight") then
                    child:Destroy()
                end
            end
        end
    end
end

-- Function to toggle highlighting
local function toggleHighlight()
    if highlighting then
        stopHighlighting()
    else
        highlightPlayers()
    end
end

-- Function to close UI
local function closeUI()
    stopHighlighting() -- Stop highlighting when closing
    screenGui:Destroy()
end

-- Create buttons
createButton("InvisibleButton", UDim2.new(0, 10, 0, 10), "Become Invisible", makeInvisible)
createButton("SpeedButton", UDim2.new(0, 10, 0, 70), "100x Speed", increaseSpeed)
createButton("HighlightButton", UDim2.new(0, 10, 0, 130), "Toggle Highlight", toggleHighlight)
createButton("CloseButton", UDim2.new(0, 10, 0, 190), "Close UI", closeUI)

-- Create username label
local usernameLabel = Instance.new("TextLabel")
usernameLabel.Size = UDim2.new(0, 180, 0, 30)
usernameLabel.Position = UDim2.new(0, 10, 0, 250)
usernameLabel.BackgroundTransparency = 1
usernameLabel.Text = "User: " .. player.Name
usernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
usernameLabel.Font = Enum.Font.SourceSans
usernameLabel.TextSize = 16
usernameLabel.Parent = frame
