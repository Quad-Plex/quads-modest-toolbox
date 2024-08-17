local keepSearching = false
local lower_bound = 100000
local upper_bound = 4200000
local old_count = 0

local isFreezerRunning = false
local frozenGlobals = {}
local freezeNumberInt
local freezeNumberFloat

local ScannerTypes = {[0]="Int", "Float", "String"}
local scannerSelection = 0
local ScriptTypes = {[0]="Global", "freemode", "shop_controller", "casino_lucky_wheel", "blackjack", "casinoroulette", "casino_slots", "three_card_poker"}
local scriptSelection = 0

local methodNames = {
    Int = "set_int",
    Float = "set_float",
    String = "set_string"
}

local function setGlobalOrScriptValue(global, value, type, scriptToUse)
    scriptToUse = (scriptToUse ~= "Global") and script(scriptToUse) or nil
    local methodName = methodNames[type]  -- Retrieve the appropriate method name

    -- Select the appropriate method based on the existence of scriptToUse
    local method = scriptToUse and scriptToUse[methodName] or globals[methodName]

    -- Call the selected method with appropriate arguments
    if scriptToUse then
        if type ~= "String" then
            method(scriptToUse, global, value)
        else
            method(scriptToUse, global, value, type == "String" and 30 or nil)
        end
    else
        if type ~= "String" then
            method(global, value)
        else
            method(global, value, type == "String" and 30 or nil)
        end
    end
end

--Change here to easily set the exact value for search
local exact_search_value_int = 69
local exact_search_value_float = 420.69
local exact_search_value_string = "yo"
local smaller_than_search_value = 100
local bigger_than_search_value = 50

local found_globals = {}
local oldResultsHistory = {}

local function getGlobalForTypeAndScript(global, type, selectedScript, translateVehicleHashes)
    local scriptToUse
    if selectedScript and selectedScript ~= "Global" then
        scriptToUse = script(selectedScript)
        if scriptToUse == nil then error("Couldn't load script " .. selectedScript) end
    end
    if type == "Int" then
        local value = scriptToUse and scriptToUse:get_int(global) or globals.get_int(global)
        if translateVehicleHashes then
            local vehicleData = VEHICLE[value]
            if vehicleData then
                return vehicleData[1]
            end
        end
        return value
    elseif type == "Float" then
        return scriptToUse and scriptToUse:get_float(global) or globals.get_float(global)
    elseif type == "String" then
        return scriptToUse and scriptToUse:get_string(global, 30) or tostring(globals.get_string(global, 30))
    else
        error("Wrong type ya dingus")
    end
end

local function setNewNumber(float, customNumber, tempNumberStorage)
    local attemptedNewNumberAsNumber = tonumber(tempNumberStorage)
    if float then
        if customNumber then
            freezeNumberFloat = attemptedNewNumberAsNumber
        else
            exact_search_value_float = attemptedNewNumberAsNumber
        end
    else
        if customNumber then
            freezeNumberInt = attemptedNewNumberAsNumber
        else
            exact_search_value_int = attemptedNewNumberAsNumber
        end
    end
end

local function numberChanger(sub, float, customNumber)
    sub:clear()
    local tempNumberStorage
    if float then
        tempNumberStorage = tostring(customNumber or exact_search_value_float)
        if string.find(tempNumberStorage, "[eE]") then
            tempNumberStorage = string.format("%.f", customNumber or exact_search_value_float)
        end
    else
        tempNumberStorage = tostring(customNumber or exact_search_value_int)
    end
    sub:add_bare_item("", function()
        return "Number: " .. tempNumberStorage
    end, null, null, null)
    greyText(sub, "----------------------------")
    sub:add_action("||⌫ Backspace ⌫|", function()
        tempNumberStorage = string.sub(tempNumberStorage, 1, -2)
        setNewNumber(float, customNumber, tempNumberStorage)
    end)
    if float then
        sub:add_bare_item("", function() return string.find(tempNumberStorage, "%.") and "Remove decimal point" or "Add decimal point" end, function()
            local decimalIndex = string.find(tempNumberStorage, "%.")
            if not decimalIndex then
                tempNumberStorage = addLetterToString(".", tempNumberStorage)
                setNewNumber(float, customNumber, tempNumberStorage)
            else
                if decimalIndex then
                    tempNumberStorage = string.sub(tempNumberStorage, 1, decimalIndex - 1)
                    setNewNumber(float, customNumber, tempNumberStorage)
                end
            end
        end, null, null)
    end
    sub:add_bare_item("", function() return string.find(tempNumberStorage, "-") and "Remove minus sign" or "Add minus sign" end, function()
        if string.sub(tempNumberStorage, 1, 1) ~= "-" then
            tempNumberStorage = "-" .. tempNumberStorage
            setNewNumber(float, customNumber, tempNumberStorage)
        else
            tempNumberStorage = string.sub(tempNumberStorage, 2)
            setNewNumber(float, customNumber, tempNumberStorage)
        end
    end, null, null)
    sub:add_bare_item("",
            function()
                return "Add Number: ◀ " .. showLettersForPosition(selectedNumberPos, numbers) .. " ▶"
            end,
            function()
                local attemptedNewNumber = addLetterToString(numbers[selectedNumberPos], tempNumberStorage)
                local attemptedNewNumberAsNumber = tonumber(attemptedNewNumber)
                if float and (attemptedNewNumberAsNumber == nil
                        or attemptedNewNumberAsNumber == math.huge
                        or attemptedNewNumberAsNumber == -math.huge) then
                    return
                elseif not float and (attemptedNewNumberAsNumber == nil
                        or attemptedNewNumberAsNumber < math.mininteger
                        or attemptedNewNumberAsNumber > math.maxinteger) then
                    return
                end
                tempNumberStorage = attemptedNewNumber
                setNewNumber(float, customNumber, tempNumberStorage)
            end,
            function()
                if selectedNumberPos > 1 then selectedNumberPos = selectedNumberPos - 1 end
                return "Add Number: ◀ " .. showLettersForPosition(selectedNumberPos, numbers) .. " ▶"
            end,
            function()
                if selectedNumberPos < #numbers then selectedNumberPos = selectedNumberPos + 1 end
                return "Add Number: ◀ " .. showLettersForPosition(selectedNumberPos, numbers) .. " ▶"
            end)
end

local function stringChanger(sub, variable, stringToChange, scriptToUse)
    sub:clear()
    sub:add_bare_item("", function()
        local string = stringToChange ~= nil and stringToChange or exact_search_value_string
        return "String: " .. string
    end, null, null, null)
    if stringToChange then
        sub:add_bare_item("", function()
            return "Set " .. getGlobalForTypeAndScript(variable, "String", scriptToUse) .. " to new String"
        end, function()
            setGlobalOrScriptValue(variable, stringToChange, "String", scriptToUse)
        end, null, null)
    end
    greyText(sub, "----------------------------")
    sub:add_action("||⌫ Backspace ⌫|", function()
        if stringToChange then
            stringToChange = string.sub(stringToChange, 1, -2)
        else
            exact_search_value_string = string.sub(exact_search_value_string, 1, -2)
        end
    end)
    sub:add_toggle("Uppercase Letters", function() return uppercaseToggle end, function(toggle) uppercaseToggle = toggle end)
    sub:add_bare_item("",
            function()
                return "Add Letter: ◀ " .. showLettersForPosition(selectedLetterPos, lowercaseLetters) .. " ▶"
            end,
            function()
                if stringToChange then
                    stringToChange = addLetterToString(lowercaseLetters[selectedLetterPos], stringToChange)
                else
                    exact_search_value_string = addLetterToString(lowercaseLetters[selectedLetterPos], exact_search_value_string)
                end
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
                if stringToChange then
                    stringToChange = addLetterToString(numbers[selectedNumberPos], stringToChange)
                else
                    exact_search_value_string = addLetterToString(numbers[selectedNumberPos], exact_search_value_string)
                end
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
                if stringToChange then
                    stringToChange = addLetterToString(symbols[selectedSymbolPos], stringToChange)
                else
                    exact_search_value_string = addLetterToString(symbols[selectedSymbolPos], exact_search_value_string)
                end
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

local success, watchlistGlobals = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/WATCHLIST_GLOBALS.json")
if success then
    print("Watchlist Globals loaded successfully!!")
end
table.sort(watchlistGlobals, function(a, b) return a[1] < b[1] end)

local function getGlobalWatchlistPosition(global)
    for i, watchedGlobalData in ipairs(watchlistGlobals) do
        if watchedGlobalData[1] == global then
            return i
        end
    end
    return false
end

local function getGlobalFrozenPosition(global)
    for i, frozen_globals in ipairs(frozenGlobals) do
        if frozen_globals[1] == global then
            return i
        end
    end
    return false
end

local function getIsSavedString(global)
    return getGlobalWatchlistPosition(global) ~= false and "Saved" or ""
end

local function initialScan(sub, typeSelection, selectedScript, initialSearchValue)
    greyText(sub, "0% processed...")
    local counter = 0
    local counter2 = 1
    local step = (upper_bound - lower_bound) / 10
    for global = lower_bound, upper_bound do
        counter = counter + 1
        if counter == math.floor(step) then
            greyText(sub, counter2 * 10 .. "% processed... (" .. formatNumberWithDots(counter2 * math.ceil(step)) .. " Variables)")
            counter = 0
            counter2 = counter2 + 1
        end
        local value = getGlobalForTypeAndScript(global, typeSelection, selectedScript)
        if value and checkType(value) == typeSelection and (not initialSearchValue or value == initialSearchValue) then
            found_globals[global] = value
        end
    end
    greyText(sub, "100% processed!")
    greyText(sub, "DONE PROCESSING VARIABLES!")
end

local function search(sub, search_type, current_count, typeSelection, selectedScript, exact_search_value)
    sub:clear()
    old_count = current_count
    greyText(sub, "UPDATING VARIABLES.....")
    greyText(sub, "0% searched...")
    local temp_globals = {}
    local temp_new_found_globals = {}
    local counter = 0
    local counter2 = 1
    local step = current_count / 10

    --Get updated values for all found globals
    for global, _ in pairs(found_globals) do
        counter = counter + 1
        if counter == math.floor(step) then
            greyText(sub, counter2 * 10 .. "% searched... (" .. formatNumberWithDots(counter2 * math.ceil(step)) .. " Variables)")
            counter = 0
            counter2 = counter2 + 1
        end
        local value = getGlobalForTypeAndScript(global, typeSelection, selectedScript)
        if value and checkType(value) == typeSelection then
            temp_globals[global] = value
        end
    end

    greyText(sub, "100% searched!!!")
    greyText(sub, "GOT UPDATED VALUES!")
    greyText(sub, "PERFORMING COMPARISONS....")

    --Perform comparisons on each global
    counter = 0
    counter2 = 1
    for global, new_value in pairs(temp_globals) do
        counter = counter + 1
        if counter == math.floor(step) then
            greyText(sub, counter2 * 10 .. "% compared...")
            counter = 0
            counter2 = counter2 + 1
        end
        local old_value = found_globals[global]

        if new_value ~= nil and ((search_type == "unequal" and new_value ~= old_value) or
                (search_type == "equal" and new_value == old_value) or
                (search_type == "smaller" and new_value < old_value) or
                (search_type == "bigger" and new_value > old_value) or
                (search_type == "smallerthanx" and new_value < smaller_than_search_value) or
                (search_type == "biggerthanx" and new_value > bigger_than_search_value) or
                (search_type == "exact" and new_value == exact_search_value))
        then
            temp_new_found_globals[global] = new_value
        end
    end

    greyText(sub, "!!!!DONE!!!!")
    greyText(sub, "Copying old Results for Undo Operation")
    --Copy old found globals into oldResults table for Undo Operation
    table.insert(oldResultsHistory, table.copy(found_globals))
    found_globals = {}
    greyText(sub, "Rebuilding Results Table...")
    found_globals = table.copy(temp_new_found_globals)
end

local translateVehicleHashes = false
local function showNearbyGlobals(sub, global, min_search, max_search, selectedScript)
    sub:clear()
    sub:add_array_item("Show as Type:", ScannerTypes, function()
        return scannerSelection
    end, function(value)
        scannerSelection = value
    end)
    if ScannerTypes[scannerSelection] == "Int" then
        sub:add_toggle("Translate Vehicle Hashes", function() return translateVehicleHashes end, function(n) translateVehicleHashes = n end)
    end
    if min_search > 50 then
        sub:add_action("Show previous 50", function()
            min_search = min_search - 50
            max_search = max_search - 50
            showNearbyGlobals(sub, global, min_search, max_search, selectedScript)
        end)
    end
    for i = min_search, max_search do
        local prefix = ""
        if i == global then
            prefix = "|"
        end
        sub:add_bare_item("", function() return prefix .. selectedScript .. "[" .. i .. "] = " .. tostring(getGlobalForTypeAndScript(i, ScannerTypes[scannerSelection], selectedScript, translateVehicleHashes)) .. " " .. getIsSavedString(i) end, function()
            local watchlistPosition = getGlobalWatchlistPosition(i)
            if not watchlistPosition then
                table.insert(watchlistGlobals, {i, checkType(getGlobalForTypeAndScript(i, ScannerTypes[scannerSelection], selectedScript)), selectedScript})
                json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/WATCHLIST_GLOBALS.json", watchlistGlobals)
            else
                table.remove(watchlistGlobals, watchlistPosition)
                json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/WATCHLIST_GLOBALS.json", watchlistGlobals)
            end
        end, null, null)
    end
    sub:add_action("Show next 50", function()
        min_search = min_search + 50
        max_search = max_search + 50
        showNearbyGlobals(sub, global, min_search, max_search, selectedScript)
    end)
end

local function toggleFreezeGlobal(global, value, typeSelection, selectedScript)
    if not value then
        value = getGlobalForTypeAndScript(global, typeSelection, selectedScript)
    end
    local frozenPosition = getGlobalFrozenPosition(global)
    if frozenPosition then
        table.remove(frozenGlobals, frozenPosition)
    else
        table.insert(frozenGlobals, {global, value, checkType(value), selectedScript})
    end
end

local function advancedGlobalEditor(sub, global, origValue, typeSelection, selectedScript)
    sub:clear()
    if typeSelection == "Int" then
        freezeNumberInt = origValue
    elseif typeSelection == "Float" then
        freezeNumberFloat = origValue
    end
    sub:add_bare_item("",function() return selectedScript .. "[" .. global .. "] = " .. tostring(getGlobalForTypeAndScript(global, typeSelection, selectedScript)) end, null, null, null)
    greyText(sub, selectedScript .. "[" .. global .. "] = ".. tostring(origValue) .. " (Orig. Value)")
    addText(sub, "---------------------------")
    sub:add_int_range("As Int:", 1, -MAX_INT, MAX_INT, function()
        if selectedScript and selectedScript ~= "Global"  then
            local scriptToUse = script(selectedScript)
            return scriptToUse:get_int(global)
        else
            return globals.get_int(global)
        end
    end, function(n)
        setGlobalOrScriptValue(global, n, "Int", selectedScript)
    end)
    sub:add_float_range("As Float:", 1, -math.huge, math.huge, function()
        if selectedScript and selectedScript ~= "Global" then
            local scriptToUse = script(selectedScript)
            return scriptToUse:get_float(global)
        else
            return globals.get_float(global)
        end
    end, function(n)
        setGlobalOrScriptValue(global, n, "Float", selectedScript)
    end)
    sub:add_bare_item("", function() return "As String:|" .. getGlobalForTypeAndScript(global, "String", selectedScript) end, null, null, null)
    local stringChangerSub
    stringChangerSub = sub:add_submenu("Set new String", function() stringChanger(stringChangerSub, global, getGlobalForTypeAndScript(global, "String", selectedScript), selectedScript) end)
    greyText(sub, "--- ❄️ Freezing Options ❄️ ---")
    sub:add_toggle("Freeze Current Value", function() return getGlobalFrozenPosition(global) ~= false end, function(_)
        toggleFreezeGlobal(global, nil, typeSelection, selectedScript)
        if not isFreezerRunning then
            menu.emit_event('startFreezer')
        end
    end)
    if checkType(getGlobalForTypeAndScript(global, typeSelection, selectedScript)) == "Int" then
        sub:add_int_range("Freeze Custom Value (Int):", 1, -MAX_INT, MAX_INT, function() return getGlobalFrozenPosition(global) and frozenGlobals[getGlobalFrozenPosition(global)][2] or freezeNumberInt
        end, function(n)
            toggleFreezeGlobal(global, n, typeSelection, selectedScript)
            if not isFreezerRunning then
                menu.emit_event('startFreezer')
            end
        end)
        local intChangerSub
        intChangerSub = sub:add_submenu("Enter custom freeze int", function() numberChanger(intChangerSub, false, freezeNumberInt) end)
    elseif checkType(getGlobalForTypeAndScript(global, typeSelection, selectedScript)) == "Float" then
        sub:add_float_range("Freeze Custom Value (Float):", 1, -MAX_INT, MAX_INT, function() return getGlobalFrozenPosition(global) and frozenGlobals[getGlobalFrozenPosition(global)][2] or freezeNumberFloat
        end, function(n)
            toggleFreezeGlobal(global, n, typeSelection, selectedScript)
            if not isFreezerRunning then
                menu.emit_event('startFreezer')
            end
        end)
        local floatChangerSub
        floatChangerSub = sub:add_submenu("Enter custom freeze float", function() numberChanger(floatChangerSub, true, freezeNumberFloat) end)
    elseif checkType(getGlobalForTypeAndScript(global, typeSelection, selectedScript)) == "String" then
        sub:add_bare_item("", function() return "Freeze (String): " .. exact_search_value_string end, function()
            toggleFreezeGlobal(global, exact_search_value_string, typeSelection, selectedScript)
            if not isFreezerRunning then
                menu.emit_event('startFreezer')
            end
        end, null, null)
        local frozenStringChangerSub
        frozenStringChangerSub = sub:add_submenu("Enter new String for String Freeze", function() stringChanger(frozenStringChangerSub) end)
    end
    greyText(sub, "---------------------------")
    sub:add_action("Set Exact Search to Global Value", function()
        if typeSelection == "Int" then
            exact_search_value_int = getGlobalForTypeAndScript(global, typeSelection, selectedScript)
        elseif typeSelection == "Float" then
            exact_search_value_float = getGlobalForTypeAndScript(global, typeSelection, selectedScript)
        elseif typeSelection == "String" then
            exact_search_value_string = getGlobalForTypeAndScript(global, typeSelection, selectedScript)
        end
    end)
    sub:add_toggle("Add " .. selectedScript .. "[".. global .. "] to watchlist", function() return getGlobalWatchlistPosition(global) ~= false end, function(add)
        if add then
            table.insert(watchlistGlobals, {global, checkType(getGlobalForTypeAndScript(global, typeSelection, selectedScript)), selectedScript})
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/WATCHLIST_GLOBALS.json", watchlistGlobals)
        else
            local watchlistPosition = getGlobalWatchlistPosition(global)
            if watchlistPosition then
                table.remove(watchlistGlobals, watchlistPosition)
                json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/WATCHLIST_GLOBALS.json", watchlistGlobals)
            end
        end
    end)
    greyText(sub, "----------------------------------")
    local nearbyGlobalsSub
    nearbyGlobalsSub = sub:add_submenu("==Nearby Variables Memory Viewer==", function()
        local min_search = global - 25
        if min_search < 0 then min_search = 0 end
        local max_search = global + 24
        showNearbyGlobals(nearbyGlobalsSub, global, min_search, max_search, selectedScript)
    end)
    greyText(sub, "Click on any Global in the list")
    greyText(sub, "to add/remove it from watchlist")
end

local function printFoundGlobals(sub, numToPrint, typeSelection, selectedScript, start_index)
    --Prepare a sorted table for all found globals
    local keys = {}
    for key, _ in pairs(found_globals) do
        table.insert(keys, key)
    end
    table.sort(keys)

    local counter = 0
    for _, global in ipairs(keys) do
        counter = counter + 1
        if counter == numToPrint or start_index and counter < start_index then
            return
        end
        sub:add_bare_item("",function() return selectedScript .. "[" .. global .. "] = " .. tostring(getGlobalForTypeAndScript(global, typeSelection, selectedScript)) .. "|(Print)" end, function() print(selectedScript .. "[" .. global .. "] = " .. getGlobalForTypeAndScript(global, typeSelection, selectedScript)) end, null, null)
        local globalSub
        globalSub = sub:add_submenu("|More Options:", function() advancedGlobalEditor(globalSub, global, getGlobalForTypeAndScript(global, typeSelection, selectedScript), typeSelection, selectedScript) end)
    end
    sub:add_action("Print all found variables to console", function()
        counter = 0
        for _, key in ipairs(keys) do
            counter = counter + 1
            if counter == numToPrint then
                return
            end
            local global = key
            local value = found_globals[key]
            print("Global[" .. global .. "] = " .. value)
        end
    end)
end

local function addWatchListGlobals(sub)
    if #watchlistGlobals > 0 then
        greyText(sub, "======= WATCHLISTED VALUES =======")
        for _, globalData in ipairs(watchlistGlobals) do
            sub:add_bare_item("", function()
                return globalData[3] .. "[" .. globalData[1] .. "] = " .. tostring(getGlobalForTypeAndScript(globalData[1], globalData[2], globalData[3])) .. "|(" .. globalData[2] .. ")"
            end, function()
                print(globalData[3] .. "[" .. globalData[1] .. "] = " .. tostring(getGlobalForTypeAndScript(globalData[1], globalData[2], globalData[3])))
            end, null, null)
            local globalSub
            globalSub = sub:add_submenu("|More Options:", function()
                advancedGlobalEditor(globalSub, globalData[1], getGlobalForTypeAndScript(globalData[1], globalData[2], globalData[3]), globalData[2], globalData[3])
            end)
        end
    end
end

local function updateGlobalScanner(sub)
    success, watchlistGlobals = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/WATCHLIST_GLOBALS.json")
    sub:clear()
    local current_num_of_results = tableCount(found_globals)
    if keepSearching then
        sub:add_action("CLICK HERE TO DISABLE", function() keepSearching = false end)
        greyText(sub,"------Results: " .. current_num_of_results .. " (" .. (current_num_of_results - old_count) .. ") -------")
        greyText(sub, "DISABLE WITHIN 2s")
        sleep(1)
        if not keepSearching then updateGlobalScanner(sub) return end
        greyText(sub, "DISABLE WITHIN 1s")
        sleep(1)
        if not keepSearching then updateGlobalScanner(sub) return end
        greyText(sub, "CONTINUING SEARCH")
        search(sub, "equal", current_num_of_results, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection])
        updateGlobalScanner(sub)
        return
    end

    ------No results yet, so do the initial scan routine
    if found_globals == nil or (current_num_of_results == 0) then
        sub:add_int_range("Lower Bound: ", 100000, 1, 9999999, function() return lower_bound end,
                function(value) lower_bound = value end)
        sub:add_int_range("Upper Bound: ", 100000, 1, 9999999, function() return upper_bound end,
                function(value) upper_bound = value end)
        sub:add_array_item("Search for Type:", ScannerTypes, function()
            return scannerSelection
        end, function(value)
            scannerSelection = value
            updateGlobalScanner(sub)
        end)
        sub:add_array_item("Search in Script:", ScriptTypes, function()
            return scriptSelection
        end, function(value)
            scriptSelection = value
            updateGlobalScanner(sub)
        end)
        if ScannerTypes[scannerSelection] == "Int" then
            sub:add_int_range("| 🔎 Scan for Int 🔍", 1, -MAX_INT, MAX_INT, function() return exact_search_value_int
            end, function(value)
                exact_search_value_int = value
                initialScan(sub, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection], exact_search_value_int)
                updateGlobalScanner(sub) end)
            local intChangerSub
            intChangerSub = sub:add_submenu("Enter custom (long) int", function() numberChanger(intChangerSub, false) end)
        elseif ScannerTypes[scannerSelection] == "Float" then
            sub:add_float_range("| 🔎 Scan for Float 🔍", 1, -MAX_INT, MAX_INT, function() return exact_search_value_float
            end, function(value)
                exact_search_value_float = value
                initialScan(sub, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection], exact_search_value_float)
                updateGlobalScanner(sub) end)
            local floatChangerSub
            floatChangerSub = sub:add_submenu("Enter custom (long) float", function() numberChanger(floatChangerSub, true) end)
        elseif ScannerTypes[scannerSelection] == "String" then
            sub:add_bare_item("", function() return "| 🔎 Scan for String 🔍 '" .. exact_search_value_string .. "'"
            end, function()
                initialScan(sub, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection], exact_search_value_string)
                updateGlobalScanner(sub) end, null, null)
            local stringChangerSub
            stringChangerSub = sub:add_submenu("Enter new String for String Search", function() stringChanger(stringChangerSub) end)
        end
        sub:add_action( #oldResultsHistory == 0 and "| 🔎 Scan for Unknown Value 🔍" or "|🔄 Start New Unknown Scan 🔄", function()
            greyText(sub, "SCANNING.....")
            oldResultsHistory = {}
            initialScan(sub, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection], initialSearchValue)
            updateGlobalScanner(sub) end)
        greyText(sub, centeredText("❌ NO RESULTS ❌"))
        if #oldResultsHistory > 0 then
            sub:add_action("↩️ UNDO LAST SEARCH OPERATION ↩️", function()
                if #oldResultsHistory > 0 then
                    found_globals = table.remove(oldResultsHistory)
                    old_count = current_num_of_results
                    updateGlobalScanner(sub)
                end
            end)
        end
        addWatchListGlobals(sub)
    else
        --There are results, so print the menu showing them
        greyText(sub, "Searching through " .. ScriptTypes[scriptSelection] .. "...")
        sub:add_array_item("Search for Type:", ScannerTypes, function()
            return scannerSelection
        end, function(value)
            scannerSelection = value
            updateGlobalScanner(sub)
        end)
        sub:add_action("!= SEARCH: changed value", function() search(sub, "unequal", current_num_of_results, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection]) updateGlobalScanner(sub) end)
        sub:add_action("== SEARCH: unchanged value", function() search(sub, "equal", current_num_of_results, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection]) updateGlobalScanner(sub) end)
        sub:add_toggle("|Keep searching unchanged", function() return keepSearching
        end, function(value) keepSearching = value end)
        sub:add_action("<  SEARCH: smaller than before", function() search(sub, "smaller", current_num_of_results, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection]) updateGlobalScanner(sub) end)
        sub:add_action(">  SEARCH: bigger than before", function() search(sub, "bigger", current_num_of_results, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection]) updateGlobalScanner(sub) end)
        sub:add_int_range("<x SEARCH: smaller than x:", 1, -MAX_INT, MAX_INT, function() return smaller_than_search_value end,
                function(value) smaller_than_search_value = value
                    search(sub, "smallerthanx", current_num_of_results, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection])
                    updateGlobalScanner(sub) end)
        sub:add_int_range(">x SEARCH: bigger than x:", 1, -MAX_INT, MAX_INT, function() return bigger_than_search_value end,
                function(value) bigger_than_search_value = value
                    search(sub, "biggerthanx", current_num_of_results, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection])
                    updateGlobalScanner(sub) end)
        if ScannerTypes[scannerSelection] == "Int" then
            sub:add_int_range(":  SEARCH: exact int", 1, -MAX_INT, MAX_INT, function() return exact_search_value_int
            end, function(value)
                        exact_search_value_int = value
                        search(sub, "exact", current_num_of_results, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection], exact_search_value_int)
                        updateGlobalScanner(sub) end)
            local intChangerSub
            intChangerSub = sub:add_submenu("Enter custom (long) int", function() numberChanger(intChangerSub, false) end)
        elseif ScannerTypes[scannerSelection] == "Float" then
            sub:add_float_range(":  SEARCH: exact float", 1, -MAX_INT, MAX_INT, function() return exact_search_value_float
            end, function(value)
                        exact_search_value_float = value
                        search(sub, "exact", current_num_of_results, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection], exact_search_value_float)
                        updateGlobalScanner(sub) end)
            local floatChangerSub
            floatChangerSub = sub:add_submenu("Enter custom (long) float", function() numberChanger(floatChangerSub, true) end)
        elseif ScannerTypes[scannerSelection] == "String" then
            sub:add_bare_item("", function() return ":  SEARCH: exact String |" .. exact_search_value_string
            end, function()
                exact_search_value_string = value
                search(sub, "exact", current_num_of_results, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection], exact_search_value_string)
                updateGlobalScanner(sub) end, null, null)
            local stringChangerSub
            stringChangerSub = sub:add_submenu("Enter new String for String Search", function() stringChanger(stringChangerSub) end)
        end
        if #oldResultsHistory > 0 then
            sub:add_action("!!! UNDO LAST SEARCH OPERATION", function()
                if #oldResultsHistory > 0 then
                    found_globals = table.remove(oldResultsHistory)
                    old_count = current_num_of_results
                    updateGlobalScanner(sub)
                end
            end)
        end

        sub:add_action("|🔄 RESET SEARCH 🔄", function()
            table.insert(oldResultsHistory, table.copy(found_globals))
            found_globals = {}
            updateGlobalScanner(sub)
        end)

        local resultChange = current_num_of_results - old_count
        resultChange = resultChange > 0 and "+" .. tostring(resultChange) or tostring(resultChange)

        addWatchListGlobals(sub)

        greyText(sub,"------Results: " .. current_num_of_results .. " (" .. resultChange .. ") -------")

        if current_num_of_results <= 50 then
            printFoundGlobals(sub, 50, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection])
        else
            local hasRun=false
            sub:add_action("Print first 50 results", function()
                if not hasRun then
                    printFoundGlobals(sub, 50, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection])
                    hasRun=true
                    sub:add_action("Show next 50 results", function()
                        printFoundGlobals(sub, 100, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection], 51)
                        sub:add_action("Show next 50 results", function()
                            printFoundGlobals(sub, 150, ScannerTypes[scannerSelection], ScriptTypes[scriptSelection], 101)
                        end)
                    end)
                end
            end, function() return not hasRun end)
        end
    end
end

--{global, value, checkType(value), selectedScript})
local function startFreezer()
    while #frozenGlobals > 0 do
        isFreezerRunning = true
        -- Iterate over frozenGlobals
        for _, globalData in ipairs(frozenGlobals) do
            setGlobalOrScriptValue(globalData[1], globalData[2], globalData[3], globalData[4])

            sleep(0.09)
        end
    end
    isFreezerRunning = false
end
menu.register_callback('startFreezer', startFreezer)

local scannerMenu
scannerMenu = debugToolsSub:add_submenu("\\\\ Global Scanner (Cheat Engine) //", function() updateGlobalScanner(scannerMenu) end)