using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace TZ_Ccharp_T_SQL.Controller
{
    class HomeController
    {
        protected string StrTemp;
        private List<string> GetVs = new List<string>();
        public static string GetFile()
        {
            var openFileDialog = new OpenFileDialog
            {
                Filter = "XML files (*.xml)|*.xml"
            };
            ;
            if (openFileDialog.ShowDialog() == true)
                return Path.GetFullPath(openFileDialog.FileName);
            else return null;
        }

        public List<string> SearchRequest(string filePath, string text)
        {
            XmlDocument xDoc = new XmlDocument();
            xDoc.Load(filePath);
            XmlElement xRoot = xDoc.DocumentElement;

            XmlNodeList childnodes = xRoot.SelectNodes(text);
            foreach (XmlNode childnode in childnodes)
            {
                GetVs.Add(GetLevels(childnode));
                StrTemp = "";
            }
            return GetVs;
        }

        private string GetLevels(XmlNode childnode)
        {
            
            if (childnode.Attributes != null && childnode.Attributes.Count > 0)
            {
                for (int i = 0; i < childnode.Attributes.Count; i++)
                {
                    StrTemp+=$" {childnode.Attributes[i].Name}: {childnode.Attributes[i].Value},\n";
                }
                if (childnode.HasChildNodes)
                {
                    foreach (XmlNode xmlNode in childnode.ChildNodes)
                    {
                        GetLevels(xmlNode);
                    }
                }
                else
                {
                    StrTemp += $" {childnode.Name}: {childnode.InnerText}\n";
                }
            }
            else
            {
                if (childnode.HasChildNodes)
                {
                    foreach (XmlNode xmlNode in childnode.ChildNodes)
                    {
                        GetLevels(xmlNode);
                    }
                }
                else
                {
                    StrTemp += $" {childnode.ParentNode.Name}: {childnode.InnerText}\n";
                }
            }
            return StrTemp;
        }
    }
}
