#if defined _apitimer_global_config_included
	#endinput
#endif
#define _apitimer_global_config_included

#define PLUGIN_VERSION					"1.0.0"
#define API_URL							"http://apitimer.sourcemod.market/api"

#define MAX_URL_LEN 					512
#define MAX_MAPZONE_ZONES				100
#define MAX_MAPZONE_POINTS				50
#define MAX_TYPES						10
#define MAX_SUBTYPES					10

enum MapzoneTypes
{
	MapzoneTypes_Normal = 1,
	MapzoneTypes_Bonus
}

enum MapzoneSubTypes
{
	MapzoneSubTypes_Start = 1,
	MapzoneSubTypes_Level,
	MapzoneSubTypes_End	
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