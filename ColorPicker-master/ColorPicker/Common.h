#pragma once
#include "CVariant.h"

//����
enum class Language
{
	FOLLOWING_SYSTEM,		//����ϵͳ
	ENGLISH,				//Ӣ��
	SIMPLIFIED_CHINESE		//��������
};

class CCommon
{
public:
	CCommon();
	~CCommon();

	//��const char*�ַ���ת���ɿ��ַ��ַ���
	static std::wstring StrToUnicode(const char* str, bool utf8 = false);

	static std::string UnicodeToStr(const wchar_t* wstr, bool utf8 = false);

	static void StringNormalize(std::wstring& str);

	static void SetDrawRect(CDC* pDC, CRect rect);

	//��һ���ַ������浽������
	static bool CopyStringToClipboard(const std::wstring& str);

    static COLORREF GetWindowsThemeColor();

	//����Դ�ļ������ַ��������У�front_str��back_strΪ�����ַ���ʱ��Ҫ��ǰ��������ӵ��ַ���
	static CString LoadText(UINT id, LPCTSTR back_str = nullptr);
	static CString LoadText(LPCTSTR front_str, UINT id, LPCTSTR back_str = nullptr);

	//��ȫ�ĸ�ʽ���ַ�������format_str������<%���%>���ַ����滻�ɳ�ʼ���б�paras�е�Ԫ�أ�Ԫ��֧��int/double/LPCTSTR/CString��ʽ����Ŵ�1��ʼ
	static CString StringFormat(LPCTSTR format_str, const std::initializer_list<CVariant>& paras);

	//����Դ�ļ��������ַ�����������Դ�ַ���������<%���%>���ַ����滻�ɿɱ�����б��еĲ���
	static CString LoadTextFormat(UINT id, const std::initializer_list<CVariant>& paras);

    //���ַ���ת�������֣�֧���Զ�ʶ��ʮ�����ơ��˽��ƺ�ʮ����
    static unsigned int StringToNumber(const CString& str);

};

