---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
------------------------------------------ UTIL FUNCTIONS -----------------------------------------------
---------------------------------------------------------------------------------------------------------
function null() end

MAX_INT = 2147483647

local function findAndEnableGodmodeForVehicle(vehicle_hash, checkPos)
    for veh in replayinterface.get_vehicles() do
        if veh:get_model_hash() == vehicle_hash and distanceBetween(veh, checkPos, true) < 2 then
            veh:set_godmode(true)
        end
    end
end

-------------------------------------------------------------
-------------------- SORTED VEHICLE LIST --------------------
-------------------------------------------------------------

local success, favoritedCars = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/FAVORITED_CARS.json")
if success then
    print("Favorite Cars loaded successfully!!")
end

-- vehicle = { hash, { name, class} }
table.sort(favoritedCars, function(a, b)
    return a[2][1]:upper() < b[2][1]:upper()
end)

--Pre-sort this table so we only do it once
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

local function isInFavorites(veh_hash)
    for i, favVehicle in ipairs(favoritedCars) do
        if favVehicle[1] == veh_hash then
            return i
        end
    end
    return false
end

local godmodeEnabledSpawn = false
local function addVehicleEntry(vehMenu, vehicle, ply)
    greyText(vehMenu, "Spawn " .. vehicle[2][1])
    vehMenu:add_action("Spawn using Method #1", function()
        local spawnPos = ply:get_position() + ply:get_heading() * 7
        createVehicle(vehicle[1], spawnPos)
        if godmodeEnabledSpawn then
            sleep(0.08)
            findAndEnableGodmodeForVehicle(vehicle[1], spawnPos)
        end
    end)
    vehMenu:add_action("Spawn using Method #2", function()
        local spawnPos = ply:get_position() + ply:get_heading() * 7
        local oldToggle = alternative_spawn_toggle
        alternative_spawn_toggle = true
        createVehicle(vehicle[1], spawnPos)
        alternative_spawn_toggle = oldToggle
        if godmodeEnabledSpawn then
            sleep(0.08)
            findAndEnableGodmodeForVehicle(vehicle[1], spawnPos)
        end
    end)
    vehMenu:add_toggle("Spawn with Godmode enabled", function() return godmodeEnabledSpawn end, function(n) godmodeEnabledSpawn = n end)
    vehMenu:add_toggle("Add " .. vehicle[2][1] .. " to favorites", function() return isInFavorites(vehicle[1]) ~= false end, function(add)
        if add then
            table.insert(favoritedCars, vehicle)
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/FAVORITED_CARS.json", favoritedCars)
        else
            local isFavorite = isInFavorites(vehicle[1])
            if isFavorite then
                table.remove(favoritedCars, isFavorite)
                json.savefile("scripts/quads_toolbox_scripts/toolbox_data/FAVORITED_CARS.json", favoritedCars)
            end
        end
    end)
end

local function buildFavoriteVehiclesSub(ply, categorySub)
    success, favoritedCars = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/FAVORITED_CARS.json")
    categorySub:clear()
    for _, favoriteVehicle in ipairs(favoritedCars) do
        local vehSub
        vehSub = categorySub:add_submenu(favoriteVehicle[2][1], function() addVehicleEntry(vehSub, favoriteVehicle, ply) end)
    end
end

--Create Vehicle Spawn Menu
function addVehicleSpawnMenu(ply, sub)
    sub:clear()
    success, favoritedCars = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/FAVORITED_CARS.json")
    if ply == nil then
        return
    end
    local vehSubs = {}

    if #favoritedCars > 0 then
        vehSubs["Favorites"] = sub:add_submenu("Favorites", function() buildFavoriteVehiclesSub(ply, vehSubs["Favorites"]) end)
        greyText(sub, "---------------------------")
    end

    -- vehicle = { hash, { name, class} }
    for _, vehicle in ipairs(sorted_vehicles) do
        if not vehSubs[vehicle[2][2]] then
            vehSubs[vehicle[2][2]] = sub:add_submenu(vehicle[2][2])
        end
        local vehSub
        vehSub = vehSubs[vehicle[2][2]]:add_submenu(vehicle[2][1], function() addVehicleEntry(vehSub, vehicle, ply) end)
    end
end

-------------------------------------------------------------
------------------JSON HOTKEY/KEYCODE DATA-------------------
-------------------------------------------------------------
-- Define the hotkeys data
success, hotkeysData = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/HOTKEY_CONFIG.json")
if success then
    print("Hotkey Configuration loaded successfully!!")
else
    error("Error loading Hotkey Configuration!", 0)
end

table.sort(hotkeysData, function(a, b)
    return a.name < b.name
end)

indexedKeycodes = {}
for key, keyCode in pairs(keycodes) do
    indexedKeycodes[keyCode]=key
end

sortedKeycodes = {}
for k in pairs(keycodes) do
    table.insert(sortedKeycodes, k)
end
table.sort(sortedKeycodes)


function find_keycode(event_name)
    success, hotkeysData = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/HOTKEY_CONFIG.json")
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
function getDirectionToThing(thing)
    if not thing then
        return
    end

    local my_pos = player.get_player_ped():get_position()
    local player_pos = thing:get_position()

    local vec1 = player.get_player_ped():get_heading()
    local vec2 = vector3(player_pos.x - my_pos.x, player_pos.y - my_pos.y, 0)
    local angleBetween = math.atan(vec2.y, vec2.x) - math.atan(vec1.y, vec1.x)
    angleBetween = ((angleBetween + math.pi) % (2 * math.pi)) - math.pi
    return math.deg(angleBetween)
end


--return one of 8 directional unicode arrows according to the angle given
-- 180/4 = 45, we shift it by 22.5 to make the arrows squarely point at the directions, and not between them
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
        if not playerVehicles[tostring(veh)] and (not bannedModels[veh:get_model_hash()]) then
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

--We need this counter for working with non-contingent tables
function tableCount(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-----------------------Text functions------------------------------
function text(sub, string)
    sub:add_bare_item("", function()
        return string
    end, null, null, null)
end

function greyText(sub, string)
    sub:add_bare_item(string, null, null, null, null)
end

function centeredText(str)
    len = 18 - math.floor(string.len(str) / 2 + 0.5)
    local centeredText = ""

    for _ = 0, len do
        centeredText = centeredText .. " "
    end

    return centeredText .. str
end

-----------------------Number Formatter--------------------------
function formatNumberWithDots(n)
    n = tostring(n):reverse()
    n = n:gsub("(%d%d%d)", "%1.")
    if n:sub(-1) == "." then
        n = n:sub(1, -2)
    end
    return n:reverse()
end

-----------------------Bit Checker--------------------------------
function checkBit(value, pos)
    --Sometimes localplayer:get_player_id() will fail and return -1, which trips up this function
    if pos == -1 then return false end
    -- shift right by pos
    while pos > 0 and value ~= 0 do
        value = math.floor(value / 2)
        pos = pos - 1
    end
    -- get rightmost ("first") bit
    return value % 2 == 1
end