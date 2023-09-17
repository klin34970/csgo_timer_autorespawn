/*            <DR.API TIMER ADMINMENU> (c) by De Battista Clint              */
/*                                                                           */
/*                 <DR.API TIMER ADMINMENU> is licensed under a              */
/*                        GNU General Public License                         */
/*                                                                           */
/*      You should have received a copy of the license along with this       */
/*            work.  If not, see <http://www.gnu.org/licenses/>.             */
//***************************************************************************//
//***************************************************************************//
//***************************DR.API TIMER ADMINMENU**************************//
//***************************************************************************//
//***************************************************************************//

#if defined _APITimer_adminmenu_included
 #endinput
#endif
#define _APITimer_adminmenu_included

/* Decide whether topmenus should be required */
#if !defined REQUIRE_PLUGIN
 #if defined REQUIRE_EXTENSIONS
  #define TEMP_REQUIRE_EXTENSIONS
  #undef REQUIRE_EXTENSIONS
 #endif
#endif

#include <topmenus>

/* Restore old REQUIRE_EXTENSIONS value if necessary */
#if defined TEMP_REQUIRE_EXTENSIONS
 #define REQUIRE_EXTENSIONS
 #undef TEMP_REQUIRE_EXTENSIONS
#endif

/** Category for player commands. */
#define ADMINMENU_MAPZONES		"Mapzones"

/**
 * Called when the admin menu is created and 3rd party plugins can grab 
 * the Handle or add categories.
 * 
 * @param topmenu		Handle to the admin menu's TopMenu.
 */
forward void APITimer_OnAdminMenuCreated(Handle topmenu);

/**
 * Called when the admin menu is ready to have items added.
 * 
 * @param topmenu		Handle to the admin menu's TopMenu.
 */
forward void APITimer_OnAdminMenuReady(Handle topmenu);

/**
 * Retrieves the Handle to the admin top menu.
 *
 * @return				Handle to the admin menu's TopMenu,
 *						or INVALID_HANDLE if not created yet.
 */
native TopMenu APITimer_GetAdminTopMenu();

/**
 * Adds targets to an admin menu.
 *
 * Each client is displayed as: name (userid)
 * Each item contains the userid as a string for its info.
 *
 * @param menu			Menu Handle.
 * @param source_client	Source client, or 0 to ignore immunity.
 * @param in_game_only	True to only select in-game players.
 * @param alive_only 	True to only select alive players.
 * @return				Number of clients added.
 */
native APITimer_AddTargetsToMenu(Handlevmenu, 
						int source_client, 
						bool in_game_only=true, 
						bool alive_only=false);

/**
 * Adds targets to an admin menu.
 *
 * Each client is displayed as: name (userid)
 * Each item contains the userid as a string for its info.
 *
 * @param menu			Menu Handle.
 * @param source_client	Source client, or 0 to ignore immunity.
 * @param flags			COMMAND_FILTER flags from commandfilters.inc.
 * @return				Number of clients added.
 */
native APITimer_AddTargetsToMenu2(Handle menu, int source_client, int flags);

/**
 * Re-displays the admin menu to a client after selecting an item.
 * Auto-aborts if the Handle is invalid.
 *
 * @param topmenu		TopMenu Handle.
 * @param client		Client index.
 * @return				True on success, false on failure.
 */
stock bool RedisplayAdminMenu(Handle topmenu, int client)
{
	if (topmenu == INVALID_HANDLE)
	{
		return false;
	}

	return DisplayTopMenu(topmenu, client, TopMenuPosition_LastCategory);
}

public SharedPlugin __pl_APITimer_adminmenu =
{
	name = "APITimer_adminmenu",
	file = "APITimer_adminmenu.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_APITimer_adminmenu_SetNTVOptional()
{
	MarkNativeAsOptional("APITimer_GetAdminTopMenu");
	MarkNativeAsOptional("APITimer_AddTargetsToMenu");
	MarkNativeAsOptional("APITimer_AddTargetsToMenu2");
}
#endif