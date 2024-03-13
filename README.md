TODO:
- See if GPS coordinates can be controlled through globals, then add a 'Track Player with GPS' option
  - Hmmm... Can't find it in globals or the scripts I've implemented so far, might not be possible
- Check if bool    vehicle:get_boost()
  bool    vehicle:get_boost_active()        nil     vehicle:set_boost(bool value)
  bool    vehicle:get_boost_enabled()       nil     vehicle:set_boost_enabled(bool value)
  - can be used to create homing cars that launch towards a player with rocket boost
- Add Readme and FAQ description for unclear actions
- More testing with the invisible MOC maybe
- More testing with the speedometer (find displayboxtype without fade-in maybe?)
- more testing with the displayboxtype that shows a playername, is it configurable?

DONE:
- ~~improve globalscanner~~
  - ~~Search through script locals or globals~~
  - ~~Search for floats and ints~~
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
- ~~FIX THE PICKUPS/MODEL LIST JFC what have I done there~~
- ~~make hotkeys customizable with array actions containing the hotkeys~~
- ~~refactor base globals into indexable table~~