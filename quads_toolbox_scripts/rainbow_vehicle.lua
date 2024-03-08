---------------------------------------
--- RAINBOW CAR SCRIPT by Quad_Plex ---
---------------------------------------

local rainbow = false
local random = false
local strobelight = false
local uniform = true
local mul = 5
local affect_traffic = false
local isRunning = false

local function null()
end

function randomColor(_, _, _)
    return math.random(0, 255), math.random(0, 255), math.random(0, 255)
end


--TODO: Check if this uniformtoggle thing and commented out logic was needed for anything
local uniformtoggle = false
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
    --if not uniform and uniformtoggle then
    --	uniformtoggle = not uniformtoggle
    --else
    --	sleep(slp / mul)
    --	uniformtoggle = true
    --end
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
        rainbow = not rainbow
        if rainbow then
            strobelight = false
            random = false
        end
    elseif colorFunc == "Strobelight" then
        strobelight = not strobelight
        if strobelight then
            rainbow = false
            random = false
        end
    elseif colorFunc == "Random" then
        random = not random
        if random then
            rainbow = false
            strobelight = false
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
        --Make sure we actually produce non-uniform colors
        if math.abs(red2 - red) < 20 and math.abs(blue2 - blue) < 20 and math.abs(green2 - green) < 20 then
            red2, blue2, green2 = 255, 0, 125
        end
        vehicle:set_custom_secondary_colour(red2, green2, blue2)
    end
end

local colorStyle = 1
local colorStyles = { "Rainbow", "Strobelight", "Random" }
toolbox:add_bare_item("", function()
    return "------- 🌈 Color Changer -------"
end, null, null, null)
toolbox:add_array_item("Car Color Changer:", colorStyles, function()
    return colorStyle
end, function(value)
    colorStyle = value
    toggleColorFunction(colorStyles[colorStyle])
    if not isRunning then
        menu.emit_event("rainbowRunner")
    end
end)
toolbox:add_toggle("uniform color", function()
    return uniform
end, function(value)
    uniform = value
end)
toolbox:add_toggle("affect traffic", function()
    return affect_traffic
end, function(value)
    affect_traffic = value
end)
toolbox:add_int_range("Rainbow Speed Multiplier|x", 1, 1, 69, function()
    return mul
end, function(value)
    mul = value
end)

function RainBowRunner()
    while rainbow or strobelight or random do
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
                rainbow = false
                strobelight = false
                random = false
            end
        end

        while rainbow do
            applyColor(nextRainbowColor)
        end
        while strobelight do
            applyColor(strobeLight)
        end
        while random do
            applyColor(randomColor)
        end
    end
    isRunning = false;
end
menu.register_callback('rainbowRunner', RainBowRunner)