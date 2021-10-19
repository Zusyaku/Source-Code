#pragma once
#include "afxcmn.h"

#define IDC_ITEM_EDITBOX 1991
#define WM_COLOR_DB_CLICKED (WM_USER + 1002)		//��˫����ɫ��ʱ�򸸴��ڷ��͵���Ϣ


enum ColorListColumn		//�б����
{
    CLC_NAME,
    CLC_COLOR,
    CLC_MAX
};

class CColorListCtrl :
    public CListCtrl
{
    DECLARE_DYNAMIC(CColorListCtrl)
public:
    CColorListCtrl();
    ~CColorListCtrl();

    void SetDrawColorRow(int row)
    {
        m_draw_color_row = row;    //����Ҫ������ɫ���У�ע����б���Ϊ���ұߵ��У����򣬴����ұߵ������н��޷���ʾ
    }
    bool AddColor(const std::wstring& name, COLORREF color);				//���һ����ɫ�������ɫ�Ѿ����ڣ������ʧ�ܣ�
    bool AddColor2(const std::wstring& name, COLORREF color);				//���һ����ɫ�������ɫ�Ѿ����ڣ������ʧ�ܣ�
    bool DeleteColor(int row);		//ɾ��ָ���е���ɫ
	void DeleteColors(std::vector<int> rows);				//ɾ�����е���ɫ

    void Edit(int row);			//�༭ָ���еĵ�һ��
    int GetColorNum() const;

    COLORREF GetColor(int row) const;
    std::wstring GetColorName(int row) const;

    void SaveColors(const wchar_t* path) const;
    void LoadColors(const wchar_t* path);

	void GetItemSelected(std::vector<int>& item_selected) const;

protected:
    struct Item
    {
        std::wstring name;
        COLORREF color;
    };

    int m_draw_color_row{};		//��Ҫ������ɫ����
    std::vector<Item> m_colors;	//���ڱ�ʾ�л��Ƶ���ɫ

    CEdit m_item_edit;
    int m_edit_row{};
    bool m_editing{};

protected:
    bool IsColorExist(COLORREF color) const;
    bool IsColorExist(COLORREF color, const std::wstring& name) const;
    void EndEdit();

    DECLARE_MESSAGE_MAP()
    afx_msg void OnNMCustomdraw(NMHDR *pNMHDR, LRESULT *pResult);
    virtual void PreSubclassWindow();
    afx_msg void OnEnKillfocusEdit1();

public:
    afx_msg void OnNMDblclk(NMHDR *pNMHDR, LRESULT *pResult);
    afx_msg void OnLvnBeginScroll(NMHDR *pNMHDR, LRESULT *pResult);
};

