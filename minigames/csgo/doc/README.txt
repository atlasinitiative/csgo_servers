
Description
-----------
    NoBlock plugin removes player vs. player collisions.
    Usefull for Surf servers.

    http://forums.alliedmods.net/showthread.php?t=91617
    
Commands and Cvars
------------------
    sm_noblock_version              - NoBlock version.
    
    sm_noblock                      - Removes player vs. player collisions. (Default: 1)
    sm_noblock_allow_block          - Allow players to use say !block. (Default: 1)
    sm_noblock_allow_block_time     - Time limit to say !block command. (Default: 20)
    sm_noblock_blockafterspawn_time - Disable blocking only for that time from spawn.
                                      (Default: 0; 0 = disabled)
    sm_noblock_nades                - Removes player vs. nade/flash/smoke collisions. (Default: 1)
    sm_noblock_hostages             - Removes player vs. hostage collisions. (Default: 0) - Only set this to 1 if you need it.
    
    say !block                      - Enable/Disable player vs. player collisions.

Requirements
------------
    * Counter-Strike: Source
    * SourceMod 1.2.0
    * You need extension SDK Hooks 1.3 (Updated 2010-05-12) or later
      https://forums.alliedmods.net/showthread.php?t=106748

Changelog
---------
    1.4.2:
        * Fixed
            L 09/21/2010 - 19:27:08: [SM] Native "GetEdictClassname" reported: Invalid edict (209 - 209)
            L 09/21/2010 - 19:27:08: [SM] Displaying call stack trace for plugin "noblock.smx":
            L 09/21/2010 - 19:27:08: [SM] [0] Line 317, noblock.sp::UnblockHostages()
            L 09/21/2010 - 19:27:08: [SM] [1] Line 189, noblock.sp::OnRoundStart()

    1.4.1:
        * Refactoring.

    1.4.0:
        + Added cvars: sm_noblock_nades, sm_noblock_hostages. Thanks to GoD-Tony.

    1.3.0:
        + Add sm_noblock_blockafterspawn_time variable to disable noblock for spawned player
            after some time.
        * Fixed two minor bugs.
    
    1.2.0:
        * Enables/disables all players blocking when cvar sm_noblock is changed.
          It is now not needed to wait until next respawn.
        * Code improved. Fixed bugs:
            1) L 06/27/2008 - 13:16:50: [SM] Native "GetClientUserId" reported: Client 2 is not connected
            2) L 06/27/2008 - 13:43:50: [SM] Native "PrintToChat" reported: Client 2 is not in game
            3) L 07/02/2008 - 20:40:33: [SM] Native "SetEntData" reported: Entity 2 is invalid
            4) L 07/15/2008 - 23:02:23: [SM] Native "CloseHandle" reported: Handle 253e00a2 is invalid (error 3)
            5) L 09/08/2008 - 15:36:25: [SM] Plugin encountered error 15: Array index is out of bounds
        
    1.1.1:
        + Added sm_noblock_version.
        
    1.0.0:
        + Added sm_noblock_allow_block, sm_noblock_allow_block_time to allow players to use say !block command.
        + If player already blocking say !block disables blocking.

Credits
-------
    * Thanks to GoD-Tony for adding cvars: sm_noblock_nades, sm_noblock_hostages.

    * Thanks to sslice for No Block plugin till version 1.0.0.0.
      http://forums.alliedmods.net/showthread.php?t=53721
      NoBlock is based on its source code.

    
TODO
----
    + Add version without SDKHooks. Add define.
    + Feature request
        Could you add cvar vice versa ?
        If sm_noblock_blockafterspawn_time 0 (disabled)
        and player can use chat command !noblock
        player temporary can go through other players
    * Fix bug:
        L 11/04/2009 - 23:09:42: Error log file session closed.
        L 11/04/2009 - 23:09:53: SourceMod error session started
        L 11/04/2009 - 23:09:53: Info (map "surf_sandman_v2") (file "errors_20091104.log")
        L 11/04/2009 - 23:09:53: [SM] Native "CloseHandle" reported: Handle e0000b5 is invalid (error 3)
        L 11/04/2009 - 23:09:53: [SM] Displaying call stack trace for plugin "noblock.smx":
        L 11/04/2009 - 23:09:53: [SM]   [0]  Line 73, noblock.sp::OnSpawn()
        L 11/04/2009 - 23:09:56: [SM] Native "CloseHandle" reported: Handle e0000b5 is invalid (error 1)
        L 11/04/2009 - 23:09:56: [SM] Displaying call stack trace for plugin "noblock.smx":
        L 11/04/2009 - 23:09:56: [SM]   [0]  Line 73, noblock.sp::OnSpawn()
        L 11/04/2009 - 23:10:43: [SM] Native "CloseHandle" reported: Handle e0000b5 is invalid (error 1)
        L 11/04/2009 - 23:10:43: [SM] Displaying call stack trace for plugin "noblock.smx":
        L 11/04/2009 - 23:10:43: [SM]   [0]  Line 73, noblock.sp::OnSpawn()
        L 11/04/2009 - 23:14:48: [SM] Native "CloseHandle" reported: Handle e0000b5 is invalid (error 1)
        L 11/04/2009 - 23:14:48: [SM] Displaying call stack trace for plugin "noblock.smx":
        L 11/04/2009 - 23:14:48: [SM]   [0]  Line 73, noblock.sp::OnSpawn()
        L 11/04/2009 - 23:18:52: [SM] Native "CloseHandle" reported: Handle e0000b5 is invalid (error 1)
        L 11/04/2009 - 23:18:52: [SM] Displaying call stack trace for plugin "noblock.smx":
        L 11/04/2009 - 23:18:52: [SM]   [0]  Line 73, noblock.sp::OnSpawn()
        L 11/04/2009 - 23:25:11: [SM] Native "CloseHandle" reported: Handle e0000b5 is invalid (error 1)
        L 11/04/2009 - 23:25:11: [SM] Displaying call stack trace for plugin "noblock.smx":
        L 11/04/2009 - 23:25:11: [SM]   [0]  Line 73, noblock.sp::OnSpawn()
    * Fix bug:
        L 08/08/2009 - 00:11:56: [SM] To enable debug mode, edit plugin_settings.cfg,
        or type: sm plugins debug 3 on
        L 08/08/2009 - 00:15:37: [SM] Native "CloseHandle" reported: Handle d9d00a8 is
        invalid (error 3)
        L 08/08/2009 - 00:15:37: [SM] Debug mode is not enabled for "noblock.smx"
        L 08/08/2009 - 00:15:37: [SM] To enable debug mode, edit plugin_settings.cfg,
        or type: sm plugins debug 3 on
        L 08/08/2009 - 00:17:16: [SM] Native "CloseHandle" reported: Handle d9d00a8 is
        invalid (error 1)
        L 08/08/2009 - 00:17:16: [SM] Debug mode is not enabled for "noblock.smx"
    + Feature request
        hi plugin is very nice... i miss a thing... when sm_noblock changed to 1/0 it
        shows in chatarea (css) "server cvar sm_noblock changed to 1/0" or like
        this... can u add a feature to the plugin that ther can be shown "NoBlock is
        now enabled/disabled" and that with colours? like green or so?
    * Add functionality to check players positions and turn off noblock just for players that has no 
        collisions with each other. Enable this only if sm_noblock_blockafterspawn_time otpion is 
        enabled.
