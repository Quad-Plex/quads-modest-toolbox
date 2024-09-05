## INSTALLATION INSTRUCTION:
Take EVERYTHING from the release .zip file and drop it into your modest-menu /scripts folder. The structure of the folder 
should look like this afterwards:

├💾 modest-menu.exe
├📁 scripts 
├── 📁 quads_toolbox_scripts
├── 📝 launcher_quads_toolbox.lua
├── 📝 loops_quads_toolbox.lua
└── <other script files>

TODO:
- Add more text labels for car mod categorie selections (like horns, xenon colors, etc)
- make neon color controllable (rgb is currently random)
- Generate Hotkey json outside of script folder next to modest-menu.exe to have it survive a script update
- playerlist readme/legend with symbol explanation
- Add Readme and FAQ description for unclear actions

DONE:
- ~~add installation isntructions~~
- ~~add livery data for all vehicles~~
- ~~add money remover with make it rain global~~
- ~~Add Mercenaries/Mugger to trolling options~~
- ~~add automated release procedure~~
  - ~~Including automatic changelog from commit messages for release~~ 
- ~~Add tiny player toggle~~
- ~~Add option to save mod data as default for favorited vehicle~~
- ~~Make vehicle search find favorited vehicles by their display name~~
- ~~'World Options' with remove traffic, remove peds, toggle snow, leave online session, Force Exit Game~~
- ~~when using random spawner, see the generated random mods as tempmods~~
- ~~Add full customizable mod options to vehicle spawner~~
- ~~Add error message about missing folder if requires fail~~
- ~~Fix missing ped categories causing missing peds~~
- ~~Don't give back weapons when changing to an animal model~~
- ~~Add drift tyres toggle~~
- ~~Add snow toggle~~
- ~~Major rewrite of all loop functions to have them running in the background including json synchronisation~~
- ~~Add Give Back Weapons~~
- ~~add text search for peds~~
- ~~add text search for cars~~
- ~~update modder info in playerinfo and add dev dlc/ped model detection~~
- ~~Fix roll_center in carboost making some cars uncontrollable~~
- ~~add missing ped models~~
- ~~Clean up ped-changer sorting~~
- ~~Add new vehicles from DLC with mod data~~
- ~~Updated all globals to version 3274~~
- ~~Fix noclip causing under-map respawn~~
- ~~add a 'Track Player with GPS' option~~
- ~~modder detection based on modified ped model~~
- ~~weaponmods menu with all interesting weapon setters to try out on the current weapon~~
- ~~add ped model changer~~
  - ~~add ability to add specific ped models as favorites~~ 
- ~~implement the hide from map/list feature~~
- ~~Figure out how to change vehicle light color during spawn FIXED~~
- ~~Add disable traffic/player collision option~~
- ~~Ability to Spawn cars with modifications (none, random or max mods)~~
  - ~~Complete hardcoded max mods values for all car hashes + cleanup~~
- ~~Detection/Notification for changed reports stats~~
- ~~noclip updated for native vehicle tp using entity:set_entity_position and entity:set_entity_rotation~~
- ~~Add native teleport with vehicle (BIG THANKS to Alice2333 on UKC)~~
- ~~Add duplicate/clone/save near/current vehicle to favorites~~~~~~
- ~~Add Beyblade Mode for current car~~
  - ~~Multiple Improvements to beyblade Mode~~ 
- ~~Add toggle for speedometer to be a banner or license plate related~~
- ~~TP into spawned vehicles~~
  - ~~TP into other players' vehicles~~
- ~~Added simple Nightclub safe money loop~~
- ~~Added Stat Changer Submenu~~
- ~~Search for globals related to remote controlling a vehicle (start engine, turn on lights, open doors etc.)~~
  - ~~If I can open doors - can I make flappy doors?? HELL YEA I CAN~~
- ~~AUTO UPDATE OF RID WITHOUT UPDATING PLAYERLIST~~
- ~~- Can I find RID from globals??~~
  - ~~Yes, through freemode script locals, but THE FUCKING OFFSET CHANGES WITH EVERY LAUNCH OF THE GAME FFS~~
  - ~~Created a huge list of possible offsets through trial and error and made the script choose the right one~~
  - ~~Added easy updater in case of unknown offset~~
- ~~Save godmode spawner status for favorited cars in vehicle spawner~~
- ~~Add all ExplosionTypes with an array item~~
- ~~Improve displayMessage timeout for multiple calls to it~~
- ~~Add displayMessages for hotkey toggles~~
- ~~add ability to turn on/off modder/spectator notifications (playerlist settings maybe)~~
- ~~More testing with the speedometer (find displayboxtype without fade-in maybe?)~~ Nope.
- ~~Check if bool    vehicle:get_boost()~~
  ~~bool    vehicle:get_boost_active()        nil     vehicle:set_boost(bool value)~~
  ~~bool    vehicle:get_boost_enabled()       nil     vehicle:set_boost_enabled(bool value)~~
  ~~- can be used to create homing cars that launch towards a player with rocket boost~~   Gotta wait for Kiddions update
- ~~improve globalscanner~~
  - ~~Add ability to show globals in nearby menu as vehicle hashes~~
  - ~~Adapted String-Entering Submenu for use with entering large numbers~~0
  - ~~A-Z String-entering submenu for globalscanner~~
  - ~~Search through script locals or globals~~
  - ~~Search for floats and ints~~
  - ~~Search for strings~~
  - ~~Make found globals be their own submenu with more options~~
    - ~~text: add original value of global on top~~
    - ~~add global to watched globals~~
    - ~~set global value as exact search~~
    - ~~show nearby globals~~
      - ~~global browser with 50 elements and a 'Show more' button on top and bottom~~
      - ~~the selected global should be greyed out or otherwise marked~~
    - ~~change global value~~
    - ~~show global as int or as string~~
    - ~~Print global to console~~
  - ~~add the ability to infinitely undo searches~~ 
  - ~~search for value lower than x or greater than x~~
- ~~Vehicle Spawner with godmode spawner option~~
  - ~~maybe make each spawner option have three buttons - Spawner #1, Spawner #2 and Godmode Toggle~~
  - ~~also save car to favorites list~~
    - ~~if favorites list exists, add a 'favorites' list on top separated by a row of ------~~
    - ~~add 'remove car from favorites' for cars in the list~~
- ~~Add an Action to Stop All Loop Actions~~
  - ~~perhaps separate the loop actions into a new "Troll Loops" sub aswell~~
- ~~Show disabled flags option for pedflags sub~~
- ~~Write a global updater.lua that allows changing of base globals and has 'Test' buttons under each base global int range~~
- ~~Create separate submenu entries for the script categories~~
- ~~action key for the vehicle jump~~
- ~~add more gun options like water jet gun/fire gun etc~~
- ~~make the hotkeys customizable and save them to json~~
- ~~add global constants for all the hotkey IDs~~
- ~~add separate Vehicle Spawner Submenu not inside the playerList~~
- ~~Look for displaybannerMessages for Water/Smoke/Fire for weaponMods~~
  - ~~Even more displayBannerMessages for other menu actions~~ 
- ~~FIX THE PICKUPS/MODEL LIST JFC what have I done there~~
- ~~make hotkeys customizable with array actions containing the hotkeys~~
- ~~refactor base globals into indexable table~~
