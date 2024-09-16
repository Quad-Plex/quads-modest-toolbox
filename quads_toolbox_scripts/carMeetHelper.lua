godmodeToggle = false
local nearbyGodmodeRunning = false
local success, carMeetData = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/CARMEET_DATA.json")
table.sort(carMeetData, function(a, b)
    return a[1]:upper() < b[1]:upper()
end)

local carMeetVehicleCategories = {"Compact", "Coupes", "Muscle", "Off-Road", "Sedan", "Sport", "Sport Classic", "Super", "SUV"}
local curatedCarMeetVehicles = {}
for hash, vehicle in pairs(VEHICLE) do
    if table.contains(carMeetVehicleCategories, vehicle[2]) then
        table.insert(curatedCarMeetVehicles, { hash, vehicle });
    end
end

local function getLocationFromCarMeetData(carMeet)
    for _, data in pairs(carMeet) do
        if data[1] == "location" then
            return vector3(data[2][1], data[2][2], data[2][3])
        end
    end
end

local function getHeadingFromCarMeetData(carMeet)
    for _, data in pairs(carMeet) do
        if data[1] == "location" then
            return vector3(data[3][1], data[3][2], data[3][3])
        end
    end
end

local function stringChangerCarmeet(sub, stringToChange)
    local oldName = stringToChange
    local tempString = stringToChange
    sub:clear()
    if stringToChange then
        sub:add_bare_item("", function()
            if stringToChange ~= tempString then
                local oldData = carMeetData[tempString]
                carMeetData[tempString] = nil
                carMeetData[stringToChange] = oldData
                table.sort(carMeetData, function(a, b)
                    return a[1]:upper() < b[1]:upper()
                end)
                json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/CARMEET_DATA.json", carMeetData)
                tempString = stringToChange
            end
            return "Rename " .. oldName .. " to " .. stringToChange
        end, null, null, null)
    end
    greyText(sub, "----------------------------")
    sub:add_action("||⌫ Backspace ⌫|", function()
        stringToChange = string.sub(stringToChange, 1, -2)
    end)
    sub:add_toggle("Uppercase Letters", function() return uppercaseToggle end, function(toggle) uppercaseToggle = toggle end)
    sub:add_bare_item("",
            function()
                return "Add Letter: ◀ " .. showLettersForPosition(selectedLetterPos, lowercaseLetters) .. " ▶"
            end,
            function()
                stringToChange = addLetterToString(lowercaseLetters[selectedLetterPos], stringToChange)
            end,
            function()
                if selectedLetterPos > 1 then selectedLetterPos = selectedLetterPos - 1 end
                return "Add Letter: ◀ " .. showLettersForPosition(selectedLetterPos, lowercaseLetters) .. " ▶"
            end,
            function()
                if selectedLetterPos < #lowercaseLetters then selectedLetterPos = selectedLetterPos + 1 end
                return "Add Letter: ◀ " .. showLettersForPosition(selectedLetterPos, lowercaseLetters) .. " ▶"
            end)
    sub:add_bare_item("",
            function()
                return "Add Number: ◀ " .. showLettersForPosition(selectedNumberPos, numbers) .. " ▶"
            end,
            function()
                stringToChange = addLetterToString(numbers[selectedNumberPos], stringToChange)
            end,
            function()
                if selectedNumberPos > 1 then selectedNumberPos = selectedNumberPos - 1 end
                return "Add Number: ◀ " .. showLettersForPosition(selectedNumberPos, numbers) .. " ▶"
            end,
            function()
                if selectedNumberPos < #numbers then selectedNumberPos = selectedNumberPos + 1 end
                return "Add Number: ◀ " .. showLettersForPosition(selectedNumberPos, numbers) .. " ▶"
            end)
    sub:add_bare_item("",
            function()
                return "Add Symbol: ◀ " .. showLettersForPosition(selectedSymbolPos, symbols) .. " ▶"
            end,
            function()
                stringToChange = addLetterToString(symbols[selectedSymbolPos], stringToChange)
            end,
            function()
                if selectedSymbolPos > 1 then selectedSymbolPos = selectedSymbolPos - 1 end
                return "Add Symbol: ◀ " .. showLettersForPosition(selectedSymbolPos, symbols) .. " ▶"
            end,
            function()
                if selectedSymbolPos < #symbols then selectedSymbolPos = selectedSymbolPos + 1 end
                return "Add Symbol: ◀ " .. showLettersForPosition(selectedSymbolPos, symbols) .. " ▶"
            end)
end

local function findJustSpawnedVehicle(hash, pos)
    for _ = 1, 10 do
        for veh in replayinterface.get_vehicles() do
            if veh:get_model_hash() == hash and distanceBetween(veh, pos, true) < 10 then
                return veh
            end
        end
        sleep(0.15)
    end
end

local function spawnCarMeet(carMeet, random, sub)
    local spawnPos = getLocationFromCarMeetData(carMeet) + getHeadingFromCarMeetData(carMeet) * 4
    for _, data in pairs(carMeet) do
        local spawnedVehicle
        local vehicle
        local vehicleNetID
        if data[1] == "location" then
            goto skip
        end
        if not random then
            greyText(sub, "Spawning " .. data[1])
            vehicleNetID = createVehicle(data[2], spawnPos, nil, false, generateRandomMods(VEHICLE[data[2]][3]), true, true, false)
            spawnedVehicle = data[2]
        else
            local selection = math.random(#curatedCarMeetVehicles)
            greyText(sub, "Spawning " .. VEHICLE[curatedCarMeetVehicles[selection][1]][1])
            vehicleNetID = createVehicle(curatedCarMeetVehicles[selection][1], spawnPos, nil, true, generateRandomMods(VEHICLE[curatedCarMeetVehicles[selection][1]][3]), true, true, false)
            spawnedVehicle = curatedCarMeetVehicles[selection][1]
        end
        globals.set_int(baseGlobals.setIntoVehicle.forceControl + 3184, vehicleNetID) --Network request control of entity -- trying to fix non-working spawned cars
        sleep(0.3)
        vehicle = findJustSpawnedVehicle(spawnedVehicle, spawnPos)
        if not vehicle then goto skip end

        setPedIntoVehicle(vehicleNetID, nil, true)
        for _ = 1, 20000 do
            vehicle:set_rotation(vector3(data[4][1], data[4][2], data[4][3]))
            vehicle:set_position(vector3(data[3][1], data[3][2], data[3][3]) + 0.3)
        end
        ::skip::
    end
    greyText(sub, "Giving Random Vehicle at end")
    local selection = math.random(#curatedCarMeetVehicles)
    local lastVehicle = createVehicle(curatedCarMeetVehicles[selection][1], spawnPos, nil, true, generateRandomMods(VEHICLE[curatedCarMeetVehicles[selection][1]][3]), true, true, false)
    spawnedVehicle = curatedCarMeetVehicles[selection][1]
    sleep(0.3)
    setPedIntoVehicle(lastVehicle)
    addText(sub, "Done creating carmeet!")
end

local function saveCarMeet(empty)
    success, carMeetData = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/CARMEET_DATA.json")
    local newCarMeetKey
    if carMeetData["new_carmeet_0"] ~= nil then
        local counter = 1
        while counter < 99 do
            if carMeetData["new_carmeet_" .. counter] == nil then
                newCarMeetKey = "new_carmeet_" .. counter
                break
            end
            counter = counter + 1
        end
    else
        newCarMeetKey = "new_carmeet_0"
    end
    carMeetData[newCarMeetKey] = {}
    table.insert(carMeetData[newCarMeetKey], {"location", {localplayer:get_position().x, localplayer:get_position().y, localplayer:get_position().z}, {localplayer:get_heading().x, localplayer:get_heading().y, localplayer:get_heading().z}})
    if not empty then
        for veh in replayinterface.get_vehicles() do
            if distanceBetween(localplayer, veh) < 69 then
                local carData = { VEHICLE[veh:get_model_hash()][1], veh:get_model_hash(), { veh:get_position().x, veh:get_position().y, veh:get_position().z }, { veh:get_rotation().x, veh:get_rotation().y, veh:get_rotation().z } }
                table.insert(carMeetData[newCarMeetKey], carData)
            end
        end
    end
    table.sort(carMeetData, function(a, b)
        return a[1]:upper() < b[1]:upper()
    end)
    json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/CARMEET_DATA.json", carMeetData)
end

local function addPredefinedCarmeetsSub(sub)
    local subMenus = {}
    sub:clear()
    success, carMeetData = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/CARMEET_DATA.json")
    local carMeetDataSortedKeys = {}
    for key in pairs(carMeetData) do
        table.insert(carMeetDataSortedKeys, key)
    end
    table.sort(carMeetDataSortedKeys)
    for _, name in ipairs(carMeetDataSortedKeys) do
        subMenus[name] = sub:add_submenu(name)
        greyText(subMenus[name], "Creating Car Meet: " .. name)
        local renameSub
        renameSub = subMenus[name]:add_submenu("Rename Carmeet", function()
            stringChangerCarmeet(renameSub, name)
        end)
        greyText(subMenus[name], "-----------------------------")
        subMenus[name]:add_action("Teleport to Carmeet", function()
            nativeTeleport(getLocationFromCarMeetData(carMeetData[name]), getHeadingFromCarMeetData(carMeetData[name]))
        end)
        subMenus[name]:add_action("Spawn predefined cars", function()
            spawnCarMeet(carMeetData[name], false, subMenus[name])
        end)
        subMenus[name]:add_action("Spawn randomized cars", function()
            spawnCarMeet(carMeetData[name], true, subMenus[name])
        end)
        greyText(subMenus[name], "-----------------------------")
        subMenus[name]:add_action("Spawn random Car Meet Vehicle", function()
            local selection = math.random(#curatedCarMeetVehicles)
            createVehicle(curatedCarMeetVehicles[selection][1], localplayer:get_position() + localplayer:get_heading() * 8.7, nil, false, generateRandomMods(VEHICLE[curatedCarMeetVehicles[selection][1]][3]), true, true, false)
        end)
        subMenus[name]:add_action("TP into last spawned car", function()
            local vehicleNetID = getNetIDOfLastSpawnedVehicle()
            if vehicleNetID then
                setPedIntoVehicle(getNetIDOfLastSpawnedVehicle())
            end
        end)
        subMenus[name]:add_action("++ Add current veh/pos to car meet ++", function()
            local veh = localplayer:get_current_vehicle()
            for id, data in pairs(carMeetData[name]) do
                if tableCount(data) == 0 then
                    break
                end
                local spawnPos = vector3(data[3][1], data[3][2], data[3][3])
                if distanceBetween(veh, spawnPos, true) < 8.05 then
                    greyText(subMenus[name], "Too Close to " .. data[1])
                    subMenus[name]:add_action("Replace " .. data[1] .. "?", function()
                        table.remove(carMeetData[name], id)
                        local carData = { VEHICLE[veh:get_model_hash()][1], veh:get_model_hash(), { veh:get_position().x, veh:get_position().y, veh:get_position().z }, { veh:get_rotation().x, veh:get_rotation().y, veh:get_rotation().z } }
                        table.insert(carMeetData[name], carData)
                        table.sort(carMeetData, function(a, b)
                            return a[1]:upper() < b[1]:upper()
                        end)
                        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/CARMEET_DATA.json", carMeetData)
                        greyText(subMenus[name], VEHICLE[veh:get_model_hash()][1] .. " added to carmeet")
                    end)
                    return
                end
            end
            local carData = { VEHICLE[veh:get_model_hash()][1], veh:get_model_hash(), { veh:get_position().x, veh:get_position().y, veh:get_position().z }, { veh:get_rotation().x, veh:get_rotation().y, veh:get_rotation().z } }
            table.insert(carMeetData[name], carData)
            table.sort(carMeetData, function(a, b)
                return a[1]:upper() < b[1]:upper()
            end)
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/CARMEET_DATA.json", carMeetData)
            greyText(subMenus[name], VEHICLE[veh:get_model_hash()][1] .. " added to carmeet")
        end, function()
            return localplayer:is_in_vehicle()
        end)
        greyText(subMenus[name], "-----------------------------")
        subMenus[name]:add_toggle("⚠️ Remove nearby traffic ⚠️", function()
            return removeTrafficToggle
        end, function(value)
            removeTrafficToggle = value
            if not trafficRemoverRunning then
                menu.emit_event('removeTraffic')
            end
        end)
        greyText(subMenus[name], "---------------------------")
        local added
        subMenus[name]:add_action("⚠️ !! Remove Car Meet Data !! ⚠️", function()
            if not added then
                subMenus[name]:add_action("!!!! Press me to confirm!!!!", function()
                    carMeetData[name] = nil
                    json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/CARMEET_DATA.json", carMeetData)
                    menu.send_key_press(returnHotkey)
                end)
                added = true
            end
        end)
    end
    greyText(sub, "--------------------")
    sub:add_action("+ Save nearby cars to carmeet data +", function()
        saveCarMeet(false)
        addPredefinedCarmeetsSub(sub)
    end)
    sub:add_action("+ Create new empty carmeet data here +", function()
        saveCarMeet(true)
        addPredefinedCarmeetsSub(sub)
    end)
end

local function addCarMeetHelper(sub)
    sub:clear()
    sub:add_action("Spawn random Car Meet Vehicle", function()
        local selection = math.random(#curatedCarMeetVehicles)
        createVehicle(curatedCarMeetVehicles[selection][1], localplayer:get_position() + localplayer:get_heading() * 8.7, nil, false, generateRandomMods(VEHICLE[curatedCarMeetVehicles[selection][1]][3]), true, true, false)
    end)
    sub:add_action("Spawn festival bus", function()
        local vehicleNetID = createVehicle(345756458, localplayer:get_position() + localplayer:get_heading() * 7, nil, true, nil, false, true, false)
        setPedIntoVehicle(vehicleNetID)
    end)
    sub:add_action("TP into last spawned car", function()
        local vehicleNetID = getNetIDOfLastSpawnedVehicle()
        if vehicleNetID then setPedIntoVehicle(getNetIDOfLastSpawnedVehicle()) end
    end)
    local vehicleSpawnMenu = sub:add_submenu("Spawn Specific Vehicle:")
    if tableCount(carMeetData) > 0 then
        local predefinedCarmeetsSub
        predefinedCarmeetsSub = sub:add_submenu("Spawn predefined Car meet:", function() addPredefinedCarmeetsSub(predefinedCarmeetsSub) end)
    end
    addVehicleSpawnMenu(localplayer, vehicleSpawnMenu)
    greyText(sub, "-------- loop helpers --------")
    sub:add_toggle("Force Godmode on nearby cars", function() return godmodeToggle end,
            function(toggle)
                godmodeToggle = toggle
                if godmodeToggle and not nearbyGodmodeRunning then
                    menu.emit_event("nearbyGodmode")
                end
            end)
    sub:add_toggle("⚠️ Remove nearby traffic ⚠️", function()
        return removeTrafficToggle
    end, function(value)
        removeTrafficToggle = value
        if not trafficRemoverRunning then
            menu.emit_event('removeTraffic')
        end
    end)
end

local function nearbyGodmode()
    if nearbyGodmodeRunning then return end
    while godmodeToggle do
        nearbyGodmodeRunning = true
        local vehicles = getNonPlayerVehicles()
        for _, veh in pairs(vehicles) do
            if distanceBetween(localplayer, veh) < 69 then
                veh:set_godmode(true)
                veh:set_health(1000)
            end
        end
        sleep(2)
    end
end
menu.register_callback("nearbyGodmode", nearbyGodmode)

local carMeetHelperMenu
carMeetHelperMenu = toolboxSub:add_submenu("  ★🚗 Car Meet Helper (Beta) ★🚗", function() addCarMeetHelper(carMeetHelperMenu) end)
