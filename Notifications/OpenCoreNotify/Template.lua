--[[
Simple rules to work with

(Duration = 0) means the Notification will last forever until it is closed. Otherwise it will be related in seconds
  Duration = 1, waits 1 second before removing itself
(Password) Generally needs working on dont use it.
(Type) There are 4 types which can be edited in the source code
  Info, Success, Warning, Error

There are plenty of other functions I haven't and wont explain here as they are perhaps a bit to complicated for simple minded individuals
and this is for the simpletons, here are the functions I have not explained

Source: https://github.com/Open-Cor3/Roblox-Libraries/blob/main/Notifications/OpenCoreNotify/Source.lua

NotificationLibrary.CONFIG -- Honestly not hard to explain

NotificationLibrary.CONFIG = {
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

NotificationLibrary:Init()

]]
local NotificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Open-Cor3/Roblox-Libraries/refs/heads/main/Notifications/OpenCoreNotify/Source.lua"))()


-- Simple Input, Password is a bit buggy
NotificationLibrary:Input({
    Title = "Enter Name", -- General Title
    Text = "What's your pookie bear called?", -- General Description
    Type = "Warning"; -- Type of Notification: Info, Success, Warning, Error
    InputType = "Text", -- Type of Input: Text, Number, (Password = Needs some fixing)
    PlaceholderText = "e.g. John Doe", -- General viewable text that doesn't effect the outcome
    ConfirmText = "yipeee!", -- The text on the confirm button
    CancelText = "Nah", -- The text on the cancel button
    DefaultValue = "nerd!", -- The text that comes with it naturally, leave blank for clear
    OnConfirm = function(value) -- Outcome of when they press Confirm, value = inputted characters
        print("You said", value)
    end,
    OnCancel = function()
        print("Cancelled!") -- Just a simpy print stating cancled when the cancled button is clicked
    end
})

NotificationLibrary:Confirm({
    Title = "Show All Settings", -- General Title
    Text = "werm so whassssss", -- General Description
    Duration = 0, -- Duration 0 = No close
    YesText = "Cool", -- The text on the confirm button
    NoText = "Dismiss" -- The text on the cancel button,
    OnYes = function() -- Outcome of when they press Confirm
        print("User confirmed!")
    end,
    OnNo = function() -- Outcome of when they press Cancel
        print("User declined.")
    end
})
NotificationLibrary:Notif(
  "hallo hallo", -- Title
  "so erm what rthe fluppers!",  -- Description
  0, -- Duration
  "Success" -- Type
)
-- Available on 1 line
-- NotificationLibrary:Notif("hallo hallo", "so erm what rthe fluppers!", 0, "Success")
