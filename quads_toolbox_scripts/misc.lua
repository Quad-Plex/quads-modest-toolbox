--displayboxtype = 39
--menu.add_int_range("Display Box Type Tester", 1, -100, 500, function()
--	return displayboxtype
--end, function(n)
--	displayboxtype = n
--	displayHudBanner("EPS_CASH", "~s~", 0, n, true)
--end)

--------------------------------
--Nightclub Popularity
--------------------------------

function mpx() return "MP" .. stats.get_int("MPPLY_LAST_MP_CHAR") .. "_" end --Returns 0 or 1

miscOptionsSub:add_action("Make Nightclub Popular", function()
	stats.set_int(mpx() .. "CLUB_POPULARITY", 1000)
	displayHudBanner("BB_BM_PC_SUCC_S", "", "", 109)
end)

--------------------------------
--Snack refill
--------------------------------

local function refillInventory()
	stats.set_int(mpx().."NO_BOUGHT_YUM_SNACKS", 30)
	stats.set_int(mpx().."NO_BOUGHT_HEALTH_SNACKS", 15)
	stats.set_int(mpx().."NO_BOUGHT_EPIC_SNACKS", 5)
	stats.set_int(mpx().."NUMBER_OF_ORANGE_BOUGHT", 10)
	stats.set_int(mpx().."NUMBER_OF_BOURGE_BOUGHT", 10)
	stats.set_int(mpx().."NUMBER_OF_CHAMP_BOUGHT", 5)
	stats.set_int(mpx().."CIGARETTES_BOUGHT", 20)
	stats.set_int(mpx().."MP_CHAR_ARMOUR_1_COUNT", 10)
	stats.set_int(mpx().."MP_CHAR_ARMOUR_2_COUNT", 10)
	stats.set_int(mpx().."MP_CHAR_ARMOUR_3_COUNT", 10)
	stats.set_int(mpx().."MP_CHAR_ARMOUR_4_COUNT", 10)
	stats.set_int(mpx().."MP_CHAR_ARMOUR_5_COUNT", 10)
	displayHudBanner("PIM_TINVE", "CC_BLUSH_0", "", 109)
end

miscOptionsSub:add_action("Refill Inventory", function()
	refillInventory()
end)

----------------------Respawn State changer----------------------
local stateToSet = 6
miscOptionsSub:add_int_range("Trigger Respawn (Unstuck):", 1, -10, 10, function() return stateToSet end, function(n)
	stateToSet = n
	for i = 0, 31 do
		local ply = player.get_player_ped(i)
		if ply == localplayer then
			globalLocalplayerID = i
		end
	end
	setPlayerRespawnState(globalLocalplayerID, n)
end)