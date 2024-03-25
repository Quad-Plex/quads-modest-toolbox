---------------------------------------------------------------------------
--Janky Speedometer implementation using HUD messages
---------------------------------------------------------------------------

local speedDisplayEnabled = false
function speedDisplay()
    while true do
        if speedDisplayEnabled then
            local myPlayer = player.get_player_ped()
            local current_vehicle = myPlayer:get_current_vehicle()
            if current_vehicle == nil or not myPlayer:is_in_vehicle() then
                return
            end
            local velocity = current_vehicle:get_velocity()
            local abs_velocity = math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y + velocity.z * velocity.z)
            if speedDisplayEnabled then
                displayHudBanner("FM_AE_SORT_3", "AMCH_KMHN", math.floor(3.6 * abs_velocity), 109, true)
            end
        end
        sleep(0.1)
    end
end
menu.register_callback('speedDisplay', speedDisplay)
vehicleOptionsSub:add_toggle("Toggle Speed Display", function()
    return speedDisplayEnabled
end, function(toggle)
    speedDisplayEnabled = toggle
    menu.emit_event("speedDisplay")
end)

--------------------------------
--Open all car doors
--------------------------------
local openTypes = { [0]="Unlock All", "Lock All"}
local openType = 0
vehicleOptionsSub:add_array_item("Car Doors State:", openTypes, function() return openType end, function(value)
    openType = value
    for veh in replayinterface.get_vehicles() do
        if openTypes[openType] == "Unlock All" then
            veh:set_door_lock_state(1)
        else
            veh:set_door_lock_state(2)
        end
    end
end)

vehicleOptionsSub:add_toggle("Alternative Veh. Spawner", function() return alternative_spawn_toggle end, function(_) toggleAlternativeSpawner() end)

--------------------------------
--functions for carboost
local _, cars_data = pcall(json.loadfile, "scripts/quads_toolbox_scripts/toolbox_data/KNOWN_BOOSTED_CARS.json")

local multiplier_percent = 70
local function boostVehicle(vehicle_data, vehicle, boost)
    if boost then
        --boost mode
        accel = vehicle_data[1] * (17 * (multiplier_percent / 100))
        brake_force = vehicle_data[2] * (23 * (multiplier_percent / 100))
        gravity = 21.420
        handbrake_force = vehicle_data[4] * (14 * (multiplier_percent / 100))
        initial_drive_force = vehicle_data[5] * (690 * (multiplier_percent / 100))   --nice
        traction_min = 6 + (2 * (multiplier_percent / 100))   --very high traction. Used without roll_centre modification, the car will constantly flip
        traction_max = vehicle_data[7] + (2 * (multiplier_percent / 100))
        traction_bias_front = 0.420
        up_shift = 10000  --huge shift values, causing cars to get stuck in gear and accelerate rapidly
        down_shift = 10000
        max_flat_vel = 10000
        collision_dmg_multiplier = 0
        engine_dmg_multiplier = 0
        if multiplier_percent >= 100 then
            --Dont increase the following roll_centre variables more than 100%. Makes things flip.
            multiplier_percent = 100
        end
        roll_centre_front = vehicle_data[14] + (0.300 * (multiplier_percent / 100)) --these two stop the car from rolling even at high speeds, it rolls inwards instead
        roll_centre_rear = vehicle_data[15] + (0.300 * (multiplier_percent / 100))
        drive_bias = 0.5   --all wheel drive
        traction_loss_multiplier = 1
        initial_drag_coefficient = 1  --no drag forces
        number_plate_text = "BOOSTEDD"
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
    vehicle:set_max_speed(10000)
    vehicle:set_number_plate_text(number_plate_text)
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
    displayHudBanner("DRONE_BOOST", "PIM_NCL_PRIV0", "", 109)
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
        if current:get_gravity() ~= 21.420 then
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
                    current:get_number_plate_text()       --19
                }
                json.savefile("scripts/quads_toolbox_scripts/toolbox_data/KNOWN_BOOSTED_CARS.json", cars_data)
            end

            --boost car if data has been read successfully
            boostVehicle(cars_data[tostring(current:get_model_hash())], current, true)
            displayHudBanner("DRONE_BOOST", "FM_ISC_RAT1", multiplier_percent, 109)
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
    return localplayer:is_in_vehicle() and localplayer:get_current_vehicle():get_gravity() == 21.420
end, carBoost)
vehicleOptionsSub:add_int_range("Car Boost strength |%", 5, 0, 690, function()
    return multiplier_percent
end, function(value)
    multiplier_percent = value
end)
vehicleOptionsSub:add_action("Reset all modified handling data", function()
    for veh in replayinterface.get_vehicles() do
        if veh:get_gravity() == 21.420 and cars_data[tostring(veh:get_model_hash())] then
            reloadVehicle(veh)
        end
    end
end, function() return tableCount(cars_data) > 0 end)

greyText(vehicleOptionsSub, centeredText("----- Vehicle Tools -----"))

--------------------------------
--car jump, numpad comma (Script by Quad_Plex)
--------------------------------
local blocked = false
local function carJump()
    if not blocked then
        blocked = true
        if localplayer ~= nil and localplayer:is_in_vehicle() then
            local vehicle = localplayer:get_current_vehicle()
            local oldGrav = vehicle:get_gravity()
            local oldTracMin = vehicle:get_traction_curve_min()
            local oldTracMax = vehicle:get_traction_curve_max()
            vehicle:set_traction_curve_min(0)
            vehicle:set_traction_curve_max(0)
            vehicle:set_gravity(-60)
            sleep(0.1)
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
            displayHudBanner("FACE_F_FAT", "FMSTP_PRCL3", 69, 109)
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