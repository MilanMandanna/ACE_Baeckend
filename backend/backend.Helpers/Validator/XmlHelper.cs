using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;
namespace backend.Helpers.Validator
{

    public static class XmlHelper
    {

        public static string getPartNumber(string URLString)
        {
            try
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(URLString);
                XmlNodeList nodeList = xmlDoc.GetElementsByTagName("asxiconfig");
                //XmlNodeList nodeList = xmlDoc.GetElementsByTagName("cfgver");
                XmlElement root = xmlDoc.DocumentElement;
                string partnumber = string.Empty;
                // Check to see if the element has a partnumber attribute.
                if (root.HasAttribute("partnumber"))
                {
                    partnumber = root.GetAttribute("partnumber");
                }
                return partnumber;
            }
            catch (Exception e)
            {
                throw new Exception("Exception at XmlHelper.getPartNumber() - "
                    + e.Message, e);
            }
        }
        public static string getMapPakageName(string URLString)
        {
            try
            {
                XmlDocument xmlDoc = new XmlDocument();
                string filecontents = string.Empty;
                using (StreamReader reader = new StreamReader(URLString))
                {
                    filecontents = reader.ReadToEnd();
                }
                xmlDoc.LoadXml(filecontents);
                XmlNodeList nodeList = xmlDoc.GetElementsByTagName("map_package");
                string configVersion = string.Empty;
                foreach (XmlNode node in nodeList)
                {
                    configVersion = node.InnerText;
                }
                return configVersion;
            }
            catch (Exception e)
            {
                throw new Exception("Exception at ConfigVersion.Open() - "
                    + e.Message, e);
            }
        }
        public static string  getConfigVersion(string URLString)
        {
            try
            {
                XmlDocument xmlDoc = new XmlDocument();
                string filecontents = string.Empty;
                using ( StreamReader reader = new StreamReader(URLString))
                {
                     filecontents = reader.ReadToEnd();
                }
                xmlDoc.LoadXml(filecontents);
                XmlNodeList nodeList = xmlDoc.GetElementsByTagName("cfgver");
                string configVersion = string.Empty;
                foreach (XmlNode node in nodeList)
                {
                    configVersion = node.InnerText;                   
                }
                return configVersion;
            }
            catch (Exception e)
            {
                throw new Exception("Exception at ConfigVersion.Open() - "
                    + e.Message, e);
            }
        }

        public static string Decompress(DirectoryInfo directoryPath)
        { 
                var path = "_Extracted";
                string extractPath = Regex.Replace(directoryPath + path, ".zip", "");
                ZipFile.ExtractToDirectory(directoryPath.FullName, extractPath);
                return extractPath;
        }

    }
}
