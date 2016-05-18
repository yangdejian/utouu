using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;

namespace DataServiceWinForm
{
    /// <summary>
    /// 数据服务桌面程序
    /// </summary>
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            try
            {
                //设置应用程序处理异常方式：ThreadException处理
                Application.SetUnhandledExceptionMode(UnhandledExceptionMode.CatchException);
                //处理UI线程异常
                Application.ThreadException += new System.Threading.ThreadExceptionEventHandler(Application_ThreadException);
                //处理非UI线程异常
                AppDomain.CurrentDomain.UnhandledException += new UnhandledExceptionEventHandler(CurrentDomain_UnhandledException);

                #region 应用程序的主入口点
                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);
                Application.Run(new MainForm());
                #endregion
            }
            catch (Exception ex)
            {
                ShowError(ex);
            }
        }

        static void Application_ThreadException(object sender, System.Threading.ThreadExceptionEventArgs e)
        {
            ShowError(e.Exception, e.ToString());
        }

        static void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            ShowError(e.ExceptionObject as Exception, e.ToString());
        }

        /// <summary>
        /// 辅助：把错误信息show出来并记录在日志中
        /// </summary>
        /// <param name="ex"></param>
        /// <param name="description"></param>
        static void ShowError(Exception ex, string description = "")
        {
            LoggerHelper.Main.Fatal(description, ex);
        }
    }
}
