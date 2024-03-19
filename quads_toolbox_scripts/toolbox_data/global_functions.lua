baseGlobals = {}

------------------Message Display-----------------------
baseGlobals.messageDisplay = {}
baseGlobals.messageDisplay.baseGlobal = 2672741 + 2518 + 1
baseGlobals.messageDisplay.testFunction = function()
    displayHudBanner("FGTXT_F_F3", "RESPAWN_W", "", 109)
end
--Credits to Kiddion for finding this stuff in an older version
--https://www.unknowncheats.me/forum/3523555-post2032.html
function displayHudBanner(headline, subHeadline, variable_text, box_type, skipTimeout)
    if localplayer == nil then return end
    globals.set_string(baseGlobals.messageDisplay.baseGlobal + 21, headline, 16)
    globals.set_string(baseGlobals.messageDisplay.baseGlobal + 8, subHeadline, 32)
    if variable_text ~= "" then
        if type(variable_text) == "number" then
            if checkType(variable_text) == "Int" then
                globals.set_int(baseGlobals.messageDisplay.baseGlobal + 3, variable_text)
            else
                globals.set_float(baseGlobals.messageDisplay.baseGlobal + 3, variable_text)
            end
        elseif type(variable_text) == "string" then
            globals.set_string(baseGlobals.messageDisplay.baseGlobal + 3, variable_text, 32)
        end
    end
    globals.set_int(baseGlobals.messageDisplay.baseGlobal + 1, box_type)
    globals.set_int(baseGlobals.messageDisplay.baseGlobal + 2, 1)

    if skipTimeout then return end

    sleep(2)

    globals.set_int(baseGlobals.messageDisplay.baseGlobal + 1, 1)
    globals.set_int(baseGlobals.messageDisplay.baseGlobal + 2, 1)
end

------------------Vehicle Spawners-----------------------------------
alternative_spawn_toggle = false
baseGlobals.vehicleSpawner = {}
baseGlobals.vehicleSpawner.baseGlobal = 2640095
baseGlobals.vehicleSpawner.testFunction = function()
    createVehicle(joaat("Youga4"), localplayer:get_position() + localplayer:get_heading() * 5)
end
baseGlobals.vehicleSpawner.testFunctionExplanation = "Spawn Youga4 with spawner#1"

baseGlobals.vehicleSpawner2 = {}
baseGlobals.vehicleSpawner2.baseGlobal2 = 2695991
baseGlobals.vehicleSpawner2.testFunction = function()
    local oldToggle = alternative_spawn_toggle
    alternative_spawn_toggle = true
    createVehicle(joaat("PoliceOld2"), localplayer:get_position() + localplayer:get_heading() * 5)
    alternative_spawn_toggle = oldToggle
end
baseGlobals.vehicleSpawner2.testFunctionExplanation = "Spawn PoliceOld2 with spawner#2"
function createVehicle(modelHash, pos, heading)
    if not alternative_spawn_toggle and not player.get_player_ped():is_in_vehicle() then
        globals.set_int(baseGlobals.vehicleSpawner.baseGlobal + 47, modelHash)
        globals.set_float(baseGlobals.vehicleSpawner.baseGlobal + 43, pos.x)
        globals.set_float(baseGlobals.vehicleSpawner.baseGlobal + 44, pos.y)
        globals.set_float(baseGlobals.vehicleSpawner.baseGlobal + 45, pos.z)
        if heading then
            globals.set_float(baseGlobals.vehicleSpawner.baseGlobal + 46, heading)
        end
        globals.set_boolean(baseGlobals.vehicleSpawner.baseGlobal + 42, true)
    else
        globals.set_boolean(baseGlobals.vehicleSpawner2.baseGlobal2 + 5, false) -- SpawnVehicles
        globals.set_boolean(baseGlobals.vehicleSpawner2.baseGlobal2 + 2, false) -- SpawnVehicles
        globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 0, pos.x) -- pos.x
        globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 1, pos.y) -- pos.y
        globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 2, pos.z) -- pos.z
        globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 66, modelHash) -- modelHash
        globals.set_boolean(baseGlobals.vehicleSpawner2.baseGlobal2 + 5, true) -- SpawnVehicles
        globals.set_boolean(baseGlobals.vehicleSpawner2.baseGlobal2 + 2, true) -- SpawnVehicles
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
        altSpawnerHotkey = menu.register_hotkey(find_keycode("ToggleAltSpawnerHotkey"), toggleAlternativeSpawner)
    else
        menu.remove_hotkey(altSpawnerHotkey)
        altSpawnerHotkey = nil
    end
end)

----------------------Pickup Spawner--------------------------
baseGlobals.ambientSpawner = {}
baseGlobals.ambientSpawner.spawn_trigger = 2707022
baseGlobals.ambientSpawner.networked_trigger = 262145 + 31218
baseGlobals.ambientSpawner.pickup_data = 2707016
baseGlobals.ambientSpawner.check = 4535851
baseGlobals.ambientSpawner.testFunction = function()
    createPickup(localplayer:get_position(), 420)
end
function createPickup(pos, value)
    local freemode_script = script("freemode")
    if freemode_script:is_active() then
        globals.set_int(baseGlobals.ambientSpawner.networked_trigger, 0)
        globals.set_uint(baseGlobals.ambientSpawner.spawn_trigger, 1)
        globals.set_int(baseGlobals.ambientSpawner.pickup_data + 1, value) --cash value
        globals.set_float(baseGlobals.ambientSpawner.pickup_data + 3, pos.x)
        globals.set_float(baseGlobals.ambientSpawner.pickup_data + 4, pos.y)
        globals.set_float(baseGlobals.ambientSpawner.pickup_data + 5, pos.z)
        globals.set_uint(baseGlobals.ambientSpawner.check + 1 + (globals.get_int(baseGlobals.ambientSpawner.pickup_data) * 85) + 66 + 2, 2)
    end
end

------------------------------------------------------------------
---------------------Get Player Stats-----------------------------
--Global_1845263[PLAYER::PLAYER_ID() /*877*/].f_205.f_6 Level
--.f_3 Wallet, .f_56 cumulative money, .f_28 kills, .f_29 deaths
baseGlobals.playerLevel = {}
baseGlobals.playerLevel.baseGlobal = 1845263
baseGlobals.playerLevel.testIntRange = function()
    return getPlayerLevel(localplayer:get_player_id())
end
baseGlobals.playerLevel.intRangeExplanation = "Shows your own LVL:"
getPlayerLevel = function(plyId)
    return globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 877) + 205 + 6)
end

getPlayerWallet = function(plyId)
    return globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 877) + 205 + 3)
end

getPlayerMoney = function(plyId)
    return globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 877) + 205 + 56)
end

getPlayerKd = function(plyId)
    local kills = globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 877) + 205 + 28)
    local deaths = globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 877) + 205 + 29)
    if kills == 0 or deaths == 0 then
        return 0
    end
    return kills / deaths
end

getPlayerKills = function(plyId)
    return globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 877) + 205 + 28)
end

getPlayerDeaths = function(plyId)
    return globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 877) + 205 + 29)
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

-------------------------------------------------------------------
---------------------Check Dev DLC --------------------------------
--Global_2657921[bParam1 /*463*/].f_269
baseGlobals.devCheck = {}
baseGlobals.devCheck.baseGlobal = 2657921
hasDevDLC = function(plyId)
    return globals.get_int(baseGlobals.devCheck.baseGlobal + 1 + (plyId * 463) + 269)
end

-------------------------------------------------------------------
----------------------Respawn State (Interior Check)----------------
--Global_2657921[iVar0 /*463*/].f_232
baseGlobals.respawnState = {}
baseGlobals.respawnState.baseGlobal = 2657921
baseGlobals.respawnState.testIntRange = function()
    return getPlayerRespawnState(localplayer:get_player_id())
end
baseGlobals.respawnState.intRangeExplanation = "Should be 99 while idling outside"
-- Order of States when Dying: -1 0 2 9 99
-- 99 is fully loaded

getPlayerRespawnState = function(plyId)
    return globals.get_int(baseGlobals.respawnState.baseGlobal + 1 + (plyId * 463) + 232)
end

-- -1/1 repair vehicle, 11 flip vehicle, 2-6 are respawn triggers
--Only seem to work on oneself
setPlayerRespawnState = function(plyId, value)
    globals.set_int(baseGlobals.respawnState.baseGlobal + 1 + (plyId * 463) + 232, value)
end

---------------------Player Org---------------------------------
--HUUUUUUUUUGE thanks to book4 on UKC for sharing a bunch of useful globals
--Global_1886967[PLAYER::PLAYER_ID() /*609*/].f_10
--OrgColor is at .f104
baseGlobals.playerOrg = {}
baseGlobals.playerOrg.baseGlobal = 1886967
baseGlobals.playerOrg.bareStringCheck = function()
    return getPlayerOrgID(localplayer:get_player_id()) ~= -1 and "Own Org Name: " .. getPlayerOrgName(localplayer:get_player_id()) or "No Organisation found"
end
baseGlobals.playerOrg.intRangeExplanation = "-1 if not in Org, else expect a value"
local org_types = { [0] = "CEO", "MC" }
getPlayerOrgType = function(plyId)
    return org_types[globals.get_int(baseGlobals.playerOrg.baseGlobal + 1 + (plyId * 609) + 10 + 429)]
end

getPlayerOrgName = function(plyId)
    local orgName = globals.get_string(baseGlobals.playerOrg.baseGlobal + 1 + (plyId * 609) + 10 + 105, 30)
    if orgName == "" then
        orgName = "Organisation"
    end
    return orgName
end

getPlayerOrgID = function(plyId)
    return globals.get_int(baseGlobals.playerOrg.baseGlobal + 1 + (plyId * 609) + 10)
end

joinPlayerOrg = function(plyId)
    local plyOrgId = getPlayerOrgId(plyId)
    globals.set_int(baseGlobals.playerOrg.baseGlobal + 1 + (localplayer:get_player_id() * 609) + 10, plyOrgId)
end

------------------------Set Wanted Level Remote----------------------
--Global_2657921[bVar0 /*463*/].f_214 playerId
--Global_2657704[bVar0 /*463*/].f_215 num of stars (0-5)
baseGlobals.wantedLevel = {}
baseGlobals.wantedLevel.baseGlobal = 2657921
baseGlobals.wantedLevel.testFunction = function()
    giveWantedLevel(localplayer:get_player_id(), 5)
    sleep(0.5)
    giveWantedLevel(localplayer:get_player_id(), 0)
end
baseGlobals.wantedLevel.testFunctionExplanation = "Give yourself 5 Stars"
giveWantedLevel = function(plyId, numStars)
    globals.set_int(baseGlobals.wantedLevel.baseGlobal + 1 + (localplayer:get_player_id() * 463) + 214, plyId)
    globals.set_int(baseGlobals.wantedLevel.baseGlobal + 1 + (localplayer:get_player_id() * 463) + 215, numStars)
end

----------------------------------------------------------------
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
baseGlobals.blipType = {}
baseGlobals.blipType.baseGlobal = 2657921
baseGlobals.blipType.testIntRange = function()
    return getPlayerBlip(localplayer:get_player_id())
end
baseGlobals.blipType.intRangeExplanation = "Should be 4 while idling outside"
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
    local plyBlip = globals.get_int(baseGlobals.blipType.baseGlobal + (plyId * 463) + 73 + 3)

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
    return globals.get_int(baseGlobals.blipType.baseGlobal + (plyId * 463) + 73 + 3)
end

----------------------------------------------------------------
---------------------Podium Vehicle Changer---------------------
baseGlobals.podiumVehicle = {}
baseGlobals.podiumVehicle.baseGlobal = 289178
baseGlobals.podiumVehicle.testFunction = function()
    setPodiumVehicle(joaat("Tug"))
end
baseGlobals.podiumVehicle.testFunctionExplanation = "Change Podium Veh. to Tugboat"
function setPodiumVehicle(vehicleHash)
    globals.set_int(baseGlobals.podiumVehicle.baseGlobal, vehicleHash)
end

function getPodiumVehicle()
    return globals.get_int(baseGlobals.podiumVehicle.baseGlobal)
end



------------------------------------------------------------------
------------------Bounty Functions--------------------------------
---CREDITS GO ENTIRELY TO APPLEVEGASS!!!!
-- 1.67 globals. Found by: (AppleVegas), updated for 1.69 by Quad_Plex
--easily updated by looking for TXT_BNTY_NPC1 in freemode.c
--Global_2359296[func_900() /*5569*/].f_5151.f_14
baseGlobals.bountyGlobals = {}
baseGlobals.bountyGlobals.bounty_base = 2738587
baseGlobals.bountyGlobals.bounty_overrideBounty = 262145
baseGlobals.bountyGlobals.bounty_selfValue = 2359296 + 1 + (0 * 5569) + 5151 + 14
baseGlobals.bountyGlobals.testFunction = function()
    sendBountyToYourself(420)
end
baseGlobals.bountyGlobals.testFunctionExplanation = "Set 420 Bounty on yourself"
local minPay = 1000
local function calculateFee(amount)
    return amount > minPay and (amount - minPay) * -1 or minPay - amount
end

function overrideBounty(amount)
    local fee = calculateFee(amount)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2348, minPay)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2349, minPay)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2350, minPay)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2351, minPay)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2352, minPay)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 7178, fee)
end

function resetOverrideBounty()
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2348, 2000)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2349, 4000)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2350, 6000)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2351, 8000)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2352, 10000)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 7178, 1000)
end

function sendBountyToYourself(money)
    globals.set_int(baseGlobals.bountyGlobals.bounty_selfValue, money)
    globals.set_int(baseGlobals.bountyGlobals.bounty_base + 1893 + 57, 0)
end

function sendBounty(id, amount, skipOverride)
    if player.get_player_ped(id) == localplayer then
        sendBountyToYourself(amount)
        return
    end

    if not skipOverride then
        overrideBounty(amount)
    end
    globals.set_int(baseGlobals.bountyGlobals.bounty_base + 4571, id)
    globals.set_int(baseGlobals.bountyGlobals.bounty_base + 4571 + 1, 1)
    globals.set_bool(baseGlobals.bountyGlobals.bounty_base + 4571 + 2 + 1, true)
    sleep(0.5)
    if not skipOverride then
        resetOverrideBounty()
    end
end

--------------------------------------------------------------
--------------------------Host Check--------------------------
--Global_2650416.f_1
baseGlobals.hostCheck = {}
baseGlobals.hostCheck.baseGlobal = 2650416 + 1
baseGlobals.hostCheck.testCheck = function()
    return getScriptHostPlayerID() == localplayer:get_player_id()
end
baseGlobals.hostCheck.checkExplanation = "(Solo Session) Am I Host?:"
function getScriptHostPlayerID()
    return globals.get_int(baseGlobals.hostCheck.baseGlobal)
end

---------------------------Host Kick--------------------------
--Global_1877042[PLAYER::PLAYER_ID()]
baseGlobals.hostKick = {}
baseGlobals.hostKick.baseGlobal = 1877042
baseGlobals.hostKick.testFunction = function()
    hostKick(localplayer:get_player_id())
end
baseGlobals.hostKick.testFunctionExplanation = "(Solo session) Kick yourself"
function hostKick(plyId)
    globals.set_int(baseGlobals.hostKick.baseGlobal + 1 + (plyId), 1)
end

--------------------Spectator Detection--------------------------------
--isTrackedPedVisible
--Global_2657921[PLAYER::PLAYER_ID() /*463*/].f_33
--isVisibleToScript
--Global_2657921[PLAYER::PLAYER_ID() /*463*/].f_34
--Scanned:
--SpecdPlayerId: 2672741

baseGlobals.spectatorCheck = {}
baseGlobals.spectatorCheck.specPlayerBaseGlobal = 2657921
baseGlobals.spectatorCheck.testCheck = function()
    return amISpectating(localplayer:get_player_id())
end
baseGlobals.spectatorCheck.checkExplanation = "Am I spectating myself?"

baseGlobals.spectatorCheck2 = {}
baseGlobals.spectatorCheck2.tvSpectatePlyIDGlobal = 2672741
baseGlobals.spectatorCheck2.testIntRange = function()
    return globals.get_int(baseGlobals.spectatorCheck2.tvSpectatePlyIDGlobal)
end
baseGlobals.spectatorCheck2.intRangeExplanation = "Currently watched player on TV:"
function getIsTrackedPedVisibleState(plyId)
    return globals.get_int(baseGlobals.spectatorCheck.specPlayerBaseGlobal + 1 + (plyId * 463) + 33)
end

--Unused, but still keeping it for documentation's sake
function getIsVisibleToScriptState(plyId)
    return globals.get_int(baseGlobals.spectatorCheck.specPlayerBaseGlobal + 1 + (plyId * 463) + 34)
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
    if globals.get_int(baseGlobals.spectatorCheck2.tvSpectatePlyIDGlobal) == plyId then return true end
    local ply = player.get_player_ped(plyId)
    if not ply then return end
    local localplayerID = localplayer:get_player_id()
    if localplayerID == -1 and globalLocalplayerID ~= -1 then localplayerID = globalLocalplayerID end
    local ownVisibleState = getIsTrackedPedVisibleState(localplayerID)
    local amIWatching = checkBit(ownVisibleState, plyId)
    return amIWatching and distanceBetween(player.get_player_ped(), ply) > 200
end

---------------------------------------------------------------------------
----------------------------Player Bounty Info-----------------------------
---playerBountyAmount: Global_1835505.f_4[PLAYER::PLAYER_ID() /*3*/].f_1
baseGlobals.bountyInfo = {}
baseGlobals.bountyInfo.playerBountyInfoGlobal = 1835505
baseGlobals.bountyInfo.testIntRange = function()
    return getPlayerBountyAmount(localplayer:get_player_id())
end
baseGlobals.bountyInfo.intRangeExplanation = "Own Bounty Value:"

hasBounty = function(plyId)
    return getPlayerBountyAmount(plyId) > 0
end

getPlayerBountyAmount = function(plyId)
    return globals.get_int(baseGlobals.bountyInfo.playerBountyInfoGlobal + 4 + 1 + (plyId * 3) + 1)
end