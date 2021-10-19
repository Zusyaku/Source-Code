#include "stdafx.h"
#include "ColorListCtrl.h"
#include "Common.h"
#include "ColorPicker.h"
#include "IniHelper.h"

IMPLEMENT_DYNAMIC(CColorListCtrl, CListCtrl)

CColorListCtrl::CColorListCtrl()
{
}


CColorListCtrl::~CColorListCtrl()
{
}

bool CColorListCtrl::AddColor(const std::wstring& name, COLORREF color)
{
    if (!IsColorExist(color))
    {
        Item item;
        item.name = name;
        item.color = color;
        m_colors.push_back(item);
        InsertItem(m_colors.size(), name.c_str());
        return true;
    }
    else
    {
        return false;
    }
}

bool CColorListCtrl::AddColor2(const std::wstring & name, COLORREF color)
{
    if (!IsColorExist(color, name))
    {
        Item item;
        item.name = name;
        item.color = color;
        m_colors.push_back(item);
        InsertItem(m_colors.size(), name.c_str());
        return true;
    }
    else
    {
        return false;
    }
}

bool CColorListCtrl::DeleteColor(int row)
{
    if (row >= 0 && row < static_cast<int>(m_colors.size()))
    {
        m_colors.erase(m_colors.begin() + row);
        DeleteItem(row);
    }
    return false;
}

void CColorListCtrl::DeleteColors(std::vector<int> rows)
{
	int size = static_cast<int>(rows.size());
	for (int i{}; i < size; i++)
	{
		DeleteColor(rows[i]);
		if (i <= size - 2 && rows[i + 1] > rows[i])
		{
			for (int j{ i + 1 }; j < size; j++)
				rows[j]--;
		}
	}

}

void CColorListCtrl::Edit(int row)
{
    EnsureVisible(row, FALSE);				//�༭һ��ʱȷ�����пɼ�
    m_editing = true;

    m_edit_row = row;
    CRect item_rect;
    GetSubItemRect(row, CLC_NAME, LVIR_LABEL, item_rect);	//ȡ������ľ���

    CString text = GetItemText(row, CLC_NAME);		//ȡ�����������

    m_item_edit.SetWindowText(text);		//�������������ʾ���༭����
    m_item_edit.ShowWindow(SW_SHOW);		//��ʾ�༭��
    m_item_edit.MoveWindow(item_rect);		//���༭���ƶ����������棬������������
    m_item_edit.SetFocus();					//ʹ�༭��ȡ�ý���
    m_item_edit.SetSel(0, -1);
}

int CColorListCtrl::GetColorNum() const
{
    return m_colors.size();
}

COLORREF CColorListCtrl::GetColor(int row) const
{
    if (row >= 0 && row < static_cast<int>(m_colors.size()))
        return m_colors[row].color;
    else
        return 0;
}

std::wstring CColorListCtrl::GetColorName(int row) const
{
    if (row >= 0 && row < static_cast<int>(m_colors.size()))
        return m_colors[row].name;
    else
        return std::wstring();
}

void CColorListCtrl::SaveColors(const wchar_t* path) const
{
    CIniHelper ini(path);
    ini.WriteInt(L"Color_table", L"color_num", m_colors.size());
    for (size_t i{}; i < m_colors.size(); i++)
    {
        wchar_t keyName[32];
        swprintf_s(keyName, L"color%d", static_cast<int>(i));
        ini.WriteInt(L"Color_table", keyName, m_colors[i].color);

        swprintf_s(keyName, L"name%d", static_cast<int>(i));
        ini.WriteString(L"Color_table", keyName, m_colors[i].name);

    }
    ini.Save();
}

void CColorListCtrl::LoadColors(const wchar_t* path)
{
    CIniHelper ini(path);
    int colorNum = ini.GetInt(L"Color_table", L"color_num", 0);
    for (int i{}; i < colorNum; i++)
    {
        wchar_t keyName[32];
        swprintf_s(keyName, L"color%d", i);
        int color = ini.GetInt(L"Color_table", keyName, 0);

        swprintf_s(keyName, L"name%d", i);
        std::wstring name = ini.GetString(L"Color_table", keyName, L"Error");

        AddColor(name, color);
    }
}


void CColorListCtrl::GetItemSelected(std::vector<int>& item_selected) const
{
	item_selected.clear();
	POSITION pos = GetFirstSelectedItemPosition();
	if (pos != NULL)
	{
		while (pos)
		{
			int nItem = GetNextSelectedItem(pos);
			item_selected.push_back(nItem);
		}
	}
}

BEGIN_MESSAGE_MAP(CColorListCtrl, CListCtrl)
    ON_NOTIFY_REFLECT(NM_CUSTOMDRAW, &CColorListCtrl::OnNMCustomdraw)
    ON_EN_KILLFOCUS(IDC_ITEM_EDITBOX, &CColorListCtrl::OnEnKillfocusEdit1)

    ON_NOTIFY_REFLECT(NM_DBLCLK, &CColorListCtrl::OnNMDblclk)
    ON_NOTIFY_REFLECT(LVN_BEGINSCROLL, &CColorListCtrl::OnLvnBeginScroll)
END_MESSAGE_MAP()


bool CColorListCtrl::IsColorExist(COLORREF color) const
{
    bool exist{ false };
    for (const auto& item : m_colors)
    {
        if (item.color == color)
        {
            exist = true;
            break;
        }
    }
    return exist;
}

bool CColorListCtrl::IsColorExist(COLORREF color, const std::wstring& name) const
{
    bool exist{ false };
    for (const auto& item : m_colors)
    {
        if (item.color == color && item.name == name)
        {
            exist = true;
            break;
        }
    }
    return exist;
}

void CColorListCtrl::EndEdit()
{
    if (m_editing)
    {
        if (m_edit_row >= 0 && m_edit_row < static_cast<int>(m_colors.size()))
        {
            CString str;
            m_item_edit.GetWindowText(str);	//ȡ�ñ༭�������
            SetItemText(m_edit_row, CLC_NAME, str);	//�������ݸ��µ�CListCtrl��
            m_colors[m_edit_row].name = str;
        }
        m_item_edit.ShowWindow(SW_HIDE);//���ر༭��
        m_editing = false;
    }
}

void CColorListCtrl::OnNMCustomdraw(NMHDR *pNMHDR, LRESULT *pResult)
{
    *pResult = CDRF_DODEFAULT;
    LPNMLVCUSTOMDRAW lplvdr = reinterpret_cast<LPNMLVCUSTOMDRAW>(pNMHDR);
    NMCUSTOMDRAW& nmcd = lplvdr->nmcd;
    switch (lplvdr->nmcd.dwDrawStage)	//�ж�״̬
    {
    case CDDS_PREPAINT:
        *pResult = CDRF_NOTIFYITEMDRAW;
        break;
    case CDDS_ITEMPREPAINT:
        if (nmcd.dwItemSpec >= 0 && nmcd.dwItemSpec < m_colors.size())
        {
            CDC* pDC = CDC::FromHandle(nmcd.hdc);		//��ȡ��ͼDC
            CRect item_rect, draw_rect;
            GetSubItemRect(nmcd.dwItemSpec, m_draw_color_row, LVIR_BOUNDS, item_rect);	//��ȡ��ͼ��Ԫ��ľ�������
            CCommon::SetDrawRect(pDC, item_rect);		//���û�ͼ����Ϊ��ǰ��
            draw_rect = item_rect;
            draw_rect.DeflateRect(item_rect.Height() / 6, item_rect.Height() / 6);
            pDC->FillSolidRect(draw_rect, m_colors[nmcd.dwItemSpec].color);

            //��ǰ�л�����ɺ󽫻�ͼ��������Ϊ��ߵ����򣬷�ֹ��ǰ�е����򱻸���
            CRect rect1{ item_rect };
            rect1.left = 0;
            rect1.right = item_rect.left;
            CCommon::SetDrawRect(pDC, rect1);
        }
        *pResult = CDRF_DODEFAULT;
        break;
    }
}


void CColorListCtrl::PreSubclassWindow()
{
    // TODO: �ڴ����ר�ô����/����û���
    SetExtendedStyle(LVS_EX_FULLROWSELECT | LVS_EDITLABELS);

    int width0, width1;
    CRect rect;
    GetWindowRect(rect);
    width0 = rect.Width() * 4 / 7;
    width1 = rect.Width() - width0 - theApp.DPI(21);

    InsertColumn(CLC_NAME, CCommon::LoadText(IDS_NAME), LVCFMT_LEFT, width0);		//�����1��
    InsertColumn(CLC_COLOR, CCommon::LoadText(IDS_COLOR), LVCFMT_LEFT, width1);		//�����2��

    m_item_edit.Create(WS_BORDER | ES_AUTOHSCROLL, CRect(), this, IDC_ITEM_EDITBOX);
    m_item_edit.SetFont(GetFont());

    CListCtrl::PreSubclassWindow();
}

void CColorListCtrl::OnEnKillfocusEdit1()
{
    //���ı��༭�ؼ��ؼ�ʧȥ����ʱ��Ӧ
    EndEdit();
}


void CColorListCtrl::OnNMDblclk(NMHDR *pNMHDR, LRESULT *pResult)
{
    LPNMITEMACTIVATE pNMItemActivate = reinterpret_cast<LPNMITEMACTIVATE>(pNMHDR);
    // TODO: �ڴ���ӿؼ�֪ͨ����������

    //˫����һ��ʱ�༭����
    if(pNMItemActivate->iSubItem == CLC_NAME)
        Edit(pNMItemActivate->iItem);

    int row = pNMItemActivate->iItem;
    if (pNMItemActivate->iSubItem == CLC_COLOR && (row >= 0 && row < static_cast<int>(m_colors.size())))
    {
        CWnd* pParent{ GetParent() };
        if (pParent != nullptr)
            pParent->SendMessage(WM_COLOR_DB_CLICKED, (WPARAM)GetColor(row));
    }

    *pResult = 0;
}


void CColorListCtrl::OnLvnBeginScroll(NMHDR *pNMHDR, LRESULT *pResult)
{
    // �˹���Ҫ�� Internet Explorer 5.5 ����߰汾��
    // ���� _WIN32_IE ������ >= 0x0560��
    LPNMLVSCROLL pStateChanged = reinterpret_cast<LPNMLVSCROLL>(pNMHDR);
    // TODO: �ڴ���ӿؼ�֪ͨ����������
    EndEdit();

    *pResult = 0;
}
