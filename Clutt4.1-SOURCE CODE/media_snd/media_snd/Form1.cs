﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Media;
using System.Text;
using System.Windows.Forms;

namespace media_snd
{
    public partial class MEDIA : Form
    {

        private SoundPlayer cerror, ding, error, er10, ding10;

        public MEDIA()
        {
            InitializeComponent();
            TransparencyKey = BackColor;
            try
            {

                if (File.Exists(@"C:\Windows\Media\Windows Critical Stop.wav"))
                {
                    cerror = new SoundPlayer(@"C:\Windows\Media\Windows Critical Stop.wav");
                }
                if (File.Exists(@"C:\Windows\Media\Windows Ding.wav"))
                {
                    ding = new SoundPlayer(@"C:\Windows\Media\Windows Ding.wav");
                }
                if (File.Exists(@"C:\Windows\Media\Windows Error.wav"))
                {
                    error = new SoundPlayer(@"C:\Windows\Media\Windows Error.wav");
                }

                if (File.Exists(@"C:\Windows\Media\Windows Background.wav"))
                {
                    ding10 = new SoundPlayer(@"C:\Windows\Media\Windows Background.wav");
                }
                if (File.Exists(@"C:\Windows\Media\Windows Foreground.wav"))
                {
                    er10 = new SoundPlayer(@"C:\Windows\Media\Windows Foreground.wav");
                }
            }
            catch(Exception ex) { }
            
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            e.Cancel = true;
        }

        private void MEDIA_Load(object sender, EventArgs e)
        {
            random_snd.Start();
        }
        private void random_snd_Tick(object sender, EventArgs e)
        {
            random_snd.Stop();
            Random r;
            r = new Random();
            int rnd_snd = r.Next(4);
            int rnd_snd10 = r.Next(3);
            try
            {
                if (!File.Exists(@"C:\Windows\Media\Windows Background.wav") && !File.Exists(@"C:\Windows\Media\Windows Foreground.wav"))
                {

                    if (File.Exists(@"C:\Windows\Media\Windows Critical Stop.wav"))
                    {
                        if (rnd_snd == 1)
                        {
                            cerror.Play();
                        }
                    }
                    if (File.Exists(@"C:\Windows\Media\Windows Ding.wav"))
                    {
                        if (rnd_snd == 2)
                        {
                            ding.Play();
                        }
                    }
                    if (File.Exists(@"C:\Windows\Media\Windows Error.wav"))
                    {
                        if (rnd_snd == 3)
                        {
                            error.Play();
                        }
                    }
                }
                else
                {
                    if (File.Exists(@"C:\Windows\Media\Windows Background.wav"))
                    {
                        if (rnd_snd10 == 1)
                        {
                            ding10.Play();
                        }
                    }
                    if (File.Exists(@"C:\Windows\Media\Windows Foreground.wav"))
                    {
                        if (rnd_snd10 == 2)
                        {
                            er10.Play();
                        }
                    }
                }
                random_snd.Start();
            }
            catch (Exception ex) { }
        }
    }
}
