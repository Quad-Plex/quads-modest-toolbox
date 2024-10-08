baseGlobals = {}

------------------------------Localplayer ID getter----------------------------
baseGlobals.localPlayerGlobal = {}
baseGlobals.localPlayerGlobal.baseGlobal = 2672855
baseGlobals.localPlayerGlobal.bareStringCheck = function()
    return "LocalplayerID from Global: " .. tostring(globals.get_int(baseGlobals.localPlayerGlobal.baseGlobal))
end

function getLocalplayerID()
    if (localplayer and localplayer:get_player_id() ~= -1) then
        return localplayer:get_player_id()
    else
        local globalID = globals.get_int(baseGlobals.localPlayerGlobal.baseGlobal)
        return globalID or -1
    end
end

function getOrSetPlayerPedID(set)
    if set then
        globals.set_int(baseGlobals.localPlayerGlobal.baseGlobal + 4 + 15, set)
    else
        return globals.get_int(baseGlobals.localPlayerGlobal.baseGlobal + 4 + 15)
    end
end

baseGlobals.playerPedGlobal = {}
baseGlobals.playerPedGlobal.baseGlobal = 1906887
baseGlobals.playerPedGlobal.freemode_local = 458 + 641
baseGlobals.playerPedGlobal.bareStringCheck = function()
    return "Own PlayerPed: " .. tostring(getPlayerPed(getLocalplayerID()))
end

function getPlayerPed(playerID)
    if not globals.get_bool(baseGlobals.playerPedGlobal.baseGlobal + 1 + (getLocalplayerID() * 304) + 29 + 18) then
        globals.set_bool(baseGlobals.playerPedGlobal.baseGlobal + 1 + (getLocalplayerID() * 304) + 29 + 18, true)
    end
    if script("freemode"):is_active() then
        return script("freemode"):get_int(baseGlobals.playerPedGlobal.freemode_local + 1 + (playerID * 3) + 2)
    end
end

------------------Message Display-----------------------
--TODO: only displayBoxType 39 showed a weird string on the bottom sometimes, which seemed to contain a playername
--after session switch that string disappeared - has to be configurable somehow
local timeoutDuration
baseGlobals.messageDisplay = {}
baseGlobals.messageDisplay.baseGlobal = 2672855 + 2557 + 1
baseGlobals.messageDisplay.testFunction = function()
    displayHudBanner("FGTXT_F_F3", "RESPAWN_W", "", 108)
end
--Credits to Kiddion for finding this stuff in an older version
--https://www.unknowncheats.me/forum/3523555-post2032.html
function displayHudBanner(headline, subHeadline, variable_text, box_type)
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
    timeoutDuration = 2
end

function OnScriptsLoadedGlobal()
    while true do
        while timeoutDuration do
            if timeoutDuration > 0 then
                sleep(0.1)
                timeoutDuration = timeoutDuration - 0.1
            elseif timeoutDuration <= 0 then
                timeoutDuration = nil
                --Setting both globals to 1 removes the currently displayed message
                globals.set_int(baseGlobals.messageDisplay.baseGlobal + 1, 1)
                globals.set_int(baseGlobals.messageDisplay.baseGlobal + 2, 1)
            end
        end
        sleep(0.4)
    end
end

menu.register_callback('OnScriptsLoaded', OnScriptsLoadedGlobal)

-----------------------------------------------------------------------------
------------------------ Vehicle Spawners -----------------------------------
local noMods = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}

baseGlobals.vehicleSpawner = {}
baseGlobals.vehicleSpawner.baseGlobal = 2640096
baseGlobals.vehicleSpawner.testFunction = function()
    createVehicle(joaat("Youga4"), localplayer:get_position() + localplayer:get_heading() * 5)
end
baseGlobals.vehicleSpawner.testFunctionExplanation = "Spawn Youga4 with spawner#1"


baseGlobals.vehicleSpawner2 = {}
baseGlobals.vehicleSpawner2.baseGlobal2 = 2696212
baseGlobals.vehicleSpawner2.testFunction = function()
    createVehicle(joaat("PoliceOld2"), localplayer:get_position() + localplayer:get_heading() * 5, nil, nil, nil, true)
end
baseGlobals.vehicleSpawner2.testFunctionExplanation = "Spawn PoliceOld2 with spawner#2"

baseGlobals.vehicleSpawnerNetID = {}
baseGlobals.vehicleSpawnerNetID.vehNetIDGlobal = 2738934
baseGlobals.vehicleSpawnerNetID.bareStringCheck = function()
    return "VehNetID (last spawned): " .. tostring(getNetIDOfLastSpawnedVehicle())
end

function getNetIDOfLastSpawnedVehicle()
    return globals.get_int(baseGlobals.vehicleSpawnerNetID.vehNetIDGlobal + 6799)
end

function createVehicle(modelHash, pos, heading, skip_remove_current, mod, alternative_spawn_toggle, random_details, max_details, custom_details_table)
    if not type(modelHash):match("number") then
        modelHash = joaat(modelHash)
    end
    --###SPAWNER #1 (With heading, spammable, without mods)
    if not alternative_spawn_toggle and not player.get_player_ped():is_in_vehicle() then
        local oldNetID = getNetIDOfLastSpawnedVehicle()
        globals.set_int(baseGlobals.vehicleSpawner.baseGlobal + 48, modelHash)
        globals.set_float(baseGlobals.vehicleSpawner.baseGlobal + 44, pos.x)
        globals.set_float(baseGlobals.vehicleSpawner.baseGlobal + 45, pos.y)
        globals.set_float(baseGlobals.vehicleSpawner.baseGlobal + 46, pos.z)
        if heading then
            globals.set_float(baseGlobals.vehicleSpawner.baseGlobal + 47, heading)
        end
        globals.set_boolean(baseGlobals.vehicleSpawner.baseGlobal + 43, true)
        sleep(0.15)
        local newNetID = getNetIDOfLastSpawnedVehicle()
        if newNetID ~= oldNetID then
            return
        end
    end
    --###SPAWNER #2 (Without heading, with mods, more reliable)
    if not vehicle_is_creating then
        vehicle_is_creating = true
        --if (not globals.get_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 2) and not globals.get_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 5)) then
            local primaryColor = custom_details_table and custom_details_table[3] or (random_details and math.random(0, 161)) or (max_details and 159) or 0
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 5, primaryColor) --primary color selection (see eVehicleColor)
            local secondaryColor = custom_details_table and custom_details_table[4] or (random_details and math.random(0, 161)) or (max_details and 159) or 0
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 6, secondaryColor) --secondary color selection
            local pearlescentColor = custom_details_table and custom_details_table[5] or (random_details and math.random(0, 161)) or (max_details and 159) or 0
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 7, pearlescentColor) --pearlescent color selection
            local wheelColor = custom_details_table and custom_details_table[6] or (random_details and math.random(0, 161)) or (max_details and 159) or 0
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 8, wheelColor) --wheel color selection
            if not mod then mod = noMods end
            --Write each mod integer into the globals in an array
            for i = 1, globals.get_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 9) do
                --see eVehicleModType
                globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 9 + i, mod[i] or 0)
            end
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 62, math.random(0, 255)) --VEHICLE::SET_VEHICLE_TYRE_SMOKE_COLOR Red
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 63, math.random(0, 255)) --Green
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 64, math.random(0, 255)) --Blue
            local windowTint = custom_details_table and custom_details_table[2] or (random_details and math.random(0, 4)) or (max_details and 3) or 0
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 65, windowTint) --Window Tint
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 66, modelHash) --veh hash
            local vehWheelType = custom_details_table and custom_details_table[1] or (random_details and math.random(0, 12)) or (max_details and 12) or 0
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 69, vehWheelType) --veh wheel type (category) see eVehicleWheelType
            --globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 71, math.random(0, 255)) --Custom Primary/Secondary Color Red
            --globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 72, math.random(0, 255)) --Green
            --globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 73, math.random(0, 255)) --Blue (has to be enabled via flag in f_77)
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 74, math.random(0, 255)) --Neon color Red
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 75, math.random(0, 255)) --Green
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 76, math.random(0, 255)) --Blue
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 77, -264238592) --Bit-Storage for veh flags 0-8: veh-specific, reserved, 9:bulletproof tires, 10: bool vehicle_is_stolen, 11: Crew Emblem  12: custom secondary color, 13: custom primary color, 27: bool IgnoredByQuickSave decor 28: Neon Front, 29: Neon Back, 30: Neon Left, 31: Neon Right
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 79, 1) --custom Horn                                     --1111111111111111111111111111111111110000010000000000101000000000
            globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 80, 0) --Dirt Level (Float between 0 and 1.0)
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 94, 0) --switch-case: 0: nil, 1: set decor player_vehicle, 2: set decor veh_modded_by_player
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 95, 15) --Bit-Storage that gets checked when previous global sets 1 or 2 (setting all to true 1111 is the easiest way)
            local interiorColor = custom_details_table and custom_details_table[7] or (random_details and math.random(0, 161)) or (max_details and 159) or 0
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 97, interiorColor) --Interior Color
            local dashboardColor = custom_details_table and custom_details_table[8] or (random_details and math.random(0, 161)) or (max_details and 159) or 0
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 97, dashboardColor) --Dashboard Interior Color
            globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 102, 1) --Wheel Upgrade (2=Standard, 1=Bulletproof, 3=drift tyres)
            if not skip_remove_current then
                globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 0, pos.x) --Spawn location xyz
                globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 1, pos.y)
                globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 2, -300)
                globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 3, false) --Spawn trigger for pegasus vehicle
                globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 2, true) --Spawn trigger #1
                globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 5, true) --Spawn trigger #2
                local counter = 0
                repeat
                    counter = counter + 1
                until (not globals.get_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 2) and not globals.get_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 5)) or counter > 426900 --Wait for under-map spawn to complete
            end
            globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 0, pos.x)
            globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 1, pos.y)
            globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 2, pos.z)
            globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 3, false) --Spawn trigger for pegasus vehicle
            globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 2, true) --Spawn trigger #1
            globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 5, true) --Spawn trigger #2
            local counter = 0
            repeat
                counter = counter + 1
            until (not globals.get_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 2) and not globals.get_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 5)) or counter > 426900 --Spawn again at correct coords, removing any vehicle in the way
        --end
        globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 2, false) --Spawn trigger #1
        globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 3, false) --Pegasus Spawn trigger
        globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 5, false) --Spawn trigger #2
        vehicle_is_creating = nil
        return getNetIDOfLastSpawnedVehicle()
    end
end
--thanks to @Alice2333 on UKC for showing me the second spawner code

------------------------------------------------------------------------------------------------
----------------------------------- set ped into vehicle ---------------------------------------
baseGlobals.setIntoVehicle = {}
baseGlobals.setIntoVehicle.baseGlobal = 2738934
baseGlobals.setIntoVehicle.forceControl = 2635563
baseGlobals.setIntoVehicle.bareStringCheck = function()
    return "Using Veh with ID:: " .. tostring(getVehicleForPlayerID() or "")
end

local function getForcedVehicleHandle(playerID)
    local oldVehicleNetIDValue = globals.get_int(baseGlobals.setIntoVehicle.baseGlobal + 7060)
    local playerPed = getPlayerPed(playerID)
    local count = 0
    while true and (count < 10000) do
        --Force a different playerPed into the function that gets the veh net ID
        getOrSetPlayerPedID(playerPed)
        local newVehicleNetIDValue = globals.get_int(baseGlobals.setIntoVehicle.baseGlobal + 7060)
        --Hope that the game used that Ped to get a different car net ID
        if (newVehicleNetIDValue ~= oldVehicleNetIDValue) then
            return newVehicleNetIDValue
        end
        count = count + 1
    end
end

function getVehicleForPlayerID(playerID)
    if not playerID or playerID == getLocalplayerID() then
        if (globals.get_int(baseGlobals.setIntoVehicle.baseGlobal + 7060) ~= 0) then
            return globals.get_int(baseGlobals.setIntoVehicle.baseGlobal + 7060) --ped:get_vehicle_ped_is_in(Global_2672741.f_4.f_15
        end
    else
        local player = player.get_player_ped(playerID)
        if player then
            if localplayer:is_in_vehicle() then
                if (localplayer:get_current_vehicle() == player:get_current_vehicle()) then
                    return globals.get_int(baseGlobals.setIntoVehicle.baseGlobal + 7060)
                end
            end
            return getForcedVehicleHandle(playerID)
        end
    end
end

function setPedIntoVehicle(vehicleNetID, oldPos, noFreeze)
    local oldVeh
    if localplayer:is_in_vehicle() then
        oldVeh = localplayer:get_current_vehicle()
    end
    if vehicleNetID and vehicleNetID ~= 0 then
        local i = 0
        repeat
            if not noFreeze then
                localplayer:set_freeze_momentum(true)
                localplayer:set_no_ragdoll(true)
                localplayer:set_config_flag(292, true)
            end
            globals.set_int(baseGlobals.setIntoVehicle.forceControl + 3184, vehicleNetID) --Network request control of entity
            setPlayerRespawnState(getLocalplayerID(), 5)
            globals.set_int(baseGlobals.setIntoVehicle.forceControl + 614, 5) --ped:set_ped_into_vehicle set in #1
            if (i == 5) then
                break
            end
            i = i+1
            sleep(0.1)
        until (getVehicleForPlayerID() == vehicleNetID)
        sleep(0.2)
    end
    setPlayerRespawnState(getLocalplayerID(), 9) --setting respawn to 9 gives back player control
    globals.set_int(baseGlobals.setIntoVehicle.forceControl + 3184, -1) --Network request control of entity
    globals.set_int(baseGlobals.setIntoVehicle.forceControl + 614, -1) --ped:set_ped_into_vehicle set in #1
    if oldPos and (not localplayer:is_in_vehicle() or (localplayer:get_current_vehicle() == oldVeh)) then
        --Assume entering the vehicle failed
        if distanceBetween(localplayer, oldPos, true) > 10 then
            nativeTeleport(oldPos)
        end
    end
    if not noFreeze then
        localplayer:set_freeze_momentum(false)
        localplayer:set_no_ragdoll(false)
        localplayer:set_config_flag(292, false)
    end
    fixPedVehTeleport()
end

----------------------Pickup Spawner--------------------------
baseGlobals.ambientSpawner = {}
baseGlobals.ambientSpawner.spawn_trigger = 2707342
baseGlobals.ambientSpawner.networked_trigger = 262145 + 31218
baseGlobals.ambientSpawner.pickup_data = 2707336
baseGlobals.ambientSpawner.check = 4535950
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
baseGlobals.playerLevel.baseGlobal = 1845281
baseGlobals.playerLevel.testIntRange = function()
    return getPlayerLevel(getLocalplayerID())
end
baseGlobals.playerLevel.intRangeExplanation = "Shows your own LVL:"
getPlayerLevel = function(plyId)
    return globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 883) + 206 + 6)
end

getPlayerWalletAmount = function(plyId)
    return globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 883) + 206 + 3)
end

getPlayerBankAmount = function(plyId)
    return globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 883) + 206 + 56)
end

getPlayerKd = function(plyId)
    local kills = globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 883) + 206 + 28)
    local deaths = globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 883) + 206 + 29)
    if kills == 0 or deaths == 0 then
        return 0
    end
    return kills / deaths
end

getPlayerKills = function(plyId)
    return globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 883) + 206 + 28)
end

getPlayerDeaths = function(plyId)
    return globals.get_int(baseGlobals.playerLevel.baseGlobal + 1 + (plyId * 883) + 206 + 29)
end

function getTopPlayer(getPlayerAttribute, nameOrId, findMin)
    local topAttribute
    local topPlayer

    if findMin then
        topAttribute = math.huge  -- Use a very high initial value to find the minimum
    else
        topAttribute = -math.huge  -- Use a very low initial value to find the maximum
    end

    for i = 0, 31 do
        local ply = player.get_player_ped(i)
        if ply then
            if getPlayerBlipType(i) == "LOADING" then goto skip end
            local attribute = getPlayerAttribute(i)
            if attribute then
                if ((findMin and attribute < topAttribute) or (not findMin and attribute > topAttribute)) and attribute > 0 then
                    topAttribute = attribute
                    topPlayer = i
                end
            end
            ::skip::
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
        return topAttribute
    end
end

-------------------------------------------------------------------
---------------------Check Dev DLC --------------------------------
--Global_2657921[bParam1 /*463*/].f_269
baseGlobals.devCheck = {}
baseGlobals.devCheck.baseGlobal = 2657971
hasDevDLC = function(plyId)
    return globals.get_int(baseGlobals.devCheck.baseGlobal + 1 + (plyId * 465) + 270) ~= 0
end

-------------------------------------------------------------------
----------------------Respawn State (Interior Check)----------------
--Global_2657921[iVar0 /*463*/].f_232
baseGlobals.respawnState = {}
baseGlobals.respawnState.baseGlobal = 2657971
baseGlobals.respawnState.testIntRange = function()
    return getPlayerRespawnState(getLocalplayerID())
end
baseGlobals.respawnState.intRangeExplanation = "Should be 99 while idling outside"
-- Order of States when Dying: -1 0 2 9 99
-- 99 is fully loaded

getPlayerRespawnState = function(plyId)
    return globals.get_int(baseGlobals.respawnState.baseGlobal + 1 + (plyId * 465) + 233)
end

-- -1/1 repair vehicle, 11 flip vehicle, 2-6 are respawn triggers
--Only seem to work on oneself
setPlayerRespawnState = function(plyId, respawnState)
    globals.set_int(baseGlobals.respawnState.baseGlobal + 1 + (plyId * 465) + 233, respawnState)
end

---------------------Player Org---------------------------------
--HUUUUUUUUUGE thanks to book4 on UKC for sharing a bunch of useful globals
--Global_1886967[PLAYER::PLAYER_ID() /*609*/].f_10
--OrgColor is at .f104
baseGlobals.playerOrg = {}
baseGlobals.playerOrg.baseGlobal = 1887305
baseGlobals.playerOrg.bareStringCheck = function()
    return getPlayerOrgID(getLocalplayerID()) ~= -1 and "Own Org Name: " .. tostring(getPlayerOrgName(getLocalplayerID())) or "No Organisation found"
end
local org_types = { [0] = "CEO", "MC" }
getPlayerOrgType = function(plyId)
    return org_types[globals.get_int(baseGlobals.playerOrg.baseGlobal + 1 + (plyId * 610) + 10 + 430)]
end

getPlayerOrgName = function(plyId)
    local orgName = globals.get_string(baseGlobals.playerOrg.baseGlobal + 1 + (plyId * 610) + 10 + 105, 30)
    if orgName == "" then
        orgName = "Organisation"
    end
    return orgName
end

getPlayerOrgID = function(plyId)
    return globals.get_int(baseGlobals.playerOrg.baseGlobal + 1 + (plyId * 610) + 10)
end

joinPlayerOrg = function(plyId)
    local plyOrgId = getPlayerOrgID(plyId)
    globals.set_int(baseGlobals.playerOrg.baseGlobal + 1 + (getLocalplayerID() * 610) + 10, plyOrgId)
end

------------------------Set Wanted Level Remote----------------------
--Global_2657921[bVar0 /*463*/].f_214 playerId
--Global_2657704[bVar0 /*463*/].f_215 num of stars (0-5)
baseGlobals.wantedLevel = {}
baseGlobals.wantedLevel.baseGlobal = baseGlobals.devCheck.baseGlobal
baseGlobals.wantedLevel.testFunction = function()
    giveWantedLevel(getLocalplayerID(), 5)
    sleep(0.5)
    giveWantedLevel(getLocalplayerID(), 0)
end
baseGlobals.wantedLevel.testFunctionExplanation = "Give yourself 5 Stars"
giveWantedLevel = function(plyId, numStars)
    globals.set_int(baseGlobals.wantedLevel.baseGlobal + 1 + (getLocalplayerID() * 465) + 215, plyId)
    globals.set_int(baseGlobals.wantedLevel.baseGlobal + 1 + (getLocalplayerID() * 465) + 216, numStars)
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
    ["LS_CUSTOMS"] = true,
    ["KOSATKA"] = true,
    ["AMMO_NATION"] = true,
    ["LOADING"] = true,
    ["CAR_MEET"] = true,
    ["MOD_SHOP"] = true,
    ["CLOTHES_SHOP"] = true,
    ["SHOP"] = true,
    ["CASHIER"] = true,
    ["HEIST_BOARD"] = true
}

vehicleBlips = {
    ["VEHICLE"] = true,
    ["PLANE_GHOST"] = true,
    ["ULTRALIGHT_GHOST"] = true,
    ["JUNK_BIKE"] = true
}
-- Create a lookup table for playerBlipTypes
shortformBlips = {
    ["LOADING"] = "LOAD",
    ["LS_CUSTOMS"] = "LSC",
    ["PLANE_GHOST"] = "FLY_GHO",
    ["ULTRALIGHT_GHOST"] = "UL_GHO",
    ["AMMO_NATION"] = "AMMO",
    ["KOSATKA"] = "SUBM",
    ["HEIST_BOARD"] = "HEIST",
    ["DELIVERY_MISSION"] = "DELIV",
    ["BEAST"] = "BEAST",
    ["CASHIER"] = "STORE",
    ["CAR_MEET"] = "LSCM",
    ["MOD_SHOP"] = "MOD_SHP",
    ["JUNK_PARACHUTE"] = "JPRCH",
    ["JUNK_BIKE"] = "JBIKE",
    ["SHOP"] = "SHOP",
    ["BALLISTIC_ARMOR"] = "ARMR",
    ["PREP_MISSION"] = "PREP",
    ["CLOTHES_SHOP"] = "CLOTH"
}

local vehicle_blips = utils_Set({ 262144, 262145, 262148, 262149, 262156, 262164, 262165, 262208, 262212, 262248, 262277, 262660, 262661, 262724, 262784, 262789, 262788, 786564, 2627888, 2359300 })
local plane_ghost_blips = utils_Set({ 8388612, 8650884, 8651332, 8651396, 8651397, 8650756, 8650757, 8650820, 8651268, 8651269 })
local ultralight_ghost_blips = utils_Set({ 262676, 262740 })
local ls_customs_blip = utils_Set({ 2097280, 2359330, 2359458, 262178 })
local interior_blips = utils_Set({ 12, 20, 262274, 262656, 262272, 192, 128, 196, 576, 512, 517, 640, 708, 1 })
local normal_blips = utils_Set({ 4, 5, 68, 132, 133, 140, 516, 580, 644, 645 })
local ls_car_meet = utils_Set({ 2359334, 2359426, 2359296, 262146 })
local cashier_blip = utils_Set({ 2097152 })
local clothes_shop_blip = utils_Set( { 130 } )
local auto_shop = utils_Set({ 2359298, 2359302 })
local beast_blips = utils_Set({ 1048580, 1049092, 1310724, 1310788, 1311236, 1572868, 1835012, 1835524 })
local kosatka_blip = utils_Set({ 262213, 262276, 262341, 262336, 262337, 262340, 262720 })
local ammo_nation_blip = utils_Set({ 2 })
local junk_parachute_blip = utils_Set({ 2097156, 2097220 })
local unsure_blips = utils_Set({ 2622788, 262656, 2359299, 2359812 })
local delivery_mission_blips = utils_Set({ 524256, 524292, 524288, 524293, 524416, 524420, 524932, 786432, 786436, 786437, 786500, 786560, 786948, 787076, 9175045, 9175044 })
local ballistic_armor_blip = utils_Set({ 16777220, 16777216, 16777348, 17039364, 17039876 })
local shop_blips = utils_Set({ 2097282, 2097154 })
local heist_planning_board = utils_Set({ 704 })
local loading_blips = utils_Set({ 0, 6, 64, 65 })
local prep_mission_blips = utils_Set({524804})
local junk_bike_blips = utils_Set({ 2359424, 2359428 })

baseGlobals.blipType = {}
baseGlobals.blipType.baseGlobal = 2657971
baseGlobals.blipType.testIntRange = function()
    return getPlayerBlip(getLocalplayerID())
end
baseGlobals.blipType.intRangeExplanation = "Should be 4 while idling outside"

getPlayerBlip = function(plyId)
    return globals.get_int(baseGlobals.blipType.baseGlobal + (plyId * 465) + 74 + 3)
end

getPlayerBlipType = function(plyId)
    local plyBlip = getPlayerBlip(plyId)

    if vehicle_blips[plyBlip] then
        return "VEHICLE"
    elseif interior_blips[plyBlip] then
        return "INTERIOR"
    elseif plane_ghost_blips[plyBlip] then
        return "PLANE_GHOST"
    elseif ultralight_ghost_blips[plyBlip] then
        return "ULTRALIGHT_GHOST"
    elseif beast_blips[plyBlip] then
        return "BEAST"
    elseif ls_customs_blip[plyBlip] then
        return "LS_CUSTOMS"
    elseif clothes_shop_blip[plyBlip] then
        return "CLOTHES_SHOP"
    elseif shop_blips[plyBlip] then
        return "SHOP"
    elseif normal_blips[plyBlip] then
        return ""
    elseif cashier_blip[plyBlip] then
        return "CASHIER"
    elseif loading_blips[plyBlip] then
        return "LOADING"
    elseif ls_car_meet[plyBlip] then
        return "CAR_MEET"
    elseif junk_parachute_blip[plyBlip] then
        return "JUNK_PARACHUTE"
    elseif junk_bike_blips[plyBlip] then
        return "JUNK_BIKE"
    elseif auto_shop[plyBlip] then
        return "MOD_SHOP"
    elseif delivery_mission_blips[plyBlip] then
        return "DELIVERY_MISSION"
    elseif kosatka_blip[plyBlip] then
        return "KOSATKA"
    elseif ammo_nation_blip[plyBlip] then
        return "AMMO_NATION"
    elseif ballistic_armor_blip[plyBlip] then
        return "BALLISTIC_ARMOR"
    elseif heist_planning_board[plyBlip] then
        return "HEIST_BOARD"
    elseif unsure_blips[plyBlip] then
        return "UNSURE: " .. plyBlip
    elseif prep_mission_blips[plyBlip] then
        return "PREP_MISSION: " .. plyBlip
    else
        return "Blip:" .. plyBlip
    end
end

----------------------------------------------------------------
---------------------Podium Vehicle Changer---------------------
baseGlobals.podiumVehicle = {}
baseGlobals.podiumVehicle.baseGlobal = 288479
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
-- Globals Found by: (AppleVegas), updated by Quad_Plex
--easily updated by looking for TXT_BNTY_NPC1 in freemode.c
baseGlobals.bountyGlobals = {}
baseGlobals.bountyGlobals.bounty_base = 2738934
baseGlobals.bountyGlobals.bounty_overrideBounty = 262145
baseGlobals.bountyGlobals.bounty_selfValue = 2359296 + 1 + (0 * 5570) + 5152 + 14
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
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2333, minPay)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2334, minPay)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2335, minPay)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2336, minPay)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2337, minPay)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 7179, fee)
end

function resetOverrideBounty()
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2333, 2000)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2334, 4000)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2335, 6000)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2336, 8000)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 2337, 10000)
    globals.set_int(baseGlobals.bountyGlobals.bounty_overrideBounty + 7179, 1000)
end

function sendBountyToYourself(money)
    globals.set_int(baseGlobals.bountyGlobals.bounty_selfValue, money)
    globals.set_int(baseGlobals.bountyGlobals.bounty_base + 1908 + 57, 0)
end

function sendBounty(id, amount, skipOverride)
    if player.get_player_ped(id) == localplayer then
        sendBountyToYourself(amount)
        return
    end

    if not skipOverride then
        overrideBounty(amount)
    end
    globals.set_int(baseGlobals.bountyGlobals.bounty_base + 4586, id)
    globals.set_int(baseGlobals.bountyGlobals.bounty_base + 4586 + 1, 1)
    globals.set_bool(baseGlobals.bountyGlobals.bounty_base + 4586 + 2 + 1, true)
    sleep(0.4)
    if not skipOverride then
        resetOverrideBounty()
    end
end

--------------------------------------------------------------
--------------------------Host Check--------------------------
--Global_2650416.f_1
baseGlobals.hostCheck = {}
baseGlobals.hostCheck.baseGlobal = 2650436 + 1
baseGlobals.hostCheck.testCheck = function()
    return getScriptHostPlayerID() == getLocalplayerID()
end
baseGlobals.hostCheck.checkExplanation = "(Solo Session) Am I Host?:"
function getScriptHostPlayerID()
    return globals.get_int(baseGlobals.hostCheck.baseGlobal)
end

---------------------------Host Kick--------------------------
--Global_1877042[PLAYER::PLAYER_ID()]
baseGlobals.hostKick = {}
baseGlobals.hostKick.baseGlobal = 1877252
baseGlobals.hostKick.testFunction = function()
    hostKick(getLocalplayerID())
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
-- now 2672855?

baseGlobals.spectatorCheck = {}
baseGlobals.spectatorCheck.specPlayerBaseGlobal = 2657971
baseGlobals.spectatorCheck.testCheck = function()
    return amISpectating(getLocalplayerID())
end
baseGlobals.spectatorCheck.checkExplanation = "Am I spectating myself?"

baseGlobals.spectatorCheck2 = {}
baseGlobals.spectatorCheck2.tvSpectatePlyIDGlobal = baseGlobals.localPlayerGlobal.baseGlobal
baseGlobals.spectatorCheck2.testIntRange = function()
    return globals.get_int(baseGlobals.spectatorCheck2.tvSpectatePlyIDGlobal)
end
baseGlobals.spectatorCheck2.intRangeExplanation = "Currently watched player on TV:"
function getIsTrackedPedVisibleState(plyId)
    return globals.get_int(baseGlobals.spectatorCheck.specPlayerBaseGlobal + 1 + (plyId * 465) + 33)
end

--Unused, but still keeping it for documentation's sake
function getIsVisibleToScriptState(plyId)
    return globals.get_int(baseGlobals.spectatorCheck.specPlayerBaseGlobal + 1 + (plyId * 465) + 34)
end

function isSpectatingMe(plyId)
    local ply = player.get_player_ped(plyId)
    if not ply then return end
    local visibleState = getIsTrackedPedVisibleState(plyId)
    local isWatchingMe = checkBit(visibleState, getLocalplayerID())
    return isWatchingMe and distanceBetween(player.get_player_ped(), ply) > 305
end

function amISpectating(plyId)
    --Check the scanned Global first, only works in TV spectator mode, not modest's Quick Spectate
    if globals.get_int(baseGlobals.spectatorCheck2.tvSpectatePlyIDGlobal) == plyId then return true end
    local ply = player.get_player_ped(plyId)
    if not ply then return end
    local ownVisibleState = getIsTrackedPedVisibleState(getLocalplayerID())
    local amIWatching = checkBit(ownVisibleState, plyId)
    return amIWatching and distanceBetween(player.get_player_ped(), ply) > 305
end

---------------------------------------------------------------------------
----------------------------Player Bounty Info-----------------------------
---playerBountyAmount: Global_1835505.f_4[PLAYER::PLAYER_ID() /*3*/].f_1
baseGlobals.bountyInfo = {}
baseGlobals.bountyInfo.playerBountyInfoGlobal = 1835505
baseGlobals.bountyInfo.testIntRange = function()
    return getPlayerBountyAmount(getLocalplayerID())
end
baseGlobals.bountyInfo.intRangeExplanation = "Own Bounty Value:"

hasBounty = function(plyId)
    return getPlayerBountyAmount(plyId) > 0
end

getPlayerBountyAmount = function(plyId)
    return globals.get_int(baseGlobals.bountyInfo.playerBountyInfoGlobal + 4 + 1 + (plyId * 3) + 1)
end

-----------------------------------------------------------------------------
-------------------------- Special Export Vehicles --------------------------
baseGlobals.specialExport = {}
--Global found through GLobal Scanner script, the value doesn't correspond to a freemode Global_
baseGlobals.specialExport.baseGlobal = 1943195
baseGlobals.specialExport.bareStringCheck = function()
    local vehicle = getSpecialExportVehiclesList()[1]
    local vehicle_data = vehicle and VEHICLE[vehicle]
    if vehicle_data then
        return "1st Vehicle in List: " .. tostring(vehicle_data[1])
    else
        return "No Vehicle Found..."
    end
end

getSpecialExportVehiclesList = function()
    local exportVehiclesList = {}
    for i = baseGlobals.specialExport.baseGlobal, baseGlobals.specialExport.baseGlobal + 9 do
        table.insert(exportVehiclesList, globals.get_int(i))
    end
    return exportVehiclesList -- Return the list of export vehicle values
end

-------------------------------------------------------------------------------
------------------------- Sessanta Shit ---------------------------------------
baseGlobals.sessantaShit = {}
baseGlobals.sessantaShit.base_local = 331
function newSessantaVehicle()
    local shop_controller = script("shop_controller")
    if shop_controller and shop_controller:is_active() then
        stats.set_int("MP" .. stats.get_int("MPPLY_LAST_MP_CHAR") .. "_TUNER_CLIENT_VEHICLE_POSSIX", 1)
        shop_controller:set_int(baseGlobals.sessantaShit.base_local + 1, 0)
        shop_controller:set_int(baseGlobals.sessantaShit.base_local + 2, 0)
        shop_controller:set_int(baseGlobals.sessantaShit.base_local + 3, 1)
        shop_controller:set_int(baseGlobals.sessantaShit.base_local, 3)
    end
end
baseGlobals.sessantaShit.testFunction = function()
    newSessantaVehicle()
end
baseGlobals.sessantaShit.testFunctionExplanation = "Trigger new Sessanta Vehicle"

---------------------------------------------------------------------------------
--------------------------------- Disable Phone ---------------------------------
--Global_20796
phoneDisabledState = false
local phoneLoopRunning = false
baseGlobals.phoneDisabler = {}
baseGlobals.phoneDisabler.base_global = 20913
baseGlobals.phoneDisabler.testFunction = function()
    setPhoneDisabled(not phoneDisabledState)
end

local function disablePhoneLoop()
    phoneLoopRunning = true
    while phoneDisabledState do
        globals.set_bool(baseGlobals.phoneDisabler.base_global, true)
        sleep(0.06)
    end
    globals.set_bool(baseGlobals.phoneDisabler.base_global, false)
    phoneLoopRunning = false
end
menu.register_callback('disablePhoneLoop', disablePhoneLoop)

function setPhoneDisabled(disable, disableNotification)
    if disable then
        phoneDisabledState = disable
        if not disableNotification then
            displayHudBanner("S23_SOAD_BLP1", "PIM_NCL_PRIV0", "", 108)
        end
        if not phoneLoopRunning then
            menu.emit_event('disablePhoneLoop')
        end
    else
        phoneDisabledState = disable
        if not disableNotification then
            displayHudBanner("S23_SOAD_BLP1", "PIM_NCL_PRIV1", "", 108)
        end
    end
end

---------------------------------------------------------------------------------
---------------------------- RID Lookup -----------------------------------------
baseGlobals.ridLookup = {}
success, possible_offsets = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/RID_DATA_OFFSETS.json")

baseGlobals.ridLookup.freemode_base_local = -1
ridLookupTable = {}

function performRidUpdate(sub, customName)
    if not customName then
        greyText(sub, "Starting search...")
    else
        greyText(sub, "Searching for " .. customName .. "'s R*ID...")
    end
    local min_value = 1
    local max_value = 9999999
    local preShortenedCheckName
    preShortenedCheckName = string.sub(player.get_player_name(getLocalplayerID()), 5)
    local current_count = math.ceil((max_value - min_value) / 2)
    local counter = 0
    local counter2 = 1
    local step = current_count / 10
    local freemode_script = script("freemode")
    if not freemode_script then
        return
    end
    --Only check every second value because the offset is always uneven
    for i = min_value, max_value, 2 do
        counter = counter + 1
        if counter == math.floor(step) then
            greyText(sub, counter2 * 10 .. "% searched... (" .. formatNumberWithDots(counter2 * math.ceil(step)) .. " Variables)")
            counter = 0
            counter2 = counter2 + 1
        end
        local shortenedPlyName = freemode_script:get_string(i + (0 * 528) + 3, 30)
        if shortenedPlyName == preShortenedCheckName then
            addText(sub, "FOUND! Correct Offset: " .. i)
            baseGlobals.ridLookup.freemode_base_local = i
            table.insert(possible_offsets, i)
            table.sort(possible_offsets)
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/RID_DATA_OFFSETS.json", possible_offsets)
            triggerRidLookupTableRefresh(player.get_player_name(getLocalplayerID()) or nil)
            return
        end
    end
    addText(sub, "NOT FOUND! Restart the game and try again")
end
function triggerRidLookupTableRefresh(plyname)
    local freemode_script = script("freemode")
    if not freemode_script or not plyname then return end
    --Only update the used offset if it hasn't been determined before
    if baseGlobals.ridLookup.freemode_base_local == -1 then
        for _, offset in pairs(possible_offsets) do
            local shortenedPlyName = freemode_script:get_string(offset + (0 * 528) + 3, 30)
            if shortenedPlyName == string.sub(plyname, 5) then
                baseGlobals.ridLookup.freemode_base_local = offset
                break
            end
        end
    end
    if baseGlobals.ridLookup.freemode_base_local == -1 then return end     --Couldn't find the correct offset, exit
    for i = 0, 200 do
        local shortenedPlyName = freemode_script:get_string(baseGlobals.ridLookup.freemode_base_local + (i * 528) + 3, 30)
        local rid = freemode_script:get_int(baseGlobals.ridLookup.freemode_base_local + (i * 528))
        if rid ~= nil and rid > 1 and shortenedPlyName ~= nil then
            ridLookupTable[shortenedPlyName] = rid
        end
    end
end

function getRidForPlayer(plyName)
    return ridLookupTable[string.sub(plyName, 5)]
end
baseGlobals.ridLookup.bareStringCheck = function()
    local freemode_script = script("freemode")
    if not freemode_script then return "Freemode Script not found" end
    return "Plyname - 4: " .. tostring(freemode_script:get_string(baseGlobals.ridLookup.freemode_base_local + 3, 30))
end

----------------------------------------------------------------------------
--------------------------- Vehicle Options --------------------------------
baseGlobals.vehicleOptions = {}
baseGlobals.vehicleOptions.base_global = 1572050
baseGlobals.vehicleOptions.testFunctionExplanation = "Toggle Flappy Doors"
baseGlobals.vehicleOptions.testFunction = function()
    flappyDoors = not flappyDoors
    if flappyDoors then
        if not rcSpamRunning then
            menu.emit_event("startRCSpamThread")
        end
    end
end

vehicleStates = {
    ["open_door"] = 0,
    ["close_door"] = 1,
    ["engine_on"] = 2,
    ["engine_off"] = 3,
    ["headlights_on"] = 4,
    ["headlights_off"] = 5,
    ["radio_on"] = 6,
    ["radio_off"] = 7,
    ["neon_lights_on"] = 8,
    ["neon_lights_off"] = 9,
    ["stance_default"] = 13,
    ["stance_lowered"] = 14,
    ["roof_up"] = 15,
    ["roof_down"] = 16,
    ["hydraulics_all"] = 17,
    ["hydraulics_off"] = 18,
    ["hydraulics_front"] = 19,
    ["hydraulics_rear"] = 20,
}

function getCurrentVehicleState(stateName)
    return checkBit(globals.get_int(baseGlobals.vehicleOptions.base_global), vehicleStates[stateName])
end

function toggleVehicleState(stateName, stateName2, stateName3)
    local stateIndex = vehicleStates[stateName]
    local stateIndex2 = stateName2 and vehicleStates[stateName2]
    local stateIndex3 = stateName3 and vehicleStates[stateName3]
    local vehRemoteOptionsState = globals.get_int(baseGlobals.vehicleOptions.base_global)
    vehRemoteOptionsState = setBit(vehRemoteOptionsState, stateIndex)
    if stateIndex2 then
        vehRemoteOptionsState = setBit(vehRemoteOptionsState, stateIndex2)
    end
    if stateIndex3 then
        vehRemoteOptionsState = setBit(vehRemoteOptionsState, stateIndex3)
    end
    globals.set_int(baseGlobals.vehicleOptions.base_global, vehRemoteOptionsState)
end

function setDoorBit(door, bit)
    local doorState = globals.get_int(baseGlobals.vehicleOptions.base_global + 8)
    if bit == 1 then
        doorState = setBit(doorState, door)
    else
        doorState = clearBit(doorState, door)
    end
    globals.set_int(baseGlobals.vehicleOptions.base_global + 8, doorState)
end

---------------------------- Native Teleport (Entity:Set_entity_coords) ---------------------------------
local coords_is_setting = false
baseGlobals.teleport = {}
baseGlobals.teleport.baseGlobalPed = 4521801
baseGlobals.teleport.baseGlobalVeh = 2635563
baseGlobals.teleport.testFunctionExplanation = "Teleport forward"
baseGlobals.teleport.testFunction = function()
    nativeTeleport(localplayer:get_position() + localplayer:get_heading() * 2)
end
function nativeTeleport(vector, headingVec)
    if (localplayer and (localplayer:get_pedtype() == 2) and not localplayer:is_in_vehicle() and not coords_is_setting) then -- localplayer is netplayer and not in vehicle
        coords_is_setting = true
        globals.set_float(baseGlobals.teleport.baseGlobalPed + 948 + 0, vector.x)
        globals.set_float(baseGlobals.teleport.baseGlobalPed + 948 + 1, vector.y)
        globals.set_float(baseGlobals.teleport.baseGlobalPed + 948 + 2, vector.z)
        if headingVec then
            globals.set_float(baseGlobals.teleport.baseGlobalPed + 951, math.deg(math.atan(headingVec.y, headingVec.x)) - 90)
        else
            globals.set_float(baseGlobals.teleport.baseGlobalPed + 951, math.deg(math.atan(localplayer:get_heading().y, localplayer:get_heading().x)) - 90)
        end
        globals.set_int(baseGlobals.teleport.baseGlobalPed + 945, 20) --Trigger Entity:set_entity_coords
        sleep(0.05)
        globals.set_int(baseGlobals.teleport.baseGlobalPed + 945, -1)
        setPlayerRespawnState(getLocalplayerID(), 0)
    elseif localplayer:is_in_vehicle() and not coords_is_setting then
        coords_is_setting = true
        globals.set_float(baseGlobals.teleport.baseGlobalVeh + 505 + 0, vector.x)
        globals.set_float(baseGlobals.teleport.baseGlobalVeh + 505 + 1, vector.y)
        globals.set_float(baseGlobals.teleport.baseGlobalVeh + 505 + 2, vector.z)
        if headingVec then
            globals.set_float(baseGlobals.teleport.baseGlobalVeh + 3207, headingVec.z) --pitch (NEEDS to be set to something other than 0 or yaw won't be applied either)
            globals.set_float(baseGlobals.teleport.baseGlobalVeh + 508, headingVec.x) --yaw
        else
            local yawAngle = math.deg(math.atan(localplayer:get_heading().y, localplayer:get_heading().x)) - 90
            local pitchAngle = math.deg(math.atan(localplayer:get_heading().z, math.sqrt(localplayer:get_heading().x^2 + localplayer:get_heading().y^2)))
            globals.set_float(baseGlobals.teleport.baseGlobalVeh + 3207, pitchAngle)
            globals.set_float(baseGlobals.teleport.baseGlobalVeh + 508, yawAngle)
        end
        setPlayerRespawnState(getLocalplayerID(), 7)
        globals.set_int(baseGlobals.teleport.baseGlobalVeh + 45 + 65, 1)
    end
    coords_is_setting = false
end

function fixPedVehTeleport()
    globals.set_int(baseGlobals.teleport.baseGlobalVeh + 45 + 65, 0)
end

------------------------------------ Playername/Blip Hider -------------------------------------
baseGlobals.hideGlobal = {}
baseGlobals.hideGlobal.baseGlobal = 1845281
baseGlobals.hideGlobal.testFunctionExplanation = "Toggle Hide"
baseGlobals.hideGlobal.testFunction = function()
    hidePlayer(not isHidden())
end

local hideRunnerEnabled = false
local hideRunnerRunning = false
local function hideRunner()
    while hideRunnerEnabled do
        hideRunnerRunning = true
        globals.set_int(baseGlobals.hideGlobal.baseGlobal + 1 + (getLocalplayerID() * 883) + 206, 8)
        sleep(1)
    end
    globals.set_int(baseGlobals.hideGlobal.baseGlobal + 1 + (getLocalplayerID() * 883) + 206, 9)
    hideRunnerRunning = false
end
menu.register_callback('hideRunner', hideRunner)

function hidePlayer(hideToggle)
    if hideToggle then
        hideRunnerEnabled = true
        if not hideRunnerRunning then
            menu.emit_event('hideRunner')
        end
    else
        hideRunnerEnabled = false
    end
end

function isHidden()
    return globals.get_int(baseGlobals.hideGlobal.baseGlobal + 1 + (getLocalplayerID() * 883) + 206) == 8
end



----------------------------- MODEL CHANGER ----------------------------------
---Big thanks to Alice2333
---
baseGlobals.pedChanger = {}
baseGlobals.pedChanger.hashGlobal1 = 152645
baseGlobals.pedChanger.hashGlobal2 = 2640096
baseGlobals.pedChanger.pedTrigger = 2708057
baseGlobals.pedChanger.testFunctionExplanation = "Turn into a Dog"
baseGlobals.pedChanger.testFunction = function()
    setPlayerModel(joaat("a_c_shepherd"))
end

function getGender()
    return stats.get_masked_int("mp"..stats.get_int("mpply_last_mp_char").."_pstat_int0", 16, 1)
end

default_models = { [0]="mp_m_freemode_01", "mp_f_freemode_01"}
local ped_is_setting = false
function setPlayerModel(hash)
    local gender = getGender()
    if not localplayer or not gender or not hash or (localplayer:get_model_hash() == hash) then return end
    if (type(hash) == "number") then
        hash = hash
    else
        hash = joaat(hash)
    end
    if not ped_is_setting then
        local tries = 0
        while (localplayer:get_model_hash() ~= hash and tries < 4) do
            ped_is_setting = true
            --globals.set_int(baseGlobals.pedChanger.hashGlobal1 + 7 + gender, hash)
            globals.set_int(baseGlobals.pedChanger.hashGlobal2 + 50, hash)
            globals.set_bool(baseGlobals.pedChanger.hashGlobal2 + 63, true)
            sleep(playerlistSettings.pedChangerSleepTimeout) -- short sleep to interrupt the ped changer function with next call, prevents it from changing back to base model
            globals.set_bool(baseGlobals.pedChanger.hashGlobal2 + 63, false)
            if (hash ~= joaat("mp_m_freemode_01") and hash ~= joaat("mp_f_freemode_01")) then
                sleep(playerlistSettings.pedChangerSleepTimeout)
                globals.set_int(baseGlobals.pedChanger.pedTrigger + 278, getOrSetPlayerPedID())
            end
            if not isAnimalPed(findPedDataFromHash(hash)[2]) then
                enableWeapons()
                globals.set_int(baseGlobals.pedChanger.hashGlobal1 + 7 + gender, joaat(default_models[gender]))
            else
                disableWeapons()
                localplayer:set_max_health(328.0)
                menu.heal_player()
            end
            tries = tries + 1
            sleep(0.02)
        end
        ped_is_setting = nil
    end
    menu.max_all_ammo()
end

function enableWeapons()
    globals.set_bool(baseGlobals.pedChanger.pedTrigger + 226 + 1, true)
end

function disableWeapons()
    globals.set_bool(baseGlobals.pedChanger.pedTrigger + 226 + 1, false)
end
--------------------------------------- SET WAYPOINT ---------------------------------------------
-----Thanks to rf2007 for the globals! Updated to newest gta version by me
local bitStorage1 = 2 ^ 8 + 2 ^ 10
local bitStorage2 = 2 ^ 15
baseGlobals.waypointGlobal = {}
baseGlobals.waypointGlobal.baseGlobal = 2672855 + 3830
baseGlobals.waypointGlobal.testFunctionExplanation = "Set Waypoint to 420, 420"
baseGlobals.waypointGlobal.testFunction = function() setWayPoint(420, 420) end
function setWayPoint(x, y)
    --set waypoint
    local oldHash = globals.get_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 66)
    globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2, joaat("rcbandito"))
    globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 0, x) --Spawn RCBandito at xyz with Pegasus flag enabled
    globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 1, y)
    globals.set_float(baseGlobals.vehicleSpawner2.baseGlobal2 + 7 + 2, 1500)
    globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 2, true) --Spawn trigger #1
    globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 3, true) --Pegasus Spawn trigger
    globals.set_bool(baseGlobals.vehicleSpawner2.baseGlobal2 + 5, true) --Spawn trigger #2
    sleep(0.1)
    globals.set_int(baseGlobals.waypointGlobal.baseGlobal, 512) -- 9th bit sets quick gps to pegasus vehicle
    for _ = 1, 10 do
        if globals.get_int(baseGlobals.waypointGlobal.baseGlobal) & bitStorage1 == bitStorage1 then
            break
        end
        sleep(0.1)
    end
    sleep(0.4)
    globals.set_int(baseGlobals.waypointGlobal.baseGlobal, bitStorage2) --bit 15 removes pegasus blip from vehicle
    globals.set_int(baseGlobals.vehicleSpawner2.baseGlobal2 + 27 + 66, oldHash)
end


--------------------- Snow Global ------------------------------
--Global_262145.f_4413 /* Tunable: TURN_SNOW_ON_OFF */
baseGlobals.snowGlobal = {}
baseGlobals.snowGlobal.baseGlobal = 262145
baseGlobals.snowGlobal.testFunctionExplanation = "Toggle snow"
baseGlobals.snowGlobal.testFunction = function()
    changeSnowGlobal(not isSnowTurnedOn())
end

function changeSnowGlobal(bool)
    globals.set_bool(baseGlobals.snowGlobal.baseGlobal + 9435, not bool) --Disable Snowballs Tunable
    globals.set_bool(baseGlobals.snowGlobal.baseGlobal + 4413, bool)
end

function isSnowTurnedOn()
    return globals.get_bool(baseGlobals.snowGlobal.baseGlobal + 4413)
end

--------------------- Set freemode thread priority? -------------------------
--TODO:
--Global_262145.f_32166 /* Tunable: SET_FREEMODE_THREAD_PRIORITY */

----------------------------- Clear Blood ----------------------------------
-----Thanks to Alice2333 and LUKY6464!
baseGlobals.clearBlood = {}
baseGlobals.clearBlood.baseGlobal = 2685444
baseGlobals.clearBlood.testFunctionExplanation = "Clear Blood"
baseGlobals.clearBlood.testFunction = function()
    clearBlood()
end

function clearBlood()
    globals.set_int(baseGlobals.clearBlood.baseGlobal + 2847 + 54, 2)
    globals.set_int(baseGlobals.clearBlood.baseGlobal + 2847 + 4, 7)
    globals.set_bool(baseGlobals.clearBlood.baseGlobal + 2847 + 19, false)
    globals.set_bool(baseGlobals.clearBlood.baseGlobal + 2847 + 55, true)
    globals.set_int(baseGlobals.clearBlood.baseGlobal + 2847 + 14, 2)
end

----------------------------- Start freemode script events --------------------------
-----Note: only works if you are host of a session and is very buggy in general
----- event 20 starts the gta online intro scene
baseGlobals.triggerScripts = {}
baseGlobals.triggerScripts.baseGlobal = 2699171
baseGlobals.triggerScripts.scriptLocal = 238

function triggerScriptWithId(scriptId)
    local am_launcher = script("am_launcher")
    if am_launcher and am_launcher:is_active() then
        am_launcher:set_int(baseGlobals.triggerScripts.scriptLocal + 1 + (getLocalplayerID()), 1)
        am_launcher:set_int(baseGlobals.triggerScripts.scriptLocal + 1 + (getLocalplayerID()) + 1, 0)
        globals.set_int(baseGlobals.triggerScripts.baseGlobal + 3 + 1, scriptId)
        am_launcher:set_int(baseGlobals.triggerScripts.scriptLocal + 1 + (getLocalplayerID()) + 2, 6)
        globals.set_int(baseGlobals.triggerScripts.baseGlobal + 2, 6)
        globals.set_int(baseGlobals.triggerScripts.baseGlobal, 1)
    end
end

------------------------------------- Halloween Weather Toggle ----------------------------------
baseGlobals.halloween = {}
baseGlobals.halloween.baseGlobal = 262145
baseGlobals.clearBlood.testFunctionExplanation = "Toggle halloween Weather"
baseGlobals.clearBlood.testFunction = function()
    setHalloweenWeather(not isHalloweenWeatherEnabled())
end

function setHalloweenWeather(bool)
    globals.set_bool(baseGlobals.halloween.baseGlobal + 32084, bool)
    globals.set_bool(baseGlobals.halloween.baseGlobal + 32157, bool)
    globals.set_bool(baseGlobals.halloween.baseGlobal + 32158, bool)
end

function isHalloweenWeatherEnabled()
    return globals.get_bool(baseGlobals.halloween.baseGlobal + 32158)
end

------------------------------ Change 'Make it Rain' Money Spent-------------------------
--Global_262145.f_25485
baseGlobals.makeItRain = {}
baseGlobals.makeItRain.baseGlobal = 262145 + 25485

function setMakeItRainAmount(amount)
    globals.set_int(baseGlobals.makeItRain.baseGlobal, amount)
end

function getMakeItRainAmount()
    return globals.get_int(baseGlobals.makeItRain.baseGlobal)
end

--------------------------------- Mugger / Mercenary Hire ---------------------------------
--Big thanks to book4 for posting 1.61 globals for this!
--Global_1845281[iVar1 /*883*/].f_141 --true=mugger/false=mercenary
--Global_1845281[iVar1 /*883*/].f_142 --playerID to send to
mugger_selection = {[1]="Mugger", [2]="Mercenaries", }
current_mugger_choice = 1
baseGlobals.hireMugger = {}
baseGlobals.hireMugger.baseGlobal = 1845281

function hireMuggerOrMercenary(plyId, muggerSelection)
    globals.set_int(baseGlobals.hireMugger.baseGlobal + 1 + (getLocalplayerID() * 883) + 142, plyId)
    globals.set_int(baseGlobals.hireMugger.baseGlobal + 1 + (getLocalplayerID() * 883) + 141, muggerSelection)
end