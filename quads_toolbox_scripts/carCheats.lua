--------------------------------
--traffic noclip
--------------------------------
vehicleOptionsSub:add_toggle("Disable Traffic/Player Collisions", function()
    return loopData.trafficNoclipToggle
end, function(value)
    if value then
        loopData.trafficNoclipToggle = true
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
        menu.emit_event('vehicleNoclip')
    else
        loopData.trafficNoclipToggle = false
        json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/LOOPS_STATE.json", loopData)
    end
end)

---------------------------------------------------------------------------
--Speedometer (Banner or license plate)
---------------------------------------------------------------------------

speedDisplayEnabled = false
local speedDisplayRunning= false
function speedDisplay()
    local myPlayer = player.get_player_ped()
    while speedDisplayEnabled do
        speedDisplayRunning = true
        local current_vehicle
        if not myPlayer:is_in_vehicle() then
            current_vehicle = myPlayer
        else
            current_vehicle = myPlayer:get_current_vehicle()
        end
        local velocity = current_vehicle:get_velocity()
        local abs_velocity = math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y + velocity.z * velocity.z)
        local trueSpeed
        if formatStyles[playerlistSettings.stringFormat] == "Metric (EU)" then
            trueSpeed = math.floor(3.6371084 * abs_velocity) --KMH
            if playerlistSettings.speedDisplaySelection == "Banner" then
                displayHudBanner("FM_AE_SORT_3", "AMCH_KMHN", math.floor(3.6371084 * abs_velocity), 108)
            elseif myPlayer:is_in_vehicle() then
                current_vehicle:set_number_plate_text(" " .. trueSpeed .. " KMH")
            end
        else
            trueSpeed = math.floor(2.26 * abs_velocity) --MPH
            if playerlistSettings.speedDisplaySelection == "Banner" then
                displayHudBanner("FM_AE_SORT_3", "AMCH_MPHN", math.floor(2.26 * abs_velocity), 108)
            elseif myPlayer:is_in_vehicle() then
                current_vehicle:set_number_plate_text(" " .. trueSpeed .. " MPH")
            end
        end
        sleep(0.09)
    end
    speedDisplayRunning = false
end
menu.register_callback('speedDisplay', speedDisplay)
vehicleOptionsSub:add_toggle("Toggle Speedometer", function()
    return speedDisplayEnabled
end, function(toggle)
    speedDisplayEnabled = toggle
    if not speedDisplayRunning then
        menu.emit_event("speedDisplay")
    end
end)
local speedDisplayTypes = { [0]="Banner", "License Plate"}
local speedDisplayType = 0
vehicleOptionsSub:add_array_item("Speedometer Type:", speedDisplayTypes, function() return speedDisplayType end, function(value)
    speedDisplayType = value
    playerlistSettings.speedDisplaySelection = speedDisplayTypes[speedDisplayType]
    json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json", playerlistSettings)
end)
vehicleOptionsSub:add_array_item("Show Speed in: ", formatStyles, function()
    return playerlistSettings.stringFormat
end, function(value)
    playerlistSettings.stringFormat = value
    json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json", playerlistSettings)
end)

--------------------------------
--functions for carboost
local _, cars_data = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/KNOWN_BOOSTED_CARS.json")

local function boostVehicle(vehicle_data, vehicle, boost, category)
    if boost then
        --boost mode
        accel = vehicle_data[1] * (17 * (playerlistSettings.defaultBoostStrength / 100))
        brake_force = vehicle_data[2] * (23 * (playerlistSettings.defaultBoostStrength / 100))
        gravity = 22.420
        handbrake_force = vehicle_data[4] * (14 * (playerlistSettings.defaultBoostStrength / 100))
        initial_drive_force = vehicle_data[5] * (690 * (playerlistSettings.defaultBoostStrength / 100))   --nice
        traction_min = 6.5 + (2 * (math.min(playerlistSettings.defaultBoostStrength, 420) / 100))   --very high traction. If used without roll_centre modification, the car will constantly flip
        traction_max = vehicle_data[7] + (2 * (math.min(playerlistSettings.defaultBoostStrength, 420) / 100))
        traction_bias_front = 0.420
        up_shift = 10000  --huge shift values, causing cars to get stuck in gear and accelerate rapidly
        down_shift = 10000
        max_flat_vel = 100000
        collision_dmg_multiplier = 0
        engine_dmg_multiplier = 0
        local tempStrength = playerlistSettings.defaultBoostStrength
        if tempStrength >= 100 then
            --Dont increase the following roll_centre variables more than 100%. Makes things flip.
            tempStrength = 100
        end
        if category == "Super" or category == "OpenWheel" or category == "Motorcycle" or category == "Sport" or category == "Cycle" then
            roll_centre_front = vehicle_data[14] + (0.18 * (tempStrength / 100)) --these two stop the car from rolling even at high speeds, it rolls inwards instead
            roll_centre_rear = vehicle_data[15] + (0.18 * (tempStrength / 100))
        elseif category == "Off-Road" or category == "Van" then
            roll_centre_front = vehicle_data[14] + (0.36 * (tempStrength / 100))
            roll_centre_rear = vehicle_data[15] + (0.36 * (tempStrength / 100))
        elseif category == "Industrial" or category == "Commercials" then
            roll_centre_front = vehicle_data[14] + (0.45 * (tempStrength / 100))
            roll_centre_rear = vehicle_data[15] + (0.45 * (tempStrength / 100))
        else
            roll_centre_front = vehicle_data[14] + (0.3 * (tempStrength / 100))
            roll_centre_rear = vehicle_data[15] + (0.3 * (tempStrength / 100))
        end
        drive_bias = 0.5   --all wheel drive
        traction_loss_multiplier = 1
        initial_drag_coefficient = 1  --no drag forces
        number_plate_text = "BOOSTEDD"
        drive_inertia = 42.0  --max change rate cap for the rpm of the engine
        if category ~= "Motorcycle" then
            steering_lock = vehicle_data[21] + (0.19 * tempStrength)  --more steering
        else
            steering_lock = vehicle_data[21] + (0.05 * tempStrength)
        end
    else
        --restore mode
        accel = vehicle_data[1]
        brake_force = vehicle_data[2]
        gravity = vehicle_data[3]
        handbrake_force = vehicle_data[4]
        initial_drive_force = vehicle_data[5]
        traction_min = vehicle_data[6]
        traction_max = vehicle_data[7]
        traction_bias_front = vehicle_data[8]
        up_shift = vehicle_data[9]
        down_shift = vehicle_data[10]
        max_flat_vel = vehicle_data[11]
        collision_dmg_multiplier = vehicle_data[12]
        engine_dmg_multiplier = vehicle_data[13]
        roll_centre_front = vehicle_data[14]
        roll_centre_rear = vehicle_data[15]
        drive_bias = vehicle_data[16]
        traction_loss_multiplier = vehicle_data[17]
        initial_drag_coefficient = vehicle_data[18]
        number_plate_text = vehicle_data[19]
        drive_inertia = vehicle_data[20]
        steering_lock = vehicle_data[21]
    end

    vehicle:set_acceleration(accel)
    vehicle:set_brake_force(brake_force)
    vehicle:set_gravity(gravity)
    vehicle:set_handbrake_force(handbrake_force)
    vehicle:set_initial_drive_force(initial_drive_force)
    vehicle:set_traction_curve_min(traction_min)
    vehicle:set_traction_curve_max(traction_max)
    vehicle:set_traction_bias_front(traction_bias_front)
    vehicle:set_up_shift(up_shift)
    vehicle:set_down_shift(down_shift)
    vehicle:set_initial_drive_max_flat_velocity(max_flat_vel)
    vehicle:set_roll_centre_height_front(roll_centre_front)
    vehicle:set_roll_centre_height_rear(roll_centre_rear)
    vehicle:set_drive_bias_front(drive_bias)
    vehicle:set_collision_damage_multiplier(collision_dmg_multiplier)
    vehicle:set_engine_damage_multiplier(engine_dmg_multiplier)
    vehicle:set_traction_loss_multiplier(traction_loss_multiplier)
    vehicle:set_initial_drag_coeff(initial_drag_coefficient)
    vehicle:set_max_speed(100000)
    vehicle:set_number_plate_text(number_plate_text)
    vehicle:set_drive_inertia(drive_inertia)
    vehicle:set_steering_lock(steering_lock)
end

local function reloadVehicle(vehicle)
    if not vehicle then
        return
    end
    --Check if car has been found in the table, then restore, otherwise exit
    local restoreData = cars_data[tostring(vehicle:get_model_hash())]
    if restoreData then
        boostVehicle(restoreData, vehicle, false)
    end
    displayHudBanner("DRONE_BOOST", "PIM_NCL_PRIV0", "", 108)
end

--------------------------------
--boosted car handling logic, insert key
--------------------------------
local function carBoost()
    if localplayer and localplayer:is_in_vehicle() then
        local current = localplayer:get_current_vehicle()
        if current == nil then
            return
        end

        --check if car has been modified already by the modified gravity value, if not, try to save and modify it
        if current:get_gravity() ~= 22.420 then
            :: retry ::
            --Save car data to map if its not in there already
            if not cars_data[tostring(current:get_model_hash())] then
                cars_data[tostring(current:get_model_hash())] = {
                    current:get_acceleration(), --1
                    current:get_brake_force(), --2
                    current:get_gravity(), --3
                    current:get_handbrake_force(), --4
                    current:get_initial_drive_force(), --5
                    current:get_traction_curve_min(), --6
                    current:get_traction_curve_max(), --7
                    current:get_traction_bias_front(), --8
                    current:get_up_shift(), --9
                    current:get_down_shift(), --10
                    current:get_initial_drive_max_flat_velocity(), --11
                    current:get_collision_damage_multiplier(), --12
                    current:get_engine_damage_multiplier(), --13
                    current:get_roll_centre_height_front(), --14
                    current:get_roll_centre_height_rear(), --15
                    current:get_drive_bias_front(), --16
                    current:get_traction_loss_multiplier(), --17
                    current:get_initial_drag_coeff(), --18
                    current:get_number_plate_text(),       --19
                    current:get_drive_inertia(),            --20
                    current:get_steering_lock()             --21
                }
                json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/KNOWN_BOOSTED_CARS.json", cars_data)
            end

            --boost car if data has been read successfully
            boostVehicle(cars_data[tostring(current:get_model_hash())], current, true, VEHICLE[current:get_model_hash()][2])
            displayHudBanner("DRONE_BOOST", "FM_ISC_RAT1", playerlistSettings.defaultBoostStrength, 108)
        else
            reloadVehicle(current)
        end
    end
end

local carBoostHotkey
menu.register_callback('ToggleCarBoostHotkey', function()
    if not carBoostHotkey then
        carBoostHotkey = menu.register_hotkey(find_keycode("ToggleCarBoostHotkey"), carBoost)
    else
        menu.remove_hotkey(carBoostHotkey)
        carBoostHotkey = nil
    end
end)

greyText(vehicleOptionsSub, centeredText("----- One-Click-Go-Quick Booster -----"))
vehicleOptionsSub:add_toggle("ULTIMATE BOOST", function()
    return localplayer and localplayer:is_in_vehicle() and localplayer:get_current_vehicle():get_gravity() == 22.420
end, carBoost)
vehicleOptionsSub:add_int_range("Car Boost strength |%", 5, 0, 690, function()
    return playerlistSettings.defaultBoostStrength
end, function(value)
    playerlistSettings.defaultBoostStrength = value
    json.savefile("scripts/quads_toolbox_scripts/toolbox_data/SAVEDATA/PLAYERLIST_SETTINGS.json", playerlistSettings)
end)
vehicleOptionsSub:add_action("Reset all boosted cars", function()
    for veh in replayinterface.get_vehicles() do
        if veh:get_gravity() == 22.420 and cars_data[tostring(veh:get_model_hash())] then
            reloadVehicle(veh)
        end
    end
end, function() return tableCount(cars_data) > 0 end)

greyText(vehicleOptionsSub, centeredText("----- Vehicle Actions -----"))

--------------------------------
--car jump, numpad comma (Script by Quad_Plex)
--------------------------------
local blocked = false
local function carJump(strength)
    if not blocked then
        if not strength then strength = -69 end
        blocked = true
        if localplayer ~= nil and localplayer:is_in_vehicle() then
            local vehicle = localplayer:get_current_vehicle()
            local oldGrav = vehicle:get_gravity()
            local oldTracMin = vehicle:get_traction_curve_min()
            local oldTracMax = vehicle:get_traction_curve_max()
            vehicle:set_traction_curve_min(0)
            vehicle:set_traction_curve_max(0)
            vehicle:set_gravity(strength)
            sleep(0.12)
            vehicle:set_gravity(oldGrav)
            vehicle:set_traction_curve_min(oldTracMin)
            vehicle:set_traction_curve_max(oldTracMax)
        end
        blocked = false
    end
end

local carJumpHotkey
menu.register_callback('ToggleCarjumpHotkey', function()
    if not carJumpHotkey then
        carJumpHotkey = menu.register_hotkey(find_keycode("ToggleCarjumpHotkey"), carJump)
    else
        menu.remove_hotkey(carJumpHotkey)
        carJumpHotkey = nil
    end
end)
vehicleOptionsSub:add_action("Quick Vehicle Jump", carJump, function() return localplayer and localplayer:is_in_vehicle() end)

--------------------------------
--massive car, F12 key
--------------------------------
local function makeCarMassive()
    if localplayer ~= nil and localplayer:is_in_vehicle() then
        local vehicle = localplayer:get_current_vehicle()
        if vehicle then
            vehicle:set_mass(26969)
            displayHudBanner("FACE_F_FAT", "FMSTP_PRCL3", 69, 108)
        end
    end
end

local massiveCarHotkey
menu.register_callback('ToggleMassiveCarHotkey', function()
    if not massiveCarHotkey then
        massiveCarHotkey = menu.register_hotkey(find_keycode("ToggleMassiveCarHotkey"), makeCarMassive)
    else
        menu.remove_hotkey(massiveCarHotkey)
        massiveCarHotkey = nil
    end
end)
vehicleOptionsSub:add_action("Set Car Mass to 26969", makeCarMassive, function() return localplayer and localplayer:is_in_vehicle() end)

--------------------------------
--Drift Tyres
--------------------------------
vehicleOptionsSub:add_toggle("Enable Drift Tyres", function() return localplayer:is_in_vehicle() and localplayer:get_current_vehicle():get_drift_tyres_enabled() end, function()
    if localplayer:is_in_vehicle() then
        localplayer:get_current_vehicle():set_drift_tyres_enabled(not localplayer:get_current_vehicle():get_drift_tyres_enabled())
    end
end)


--------------------------------
--Car beyblade
--------------------------------
beybladeEnabled = false
local beybladeRunning = false
local beybladeModes = {[0]="Hover", "Drop Down"}
local beybladeModeSelection = 0
local function carBeyblade()
    if not localplayer:is_in_vehicle() or beybladeRunning or not beybladeEnabled then return end
    beybladeRunning = true
    local checkHeight = localplayer:get_current_vehicle():get_position().z + 1.2
    local additionalGrav
    local heightDifference
    local oldGrav = localplayer:get_current_vehicle():get_gravity()
    localplayer:get_current_vehicle():set_gravity(9.8)
    menu.send_key_down(keycodes.W_KEY)
    menu.send_key_down(keycodes.S_KEY)
    menu.send_key_down(keycodes.A_KEY)
    carJump(-45)
    sleep(0.8)
    while beybladeEnabled do
        if not localplayer:is_in_vehicle() then goto stop end
        heightDifference = localplayer:get_current_vehicle():get_position().z - checkHeight
        if beybladeModes[beybladeModeSelection] == "Hover" then
            localplayer:get_current_vehicle():set_gravity(9.8)
            additionalGrav = localplayer:get_velocity().z * 7
            menu.send_key_down(keycodes.W_KEY)
            menu.send_key_down(keycodes.S_KEY)
            menu.send_key_down(keycodes.A_KEY)
            carJump(-25 + additionalGrav + heightDifference * 1.5)
        else
            local plyVelocity = localplayer:get_velocity().z
            localplayer:get_current_vehicle():set_gravity(35)
            if plyVelocity > 0 then
                additionalGrav = plyVelocity * 7
            else
                additionalGrav = plyVelocity * 3
            end
            if heightDifference < 0 then heightDifference = 0 end
            menu.send_key_down(keycodes.W_KEY)
            menu.send_key_down(keycodes.S_KEY)
            menu.send_key_down(keycodes.A_KEY)
            carJump(-55 + additionalGrav + heightDifference * 1.5)
        end
        sleep(0.3)
    end
    ::stop::
    menu.send_key_up(keycodes.W_KEY)
    menu.send_key_up(keycodes.S_KEY)
    menu.send_key_up(keycodes.A_KEY)
    menu.send_key_up(keycodes.D_KEY)
    if localplayer:is_in_vehicle() then
        localplayer:get_current_vehicle():set_gravity(oldGrav)
    end
    beybladeRunning = false
    beybladeEnabled = false
end
menu.register_callback('startBeyblade', carBeyblade)

vehicleOptionsSub:add_toggle("|Beyblade: LET IT RIP!  ", function() return beybladeEnabled end, function(value)
    if not localplayer:is_in_vehicle() then return end
    beybladeEnabled = value
    if not beybladeRunning and beybladeEnabled then
        menu.emit_event('startBeyblade')
    end
end)
vehicleOptionsSub:add_array_item("|Beyblade Type: ", beybladeModes, function() return beybladeModeSelection end, function(value)
    beybladeModeSelection = value
end)