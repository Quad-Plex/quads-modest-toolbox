require("scripts/quads_toolbox/toolbox_data/globals_and_utils")

local keepSearching = false
local lower_bound = 100000
local upper_bound = 6000000
local old_count = 0

--Change here to easily set the exact value for search
local exact_search_value = -1233767450

local found_globals = {}

local function null()
end

--We need this counter because we're working with non-contingent tables
function tableCount(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

local function initialScan()
    for global = lower_bound, upper_bound do
        local value = globals.get_int(global)
        if value then
            found_globals[global] = value
        end
    end
end

local function search(sub, search_type, current_count)
    old_count = current_count
    text(sub, "UPDATING GLOBALS.....")
    local temp_globals = {}
    local temp_found_globals = {}

    --Get updated values for all found globals
    for global, _ in pairs(found_globals) do
        temp_globals[global] = globals.get_int(global)
    end

    text(sub, "GOT UPDATED VALUES!")
    text(sub, "PERFORMING COMPARISONS....")

    --Perform comparisons on each global
    for global, old_value in pairs(found_globals) do
        local new_value = temp_globals[global]

        if (search_type == "unequal" and new_value ~= old_value) or
                (search_type == "equal" and new_value == old_value) or
                (search_type == "smaller" and new_value < old_value) or
                (search_type == "bigger" and new_value > old_value) or
                (search_type == "exact" and new_value == exact_search_value)
        then
            temp_found_globals[global] = new_value
        else
        end
    end

    text(sub, "!!!!DONE!!!!")
    found_globals = {}
    text(sub, "Rebuilding Results Table...")
    for global, value in pairs(temp_found_globals) do
        found_globals[global] = value
    end
end

local function updateGlobalScanner(sub)
    sub:clear()
    local current_num_of_results = tableCount(found_globals)
    if keepSearching then
        sub:add_action("CLICK HERE TO DISABLE", function() keepSearching = false end)
        greyText(sub,"------Results: " .. current_num_of_results .. " (" .. (current_num_of_results - old_count) .. ") -------")
        text(sub, "DISABLE WITHIN 2s")
        sleep(1)
        if not keepSearching then updateGlobalScanner(sub) goto finish end
        text(sub, "DISABLE WITHIN 1s")
        sleep(1)
        if not keepSearching then updateGlobalScanner(sub) goto finish end
        text(sub, "CONTINUING SEARCH")
        search(sub, "equal", current_num_of_results)
        updateGlobalScanner(sub)
        goto finish
    end

    if found_globals == nil or (current_num_of_results == 0) then
        sub:add_int_range("Lower Bound: ", 100000, 1, 9999999, function() return lower_bound end,
                function(value) lower_bound = value end)
        sub:add_int_range("Upper Bound: ", 100000, 1, 9999999, function() return upper_bound end,
                function(value) upper_bound = value end)
        sub:add_action("-Start initial scan-", function()
            text(sub, "SCANNING.....")
            initialScan()
            updateGlobalScanner(sub) end)
        goto finish
    end
    sub:add_action("!= SEARCH: changed value", function() search(sub, "unequal", current_num_of_results) updateGlobalScanner(sub) end)
    sub:add_action("== SEARCH: unchanged value", function() search(sub, "equal", current_num_of_results) updateGlobalScanner(sub) end)
    sub:add_toggle("|Keep searching unchanged", function() return keepSearching
    end, function(value) keepSearching = value end)
    sub:add_action("<  SEARCH: smaller value", function() search(sub, "smaller", current_num_of_results) updateGlobalScanner(sub) end)
    sub:add_action(">  SEARCH: bigger value", function() search(sub, "bigger", current_num_of_results) updateGlobalScanner(sub) end)
    sub:add_int_range(":  SEARCH: exact", 1, 0, 9999999, function() return exact_search_value end,
            function(value) exact_search_value = value
                            search(sub, "exact", current_num_of_results)
                            updateGlobalScanner(sub) end)

    greyText(sub,"------Results: " .. current_num_of_results .. " (" .. (current_num_of_results - old_count) .. ") -------")

    if current_num_of_results <= 100 then
        local keys = {}
        for key, _ in pairs(found_globals) do
            table.insert(keys, key)
        end
        -- Sort the keys
        table.sort(keys)
        for _, key in ipairs(keys) do
            local global = key
            sub:add_bare_item("",function() return "Global[" .. global .. "] = " .. globals.get_int(global) .. "|(Print)" end, function() print("Global[" .. global .. "] = " .. globals.get_int(global)) end, null, null)
        end
    end
    sub:add_action("Print found globals to console", function()
        local keys = {}
        for key, _ in pairs(found_globals) do
            table.insert(keys, key)
        end
        -- Sort the keys
        table.sort(keys)
        for _, key in ipairs(keys) do
            local global = key
            local value = found_globals[key]
            print("Global[" .. global .. "] = " .. value)
        end
    end)

    ::finish::
end

scannerMenu = toolbox:add_submenu("(((( Global Scanner ))))", function() updateGlobalScanner(scannerMenu) end)