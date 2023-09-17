#if defined _apitimer_logger_included
	#endinput
#endif
#define _apitimer_logger_included

#define 		MSG_LENGTH 192

/***********************************************************/
/********************** LOG TO APITIMER ********************/
/***********************************************************/
stock void LogToAPITimer(bool status, const char[] format, any ...)
{
	if(status)
	{
		char msg[MSG_LENGTH];
		char msg2[MSG_LENGTH];
		char logfile[MSG_LENGTH];
		Format(msg, MSG_LENGTH, "%s", format);
		VFormat(msg2, MSG_LENGTH, msg, 3);
		
		BuildPath(Path_SM, logfile, sizeof(logfile), "logs/APITimer.txt");
		LogToFile(logfile, msg2);
	}
}
