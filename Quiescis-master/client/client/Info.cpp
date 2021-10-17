#include <windows.h>
#include <fstream>
#include <intrin.h>
#include <string>
#include <comdef.h>
#include <Wbemidl.h>

#pragma comment(lib, "wbemuuid.lib")
#pragma warning(disable: 4996)

#define _WIN32_DCOM
#define _CRT_OBSOLETE_NO_WARNINGS

#define PRODUCT_PROFESSIONAL 0x00000030
#define VER_SUITE_WH_SERVER	 0x00008000

typedef void (WINAPI* PGNSI)(LPSYSTEM_INFO);
typedef BOOL(WINAPI* PGPI)(DWORD, DWORD, DWORD, DWORD, PDWORD);


std::string Gpu() {
	std::string res = "";
	HRESULT hres;
	hres = CoInitializeEx(0, COINIT_MULTITHREADED);
	if (FAILED(hres)) return 0;
	hres = CoInitializeSecurity(NULL, -1, NULL, NULL, RPC_C_AUTHN_LEVEL_DEFAULT, RPC_C_IMP_LEVEL_IMPERSONATE, NULL, EOAC_NONE, NULL);
	if (FAILED(hres)) { 
		CoUninitialize();
		return "none";
	}
	IWbemLocator* pLoc = NULL;
	hres = CoCreateInstance(CLSID_WbemLocator, 0, CLSCTX_INPROC_SERVER, IID_IWbemLocator, (LPVOID*)&pLoc);
	if (FAILED(hres)) { 
		CoUninitialize();
		return "none";
	}
	IWbemServices* pSvc = NULL;
	hres = pLoc->ConnectServer(_bstr_t(L"root\\CIMV2"), NULL, NULL, 0, NULL, 0, 0, &pSvc);
	if (FAILED(hres)) { pLoc->Release(); CoUninitialize(); return 0; }
	hres = CoSetProxyBlanket(pSvc, RPC_C_AUTHN_WINNT, RPC_C_AUTHZ_NONE, NULL, RPC_C_AUTHN_LEVEL_CALL, RPC_C_IMP_LEVEL_IMPERSONATE, NULL, EOAC_NONE);
	if (FAILED(hres)) { 
		pSvc->Release();
		pLoc->Release();
		CoUninitialize();
		return "none";
	}
	IEnumWbemClassObject* pEnumerator = NULL;
	hres = pSvc->ExecQuery(bstr_t("WQL"),
		bstr_t("SELECT * FROM Win32_VideoController"),
		WBEM_FLAG_FORWARD_ONLY | WBEM_FLAG_RETURN_IMMEDIATELY, NULL, &pEnumerator);
	if (FAILED(hres)) { pSvc->Release(); pLoc->Release(); CoUninitialize(); return 0; }
	IWbemClassObject* pclsObj = (IWbemClassObject*)malloc(sizeof(IWbemClassObject));

	ULONG uReturn = 0;
	while (pEnumerator) {
		HRESULT hr = pEnumerator->Next(WBEM_INFINITE, 1, &pclsObj, &uReturn);
		if (0 == uReturn)break;
		VARIANT vtProp;
		hr = pclsObj->Get(L"Caption", 0, &vtProp, 0, 0);
		std::wstring wGpuName = vtProp.bstrVal;
		int size_needed = WideCharToMultiByte(CP_UTF8, 0, &wGpuName[0], (int)wGpuName.size(), NULL, 0, NULL, NULL);
		std::string strTo(size_needed, 0);
		WideCharToMultiByte(CP_UTF8, 0, &wGpuName[0], (int)wGpuName.size(), &strTo[0], size_needed, NULL, NULL);
			
		res += strTo;
		VariantClear(&vtProp);
	}
	pSvc->Release();
	pLoc->Release();
	pEnumerator->Release();
	pclsObj->Release();
	CoUninitialize();

	return res;
}

std::string RAM() {
	unsigned long long rams;
	GetPhysicallyInstalledSystemMemory(&rams);
	return std::to_string(rams/1024/1024);
}

std::string Cpu()
{
	// Get extended ids.
	int CPUInfo[4] = { -1 };
	__cpuid(CPUInfo, 0x80000000);
	unsigned int nExIds = CPUInfo[0];

	// Get the information associated with each extended ID.
	char CPUBrandString[0x40] = { 0 };
	for (unsigned int i = 0x80000000; i <= nExIds; ++i) {
		__cpuid(CPUInfo, i);

		// Interpret CPU brand string and cache information.
		if (i == 0x80000002)
			memcpy(CPUBrandString, CPUInfo,sizeof(CPUInfo));
		else if (i == 0x80000003)
			memcpy(CPUBrandString + 16, CPUInfo, sizeof(CPUInfo));
		else if (i == 0x80000004)
			memcpy(CPUBrandString + 32, CPUInfo, sizeof(CPUInfo));
		
	}
	std::string res = "";
	res += CPUBrandString;
	return res;
}

std::string OS() {
	OSVERSIONINFOEXA osvi;
	SYSTEM_INFO si;
	BOOL bOsVersionInfoEx;
	DWORD dwType; ZeroMemory(&si, sizeof(SYSTEM_INFO));
	ZeroMemory(&osvi, sizeof(OSVERSIONINFOEXA));
	osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEXA);
	bOsVersionInfoEx = GetVersionExA((OSVERSIONINFOA*)&osvi);

	PGNSI pGNSI = (PGNSI)GetProcAddress(GetModuleHandle(TEXT("kernel32.dll")), "GetNativeSystemInfo");
	if (NULL != pGNSI)
		pGNSI(&si);
	else GetSystemInfo(&si);
	if (VER_PLATFORM_WIN32_NT != osvi.dwPlatformId || osvi.dwMajorVersion <= 4) {
		return "none";
	} 
	std::string os = "Microsoft ";
	
	if (osvi.dwMinorVersion == 0) {
		if (osvi.wProductType == VER_NT_WORKSTATION)
			os += "Windows Vista ";
		else os += "Windows Server 2008 ";
	} 
	if (osvi.dwMinorVersion == 1) {
		if (osvi.wProductType == VER_NT_WORKSTATION)
			os += "Windows 7 ";
		else os += "Windows Server 2008 R2 ";
	}  PGPI pGPI = (PGPI)GetProcAddress(GetModuleHandle(TEXT("kernel32.dll")), "GetProductInfo");
	pGPI(osvi.dwMajorVersion, osvi.dwMinorVersion, 0, 0, &dwType);
	switch (dwType) {
		case PRODUCT_ULTIMATE:
			os += "Ultimate Edition";
			break;
		case PRODUCT_PROFESSIONAL:
			os += "Professional";
			break;
		case PRODUCT_HOME_PREMIUM:
			os += "Home Premium Edition";
			break;
		case PRODUCT_HOME_BASIC:
			os += "Home Basic Edition";
			break;
		case PRODUCT_ENTERPRISE:
			os += "Enterprise Edition";
			break;
		case PRODUCT_BUSINESS:
			os += "Business Edition";
			break;
		case PRODUCT_STARTER:
			os += "Starter Edition";
			break;
		case PRODUCT_CLUSTER_SERVER:
			os += "Cluster Server Edition";
			break;
		case PRODUCT_DATACENTER_SERVER:
			os += "Datacenter Edition";
			break;
		case PRODUCT_DATACENTER_SERVER_CORE:
			os += "Datacenter Edition (core installation)";
			break;
		case PRODUCT_ENTERPRISE_SERVER:
			os += "Enterprise Edition";
			break;
		case PRODUCT_ENTERPRISE_SERVER_CORE:
			os += "Enterprise Edition (core installation)";
			break;
		case PRODUCT_ENTERPRISE_SERVER_IA64:
			os += "Enterprise Edition for Itanium-based Systems";
			break;
		case PRODUCT_SMALLBUSINESS_SERVER:
			os += "Small Business Server";
			break;
		case PRODUCT_SMALLBUSINESS_SERVER_PREMIUM:
			os += "Small Business Server Premium Edition";
			break;
		case PRODUCT_STANDARD_SERVER:
			os += "Standard Edition";
			break;
		case PRODUCT_STANDARD_SERVER_CORE:
			os += "Standard Edition (core installation)";
			break;
		case PRODUCT_WEB_SERVER:
			os += "Web Server Edition";
			break;
		}

	if (osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 2) {
		if (GetSystemMetrics(SM_SERVERR2))
			os += "Windows Server 2003 R2, ";
		else if (osvi.wSuiteMask & VER_SUITE_STORAGE_SERVER)
			os += "Windows Storage Server 2003";
		else if (osvi.wSuiteMask & VER_SUITE_WH_SERVER)
			os += "Windows Home Server";
		else if (osvi.wProductType == VER_NT_WORKSTATION && si.wProcessorArchitecture == PROCESSOR_ARCHITECTURE_AMD64)
			os += "Windows XP Professional x64 Edition";
		else os += "Windows Server 2003";
		if (osvi.wProductType != VER_NT_WORKSTATION) {
			if (si.wProcessorArchitecture == PROCESSOR_ARCHITECTURE_IA64) {
				if (osvi.wSuiteMask & VER_SUITE_DATACENTER)
					os += "Datacenter Edition for Itanium-based Systems";
				else if (osvi.wSuiteMask & VER_SUITE_ENTERPRISE)
					os += "Enterprise Edition for Itanium-based Systems";
			}
			else if (si.wProcessorArchitecture == PROCESSOR_ARCHITECTURE_AMD64) {
				if (osvi.wSuiteMask & VER_SUITE_DATACENTER)
					os += "Datacenter x64 Edition";
				else if (osvi.wSuiteMask & VER_SUITE_ENTERPRISE)
					os += "Enterprise x64 Edition";
				else os += "Standard x64 Edition";
			}
			else {
				if (osvi.wSuiteMask & VER_SUITE_COMPUTE_SERVER)
					os += "Compute Cluster Edition";
				else if (osvi.wSuiteMask & VER_SUITE_DATACENTER)
					os += "Datacenter Edition";
				else if (osvi.wSuiteMask & VER_SUITE_ENTERPRISE)
					os += "Enterprise Edition";
				else if (osvi.wSuiteMask & VER_SUITE_BLADE)
					os += "Web Edition";
				else os += "Standard Edition";
			}
		}
	} 
	if (osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 1) {
		os += "Windows XP ";
		if (osvi.wSuiteMask & VER_SUITE_PERSONAL)
			os += "Home Edition";
		else os += "Professional";
	} 
	if (osvi.dwMajorVersion == 5 && osvi.dwMinorVersion == 0) {
		os += "Windows 2000 ";
		if (osvi.wProductType == VER_NT_WORKSTATION)
			os += "Professional";
		else {
			if (osvi.wSuiteMask & VER_SUITE_DATACENTER)
				os += "Datacenter Server";
			else if (osvi.wSuiteMask & VER_SUITE_ENTERPRISE)
				os += "Advanced Server";
			else os += "Server";
		}
	} 
	if (osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 2) {
		if (osvi.wProductType != VER_NT_WORKSTATION)
			os += "Server 2012";
		else
			os += "Windows 8";
		if (si.wProcessorArchitecture == PROCESSOR_ARCHITECTURE_AMD64)
			os += " x64 Edition";

	}
	if (osvi.dwMajorVersion == 6 && osvi.dwMinorVersion == 3) {
		if (osvi.wProductType != VER_NT_WORKSTATION)
			os += "Server 2012 R2";
		else
			os += "Windows 8.1";

		if (si.wProcessorArchitecture == PROCESSOR_ARCHITECTURE_AMD64)
			os += " x64 Edition";
	}
	if (osvi.dwMajorVersion == 10 && osvi.dwMinorVersion == 0) {
		if (osvi.wProductType != VER_NT_WORKSTATION)
			os += "Windows Server 2016 Technical Preview";
		else
			os += "Windows 10";

		if (si.wProcessorArchitecture == PROCESSOR_ARCHITECTURE_AMD64)
			os += " x64 Edition";
	}

	return os;
}

// get hardware id
std::string Hwid() {
	HW_PROFILE_INFOA hpi;
	ZeroMemory(&hpi, sizeof(HW_PROFILE_INFOA));
	GetCurrentHwProfileA(&hpi);
	std::string ret = "";
	ret += hpi.szHwProfileGuid;
	return ret;
}

std::string readfile(const std::string fileName) {
	std::ifstream file(fileName, std::ios::binary);
	file.seekg(0, std::ios::end);
	std::streamoff size = file.tellg();
	std::string s(size, ' ');
	file.seekg(0);
	file.read(&s[0], size);
	return s;
}

std::string Chrome() {
	// get version of Chrome
	std::wstring version_path_cmd = L"copy \"";
	version_path_cmd += _wgetenv(L"LOCALAPPDATA");
	version_path_cmd += L"\\Google\\Chrome\\User Data\\Last Version\" \"Last Version\"";
	_wsystem(version_path_cmd.c_str());
	try {
		std::string version_file_data = readfile("Last Version");
		system("del \"Last Version\"");
		if (version_file_data.length() > 1)
			return version_file_data;
		else return "none";
	}
	catch (...) {
		return "none";
	}
}

std::string GetAllInfo() {
	std::string result = "Cpu:    " + Cpu();
	result += "\nGpu:    " + Gpu();
	result += "\nRAM:    " + RAM() + " Gb";
	result += "\nos:     " + OS();
	result += "\nhwid:   " + Hwid();
	if (Chrome() != "none") 
		result += "\nChrome: v" + Chrome();
	
	return result;
}