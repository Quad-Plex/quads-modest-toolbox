---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
------------------------------------------ UTIL FUNCTIONS -----------------------------------------------
---------------------------------------------------------------------------------------------------------
function null() end

MAX_INT = 2147483647

--------------------Spawned Vehicle Godmode toggler-----------------------------------

function findAndEnableGodmodeForVehicle(vehicle_hash, checkPos)
    local foundVeh
    for _ = 0, 12 do
        for veh in replayinterface.get_vehicles() do
            if veh:get_model_hash() == vehicle_hash and distanceBetween(veh, checkPos, true) < 4 then
                foundVeh = veh
                break
            end
        end
        sleep(0.08)
    end
    if not foundVeh then print("Couldn't find veh to godmode!") return end
    for _ = 0, 42 do
        --For some reason godmode gets enabled here but doesn't stick well so I just force it for a while
        foundVeh:set_godmode(true)
        sleep(0.1)
    end
    return
end


---------------------------- Reused Keyboard functions -------------------------
selectedLetterPos = 1
lowercaseLetters = { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z' }
selectedNumberPos = 1
numbers = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' }
selectedSymbolPos = 1
symbols = { ' ', '!', '?', '.', ',', '/', '\\','_', '*', '-', '=', '+', ';', ':', "'", '"', '(', ')', '[', ']', '{', '}', '@', '#', '$', '€', '%', '^', '&', '<', '>', '|' }
uppercaseToggle = false
function showLettersForPosition(letterPos, table, ignore_uppercase)
    local result = ""
    local start_index = letterPos - 4
    local end_index = letterPos + 4
    for i = start_index, end_index do
        local index = i
        if index == letterPos then
            result = result .. "(" .. table[index] .. ") "
        elseif i < 1 then
            result = result .. "  "
        elseif i > #table then
            result = result .. "  "
        else
            result = result .. table[index] .. " "
        end
    end
    if table == lowercaseLetters and uppercaseToggle and not ignore_uppercase then
        result = result:upper()
    end
    return result
end

function addLetterToString(letter, string)
    if not uppercaseToggle then
        return string .. letter
    else
        return string .. letter:upper()
    end
end


-------------------------------------------------------------
------------------JSON HOTKEY/KEYCODE DATA-------------------
-------------------------------------------------------------
function find_keycode(event_name)
    success, hotkeysData = pcall(json.loadfile, "HOTKEY_CONFIG.json")
    for i=1, #hotkeysData do
        if hotkeysData[i].event == event_name then
            return hotkeysData[i].keycode
        end
    end
    return nil
end

-------------------Distance function----------------------------
function round(num)
    return math.floor(num + 0.5)
end

function distanceBetween(one, two, vector, km)
    if not one or not two then
        return
    end
    local pos1 = one:get_position()
    local pos2 = vector and two or two:get_position()

    local dis = (pos1.x - pos2.x) ^ 2 + (pos1.y - pos2.y) ^ 2 + (pos1.z - pos2.z) ^ 2
    local result = round(math.sqrt(dis))

    return km and result * 0.001 or result
end

-------------------Direction Function----------------------------
function getAngleToThing(toThing, fromThing)
    if not toThing then return end
    if not fromThing then fromThing = player.get_player_ped() end
    local fromPos = fromThing:get_position()
    local toPos = toThing:get_position()

    local vec1 = fromThing:get_heading()
    local vec2 = vector3(toPos.x - fromPos.x, toPos.y - fromPos.y, 0)
    local angleBetween = math.atan(vec2.y, vec2.x) - math.atan(vec1.y, vec1.x)
    angleBetween = ((angleBetween + math.pi) % (2 * math.pi)) - math.pi
    return math.deg(angleBetween)
end


--return one of 8 directional unicode arrows according to the angle given
-- 180/4 = 45, shift it by 22.5 to make the arrows squarely point at the directions, and not between them
function getDirectionalArrow(angle)
    if not angle then
        return
    end

    --starting with downward arrow, going clockwise
    local arrows = {
        { max = 180, min = 157.5, arrow = "\u{1F863}" }, --down
        { max = 157.5, min = 112.5, arrow = "\u{1F867}" }, --down left
        { max = 112.5, min = 67.5, arrow = "\u{1F860}" }, --left
        { max = 67.5, min = 22.5, arrow = "\u{1F864}" }, --up left
        { max = 22.5, min = -22.5, arrow = "\u{1F861}" }, --up
        { max = -22.5, min = -67.5, arrow = "\u{1F865}" }, --up right
        { max = -67.5, min = -112.5, arrow = "\u{1F862}" }, --right
        { max = -112.5, min = -157.5, arrow = "\u{1F866}" }, --down right
        { max = -157.5, min = -180, arrow = "\u{1F863}" } --down
    }

    for _, v in ipairs(arrows) do
        if angle <= v.max and angle > v.min then
            return v.arrow
        end
    end
end

function printPlayerPos(ply)
    local pos = ply:get_position()
    return string.format("%.1fx, %.1fy, %.1fz", pos.x, pos.y, pos.z)
end

function getNonPlayerVehicles()
    local playerVehicles = {}
    for i = 0, 31 do
        local plyToCheck = player.get_player_ped(i)
        if plyToCheck and plyToCheck:is_in_vehicle() then
            playerVehicles[tostring(plyToCheck:get_current_vehicle())] = true
        end
    end

    local nonPlayerVehicles = {}
    local bannedModels = { [joaat("TrailerLarge")] = true }

    for veh in replayinterface.get_vehicles() do
        if not playerVehicles[tostring(veh)] and not bannedModels[veh:get_model_hash()] then
            table.insert(nonPlayerVehicles, veh)
        end
    end

    return nonPlayerVehicles
end

-------------------------Table Helper Functions-------------------------
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        elseif value[1] == element then
            return true
        end
    end
    return false
end

function table.copy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

--This counter is for working with non-contingent tables
function tableCount(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-----------------------Text functions------------------------------
function addText(sub, string)
    sub:add_bare_item("", function()
        return string
    end, null, null, null)
end

function greyText(sub, string)
    if not sub then error("Missing sub in greyText!") end
    sub:add_bare_item(string, null, null, null, null)
end

function centeredText(str)
    len = 18 - (math.floor(string.len(str) >> 1) + 0.5)
    local centeredText = ""

    for _ = 0, len do
        centeredText = centeredText .. " "
    end

    return centeredText .. str
end

-----------------------Number Formatter--------------------------
function formatNumberWithDots(n)
    n = tostring(n):reverse()
    if formatStyles[playerlistSettings.stringFormat] == "Metric (EU)" then
        n = n:gsub("(%d%d%d)", "%1.")
    elseif formatStyles[playerlistSettings.stringFormat] == "Imperial (US)" then
        n = n:gsub("(%d%d%d)", "%1,")
    end
    if n:sub(-1) == "." then
        n = n:sub(1, -2)
    elseif n:sub(-1) == "," then
        n = n:sub(1, -2)
    end
    return n:reverse()
end

-----------------------Bit Checker--------------------------------
function checkBit(value, pos)
    --Sometimes localplayer:get_player_id() will fail and return -1, which trips up this function
    if not pos or pos == -1 then return false end
    return (value >> pos) % 2 == 1
end

-- Function to set a bit
function setBit(value, bit)
    if not checkBit(value, bit) then
        value = value + (2 ^ bit)
    end
    return value
end

-- Function to clear a bit
function clearBit(value, bit)
    if checkBit(value, bit) then
        value = value - (2 ^ bit)
    end
    return value
end

---------------------------Type Checker-------------------------------
function checkType(var)
    if type(var) == "number" then
        if var ~= var then
            return 'NaN'
        elseif var % 1 == 0 then
            return 'Int'
        else
            return 'Float'
        end
    elseif type(var) == "string" then
        return 'String'
    else
        return 'Other'
    end
end

------------------------ is animal ped model -----------------------
function isAnimalPed(internalPedName)
    if checkType(internalPedName) == "Int" then return false end
    if string.find(internalPedName:lower(), "a_c") then return true end
    return false
end

-------------------- Sorted vehicle list --------------------------
--Pre-sort this table in order to only do it once
sorted_vehicles = {}
for hash, vehicle in pairs(VEHICLE) do
    table.insert(sorted_vehicles, { hash, vehicle })
end
--sort by Name if classes are the same, otherwise sort by class
table.sort(sorted_vehicles, function(a, b)
    if a[2][2] == b[2][2] then
        return a[2][1]:upper() < b[2][1]:upper()
    end
    return a[2][2] < b[2][2]
end)

------------------- generate random mods ------------------------------------------------------------
function generateRandomMods(inputTable)
    local newTable = {}
    for i, value in ipairs(inputTable) do
        if value == -1 then
            -- If the value is -1, keep it unchanged
            newTable[i] = value
        else
            local lowerLimit
            if value > 1 then
                lowerLimit = 1
            else
                lowerLimit = 0
            end
            newTable[i] = math.random(lowerLimit, value)
        end
    end
    return newTable
end