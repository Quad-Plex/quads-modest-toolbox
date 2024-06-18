local _, favPeds = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/FAVORITED_PEDS.json")

greyText(pedChangerSub, centeredText("     ★🏃 Ped Changer 🏃★"))

function findPedDataFromHash(hash)
    if not hash then return {"", "", ""} end
    for _, pedModelData in ipairs(tbl_PedList) do
        if joaat(pedModelData[2]) == hash then return pedModelData end
    end

    return {"Unknown: " .. hash, hash, "Unknown: " .. hash}
end

local function isInFavoritePeds(pedModel)
    for i, favPedData in ipairs(favPeds) do
        if favPedData[2] == pedModel then
            return i
        end
    end
    return false
end

local function addPedMenu(sub, pedData)
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

local pedSubs = {};
-- { hash, internal_name, display_name}
for _, pedModelData in ipairs(tbl_PedList) do
    local current_category
    for _, pedCategory in ipairs(tbl_PedModelTypes) do
        if string.find(pedModelData[2], "^" .. pedCategory[1]) then
            current_category = pedCategory[2]
            break;
        end
    end
    if current_category == nil then
        current_category = "Other"
    end
    if pedSubs[current_category] == nil then
        pedSubs[current_category] = pedChangerSub:add_submenu(current_category)
    end

    local pedMenu
    pedMenu = pedSubs[current_category]:add_submenu(pedModelData[3], function() addPedMenu(pedMenu, pedModelData) end)
end