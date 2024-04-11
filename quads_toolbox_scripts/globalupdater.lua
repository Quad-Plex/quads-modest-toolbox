local sortedGlobals = {}
for k in pairs(baseGlobals) do
    table.insert(sortedGlobals, k)
end
table.sort(sortedGlobals)

local function launchGlobalUpdater(sub)
    addText(sub, "!!WARNING!! DON'T CHANGE THESE")
    addText(sub, "VALUES IF YOU DON'T KNOW WHAT")
    addText(sub, "YOU'RE DOING!")
    greyText(sub, "============================")
    for _, globalCategory in ipairs(sortedGlobals) do
        addText(sub, centeredText("====" .. globalCategory .. "===="))
        local sortedCategory = {}
        local testFunction
        local testFunctionExplanation
        local testIntRange
        local intRangeExplanation
        local testCheck
        local checkExplanation
        local bareStringCheck
        for k in pairs(baseGlobals[globalCategory]) do
            table.insert(sortedCategory, k)
        end
        table.sort(sortedCategory)
        for _, globalName in ipairs(sortedCategory) do
            if globalName == "testFunction" then
                testFunction = baseGlobals[globalCategory][globalName]
            elseif globalName == "testFunctionExplanation" then
                testFunctionExplanation = baseGlobals[globalCategory][globalName]
            elseif globalName == "testIntRange" then
                testIntRange = baseGlobals[globalCategory][globalName]
            elseif globalName == "intRangeExplanation" then
                intRangeExplanation = baseGlobals[globalCategory][globalName]
            elseif globalName == "testCheck" then
                testCheck = baseGlobals[globalCategory][globalName]
            elseif globalName == "checkExplanation" then
                checkExplanation = baseGlobals[globalCategory][globalName]
            elseif globalName == "bareStringCheck" then
                bareStringCheck = baseGlobals[globalCategory][globalName]
            else
                sub:add_int_range(globalName, 1, 0, MAX_INT,
                        function()
                            return baseGlobals[globalCategory][globalName]
                        end,
                        function(n)
                            baseGlobals[globalCategory][globalName] = n
                        end
                )
            end
        end
        if testFunction then
            if testFunctionExplanation then
                sub:add_action(testFunctionExplanation, testFunction)
            else
                sub:add_action("Test " .. globalCategory, testFunction)
            end
        elseif testCheck then
            sub:add_toggle(checkExplanation, testCheck, null)
        elseif testIntRange then
            sub:add_int_range(intRangeExplanation, 1, 0, MAX_INT, testIntRange, null)
        elseif bareStringCheck then
            sub:add_bare_item("", bareStringCheck, null, null, null)
        else
            greyText(sub, "Update via freemode.c")
        end
        greyText(sub, "---------------------------")
    end
end

local globalUpdaterSub
globalUpdaterSub = debugToolsSub:add_submenu("Global Updater", function()
    launchGlobalUpdater(globalUpdaterSub)
end)