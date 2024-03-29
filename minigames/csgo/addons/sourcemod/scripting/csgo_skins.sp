/**
* CS:GO Skins Chooser by Root
*
* Description:
*   Changes player skin and appropriate arms on the fly without editing any configuration files.
*
* Version 1.2.2
* Changelog & more info at http://goo.gl/4nKhJ
*/

// ====[ SEMICOLON ]=========================================================================
#pragma semicolon 1

// ====[ INCLUDES ]==========================================================================
#include <sdktools>
#include <cstrike>
#undef REQUIRE_PLUGIN
#include <updater>

// ====[ CONSTANTS ]=========================================================================
#define PLUGIN_NAME     "CS:GO Skins Chooser"
#define PLUGIN_VERSION  "1.2.2"
#define UPDATE_URL      "https://raw.github.com/zadroot/CSGO_SkinsChooser/master/updater.txt"
#define MAX_SKINS_COUNT 72
#define MAX_SKIN_LENGTH 41
#define RANDOM_SKIN     -1

// ====[ VARIABLES ]=========================================================================
new	Handle:sc_enable     = INVALID_HANDLE,
	Handle:sc_random     = INVALID_HANDLE,
	Handle:sc_changetype = INVALID_HANDLE,
	Handle:sc_admflag    = INVALID_HANDLE,
	Handle:t_skins_menu  = INVALID_HANDLE,
	Handle:ct_skins_menu = INVALID_HANDLE,
	String:TerrorSkin[MAX_SKINS_COUNT][MAX_SKIN_LENGTH],
	String:TerrorArms[MAX_SKINS_COUNT][MAX_SKIN_LENGTH],
	String:CTerrorSkin[MAX_SKINS_COUNT][MAX_SKIN_LENGTH],
	String:CTerrorArms[MAX_SKINS_COUNT][MAX_SKIN_LENGTH],
	AdmFlag, TSkins_Count, CTSkins_Count, Selected[MAXPLAYERS + 1] = {RANDOM_SKIN, ...};

// ====[ PLUGIN ]============================================================================
public Plugin:myinfo =
{
	name        = PLUGIN_NAME,
	author      = "Root",
	description = "Simply stock skin chooser for CS:GO",
	version     = PLUGIN_VERSION,
	url         = "forums.alliedmods.net/showthread.php?p=1889086"
};


/* OnPluginStart()
 *
 * When the plugin starts up.
 * ------------------------------------------------------------------------------------------ */
public OnPluginStart()
{
	// Create console variables
	CreateConVar("sm_csgo_skins_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_NOTIFY|FCVAR_PLUGIN|FCVAR_SPONLY);
	sc_enable     = CreateConVar("sm_csgo_skins_enable",  "1", "Whether or not enable CS:GO Skins Chooser plugin",                                   FCVAR_PLUGIN, true, 0.0, true, 1.0);
	sc_random     = CreateConVar("sm_csgo_skins_random",  "1", "Whether or not randomly change models for all players on every respawn",             FCVAR_PLUGIN, true, 0.0, true, 1.0);
	sc_changetype = CreateConVar("sm_csgo_skins_change",  "0", "Determines when change selected player skin:\n0 = On next respawn\n1 = Immediately", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	sc_admflag    = CreateConVar("sm_csgo_skins_admflag", "",  "If flag is specified (a-z), only admins with that flag will able to use skins menu", FCVAR_PLUGIN, true, 0.0);

	// Create/register client commands
	RegConsoleCmd("skin",  Command_SkinsMenu);
	RegConsoleCmd("skins", Command_SkinsMenu);
	RegConsoleCmd("model", Command_SkinsMenu);

	// Hook post-respawn event
	HookEvent("player_spawn", OnPlayerSpawn, EventHookMode_Post);

	// Create and exec plugin configuration file
	AutoExecConfig(true, "csgo_skins");

	if (LibraryExists("updater"))
	{
		// Adds plugin to the updater
		Updater_AddPlugin(UPDATE_URL);
	}
}

/* OnMapStart()
 *
 * When the map starts.
 * ------------------------------------------------------------------------------------------ */
public OnMapStart()
{
	// Declare string to load skin's config from sourcemod/configs folder
	decl String:file[PLATFORM_MAX_PATH], String:curmap[64];

	// Get current map
	GetCurrentMap(curmap, sizeof(curmap));

	// Let's check that custom skin configuration file is exists for this map
	BuildPath(Path_SM, file, sizeof(file), "configs/skins/%s.cfg", curmap);

	// Could not read config for new map
	if (!FileExists(file))
	{
		// Then use default one
		BuildPath(Path_SM, file, sizeof(file), "configs/skins/any.cfg");

		// No config wtf?!
		if (!FileExists(file)) SetFailState("Fatal error: Unable to open generic configuration file \"%s\"", file);
	}

	// Refresh menus and config
	PrepareMenus();
	PrepareConfig(file);
}

/* OnLibraryAdded()
 *
 * Called after a library is added that the current plugin references.
 * ------------------------------------------------------------------------------------------ */
public OnLibraryAdded(const String:name[])
{
	// Updater stuff
	if (StrEqual(name, "updater")) Updater_AddPlugin(UPDATE_URL);
}

/* OnPlayerSpawn()
 *
 * Called after a player spawns.
 * ------------------------------------------------------------------------------------------ */
public OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Skip event if plugin is disabled
	if (GetConVarBool(sc_enable))
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));

		// Plugin should work only with valid clients
		if (IsValidClient(client))
		{
			// Get chosen model if avalible
			new model = Selected[client];

			// Get same random number for using same arms and skin
			new trandom  = GetRandomInt(0, TSkins_Count  - 1);
			new ctrandom = GetRandomInt(0, CTSkins_Count - 1);

			// Set skin depends on client's team
			switch (GetClientTeam(client))
			{
				case CS_TEAM_T: // Terrorists
				{
					// If random model should be accepted, get random skin of all avalible skins
					if (GetConVarBool(sc_random) && Selected[client] == RANDOM_SKIN)
					{
						SetEntityModel(client, TerrorSkin[trandom]);

						// It works!!
						SetEntPropString(client, Prop_Send, "m_szArmsModel", TerrorArms[trandom]);
					}
					else if (model > RANDOM_SKIN && model < TSkins_Count)
					{
						SetEntityModel(client, TerrorSkin[model]);
						SetEntPropString(client, Prop_Send, "m_szArmsModel", TerrorArms[model]);
					}
				}
				case CS_TEAM_CT: // Counter-Terrorists
				{
					// Also make sure that player havent chosen any skin yet
					if (GetConVarBool(sc_random) && Selected[client] == RANDOM_SKIN)
					{
						SetEntityModel(client, CTerrorSkin[ctrandom]);
						SetEntPropString(client, Prop_Send, "m_szArmsModel", CTerrorArms[ctrandom]);
					}

					// Model index must be valid (more than map default and less than max)
					else if (model > RANDOM_SKIN && model < CTSkins_Count)
					{
						// And set the model
						SetEntityModel(client, CTerrorSkin[model]);
						SetEntPropString(client, Prop_Send, "m_szArmsModel", CTerrorArms[model]);
					}
				}
			}
		}
	}
}

/* Command_SkinsMenu()
 *
 * Shows skin's menu to a player.
 * ------------------------------------------------------------------------------------------ */
public Action:Command_SkinsMenu(client, args)
{
	if (GetConVarBool(sc_enable))
	{
		// Once again make sure that client is valid
		if (IsValidClient(client) && (IsPlayerAlive(client) || !GetConVarBool(sc_changetype)))
		{
			// Get flag name from convar string and get client's access
			decl String:admflag[AdminFlags_TOTAL];
			GetConVarString(sc_admflag, admflag, sizeof(admflag));

			// Converts a string of flag characters to a bit string
			AdmFlag = ReadFlagString(admflag);

			// Check if player is having any access (including skins overrides)
			if (AdmFlag == 0
			||  AdmFlag != 0 && CheckCommandAccess(client, "csgo_skins_override", AdmFlag, true))
			{
				// Show individual skin menu depends on client's team
				switch (GetClientTeam(client))
				{
					case CS_TEAM_T:  if (t_skins_menu  != INVALID_HANDLE) DisplayMenu(t_skins_menu,  client, MENU_TIME_FOREVER);
					case CS_TEAM_CT: if (ct_skins_menu != INVALID_HANDLE) DisplayMenu(ct_skins_menu, client, MENU_TIME_FOREVER);
				}
			}
		}
	}

	// That thing fixing 'unknown command' in client console on command call
	return Plugin_Handled;
}

/* MenuHandler_ChooseSkin()
 *
 * Menu to set player's skin.
 * ------------------------------------------------------------------------------------------ */
public MenuHandler_ChooseSkin(Handle:menu, MenuAction:action, client, param)
{
	// Called when player pressed something in a menu
	if (action == MenuAction_Select)
	{
		// Don't use any other value than 10, otherwise you may crash clients and a server!
		decl String:skin_id[10];
		GetMenuItem(menu, param, skin_id, sizeof(skin_id));

		new skin = StringToInt(skin_id, sizeof(skin_id));

		// Make sure we havent selected random skin
		if (!StrEqual(skin_id, "Random"))
		{
			// Correct. So lets save the selected skin
			Selected[client] = skin;

			// Set player model and arms immediately
			if (GetConVarBool(sc_changetype))
			{
				// Depends on client team obviously
				switch (GetClientTeam(client))
				{
					case CS_TEAM_T:
					{
						SetEntityModel(client, TerrorSkin[skin]);
						SetEntPropString(client, Prop_Send, "m_szArmsModel", TerrorArms[skin]);
					}
					case CS_TEAM_CT:
					{
						SetEntityModel(client, CTerrorSkin[skin]);
						SetEntPropString(client, Prop_Send, "m_szArmsModel", CTerrorArms[skin]);
					}
				}
			}
		}
		else Selected[client] = RANDOM_SKIN;
	}
}

/* PrepareConfig()
 *
 * Adds skins to a menu, makes limits for allowed skins
 * ------------------------------------------------------------------------------------------ */
PrepareConfig(const String:file[])
{
	// Creates a new KeyValues structure
	new Handle:kv = CreateKeyValues("Skins");

	// Convert given file to a KeyValues tree
	FileToKeyValues(kv, file);

	// Get 'Terrorists' section
	if (KvJumpToKey(kv, "Terrorists"))
	{
		decl String:section[64], String:skin[64], String:arms[64], String:skin_id[3];

		// Sets the current position in the KeyValues tree to the first sub key
		KvGotoFirstSubKey(kv);

		do
		{
			// Get current section name
			KvGetSectionName(kv, section, sizeof(section));

			// Also make sure we've got 'skin' and 'arms' sections!
			if (KvGetString(kv, "skin", skin, sizeof(skin))
			&&  KvGetString(kv, "arms", arms, sizeof(arms)))
			{
				// Copy the full path of skin from config and save it
				strcopy(TerrorSkin[TSkins_Count], sizeof(TerrorSkin[]), skin);
				strcopy(TerrorArms[TSkins_Count], sizeof(TerrorArms[]), arms);

				Format(skin_id, sizeof(skin_id), "%d", TSkins_Count++);

				AddMenuItem(t_skins_menu, skin_id, section);

				// Precache every added model to prevent client crashes
				PrecacheModel(skin, true);
				PrecacheModel(arms, true);
			}
			else LogError("Player/arms model for \"%s\" is missing!", section); // Otherwise log an error
		}

		// Because we need to process all keys!
		while (KvGotoNextKey(kv));
	}
	else SetFailState("Fatal error: Missing \"Terrorists\" section!");

	// Get back to the top
	KvRewind(kv);

	// Check CT config right now
	if (KvJumpToKey(kv, "Counter-Terrorists"))
	{
		decl String:section[64], String:skin[64], String:arms[64], String:skin_id[3];

		KvGotoFirstSubKey(kv);

		// Lets begin!
		do
		{
			KvGetSectionName(kv, section, sizeof(section));

			if (KvGetString(kv, "skin", skin, sizeof(skin))
			&&  KvGetString(kv, "arms", arms, sizeof(arms)))
			{
				strcopy(CTerrorSkin[CTSkins_Count], sizeof(CTerrorSkin[]), skin);
				strcopy(CTerrorArms[CTSkins_Count], sizeof(CTerrorArms[]), arms);

				// Calculate number of avalible CT skins
				Format(skin_id, sizeof(skin_id), "%d", CTSkins_Count++);

				// Add every section as a menu item
				AddMenuItem(ct_skins_menu, skin_id, section);

				PrecacheModel(skin, true);

				// Precache arms too. Those will not crash client, but arms will not be shown at all
				PrecacheModel(arms, true);
			}

			// Whoops something was wrong here!
			else LogError("Player/arms model for \"%s\" is missing!", section);
		}
		while (KvGotoNextKey(kv));
	}
	else SetFailState("Fatal error: Missing \"Counter-Terrorists\" section!");

	KvRewind(kv);

	// Local handles must be freed!
	CloseHandle(kv);
}

/* PrepareMenus()
 *
 * Create menus if config is valid.
 * ------------------------------------------------------------------------------------------ */
PrepareMenus()
{
	// Firstly reset amount of avalible skins
	TSkins_Count = 0, CTSkins_Count = 0;

	// Then make sure that menu handlers is closed
	if (t_skins_menu != INVALID_HANDLE)
	{
		CloseHandle(t_skins_menu);
		t_skins_menu = INVALID_HANDLE;
	}
	if (ct_skins_menu != INVALID_HANDLE)
	{
		CloseHandle(ct_skins_menu);
		ct_skins_menu = INVALID_HANDLE;
	}

	// Create specified menus depends on client teams
	t_skins_menu  = CreateMenu(MenuHandler_ChooseSkin, MenuAction_Select);
	ct_skins_menu = CreateMenu(MenuHandler_ChooseSkin, MenuAction_Select);

	// And finally set the menu's titles
	SetMenuTitle(t_skins_menu,  "Choose your Terrorist skin:");
	SetMenuTitle(ct_skins_menu, "Choose your Counter-Terrorist skin:");

	if (GetConVarBool(sc_random))
	{
		AddMenuItem(t_skins_menu,  "Random", "Random");
		AddMenuItem(ct_skins_menu, "Random", "Random");
	}
}

/* IsValidClient()
 *
 * Checks if a client is valid.
 * ------------------------------------------------------------------------------------------ */
bool:IsValidClient(client) return (client > 0 && client <= MaxClients && IsClientInGame(client) && !GetEntProp(client, Prop_Send, "m_bIsControllingBot")) ? true : false;