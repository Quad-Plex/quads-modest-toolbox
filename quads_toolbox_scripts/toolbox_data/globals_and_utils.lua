function null()
end

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

--Create Vehicle Spawn Menu
function addVehicleSpawnMenu(ply, sub)
    sub:clear()
    if ply == nil then
        return
    end
    local vehSubs = {}

    -- vehicle = { hash, { name, class} }
    for _, vehicle in ipairs(sorted_vehicles) do
        local current_category = vehicle[2][2]
        if vehSubs[current_category] == nil then
            vehSubs[current_category] = sub:add_submenu(current_category)
        end

        vehSubs[current_category]:add_action(vehicle[2][1], function()
            createVehicle(vehicle[1], ply:get_position() + ply:get_heading() * 7)
        end)
    end
end

------------------Message Display-----------------------
local base_offset = 2672741 + 2518 + 1
--Credits to Kiddion for finding this stuff in an older version
--https://www.unknowncheats.me/forum/3523555-post2032.html
function displayHudBanner(headline, subHeadline, variable_text, box_type, skipTimeout)
    if localplayer == nil then return end
    globals.set_string(base_offset + 21, headline, 16)
    globals.set_string(base_offset + 8, subHeadline, 32)
    if variable_text ~= "" then
        if type(variable_text) == "number" then
            globals.set_int(base_offset + 3, variable_text)
        elseif type(variable_text) == "string" then
            globals.set_string(base_offset + 3, variable_text, 32)
        end
    end
    globals.set_int(base_offset + 1, box_type)
    globals.set_int(base_offset + 2, 1)

    if skipTimeout then return end

    sleep(2)

    globals.set_int(base_offset + 1, 1)
    globals.set_int(base_offset + 2, 1)
end

------------------Vehicle Spawners-----------------------------------
local VehicleSpawnGlobal = 2640095
local VehicleSpawnGlobal2 = 2695991
alternative_spawn_toggle = false
function createVehicle(modelHash, pos, heading)
    if not alternative_spawn_toggle and not player.get_player_ped():is_in_vehicle() then
        globals.set_int(VehicleSpawnGlobal + 47, modelHash)
        globals.set_float(VehicleSpawnGlobal + 43, pos.x)
        globals.set_float(VehicleSpawnGlobal + 44, pos.y)
        globals.set_float(VehicleSpawnGlobal + 45, pos.z)
        if heading then
            globals.set_float(VehicleSpawnGlobal + 46, heading)
        end
        globals.set_boolean(VehicleSpawnGlobal + 42, true)
    else
        globals.set_boolean(VehicleSpawnGlobal2 + 5, false) -- SpawnVehicles
        globals.set_boolean(VehicleSpawnGlobal2 + 2, false) -- SpawnVehicles
        globals.set_float(VehicleSpawnGlobal2 + 7 + 0, pos.x) -- pos.x
        globals.set_float(VehicleSpawnGlobal2 + 7 + 1, pos.y) -- pos.y
        globals.set_float(VehicleSpawnGlobal2 + 7 + 2, pos.z) -- pos.z
        globals.set_int(VehicleSpawnGlobal2 + 27 + 66, modelHash) -- modelHash
        globals.set_boolean(VehicleSpawnGlobal2 + 5, true) -- SpawnVehicles
        globals.set_boolean(VehicleSpawnGlobal2 + 2, true) -- SpawnVehicles
        --thanks to @Alice2333 on UKC for showing me the second spawner code
    end
end

function toggleAlternativeSpawner()
    alternative_spawn_toggle = not alternative_spawn_toggle
    if alternative_spawn_toggle then
        displayHudBanner("BLIP_125", "MO_CCONF_2", "", 109)
    else
        displayHudBanner("BLIP_125", "CELL_840", "", 109)
    end
end

--PgUp alternative spawner toggle
local altSpawnerHotkey
menu.register_callback('ToggleAltSpawnerHotkey', function()
    if not altSpawnerHotkey then
        altSpawnerHotkey = menu.register_hotkey(keycodes.PAGE_UP_KEY, toggleAlternativeSpawner)
    else
        menu.remove_hotkey(altSpawnerHotkey)
        altSpawnerHotkey = nil
    end
end)

----------------------Pickup Spawner--------------------------
local ambient_spawn_trigger = 2707022
local networked_pickup_trigger = 262145 + 31218
local pickup_data_global = 2707016
local ambient_variable_check = 4535851
function createPickup(pos, value)
    local freemode_script = script("freemode")
    if freemode_script:is_active() then
        globals.set_int(networked_pickup_trigger, 0)
        globals.set_uint(ambient_spawn_trigger, 1)
        globals.set_int(pickup_data_global + 1, value) --cash value
        globals.set_float(pickup_data_global + 3, pos.x)
        globals.set_float(pickup_data_global + 4, pos.y)
        globals.set_float(pickup_data_global + 5, pos.z)
        globals.set_uint(ambient_variable_check + 1 + (globals.get_int(pickup_data_global) * 85) + 66 + 2, 2)
    end
end

---------------------Get Player Level-----------------------------
--Global_1845263[PLAYER::PLAYER_ID() /*877*/].f_205.f_6 Level
--.f_3 Wallet, .f_56 cumulative money, .f_28 kills, .f_29 deaths
local playerLevelGlobal = 1845263
getPlayerLevel = function(plyId)
    return globals.get_int(playerLevelGlobal + 1 + (plyId * 877) + 205 + 6)
end

getPlayerWallet = function(plyId)
    return globals.get_int(playerLevelGlobal + 1 + (plyId * 877) + 205 + 3)
end

getPlayerMoney = function(plyId)
    return globals.get_int(playerLevelGlobal + 1 + (plyId * 877) + 205 + 56)
end

getPlayerKd = function(plyId)
    local kills = globals.get_int(playerLevelGlobal + 1 + (plyId * 877) + 205 + 28)
    local deaths = globals.get_int(playerLevelGlobal + 1 + (plyId * 877) + 205 + 29)
    if kills == 0 or deaths == 0 then
        return 0
    end
    return kills / deaths
end

getPlayerKills = function(plyId)
    return globals.get_int(playerLevelGlobal + 1 + (plyId * 877) + 205 + 28)
end

getPlayerDeaths = function(plyId)
    return globals.get_int(playerLevelGlobal + 1 + (plyId * 877) + 205 + 29)
end

function getTopPlayer(getPlayerAttribute, nameOrId)
    local maxAttribute = 0
    local topPlayer

    for i = 0, 31 do
        local ply = player.get_player_ped(i)
        if ply then
            local attribute = getPlayerAttribute(i)
            if attribute and attribute > maxAttribute then
                maxAttribute = attribute
                topPlayer = i
            end
        end
    end
    if not topPlayer then 
		if nameOrId == "name" then
			return "/"
		else
			return "-1"
		end
	end
    if nameOrId == "name" then
        return player.get_player_name(topPlayer) or ""
    elseif nameOrId == "id" then
        return topPlayer
    else
        return maxAttribute
    end
end

---------------------Check Dev DLC -------------------------------
--Global_2657921[bParam1 /*463*/].f_269
local dev_check_global = 2657921
hasDevDLC = function(plyId)
    return globals.get_int(dev_check_global + 1 + (plyId * 463) + 269)
end

----------------------Respawn State (Interior Check)---------------------------
--Global_2657921[iVar0 /*463*/].f_232
local interiorIdGlobal = 2657921
-- Order of States when Dying: -1 0 2 9 99
-- 99 is fully loaded

getPlayerRespawnState = function(plyId)
    return globals.get_int(interiorIdGlobal + 1 + (plyId * 463) + 232)
end

-- -1/1 repair vehicle, 11 flip vehicle, 2-6 are respawn triggers
--Only seem to work on oneself
setPlayerRespawnState = function(plyId, value)
    globals.set_int(interiorIdGlobal + 1 + (plyId * 463) + 232, value)
end

---------------------Player Org---------------------------------
--HUUUUUUUUUGE thanks to book4 on UKC for sharing a bunch of useful globals
--Global_1886967[PLAYER::PLAYER_ID() /*609*/].f_10
--OrgColor is at .f104
local playerOrgGlobal = 1886967
local org_types = { [0] = "CEO", "MC" }
getPlayerOrgType = function(plyId)
    return org_types[globals.get_int(playerOrgGlobal + 1 + (plyId * 609) + 10 + 429)]
end

getPlayerOrgName = function(plyId)
    local orgName = globals.get_string(playerOrgGlobal + 1 + (plyId * 609) + 10 + 105, 30)
    if orgName == "" then
        orgName = "Organisation"
    end
    return orgName
end

getPlayerOrgID = function(plyId)
    return globals.get_int(playerOrgGlobal + 1 + (plyId * 609) + 10)
end

joinPlayerOrg = function(plyId)
    local plyOrgId = getPlayerOrgId(plyId)
    globals.set_int(playerOrgGlobal + 1 + (localplayer:get_player_id() * 609) + 10, plyOrgId)
end

------------------------Set Wanted Level Remote----------------------
--Global_2657921[bVar0 /*463*/].f_214 playerId
--Global_2657704[bVar0 /*463*/].f_215 num of stars (0-5)
local wantedLevelGlobal = 2657921
giveWantedLevel = function(plyId, numStars)
    globals.set_int(wantedLevelGlobal + 1 + (localplayer:get_player_id() * 463) + 214, plyId)
    globals.set_int(wantedLevelGlobal + 1 + (localplayer:get_player_id() * 463) + 215, numStars)
end

---------------------Get PlayerVehicleBlipType------------------
-- Helper Method for working with a set
function utils_Set(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end
--see https://www.unknowncheats.me/forum/3955633-post14596.html
--Global_2657921[player /*463*/].f_73.f_3
interiorBlips = {
    ["INTERIOR"] = true,
    ["LS CUSTOMS"] = true,
    ["CAR_MEET_MODSHOP"] = true,
    ["KOSATKA"] = true,
    ["AMMO NATION"] = true,
    ["LOADING"] = true,
    ["CAR MEET"] = true,
    ["AUTO SHOP"] = true,
    ["CLOTHES"] = true,
    ["HANGAR_MODSHOP"] = true
}
-- Create a lookup table for playerBlipTypes
shortformBlips = {
    ["LOADING"] = "LOAD",
    ["LS CUSTOMS"] = "LSC",
    ["PLANE GHOST"] = "FLY_GHO",
    ["ULTRALIGHT GHOST"] = "UL_GHO",
    ["AMMO NATION"] = "AMMO",
    ["KOSATKA"] = "SUBM",
    ["HEIST BOARD"] = "HEIST",
    ["DELIVERY_MISSION"] = "DELIV",
    ["HANGAR_MODSHOP"] = "HANGR",
    ["BEAST"] = "BEAST",
    ["CASHIER"] = "STORE",
    ["CAR MEET"] = "LSCM",
    ["AUTO SHOP"] = "AUTO",
    ["JUNK PARACHUTE"] = "PRCH",
    ["CLOTHES"] = "CLOTH"
}
local playerBlipTypeGlobal = 2657921
local vehicle_blips = utils_Set({ 262144, 262145, 262148, 262149, 262156, 262208, 262212, 262276, 262277, 262660, 262661, 262724, 262784, 262789, 262788, 786564, 2627888, 2359300 })
local plane_ghost_blips = utils_Set({ 8388612, 8650884, 8651332, 8651396, 8651397, 8650756, 8650757, 8650820, 8651268, 8651269 })
local ultralight_ghost_blips = utils_Set({ 262676, 262740 })
local ls_customs_blip = utils_Set({ 2097280, 2359330, 2359458, 262178 })
local interior_blips = utils_Set({ 262656, 262272, 192, 64, 128, 196, 576, 512, 517, 640, 708, 1 })
local normal_blips = utils_Set({ 4, 5, 68, 132, 516, 580, 644 })
local ls_car_meet = utils_Set({ 2359334, 2359426, 2359296, 262146 })
local cashier_blip = utils_Set({ 2097152 })
local auto_shop = utils_Set({ 2359298, 2359302 })
local beast_blips = utils_Set({ 1048580, 1049092, 1310724, 1310788, 1311236 })
local kosatka_blip = utils_Set({ 262213, 262341, 262336, 262337, 262340, 262720 })
local ammo_nation_blip = utils_Set({ 2 })
local junk_parachute_blip = utils_Set({ 2097156, 2097220 })
local unsure_blips = utils_Set({ 2622788, 262656, 2359299, 524416, 524420 })
local delivery_mission_blips = utils_Set({ 786432, 786436, 786437, 786500, 786560, 786948, 787076, 524292, 524288 })
local ballistic_armor_blip = utils_Set({ 16777220, 16777216 })
local hangar_modshop_blip = utils_Set({ 262274 })
local clothes_store = utils_Set({ 2097282, 2097154 })
local heist_planning_board = utils_Set({ 704 })
local loading_blips = utils_Set({ 0, 6 })
getPlayerBlipType = function(plyId)
    local plyBlip = globals.get_int(playerBlipTypeGlobal + (plyId * 463) + 73 + 3)

    if vehicle_blips[plyBlip] then
        return "VEHICLE"
    elseif interior_blips[plyBlip] then
        return "INTERIOR"
    elseif plane_ghost_blips[plyBlip] then
        return "PLANE GHOST"
    elseif ultralight_ghost_blips[plyBlip] then
        return "ULTRALIGHT GHOST"
    elseif beast_blips[plyBlip] then
        return "BEAST"
    elseif ls_customs_blip[plyBlip] then
        return "LS CUSTOMS"
    elseif clothes_store[plyBlip] then
        return "CLOTHES"
    elseif normal_blips[plyBlip] then
        return "NORMAL"
    elseif cashier_blip[plyBlip] then
        return "CASHIER"
    elseif loading_blips[plyBlip] then
        return "LOADING"
    elseif ls_car_meet[plyBlip] then
        return "CAR MEET"
    elseif junk_parachute_blip[plyBlip] then
        return "JUNK PARACHUTE"
    elseif auto_shop[plyBlip] then
        return "AUTO SHOP"
    elseif hangar_modshop_blip[plyBlip] then
        return "HANGAR_MODSHOP"
    elseif delivery_mission_blips[plyBlip] then
        return "DELIVERY_MISSION"
    elseif kosatka_blip[plyBlip] then
        return "KOSATKA"
    elseif ammo_nation_blip[plyBlip] then
        return "AMMO NATION"
    elseif ballistic_armor_blip[plyBlip] then
        return "BALLISTIC ARMOR"
    elseif heist_planning_board[plyBlip] then
        return "HEIST BOARD"
    elseif unsure_blips[plyBlip] then
        return "UNSURE: " .. plyBlip
    else
        return "Blip:" .. plyBlip
    end
end

getPlayerBlip = function(plyId)
    return globals.get_int(playerBlipTypeGlobal + (plyId * 463) + 73 + 3)
end

---------------------Podium Vehicle Changer---------------------
function setPodiumVehicle(vehicle)
    globals.set_int(4622746, vehicle)
end

------------------Bounty Functions------------------------------
---CREDITS GO ENTIRELY TO APPLEVEGASS!!!!
-- 1.67 globals. Found by: (AppleVegas), updated for 1.69 by Quad_Plex
--easily updated by looking for TXT_BNTY_NPC1 in freemode.c
--Global_2359296[func_900() /*5569*/].f_5151.f_14
local global_bounty_base = 2738587
local global_overrideBounty = 262145
local global_selfBounty_value = 2359296 + 1 + (0 * 5569) + 5151 + 14
--trigger needs to be 0
local global_selfBounty_trigger = global_bounty_base + 1893 + 57
local minPay = 1000
local function calculateFee(amount)
    return amount > minPay and (amount - minPay) * -1 or minPay - amount
end

function overrideBounty(amount)
    local fee = calculateFee(amount)
    globals.set_int(global_overrideBounty + 2348, minPay)
    globals.set_int(global_overrideBounty + 2349, minPay)
    globals.set_int(global_overrideBounty + 2350, minPay)
    globals.set_int(global_overrideBounty + 2351, minPay)
    globals.set_int(global_overrideBounty + 2352, minPay)
    globals.set_int(global_overrideBounty + 7178, fee)
end

function resetOverrideBounty()
    globals.set_int(global_overrideBounty + 2348, 2000)
    globals.set_int(global_overrideBounty + 2349, 4000)
    globals.set_int(global_overrideBounty + 2350, 6000)
    globals.set_int(global_overrideBounty + 2351, 8000)
    globals.set_int(global_overrideBounty + 2352, 10000)
    globals.set_int(global_overrideBounty + 7178, 1000)
end

function sendBountyToYourself(money)
    globals.set_int(global_selfBounty_value, money)
    globals.set_int(global_selfBounty_trigger, 0)
end

function sendBounty(id, amount, skipOverride)
    if player.get_player_ped(id) == localplayer then
        sendBountyToYourself(amount)
        return
    end

    if not skipOverride then
        overrideBounty(amount)
    end
    globals.set_int(global_bounty_base + 4571, id)
    globals.set_int(global_bounty_base + 4571 + 1, 1)
    globals.set_bool(global_bounty_base + 4571 + 2 + 1, true)
    sleep(0.5)
    if not skipOverride then
        resetOverrideBounty()
    end
end

--------------------------Host Check--------------------------
--Global_2650416.f_1
local hostCheckGlobal = 2650416 + 1
function getScriptHostPlayerID()
    return globals.get_int(hostCheckGlobal)
end

---------------------------Host Kick--------------------------
--Global_1877042[PLAYER::PLAYER_ID()]
local playerHostKickGlobal = 1877042
function hostKick(plyId)
    globals.set_int(playerHostKickGlobal + 1 + (plyId), 1)
end

--------------------Spectator Detection--------------------------------
--isTrackedPedVisible
--Global_2657921[PLAYER::PLAYER_ID() /*463*/].f_33
--isVisibleToScript
--Global_2657921[PLAYER::PLAYER_ID() /*463*/].f_34
--Scanned:
--SpecdPlayerId: 2672741

local specPlayerIDGlobal = 2672741
local spectatingPlayerBaseGlobal = 2657921
function getIsTrackedPedVisibleState(plyId)
    return globals.get_int(spectatingPlayerBaseGlobal + 1 + (plyId * 463) + 33)
end

function getIsVisibleToScriptState(plyId)
    return globals.get_int(spectatingPlayerBaseGlobal + 1 + (plyId * 463) + 34)
end

function isSpectatingMe(plyId)
    local ply = player.get_player_ped(plyId)
    if not ply then return end
    local visibleState = getIsTrackedPedVisibleState(plyId)
    local localplayerID = localplayer:get_player_id()
    if localplayerID == -1 and globalLocalplayerID ~= -1 then localplayerID = globalLocalplayerID end
    local isWatchingMe = checkBit(visibleState, localplayerID)
    return isWatchingMe and distanceBetween(player.get_player_ped(), ply) > 200
end

function amISpectating(plyId)
    --Check the scanned Global first, only works in TV spectator mode, not modest's Quick Spectate
    if globals.get_int(specPlayerIDGlobal) == plyId then return true end
    local ply = player.get_player_ped(plyId)
    if not ply then return end
    local ownVisibleState = getIsTrackedPedVisibleState(localplayer:get_player_id())
    local amIWatching = checkBit(ownVisibleState, plyId)
    return amIWatching and distanceBetween(player.get_player_ped(), ply) > 200
end

----------------------------Player Bounty Info-----------------------------
---playerBountyAmount: Global_1835505.f_4[PLAYER::PLAYER_ID() /*3*/].f_1
local playerBountyAmountGlobal = 1835505

hasBounty = function(plyId)
    return getPlayerBountyAmount(plyId) > 0
end

getPlayerBountyAmount = function(plyId)
    return globals.get_int(playerBountyAmountGlobal + 4 + 1 + (plyId * 3) + 1)
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