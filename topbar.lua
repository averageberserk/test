--[[
Flame's Topbar
With this API, you can make your own top-bar buttons!
Use addButton() to create buttons.
addButton requires you to specify some things in order to work, let's break the function.
addButton(
    buttonType,     string     defines the button type, a button can be "single", "group", or "list", "group" buttons still on development, so expect some bugs!
    listParent,     number     the button's parent ID (if is a list), set to -1 if it isn't a list button, set to 0 to make a new list.
    groupParent,    number     the button's parent ID (if is a group), set to -1 if it isn't a group button, set to 0 to make a new group.
    isToggleable,   boolean    defines if the button is toggleable or not.
    buttonPosition, string     defines the button's top-bar position, can be "left" or "right" aligned.
    hasImage,       boolean    determines if the button has an image.
    buttonImageId,  string     defines the image ID, only include the ID, not the URL.
    toggledImageId, string     defines the toggled image ID, only applies if the button is toggleable, leave it empty if your button isn't toggleable.
    hasText,        boolean    determines if the button has text.
    buttonContent,  string     defines the button's default text, it will also be used as the un-toggled button content.
    toggledContent, string     defines the toggled button's text, only applies if the button is toggleable, leave it empty if your button isn't toggleable.
    callback,       function   defines the button's action when pressed, it will be used as the toggle function if is toggleable.
    callbackEnd     function   defines the button's un-toggle action, leave it as "" if your button isn't toggleable.
)
v1.0.0
~ By FlameWaterYT with love :3
]]
if game:GetService("CoreGui"):FindFirstChild("FWTopBarAPI") then
    game:GetService("CoreGui"):FindFirstChild("FWTopBarAPI"):Destroy()
end

local player = game:GetService("Players").LocalPlayer
local vc = game:GetService("VoiceChatService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local rightButtonsCount = 0
local leftButtonsCount = 0
local buttonId = 0
local topbarSide = nil
local buttonOffset = 0
local oldPosition = 0
local rightNewPosition = 0
local leftNewPosition = 0
local alignPosition = 0
local buttons = { right = {}, left = {} }
local listButtonId = 0
local groupButtonId = 0

FWTopBarAPI = Instance.new("ScreenGui")
screenSpace = Instance.new("Frame")
topbarSpace = Instance.new("Frame")
topbarRightSpace = Instance.new("Frame")

FWTopBarAPI.Name = "FWTopBarAPI"
FWTopBarAPI.Parent = game:GetService("CoreGui")
FWTopBarAPI.Enabled = true
FWTopBarAPI.IgnoreGuiInset = true

screenSpace.Name = "screenSpace"
screenSpace.Parent = FWTopBarAPI
screenSpace.Size = UDim2.new(1, 0, 1, 0)
screenSpace.Position = UDim2.new(0, 0, 0, 0)
screenSpace.AnchorPoint = Vector2.new(0, 0)
screenSpace.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
screenSpace.BackgroundTransparency = 1

topbarSpace.Name = "topbarSpace"
topbarSpace.Parent = screenSpace
topbarSpace.AnchorPoint = Vector2.new(0, 0)
topbarSpace.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
topbarSpace.BackgroundTransparency = 1

topbarRightSpace.Name = "topbarRightSpace"
topbarRightSpace.Parent = screenSpace
topbarRightSpace.Position = UDim2.new(1, -16, 0, 12)
topbarRightSpace.AnchorPoint = Vector2.new(1, 0)
topbarRightSpace.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
topbarRightSpace.BackgroundTransparency = 1

if vc:IsVoiceEnabledForUserIdAsync(player.UserId) then
    topbarSpace.Size = UDim2.new(0, 546, 0, 44)
    topbarSpace.Position = UDim2.new(0, 253, 0, 12)
    topbarRightSpace.Size = UDim2.new(0, 530, 0, 44)
else
    topbarSpace.Size = UDim2.new(0, 623, 0, 44)
    topbarSpace.Position = UDim2.new(0, 176, 0, 12)
    topbarRightSpace.Size = UDim2.new(0, 607, 0, 44)
end

function addButton(buttonType, listParent, groupParent, isToggelable, buttonPosition, hasImage, buttonImageId, toggledImageId, hasText, buttonContent, toggledContent, callback, callbackEnd)
    if not hasImage and not hasText and buttonType ~= "group" then
        warn("Error creating button, a button can't be empty!")
        return
    end

    local listButtonParent = nil
    if listParent > 0 then
        for _, buttonData in ipairs(buttons[buttonPosition]) do
            if buttonData.id == listParent then
                listButtonParent = buttonData.dropdown
                listButtonId = listButtonId + 1
                break
            end
        end
        if not listButtonParent then
            warn("Error creating button, list parent with ID " .. listParent .. " not found!")
            return
        end
        if not hasImage or not hasText then
            warn("Error creating button, list buttons require both an image and a text to work!")
            listButtonId = listButtonId - 1
            return
        end
        if listButtonId > 8 then
            warn("Error creating button, lists can't have more than 8 buttons!")
            listButtonId = listButtonId - 1
            return
        end
    end

    local groupButtonParent = nil
    if groupParent > 0 then
        for _, buttonData in ipairs(buttons[buttonPosition]) do
            if buttonData.id == groupParent then
                groupButtonParent = buttonData.frame
                groupButtonId = groupButtonId + 1
                break
            end
        end
        if not groupButtonParent then
            warn("Error creating button, group parent with ID " .. groupParent .. " not found!")
            return
        end
        if not hasImage then
            warn("Error creating button, group buttons require an image to work!")
            groupButtonId = groupButtonId - 1
            return
        end
        if hasText then
            warn("Error creating button, group buttons can't have text!")
            groupButtonId = groupButtonId - 1
            return
        end
        if groupButtonId > 3 then
            warn("Error creating button, groups can't have more than 3 buttons!")
            groupButtonId = groupButtonId - 1
            return
        end
    end
    
    local topbarWidth
    if buttonPosition == "right" then
        topbarWidth = topbarRightSpace.AbsoluteSize.X
    elseif buttonPosition == "left" then
        topbarWidth = topbarSpace.AbsoluteSize.X
    end
    local occupiedWidth = 0

    for _, buttonData in ipairs(buttons[buttonPosition]) do
        local buttonFrame = buttonData.frame
        local buttonText = buttonData.text
        local lparent = buttonData.listParentId
        local textSize
        if lparent > 0 then
            occupiedWidth = occupiedWidth
        else
            if buttonText then
                textSize = TextService:GetTextSize(buttonText.Text, buttonText.TextSize, buttonText.Font, Vector2.new(math.huge, 36))
                occupiedWidth = occupiedWidth + buttonFrame.AbsoluteSize.X + textSize.X + 8
            else
                occupiedWidth = occupiedWidth + buttonFrame.AbsoluteSize.X + 8
            end
        end
    end

    local estimatedWidth = 44
    if hasText then
        local newTextSize = TextService:GetTextSize(buttonContent, 12, Enum.Font.SourceSans, Vector2.new(math.huge, 36))
        estimatedWidth = newTextSize.X + 12 + (hasImage and 44 or 0)
    end

    if occupiedWidth + estimatedWidth > topbarWidth then
        warn("Error creating button, not enough space on the topbar!")
        return
    end

    if buttonPosition == "right" then
        rightButtonsCount = rightButtonsCount + 1
        topbarSide = topbarRightSpace
        alignPosition = 1
    elseif buttonPosition == "left" then
        leftButtonsCount = leftButtonsCount + 1
        topbarSide = topbarSpace
        alignPosition = 0
    else
        warn("Error creating button, invalid position!")
        return
    end

    if callback and type(callback) == "function" then
    else
        if buttonType == "list" then
        elseif buttonType == "group" and groupParent == 0 then
        else
            warn("No valid function assigned for button " .. buttonId .. ", pressing it will do nothing!")
        end
    end
    if isToggelable then
        if callbackEnd and type(callbackEnd) == "function" then
        else
            warn("No valid un-toggle function assigned for button " .. buttonId .. ", un-toggle function can malfunction!")
        end
    end
    local buttonFrame = Instance.new("Frame")
    local buttonFrameCorner = Instance.new("UICorner")
    local buttonImage, buttonImageCorner
    if hasImage then
        buttonImage = Instance.new("ImageLabel")
        buttonImageCorner = Instance.new("UICorner")
    end
    local button = Instance.new("TextButton")
    local buttonText
    if hasText then
        buttonText = Instance.new("TextLabel")
    end
    local buttonToggle, buttonToggleCorner
    if isToggelable or buttonType == "list" then
        buttonToggle = Instance.new("Frame")
        buttonToggleCorner = Instance.new("UICorner")
    end
    local buttonCorner = Instance.new("UICorner")
    local buttonHover = Instance.new("Frame")
    local buttonHoverCorner = Instance.new("UICorner")
    local listFrame, listFrameCorner
    if buttonType == "list" and listParent == 0 then
        listFrame = Instance.new("Frame")
        listFrameCorner = Instance.new("UICorner")
    end

    buttonId = buttonId + 1
    local buttonData = {
        id = buttonId,
        frame = buttonFrame,
        text = buttonText,
        button = button,
        image = hasImage,
        position = buttonPosition,
        dropdown = listFrame,
        isToggled = false,
        isOpen = false,
        listParentId = listParent,
        groupParentId = groupParent

    }
    table.insert(buttons[buttonPosition], buttonData)

    buttonFrame.Name = "buttonFrame" .. buttonId
    if listButtonParent then
        buttonFrame.Parent = listButtonParent
    elseif groupButtonParent then
        buttonFrame.Parent = groupButtonParent
    else
        buttonFrame.Parent = topbarSide
    end
    if listButtonParent then
        listPosition = listButtonId - 1
        buttonFrame.Size = UDim2.new(1, 0, 0, 56)
        buttonFrame.Position = UDim2.new(0, 0, 0, 56 * listPosition)
        buttonFrame.AnchorPoint = Vector2.new(0, 0)
    elseif groupButtonParent then
        groupPosition = 44 * (groupButtonId - 1)
        buttonFrame.Size = UDim2.new(0, 44, 0, 44)
        buttonFrame.Position = UDim2.new(0, groupPosition, 0, 0)
        buttonFrame.AnchorPoint = Vector2.new(0, 0)
    else
        buttonFrame.Size = UDim2.new(0, 44, 0, 44)
        buttonFrame.Position = UDim2.new(alignPosition, 0, 0, 0)
        buttonFrame.AnchorPoint = Vector2.new(alignPosition, 0)
    end
    buttonFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    if buttonType == "single" then
        buttonFrame.BackgroundTransparency = 0.25
    elseif buttonType == "list" and listParent == 0 then
        buttonFrame.BackgroundTransparency = 0.25
    elseif buttonType == "group" and groupParent == 0 then
        buttonFrame.BackgroundTransparency = 0.25
    else
        buttonFrame.BackgroundTransparency = 1
    end
    buttonFrameCorner.Name = "buttonFrameCorner"
    buttonFrameCorner.Parent = buttonFrame
    if buttonType == "list" and listParent > 0 then
        buttonFrameCorner.CornerRadius = UDim.new(0.20)
    else
        buttonFrameCorner.CornerRadius = UDim.new(1)
    end

    if hasImage then
        buttonImage.Name = "buttonImage" .. buttonId
        buttonImage.Parent = buttonFrame
        buttonImage.Size = UDim2.new(0, 36, 0, 36)
        if listButtonParent then
            buttonImage.Position = UDim2.new(0, 12, 0, 10)
        else
            buttonImage.Position = UDim2.new(0, 4, 0, 4)
        end
        buttonImage.AnchorPoint = Vector2.new(0, 0)
        buttonImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        buttonImage.BackgroundTransparency = 1
        buttonImage.Image = "rbxassetid://" .. buttonImageId
        buttonImageCorner.Name = "buttonImageCorner"
        buttonImageCorner.Parent = buttonImage
        buttonImageCorner.CornerRadius = UDim.new(1)
    end

    button.Name = "button" .. buttonId
    button.Parent = buttonFrame
    if listButtonParent then
        button.Size = UDim2.new(1, 0, 1, 0)
        button.Position = UDim2.new(0, 0, 0, 0)
    else
        button.Size = UDim2.new(0, 36, 0, 36)
        button.Position = UDim2.new(0, 4, 0, 4)
    end
    button.AnchorPoint = Vector2.new(0, 0)
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.MouseEnter:Connect(function()
        buttonHover.BackgroundTransparency = 0.85
    end)
    button.MouseLeave:Connect(function()
        buttonHover.BackgroundTransparency = 1
    end)
    button.MouseButton1Click:Connect(function()
        if buttonType == "single" or buttonType == "group" then
            if isToggelable then
                if buttonData.isToggled then
                    if callbackEnd and type(callbackEnd) == "function" then
                        callbackEnd()
                    end
                    if hasImage then
                        if #toggledImageId > 0 then
                            buttonImage.Image = "rbxassetid://" .. buttonImageId
                        end
                    end
                    if hasText then
                        if #toggledContent > 0 then
                            buttonText.Text = buttonContent
                        end
                    end
                    adjustButton()
                    buttonData.isToggled = false
                    buttonToggle.Transparency = 1
                else
                    if callback and type(callback) == "function" then
                        callback()
                    end
                    if hasImage then
                        if #toggledImageId > 0 then
                            buttonImage.Image = "rbxassetid://" .. toggledImageId
                        end
                    end
                    if hasText then
                        if #toggledContent > 0 then
                            buttonText.Text = toggledContent
                        end
                    end
                    adjustButton()
                    buttonData.isToggled = true
                    buttonToggle.Transparency = 0.85
                end
            else
                if callback and type(callback) == "function" then
                    callback()
                end
                adjustButton()
            end
        elseif buttonType == "list" and listParent == 0 then
            if buttonData.isOpen then
                buttonData.isOpen = false
                buttonToggle.Transparency = 1
                if hasImage then
                    if #toggledImageId > 0 then
                        buttonImage.Image = "rbxassetid://" .. buttonImageId
                    end
                end
                if hasText then
                    if #toggledContent > 0 then
                        buttonText.Text = buttonContent
                    end
                end
                adjustButton()
                info = TweenInfo.new(0.1)
                tween = TweenService:Create(listFrame, info, {BackgroundTransparency = 1})
                tween:Play()
                wait(0.1)
                listFrame.Visible = false
            else
                buttonData.isOpen = true
                listFrame.Visible = true
                buttonToggle.Transparency = 0.85
                if hasImage then
                    if #toggledImageId > 0 then
                        buttonImage.Image = "rbxassetid://" .. toggledImageId
                    end
                end
                if hasText then
                    if #toggledContent > 0 then
                        buttonText.Text = toggledContent
                    end
                end
                adjustButton()
                listFrame.Size = UDim2.new(0, 192, 0, 0)
                listFrame:TweenSize(
                    UDim2.new(0, 192, 0, (56 * listButtonId)),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.2,
                    false
                )
                info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                tween = TweenService:Create(listFrame, info, {BackgroundTransparency = 0.25})
                tween:Play()
            end
        else
            if isToggelable then
                if buttonData.isToggled then
                    if callbackEnd and type(callbackEnd) == "function" then
                        callbackEnd()
                    end
                    if hasImage then
                        if #toggledImageId > 0 then
                            buttonImage.Image = "rbxassetid://" .. buttonImageId
                        end
                    end
                    if hasText then
                        if #toggledContent > 0 then
                            buttonText.Text = buttonContent
                        end
                    end
                    buttonData.isToggled = false
                else
                    if callback and type(callback) == "function" then
                        callback()
                    end
                    if hasImage then
                        if #toggledImageId > 0 then
                            buttonImage.Image = "rbxassetid://" .. toggledImageId
                        end
                    end
                    if hasText then
                        if #toggledContent > 0 then
                            buttonText.Text = toggledContent
                        end
                    end
                    buttonData.isToggled = true
                end
            else
                if callback and type(callback) == "function" then
                    callback()
                end
            end
        end
    end)
    if buttonType == "group" and groupParent == 0 then
        button.Visible = false
    end
    buttonCorner.Name = "buttonCorner"
    buttonCorner.Parent = button
    if listButtonParent then
        buttonCorner.CornerRadius = UDim.new(0.20)
    else
        buttonCorner.CornerRadius = UDim.new(1)
    end
        
    if isToggelable or buttonType == "list" then
        buttonToggle.Name = "buttonToggle" .. buttonId
        buttonToggle.Parent = button
        buttonToggle.Size = UDim2.new(1, 0, 1, 0)
        buttonToggle.Position = UDim2.new(0, 0, 0, 0)
        buttonToggle.AnchorPoint = Vector2.new(0, 0)
        buttonToggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        buttonToggle.BackgroundTransparency = 1
        buttonToggleCorner.Name = "buttonToggleCorner" .. buttonId
        buttonToggleCorner.Parent = buttonToggle
        buttonToggleCorner.CornerRadius = UDim.new(1)
    end

    if hasText then
        buttonText.Name = "buttonText" .. buttonId
        buttonText.Parent = button
        buttonText.Size = UDim2.new(0, 36, 0, 36)
        if not hasImage then
            buttonText.Position = UDim2.new(0, 4, 0, 0)
        else
            if listButtonParent then
                buttonText.TextSize = 14
                buttonText.Position = UDim2.new(0, 60, 0, 10)
            else
                buttonText.TextSize = 12
                buttonText.Position = UDim2.new(0, 40, 0, 0)
            end
        end
        buttonText.AnchorPoint = Vector2.new(0, 0)
        buttonText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        buttonText.BackgroundTransparency = 1
        buttonText.TextXAlignment = Enum.TextXAlignment.Left
        buttonText.Text = buttonContent
        buttonText.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    buttonHover.Name = "buttonHover" .. buttonId
    buttonHover.Parent = button
    buttonHover.Size = UDim2.new(1, 0, 1, 0)
    buttonHover.Position = UDim2.new(0, 0, 0, 0)
    buttonHover.AnchorPoint = Vector2.new(0, 0)
    buttonHover.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    buttonHover.BackgroundTransparency = 1
    buttonHoverCorner.Name = "buttonHoverCorner"
    buttonHoverCorner.Parent = buttonHover
    if listButtonParent then
        buttonHoverCorner.CornerRadius = UDim.new(0.20)
    else
        buttonHoverCorner.CornerRadius = UDim.new(1)
    end

    if buttonType == "list" and listParent == 0 then
        if buttonPosition == "right" and rightButtonsCount == 1 then
            listFrame.Name = "listFrame" .. buttonId
            listFrame.Parent = buttonFrame
            listFrame.Size = UDim2.new(0, 0, 0, 0)
            listFrame.Position = UDim2.new(1, 0, 1, 10)
            listFrame.AnchorPoint = Vector2.new(1, 0)
            listFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            listFrame.BackgroundTransparency = 0
            listFrameCorner.Name = "listFrameCorner"
            listFrameCorner.Parent = listFrame
            listFrameCorner.CornerRadius = UDim.new(0.06)
            listFrame.Visible = false
        else
            listFrame.Name = "listFrame" .. buttonId
            listFrame.Parent = buttonFrame
            listFrame.Size = UDim2.new(0, 0, 0, 0)
            listFrame.Position = UDim2.new(0.5, 0, 1, 10)
            listFrame.AnchorPoint = Vector2.new(0.5, 0)
            listFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            listFrame.BackgroundTransparency = 0
            listFrameCorner.Name = "listFrameCorner"
            listFrameCorner.Parent = listFrame
            listFrameCorner.CornerRadius = UDim.new(0.06)
            listFrame.Visible = false
        end
    end

    function adjustButton()
        local rightStartPosition = 0
        local leftStartPosition = 0
        for _, buttonData in ipairs(buttons["left"]) do
            local buttonFrame = buttonData.frame
            local buttonText = buttonData.text
            local button = buttonData.button
            local hasImage = buttonData.image
            local lparent = buttonData.listParentId
            local gparent = buttonData.groupParentId
            local newWidth = 44
            if buttonText then
                local numChars = #buttonText.Text
                if numChars > 16 then
                    warn("Error creating button, buttons can't have more than 16 characters!")
                    buttonText.Text = ""
                    buttonFrame.Size = UDim2.new(0, 44, 0, 44)
                else
                    textsize = TextService:GetTextSize(buttonText.Text, buttonText.TextSize, buttonText.Font, Vector2.new(math.huge, 36))
                    --newWidth = numChars * 9.75 + 8 + (hasImage and 44 or 0)
                    newWidth = textsize.X + 12 + (hasImage and 44 or 0)
                end
            end
            if lparent > 0 then
                newWidth = 0
            end
            if gparent > 0 then
                newWidth = 0
            end
            if gparent == 0 then
                newWidth = 44 * groupButtonId
            end
            if newWidth > 0 then
                buttonFrame:TweenSizeAndPosition(
                    UDim2.new(0, newWidth, 0, 44),
                    UDim2.new(0, leftStartPosition, 0, 0),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quart,
                    0.1,
                    false
                )
                button:TweenSize(
                    UDim2.new(0, newWidth - 8, 0, 36),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quart,
                    0.1,
                    false
                )
                leftStartPosition = leftStartPosition + newWidth + 8
            end
        end
        for _, buttonData in ipairs(buttons["right"]) do
            local buttonFrame = buttonData.frame
            local buttonText = buttonData.text
            local button = buttonData.button
            local hasImage = buttonData.image
            local lparent = buttonData.listParentId
            local gparent = buttonData.groupParentId
            local newWidth = 44
            if buttonText then
                local numChars = #buttonText.Text
                if numChars > 16 then
                    warn("Error creating button, buttons can't have more than 16 characters!")
                    buttonText.Text = ""
                    buttonFrame.Size = UDim2.new(0, 44, 0, 44)
                else
                    textsize = TextService:GetTextSize(buttonText.Text, buttonText.TextSize, buttonText.Font, Vector2.new(math.huge, 36))
                    --newWidth = numChars * 9.75 + 8 + (hasImage and 44 or 0)
                    newWidth = textsize.X + 12 + (hasImage and 44 or 0)
                end
            end
            if lparent > 0 then
                newWidth = 0
            end
            if gparent > 0 then
                newWidth = 0
            end
            if gparent == 0 then
                newWidth = 44 * groupButtonId
            end
            if newWidth > 0 then
                buttonFrame:TweenSizeAndPosition(
                    UDim2.new(0, newWidth, 0, 44),
                    UDim2.new(1, -rightStartPosition, 0, 0),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.1,
                    false
                )
                button:TweenSize(
                    UDim2.new(0, newWidth - 8, 0, 36),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.1,
                    false
                )
                rightStartPosition = rightStartPosition + newWidth + 8
            end
        end
        --[[if buttonPosition == "right" then
            rightNewPosition = rightNewPosition + oldPosition + 8
        elseif buttonPosition == "left" then
            leftNewPosition = leftNewPosition + oldPosition + 8
        end]]
    end
    adjustButton()
end

addButton("single", -1, -1, true, "left", true, "16086868244", "16086868447", true, "Example", "Example toggled", function()
    print("Toggled example button 1")
end,
function()
    print("Un-toggled example button 1")
end
)
addButton("group", -1, 0, false, "left", false, "", "", false, "", "", nil, nil)
addButton("group", -2, 2, true, "left", true, "16086868244", "16086868447", false, "", "", function()
    print("Toggled example button 2")
end,
function()
    print("Un-toggled example button 2")
end
)
addButton("group", -2, 2, false, "left", true, "16086868244", "16086868447", false, "", "", function()
    print("Example button 3")
end,
nil
)
addButton("list", 0, -1, false, "left", true, "16086868244", "16086868447", false, "", "", nil, nil)
addButton("list", 5, -1, false, "left", true, "16086868244", "", true, "Example 4", "", function()
    print("Example button 4")
end,
nil
)
addButton("list", 5, -1, true, "left", true, "16086868244", "16086868447", true, "Example 5", "", function()
    print("Toggled example button 5")
end,
function()
    print("Un-toggled example button 5")
end
)
