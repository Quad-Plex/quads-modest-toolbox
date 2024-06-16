local function getCurrentWeaponName()
    if localplayer and localplayer:get_current_weapon() then
        return WEAPON[localplayer:get_current_weapon():get_name_hash()] or "hash: " .. weaponHash
    end
    return "No Weapon"
end

gunOptionsSub:add_bare_item("", function() return "=== Current Weapon: " .. getCurrentWeaponName() .. " ===" end, null, null, null)
gunOptionsSub:add_float_range("Bullet DMG", 10, 0, 10000, function() return localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_bullet_damage() or 0 end,
        function(value)
            if localplayer and localplayer:get_current_weapon() then
                localplayer:get_current_weapon():set_bullet_damage(value)
            end
        end)
gunOptionsSub:add_int_range("Bullets in Batch", 1, 0, 100, function() return localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_bullets_in_batch() or 0 end,
        function(value)
            if localplayer and localplayer:get_current_weapon() then
                localplayer:get_current_weapon():set_bullets_in_batch(value)
            end
        end)
gunOptionsSub:add_float_range("Push Force (Ped/Veh/Heli)", 1000, 0, 1000000, function() return localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_ped_force() or 0 end,
        function(value)
            if localplayer and localplayer:get_current_weapon() then
                localplayer:get_current_weapon():set_heli_force(value)
                localplayer:get_current_weapon():set_ped_force(value)
                localplayer:get_current_weapon():set_vehicle_force(value)
            end
        end)
gunOptionsSub:add_float_range("Range", 100, 0, 1000000, function() return localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_range() or 0 end,
        function(value)
            if localplayer and localplayer:get_current_weapon() then
                localplayer:get_current_weapon():set_range(value)
            end
        end)
gunOptionsSub:add_float_range("Lock On Range", 100, 0, 1000000, function() return localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_lock_on_range() or 0 end,
        function(value)
            if localplayer and localplayer:get_current_weapon() then
                localplayer:get_current_weapon():set_lock_on_range(value)
            end
        end)
gunOptionsSub:add_float_range("Time between Shots", 0.1, 0, 1000, function() return localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_time_between_shots() or 0 end,
        function(value)
            if localplayer and localplayer:get_current_weapon() then
                localplayer:get_current_weapon():set_time_between_shots(value)
            end
        end)
gunOptionsSub:add_float_range("Reload Time Multiplier", 0.1, 0, 1000, function() return localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_reload_time_multiplier() or 0 end,
        function(value)
            if localplayer and localplayer:get_current_weapon() then
                localplayer:get_current_weapon():set_reload_time_multiplier(value)
            end
        end)
gunOptionsSub:add_float_range("Speed", 100, 0, 10000, function() return localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_speed() or 0 end,
        function(value)
            if localplayer and localplayer:get_current_weapon() then
                localplayer:get_current_weapon():set_speed(value)
            end
        end)
gunOptionsSub:add_float_range("Spread", 0.5, 0, 1000, function() return localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_spread() or 0 end,
        function(value)
            if localplayer and localplayer:get_current_weapon() then
                localplayer:get_current_weapon():set_spread(value)
            end
        end)