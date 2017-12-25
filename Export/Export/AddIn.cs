using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using Excel = Microsoft.Office.Interop.Excel;
using Office = Microsoft.Office.Core;
using Microsoft.Office.Tools.Excel;
using System.Windows.Forms;

namespace Export
{
    public partial class AddIn
    {
        void btnCalc_Click(Microsoft.Office.Core.CommandBarButton Ctrl, ref bool CancelDefault)
        {
            object o = System.Runtime.InteropServices.Marshal.GetActiveObject("Excel.Application");
            Microsoft.Office.Interop.Excel._Application app = o as Microsoft.Office.Interop.Excel._Application;
            Microsoft.Office.Interop.Excel.Workbook workBook = app.ActiveWorkbook;
            ValiedateDialog dialog = new ValiedateDialog();
            dialog.Show();
        }

        private void AddIn_Startup(object sender, System.EventArgs e)
        {

            Microsoft.Office.Core.CommandBar cmdBar = Application.CommandBars["cell"];
            Microsoft.Office.Core.CommandBarControl comCtrl = cmdBar.Controls.Add(Microsoft.Office.Core.MsoControlType.msoControlButton, Type.Missing, Type.Missing, Type.Missing, true);
            Microsoft.Office.Core.CommandBarButton comButton = comCtrl as Microsoft.Office.Core.CommandBarButton;
            comButton.Tag = "Validate";
            comButton.Caption = "校验列";
            comButton.Style = Microsoft.Office.Core.MsoButtonStyle.msoButtonIcon;
            comButton.Click += new Microsoft.Office.Core._CommandBarButtonEvents_ClickEventHandler(btnCalc_Click);

        }

        private void AddIn_Shutdown(object sender, System.EventArgs e)
        {
        }

        #region VSTO 生成的代码

        /// <summary>
        /// 设计器支持所需的方法 - 不要
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InternalStartup()
        {
            this.Startup += new System.EventHandler(AddIn_Startup);
            this.Shutdown += new System.EventHandler(AddIn_Shutdown);
        }
 
        #endregion
    }
}
