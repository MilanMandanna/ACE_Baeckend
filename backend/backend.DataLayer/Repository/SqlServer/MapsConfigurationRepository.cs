using backend.DataLayer.Helpers;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Xml;

namespace backend.DataLayer.Repository.SqlServer
{
    public class MapsConfigurationRepository : Repository, IMapsConfigurationRepository
    {

        public MapsConfigurationRepository(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;
        }

        public MapsConfigurationRepository() { }

        public virtual async Task<Dictionary<string, object>> GetConfigurationFor(int configurationId, string section)
        {
            var command = CreateCommand("[dbo].[SP_Maps_GetConfigurations]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@section", section.ToLower()));
            return await SQLHelper.GetSQLResultsForCommand(command);
        }

        public virtual async Task<(int, string)> UpdateSectionData(int configurationId, string section, string name, string value)
        {
            try {
                string returnValue = string.Empty;
                var command = CreateCommand("[dbo].[SP_Maps_UpdateSectionData]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@section", section));
                command.Parameters.Add(new SqlParameter("@name", name));
                command.Parameters.Add(new SqlParameter("@inputvalue", value));
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    returnValue = DbHelper.StringFromDb(reader["message"].ToString());
                }
                reader.Close();
                if (returnValue.ToLower() == "success")
                    return (1, returnValue);
                else
                {
                    var tableName = "";
                    if (section.Equals("flyoveralerts"))
                    {
                        tableName = "flyoveralerts";
                    }
                    else if (section.Equals("tabnavigation") ||
                      section.Equals("extendedtabnavigation") ||
                      section.Equals("help") ||
                      section.Equals("worldguide"))
                    {
                        tableName = "webmain";

                    }
                    else if (section.Equals("separators"))
                    {
                        tableName = "global";

                    }
                    else if (section.Equals("trackline") ||
                    section.Equals("futuretrackline") ||
                    section.Equals("3dtrackline") ||
                    section.Equals("future3dtrackline") ||
                    section.Equals("destination") ||
                    section.Equals("departure") ||
                    section.Equals("departure/destination") ||
                    section.Equals("borders") ||
                    section.Equals("broadcastborders") ||
                    section.Equals("mapPackage"))
                    {
                        tableName = "maps";

                    }
                    XmlDocument document = new XmlDocument();
                    XmlNodeList node = null;

                    command = CreateCommand("[cust].[SP_GetXML]");
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                    command.Parameters.Add(new SqlParameter("@section", tableName));
                    using var xmlreader = await command.ExecuteReaderAsync();
                    while (await xmlreader.ReadAsync())
                    {
                        document.LoadXml(xmlreader["XMLValue"].ToString());
                    }
                    xmlreader.Close();
                    if (document.DocumentElement != null)
                    {
                        if (section.Equals("flyoveralerts"))
                        {
                            node = document.SelectNodes("flyoveralert");

                        }
                        if (section.Equals("tabnavigation"))
                        {
                            node = document.SelectNodes("webmain/tab_nav");

                        }
                        else if (section.Equals("extendedtabnavigation"))
                        {
                            if (name.Contains("color"))
                            {
                                node = document.SelectNodes("webmain/extended_tab_nav/map_pois");
                            }
                            else
                            {
                                node = document.SelectNodes("webmain/extended_tab_nav");
                            }

                        }
                        else if (section.Equals("help"))
                        {
                            node = document.SelectNodes("webmain");
                        }
                        else if (section.Equals("worldguide"))
                        {
                            node = document.SelectNodes("webmain/world_guide");
                        }
                        else if (section.Equals("seperators"))
                        {
                            node = document.SelectNodes("global/separators");
                        }
                        else if (section.Equals("trackline"))
                        {
                            node = document.SelectNodes("maps/trackline");
                        }
                        else if (section.Equals("futuretrackline"))
                        {
                            node = document.SelectNodes("maps/ftrackline");
                        }
                        else if (section.Equals("3dtrackline"))
                        {
                            node = document.SelectNodes("maps/trackline3d/past");
                        }
                        else if (section.Equals("future3dtrackline"))
                        {
                            node = document.SelectNodes("maps/trackline3d/future");
                        }
                        else if (section.Equals("departure"))
                        {
                            node = document.SelectNodes("maps/depart_marker");
                        }
                        else if (section.Equals("destination"))
                        {
                            node = document.SelectNodes("maps/dest_marker");
                        }
                        else if (section.Equals("borders"))
                        {
                            node = document.SelectNodes("maps/borders");
                        }
                        else if (section.Equals("broadcastborders"))
                        {
                            node = document.SelectNodes("maps/broadcast_borders");
                        }
                        else if (section.Equals("help"))
                        {
                            if(document.DocumentElement ==null)
                            {
                                string webmainNode = "<webmain><help_enabled>" + value + "</help_enabled><webmain>";
                                document.LoadXml(webmainNode);
                            }
                            XmlDocument doc = new XmlDocument();
                            var helpNode = "<help_enabled>" + value + "</help_enabled>";
                            doc.LoadXml(helpNode);
                            XmlNode insertNode = document.ImportNode(doc.DocumentElement, true);
                            document.DocumentElement.AppendChild(insertNode);
                        }
                        else if (section.Equals("mapPackage"))
                        {
                            node = document.SelectNodes("maps/map_package");
                        }

                        if (node.Count == 1)
                        {
                            if (section.Equals("mapPackage"))
                            {
                                if (value.ToLower() == "not selected")
                                    value = "";
                                ((XmlElement)node[0]).InnerText = value;
                            }
                            else
                            {
                                ((XmlElement)node[0]).SetAttribute(name, value);
                            }

                        }
                        else if (node.Count == 0)
                        {
                            XmlNode newNode = null;
                            XmlAttribute attribute = null;

                            if (section.Equals("borders"))
                            {
                                newNode = document.CreateNode("element", "borders", "");
                                attribute = document.CreateAttribute(name);
                                attribute.Value = value;
                                newNode.Attributes.Append(attribute);
                                string xmlNode = "<xml><type width=\"2.0\" color=\"FFAABE91\" name=\"Country\" id=\"1\"/>" +
                                "<type width=\"2.5\" color=\"FF888888\" name=\"State\" id=\"2\"/></xml>";
                                XmlDocument doc = new XmlDocument();
                                doc.LoadXml(xmlNode);
                                XmlNode insertNode = document.ImportNode(doc.DocumentElement.FirstChild, true);
                                newNode.AppendChild(insertNode);
                                insertNode = document.ImportNode(doc.DocumentElement.LastChild, true);
                                newNode.AppendChild(insertNode);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            else if (section.Equals("broadcastborders"))
                            {
                                newNode = document.CreateNode("element", "broadcast_borders", "");
                                attribute = document.CreateAttribute(name);
                                attribute.Value = value;
                                newNode.Attributes.Append(attribute);
                                string xmlNode = "<xml><type width=\"1\" color=\"FFAABE91\" name=\"Country\" id=\"1\"/>" +
                                    "<type width=\"1\" color=\"FF888888\" name=\"State\" id=\"2\"/></xml>";
                                XmlDocument doc = new XmlDocument();
                                doc.LoadXml(xmlNode);
                                XmlNode insertNode = document.ImportNode(doc.DocumentElement.FirstChild, true);
                                newNode.AppendChild(insertNode);
                                insertNode = document.ImportNode(doc.DocumentElement.LastChild, true);
                                newNode.AppendChild(insertNode);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            else if (section.Equals("flyoveralerts"))
                            {
                                attribute = document.CreateAttribute(name);
                                attribute.Value = value;
                                document.DocumentElement.Attributes.Append(attribute);
                            }
                            else if (section.Equals("trackline"))
                            {
                                newNode = document.CreateNode("element", "trackline", "");
                                attribute = document.CreateAttribute(name);
                                attribute.Value = value;
                                newNode.Attributes.Append(attribute);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            else if (section.Equals("futuretrackline"))
                            {
                                newNode = document.CreateNode("element", "ftrackline", "");
                                attribute = document.CreateAttribute(name);
                                attribute.Value = value;
                                newNode.Attributes.Append(attribute);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            else if (section.Equals("3dtrackline"))
                            {
                                XmlNode past = null;
                                newNode = document.CreateElement("element", "trackline3d", "");
                                past = document.CreateElement("element", "past", "");
                                attribute = document.CreateAttribute(name);
                                attribute.Value = value;
                                past.Attributes.Append(attribute);
                                newNode.AppendChild(past);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            else if (section.Equals("future3dtrackline"))
                            {
                                XmlNode future = null;
                                newNode = document.CreateElement("element", "trackline3d", "");
                                future = document.CreateElement("element", "future", "");
                                attribute = document.CreateAttribute(name);
                                attribute.Value = value;
                                future.Attributes.Append(attribute);
                                newNode.AppendChild(future);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            else if (section.Equals("departure"))
                            {
                                newNode = document.CreateNode("element", "depart_marker", "");
                                attribute = document.CreateAttribute(name);
                                attribute.Value = value;
                                newNode.Attributes.Append(attribute);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            else if (section.Equals("destination"))
                            {
                                newNode = document.CreateNode("element", "dest_marker", "");
                                attribute = document.CreateAttribute(name);
                                attribute.Value = value;
                                newNode.Attributes.Append(attribute);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            else if (section.Equals("tabnavigation"))
                            {
                                newNode = document.CreateNode("element", "tab_nav", "");
                                attribute = document.CreateAttribute(name);
                                attribute.Value = value;
                                newNode.Attributes.Append(attribute);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            else if (section.Equals("extendedtabnavigation"))
                            {
                                if (name.Contains("color"))
                                {
                                    XmlNode map_pois = null;
                                    newNode = document.CreateElement("element", "extended_tab_nav", "");
                                    map_pois = document.CreateElement("element", "map_pois", "");
                                    attribute = document.CreateAttribute(name);
                                    attribute.Value = value;
                                    map_pois.Attributes.Append(attribute);
                                    newNode.AppendChild(map_pois);
                                    document.DocumentElement.AppendChild(newNode);
                                }
                                else
                                {
                                    newNode = document.CreateNode("element", "extended_tab_nav", "");
                                    attribute = document.CreateAttribute(name);
                                    attribute.Value = value;
                                    newNode.Attributes.Append(attribute);
                                    document.DocumentElement.AppendChild(newNode);
                                }
                            }
                            else if(section.Equals("worldguide"))
                            {
                                newNode = document.CreateNode("element", "world_guide", "");
                                attribute = document.CreateAttribute(name);
                                attribute.Value = value;
                                newNode.Attributes.Append(attribute);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            else if (section.Equals("mapPackage"))
                            {
                                if (value.ToLower() == "not selected")
                                    value = "";
                                newNode = document.CreateElement("element", "map_package", "");
                                newNode.Value = value;
                            }
                        }
                    }
                    else
                    {
                        string xml = string.Empty;
                        if (section.Equals("flyoveralerts"))
                        {
                            xml = "<flyover_alert " + name + "=\"" + value + "\"/>";
                        }
                        if (section.Equals("tabnavigation"))
                        {
                            xml = "<webmain><tab_nav " + name + "=\"" + value + "\"/></webmain>";

                        }
                        else if (section.Equals("extendedtabnavigation"))
                        {
                            if (name.Contains("color"))
                            {
                                xml = "<webmain><extended_tab_nav><map_pois " + name + "=\"" + value + "\"></map_pois></extended_tab_nav></webmain>";
                            }
                            else
                            {
                                xml = "<webmain><extended_tab_nav " + name + "=\"" + value + "\"></extended_tab_nav></webmain>";
                            }
                        }
                        else if (section.Equals("trackline"))
                        {
                            xml = "<maps><trackline " + name + "=\"" + value + "\"/></maps>";
                        }
                        else if (section.Equals("futuretrackline"))
                        {
                            xml = "<maps><ftrackline " + name + "=\"" + value + "\"/></maps>";
                        }
                        else if (section.Equals("3dtrackline"))
                        {
                            xml = "<maps><trackline3d><past " + name + "=\"" + value + "\"/></trackline3d></maps>";
                        }
                        else if (section.Equals("future3dtrackline"))
                        {
                            xml = "<maps><trackline3d><future " + name + "=\"" + value + "\"/></trackline3d></maps>";
                        }
                        else if (section.Equals("departure"))
                        {
                            xml = "<maps><depart_marker " + name + "=\"" + value + "\"/></maps>";
                        }
                        else if (section.Equals("destination"))
                        {
                            xml = "<maps><dest_marker " + name + "=\"" + value + "\"/></maps>";
                        }
                        else if (section.Equals("borders"))
                        {
                            xml = "<maps><borders " + name + "=\"" + value + "\">" +
                                "<type width=\"2.0\" color=\"FFAABE91\" name=\"Country\" id=\"1\" />" +
                                "<type width=\"2.5\" color=\"FF888888\" name=\"State\" id=\"2\" />" +
                                "</borders></maps>";
                        }
                        else if (section.Equals("broadcastborders"))
                        {
                            xml = "<maps><broadcast_borders " + name + "=\"" + value + "\">" +
                                "<type width=\"1\" color=\"FFAABE91\" name=\"Country\" id=\"1\" />" +
                                "<type width=\"1\" color=\"FF888888\" name=\"State\" id=\"2\"/>" +
                                "</broadcast_borders></maps>";
                        }
                        else if(section.Equals("help"))
                        {
                            xml = "<webmain><help_enabled>" + value + "</help_enabled></webmain>";
                        }
                        else if(section.Equals("world_guide"))
                        {
                            xml = "<webmain><world_guide>" + value + "</world_guide></webmain>";
                        }
                        else if (section.Equals("mapPackage"))
                        {
                            if (value.ToLower() == "not selected")
                                value = "";
                            xml = "<maps><map_package>" + value + "</map_package></maps>";
                        }
                        document.LoadXml(xml);
                    }

                    var updatecommand = CreateCommand("[cust].[SP_UpdateXML]");
                    updatecommand.CommandType = CommandType.StoredProcedure;
                    updatecommand.Parameters.AddWithValue("@configurationId", configurationId);
                    updatecommand.Parameters.Add(new SqlParameter("@section", tableName));
                    updatecommand.Parameters.Add("@xmlValue", SqlDbType.Xml).Value = document.OuterXml.ToString();

                    var result = await updatecommand.ExecuteNonQueryAsync();

                    if (result > 0)
                    {
                        return (1, "success");

                    }
                    return (0, "Error Adding " + name + " attribute in " + section);
                }
            }
         catch (Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<IEnumerable<Layer>> GetLayers(int configurationId)
        {
            IEnumerable<Layer> layerArray;
            var command = CreateCommand("[dbo].[SP_Maps_GetLayers]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@type", "layers"));
            using (var reader = await command.ExecuteReaderAsync())
            {
                 layerArray =  await DatabaseMapper.Instance.FromReaderAsync<Layer>(reader);
            }


            var names = "";
            var displayNames = "";
            command = CreateCommand("[dbo].[SP_Maps_GetLayers]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@type", "all"));

            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    names = reader.GetString(0);
                    displayNames = reader.GetString(1);
                }
            }
            string[] layerNames = names.Split(',');
            string[] layerDisplayNames = displayNames.Split(',');
            var parameters = layerNames.Zip(layerDisplayNames, (namesArray, displaynamesArray) => new { Name = namesArray, displayName = displaynamesArray });
            foreach (var layer in layerArray)
            {
                var parameter = parameters.Where(x => x.Name == layer.Name);
                layer.DisplayName = parameter.First().displayName;
            }
            List<Layer> layers = new List<Layer>();
            layers.AddRange(layerArray);
            foreach(var parameter in parameters)
            {
                var layer = layerArray.Where(x => x.Name == parameter.Name);
                if(layer.Count() == 0)
                {
                    layers.Add(new Layer { Name = parameter.Name, DisplayName = parameter.displayName, Active = "false", Enabled = "false" });
                }
            }
            return layers.AsEnumerable();

        }

        public virtual async Task<int> UpdateLayer(int configurationId, Layer layeData)
        {
        

            XmlDocument document = new XmlDocument();
            XmlNodeList layerNode = null;
            var result = 0;

            try
            {
                var command = CreateCommand("[cust].[SP_GetXML]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@section", "layers"));
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    if (!string.IsNullOrWhiteSpace(reader["XMLValue"].ToString()))
                        document.LoadXml(reader["XMLValue"].ToString());
                }
                reader.Close();
                if (document != null && document.DocumentElement != null)
                {
                    layerNode = document.SelectNodes("category/item[@name = '" + layeData.Name + "']");
                    if (layerNode.Count == 1)
                    {

                        ((XmlElement)layerNode[0]).SetAttribute("active", layeData.Active);

                        ((XmlElement)layerNode[0]).SetAttribute("enable", layeData.Enabled);

                    }
                    else
                    {
                        string node = "<category name=\"layers\"><item name=" + "\"" + layeData.Name.Trim() + "\"" + " enable = " + "\"" + layeData.Enabled + "\"" + " active= " + "\"" + layeData.Active + "\"" + "/></category>";
                        XmlDocument doc = new XmlDocument();
                        doc.LoadXml(node);
                        XmlNode importNode = document.ImportNode(doc.DocumentElement.FirstChild, true);
                        document.DocumentElement.AppendChild(importNode);
                    }
                }
                else
                {
                    string node = "<category name=\"layers\"><item name=" + "\"" + layeData.Name.Trim() + "\"" + " enable = " + "\"" + layeData.Enabled + "\"" + " active= " + "\"" + layeData.Active + "\"" + "/></category>";
                    document.LoadXml(node);
                }
                
                var updatecommand = CreateCommand("[cust].[SP_UpdateXML]");
                updatecommand.CommandType = CommandType.StoredProcedure;
                updatecommand.Parameters.AddWithValue("@configurationId", configurationId);
                updatecommand.Parameters.AddWithValue("@section", "layers");
                updatecommand.Parameters.Add("@xmlValue", SqlDbType.Xml).Value = document.OuterXml.ToString();

                result = await updatecommand.ExecuteNonQueryAsync();

            }
            catch (Exception ex)
            {
                throw ex;
            }

            if (result > 0 )
            {
                return 1;
            }
            return 0;

        }
        public virtual async Task<bool> GetProductLevelConfigDetails(int configurationId)
        {
            bool isProductConfig = false;
            try
            {
                var command = CreateCommand("[dbo].[SP_Maps_GetProductLevelConfigDetails]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    isProductConfig = DbHelper.BoolFromDb(reader["isProductConfig"]);
                }
                return isProductConfig;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            

        }
    }
}
