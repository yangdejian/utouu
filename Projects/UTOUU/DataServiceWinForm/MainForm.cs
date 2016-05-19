using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Lib4Net;
using System.Threading;

namespace DataServiceWinForm
{
    public partial class MainForm : Form
    {
        private bool isUpdating = false;
        private string govDataFile = "";
        private string fields = "";
        private string FORMNAME = "UTOUU数据服务 ";
        private string LASTAYSNCTIME = "";

        private Lib4Net.DB.DataAccessProvider db;
        private BlackBoardController blackboard;
        
        public MainForm()
        {
            InitializeComponent();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            this.Text = FORMNAME;
            blackboard = new BlackBoardController(this.richTBResult);
            db = new Lib4Net.DB.DataAccessProvider();
            govDataFile = Lib4Net.Data.SettingHelper.GetData("govDataFile");
            fields = Lib4Net.IO.IniFile.Read(govDataFile, "Datas", "utCardID");

            blackboard.Info("数据键:" + fields);
            this.govsAsyncTimer.Start();
        }


        private void govsAsyncTimer_Tick(object sender, EventArgs e)
        {
            this.Text = FORMNAME + " " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");

            if (!isPrepareOk())
            {
                blackboard.Error("没有准备好,退出！");
                return;
            }

            new Thread(new ThreadStart(() =>
            {
                isUpdating = true;
                blackboard.Info("--------------------开始同步数据---------------------");

                List<string> lines = Lib4Net.IO.TxtFile.ReadAllLines(govDataFile,"GB2312");
                bool isCanLoad = false;
                
                int totalCount = 0;

                System.Data.DataTable dt = new System.Data.DataTable("uu_card_info");
                dt.Columns.Add("change");
                dt.Columns.Add("change_ratio");
                dt.Columns.Add("code");
                dt.Columns.Add("first_tradingday");
                dt.Columns.Add("ft_date");
                dt.Columns.Add("highest");
                dt.Columns.Add("card_id");
                dt.Columns.Add("ipo_time");
                dt.Columns.Add("lowest");
                dt.Columns.Add("name");
                dt.Columns.Add("pop_number");
                dt.Columns.Add("price");
                dt.Columns.Add("avg_bonus");
                dt.Columns.Add("trade_count");
                dt.Columns.Add("trade_price");
                dt.Columns.Add("zombie");
                dt.Columns.Add("last_update_Time");

                blackboard.Info("加载数据.........");
                for (int i = 0, len = lines.Count; i < len; i++)
                {
                    if (string.IsNullOrEmpty(lines[i])) continue;
                    if (lines[i].StartsWith("utCardID="))
                    {
                        isCanLoad = true;
                        continue;
                    }
                    if (isCanLoad)
                    {
                        totalCount++;
                        string line = lines[i];
                        string cardId = line.Substring(0, line.IndexOf("="));
                        string data = line.Substring(line.IndexOf("=") + 1);

                        string[] values = data.Split('|');
                        System.Data.DataRow dr = dt.NewRow();
                        for (int j = 0; j < values.Length; j++)
                        {
                            if (string.IsNullOrEmpty(values[j]))
                            {
                                dr[j] = 0;
                            }
                            else
                            {
                                dr[j] = values[j];
                            }
                        }
                        dt.Rows.Add(dr);
                    }
                }

                blackboard.Info("清空当前表.........");
                int clearTotalCount = clearAllCard();
                blackboard.Info("清空总数：" + clearTotalCount);

                blackboard.Info("批量插入..........");
                int insertTotalCount = db.NewBattchInsert(dt);
                blackboard.Info("导入总数：" + insertTotalCount);

                blackboard.Over();
                isUpdating = false;
                LASTAYSNCTIME = Lib4Net.IO.IniFile.Read(govDataFile, "UpdateSummary", "LastOverTime");

            })) { IsBackground = true }.Start();
        }

        private bool isPrepareOk()
        {
            string govDataLastUpdateTime = Lib4Net.IO.IniFile.Read(govDataFile, "UpdateSummary", "LastOverTime");
            if (govDataLastUpdateTime == LASTAYSNCTIME)
            {
                blackboard.Info("本地数据更新时间没有变化,无需更新！");
                return false;
            }
            if (string.IsNullOrEmpty(fields))
            {
                blackboard.Error("无法取到数据键！");
                return false;
            }
            if (isUpdating)
            {
                blackboard.Info("程序还在执行,再等等吧......");
                return false;
            }
            UpdateStatus updateStatus = (UpdateStatus)Int16.Parse(Lib4Net.IO.IniFile.Read(govDataFile, "UpdateSummary", "Status", "-1"));
            if (updateStatus != UpdateStatus.Success && updateStatus != UpdateStatus.Failure)
            {
                blackboard.Info("本地数据在自我更新,需要等它先完成......");
                return false;
            }
            return true;
        }



        private bool isCardExists(string cardId)
        {
            List<Lib4Net.DB.DbParameter> input = new List<Lib4Net.DB.DbParameter>();
            input.Add(new Lib4Net.DB.DbParameter(":card_id",cardId));
            object count = db.Scalar("select count(0) from uu_card_info where card_id=:card_id", input.ToArray());
            return Convert.ToInt16(count) > 0;
        }

        private int clearAllCard()
        {
            return db.Alter("delete from uu_card_info where 1=1");
        }

        private bool addCardInfo(string data)
        {
            string[] keys = (fields + ",last_update_Time").Split(',');
            string[] datas = data.Split('|');
            List<Lib4Net.DB.DbParameter> input = new List<Lib4Net.DB.DbParameter>();
            for (int i = 0, len = keys.Length; i < len; i++)
            {
                input.Add(new Lib4Net.DB.DbParameter("@" + keys[i], datas[i]));
            }
            try
            {
                db.Alter(@"insert into uu_card_info(
                    change,
                    change_ratio,
                    code,
                    first_tradingday,
                    ft_date,
                    highest,
                    card_id,
                    ipo_time,
                    lowest,
                    name,
                    pop_number,
                    price,
                    avg_bonus,
                    trade_count,
                    trade_price,
                    zombie,
                    last_update_Time)
                values(
	                @change,
	                @change_ratio,
	                @code,
	                @first_tradingday,
	                @ft_date,
	                @highest,
	                @id,
	                @ipo_time,
	                @lowest,
	                @name,
	                @people,
	                @price,
	                @stock_avg_bonus,
	                @trade_amount,
	                @trade_price,
	                @zombie,
	                @last_update_Time
                )", input.ToArray());
                return true;
            }
            catch (Exception ex)
            {
                blackboard.Error("数据插入失败:" + data);
                LoggerHelper.Main.Error("府数据添加失败", ex);
            }
            return false;
        }

        private bool updateCardInfo(string data)
        {
            string[] keys = (fields + ",last_update_Time").Split(',');
            string[] datas = data.Split('|');
            List<Lib4Net.DB.DbParameter> input = new List<Lib4Net.DB.DbParameter>();
            for (int i = 0, len = keys.Length; i < len; i++)
            {
                input.Add(new Lib4Net.DB.DbParameter("@" + keys[i], datas[i]));
            }
            try
            {
                int count = db.Alter(@"update uu_card_info set
	                change = @change,
	                change_ratio = @change_ratio,
	                ft_date = @ft_date,
	                highest = @highest,
	                lowest = @lowest,
	                name = @name,
	                pop_number = @people,
	                price = @price,
	                avg_bonus = @stock_avg_bonus,
	                trade_count = @trade_amount,
	                trade_price = @trade_price,
	                zombie = @zombie,
	                last_update_Time = @last_update_Time
                where card_id = @id", input.ToArray());
                return count == 1;
            }
            catch (Exception ex)
            {
                blackboard.Error("数据更新失败:" + data);
                LoggerHelper.Main.Error("府数据更新失败", ex);
            }
            return false;
        }

        private enum UpdateStatus
        { 
            Waiting = 20,
            Doing = 30,
            Success = 0,
            Failure = 90
        }

        private void toolStripButton1_Click(object sender, EventArgs e)
        {
            this.govsAsyncTimer.Stop();
            blackboard.Info("计时器被停止！");
        }

        private void toolStripMenuItem1_Click(object sender, EventArgs e)
        {
            this.govsAsyncTimer.Start();
            blackboard.Info("计时器被启动！");
        }

    }
}
