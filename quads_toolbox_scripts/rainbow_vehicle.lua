---------------------------------------
--- RAINBOW CAR SCRIPT by Quad_Plex ---
---------------------------------------

rainbowcolorToggle = false
randomcolorToggle = false
strobecolorToggle = false
local uniform = true
local mul = 5
local affect_traffic = false
local isRunning = false

function randomColor(_, _, _)
    return math.random(0, 255), math.random(0, 255), math.random(0, 255)
end

function strobeLight(color_red, color_green, color_blue)
    local slp = 0.8
    if affect_traffic then
        slp = 0.02
    end
    if color_red == 255 then
        color_red, color_green, color_blue = 0, 0, 0
    else
        color_red, color_green, color_blue = 255, 255, 255
    end
    return color_red, color_green, color_blue
end

function nextRainbowColor(color_red, color_green, color_blue)
    if (color_red > 0 and color_blue == 0 and color_green == 0 and not (color_red >= 255)) then
        color_red = color_red + 1 * mul
    elseif (color_red > 0 and color_blue == 0) then
        color_red = color_red - 1 * mul
        color_green = color_green + 1 * mul
    elseif (color_green > 0 and color_red == 0) then
        color_green = color_green - 1 * mul
        color_blue = color_blue + 1 * mul
    elseif (color_blue > 0 and color_green == 0) then
        color_red = color_red + 1 * mul
        color_blue = color_blue - 1 * mul
    else
        color_red = color_red + 1 * mul
        color_green = color_green - 1 * mul
        color_blue = color_blue - 1 * mul
    end

    -- Clamp the color values to the range of 0-255
    color_red = math.max(0, math.min(255, color_red))
    color_green = math.max(0, math.min(255, color_green))
    color_blue = math.max(0, math.min(255, color_blue))

    return color_red, color_green, color_blue
end

local function toggleColorFunction(colorFunc)
    if colorFunc == "Rainbow" then
        rainbowcolorToggle = not rainbowcolorToggle
        if rainbowcolorToggle then
            strobecolorToggle = false
            randomcolorToggle = false
        end
    elseif colorFunc == "Strobelight" then
        strobecolorToggle = not strobecolorToggle
        if strobecolorToggle then
            rainbowcolorToggle = false
            randomcolorToggle = false
        end
    elseif colorFunc == "Random" then
        randomcolorToggle = not randomcolorToggle
        if randomcolorToggle then
            rainbowcolorToggle = false
            strobecolorToggle = false
        end
    end
end

local function changeVehicleColor(vehicle, colorFunc)
    local red, green, blue = vehicle:get_custom_primary_colour()
    local red2, green2, blue2 = vehicle:get_custom_secondary_colour()
    red, green, blue = colorFunc(red, green, blue)
    vehicle:set_custom_primary_colour(red, green, blue)
    if uniform then
        vehicle:set_custom_secondary_colour(red, green, blue)
    else
        red2, green2, blue2 = colorFunc(red2, green2, blue2)
        --Make sure to actually produce non-uniform colors
        if math.abs(red2 - red) < 30 and math.abs(blue2 - blue) < 30 and math.abs(green2 - green) < 30 then
            red2, blue2, green2 = math.random(0,255), math.random(0,255), math.random(0,255)
        end
        vehicle:set_custom_secondary_colour(red2, green2, blue2)
    end
end

local colorStyle = 1
local colorStyles = { "Rainbow", "Strobelight", "Random" }
greyText(vehicleOptionsSub, "------- 🌈 Color Changer -------")
vehicleOptionsSub:add_array_item("Car Color Changer:", colorStyles, function()
    return colorStyle
end, function(value)
    colorStyle = value
    toggleColorFunction(colorStyles[colorStyle])
    if not isRunning then
        menu.emit_event("rainbowRunner")
    end
end)
vehicleOptionsSub:add_toggle("Same primary/secondary colors", function()
    return uniform
end, function(value)
    uniform = value
end)
vehicleOptionsSub:add_toggle("Affect traffic", function()
    return affect_traffic
end, function(value)
    affect_traffic = value
end)
vehicleOptionsSub:add_int_range("|Speed Multiplier x", 1, 1, 69, function()
    return mul
end, function(value)
    mul = value
end)

function RainBowRunner()
    while rainbowcolorToggle or strobecolorToggle or randomcolorToggle do
        isRunning = true;
        local myPlayer = player.get_player_ped()
        local vehicle = myPlayer:get_current_vehicle()

        local function applyColor(colorFunc)
            if affect_traffic then
                for veh in replayinterface.get_vehicles() do
                    changeVehicleColor(veh, colorFunc)
                end
            elseif vehicle then
                changeVehicleColor(vehicle, colorFunc)
            end

            sleep(0.6 / mul)

            if not myPlayer:is_in_vehicle() and not affect_traffic then
                rainbowcolorToggle = false
                strobecolorToggle = false
                randomcolorToggle = false
            end
        end

        while rainbowcolorToggle do
            applyColor(nextRainbowColor)
        end
        while strobecolorToggle do
            applyColor(strobeLight)
        end
        while randomcolorToggle do
            applyColor(randomColor)
        end
    end
    isRunning = false;
end
menu.register_callback('rainbowRunner', RainBowRunner)