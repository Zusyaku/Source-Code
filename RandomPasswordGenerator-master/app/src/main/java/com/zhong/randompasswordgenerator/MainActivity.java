package com.zhong.randompasswordgenerator;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.CheckBox;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

//用于表示字符类型的枚举
enum CharType
{
    CK_NUMBERS,         //数字
    CK_CAPITAL,         //大写字母
    CK_LOWERCASE,       //小写字母
    CK_SPECIAL_CHAR       //特殊字符
}


public class MainActivity extends AppCompatActivity
{
    //私有的字段
    protected List m_option_check = new ArrayList();
    final String m_specialChar = "~!@#$%^&*()_-+={}[]|\\<>/?";   //特殊字符
    Random m_random = new Random();
    final int MAX_LENGTH = 128;

    //控件变量
    private CheckBox m_numbers_chk;
    private CheckBox m_capital_chk;
    private CheckBox m_lowercase_chk;
    private CheckBox m_special_chars_che;
    private EditText m_length_edit;
    private EditText m_result_edit;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        //将控件变量与控件ID关联
        m_numbers_chk = (CheckBox)findViewById(R.id.check_number);
        m_capital_chk = (CheckBox)findViewById(R.id.check_captal);
        m_lowercase_chk = (CheckBox)findViewById(R.id.check_lowercase);
        m_special_chars_che = (CheckBox)findViewById(R.id.check_specal_char);
        m_length_edit = (EditText)findViewById(R.id.edit_length);
        m_result_edit = (EditText)findViewById(R.id.editResult);
    }

    public void onClick(View view)
    {
        int id = view.getId();
        if(id==R.id.button_generate)
        {
            //获取复选框的选中状态
            m_option_check.clear();
            if(m_numbers_chk.isChecked())
                m_option_check.add(CharType.CK_NUMBERS);
            if(m_capital_chk.isChecked())
                m_option_check.add(CharType.CK_CAPITAL);
            if(m_lowercase_chk.isChecked())
                m_option_check.add(CharType.CK_LOWERCASE);
            if(m_special_chars_che.isChecked())
                m_option_check.add(CharType.CK_SPECIAL_CHAR);

            if(m_length_edit.getText().length()==0)
            {
                Toast.makeText(this, "请输入要生成的密码长度！", Toast.LENGTH_SHORT).show();
                return;
            }
            if(m_option_check.size()==0)
            {
                Toast.makeText(this, "请选择一种要包含的字符类型！", Toast.LENGTH_SHORT).show();
                return;
            }
            //获取密码的长度
            int length = 0;
            try
            {
                length = Integer.parseInt(m_length_edit.getText().toString());
            }
            catch (NumberFormatException e)
            {
                Toast.makeText(this, "你只能在“密码位数”文本框中输入数字！", Toast.LENGTH_SHORT).show();
                return;
            }
            if(length == 0)
            {
                Toast.makeText(this, "密码长度不能为0！", Toast.LENGTH_SHORT).show();
                return;
            }
            if(length>MAX_LENGTH)
            {
                Toast.makeText(this, String.format("密码的长度不能超过 %d！", MAX_LENGTH), Toast.LENGTH_SHORT).show();
                return;
            }
            String password = "";

            for (int i = 0; i< length; i++)
            {
                int index = m_random.nextInt(m_option_check.size());  //随机确定生成哪一种字符
                CharType charType = (CharType)m_option_check.get(index);
                char currentChar = '\0';
                switch(charType)
                {
                    case CK_NUMBERS:
                        currentChar = (char)(m_random.nextInt(10)+'0');    //随机生成一个0~9的数字
                        break;
                    case CK_CAPITAL:
                        currentChar = (char)(m_random.nextInt(26)+'A');    //随机生成一个大写字母
                        break;
                    case CK_LOWERCASE:
                        currentChar = (char)(m_random.nextInt(26)+'a');    //随机生成一个小写字母
                        break;
                    case CK_SPECIAL_CHAR:
                        int random = m_random.nextInt(m_specialChar.length());
                        currentChar = m_specialChar.charAt(random);     //随机生成一个特殊字符
                        break;
                }
                password += currentChar;
            }
            m_result_edit.setText(password);
        }
        else if(id == R.id.copy)
        {
            ClipboardManager myClipboard;
            myClipboard = (ClipboardManager)getSystemService(CLIPBOARD_SERVICE);
            ClipData myClip;
            String text = m_result_edit.getText().toString();
            myClip = ClipData.newPlainText("text", text);
            myClipboard.setPrimaryClip(myClip);
            Toast.makeText(this, "密码已经复制到剪贴板。", Toast.LENGTH_SHORT).show();
        }
    }
}
