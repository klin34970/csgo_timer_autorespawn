/*               <DR.API TIMER AUTH> (c) by De Battista Clint                */
/*                                                                           */
/*                   <DR.API TIMER AUTH> is licensed under a                 */
/*                        GNU General Public License                         */
/*																			 */
/*      You should have received a copy of the license along with this       */
/*            work.  If not, see <http://www.gnu.org/licenses/>.             */
//***************************************************************************//
//***************************************************************************//
//*****************************DR.API TIMER AUTH*****************************//
//***************************************************************************//
//***************************************************************************//

#if defined _APITimer_core_included
 #endinput
#endif
#define _APITimer_core_included

//Start the timer.
//@param client
//@return	True/False:		True if started, and false if not started.
native bool APITimer_TimerStart(int client);

//Stop the timer.
//@param client
//@param pause
//@return	True/False:		True if stopped, and false if not stopped.
native bool APITimer_TimerStop(int client, bool isPaused = true);

public SharedPlugin __pl_APITimer_core =
{
	name = "APITimer_core",
	file = "APITimer_core.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_APITimer_core_SetNTVOptional()
{
	MarkNativeAsOptional("APITimer_TimerStart");
	MarkNativeAsOptional("APITimer_TimerStop");
}
#endif