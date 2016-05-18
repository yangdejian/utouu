using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Lib4Net;

namespace DataServiceWinForm
{
    public class LoggerHelper
    {
        private static ILogger mainLogger = LoggerManager.Instance.GetLogger("Main");
        //private static ILogger otherLogger = LoggerManager.Instance.GetLogger("ORDER_REQUEST", "HttpApi");


        public static ILogger Main
        {
            get { return mainLogger; }
        }
    }
}
