#pragma once
class CColorConvert
{
public:
	CColorConvert();
	~CColorConvert();

	static unsigned int RGB2Hex(unsigned char R, unsigned char G, unsigned char B);	//RGBֵת������ɫʮ������ֵ
	static unsigned char Hex2R(unsigned int hex);	//����ɫʮ�����ƻ�ȡRGB�еĺ�ɫֵ
	static unsigned char Hex2G(unsigned int hex);	//����ɫʮ�����ƻ�ȡRGB�е���ɫֵ
	static unsigned char Hex2B(unsigned int hex);	//����ɫʮ�����ƻ�ȡRGB�е���ɫֵ

};

