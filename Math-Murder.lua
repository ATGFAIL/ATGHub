local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local workspace = game:GetService("Workspace")

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MathSolverUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Container
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 180, 0, 85)
mainContainer.Position = UDim2.new(0.5, -90, 0.05, 0)
mainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainContainer.BorderSizePixel = 0
mainContainer.ClipsDescendants = true
mainContainer.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainContainer

-- Animated Border
local border = Instance.new("UIStroke")
border.Color = Color3.fromRGB(138, 43, 226)
border.Thickness = 2
border.Parent = mainContainer

spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        local hue = tick() % 5 / 5
        border.Color = Color3.fromHSV(hue, 0.8, 1)
    end
end)

-- Header Bar
local headerBar = Instance.new("Frame")
headerBar.Name = "HeaderBar"
headerBar.Size = UDim2.new(1, 0, 0, 30)
headerBar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
headerBar.BorderSizePixel = 0
headerBar.Parent = mainContainer

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = headerBar

local headerCover = Instance.new("Frame")
headerCover.Size = UDim2.new(1, 0, 0, 15)
headerCover.Position = UDim2.new(0, 0, 1, -15)
headerCover.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
headerCover.BorderSizePixel = 0
headerCover.Parent = headerBar

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -50, 0, 20)
titleLabel.Position = UDim2.new(0, 5, 0, 3)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "ATG Hub"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 12
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = headerBar

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 45, 0, 22)
toggleButton.Position = UDim2.new(1, -50, 0, 4)
toggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "ON"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 10
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = headerBar

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 5)
toggleCorner.Parent = toggleButton

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -10, 1, -40)
contentFrame.Position = UDim2.new(0, 5, 0, 35)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainContainer

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, 0, 0, 15)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "⚡ Ready"
statusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
statusLabel.TextSize = 10
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = contentFrame

-- Question Label
local questionLabel = Instance.new("TextLabel")
questionLabel.Name = "Question"
questionLabel.Size = UDim2.new(1, 0, 0, 12)
questionLabel.Position = UDim2.new(0, 0, 0, 17)
questionLabel.BackgroundTransparency = 1
questionLabel.Text = "❓ Waiting..."
questionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
questionLabel.TextSize = 9
questionLabel.Font = Enum.Font.Gotham
questionLabel.TextXAlignment = Enum.TextXAlignment.Left
questionLabel.Parent = contentFrame

-- Answer Label
local answerLabel = Instance.new("TextLabel")
answerLabel.Name = "Answer"
answerLabel.Size = UDim2.new(1, 0, 0, 12)
answerLabel.Position = UDim2.new(0, 0, 0, 31)
answerLabel.BackgroundTransparency = 1
answerLabel.Text = "N/A"
answerLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
answerLabel.TextSize = 9
answerLabel.Font = Enum.Font.GothamBold
answerLabel.TextXAlignment = Enum.TextXAlignment.Left
answerLabel.Parent = contentFrame

-- Drag
local dragging, dragStart, startPos

headerBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainContainer.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService = game:GetService("UserInputService")
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainContainer.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Toggle
local isEnabled = true
toggleButton.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    if isEnabled then
        toggleButton.Text = "ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        toggleButton.Text = "OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

-- CACHED PATHS
local screenPath
local questionTextObj
local gameEvent
local lastQuestion = ""

-- SOLVE (INSTANT)
local function solve(q)
    local c = q:gsub("%s+", ""):gsub("[xX]", "*")
    local e = c:match("(.+)=")
    if not e then return nil end
    
    local n1, n2
    
    n1, n2 = e:match("(%d+)/(%d+)")
    if n1 then return tostring(math.floor(tonumber(n1) / tonumber(n2))) end
    
    n1, n2 = e:match("(%d+)%*(%d+)")
    if n1 then return tostring(tonumber(n1) * tonumber(n2)) end
    
    n1, n2 = e:match("(%d+)%+(%d+)")
    if n1 then return tostring(tonumber(n1) + tonumber(n2)) end
    
    n1, n2 = e:match("(%d+)%-(%d+)")
    if n1 then return tostring(tonumber(n1) - tonumber(n2)) end
    
    return nil
end

-- HEARTBEAT MONITOR (ULTRA FAST)
RunService.Heartbeat:Connect(function()
    if not isEnabled then return end
    
    -- Cache paths once
    if not screenPath then
        screenPath = workspace:FindFirstChild("Map")
        if screenPath then
            screenPath = screenPath:FindFirstChild("Functional")
            if screenPath then
                screenPath = screenPath:FindFirstChild("Screen")
                if screenPath then
                    screenPath = screenPath:FindFirstChild("SurfaceGui")
                    if screenPath then
                        screenPath = screenPath:FindFirstChild("MainFrame")
                        if screenPath then
                            screenPath = screenPath:FindFirstChild("MainGameContainer")
                            if screenPath then
                                screenPath = screenPath:FindFirstChild("MainTxtContainer")
                            end
                        end
                    end
                end
            end
        end
    end
    
    if not screenPath then return end
    
    -- Cache question object
    if not questionTextObj then
        questionTextObj = screenPath:FindFirstChild("QuestionText")
    end
    
    if not questionTextObj then return end
    
    local txt = questionTextObj.Text
    if txt == "" or txt == lastQuestion then return end
    
    lastQuestion = txt
    
    questionLabel.Text = "❓ " .. (txt:len() > 30 and txt:sub(1, 27) .. "..." or txt)
    
    local ans = solve(txt)
    
    if ans then
        answerLabel.Text = "✓ " .. ans
        answerLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
        statusLabel.Text = "⚡ SUBMIT"
        
        -- Cache event
        if not gameEvent then
            local evt = ReplicatedStorage:FindFirstChild("Events")
            if evt then
                gameEvent = evt:FindFirstChild("GameEvent")
            end
        end
        
        if gameEvent then
            gameEvent:FireServer("updateAnswer", ans)
            gameEvent:FireServer("submitAnswer", ans)
        end
    else
        answerLabel.Text = "✗ FAIL"
        answerLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        statusLabel.Text = "⚠ ERROR"
    end
end)

statusLabel.Text = "⚡ SCANNING"
