
// ColorPicker.h : PROJECT_NAME Ӧ�ó������ͷ�ļ�
//

#pragma once

#ifndef __AFXWIN_H__
	#error "�ڰ������ļ�֮ǰ������stdafx.h�������� PCH �ļ�"
#endif

#include "resource.h"		// ������
#include "Common.h"


// CColorPickerApp: 
// �йش����ʵ�֣������ ColorPicker.cpp
//

class CColorPickerApp : public CWinApp
{
public:
	CColorPickerApp();

	int DPI(int pixel);
	std::wstring GetModleDir() const { return m_modle_dir; }
	void InitThreadLanguage();

public:
	Language m_language;

public:
	void SaveConfig();

private:
	void LoadConfig();

// ��д
public:
	virtual BOOL InitInstance();

private:
	int m_dpi{ 96 };
	std::wstring m_modle_dir;

// ʵ��

	DECLARE_MESSAGE_MAP()
};

extern CColorPickerApp theApp;