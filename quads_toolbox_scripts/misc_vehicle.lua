greyText(vehicleOptionsSub, "----------------------------------")

----------------Sessanta shit------------------
vehicleOptionsSub:add_action("New Sessanta Vehicle", function() newSessantaVehicle() end , function()
    return script("shop_controller"):is_active()
end)

-----------------Podium Changer-------------------
--Create Vehicle Spawn Menu
--Pre-sort this table so we only do it once
local sorted_vehicles = {}
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

local oldPodiumVehicle
local function podiumChanger(sub)
    sub:clear()
    text(sub, "WARNING! This can corrupt garage spots!")
    text(sub, "Be careful which vehicle you obtain!")
    text(sub, "I am NOT responsible for your garages!")
    text(sub, "--------------------------------------")
    local vehSubs = {}

    -- vehicle = { hash, { name, class} }
    for _, vehicle in ipairs(sorted_vehicles) do
        local current_category = vehicle[2][2]
        if vehSubs[current_category] == nil then
            vehSubs[current_category] = sub:add_submenu(current_category)
        end

        vehSubs[current_category]:add_action(vehicle[2][1], function()
            if not oldPodiumVehicle then
                oldPodiumVehicle = getPodiumVehicle()
                greyText(sub, "------------------------")
                sub:add_action("Reset Podium Vehicle to " .. VEHICLE[oldPodiumVehicle][1], function()
                    setPodiumVehicle(oldPodiumVehicle)
                end)
            end
            setPodiumVehicle(vehicle[1])
        end)
    end

    if oldPodiumVehicle and getPodiumVehicle() ~= oldPodiumVehicle then
        greyText(sub, "------------------------")
        sub:add_action("Reset Podium Vehicle to " .. VEHICLE[oldPodiumVehicle][1], function()
            setPodiumVehicle(oldPodiumVehicle)
        end)
    end
end
local podiumSub
podiumSub = vehicleOptionsSub:add_submenu("\u{26A0} Change Casino Podium vehicle \u{26A0} ", function() podiumChanger(podiumSub) end)

--------------------------- Special Export Vehicles Submenu -------------------------
local function buildSpecialExportSubmenu(sub)
    sub:clear()
    local specialExportVehicles = getSpecialExportVehiclesList()
    if not specialExportVehicles then
        text(sub, "!!Couldn't get Export Vehicle List!!")
        text(sub, "You have to be loaded into Online")
        text(sub, "and own the Auto Shop!")
        return
    end
    text(sub, "--- Special Export Vehicles: ---")
    greyText(sub, "Wait ~2 min between selling vehicles")
    greyText(sub, "or the transaction might fail")
    for _, hash in ipairs(specialExportVehicles) do
        sub:add_action("Spawn " .. VEHICLE[hash][1], function()
            local vector = localplayer:get_heading()
            local angle = math.deg(math.atan(vector.y, vector.x))
            createVehicle(hash, localplayer:get_position() + localplayer:get_heading() * 7, angle)
        end)
    end
end
local specialExportSub
specialExportSub = vehicleOptionsSub:add_submenu("$ Get Special Export Vehicles $", function() buildSpecialExportSubmenu(specialExportSub) end)