using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Drawing;
using System.Threading;

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
        private Brush brush;
        private Chalk chalk;

        private const string NOMSG = "no message";
        private Color
            INFOCOLOR = Color.AntiqueWhite, // 提示文本颜色
            ERRORCOLOR = Color.OrangeRed, // 错误文本颜色
            OVERCOLOR = Color.DarkGray; // 结束符颜色

        private bool isPause = false; // 用来标记加载状态
        private Color LOADINGCOLOR = Color.AntiqueWhite; // 加载符颜色


        public BlackBoardController(RichTextBox blackboard)
        {
            this.brush = new Brush(blackboard);
            this.chalk = new Chalk(blackboard);
        }
        /// <summary>
        /// 打印普通消息
        /// </summary>
        /// <param name="message"></param>
        public void Info(string message)
        {
            string prefix = "";
            this.chalk.WriteToEndInvoke(GetFormatMessage(prefix, message), INFOCOLOR);
        }

        /// <summary>
        /// 打印错误消息
        /// </summary>
        /// <param name="message"></param>
        public void Error(string message)
        {
            string prefix = ""; // 为了对齐
            this.chalk.WriteToEndInvoke(GetFormatMessage(prefix, message), ERRORCOLOR);
        }

        /// <summary>
        /// 打印分隔符：---------------*-*-*-*-*-*-*---------------
        /// </summary>
        /// <param name="message"></param>
        public void Over(string message = "结束符！")
        {
            string prefix = ""; // 为了对齐
            StringBuilder sb = new StringBuilder();
            sb.Append(message);
            sb.Append("\n");
            sb.AppendLine("---------------*-*-*-*-*-*-*---------------");
            sb.AppendLine("OK！");
            this.chalk.WriteToEndInvoke(GetFormatMessage(prefix, sb.ToString()), OVERCOLOR);
        }

        /// <summary>
        /// 等待（带进度），如果达到1，将不再显示进度
        /// </summary>
        /// <param name="percent">百分比</param>
        public void Wait(string prefix, double percent)
        {
            string format = "0.00%"; int totalLength = 7;
            string output = percent.ToString(format).PadLeft(totalLength, ' ');

            if (false == isPause)
            {
                // 第一次，要打印被替换符，并标记为暂停
                this.chalk.WriteToEndInvoke(prefix + "".PadLeft(totalLength, '*'), LOADINGCOLOR);
                isPause = true;
            }

            if (percent >= 1)
            {
                // 进度100%后，暂停标记为false
                output += System.Environment.NewLine; // 必须在100%时，手动换行
                if (this.isPause) this.isPause = false;
            }

            this.chalk.WriteReplaceEndInvoke(output, totalLength, LOADINGCOLOR);
        }

        /// <summary>
        /// 加载中...显示|/--\|
        /// TODO：结束时，没有擦除最后的字符
        /// </summary>
        /// <param name="percent"></param>
        public void Pause()
        {
            if (this.isPause) return;

            string[] sequence;
            sequence = new string[] { ".", "-", "+", "^", "°", "*" };
            // new string[] { "×", "＋" };
            // new string[] { "↘", "↓", "↙", "←", "↖", "↑", "↗", "→" };
            // new string[] { " ","加","加载","加载中","加载中.","加载中.."... }

            int increment = 0, count = sequence.Length; bool isFirst = true;
            new Thread(new ThreadStart(() =>
            {
                while (isPause)
                {
                    if (increment >= count) { increment = 0; }

                    string prevWords = sequence[(increment - 1 < 0 ? count - 1 : increment - 1)];
                    if (!isFirst) this.brush.EraseEndInvoke(prevWords.Length);

                    this.chalk.WriteToEndInvoke(sequence[increment], LOADINGCOLOR);

                    increment++; isFirst = false;

                    Thread.Sleep(100);
                }
            })) { IsBackground = true }.Start(); ;

            this.isPause = true;
        }

        /// <summary>
        /// 停止加载
        /// </summary>
        public void Continue()
        {
            if (this.isPause) this.isPause = false;
        }

        /// <summary>
        /// 擦净黑板
        /// </summary>
        public void Clear()
        {
            this.brush.EraseAllInvoke();
        }

        #region 辅助函数

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
            str.AppendLine(string.Concat(prefix, GetTimeStamp(), message));
            return str.ToString();
        }

        #endregion 辅助函数



    }

    /// <summary>
    /// 粉笔
    /// </summary>
    internal class Chalk
    {
        private const long MAXSHOWCHARS = 200000;
        private RichTextBox blackboard;

        public Chalk(RichTextBox blackboard)
        {
            this.blackboard = blackboard;
        }

        /// <summary>
        /// 写字
        /// </summary>
        /// <param name="words"></param>
        /// <param name="color"></param>
        public void WriteToEndInvoke(string words, Color color)
        {
            if (this.blackboard.InvokeRequired)
            {
                this.blackboard.BeginInvoke(new ThreadStart(() =>
                {
                    this.WriteToEnd(words, color);
                }));
            }
            else
            {
                this.WriteToEnd(words, color);
            }
        }

        /// <summary>
        /// 替换后面的length个字符
        /// </summary>
        /// <param name="words"></param>
        /// <param name="length"></param>
        /// <param name="color"></param>
        public void WriteReplaceEndInvoke(string words, int length, Color color)
        {
            if (this.blackboard.InvokeRequired)
            {
                this.blackboard.BeginInvoke(new ThreadStart(() =>
                {
                    this.WriteReplaceEnd(words, length, color);
                }));
            }
            else
            {
                this.WriteReplaceEnd(words, length, color);
            }
        }

        /// <summary>
        /// 写字
        /// </summary>
        /// <param name="words"></param>
        /// <param name="color"></param>
        private void WriteToEnd(string words, Color color)
        {
            int startPos = this.blackboard.Text.Length;
            if (startPos >= MAXSHOWCHARS)
            {
                this.blackboard.Clear();
                startPos = 0;
            }
            
            this.blackboard.Select(startPos, 0);
            this.blackboard.SelectionColor = color;
            this.blackboard.AppendText(words);
            this.blackboard.HideSelection = false;
        }

        /// <summary>
        /// 替换后面的length个字符
        /// </summary>
        /// <param name="words"></param>
        /// <param name="length"></param>
        /// <param name="color"></param>
        private void WriteReplaceEnd(string words, int length, Color color)
        {
            int startPos = this.blackboard.Text.Length;
            this.blackboard.Select(startPos - length, length);
            this.blackboard.SelectionColor = color;
            this.blackboard.SelectedText = words;
            this.blackboard.HideSelection = false;
        }
    }

    /// <summary>
    /// 刷子
    /// </summary>
    internal class Brush
    {
        private RichTextBox blackboard;

        public Brush(RichTextBox blackboard)
        {
            this.blackboard = blackboard;
        }

        #region Invoke

        /// <summary>
        /// 擦干净
        /// </summary>
        public void EraseAllInvoke()
        {
            if (this.blackboard.InvokeRequired)
            {
                this.blackboard.BeginInvoke(new ThreadStart(() =>
                {
                    this.EraseAll();
                }));
            }
            else
            {
                this.EraseAll();
            }
        }

        /// <summary>
        /// 擦写指定位置的字符
        /// </summary>
        public void EraseInvoke(int start, int length)
        {
            if (this.blackboard.InvokeRequired)
            {
                this.blackboard.BeginInvoke(new ThreadStart(() =>
                {
                    Erase(start, length);
                }));
            }
            else
            {
                Erase(start, length);
            }
        }

        /// <summary>
        /// 擦写末尾的指定长度
        /// </summary>
        public void EraseEndInvoke(int length)
        {
            if (this.blackboard.InvokeRequired)
            {
                this.blackboard.BeginInvoke(new ThreadStart(() =>
                {
                    EraseEnd(length);
                }));
            }
            else
            {
                EraseEnd(length);
            }
        }

        #endregion EndInvoke


        /// <summary>
        /// 擦除
        /// </summary>
        /// <param name="start"></param>
        /// <param name="length"></param>
        private void Erase(int start, int length)
        {
            this.blackboard.Select(start, length);
            this.blackboard.SelectedText = "";
            this.blackboard.HideSelection = false;
        }

        /// <summary>
        /// 擦干净
        /// </summary>
        private void EraseAll()
        {
            this.blackboard.Clear();
        }

        /// <summary>
        /// 擦最后指定长度的字
        /// </summary>
        /// <param name="length"></param>
        private void EraseEnd(int length)
        {
            int startPos = this.blackboard.Text.Length;
            this.blackboard.Select(startPos - length, startPos);
            this.blackboard.SelectedText = "";
            this.blackboard.HideSelection = false;
        }
    }
}
