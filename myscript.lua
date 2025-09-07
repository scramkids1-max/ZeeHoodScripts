-- Zee Hood ESP and Aimbot Script for Loadstring
return function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = game:GetService("Workspace").CurrentCamera
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    -- ESP Settings
    local ESP_ENABLED = true
    local ESP_COLOR = Color3.new(1, 0, 0) -- Red for visibility
    local ESP_DISTANCE = 1000 -- Max distance for ESP

    -- Aimbot Settings
    local AIMBOT_ENABLED = true
    local AIMBOT_KEY = Enum.UserInputType.MouseButton2 -- Right mouse button to activate
    local AIMBOT_FOV = 100 -- Field of view for aimbot
    local AIMBOT_SMOOTHNESS = 0.1 -- Smoothing factor for aimbot

    -- ESP Function
    local function createESP(player)
        if player == LocalPlayer or not ESP_ENABLED then return end
        local character = player.Character
        if not character or not character:FindFirstChild("Head") then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = character.Head
        billboard.Size = UDim2.new(0, 50, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Name = "ESP"

        local frame = Instance.new("Frame", billboard)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = ESP_COLOR
        frame.BackgroundTransparency = 0.5

        local nameLabel = Instance.new("TextLabel", billboard)
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.Position = UDim2.new(0, 0, -0.5, 0)
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextScaled = true

        billboard.Parent = character.Head
    end

    -- Aimbot Function
    local function getClosestPlayer()
        local closestPlayer = nil
        local closestDistance = AIMBOT_FOV
        local mousePos = UserInputService:GetMouseLocation()

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local head = player.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
        return closestPlayer
    end

    -- Aimbot Logic
    local aiming = false
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == AIMBOT_KEY and AIMBOT_ENABLED then
            aiming = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == AIMBOT_KEY then
            aiming = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if aiming and AIMBOT_ENABLED then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local headPos = target.Character.Head.Position
                local cameraPos = Camera.CFrame.Position
                local direction = (headPos - cameraPos).Unit
                local newCFrame = CFrame.new(cameraPos, cameraPos + direction)
                Camera.CFrame = Camera.CFrame:Lerp(newCFrame, AIMBOT_SMOOTHNESS)
            end
        end
    end)

    -- ESP for all players
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            createESP(player)
        end)
    end)

    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            createESP(player)
        end
    end)

    -- Remove ESP when player leaves
    Players.PlayerRemoving:Connect(function(player)
        if player.Character and player.Character:FindFirstChild("Head") then
            local esp = player.Character.Head:FindFirstChild("ESP")
            if esp then
                esp:Destroy()
            end
        end
    end)

    print("Zee Hood ESP and Aimbot loaded successfully!")
end