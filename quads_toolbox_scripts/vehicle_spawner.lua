-------------------------------------------------------------
-------------------- SORTED VEHICLE LIST --------------------
-------------------------------------------------------------

local success, favoritedCars = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_CARS.json")
if success then
    print("Favorite Cars loaded successfully!!")
end

-- vehicle = { hash, { name, class} }
table.sort(favoritedCars, function(a, b)
    return a[2][1]:upper() < b[2][1]:upper()
end)

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

local function isInFavorites(veh_hash)
    for i, favVehicle in ipairs(favoritedCars) do
        if favVehicle[1] == veh_hash then
            return i
        end
    end
    return false
end


------------------- Vehicle Search ----------------------
local function searchForVehicle(searchString)
    local results = {}
    for _, vehicle in ipairs(sorted_vehicles) do
        if string.find(vehicle[2][1]:lower(), searchString:lower()) then
            table.insert(results, vehicle)
        end
    end
    return results
end


------------------------KEYBOARD ENTRY FOR FAV VEHICLES/SEARCH ----------------------------
local function stringChangerFavVehicle(sub, stringToChange, veh_data)
    local tempString = stringToChange
    sub:clear()
    if stringToChange then
        sub:add_bare_item("", function()
            if stringToChange ~= tempString then
                local isFavorite = isInFavorites(veh_data[1])
                if isFavorite then
                    table.remove(favoritedCars, isFavorite)
                    veh_data[2][1] = stringToChange
                    table.insert(favoritedCars, veh_data)
                    table.sort(favoritedCars, function(a, b)
                        return a[2][1]:upper() < b[2][1]:upper()
                    end)

                    json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_CARS.json", favoritedCars)
                end
                tempString = stringToChange
            end
            return "Rename to " .. stringToChange
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

local function stringChangerSearch(sub, ply, results, oldSearch)
    if not results then
        results = {}
    end
    local searchString = ""
    if oldSearch then
        searchString = oldSearch
    end
    sub:clear()
    sub:add_action("||⌫ Backspace ⌫|", function()
        searchString = string.sub(searchString, 1, -2)
    end)
    sub:add_bare_item("",
            function()
                return "Add Letter: ◀ " .. showLettersForPosition(selectedLetterPos, lowercaseLetters, true) .. " ▶"
            end,
            function()
                searchString = addLetterToString(lowercaseLetters[selectedLetterPos], searchString)
            end,
            function()
                if selectedLetterPos > 1 then selectedLetterPos = selectedLetterPos - 1 end
                return "Add Letter: ◀ " .. showLettersForPosition(selectedLetterPos, lowercaseLetters, true) .. " ▶"
            end,
            function()
                if selectedLetterPos < #lowercaseLetters then selectedLetterPos = selectedLetterPos + 1 end
                return "Add Letter: ◀ " .. showLettersForPosition(selectedLetterPos, lowercaseLetters, true) .. " ▶"
            end)
    sub:add_bare_item("", function()
        return "Search for " .. searchString
    end, function()
        local newResults = searchForVehicle(searchString)
        if #newResults > 0 then
            stringChangerSearch(sub, ply, newResults, searchString)
        end
    end, null, null)
    greyText(sub, "---------------------------")
    if #results < 1 then
        addText(sub, "❌ No results yet! ❌")
    else
        local count = 0
        for _, vehicle in ipairs(results) do
            if count == 40 then
                goto continue
            end
            local vehSub
            vehSub = sub:add_submenu(vehicle[2][1], function() addVehicleEntry(vehSub, vehicle, ply) end)
            count = count + 1
        end
    end
    ::continue::
    greyText(sub, "---------------------------")
end

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

--Create Vehicle Spawn Menu
local spawnTypes = { [0]="No Mods", "Random Mods", "Max Mods"}
local spawnTypeSelectionNearest = 0
local spawnTypeSelectionCurrent = 0
local spawnTypeSelectionStandard = 0
local godmodeEnabledSpawn = false
local enterOnSpawn = false
local livePreview = false
function addVehicleEntry(vehMenu, vehicle, ply)
    vehMenu:clear()
    local tempMods = table.copy(empty_mods)
    local tempExtraMods = table.copy(extra_mods_base)
    greyText(vehMenu, "|Spawning " .. vehicle[2][1] .. "...")
    local favoriteVehicle = isInFavorites(vehicle[1])
    if favoriteVehicle then
        local renameSub
        renameSub = vehMenu:add_submenu("Rename " .. vehicle[2][1], function() stringChangerFavVehicle(renameSub, vehicle[2][1], vehicle) end)
    end
    vehMenu:add_action("Spawn using Method #1", function()
        local oldVehNetId = getNetIDOfLastSpawnedVehicle()
        local spawnPos = ply:get_position() + ply:get_heading() * 7
        createVehicle(vehicle[1], spawnPos)
        if (vehicle[4] == nil and enterOnSpawn) or (vehicle[4] ~= nil and vehicle[4]) then
            sleep(0.1)
            local newVehNetID = getNetIDOfLastSpawnedVehicle()
            if newVehNetID ~= oldVehNetId then
                setPedIntoVehicle(getNetIDOfLastSpawnedVehicle(), localplayer:get_position())
            end
        end
        if (vehicle[3] == nil and godmodeEnabledSpawn) or (vehicle[3] ~= nil and vehicle[3]) then
            if (vehicle[4] == nil and enterOnSpawn) or (vehicle[4] ~= nil and vehicle[4]) then
                sleep(3) --there is a weird timeout after tping into a car where it will be godmoded, but lose godmode after ~3sec, so we need to wait for that long to re-apply gm so it sticks
            end
            sleep(0.2)
            findAndEnableGodmodeForVehicle(vehicle[1], spawnPos)
        end
    end)
    vehMenu:add_array_item("Spawn using Method #2", spawnTypes, function() return spawnTypeSelectionStandard end, function(selection)
        spawnTypeSelectionStandard = selection
        local oldVehNetId = getNetIDOfLastSpawnedVehicle()
        local spawnPos = ply:get_position() + ply:get_heading() * 7

        local spawnedVehicle
        if spawnTypes[selection] == "No Mods" then
            spawnedVehicle = createVehicle(vehicle[1], spawnPos, nil, nil, nil, true, false, false)
        elseif spawnTypes[selection] == "Random Mods" then
            tempMods = generateRandomMods(VEHICLE[vehicle[1]][3])
            tempExtraMods = generateRandomMods(extra_mods_max)
            spawnedVehicle = createVehicle(vehicle[1], spawnPos, nil, nil, tempMods, true, false, false, tempExtraMods)
        elseif spawnTypes[selection] == "Max Mods" then
            spawnedVehicle = createVehicle(vehicle[1], spawnPos, nil, nil, VEHICLE[vehicle[1]][3], true, false, true)
        end

        if (vehicle[4] == nil and enterOnSpawn) or (vehicle[4] ~= nil and vehicle[4]) and spawnedVehicle ~= oldVehNetId then
            setPedIntoVehicle(spawnedVehicle, localplayer:get_position())
        end
        if (vehicle[3] == nil and godmodeEnabledSpawn) or (vehicle[3] ~= nil and vehicle[3]) then
            if (vehicle[4] == nil and enterOnSpawn) or (vehicle[4] ~= nil and vehicle[4]) then
                sleep(3) --there is a weird timeout after tping into a car where it will be godmoded, but lose godmode after ~3sec, so we need to wait for that long to re-apply gm so it sticks
            end
            sleep(0.2)
            findAndEnableGodmodeForVehicle(vehicle[1], spawnPos)
        end
    end)
    vehMenu:add_toggle("Spawn with Godmode enabled", function()
        if vehicle[3] ~= nil then
            return vehicle[3]
        end
        return godmodeEnabledSpawn
    end, function(n)
        if vehicle[3] ~= nil then
            local oldModData = vehicle[2][3]
            vehicle[2][3] = nil --Don't want the mod data to be copied into the favorited_vehicles json so we exclude it temporarily from the object
            vehicle[3] = n
            table.sort(favoritedCars, function(a, b)
                return a[2][1]:upper() < b[2][1]:upper()
            end)
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_CARS.json", favoritedCars)
            vehicle[2][3] = oldModData
        else
            godmodeEnabledSpawn = n
        end
    end)
    vehMenu:add_toggle("Immediately enter when spawning", function()
        if vehicle[4] ~= nil then
            return vehicle[4]
        end
        return enterOnSpawn
    end, function(n)
        if vehicle[4] ~= nil then
            local oldModData = vehicle[2][3]
            vehicle[2][3] = nil --Don't want the mod data to be copied into the favorited_vehicles json so we exclude it temporarily from the object
            vehicle[4] = n
            table.sort(favoritedCars, function(a, b)
                return a[2][1]:upper() < b[2][1]:upper()
            end)
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_CARS.json", favoritedCars)
            vehicle[2][3] = oldModData
        else
            enterOnSpawn = n
        end
    end)
    vehMenu:add_toggle("Mark " .. vehicle[2][1] .. " as favorite", function() return isInFavorites(vehicle[1]) ~= false end, function(add)
        if add then
            local oldModData = vehicle[2][3]
            vehicle[2][3] = nil --Don't want the mod data to be copied into the favorited_vehicles json so we exclude it temporarily from the object
            vehicle[3]=godmodeEnabledSpawn
            vehicle[4]=enterOnSpawn
            table.insert(favoritedCars, vehicle)
            table.sort(favoritedCars, function(a, b)
                return a[2][1]:upper() < b[2][1]:upper()
            end)
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_CARS.json", favoritedCars)
            vehicle[2][3] = oldModData
        else
            local favVehicle = isInFavorites(vehicle[1])
            if favVehicle then
                table.remove(favoritedCars, favVehicle)
                table.sort(favoritedCars, function(a, b)
                    return a[2][1]:upper() < b[2][1]:upper()
                end)
                json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_CARS.json", favoritedCars)
            end
        end
    end)
    greyText(vehMenu, "==== Specific Mods Settings ====")
    for index, maxMods in ipairs(VEHICLE[vehicle[1]][3]) do
        local oldMaxMods = maxMods
        if maxMods > -1 then
            vehMenu:add_bare_item("", function()
                if string.sub(eVehicleModType[index], 5) == "WHEELS" and tempExtraMods[1] == 9 or tempExtraMods[1] == 8 then
                    maxMods = 217
                else
                    maxMods = oldMaxMods
                end
                return string.sub(eVehicleModType[index] .. "|(0 to " .. string.format("%2d", maxMods) .. ")",5) .. " ◀ " .. tempMods[index] .. " ▶"
            end, null, function() --On Left
                if string.sub(eVehicleModType[index], 5) == "WHEELS" and tempExtraMods[1] == 9 or tempExtraMods[1] == 8 then --Category 8/9 is Bennys wheels, it has a lot more choice
                    maxMods = 217
                else
                    maxMods = oldMaxMods
                end
                if tempMods[index] - 1 >= 0 then
                    tempMods[index] = tempMods[index] - 1
                end
                if livePreview then
                    local spawnPos = ply:get_position() + ply:get_heading() * 7
                    createVehicle(vehicle[1], spawnPos, nil, nil, tempMods, true, false, false, tempExtraMods)
                end
                return string.sub(eVehicleModType[index] .. "|(0 to " .. string.format("%2d", maxMods) .. ")",5) .. " ◀ " .. tempMods[index] .. " ▶"
            end, function() --on_right
                if string.sub(eVehicleModType[index], 5) == "WHEELS" and tempExtraMods[1] == 9 or tempExtraMods[1] == 8 then
                    maxMods = 217
                else
                    maxMods = oldMaxMods
                end
                if tempMods[index] + 1 <= maxMods then
                    tempMods[index] = tempMods[index] + 1
                end
                if livePreview then
                    local spawnPos = ply:get_position() + ply:get_heading() * 7
                    createVehicle(vehicle[1], spawnPos, nil, nil, tempMods, true, false, false, tempExtraMods)
                end
                return string.sub(eVehicleModType[index] .. "|(0 to " .. string.format("%2d", maxMods) .. ")",5) .. " ◀ " .. tempMods[index] .. " ▶"
            end)
        end
    end
    for index, maxExtraMods in ipairs(extra_mods_max) do
        vehMenu:add_bare_item("", function()
            if not string.find(extra_mods_labels[index]:lower(), "color") then
                return extra_mods_labels[index] .. "|(0 to " .. string.format("%2d", maxExtraMods) .. ")" .. " ◀ " .. tempExtraMods[index] .. " ▶"
            else
                return extra_mods_labels[index] .. "| ◀ " .. string.sub(eVehicleColor[tempExtraMods[index]] .. " ▶", 13)
            end
        end, null, function() --On Left
            if tempExtraMods[index] - 1 >= 0 then
                tempExtraMods[index] = tempExtraMods[index] - 1
            end
            if livePreview then
                local spawnPos = ply:get_position() + ply:get_heading() * 7
                createVehicle(vehicle[1], spawnPos, nil, nil, tempMods, true, false, false, tempExtraMods)
            end
            if not string.find(extra_mods_labels[index]:lower(), "color") then
                return extra_mods_labels[index] .. "|(0 to " .. string.format("%2d", maxExtraMods) .. ")" .. " ◀ " .. tempExtraMods[index] .. " ▶"
            else
                return extra_mods_labels[index] .. "| ◀ " .. string.sub(eVehicleColor[tempExtraMods[index]] .. " ▶", 13)
            end
        end, function() --on_right
            if tempExtraMods[index] + 1 <= maxExtraMods then
                tempExtraMods[index] = tempExtraMods[index] + 1
            end
            if livePreview then
                local spawnPos = ply:get_position() + ply:get_heading() * 7
                createVehicle(vehicle[1], spawnPos, nil, nil, tempMods, true, false, false, tempExtraMods)
            end
            if not string.find(extra_mods_labels[index]:lower(), "color") then
                return extra_mods_labels[index] .. "|(0 to " .. string.format("%2d", maxExtraMods) .. ")" .. " ◀ " .. tempExtraMods[index] .. " ▶"
            else
                return extra_mods_labels[index] .. "| ◀ " .. string.sub(eVehicleColor[tempExtraMods[index]] .. " ▶", 13)
            end
        end)
    end
    greyText(vehMenu, "-----------------------")
    vehMenu:add_toggle("Live Preview", function() return livePreview end, function(toggle) livePreview = toggle end)
    vehMenu:add_action("Spawn with specified mods", function()
        local oldVehNetId = getNetIDOfLastSpawnedVehicle()
        local spawnPos = ply:get_position() + ply:get_heading() * 7

        local spawnedVehicle
        spawnedVehicle = createVehicle(vehicle[1], spawnPos, nil, nil, tempMods, true, false, false, tempExtraMods)

        if (vehicle[4] == nil and enterOnSpawn) or (vehicle[4] ~= nil and vehicle[4]) and spawnedVehicle ~= oldVehNetId then
            setPedIntoVehicle(spawnedVehicle, localplayer:get_position())
        end
        if (vehicle[3] == nil and godmodeEnabledSpawn) or (vehicle[3] ~= nil and vehicle[3]) then
            if (vehicle[4] == nil and enterOnSpawn) or (vehicle[4] ~= nil and vehicle[4]) then
                sleep(3) --there is a weird timeout after tping into a car where it will be godmoded, but lose godmode after ~3sec, so we need to wait for that long to re-apply gm so it sticks
            end
            sleep(0.2)
            findAndEnableGodmodeForVehicle(vehicle[1], spawnPos)
        end
    end)
end

local function buildFavoriteVehiclesSub(player, categorySub)
    success, favoritedCars = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_CARS.json")
    categorySub:clear()
    for _, favoriteVehicle in ipairs(favoritedCars) do
        local vehSub
        vehSub = categorySub:add_submenu(favoriteVehicle[2][1], function() addVehicleEntry(vehSub, favoriteVehicle, player) end)
    end
end

local function countCategory(category)
    local count = 0
    for _, v in pairs(VEHICLE) do
        if v[2] == category then
            count = count + 1
        end
    end
    return count
end

function addVehicleSpawnMenu(ply, sub)
    sub:clear()
    if ply == nil then
        greyText(sub, "Couldn't find player object")
        greyText(sub, "Are you fully loaded yet?")
        return
    end
    success, favoritedCars = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_CARS.json")
    local vehSubs = {}

    if #favoritedCars > 0 then
        vehSubs["Favorites"] = sub:add_submenu("Favorites", function() buildFavoriteVehiclesSub(ply, vehSubs["Favorites"]) end)
    end

    sub:add_action("Add current vehicle to favorites", function()
        local currentVeh = ply:get_current_vehicle()
        local vehData = VEHICLE[currentVeh:get_model_hash()]
        local oldModData = vehData[3] --Don't want the mod data to be copied into the favorited_vehicles json so we exclude it temporarily from the object
        vehData[3] = nil
        local vehicle = { currentVeh:get_model_hash(), vehData, false, false }
        table.insert(favoritedCars, vehicle)
        table.sort(favoritedCars, function(a, b)
            return a[2][1]:upper() < b[2][1]:upper()
        end)
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_CARS.json", favoritedCars)
        vehData[3] = oldModData
    end, function() return ply:is_in_vehicle() and #favoritedCars > 0 and not table.contains(favoritedCars, ply:get_current_vehicle():get_model_hash()) end)

    greyText(sub, "---------------------------")
    local searchSub
    searchSub = sub:add_submenu("🔎 Search for vehicle ➜", function() stringChangerSearch(searchSub, ply) end)
    greyText(sub, "---------------------------")
    -- vehicle = { hash, { name, class} }
    for index, vehicle in ipairs(sorted_vehicles) do --Populate sub with vehicle categories, and fill the categories with all cars belonging to that category
        if not vehSubs[vehicle[2][2]] then
            vehSubs[vehicle[2][2]] = sub:add_submenu(vehicle[2][2])
            vehSubs[vehicle[2][2]]:add_action("Spawn randomized " .. vehicle[2][2] .. " vehicle", function()
                local min_veh_number = index
                local max_veh_number = min_veh_number + countCategory(vehicle[2][2]) - 1
                local spawnPos = ply:get_position() + ply:get_heading() * 7
                local selection = math.random(min_veh_number, max_veh_number)
                createVehicle(sorted_vehicles[selection][1], spawnPos, nil, skip_remove, generateRandomMods(VEHICLE[sorted_vehicles[selection][1]][3]), true, true, false)
                local spawnedModel = sorted_vehicles[selection][1]
                if enterOnSpawn then
                    sleep(0.1)
                    setPedIntoVehicle(getNetIDOfLastSpawnedVehicle(), localplayer:get_position())
                end
                if godmodeEnabledSpawn then
                    if enterOnSpawn then
                        sleep(3) --there is a weird timeout after tping into a car where it will be godmoded, but lose godmode after ~3sec, so we need to wait for that long to re-apply gm so it sticks
                    end
                    sleep(0.2)
                    findAndEnableGodmodeForVehicle(spawnedModel, spawnPos)
                end
            end)
            vehSubs[vehicle[2][2]]:add_toggle("Immediately enter when spawning", function()
                return enterOnSpawn
            end, function(n)
                enterOnSpawn = n
            end)
            vehSubs[vehicle[2][2]]:add_toggle("Spawn with Godmode enabled", function()
                return godmodeEnabledSpawn
            end, function(n)
                godmodeEnabledSpawn = n
            end)
            greyText(vehSubs[vehicle[2][2]], "---------------------------")
        end
        local vehSub
        vehSub = vehSubs[vehicle[2][2]]:add_submenu(vehicle[2][1], function() addVehicleEntry(vehSub, vehicle, ply) end)
    end

    greyText(sub, "---------------------------")

    sub:add_action("Spawn Randomized Vehicle", function()
        local spawnPos = ply:get_position() + ply:get_heading() * 7
        local spawnedModel = giveRandomVehicle(ply)
        if enterOnSpawn then
            sleep(0.1)
            setPedIntoVehicle(getNetIDOfLastSpawnedVehicle(), localplayer:get_position())
        end
        if godmodeEnabledSpawn then
            if enterOnSpawn then
                sleep(3) --there is a weird timeout after tping into a car where it will be godmoded, but lose godmode after ~3sec, so we need to wait for that long to re-apply gm so it sticks
            end
            sleep(0.2)
            findAndEnableGodmodeForVehicle(spawnedModel, spawnPos)
        end
    end)
    sub:add_array_item("Copy nearest Vehicle", spawnTypes, function() return spawnTypeSelectionNearest end, function(selection)
        spawnTypeSelectionNearest = selection
        local minDistance = 5000
        local minDistanceVeh
        local ownVeh = ply:is_in_vehicle() and ply:get_current_vehicle()
        for veh in replayinterface.get_vehicles() do
            local distance = distanceBetween(ply, veh)
            if distance < minDistance and (not ownVeh or (ownVeh:get_model_hash() ~= veh:get_model_hash())) then
                minDistance = distance
                minDistanceVeh = veh
            end
        end
        local spawnPos = ply:get_position() + ply:get_heading() * 7
        if spawnTypes[selection] == "No Mods" then
            createVehicle(minDistanceVeh:get_model_hash(), spawnPos, math.deg(math.atan(ply:get_heading().y, ply:get_heading().x)))
        elseif spawnTypes[selection] == "Random Mods" then
            createVehicle(minDistanceVeh:get_model_hash(), spawnPos, math.deg(math.atan(ply:get_heading().y, ply:get_heading().x)), nil, generateRandomMods(VEHICLE[minDistanceVeh:get_model_hash()][3]), true, true, false)
        elseif spawnTypes[selection] == "Max Mods" then
            createVehicle(minDistanceVeh:get_model_hash(), spawnPos, math.deg(math.atan(ply:get_heading().y, ply:get_heading().x)), nil, VEHICLE[minDistanceVeh:get_model_hash()][3], true, false, true)
        end
        if enterOnSpawn then
            sleep(0.1)
            setPedIntoVehicle(getNetIDOfLastSpawnedVehicle(), localplayer:get_position())
        end
        if godmodeEnabledSpawn then
            if enterOnSpawn then
                sleep(3) --there is a weird timeout after tping into a car where it will be godmoded, but lose godmode after ~3sec, so we need to wait for that long to re-apply gm so it sticks
            end
            sleep(0.2)
            findAndEnableGodmodeForVehicle(minDistanceVeh:get_model_hash(), spawnPos)
        end
    end)
    sub:add_array_item("Copy current Vehicle" , spawnTypes, function() return spawnTypeSelectionCurrent end, function(selection)
        spawnTypeSelectionCurrent = selection
        local currentVeh = ply:get_current_vehicle()
        if not currentVeh then return end
        local spawnPos = ply:get_position() + ply:get_heading() * 7
        if spawnTypes[selection] == "No Mods" then
            createVehicle(currentVeh:get_model_hash(), spawnPos, math.deg(math.atan(ply:get_heading().y, ply:get_heading().x)))
        elseif spawnTypes[selection] == "Random Mods" then
            createVehicle(currentVeh:get_model_hash(), spawnPos, math.deg(math.atan(ply:get_heading().y, ply:get_heading().x)), nil, generateRandomMods(VEHICLE[currentVeh:get_model_hash()][3]), true, true, false)
        elseif spawnTypes[selection] == "Max Mods" then
            createVehicle(currentVeh:get_model_hash(), spawnPos, math.deg(math.atan(ply:get_heading().y, ply:get_heading().x)), nil, VEHICLE[currentVeh:get_model_hash()][3], true, false, true)
        end
        if enterOnSpawn then
            sleep(0.1)
            setPedIntoVehicle(getNetIDOfLastSpawnedVehicle(), localplayer:get_position())
        end
        if godmodeEnabledSpawn then
            if enterOnSpawn then
                sleep(3) --there is a weird timeout after tping into a car where it will be godmoded, but lose godmode after ~3sec, so we need to wait for that long to re-apply gm so it sticks
            end
            sleep(0.2)
            findAndEnableGodmodeForVehicle(currentVeh:get_model_hash(), spawnPos)
        end
    end)
    sub:add_toggle("Immediately enter when spawning", function()
        return enterOnSpawn
    end, function(n)
        enterOnSpawn = n
    end)
    sub:add_toggle("Spawn with Godmode enabled", function()
        return godmodeEnabledSpawn
    end, function(n)
        godmodeEnabledSpawn = n
    end)

    greyText(sub, "---------------------------")

    sub:add_action("TP into last spawned car", function()
        local vehicleNetID = getNetIDOfLastSpawnedVehicle()
        if vehicleNetID then setPedIntoVehicle(getNetIDOfLastSpawnedVehicle(), localplayer:get_position()) end
    end)
end