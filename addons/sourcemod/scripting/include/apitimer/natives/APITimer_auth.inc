/*               <DR.API TIMER AUTH> (c) by De Battista Clint                */
/*                                                                           */
/*                   <DR.API TIMER AUTH> is licensed under a                 */
/*                        GNU General Public License                         */
/*                                                                           */
/*      You should have received a copy of the license along with this       */
/*            work.  If not, see <http://www.gnu.org/licenses/>.             */
//***************************************************************************//
//***************************************************************************//
//*****************************DR.API TIMER AUTH*****************************//
//***************************************************************************//
//***************************************************************************//

#if defined _APITimer_auth_included
 #endinput
#endif
#define _APITimer_auth_included

//Check if server is authorized to access to the global data.
//@return	True/False:		True if granted, and false if refused.
native bool APITimerAuthServerIsAuthorized();

//Retrieve the url api with authorisation access.
//@return	String:			Url web api.
native void APITimerAuthGetAPIWebUrl(char[] url);

//Retrieve the steamid64 client.
//@return	String:			SteamID64.
native void APITimerAuthGetClientSteamID64(int client, char[] steamid64);

public SharedPlugin __pl_APITimer_auth =
{
	name = "APITimer_auth",
	file = "APITimer_auth.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_APITimer_auth_SetNTVOptional()
{
	MarkNativeAsOptional("APITimerAuthServerIsAuthorized");
	MarkNativeAsOptional("APITimerAuthGetAPIWebUrl");
	MarkNativeAsOptional("APITimerAuthGetClientSteamID64");
}
#endif