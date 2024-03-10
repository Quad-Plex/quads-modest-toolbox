local function OnWeaponChanged(_, newWeapon)
    if newWeapon ~= nil then
        local NAME = localplayer:get_current_weapon():get_name_hash()
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
    local weapon = localplayer:get_current_weapon()
    if weapon then
        --save old values
        local weapon_hash = weapon:get_name_hash()
        original_weapon_stats[weapon_hash] = {
            explosion_type = weapon:get_explosion_type(),
            damage_type = weapon:get_damage_type(),
            range = weapon:get_range(),
            bullet_damage = weapon:get_bullet_damage()
        }
        --set new values
        weapon:set_explosion_type(new_explosion_type)
        weapon:set_damage_type(new_damage_type)
        weapon:set_range(new_range)
        weapon:set_bullet_damage(new_damage)
    end
end

local function ResetWeaponStats()
    local weapon = localplayer:get_current_weapon()
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
        displayHudBanner(banner_message, "PIM_NCL_PRIV1", "", 109)
    else
        ResetWeaponStats()
        displayHudBanner(banner_message, "PIM_NCL_PRIV0", "", 109)
    end
end

local atomizerToggle = false
local function toggleAtomizerGun()
    atomizerToggle = not (localplayer:get_current_weapon():get_explosion_type() == 70)
    ToggleWeaponStats(atomizerToggle, 70, 5, 9999, 0, "UNLOCK_RAYGUN")
end

gunOptionsSub:add_toggle("Constant Atomizer", function()
    return localplayer:get_current_weapon():get_explosion_type() == 70
end, function(_)
    toggleAtomizerGun()
end)

--Right Shift
local atomizerGunHotkey
menu.register_callback('ToggleAtomizerHotkey', function()
    if not atomizerGunHotkey then
        atomizerGunHotkey = menu.register_hotkey(keycodes.RIGHT_SHIFT_KEY, toggleAtomizerGun)
    else
        menu.remove_hotkey(atomizerGunHotkey)
        atomizerGunHotkey = nil
    end
end)

local explosionToggle = false
local function toggleExplosionGun()
    explosionToggle = not (localplayer:get_current_weapon():get_explosion_type() == 31)
    ToggleWeaponStats(explosionToggle, 31, 5, 9999, 1000, "VEUI_SHAKE_EXPLOSION")
end

gunOptionsSub:add_toggle("Explosion Gun", function()
    return localplayer:get_current_weapon():get_explosion_type() == 31
end, function(_)
    toggleExplosionGun()
end)

--Right Ctrl
local explosionGunHotkey
menu.register_callback('ToggleExplosionGunHotkey', function()
    if not explosionGunHotkey then
        explosionGunHotkey = menu.register_hotkey(keycodes.RIGHT_CONTROL_KEY, toggleExplosionGun)
    else
        menu.remove_hotkey(explosionGunHotkey)
        explosionGunHotkey = nil
    end
end)

local fireToggle = false
local function toggleFireGun()
    fireToggle = not (localplayer:get_current_weapon():get_explosion_type() == 12)
    ToggleWeaponStats(fireToggle, 12, 5, 9999, 1, "VEUI_SHAKE_EXPLOSION")
end
gunOptionsSub:add_toggle("Fire Gun", function()
    return localplayer:get_current_weapon():get_explosion_type() == 12
end, function(_)
    toggleFireGun()
end)

local waterToggle = false
local function toggleWaterGun()
    waterToggle = not (localplayer:get_current_weapon():get_explosion_type() == 13)
    ToggleWeaponStats(waterToggle, 13, 5, 9999, 0, "VEUI_SHAKE_EXPLOSION")
end
gunOptionsSub:add_toggle("Water Gun", function()
    return localplayer:get_current_weapon():get_explosion_type() == 13
end, function(_)
    toggleWaterGun()
end)

local smokeToggle = false
local function toggleSmokeGun()
    smokeToggle = not (localplayer:get_current_weapon():get_explosion_type() == 20)
    ToggleWeaponStats(smokeToggle, 20, 5, 9999, 0, "VEUI_SHAKE_EXPLOSION")
end
gunOptionsSub:add_toggle("Smoke Gun", function()
    return localplayer:get_current_weapon():get_explosion_type() == 20
end, function(_)
    toggleSmokeGun()
end)