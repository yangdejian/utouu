using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Drawing;

namespace DataServiceWinForm
{
    /// <summary>
    /// 报告板类
    /// INFO: Transparent
    /// Warning: Coral
    /// error: OrangeRed
    /// Parimary: Lime
    /// OVER: 同INFO
    /// </summary>
    public class BlackBoardController
    {
        private RichTextBox blackboard;
        private const string NOMSG = "no message";
        private Color INFOCOLOR = Color.AntiqueWhite, // 提示文本颜色
            ERRORCOLOR = Color.OrangeRed, // 错误文本颜色
            OVERCOLOR = Color.DarkGray; // 结束符颜色

        public BlackBoardController(RichTextBox blackboard)
        {
            this.blackboard = blackboard;
        }
        /// <summary>
        /// 打印普通消息
        /// </summary>
        /// <param name="message"></param>
        public void Info(string message)
        {
            string prefix = "【Info】";
            WriteToBoard(GetFormatMessage(prefix, message), INFOCOLOR);
        }

        /// <summary>
        /// 打印错误消息
        /// </summary>
        /// <param name="message"></param>
        public void Error(string message)
        {
            string prefix = "【Erro】"; // 为了对齐
            WriteToBoard(GetFormatMessage(prefix, message), ERRORCOLOR);
        }

        /// <summary>
        /// 打印分隔符：---------------*-*-*-*-*-*-*---------------
        /// </summary>
        /// <param name="message"></param>
        public void Over(string message = "结束符！")
        {
            string prefix = "【Over】"; // 为了对齐
            StringBuilder sb = new StringBuilder();
            sb.Append(message);
            sb.Append("\n");
            sb.AppendLine("---------------*-*-*-*-*-*-*---------------");
            sb.AppendLine("OK！");
            WriteToBoard(GetFormatMessage(prefix, sb.ToString()), OVERCOLOR);
        }
        /// <summary>
        /// 擦净黑板
        /// </summary>
        public void Clear()
        {
            this.blackboard.Clear();
        }

        #region 辅助函数

        /// <summary>
        /// 用指定颜色的粉笔，写到黑板上
        /// </summary>
        /// <param name="appendStr"></param>
        /// <param name="color"></param>
        private void WriteToBoard(string appendStr, Color color)
        {
            int startPos = this.blackboard.Text.Length;
            this.blackboard.Select(startPos, 0);
            this.blackboard.SelectionColor = color;
            this.blackboard.AppendText(appendStr);
            this.blackboard.ScrollToCaret();
        }

        /// <summary>
        /// 获取一个漂亮的时间戳
        /// </summary>
        /// <returns></returns>
        private string GetTimeStamp()
        {
            return String.Format("【{0}】", DateTime.Now.ToString("HH:mm:ss"));
        }

        /// <summary>
        /// 统一一下书写格式
        /// 返回的格式：前缀(arg1)+时间戳+内容(arg2)+换行符
        /// </summary>
        /// <param name="prefix"></param>
        /// <param name="message"></param>
        /// <returns></returns>
        private string GetFormatMessage(string prefix, string message)
        {
            if (message.Trim() == "") message = NOMSG;
            StringBuilder str = new StringBuilder();
            str.Append(prefix);
            str.Append(GetTimeStamp());
            str.Append(message.Trim() == string.Empty ? NOMSG : message);
            str.Append("\n");
            return str.ToString();
        }

        #endregion 辅助函数

    }
}
