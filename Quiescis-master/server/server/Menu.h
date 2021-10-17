/*
 * Displaying a menu about RAT commands
 * Banner output
*/

#ifndef MENU_H
#define MENU_H

void timenow();
void HelpMenu();
void PrintGreeting();

#ifdef __linux__
	#include <string>

	// colours
	static std::string wh_blue = "\033[1;36m";
	static std::string purpure = "\033[1;35m";
	static std::string blue    = "\033[1;34m";
	static std::string green   = "\033[1;32m";
	static std::string red     = "\033[1;31m";
	static std::string st_end  = "\033[1;0m";
#endif

#endif
