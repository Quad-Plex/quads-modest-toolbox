local function OnWeaponChanged(_, newWeapon)
    if newWeapon ~= nil then
        local NAME = localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_name_hash()
        if NAME == joaat("weapon_stungun_mp") or NAME == joaat("weapon_stungun") then
            newWeapon:set_time_between_shots(1)
            newWeapon:set_range(1000)
        elseif NAME == joaat("weapon_raypistol") then
            newWeapon:set_time_between_shots(0.5)
            newWeapon:set_range(1200)
        end
    end
end
menu.register_callback('OnWeaponChanged', OnWeaponChanged)

local original_weapon_stats = {}
local function ChangeWeaponStats(new_explosion_type, new_damage_type, new_range, new_damage)
    local weapon = localplayer and  localplayer:get_current_weapon()
    if weapon then
        if not original_weapon_stats[weapon:get_name_hash()] then
            --save old values
            original_weapon_stats[weapon:get_name_hash()] = {
                explosion_type = weapon:get_explosion_type(),
                damage_type = weapon:get_damage_type(),
                range = weapon:get_range(),
                bullet_damage = weapon:get_bullet_damage()
            }
        end
        --set new values
        weapon:set_explosion_type(new_explosion_type)
        weapon:set_damage_type(new_damage_type)
        weapon:set_range(new_range)
        weapon:set_bullet_damage(new_damage)
    end
end

local function ResetWeaponStats()
    local weapon = localplayer and localplayer:get_current_weapon()
    if weapon then
        local weapon_hash = weapon:get_name_hash()
        if original_weapon_stats[weapon_hash] then
            weapon:set_explosion_type(original_weapon_stats[weapon_hash].explosion_type)
            weapon:set_damage_type(original_weapon_stats[weapon_hash].damage_type)
            weapon:set_range(original_weapon_stats[weapon_hash].range)
            weapon:set_bullet_damage(original_weapon_stats[weapon_hash].bullet_damage)
        end
    end
end

local function ToggleWeaponStats(toggle, new_expl_type, new_damage_type, new_range, new_damage, banner_message)
    if toggle then
        ChangeWeaponStats(new_expl_type, new_damage_type, new_range, new_damage)
        displayHudBanner(banner_message, "PIM_NCL_PRIV1", "", 108)
    else
        ResetWeaponStats()
        displayHudBanner(banner_message, "PIM_NCL_PRIV0", "", 108)
    end
end

local atomizerToggle = false
local function toggleAtomizerGun()
    atomizerToggle = not (localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_explosion_type() == ExplosionTypes.RAYGUN)
    ToggleWeaponStats(atomizerToggle, ExplosionTypes.RAYGUN, 5, 9999, 0, "UNLOCK_RAYGUN")
end

gunOptionsSub:add_toggle("Constant Atomizer", function()
    return localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_explosion_type() == ExplosionTypes.RAYGUN
end, function(_)
    toggleAtomizerGun()
end)

--Right Shift
local atomizerGunHotkey
menu.register_callback('ToggleAtomizerHotkey', function()
    if not atomizerGunHotkey then
        atomizerGunHotkey = menu.register_hotkey(find_keycode("ToggleAtomizerHotkey"), toggleAtomizerGun)
    else
        menu.remove_hotkey(atomizerGunHotkey)
        atomizerGunHotkey = nil
    end
end)

local explosionToggle = false
local function toggleExplosionGun()
    explosionToggle = not (localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_explosion_type() == ExplosionTypes.TANKER)
    ToggleWeaponStats(explosionToggle, ExplosionTypes.TANKER, 5, 9999, 1000, "VEUI_SHAKE_EXPLOSION")
end

gunOptionsSub:add_toggle("Explosion Gun", function()
    return localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_explosion_type() == ExplosionTypes.TANKER
end, function(_)
    toggleExplosionGun()
end)

--Right Ctrl
local explosionGunHotkey
menu.register_callback('ToggleExplosionGunHotkey', function()
    if not explosionGunHotkey then
        explosionGunHotkey = menu.register_hotkey(find_keycode("ToggleExplosionGunHotkey"), toggleExplosionGun)
    else
        menu.remove_hotkey(explosionGunHotkey)
        explosionGunHotkey = nil
    end
end)

local fireToggle = false
local function toggleFireGun()
    fireToggle = not (localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_explosion_type() == ExplosionTypes.FLAME)
    ToggleWeaponStats(fireToggle, ExplosionTypes.FLAME, 5, 9999, 1, "MO_ADB_OFF")
end
gunOptionsSub:add_toggle("Fire Gun", function()
    return localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_explosion_type() == ExplosionTypes.FLAME
end, function(_)
    toggleFireGun()
end)

local waterToggle = false
local function toggleWaterGun()
    waterToggle = not (localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_explosion_type() == ExplosionTypes.WATER_HYDRANT)
    ToggleWeaponStats(waterToggle, ExplosionTypes.WATER_HYDRANT, 5, 9999, 0, "PIM_LGHTCOL6")
end
gunOptionsSub:add_toggle("Water Gun", function()
    return localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_explosion_type() == ExplosionTypes.WATER_HYDRANT
end, function(_)
    toggleWaterGun()
end)

local smokeToggle = false
local function toggleSmokeGun()
    smokeToggle = not (localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_explosion_type() == ExplosionTypes.SMOKEGRENADE)
    ToggleWeaponStats(smokeToggle, ExplosionTypes.SMOKEGRENADE, 5, 9999, 0, "CMOD_SMOKE_N")
end
gunOptionsSub:add_toggle("Smoke Gun", function()
    return localplayer and localplayer:get_current_weapon() and localplayer:get_current_weapon():get_explosion_type() == ExplosionTypes.SMOKEGRENADE
end, function(_)
    toggleSmokeGun()
end)