#include <windows.h>
#include <tlhelp32.h>
#include <vector>
#include <string>
#include <fstream>

void TreatmentPath(std::string& path) {
	std::string n_path;
	for (unsigned int item = 0; item < path.length(); ++item) {
		if (path[item] == '/') n_path += "\\";
		else n_path += path[item];
	}
	path = n_path;
}

bool dirExists(const std::string& dirName_in) {
	DWORD ftyp = GetFileAttributesA(dirName_in.c_str());
	if (ftyp == INVALID_FILE_ATTRIBUTES)
		return false;

	if (ftyp & FILE_ATTRIBUTE_DIRECTORY)
		return true;

	return false;
}


bool FilExist(const std::string& name) {
	std::ifstream file(name);
	if (!file) return false;
	return true;
}

std::wstring string_to_wstring(std::string& s) {
	std::ofstream ofs("temp.txt", std::ofstream::out);
	if (!ofs) exit(1);
	ofs << s;
	ofs.close();

	std::wstring s1;
	std::wifstream wifs("temp.txt", std::wifstream::in);
	if (!wifs) exit(1);
	wifs >> s1;
	wifs.close();
	system("del temp.txt");
	return s1;
}

std::string wstring_to_string(std::wstring s) {
	std::wofstream wofs("temp.txt", std::wofstream::out);
	if (!wofs) exit(1);
	wofs << s;
	wofs.close();

	std::string s1;
	std::ifstream ifs("temp.txt", std::ifstream::in);
	if (!ifs) exit(1);
	ifs >> s1;
	ifs.close();
	system("del temp.txt");
	return s1;
}

DWORD GetProcessID(const char* lpNameProcess) {
	HANDLE snap;
	PROCESSENTRY32 pentry32;
	snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	if (snap == INVALID_HANDLE_VALUE) return 0;
	pentry32.dwSize = sizeof(PROCESSENTRY32);
	if (!Process32First(snap, &pentry32)) {
		CloseHandle(snap);
		return 0;
	}
	do {
		if (!lstrcmpi((LPCWSTR)lpNameProcess, &pentry32.szExeFile[0])) {
			CloseHandle(snap);
			return pentry32.th32ProcessID;
		}
	} while (Process32Next(snap, &pentry32));
	CloseHandle(snap);
	return 0;
}

std::vector<std::string> scandir(std::string p) {
	std::wstring Path = string_to_wstring(p);

	WIN32_FIND_DATA FindFileData;
	HANDLE hf;

	hf = FindFirstFile((string_to_wstring(p)).c_str(), &FindFileData);

	std::vector<std::string> v;
	if (hf != INVALID_HANDLE_VALUE) {
		do {
			if (FindFileData.dwFileAttributes != FILE_ATTRIBUTE_DIRECTORY)
				v.push_back(wstring_to_string(FindFileData.cFileName));
		} while (FindNextFile(hf, &FindFileData) != 0);
	}

	return v;
}