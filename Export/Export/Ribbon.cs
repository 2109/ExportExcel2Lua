using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Office.Tools.Ribbon;
using System.Windows.Forms;
using Microsoft.Office.Interop.Excel;
using System.Diagnostics;
using Microsoft.Win32;
using Microsoft.Office.Core;

namespace Export
{
    public partial class Ribbon
    {
        private string GetRegisterValue(string key)
        {
            RegistryKey registerkey = Registry.LocalMachine;
            RegistryKey registerValue = registerkey.CreateSubKey("software\\export_lua");
            string value = registerValue.GetValue(key) as string;
            if (value == null || value.Length == 0)
                return null;
            return value;
        }

        private void SetRegisterValue(string key,string value)
        {
            RegistryKey registerkey = Registry.LocalMachine;
            RegistryKey registerValue = registerkey.CreateSubKey("software\\export_lua");
            registerValue.SetValue(key, value);
        }

        public void TestHandler(CommandBarButton Ctrl, ref bool CancelDefault)
        {
            MessageBox.Show("TestHandler");
        }

        private void Ribbon_Load(object sender, RibbonUIEventArgs e)
        {
            string exportPath = GetRegisterValue("export_path");
            if (exportPath == null)
            {
                label4.Label = "请先设置导出目录";
            }
            else
            {
                label4.Label = exportPath;
            }
            
            string parsePath = GetRegisterValue("parser_path");
            if (parsePath == null)
            {
                label1.Label = "请先设置解析目录";
            }
            else
            {
                label1.Label = parsePath;
            }

            string clientPath = GetRegisterValue("client_path");
            if (clientPath == null)
            {
                label2.Label = "请先设置前端导出目录";
            }
            else
            {
                label2.Label = clientPath;
            }

            string serverPath = GetRegisterValue("server_path");
            if (serverPath == null)
            {
                label3.Label = "请先设置后端导出目录";
            }
            else
            {
                label3.Label = serverPath;
            }

            button5.Label = "";
            button5.Enabled = false;
            button7.Label = "";
            button7.Enabled = false;
            label5.Label = "";
            label5.Enabled = false;
        }

        private string addQuote(string str)
        {
            StringBuilder builder = new StringBuilder();
            builder.Append("\"");
            foreach (char ch in str)
            {
                if (ch == '"' || ch == '\\')
                {
                    builder.Append('\\').Append(ch);
                }
                else if (ch == '\r')
                {
                    builder.Append('\\').Append('r');
                }
                else if (ch == '\n')
                {
                    builder.Append('\\').Append('n');
                }
                else if (ch == '\t')
                {
                    builder.Append('\\').Append('t');
                }
                else if (ch == '\0')
                {
                    builder.Append('\\').Append('0');
                }
                else
                {
                    builder.Append(ch);
                }
            }
            builder.Append("\"");
            return builder.ToString();
        }

        private string formatOutput(string value)
        {
            if (value.Length == 0)
            {
                return "nil";
            }
            return addQuote(value);
        }

        private void ParseClick(object sender, RibbonControlEventArgs e)
        {
            FolderBrowserDialog path = new FolderBrowserDialog();

            string oldPath = GetRegisterValue("parser_path");
            if (oldPath != null)
                path.SelectedPath = oldPath;
            path.ShowDialog();

            SetRegisterValue("parser_path", path.SelectedPath);

            label1.Label = path.SelectedPath;
        }

        private void ClientClick(object sender, RibbonControlEventArgs e)
        {
            FolderBrowserDialog path = new FolderBrowserDialog();

            string oldPath = GetRegisterValue("client_path");
            if (oldPath != null)
                path.SelectedPath = oldPath;
            path.ShowDialog();

            SetRegisterValue("client_path", path.SelectedPath);

            label2.Label = path.SelectedPath;
        }

        private void ServerClick(object sender, RibbonControlEventArgs e)
        {
            FolderBrowserDialog path = new FolderBrowserDialog();

            string oldPath = GetRegisterValue("server_path");
            if (oldPath != null)
                path.SelectedPath = oldPath;
            path.ShowDialog();

            SetRegisterValue("server_path", path.SelectedPath);

            label3.Label = path.SelectedPath;
        }

        private void ExportClick(object sender, RibbonControlEventArgs e)
        {
            string parsePath = GetRegisterValue("parser_path");
            if (parsePath == null)
            {
                MessageBox.Show("请先设置解析目录");
                return;
            }

            string exportPath = GetRegisterValue("export_path");
            if (exportPath == null)
            {
                MessageBox.Show("请先设置导出目录");
                return;
            }

            string clientPath = GetRegisterValue("client_path");
            if (clientPath == null)
            {
                MessageBox.Show("请先设置前端导出目录");
                return;
            }
            string serverPath = GetRegisterValue("server_path");
            if (serverPath == null)
            {
                MessageBox.Show("请先设置后端导出目录");
                return;
            }

            object o = System.Runtime.InteropServices.Marshal.GetActiveObject("Excel.Application");
            Microsoft.Office.Interop.Excel._Application app = o as Microsoft.Office.Interop.Excel._Application;
            Microsoft.Office.Interop.Excel.Workbook workBook = app.ActiveWorkbook;

            StringBuilder strBuilder = new StringBuilder();
            strBuilder.Append("\n{\n");
            for (int i = 1; i <= workBook.Sheets.Count; i++)
            {
                Microsoft.Office.Interop.Excel.Worksheet sheet = (Microsoft.Office.Interop.Excel.Worksheet)workBook.Sheets[i];

                int validCol = 0;
                for (int c = 1; c <= sheet.UsedRange.Columns.Count; c++)
                {
                    Range range = sheet.Cells[1, c];
                    if (range.Text.Length != 0)
                    {
                        validCol = c;
                    }
                    else
                    {
                        break;
                    }
                }

                int validRow = 0;
                for (int r = 1; r <= sheet.UsedRange.Rows.Count; r++)
                {
                    Range range = sheet.Cells[r, i];
                    if (range.Text.Length != 0)
                    {
                        validRow = r;
                    }
                    else
                    {
                        break;
                    }
                }

                strBuilder.AppendFormat("\t[{0}] = {{\n", formatOutput(sheet.Name));

                for (int c = 1; c <= validCol; c++)
                {
                    strBuilder.AppendFormat("\t\t[{0}] = {{\n", c);
                    for (int r = 1; r <= validRow; r++)
                    {
                        Range range = sheet.Cells[r, c];
                        strBuilder.AppendFormat("\t\t\t{0},\n", formatOutput(range.Text));
                    }

                    strBuilder.Append("\t\t},\n");
                }

                strBuilder.Append("\t},\n");
            }
            strBuilder.Append("}");


            string cmd = string.Format("{0}\\lua.exe", parsePath);

            try
            {
                ProcessStartInfo startInfo = new ProcessStartInfo(cmd, "export.lua");
                startInfo.UseShellExecute = false;
                startInfo.RedirectStandardInput = true;
                startInfo.RedirectStandardOutput = true;
                startInfo.RedirectStandardError = true;
                startInfo.WindowStyle = ProcessWindowStyle.Hidden;
                startInfo.CreateNoWindow = true;
                startInfo.WorkingDirectory = parsePath;

                Process process = new Process();
                process.StartInfo = startInfo;
                process.Start();

                process.StandardInput.WriteLine(exportPath);
                process.StandardInput.WriteLine(clientPath);
                process.StandardInput.WriteLine(serverPath);
                process.StandardInput.WriteLine(workBook.Name.Substring(0, workBook.Name.IndexOf('.')));
                process.StandardInput.Write(strBuilder.ToString());
                process.StandardInput.Close();

                string stdout = process.StandardOutput.ReadToEnd();
                string stderr = process.StandardError.ReadToEnd();

                process.WaitForExit();
                process.Close();

                if (stdout.Length != 0)
                {
                    MessageBox.Show(stdout);

                }
                if (stderr.Length != 0)
                {
                    MessageBox.Show(stderr, "错误提示");
                }
            }
            catch (Exception ex)
            {
                string err = string.Format("{0}请检查解析目录", ex.Message);
                MessageBox.Show(err, "错误提示", MessageBoxButtons.OK);
                return;
            }
        }

        private void ExportPathClick(object sender, RibbonControlEventArgs e)
        {
            FolderBrowserDialog path = new FolderBrowserDialog();

            string oldPath = GetRegisterValue("export_path");
            if (oldPath != null)
                path.SelectedPath = oldPath;
            path.ShowDialog();

            SetRegisterValue("export_path", path.SelectedPath);

            label4.Label = path.SelectedPath;
        }


        private void ExcelPathClick(object sender, RibbonControlEventArgs e)
        {
            FolderBrowserDialog path = new FolderBrowserDialog();

            string oldPath = GetRegisterValue("excel_path");
            if (oldPath != null)
                path.SelectedPath = oldPath;
            path.ShowDialog();

            SetRegisterValue("excel_path", path.SelectedPath);

            label5.Label = path.SelectedPath;
        }

        private void ExportAllClick(object sender, RibbonControlEventArgs e)
        {
            string parsePath = GetRegisterValue("parser_path");
            if (parsePath == null)
            {
                MessageBox.Show("请先设置解析目录");
                return;
            }

            string exportPath = GetRegisterValue("export_path");
            if (exportPath == null)
            {
                MessageBox.Show("请先设置导出目录");
                return;
            }

            string clientPath = GetRegisterValue("client_path");
            if (clientPath == null)
            {
                MessageBox.Show("请先设置前端导出目录");
                return;
            }
            string serverPath = GetRegisterValue("server_path");
            if (serverPath == null)
            {
                MessageBox.Show("请先设置后端导出目录");
                return;
            }

            object o = System.Runtime.InteropServices.Marshal.GetActiveObject("Excel.Application");
            Microsoft.Office.Interop.Excel._Application app = o as Microsoft.Office.Interop.Excel._Application;
            Microsoft.Office.Interop.Excel.Workbook workBook = app.ActiveWorkbook;

           
            string cmd = string.Format("{0}\\lua.exe", parsePath);

            try
            {
                ProcessStartInfo startInfo = new ProcessStartInfo(cmd, "main.lua");
                startInfo.UseShellExecute = false;
                startInfo.RedirectStandardInput = true;
                startInfo.RedirectStandardOutput = true;
                startInfo.RedirectStandardError = true;
                startInfo.WindowStyle = ProcessWindowStyle.Hidden;
                startInfo.CreateNoWindow = true;
                startInfo.WorkingDirectory = parsePath;

                Process process = new Process();
                process.StartInfo = startInfo;
                process.Start();

                process.StandardInput.WriteLine(exportPath);
                process.StandardInput.WriteLine(clientPath);
                process.StandardInput.WriteLine(serverPath);
                process.StandardInput.WriteLine(workBook.Name);
                process.StandardInput.WriteLine(workBook.Path);

                process.StandardInput.Close();

                string stdout = process.StandardOutput.ReadToEnd();
                string stderr = process.StandardError.ReadToEnd();

                process.WaitForExit();
                process.Close();

                if (stdout.Length != 0)
                {
                    MessageBox.Show(stdout);

                }
                if (stderr.Length != 0)
                {
                    MessageBox.Show(stderr, "错误提示");
                }
            }
            catch (Exception ex)
            {
                string err = string.Format("{0}请检查解析目录", ex.Message);
                MessageBox.Show(err, "错误提示", MessageBoxButtons.OK);
                return;
            }
        }
    }
}
