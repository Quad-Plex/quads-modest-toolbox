--Report Stats
greyText(miscOptionsSub, "-------- Reports Stats --------")
local ReportsStats_submenu= miscOptionsSub:add_submenu("Reports Stats")
greyText(ReportsStats_submenu, "[These Stats are READ ONLY]")
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


--Unused loop for checking stat changes in the background
--local lastStatIncreased
--greyText(ReportsStats_submenu, "!!!!!!!!!!!!!!!!!!!!!!!!!")
--ReportsStats_submenu:add_bare_item("", function() return lastStatIncreased == nil and "Last report received: |none" or "Last report received: |" .. lastStatIncreased  end, null, null, null)
--local numGriefings
--local numExploits
--local numGameExploits
--local numAnnoyingMe
--local numHateSpeech
--local numOffensiveLanguage
--local numOffensiveTagplate
--local numOffensiveContent
--local numBadCrewName
--local numBadCrewMotto
--local numBadCrewStatus
--local numBadCrewEmblem
--local numFriendly
--local numHelpful
--local markedAsCheater
--local markedBadSport
--local markedHighEarner
--statsInitialized = false
--function initializeStats()
--    if getPlayerRespawnState(getLocalplayerID()) == 99 then --Only run the initial scan if we are fully loaded into online
--        numGriefings = stats.get_int("MPPLY_GRIEFING")
--        numExploits = stats.get_int("MPPLY_EXPLOITS")
--        numGameExploits = stats.get_int("MPPLY_GAME_EXPLOITS")
--        numAnnoyingMe = stats.get_int("MPPLY_TC_ANNOYINGME")
--        numHateSpeech = stats.get_int("MPPLY_VC_HATE")
--        numOffensiveLanguage = stats.get_int("MPPLY_OFFENSIVE_LANGUAGE")
--        numOffensiveTagplate = stats.get_int("MPPLY_OFFENSIVE_TAGPLATE")
--        numOffensiveContent = stats.get_int("MPPLY_OFFENSIVE_UGC")
--        numBadCrewName = stats.get_int("MPPLY_BAD_CREW_NAME")
--        numBadCrewMotto = stats.get_int("MPPLY_BAD_CREW_MOTTO")
--        numBadCrewStatus = stats.get_int("MPPLY_BAD_CREW_STATUS")
--        numBadCrewEmblem = stats.get_int("MPPLY_BAD_CREW_EMBLEM")
--        numFriendly = stats.get_int("MPPLY_FRIENDLY")
--        numHelpful = stats.get_int("MPPLY_HELPFUL")
--        markedAsCheater = stats.get_bool("MPPLY_IS_CHEATER")
--        markedBadSport = stats.get_bool("MPPLY_WAS_I_BAD_SPORT")
--        markedHighEarner = stats.get_bool("MPPLY_IS_HIGH_EARNER")
--        statsInitialized = true
--    end
--end
--
--
--function checkForChanges()
--    local newNumGriefings = stats.get_int("MPPLY_GRIEFING")
--    local newNumExploits = stats.get_int("MPPLY_EXPLOITS")
--    local newNumGameExploits = stats.get_int("MPPLY_GAME_EXPLOITS")
--    local newNumAnnoyingMe = stats.get_int("MPPLY_TC_ANNOYINGME")
--    local newNumHateSpeech = stats.get_int("MPPLY_VC_HATE")
--    local newNumOffensiveLanguage = stats.get_int("MPPLY_OFFENSIVE_LANGUAGE")
--    local newNumOffensiveTagplate = stats.get_int("MPPLY_OFFENSIVE_TAGPLATE")
--    local newNumOffensiveContent = stats.get_int("MPPLY_OFFENSIVE_UGC")
--    local newNumBadCrewName = stats.get_int("MPPLY_BAD_CREW_NAME")
--    local newNumBadCrewMotto = stats.get_int("MPPLY_BAD_CREW_MOTTO")
--    local newNumBadCrewStatus = stats.get_int("MPPLY_BAD_CREW_STATUS")
--    local newNumBadCrewEmblem = stats.get_int("MPPLY_BAD_CREW_EMBLEM")
--    local newNumFriendly = stats.get_int("MPPLY_FRIENDLY")
--    local newNumHelpful = stats.get_int("MPPLY_HELPFUL")
--    local newMarkedAsCheater = stats.get_bool("MPPLY_IS_CHEATER")
--    local newMarkedBadSport = stats.get_bool("MPPLY_WAS_I_BAD_SPORT")
--    local newMarkedHighEarner = stats.get_bool("MPPLY_IS_HIGH_EARNER")
--
--    local changeDetected = false
--
--    if newNumGriefings > numGriefings then
--        lastStatIncreased = "Griefing"
--        numGriefings = newNumGriefings
--        changeDetected = true
--    end
--    if newNumExploits > numExploits then
--        lastStatIncreased = "Exploits"
--        numExploits = newNumExploits
--        changeDetected = true
--    end
--    if newNumGameExploits > numGameExploits then
--        lastStatIncreased = "Game Exploits"
--        numGameExploits = newNumGameExploits
--        changeDetected = true
--    end
--    if newNumAnnoyingMe > numAnnoyingMe then
--        lastStatIncreased = "Annoying Me"
--        numAnnoyingMe = newNumAnnoyingMe
--        changeDetected = true
--    end
--    if newNumHateSpeech > numHateSpeech then
--        lastStatIncreased = "Hate Speech"
--        numHateSpeech = newNumHateSpeech
--        changeDetected = true
--    end
--    if newNumOffensiveLanguage > numOffensiveLanguage then
--        lastStatIncreased = "Offensive Language"
--        numOffensiveLanguage = newNumOffensiveLanguage
--        changeDetected = true
--    end
--    if newNumOffensiveTagplate > numOffensiveTagplate then
--        lastStatIncreased = "Offensive Tagplate"
--        numOffensiveTagplate = newNumOffensiveTagplate
--        changeDetected = true
--    end
--    if newNumOffensiveContent > numOffensiveContent then
--        lastStatIncreased = "Offensive Content"
--        numOffensiveContent = newNumOffensiveContent
--        changeDetected = true
--    end
--    if newNumBadCrewName > numBadCrewName then
--        lastStatIncreased = "Offensive Crew Name"
--        numBadCrewName = newNumBadCrewName
--        changeDetected = true
--    end
--    if newNumBadCrewMotto > numBadCrewMotto then
--        lastStatIncreased = "Offensive Crew Motto"
--        numBadCrewMotto = newNumBadCrewMotto
--        changeDetected = true
--    end
--    if newNumBadCrewStatus > numBadCrewStatus then
--        lastStatIncreased = "Offensive Crew Status"
--        numBadCrewStatus = newNumBadCrewStatus
--        changeDetected = true
--    end
--    if newNumBadCrewEmblem > numBadCrewEmblem then
--        lastStatIncreased = "Offensive Crew Emblem"
--        numBadCrewEmblem = newNumBadCrewEmblem
--        changeDetected = true
--    end
--    if newNumFriendly > numFriendly then
--        lastStatIncreased = "Friendly Commend"
--        numFriendly = newNumFriendly
--        changeDetected = true
--    end
--    if newNumHelpful > numHelpful then
--        lastStatIncreased = "Helpful Commend"
--        numHelpful = newNumHelpful
--        changeDetected = true
--    end
--    if newMarkedAsCheater ~= markedAsCheater then
--        lastStatIncreased = "Marked As Cheater"
--        markedAsCheater = newMarkedAsCheater
--        changeDetected = true
--    end
--    if newMarkedBadSport ~= markedBadSport then
--        lastStatIncreased = "Marked As Bad Sport"
--        markedBadSport = newMarkedBadSport
--        changeDetected = true
--    end
--    if newMarkedHighEarner ~= markedHighEarner then
--        lastStatIncreased = "Marked As High Earner"
--        markedHighEarner = newMarkedHighEarner
--        changeDetected = true
--    end
--
--    if changeDetected then
--        displayHudBanner("CM_REPORT", "EF_RECEIVED", 69, 78)
--    end
--end
