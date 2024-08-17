local _, favPeds = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_PEDS.json")

greyText(pedChangerSub, centeredText("     ★🏃 Ped Changer 🏃★"))

function findPedDataFromHash(hash)
    if not hash then return {"", "", ""} end
    for _, pedModelData in ipairs(tbl_PedList) do
        if joaat(pedModelData[2]) == hash then return pedModelData end
    end

    return {"Unknown: " .. hash, hash, "Unknown: " .. hash}
end

local function searchForPed(searchString)
    local results = {}
    for index, ped in ipairs(tbl_PedList) do
        if string.find(ped[3]:lower(), searchString:lower()) then
            table.insert(results, ped)
        end
    end
    return results
end


----------------- Keyboard Ped Search ---------------------
local function stringChangerSearch(sub, results, oldSearch)
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
        local newResults = searchForPed(searchString)
        if #newResults > 0 then
            stringChangerSearch(sub, newResults, searchString)
        end
    end, null, null)
    greyText(sub, "---------------------------")
    if #results < 1 then
        addText(sub, "❌ No results yet! ❌")
    else
        local count = 0
        for _, ped in ipairs(results) do
            if count == 40 then
                goto continue
            end
            local pedSub
            pedSub = sub:add_submenu(ped[3], function() addPedMenu(pedSub, ped) end)
            count = count + 1
        end
    end
    ::continue::
    greyText(sub, "---------------------------")
end


local function isInFavoritePeds(pedModel)
    for i, favPedData in ipairs(favPeds) do
        if favPedData[2] == pedModel then
            return i
        end
    end
    return false
end

function addPedMenu(sub, pedData)
    sub:clear()
    greyText(sub, "Selected Ped: " .. pedData[3])
    sub:add_toggle("Mark " .. pedData[3] .. " as favorite", function() return isInFavoritePeds(pedData[2]) ~= false end, function(state)
        if state then
            table.insert(favPeds, pedData)
            table.sort(favPeds, function(a, b)
                return a[2]:upper() < b[2]:upper()
            end)
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_PEDS.json", favPeds)
        else
            local favPed = isInFavoritePeds(pedData[2])
            if favPed then
                table.remove(favPeds, favPed)
                table.sort(favPeds, function(a, b)
                    return a[2]:upper() < b[2]:upper()
                end)
                json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_PEDS.json", favPeds)
            end
        end
    end)
    sub:add_action("Turn into " .. pedData[3], function()
        setPlayerModel(joaat(pedData[2]))
    end)
    sub:add_action("     🔄 Reset Ped Model 🔄", function() setPlayerModel(joaat(default_models[getGender()])) end)
    sub:add_bare_item("", function() return "|Sleep: ◀ " .. playerlistSettings.pedChangerSleepTimeout .. " ▶" end, null, function()
        if playerlistSettings.pedChangerSleepTimeout > 0.001 then
            playerlistSettings.pedChangerSleepTimeout = tonumber(string.format("%.3f", playerlistSettings.pedChangerSleepTimeout - 0.001))
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json", playerlistSettings)
        end
        return "|Sleep: ◀ " .. playerlistSettings.pedChangerSleepTimeout .. " ▶"
    end, function()
        if playerlistSettings.pedChangerSleepTimeout < 1 then
            playerlistSettings.pedChangerSleepTimeout = tonumber(string.format("%.3f", playerlistSettings.pedChangerSleepTimeout + 0.001))
            json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json", playerlistSettings)
        end
        return "|Sleep: ◀ " .. playerlistSettings.pedChangerSleepTimeout .. " ▶"
    end)
    greyText(sub, "If the ped change doesn't work,")
    greyText(sub, "Try changing the sleep time ")
    greyText(sub, "step by step until it works")
    greyText(sub, "Sometimes spamming 'Turn into' helps")
end

local function showFavoritePedsMenu(sub)
    sub:clear()
    _, favPeds = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_PEDS.json")
    if #favPeds == 0 then
        greyText(sub, "No favorited peds yet!")
    else
        for _, favPedData in ipairs(favPeds) do
            local favPedMenu
            favPedMenu = sub:add_submenu(favPedData[3], function() addPedMenu(favPedMenu, favPedData) end)
        end
    end
end

local function findNearestPedModelHash()
    local minDistance = MAX_INT
    local minPed
    for ped in replayinterface.get_peds() do
        if ped and ped ~= localplayer and distanceBetween(localplayer, ped) < minDistance then
            minDistance = distanceBetween(localplayer, ped)
            minPed = ped
        end
    end
    if minPed then
        return minPed:get_model_hash()
    end
end

pedChangerSub:add_bare_item("", function() return "Current Ped: " .. findPedDataFromHash(localplayer and localplayer:get_model_hash())[3] or "" end, null, null, null)
pedChangerSub:add_bare_item("", function()
    _, favPeds = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_PEDS.json")
    local currentPedData = findPedDataFromHash(localplayer and localplayer:get_model_hash())
    local shouldAdd = not isInFavoritePeds(currentPedData[2]) and not (localplayer and (localplayer:get_model_hash() == joaat(default_models[getGender()]))) and not (currentPedData[2] == "")
    return shouldAdd and "+ Add " .. currentPedData[3] .. " to favorites +" or ""
end, function()
    _, favPeds = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_PEDS.json")
    local currentPedData = findPedDataFromHash(localplayer and localplayer:get_model_hash())
    local shouldAdd = not isInFavoritePeds(currentPedData[2]) and not (localplayer:get_model_hash() == joaat(default_models[getGender()]))
    if shouldAdd then
        table.insert(favPeds, findPedDataFromHash(localplayer and localplayer:get_model_hash()))
        table.sort(favPeds, function(a, b)
            return a[2]:upper() < b[2]:upper()
        end)
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_PEDS.json", favPeds)
    end
end, null, null)
pedChangerSub:add_action("Turn into nearest Ped", function() setPlayerModel(findNearestPedModelHash()) end)
pedChangerSub:add_action("Turn into random Ped", function()
    local random_selection = tbl_PedList[math.random(1, #tbl_PedList)][2]
    setPlayerModel(joaat(random_selection))
end)
pedChangerSub:add_bare_item("", function() return "|Sleep: ◀ " .. playerlistSettings.pedChangerSleepTimeout .. " ▶" end, null, function()
    if playerlistSettings.pedChangerSleepTimeout > 0.001 then
        playerlistSettings.pedChangerSleepTimeout = tonumber(string.format("%.3f", playerlistSettings.pedChangerSleepTimeout - 0.001))
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json", playerlistSettings)
    end
    return "|Sleep: ◀ " .. playerlistSettings.pedChangerSleepTimeout .. " ▶"
end, function()
    if playerlistSettings.pedChangerSleepTimeout < 1 then
        playerlistSettings.pedChangerSleepTimeout = tonumber(string.format("%.3f", playerlistSettings.pedChangerSleepTimeout + 0.001))
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json", playerlistSettings)
    end
    return "|Sleep: ◀ " .. playerlistSettings.pedChangerSleepTimeout .. " ▶"
end)
pedChangerSub:add_action("     🔄 Reset Ped Model 🔄", function() setPlayerModel(joaat(default_models[getGender()])) end)
greyText(pedChangerSub, "-------------------------")
local favoritePedsMenu
favoritePedsMenu = pedChangerSub:add_submenu("Favorited Peds", function() showFavoritePedsMenu(favoritePedsMenu) end)
greyText(pedChangerSub, "-------------------------")
local pedSearchSub
pedSearchSub = pedChangerSub:add_submenu("🔎 Search for specific Ped ➜", function() stringChangerSearch(pedSearchSub) end)
greyText(pedChangerSub, "-------------------------")


local pedSubs = {}
local categorizedPeds = {}

-- Categorize each ped
for _, pedModelData in ipairs(tbl_PedList) do
    local current_category
    for _, pedCategory in ipairs(tbl_PedModelTypes) do
        if string.find(pedModelData[2], "^" .. pedCategory[1]) then
            current_category = pedCategory[2]
            break
        end
    end

    if current_category == nil then
        current_category = "Other"
    end

    -- Create a table for the category if it doesn't exist
    if categorizedPeds[current_category] == nil then
        categorizedPeds[current_category] = {}
    end

    -- Add the ped to the appropriate category table
    table.insert(categorizedPeds[current_category], pedModelData)
end

-- Sort each category table by display_name
for category, pedList in pairs(categorizedPeds) do
    table.sort(pedList, function(a, b)
        return a[3] < b[3]  -- Sort by display_name (3rd element in pedModelData)
    end)
end

-- Get the categories and sort them alphabetically
local sortedCategories = {}
for category in pairs(categorizedPeds) do
    table.insert(sortedCategories, category)
end
table.sort(sortedCategories)

-- Create the submenus and add peds in sorted order
for _, category in ipairs(sortedCategories) do
    -- Create a submenu for the category if it doesn't exist
    if pedSubs[category] == nil then
        pedSubs[category] = pedChangerSub:add_submenu(category)
    end

    -- Add each ped to the category submenu in sorted order
    for _, pedModelData in ipairs(categorizedPeds[category]) do
        local pedMenu
        pedMenu = pedSubs[category]:add_submenu(pedModelData[3], function() addPedMenu(pedMenu, pedModelData) end)
    end
end