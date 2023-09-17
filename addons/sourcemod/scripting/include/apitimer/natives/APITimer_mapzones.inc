/*             <DR.API TIMER MAPZONES> (c) by De Battista Clint              */
/*                                                                           */
/*                 <DR.API TIMER MAPZONES> is licensed under a               */
/*                        GNU General Public License                         */
/*                                                                           */
/*      You should have received a copy of the license along with this       */
/*            work.  If not, see <http://www.gnu.org/licenses/>.             */
//***************************************************************************//
//***************************************************************************//
//***************************DR.API TIMER MAPZONES***************************//
//***************************************************************************//
//***************************************************************************//

#if defined _APITimer_mapzones_included
 #endinput
#endif
#define _APITimer_mapzones_included

//Call when player is entering in a zone
//@param	client
//@param	type
//@param	subtype
//@param	zoneid
//@param	lasttype
//@param	lastsubtype
//@param	lastzoneid
forward void APITimer_OnClientStartTouchZone(int client, MapzoneTypes type, MapzoneSubTypes subtype, int zoneid, MapzoneTypes lasttype, MapzoneSubTypes lastsubtype, int lastzoneid);

//Call when player is leaving in a zone
//@param	client
//@param	type
//@param	subtype
//@param	zoneid
forward void APITimer_OnClientEndTouchZone(int client, MapzoneTypes type, MapzoneSubTypes subtype, int zoneid);

//Retrieve all information when inside a zone
//@param	client
//@param	type
//@param	subtype
//@param	zoneid
//@return true/false if player is inside
native bool APITimerMapzonesInfos(int client, int &type, int &subtype, int &zoneid);

public SharedPlugin __pl_APITimer_mapzones =
{
	name = "APITimer_mapzones",
	file = "APITimer_mapzones.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_APITimer_mapzones_SetNTVOptional()
{
	MarkNativeAsOptional("APITimerMapzonesInfos");
}
#endif
