local NotificationLibrary = {}
NotificationLibrary.__index = NotificationLibrary

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local CONFIG = {
    ANIMATION_SPEED = 0.3,
    DEFAULT_DURATION = 5,
    CORNER_RADIUS = UDim.new(0, 8),
    THEME = {
        DARK = Color3.fromRGB(35, 35, 35),
        TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
        TEXT_SECONDARY = Color3.fromRGB(200, 200, 200),
        SUCCESS = Color3.fromRGB(76, 175, 80),
        WARNING = Color3.fromRGB(255, 193, 7),
        ERROR = Color3.fromRGB(244, 67, 54),
        INFO = Color3.fromRGB(33, 150, 243),
    },
    BUTTON_HOVER_TWEEN = {
        SCALE = Vector3.new(1.05, 1.05, 1.05),
        DURATION = 0.15,
    },
    BUTTON_CLICK_TWEEN = {
        SCALE = Vector3.new(0.95, 0.95, 0.95),
        DURATION = 0.1,
    },
    PULSE_EFFECT = {
        MIN_TRANSPARENCY = 0.7,
        MAX_TRANSPARENCY = 1,
        DURATION = 1.5
    },
    TEXT_APPEAR_DELAY = 0.2,
    RIPPLE_EFFECT_DURATION = 0.6
}

function NotificationLibrary:Init()
    local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    if PlayerGui:FindFirstChild("NotificationContainer") then
        return PlayerGui.NotificationContainer
    end

    local NotificationContainer = Instance.new("ScreenGui")
    NotificationContainer.Name = "NotificationContainer"
    NotificationContainer.ResetOnSpawn = false
    NotificationContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local NotificationsFrame = Instance.new("Frame")
    NotificationsFrame.Name = "NotificationsFrame"
    NotificationsFrame.AnchorPoint = Vector2.new(1, 0)
    NotificationsFrame.BackgroundTransparency = 1
    NotificationsFrame.Position = UDim2.new(0.98, 0, 0.02, 0)
    NotificationsFrame.Size = UDim2.new(0, 300, 1, -40)
    NotificationsFrame.Parent = NotificationContainer

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Name = "ListLayout"
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    ListLayout.Parent = NotificationsFrame

    NotificationContainer.Parent = PlayerGui
    return NotificationContainer
end

function NotificationLibrary:CreateRippleEffect(parent, x, y, color)

    local ripple = Instance.new("Frame")
    ripple.Name = "RippleEffect"
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.ZIndex = 2

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0) 
    corner.Parent = ripple

    ripple.Parent = parent

    local targetSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    local tweenInfo = TweenInfo.new(CONFIG.RIPPLE_EFFECT_DURATION, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    local sizeTween = TweenService:Create(ripple, tweenInfo, {
        Size = UDim2.new(0, targetSize, 0, targetSize),
        BackgroundTransparency = 1
    })

    sizeTween:Play()

    task.delay(CONFIG.RIPPLE_EFFECT_DURATION, function()
        if ripple and ripple.Parent then
            ripple:Destroy()
        end
    end)
end

function NotificationLibrary:Notify(options)
    local container = self:Init()
    local notificationsFrame = container.NotificationsFrame

    options = options or {}
    local title = options.Title or "Notification"
    local text = options.Text or ""
    local duration = options.Duration or CONFIG.DEFAULT_DURATION
    local notificationType = options.Type or "Info" 
    local callback = options.Callback
    local closeOnClick = options.CloseOnClick
    if closeOnClick == nil then closeOnClick = true end

    local typeColor
    if notificationType == "Success" then
        typeColor = CONFIG.THEME.SUCCESS
    elseif notificationType == "Warning" then
        typeColor = CONFIG.THEME.WARNING
    elseif notificationType == "Error" then
        typeColor = CONFIG.THEME.ERROR
    else
        typeColor = CONFIG.THEME.INFO
    end

    local notificationFrame = Instance.new("Frame")
    notificationFrame.Name = "Notification_" .. title:gsub("%s+", "_")
    notificationFrame.BackgroundColor3 = CONFIG.THEME.DARK
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Size = UDim2.new(1, 0, 0, 90)
    notificationFrame.ClipsDescendants = true  
    notificationFrame.BackgroundTransparency = 0.1
    notificationFrame.AnchorPoint = Vector2.new(0.5, 0)
    notificationFrame.Position = UDim2.new(1.5, 0, 0, 0) 

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(55, 55, 55)),
        ColorSequenceKeypoint.new(1, CONFIG.THEME.DARK)
    })
    gradient.Rotation = 45
    gradient.Parent = notificationFrame

    task.spawn(function()
        local rotationDirection = 1
        local rotationSpeed = 15 

        while notificationFrame and notificationFrame.Parent do
            gradient.Rotation = (gradient.Rotation + rotationDirection * rotationSpeed * RunService.Heartbeat:Wait()) % 360
            if math.random(1, 1000) == 1 then  
                rotationDirection = -rotationDirection
            end
            task.wait(0.1)
        end
    end)

    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = CONFIG.CORNER_RADIUS
    cornerRadius.Parent = notificationFrame

    local glowBorder = Instance.new("UIStroke")
    glowBorder.Name = "GlowBorder"
    glowBorder.Color = typeColor
    glowBorder.Thickness = 1.5
    glowBorder.Transparency = 0.6
    glowBorder.Parent = notificationFrame

    task.spawn(function()
        while notificationFrame and notificationFrame.Parent do
            local pulseInfo = TweenInfo.new(
                CONFIG.PULSE_EFFECT.DURATION, 
                Enum.EasingStyle.Sine, 
                Enum.EasingDirection.InOut, 
                -1, 
                true 
            )

            local pulseTween = TweenService:Create(glowBorder, pulseInfo, {
                Transparency = CONFIG.PULSE_EFFECT.MIN_TRANSPARENCY
            })

            pulseTween:Play()

            repeat task.wait(0.5) until not (notificationFrame and notificationFrame.Parent)
            pulseTween:Cancel()
            break
        end
    end)

    local typeBorder = Instance.new("Frame")
    typeBorder.Name = "TypeBorder"
    typeBorder.BackgroundColor3 = typeColor
    typeBorder.BorderSizePixel = 0
    typeBorder.Size = UDim2.new(0, 4, 1, 0)
    typeBorder.Position = UDim2.new(0, 0, 0, 0)
    typeBorder.Parent = notificationFrame

    local accentGlow = Instance.new("ImageLabel")
    accentGlow.Name = "AccentGlow"
    accentGlow.BackgroundTransparency = 1
    accentGlow.Size = UDim2.new(0, 20, 1, 0)
    accentGlow.Position = UDim2.new(0, 0, 0, 0)
    accentGlow.Image = "rbxassetid://131426127" 
    accentGlow.ImageColor3 = typeColor
    accentGlow.ImageTransparency = 0.7
    accentGlow.ZIndex = 0
    accentGlow.Parent = notificationFrame

    local iconContainer = Instance.new("Frame")
    iconContainer.Name = "IconContainer"
    iconContainer.BackgroundTransparency = 1
    iconContainer.Position = UDim2.new(0, 16, 0, 16)
    iconContainer.Size = UDim2.new(0, 24, 0, 24)
    iconContainer.Parent = notificationFrame

    local statusIcon = Instance.new("ImageLabel")
    statusIcon.Name = "StatusIcon"
    statusIcon.BackgroundTransparency = 1
    statusIcon.Size = UDim2.new(1, 0, 1, 0)
    statusIcon.ImageTransparency = 1 

    if notificationType == "Success" then
        statusIcon.Image = "rbxassetid://7733715400" 
    elseif notificationType == "Warning" then
        statusIcon.Image = "rbxassetid://7733658271" 
    elseif notificationType == "Error" then
        statusIcon.Image = "rbxassetid://7743878358" 
    else
        statusIcon.Image = "rbxassetid://140353058114962" 
    end

    statusIcon.ImageColor3 = typeColor
    statusIcon.Parent = iconContainer

    local iconGlow = statusIcon:Clone()
    iconGlow.Name = "IconGlow"
    iconGlow.ImageTransparency = 0.7
    iconGlow.Size = UDim2.new(1.5, 0, 1.5, 0)
    iconGlow.Position = UDim2.new(-0.25, 0, -0.25, 0)
    iconGlow.ZIndex = statusIcon.ZIndex - 1
    iconGlow.Parent = iconContainer

    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.BackgroundTransparency = 1
    titleText.Position = UDim2.new(0, 50, 0, 14)
    titleText.Size = UDim2.new(1, -100, 0, 24)
    titleText.Font = Enum.Font.GothamBold
    titleText.Text = title
    titleText.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
    titleText.TextSize = 16
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.TextTransparency = 1 
    titleText.Parent = notificationFrame

    local messageText = Instance.new("TextLabel")
    messageText.Name = "Message"
    messageText.BackgroundTransparency = 1
    messageText.Position = UDim2.new(0, 50, 0, 38)
    messageText.Size = UDim2.new(1, -70, 0, 36)
    messageText.Font = Enum.Font.Gotham
    messageText.Text = text
    messageText.TextColor3 = CONFIG.THEME.TEXT_SECONDARY
    messageText.TextSize = 14
    messageText.TextWrapped = true
    messageText.TextXAlignment = Enum.TextXAlignment.Left
    messageText.TextYAlignment = Enum.TextYAlignment.Top
    messageText.TextTransparency = 1 
    messageText.Parent = notificationFrame

    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.BackgroundTransparency = 1
    closeButton.Position = UDim2.new(1, -32, 0, 14)
    closeButton.Size = UDim2.new(0, 18, 0, 18)
    closeButton.Image = "rbxassetid://7733717646" 
    closeButton.ImageColor3 = CONFIG.THEME.TEXT_SECONDARY
    closeButton.ImageTransparency = 1 
    closeButton.Parent = notificationFrame

    closeButton.MouseEnter:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {
            ImageColor3 = typeColor
        }):Play()
    end)

    closeButton.MouseLeave:Connect(function()
        TweenService:Create(closeButton, TweenInfo.new(0.2), {
            ImageColor3 = CONFIG.THEME.TEXT_SECONDARY
        }):Play()
    end)

    local shadowEffect = Instance.new("ImageLabel")
    shadowEffect.Name = "Shadow"
    shadowEffect.BackgroundTransparency = 1
    shadowEffect.Size = UDim2.new(1, 20, 1, 20)
    shadowEffect.Position = UDim2.new(0, -10, 0, 5)
    shadowEffect.ZIndex = -1
    shadowEffect.Image = "rbxassetid://7912134082" 
    shadowEffect.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadowEffect.ImageTransparency = 0.7
    shadowEffect.ScaleType = Enum.ScaleType.Slice
    shadowEffect.SliceCenter = Rect.new(25, 25, 65, 65)
    shadowEffect.Parent = notificationFrame

    task.spawn(function()
        while notificationFrame and notificationFrame.Parent do
            local floatInfo = TweenInfo.new(
                2, 
                Enum.EasingStyle.Sine, 
                Enum.EasingDirection.InOut, 
                -1, 
                true 
            )

            local floatTween = TweenService:Create(shadowEffect, floatInfo, {
                Position = UDim2.new(0, -10, 0, 8)
            })

            floatTween:Play()

            repeat task.wait(0.5) until not (notificationFrame and notificationFrame.Parent)
            floatTween:Cancel()
            break
        end
    end)

    local progressBarContainer = Instance.new("Frame")
    progressBarContainer.Name = "ProgressBarContainer"
    progressBarContainer.BackgroundTransparency = 1
    progressBarContainer.Size = UDim2.new(1, 0, 0, 3)
    progressBarContainer.Position = UDim2.new(0, 0, 1, -3)
    progressBarContainer.Parent = notificationFrame

    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.BackgroundColor3 = typeColor
    progressBar.BorderSizePixel = 0
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.Parent = progressBarContainer

    local progressGradient = Instance.new("UIGradient")
    progressGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, typeColor),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(
            math.min(typeColor.R * 1.3 * 255, 255),
            math.min(typeColor.G * 1.3 * 255, 255),
            math.min(typeColor.B * 1.3 * 255, 255)
        )),
        ColorSequenceKeypoint.new(1, typeColor)
    })
    progressGradient.Parent = progressBar

    local progressGlow = Instance.new("Frame")
    progressGlow.Name = "ProgressGlow"
    progressGlow.BackgroundColor3 = typeColor
    progressGlow.BackgroundTransparency = 0.7
    progressGlow.BorderSizePixel = 0
    progressGlow.Size = UDim2.new(1, 0, 0, 6)
    progressGlow.Position = UDim2.new(0, 0, 0, -3)
    progressGlow.ZIndex = progressBar.ZIndex - 1
    progressGlow.Parent = progressBar

    local progressGlowCorner = Instance.new("UICorner")
    progressGlowCorner.CornerRadius = UDim.new(1, 0)
    progressGlowCorner.Parent = progressGlow

    task.spawn(function()
        while progressBar and progressBar.Parent do
            local offset = 0
            local moveSpeed = 1 

            while true do
                offset = (offset + 0.01) % 1
                progressGradient.Offset = Vector2.new(offset, 0)

                if not (progressBar and progressBar.Parent) then
                    break
                end

                task.wait(moveSpeed / 100)
            end

            break
        end
    end)

    notificationFrame.Parent = notificationsFrame

    local entranceTweenInfo = TweenInfo.new(CONFIG.ANIMATION_SPEED, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local exitTweenInfo = TweenInfo.new(CONFIG.ANIMATION_SPEED, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    local progressTweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local elementAppearInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    local entranceTween = TweenService:Create(notificationFrame, entranceTweenInfo, {
        Position = UDim2.new(0.5, 0, 0, 0)
    })

    local progressTween = TweenService:Create(progressBar, progressTweenInfo, {
        Size = UDim2.new(0, 0, 1, 0)
    })

    local exitTween = TweenService:Create(notificationFrame, exitTweenInfo, {
        Position = UDim2.new(1.5, 0, 0, 0)
    })

    local iconAppearTween = TweenService:Create(statusIcon, elementAppearInfo, {
        ImageTransparency = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0)
    })

    local titleAppearTween = TweenService:Create(titleText, elementAppearInfo, {
        TextTransparency = 0,
        Position = UDim2.new(0, 50, 0, 14)
    })

    local messageAppearTween = TweenService:Create(messageText, elementAppearInfo, {
        TextTransparency = 0,
        Position = UDim2.new(0, 50, 0, 38)
    })

    local closeAppearTween = TweenService:Create(closeButton, elementAppearInfo, {
        ImageTransparency = 0
    })

    statusIcon.Size = UDim2.new(0.5, 0, 0.5, 0)
    statusIcon.Position = UDim2.new(0.25, 0, 0.25, 0)
    titleText.Position = UDim2.new(0, 70, 0, 14)
    messageText.Position = UDim2.new(0, 70, 0, 38)

    local function applyThoccyEffect(object, isHovering)
        local targetY = isHovering and -5 or 0
        local targetSize = isHovering and UDim2.new(1, 0, 0, 95) or UDim2.new(1, 0, 0, 90)
        local duration = isHovering and CONFIG.BUTTON_HOVER_TWEEN.DURATION or CONFIG.BUTTON_HOVER_TWEEN.DURATION

        local buttonTween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Back), {
            Size = targetSize,
            Position = UDim2.new(0.5, 0, 0, targetY)
        })

        local shadowTween = TweenService:Create(shadowEffect, TweenInfo.new(duration, Enum.EasingStyle.Quart), {
            ImageTransparency = isHovering and 0.5 or 0.7,
            Size = isHovering and UDim2.new(1, 30, 1, 30) or UDim2.new(1, 20, 1, 20)
        })

        local glowTween = TweenService:Create(glowBorder, TweenInfo.new(duration, Enum.EasingStyle.Quart), {
            Transparency = isHovering and 0.3 or 0.6
        })

        buttonTween:Play()
        shadowTween:Play()
        glowTween:Play()
    end

    notificationFrame.InputBegan:Connect(function(input)
        local MouseLocation = game:GetService("UserInputService"):GetMouseLocation()
        local RelativePosition = Vector2.new(
            MouseLocation.X - notificationFrame.AbsolutePosition.X,
            MouseLocation.Y - notificationFrame.AbsolutePosition.Y
        )

        if input.UserInputType == Enum.UserInputType.MouseButton1 then

            self:CreateRippleEffect(notificationFrame, RelativePosition.X, RelativePosition.Y, typeColor)

            if callback then
                callback()
            end

            if closeOnClick then
                progressTween:Cancel()

                local fadeOutInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

                local iconFadeOut = TweenService:Create(statusIcon, fadeOutInfo, {
                    ImageTransparency = 1
                })

                local titleFadeOut = TweenService:Create(titleText, fadeOutInfo, {
                    TextTransparency = 1
                })

                local messageFadeOut = TweenService:Create(messageText, fadeOutInfo, {
                    TextTransparency = 1
                })

                iconFadeOut:Play()
                titleFadeOut:Play()
                messageFadeOut:Play()

                task.delay(0.2, function()
                    exitTween:Play()
                    exitTween.Completed:Wait()
                    if notificationFrame and notificationFrame.Parent then
                        notificationFrame:Destroy()
                    end
                end)
            end
        end
    end)

    closeButton.MouseButton1Click:Connect(function()
        progressTween:Cancel()

        self:CreateRippleEffect(notificationFrame, closeButton.AbsolutePosition.X, closeButton.AbsolutePosition.Y, typeColor)

        local fadeOutInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        local iconFadeOut = TweenService:Create(statusIcon, fadeOutInfo, {
            ImageTransparency = 1,
            Size = UDim2.new(0.5, 0, 0.5, 0),
            Position = UDim2.new(0.25, 0, 0.25, 0)
        })

        local titleFadeOut = TweenService:Create(titleText, fadeOutInfo, {
            TextTransparency = 1,
            Position = UDim2.new(0, 70, 0, 14)
        })

        local messageFadeOut = TweenService:Create(messageText, fadeOutInfo, {
            TextTransparency = 1,
            Position = UDim2.new(0, 70, 0, 38)
        })

        iconFadeOut:Play()
        titleFadeOut:Play()
        messageFadeOut:Play()

        task.delay(0.2, function()
            exitTween:Play()
            exitTween.Completed:Wait()
            if notificationFrame and notificationFrame.Parent then
                notificationFrame:Destroy()
            end
        end)
    end)

    entranceTween:Play()
    entranceTween.Completed:Connect(function()

        iconAppearTween:Play()

        task.delay(CONFIG.TEXT_APPEAR_DELAY, function()
            titleAppearTween:Play()
        end)

        task.delay(CONFIG.TEXT_APPEAR_DELAY * 2, function()
            messageAppearTween:Play()
        end)

        task.delay(CONFIG.TEXT_APPEAR_DELAY * 3, function()
            closeAppearTween:Play()
            progressTween:Play()
        end)
    end)

    task.spawn(function()
        if duration > 0 then
            task.wait(duration)

            if notificationFrame and notificationFrame.Parent then

                local fadeOutInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

                local iconFadeOut = TweenService:Create(statusIcon, fadeOutInfo, {
                    ImageTransparency = 1,
                    Size = UDim2.new(0.5, 0, 0.5, 0),
                    Position = UDim2.new(0.25, 0, 0.25, 0)
                })

                local titleFadeOut = TweenService:Create(titleText, fadeOutInfo, {
                    TextTransparency = 1,
                    Position = UDim2.new(0, 70, 0, 14)
                })

                local messageFadeOut = TweenService:Create(messageText, fadeOutInfo, {
                    TextTransparency = 1,
                    Position = UDim2.new(0, 70, 0, 38)
                })

                local closeButtonFadeOut = TweenService:Create(closeButton, fadeOutInfo, {
                    ImageTransparency = 1
                })

                iconFadeOut:Play()
                titleFadeOut:Play()
                messageFadeOut:Play()
                closeButtonFadeOut:Play()

                task.delay(0.2, function()
                    exitTween:Play()
                    exitTween.Completed:Wait()
                    if notificationFrame and notificationFrame.Parent then
                        notificationFrame:Destroy()
                    end
                end)
            end
        end
    end)

    return {
        Frame = notificationFrame,
        Close = function()
            if notificationFrame and notificationFrame.Parent then
                progressTween:Cancel()
                exitTween:Play()
                exitTween.Completed:Wait()
                notificationFrame:Destroy()
            end
        end,
        Update = function(newOptions)
            if notificationFrame and notificationFrame.Parent then
                if newOptions.Title then
                    titleText.Text = newOptions.Title
                end
                if newOptions.Text then
                    messageText.Text = newOptions.Text
                end
                if newOptions.Duration then

                    progressTween:Cancel()
                    progressBar.Size = UDim2.new(1, 0, 1, 0)
                    progressTween = TweenService:Create(progressBar, TweenInfo.new(newOptions.Duration, Enum.EasingStyle.Linear), {
                        Size = UDim2.new(0, 0, 1, 0)
                    })
                    progressTween:Play()
                end
            end
        end
    }
end

function NotificationLibrary:Notif(title, text, duration, type, callback)
    return self:Notify({
        Title = title,
        Text = text,
        Duration = duration,
        Type = type or "Info", 
        Callback = callback
    })
end

function NotificationLibrary:Toast(text, duration, notificationType)
    return self:Notify({
        Title = "",
        Text = text,
        Duration = duration or 3,
        Type = notificationType or "Info",
        CloseOnClick = true
    })
end

function NotificationLibrary:Confirm(options)
    local title = options.Title or "Confirmation"
    local text = options.Text or "Are you sure?"
    local duration = options.Duration or 0 
    local onYes = options.OnYes or function() end
    local onNo = options.OnNo or function() end
    local yesText = options.YesText or "Yes"
    local noText = options.NoText or "No"

    local notification = self:Notify({
        Title = title,
        Text = text,
        Duration = duration,
        Type = "Info",
        CloseOnClick = false
    })

    local notificationFrame = notification.Frame

    TweenService:Create(notificationFrame, TweenInfo.new(0.2), {
        Size = UDim2.new(1, 0, 0, 120)
    }):Play()

    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Size = UDim2.new(1, -60, 0, 32)
    buttonContainer.Position = UDim2.new(0, 50, 0, 80)
    buttonContainer.Parent = notificationFrame

    local yesButton = Instance.new("TextButton")
    yesButton.Name = "YesButton"
    yesButton.Size = UDim2.new(0.48, 0, 1, 0)
    yesButton.Position = UDim2.new(0, 0, 0, 0)
    yesButton.BackgroundColor3 = CONFIG.THEME.SUCCESS
    yesButton.BorderSizePixel = 0
    yesButton.Font = Enum.Font.GothamBold
    yesButton.Text = yesText
    yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    yesButton.TextSize = 14
    yesButton.AutoButtonColor = false
    yesButton.ClipsDescendants = true 
    yesButton.Parent = buttonContainer

    local noButton = Instance.new("TextButton")
    noButton.Name = "NoButton"
    noButton.Size = UDim2.new(0.48, 0, 1, 0)
    noButton.Position = UDim2.new(0.52, 0, 0, 0)
    noButton.BackgroundColor3 = CONFIG.THEME.ERROR
    noButton.BorderSizePixel = 0
    noButton.Font = Enum.Font.GothamBold
    noButton.Text = noText
    noButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    noButton.TextSize = 14
    noButton.AutoButtonColor = false
    noButton.ClipsDescendants = true 
    noButton.Parent = buttonContainer

    local yesCorner = Instance.new("UICorner")
    yesCorner.CornerRadius = CONFIG.CORNER_RADIUS
    yesCorner.Parent = yesButton

    local noCorner = Instance.new("UICorner")
    noCorner.CornerRadius = CONFIG.CORNER_RADIUS
    noCorner.Parent = noButton

    local function setupButtonEffects(button, color)
        button.MouseEnter:Connect(function()
            local hoverTween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Size = UDim2.new(0.48, 0, 1, -4),
                Position = UDim2.new(button.Position.X.Scale, 0, 0, -2)
            })
            hoverTween:Play()

            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(
                    math.min(color.R * 1.1 * 255, 255),
                    math.min(color.G * 1.1 * 255, 255),
                    math.min(color.B * 1.1 * 255, 255)
                )
            }):Play()
        end)

        button.MouseLeave:Connect(function()
            local resetTween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Size = UDim2.new(0.48, 0, 1, 0),
                Position = UDim2.new(button.Position.X.Scale, 0, 0, 0)
            })
            resetTween:Play()

            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = color
            }):Play()
        end)

        button.MouseButton1Down:Connect(function()
            local clickTween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0.48, 0, 1, -6),
                Position = UDim2.new(button.Position.X.Scale, 0, 0, 3)
            })
            clickTween:Play()

            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(
                    math.max(color.R * 0.9 * 255, 0),
                    math.max(color.G * 0.9 * 255, 0),
                    math.max(color.B * 0.9 * 255, 0)
                )
            }):Play()
        end)

        button.MouseButton1Up:Connect(function()
            local releaseTween = TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0.48, 0, 1, -4),
                Position = UDim2.new(button.Position.X.Scale, 0, 0, -2)
            })
            releaseTween:Play()

            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = color
            }):Play()
        end)
    end

    setupButtonEffects(yesButton, CONFIG.THEME.SUCCESS)
    setupButtonEffects(noButton, CONFIG.THEME.ERROR)

    yesButton.MouseButton1Click:Connect(function()

        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
        local buttonPos = yesButton.AbsolutePosition
        local relX = mousePos.X - buttonPos.X
        local relY = mousePos.Y - buttonPos.Y
        self:CreateRippleEffect(yesButton, relX, relY, Color3.fromRGB(255, 255, 255))

        task.spawn(onYes)

        notification.Close()
    end)

    noButton.MouseButton1Click:Connect(function()

        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
        local buttonPos = noButton.AbsolutePosition
        local relX = mousePos.X - buttonPos.X
        local relY = mousePos.Y - buttonPos.Y
        self:CreateRippleEffect(noButton, relX, relY, Color3.fromRGB(255, 255, 255))

        task.spawn(onNo)

        notification.Close()
    end)

    return notification
end

function NotificationLibrary:Input(options)
    local title = options.Title or "Input"
    local text = options.Text or "Please enter a value:"
    local type = options.Type or "Info"
    local inputType = options.InputType or "Text" 
    local placeholderText = options.PlaceholderText or "Enter value here..."
    local confirmText = options.ConfirmText or "Submit"
    local cancelText = options.CancelText or "Cancel"
    local onConfirm = options.OnConfirm or function() end
    local onCancel = options.OnCancel or function() end
    local defaultValue = options.DefaultValue or ""

    local notification = self:Notify({
        Title = title,
        Text = text,
        Duration = 0, 
        Type = type,
        CloseOnClick = false
    })

    local notificationFrame = notification.Frame

    TweenService:Create(notificationFrame, TweenInfo.new(0.2), {
        Size = UDim2.new(1, 0, 0, 175)
    }):Play()

    local inputContainer = Instance.new("Frame")
    inputContainer.Name = "InputContainer"
    inputContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    inputContainer.BorderSizePixel = 0
    inputContainer.Size = UDim2.new(1, -60, 0, 36)
    inputContainer.Position = UDim2.new(0, 50, 0, 80)
    inputContainer.Parent = notificationFrame

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = CONFIG.CORNER_RADIUS
    inputCorner.Parent = inputContainer

    local inputBox = Instance.new("TextBox")
    inputBox.Name = "InputBox"
    inputBox.BackgroundTransparency = 1
    inputBox.Size = UDim2.new(1, -20, 1, 0)
    inputBox.Position = UDim2.new(0, 10, 0, 0)
    inputBox.Font = Enum.Font.Gotham
    inputBox.PlaceholderText = placeholderText
    inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    inputBox.Text = defaultValue
    inputBox.TextColor3 = CONFIG.THEME.TEXT_PRIMARY
    inputBox.TextSize = 14
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.ClearTextOnFocus = false
    inputBox.MultiLine = false
    inputBox.TextWrapped = false
    inputBox.Parent = inputContainer

    local actualValue = defaultValue
    local isUpdatingText = false
    
    if inputType == "Password" then
        if defaultValue ~= "" then
            inputBox.Text = string.rep("•", #defaultValue)
        end
        
        inputBox.Changed:Connect(function(property)
            if property ~= "Text" or isUpdatingText then return end
            
            isUpdatingText = true
            local currentText = inputBox.Text
            local currentTextLen = #currentText
            local actualValueLen = #actualValue
            
            if currentTextLen > actualValueLen then
                local addedChars = string.sub(currentText, actualValueLen + 1)
                if not string.find(addedChars, "•") then
                    actualValue = actualValue .. addedChars
                    inputBox.Text = string.rep("•", #actualValue)
                end
            elseif currentTextLen < actualValueLen then
                actualValue = string.sub(actualValue, 1, currentTextLen)
                inputBox.Text = string.rep("•", #actualValue)
            end
            
            inputBox.CursorPosition = #inputBox.Text + 1
            isUpdatingText = false
        end)
    end

    if inputType == "Number" then
        inputBox.Changed:Connect(function(property)
            if property ~= "Text" or isUpdatingText then return end
            
            isUpdatingText = true
            local newText = string.gsub(inputBox.Text, "[^%d%.]", "")
            
            local dotCount = 0
            for i = 1, #newText do
                if string.sub(newText, i, i) == "." then
                    dotCount = dotCount + 1
                    if dotCount > 1 then
                        newText = string.sub(newText, 1, i-1) .. string.sub(newText, i+1)
                        dotCount = dotCount - 1
                    end
                end
            end
            
            if newText ~= inputBox.Text then
                local cursorPosition = inputBox.CursorPosition
                inputBox.Text = newText
                inputBox.CursorPosition = cursorPosition
            end
            
            isUpdatingText = false
        end)
    end

    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Size = UDim2.new(1, -60, 0, 32)
    buttonContainer.Position = UDim2.new(0, 50, 0, 125)
    buttonContainer.Parent = notificationFrame

    local confirmButton = Instance.new("TextButton")
    confirmButton.Name = "ConfirmButton"
    confirmButton.Size = UDim2.new(0.48, 0, 1, 0)
    confirmButton.Position = UDim2.new(0, 0, 0, 0)
    confirmButton.BackgroundColor3 = CONFIG.THEME.INFO
    confirmButton.BorderSizePixel = 0
    confirmButton.Font = Enum.Font.GothamBold
    confirmButton.Text = confirmText
    confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmButton.TextSize = 14
    confirmButton.AutoButtonColor = false
    confirmButton.ClipsDescendants = true 
    confirmButton.Parent = buttonContainer

    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(0.48, 0, 1, 0)
    cancelButton.Position = UDim2.new(0.52, 0, 0, 0)
    cancelButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    cancelButton.BorderSizePixel = 0
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.Text = cancelText
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.TextSize = 14
    cancelButton.AutoButtonColor = false
    cancelButton.ClipsDescendants = true 
    cancelButton.Parent = buttonContainer

    local confirmCorner = Instance.new("UICorner")
    confirmCorner.CornerRadius = CONFIG.CORNER_RADIUS
    confirmCorner.Parent = confirmButton

    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = CONFIG.CORNER_RADIUS
    cancelCorner.Parent = cancelButton

    local function setupButtonEffects(button, color)
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Size = UDim2.new(0.48, 0, 1, -4),
                Position = UDim2.new(button.Position.X.Scale, 0, 0, -2)
            }):Play()

            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(
                    math.min(color.R * 1.1 * 255, 255),
                    math.min(color.G * 1.1 * 255, 255),
                    math.min(color.B * 1.1 * 255, 255)
                )
            }):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Size = UDim2.new(0.48, 0, 1, 0),
                Position = UDim2.new(button.Position.X.Scale, 0, 0, 0)
            }):Play()

            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = color
            }):Play()
        end)

        button.MouseButton1Down:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0.48, 0, 1, -6),
                Position = UDim2.new(button.Position.X.Scale, 0, 0, 3)
            }):Play()

            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(
                    math.max(color.R * 0.9 * 255, 0),
                    math.max(color.G * 0.9 * 255, 0),
                    math.max(color.B * 0.9 * 255, 0)
                )
            }):Play()
        end)

        button.MouseButton1Up:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0.48, 0, 1, -4),
                Position = UDim2.new(button.Position.X.Scale, 0, 0, -2)
            }):Play()

            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = color
            }):Play()
        end)
    end

    setupButtonEffects(confirmButton, CONFIG.THEME.INFO)
    setupButtonEffects(cancelButton, Color3.fromRGB(100, 100, 100))

    confirmButton.MouseButton1Click:Connect(function()
        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
        local buttonPos = confirmButton.AbsolutePosition
        local relX = mousePos.X - buttonPos.X
        local relY = mousePos.Y - buttonPos.Y
        self:CreateRippleEffect(confirmButton, relX, relY, Color3.fromRGB(255, 255, 255))

        local value = (inputType == "Password") and actualValue or inputBox.Text
        
        if inputType == "Number" then
            value = tonumber(value) or 0
        end

        task.spawn(function()
            onConfirm(value)
        end)

        notification.Close()
    end)

    cancelButton.MouseButton1Click:Connect(function()
        local mousePos = game:GetService("UserInputService"):GetMouseLocation()
        local buttonPos = cancelButton.AbsolutePosition
        local relX = mousePos.X - buttonPos.X
        local relY = mousePos.Y - buttonPos.Y
        self:CreateRippleEffect(cancelButton, relX, relY, Color3.fromRGB(255, 255, 255))

        task.spawn(onCancel)

        notification.Close()
    end)

    task.delay(0.1, function()
        if inputBox and inputBox.Parent then
            inputBox:CaptureFocus()
        end
    end)

    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local value = (inputType == "Password") and actualValue or inputBox.Text
            
            if inputType == "Number" then
                value = tonumber(value) or 0
            end

            task.spawn(function()
                onConfirm(value)
            end)

            notification.Close()
        end
    end)

    return notification
end

function NotificationLibrary:CloseAll()
    local container = self:Init()
    local notificationsFrame = container.NotificationsFrame

    for _, child in ipairs(notificationsFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name:match("^Notification_") then

            local fadeOutInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            local statusIcon = child:FindFirstChild("IconContainer") and 
                child.IconContainer:FindFirstChild("StatusIcon")

            local titleText = child:FindFirstChild("Title")
            local messageText = child:FindFirstChild("Message")
            local closeButton = child:FindFirstChild("CloseButton")

            if statusIcon then
                TweenService:Create(statusIcon, fadeOutInfo, {
                    ImageTransparency = 1
                }):Play()
            end

            if titleText then
                TweenService:Create(titleText, fadeOutInfo, {
                    TextTransparency = 1
                }):Play()
            end

            if messageText then
                TweenService:Create(messageText, fadeOutInfo, {
                    TextTransparency = 1
                }):Play()
            end

            if closeButton then
                TweenService:Create(closeButton, fadeOutInfo, {
                    ImageTransparency = 1
                }):Play()
            end

            task.delay(0.2, function()
                local exitTween = TweenService:Create(child, TweenInfo.new(CONFIG.ANIMATION_SPEED, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Position = UDim2.new(1.5, 0, 0, child.Position.Y.Offset)
                })

                exitTween:Play()
                exitTween.Completed:Wait()
                if child and child.Parent then
                    child:Destroy()
                end
            end)
        end
    end
end

function NotificationLibrary:SetTheme(themeTable)
    for key, value in pairs(themeTable) do
        if CONFIG.THEME[key] then
            CONFIG.THEME[key] = value
        end
    end
end

function NotificationLibrary:SetConfig(configTable)
    for key, value in pairs(configTable) do
        if CONFIG[key] and type(CONFIG[key]) == type(value) then
            CONFIG[key] = value
        end
    end
end

return NotificationLibrary
