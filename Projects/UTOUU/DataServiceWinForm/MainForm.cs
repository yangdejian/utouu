using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Lib4Net;

namespace DataServiceWinForm
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            BlackBoardController blackboard = new BlackBoardController(this.richTBResult);

            //Application.StartupPath
            //AppDomain.CurrentDomain.RelativeSearchPath
            //string provider = "System.Data.SQLite";
            //string connstr = @"Data Source=E:\sqlite3\test.db;Version=3;";
            Lib4Net.DB.DataAccessProvider db = new Lib4Net.DB.DataAccessProvider();

            object obj = db.BattchInsert(
            //LoggerHelper.Main.Info("这是日志测试");

            blackboard.Error("错误测试");
            blackboard.Info("提示测试");
            blackboard.Info(obj.ToString());
            //string id = Lib4Net.Data.SettingHelper.GetData("id");
            //LoggerHelper.Main.Error("测试Settings,ID:" + id);
        }


        private void govsAsyncTimer_Tick(object sender, EventArgs e)
        {

        }


    }
}
