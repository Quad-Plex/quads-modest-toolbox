--Report Stats
greyText(miscOptionsSub, "-------- Reports Stats --------")
local ReportsStats_submenu= miscOptionsSub:add_submenu("Reports Stats")
ReportsStats_submenu:add_action("[These Stats are READ ONLY]", function() end)
ReportsStats_submenu:add_int_range("Griefing Reports", 0, 0, MAX_INT, function() return stats.get_int("MPPLY_GRIEFING") end, null)
ReportsStats_submenu:add_int_range("Exploits",0,0,MAX_INT,function()if localplayer then return stats.get_int("MPPLY_EXPLOITS")end end, function() end)
ReportsStats_submenu:add_int_range("Game Exploits", 0, 0, MAX_INT, function() return stats.get_int("MPPLY_GAME_EXPLOITS") end, null)
ReportsStats_submenu:add_int_range("Text Chat:Annoying Me",0,0,MAX_INT,function()if localplayer then return stats.get_int("MPPLY_TC_ANNOYINGME")end end, function() end)
ReportsStats_submenu:add_int_range("Voice Chat: Annoying", 0, 0, MAX_INT, function() return stats.get_int("MPPLY_VC_ANNOYINGME") end, null)
ReportsStats_submenu:add_int_range("Voice Chat: Hate Speech", 0, 0, MAX_INT, function() return stats.get_int("MPPLY_VC_HATE") end, null)
ReportsStats_submenu:add_int_range("Offensive Language", 0, 0, MAX_INT, function() return stats.get_int("MPPLY_OFFENSIVE_LANGUAGE") end, null)
ReportsStats_submenu:add_int_range("Offensive Tagplate", 0, 0, MAX_INT, function() return stats.get_int("MPPLY_OFFENSIVE_TAGPLATE") end, null)
ReportsStats_submenu:add_int_range("Offensive Content", 0, 0, MAX_INT, function() return stats.get_int("MPPLY_OFFENSIVE_UGC") end, null)
ReportsStats_submenu:add_int_range("Offensive Crew Name", 0, 0, MAX_INT, function() return stats.get_int("MPPLY_BAD_CREW_NAME") end, null)
ReportsStats_submenu:add_int_range("Offensive Crew Motto", 0, 0, MAX_INT, function() return stats.get_int("MPPLY_BAD_CREW_MOTTO") end, null)
ReportsStats_submenu:add_int_range("Offensive Crew Status", 0, 0, MAX_INT, function() return stats.get_int("MPPLY_BAD_CREW_STATUS") end, null)
ReportsStats_submenu:add_int_range("Offensive Crew Emblem", 0, 0, MAX_INT, function() return stats.get_int("MPPLY_BAD_CREW_EMBLEM") end, null)
ReportsStats_submenu:add_int_range("Friendly Commends", 0, 0, MAX_INT, function() return stats.get_int("MPPLY_FRIENDLY") end, null)
ReportsStats_submenu:add_int_range("Helpful Commends", 0, 0, MAX_INT, function() return stats.get_int("MPPLY_HELPFUL") end, null)
ReportsStats_submenu:add_bare_item("", function() return stats.get_bool("MPPLY_IS_CHEATER") and "Marked As Cheater?|True" or "Marked As Cheater?|False" end, null, null, null)
ReportsStats_submenu:add_bare_item("", function() return stats.get_bool("MPPLY_WAS_I_BAD_SPORT") and "Marked As Bad Sport?|True" or "Marked As Bad Sport?|False" end, null, null, null)
ReportsStats_submenu:add_bare_item("", function() return stats.get_bool("MPPLY_IS_HIGH_EARNER") and "Marked as High Earner?|True" or "Marked as High Earner?|False" end, null, null, null)