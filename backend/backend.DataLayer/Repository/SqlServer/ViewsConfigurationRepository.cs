using backend.DataLayer.Helpers;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Xml;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Repository.SqlServer
{
    public class ViewsConfigurationRepository : SimpleRepository<Configuration>, IViewConfigurationReposiory
    {
        public ViewsConfigurationRepository()
        {

        }
        public ViewsConfigurationRepository(SqlConnection context, SqlTransaction transaction) :
           base(context, transaction)
        { }

        #region Public Methods

        #region Views
        /// <summary>
        /// 1. To get all the view from the table
        /// 2. Input is configuration ID
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<ConfigurationViewDTO> GetAllViewDetails(int configurationId, string type)
        {
            ConfigurationViewDTO viewDetails = new ConfigurationViewDTO();
            viewDetails.ConfigurationData = new List<Views>();
            var command = CreateCommand("[dbo].[SP_Views_GetAllViewDetails]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@type", type));

            try
            {
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    Views viewData = new Views();
                    viewData.Name = reader.GetString(0);
                    viewData.Preset = Convert.ToBoolean(reader.GetString(1));
                    viewDetails.ConfigurationData.Add(viewData);
                }
                reader.Close();
            }
            catch(Exception ex)
            {
                throw ex;
            }
            return viewDetails;
        }

        /// <summary>
        /// 1. Update quick select value for selected view
        /// 2. Preset can be set max for 3 views
        /// 3. If max preset is reached error will be shown
        /// 4. If not preset will be updated
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="viewName"></param>
        /// <param name="updatedValue"></param>
        /// <returns></returns>
        public virtual async Task<int> UpdateSelectedView(int configurationId, string viewName, string updatedValue)
        {
            int returnValue = 0;
            try
            {
                var command = CreateCommand("[dbo].[SP_Views_UpdateSelectedView]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@viewName", viewName));
                command.Parameters.Add(new SqlParameter("@updateValue", updatedValue));

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    returnValue = reader.GetInt32(0);
                }

            }
            catch (Exception ex)
            {
                throw ex;
            }
            return returnValue;
        }

        /// <summary>
        /// 1. To delete selected view
        /// 2. Enable status of the view will be updated to false
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="viewName"></param>
        /// <returns></returns>
        public virtual async Task<int> DisableSelectedView(int configurationId, string viewName)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_Views_DisableSelectedView]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@viewName", viewName));
                command.Parameters.Add(new SqlParameter("@updateValue", "false"));
                return await command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// Add new view or updated view to enable true
        /// 1. If no view with given name is available, new view will be added
        /// 2. If a view with given name exists and if view is enable status is false, then enable status will be updated to true
        /// 3. If given view's enable status is true, then it will not be updated
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="views"></param>
        /// <returns></returns>
        public virtual async Task<int> AddSelectedView(int configurationId, List<string> views)
        {
            XmlDocument document = new XmlDocument();

            var command = CreateCommand("[dbo].[SP_AddNewConfigurationView]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@ConfigurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@type", "get"));
            try
            {
                using var reader = await command.ExecuteReaderAsync();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        if (reader["Perspective"] != DBNull.Value)
                        {
                            document.LoadXml(reader["perspective"].ToString());
                        }
                    }
                }
                reader.Close();

                if (document.DocumentElement == null)
                {
                    string parentNode = "<category name=\"perspectives\"></category>";
                    document.LoadXml(parentNode);
                }

                views.ForEach(view =>
                {
                    XmlNode newNode = null;
                    XmlAttribute enableAttribute = null;
                    XmlAttribute labelAttribute = null;
                    XmlAttribute nameAttribute = null;
                    XmlAttribute presetAttribute = null;

                    newNode = document.CreateNode("element", "item", "");
                    
                    enableAttribute = document.CreateAttribute("enable");
                    enableAttribute.Value = "true";

                    labelAttribute = document.CreateAttribute("label");
                    labelAttribute.Value = view;

                    nameAttribute = document.CreateAttribute("name");
                    nameAttribute.Value = view.ToLower();

                    presetAttribute = document.CreateAttribute("quick_select");
                    presetAttribute.Value = "false";

                    newNode.Attributes.Append(enableAttribute);
                    newNode.Attributes.Append(labelAttribute);
                    newNode.Attributes.Append(nameAttribute);
                    newNode.Attributes.Append(presetAttribute);

                    document.DocumentElement.AppendChild(newNode);
                });

                var updateCommand = CreateCommand("[dbo].[SP_AddNewConfigurationView]");
                updateCommand.CommandType = CommandType.StoredProcedure;
                updateCommand.Parameters.Add(new SqlParameter("@ConfigurationId", configurationId));
                updateCommand.Parameters.Add(new SqlParameter("@type", "update"));
                updateCommand.Parameters.Add("@xml", SqlDbType.Xml).Value = document.OuterXml.ToString();

                return await updateCommand.ExecuteNonQueryAsync();
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// 1. Move selected view to new position
        /// 2. If position is less than 0, move to top position
        /// 3. If position is greater than available view, move to last position
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="viewName"></param>
        /// <param name="positionNumber"></param>
        /// <returns></returns>
        public virtual async Task<int> MoveSelectedView(int configurationId, string viewName, int oldPositionNumber, int newPositionNumber)
        {
            XmlDocument document = new XmlDocument();
            int returnValue = 0;
            XmlNode xNode = null;
            XmlNodeList allNodeList;
            XmlNodeList enabledNodes;
            try
            {
                var command = CreateCommand("[dbo].[SP_Views_MoveSelectedView]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@type", "get"));
                
                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (reader.Read())
                    {
                        document.LoadXml(reader["xmlData"].ToString());
                    }
                }

                if (document != null)
                {
                    allNodeList = document.SelectNodes("/category/item");
                    enabledNodes = document.SelectNodes("/category/ item[@enable = 'true']");

                    if (document.SelectSingleNode("/category/item[@label='" + viewName + "' and @enable = 'true']") != null)
                    {
                        xNode = document.SelectSingleNode("/category/item[@label='" + viewName + "' and @enable = 'true']");
                    }
                    if (xNode == null)
                    {
                        returnValue = 2;
                    }
                    else if (xNode != null)
                    {
                        if (newPositionNumber <= 0)
                        {
                            xNode.ParentNode.RemoveChild(xNode);
                            document.DocumentElement.InsertBefore(xNode, document.DocumentElement.FirstChild);
                        }
                        else
                        {
                            XmlNode updateNode;
                            if (oldPositionNumber > newPositionNumber)
                            {
                                updateNode = enabledNodes[newPositionNumber];
                                xNode.ParentNode.RemoveChild(xNode);
                                document.DocumentElement.InsertBefore(xNode, updateNode);
                            }
                            else if (oldPositionNumber < newPositionNumber)
                            {
                                updateNode = enabledNodes[newPositionNumber];
                                xNode.ParentNode.RemoveChild(xNode);
                                document.DocumentElement.InsertAfter(xNode, updateNode);
                            }
                        }
                        var updateCommand = CreateCommand("[dbo].[SP_Views_MoveSelectedView]");
                        updateCommand.CommandType = CommandType.StoredProcedure;
                        updateCommand.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                        updateCommand.Parameters.Add(new SqlParameter("@type", "update"));
                        updateCommand.Parameters.Add("@xmlValue", SqlDbType.Xml).Value = document.OuterXml.ToString();
                        returnValue = await updateCommand.ExecuteNonQueryAsync();
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return returnValue;
        }
        #endregion

        #region Get Locations for View
        /// <summary>
        /// 1. To get list of cities available for the given config ID
        /// 2. Three default values will be there in the list
        /// 3. The values are Departure, Destination and Current location
        /// 4. After deafults other values will follow.
        /// 5. This API will return values for Compass, Timezone and Worldclock
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<ConfigAvailableLocationsDTO> GetLocationsForViewType(int configurationId, string type)
        {
            ConfigAvailableLocationsDTO cities = new ConfigAvailableLocationsDTO();
            cities.Cities = new List<CityDetails>();

            var command = CreateCommand("[dbo].[SP_Views_GetLocationForSelectedView]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@viewName", type));
            try
            {
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    CityDetails details = new CityDetails();
                    string city = string.Empty;
                    string[] data = null;
                    details.GeoRefid = reader.GetInt32(0);
                    city = reader.GetString(1);
                    data = city.Split(",");
                    if (data != null)
                    {
                        details.Name = data?[0];
                        details.State = data.Length == 3 ? data?[1] : "";
                        details.Country = data.Length == 3 ? data?[2] : data.Length == 2 ? data[1] : "";
                        cities.Cities.Add(details);
                    }
                }
                reader.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return cities;
        }
        #endregion

        #region Compass
        /// <summary>
        /// 1. Method to return available locations for compass view
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<CompassLocationsDTO> GetAvailableCompassLocation(int configurationId)
        {
            CompassLocationsDTO locations = new CompassLocationsDTO();
            locations.LocationDetails = new List<LocationDetails>();
            int index = 0;

            var command = CreateCommand("[dbo].[SP_Compass_GetAvailableAircraftAndLocation]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@type", "location"));

            try
            {
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    LocationDetails locationDetails = new LocationDetails();
                    locationDetails.Location = new CityDetails();
                    string city = string.Empty;
                    string[] data = null;

                    locationDetails.Index = index;
                    locationDetails.Location.GeoRefid = reader.IsDBNull(1) ? -3 : int.Parse(reader.GetString(1));
                    city = reader.IsDBNull(0) ? "" : reader.GetString(0);
                    data = !string.IsNullOrWhiteSpace(city) ? city.Split(",") : null;
                    locationDetails.Location.Name = data != null ? data[0] : "Closest Location";
                    locationDetails.Location.State = data?.Length == 3 ? data?[1] : "";
                    locationDetails.Location.Country = data?.Length == 3 ? data?[2] : data?.Length == 2 ? data[1] : "";
                    locations.LocationDetails.Add(locationDetails);
                    index++;
                }
                reader.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return locations;
        }

        /// <summary>
        /// 1. Get available airplane types from compass API
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<AirplaneData> GetAirplaneTypes(int configurationId)
        {
            AirplaneData airplaneData = new AirplaneData();
            airplaneData.AirplaneList = new List<AirplaneTypes>();
            try
            {
                var command = CreateCommand("[dbo].[SP_Compass_GetAvailableAircraftAndLocation]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@type", "aircraft"));

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    AirplaneTypes types = new AirplaneTypes();
                    types.Name = reader.GetString(0);
                    types.Id = reader.GetInt32(1);
                    airplaneData.AirplaneList.Add(types);
                }
                reader.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return airplaneData;
        }

        /// <summary>
        /// 1. Get the airplane types from tblConfigurationComponents table
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<AirplaneData> GetAvailableAirplaneTypes(int configurationId)
        {
            AirplaneData airplaneData = new AirplaneData();
            airplaneData.AirplaneList = new List<AirplaneTypes>();
            try
            {
                var command = CreateCommand("[dbo].[SP_Compass_GetAvailableAircraftAndLocation]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@type", "available"));

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    AirplaneTypes types = new AirplaneTypes();
                    types.Name = reader.GetString(0);
                    types.Id = reader.GetInt32(1);
                    airplaneData.AirplaneList.Add(types);
                }
                reader.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return airplaneData;
        }

        /// <summary>
        /// 1. Add airplane types from configurationcomponents table to the RLI table xml
        /// 2. Get airplane name based on airplane ID
        /// 3. If already xml has values then get names which are not present in xml
        /// 4. Add values to the airplane tag in the xml and update the table 
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="airplaneIds"></param>
        /// <returns></returns>
        public virtual async Task<int> AddCompassAirplaneTypes(int configurationId, List<string> airplaneIds)
        {
            int result = 0;
            try
            {
                XmlDocument document = new XmlDocument();
                XmlNode node = null;
                var command = CreateCommand("[dbo].[SP_Compass_RliXML]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@type", "get"));
                
                using var reader = await command.ExecuteReaderAsync();
                while (reader.Read())
                {
                    if (!string.IsNullOrWhiteSpace(reader["xmlData"].ToString()))
                        document.LoadXml(reader["xmlData"].ToString());
                }
                reader.Close();

                if (document != null && document.DocumentElement != null)
                {
                    if (document.SelectSingleNode("rli/airplanes") != null)
                    {
                        node = document.SelectSingleNode("rli/airplanes");
                        node.InnerText = node.InnerText + ',' + string.Join(",", airplaneIds);
                    }
                    else
                    {
                        node = document.SelectSingleNode("rli");
                        XmlNode newNode = document.CreateNode(XmlNodeType.Element, "airplanes", null);
                        newNode.InnerText = string.Join(",", airplaneIds);
                        node.AppendChild(newNode);
                        document.LoadXml(node.OuterXml);
                    }
                }
                else
                {
                    string newNode = "<rli><airplanes>" + string.Join(",", airplaneIds) + "</airplanes></rli>";
                    document.LoadXml(newNode);
                }

                var updateCommand = CreateCommand("[dbo].[SP_Compass_RliXML]");
                updateCommand.CommandType = CommandType.StoredProcedure;
                updateCommand.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                updateCommand.Parameters.Add(new SqlParameter("@type", "update"));
                updateCommand.Parameters.Add("@xmlValue", SqlDbType.Xml).Value = document.OuterXml.ToString();

                using var updateReader = await updateCommand.ExecuteReaderAsync();
                while (updateReader.Read())
                {
                    result = DbHelper.DBValueToInt(updateReader["retValue"]);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        /// <summary>
        /// 1. Method to get all the colors for the compass colors
        /// 2. Total there are 7 colors saved in the XML
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<CompassColors> GetCompassColors(int configurationId)
        {
            CompassColors compassColors = new CompassColors();
            try
            {
                var command = CreateCommand("[dbo].[SP_Compass_GetCompassColors]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    compassColors.CompassColorPlaceholder = reader["CompassColorPlaceholder"].ToString();
                    compassColors.Location_1_Color = reader["Location_1_Color"].ToString();
                    compassColors.Location_2_Color = reader["Location_2_Color"].ToString();
                    compassColors.NorthTextColor = reader["NorthTextColor"].ToString();
                    compassColors.NorthBaseColor = reader["NorthBaseColor"].ToString();
                    compassColors.POIColor = reader["POIColor"].ToString();
                    compassColors.ValueTextColor = reader["ValueTextColor"].ToString();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return compassColors;
        }

        /// <summary>
        /// 1. Update compass locations
        /// 2. There are 2 locations
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="color"></param>
        /// <param name="nodeName"></param>
        /// <returns></returns>
        public virtual async Task<int> UpdateCompassColors(int configurationId, string color, string nodeName)
        {
            int result = 0;
            try
            {
                XmlDocument document = new XmlDocument();
                XmlNode node = null;
                XmlNode newNode = null;
                XmlAttribute name = null;
                var command = CreateCommand("[dbo].[SP_Compass_RliXML]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@type", "get"));
                
                using var reader = await command.ExecuteReaderAsync();
                while (reader.Read())
                {
                    if (!string.IsNullOrWhiteSpace(reader["xmlData"].ToString()))
                        document.LoadXml(reader["xmlData"].ToString());
                }
                reader.Close();
                if (document != null && document.DocumentElement != null)
                {
                    switch (nodeName.ToLower())
                    {
                        case "loc1":
                            if (document.SelectSingleNode("rli/loc1") != null)
                            {
                                node = document.SelectSingleNode("rli/loc1");
                                node.Attributes[0].Value = color;
                            }
                            else
                            {
                                newNode = document.CreateNode("element", "loc1", "");
                                name = document.CreateAttribute("color");
                                name.Value = color;
                                newNode.Attributes.Append(name);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            break;
                        case "loc2":
                            if (document.SelectSingleNode("rli/loc2") != null)
                            {
                                node = document.SelectSingleNode("rli/loc2");
                                node.Attributes[0].Value = color;
                            }
                            else
                            {
                                newNode = document.CreateNode("element", "loc2", "");
                                name = document.CreateAttribute("color");
                                name.Value = color;
                                newNode.Attributes.Append(name);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            break;
                        case "north_text":
                            if (document.SelectSingleNode("rli/north_text") != null)
                            {
                                node = document.SelectSingleNode("rli/north_text");
                                node.Attributes[0].Value = color;
                            }
                            else
                            {
                                newNode = document.CreateNode("element", "north_text", "");
                                name = document.CreateAttribute("color");
                                name.Value = color;
                                newNode.Attributes.Append(name);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            break;
                        case "north_base":
                            if (document.SelectSingleNode("rli/north_base") != null)
                            {
                                node = document.SelectSingleNode("rli/north_base");
                                node.Attributes[0].Value = color;
                            }
                            else
                            {
                                newNode = document.CreateNode("element", "north_base", "");
                                name = document.CreateAttribute("color");
                                name.Value = color;
                                newNode.Attributes.Append(name);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            break;
                        case "poi_text":
                            if (document.SelectSingleNode("rli/poi_text") != null)
                            {
                                node = document.SelectSingleNode("rli/poi_text");
                                node.Attributes[0].Value = color;
                            }
                            else
                            {
                                newNode = document.CreateNode("element", "poi_text", "");
                                name = document.CreateAttribute("color");
                                name.Value = color;
                                newNode.Attributes.Append(name);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            break;
                        case "value_text":
                            if (document.SelectSingleNode("rli/value_text") != null)
                            {
                                node = document.SelectSingleNode("rli/value_text");
                                node.Attributes[0].Value = color;
                            }
                            else
                            {
                                newNode = document.CreateNode("element", "value_text", "");
                                name = document.CreateAttribute("color");
                                name.Value = color;
                                newNode.Attributes.Append(name);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            break;

                        case "compass":
                            if (document.SelectSingleNode("rli/compass") != null)
                            {
                                node = document.SelectSingleNode("rli/compass");
                                node.Attributes[0].Value = color;
                            }
                            else
                            {
                                newNode = document.CreateNode("element", "compass", "");
                                name = document.CreateAttribute("color");
                                name.Value = color;
                                newNode.Attributes.Append(name);
                                document.DocumentElement.AppendChild(newNode);
                            }
                            break;
                    }
                }
                else
                {
                    string xmlData = string.Empty;
                    switch (nodeName.ToLower())
                    {
                        case "loc1":
                            xmlData = "<rli><loc1 color=" + "\"" + color + "\"" + "/></rli>";
                            break;
                        case "loc2":
                            xmlData = "<rli><loc2 color=" + "\"" + color + "\"" + "/></rli>";
                            break;
                        case "north_text":
                            xmlData = "<rli><north_text color=" + "\"" + color + "\"" + "/></rli>";
                            break;
                        case "north_base":
                            xmlData = "<rli><north_base color=" + "\"" + color + "\"" + "/></rli>";
                            break;
                        case "poi_text":
                            xmlData = "<rli><poi_text color=" + "\"" + color + "\"" + "/></rli>";
                            break;
                        case "value_text":
                            xmlData = "<rli><value_text color=" + "\"" + color + "\"" + "/></rli>";
                            break;
                        case "compass":
                            xmlData = "<rli><compass color=" + "\"" + color + "\"" + "/></rli>";
                            break;
                    }
                    document.LoadXml(xmlData);
                }

                var updateCommand = CreateCommand("[dbo].[SP_Compass_RliXML]");
                updateCommand.CommandType = CommandType.StoredProcedure;
                updateCommand.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                updateCommand.Parameters.Add(new SqlParameter("@type", "update"));
                updateCommand.Parameters.Add("@xmlValue", SqlDbType.Xml).Value = document.OuterXml.ToString();

                using var updateReader = await updateCommand.ExecuteReaderAsync();
                while (updateReader.Read())
                {
                    result = DbHelper.DBValueToInt(updateReader["retValue"]);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        /// <summary>
        /// 1. Update compass locations
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="index"></param>
        /// <param name="geoRefId"></param>
        /// <returns></returns>
        public virtual async Task<int> UpdateCompassLocation(int configurationId, int index, int geoRefId)
        {
            int result = 0;
            string cityName = string.Empty;
            int nodeNumber = index + 1;
            XmlDocument document = new XmlDocument();
            var command = CreateCommand("[dbo].[SP_Compass_UpdateCompassLocation]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@inputGeoRefId", geoRefId));
            command.Parameters.Add(new SqlParameter("@type", "get"));

            try
            {
                using var reader = await command.ExecuteReaderAsync();
                while (reader.Read())
                {
                    if (!string.IsNullOrWhiteSpace(reader["xmlData"].ToString()))
                        document.LoadXml(reader["xmlData"].ToString());
                    cityName = DbHelper.StringFromDb(reader["cityName"]);
                }
                reader.Close();

                if (document != null && document.DocumentElement != null)
                {

                    if (document.SelectSingleNode("rli/location" + nodeNumber) != null)
                    {
                        XmlNode defaultNode = document.SelectSingleNode("rli/location" + nodeNumber);
                        defaultNode.ParentNode.RemoveChild(defaultNode);
                    }
                    string newNode = "<rli><location" + nodeNumber + " name=" + "\"" + cityName + "\"" + ">" + geoRefId + "</location" + nodeNumber + "></rli>";
                    XmlDocument doc = new XmlDocument();
                    doc.LoadXml(newNode);
                    XmlNode importNode = document.ImportNode(doc.DocumentElement.FirstChild, true);
                    document.DocumentElement.AppendChild(importNode);
                }
                else
                {
                    string newNode = "<rli><location" + nodeNumber + " name=" + "\"" + cityName + "\"" + ">" + geoRefId + "</location" + nodeNumber + "></rli>";
                    document.LoadXml(newNode);
                }

                var updateCommand = CreateCommand("[dbo].[SP_Compass_UpdateCompassLocation]");
                updateCommand.CommandType = CommandType.StoredProcedure;
                updateCommand.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                updateCommand.Parameters.Add(new SqlParameter("@inputGeoRefId", geoRefId));
                updateCommand.Parameters.Add(new SqlParameter("@type", "update"));
                updateCommand.Parameters.Add("@xmlValue", SqlDbType.Xml).Value = document.OuterXml.ToString();

                using var updateReader = await updateCommand.ExecuteReaderAsync();
                while (updateReader.Read())
                {
                    result = updateReader.GetInt32(0);
                }
                updateReader.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        /// <summary>
        /// 1. Get makkah text and images values
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<List<string>> getCompassMakkahValues(int configurationId)
        {
            List<string> imageTextValues = new List<string>();
            string image = string.Empty;
            string text = string.Empty;
            try
            {
                var command = CreateCommand("[dbo].[SP_Compass_GetMakkahImageTextValues]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));

                using var reader = await command.ExecuteReaderAsync();
                while (reader.Read())
                {
                    image = !reader.IsDBNull(0) ? reader.GetString(0) : "false";
                    text = !reader.IsDBNull(1) ? reader.GetString(1) : "false";
                    imageTextValues.Add(image);
                    imageTextValues.Add(text);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return imageTextValues;
        }

        /// <summary>
        /// 1. Update compass values
        /// 2. These values effect both compass and Makkah screens
        /// 3. The values are image and text
        /// 4. Values for these are true and false
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="type"></param>
        /// <param name="data"></param>
        /// <returns></returns>
        public virtual async Task<int> UpdateCompassValues(int configurationId, string type, string data)
        {
            int result = 0;
            try
            {
                XmlDocument document = new XmlDocument();
                XmlNode node = null;
                XmlAttribute name = null;

                var command = CreateCommand("[dbo].[SP_Compass_RliXML]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@type", "get"));

                using var reader = await command.ExecuteReaderAsync();
                while (reader.Read())
                {
                    if (!string.IsNullOrWhiteSpace(reader["xmlData"].ToString()))
                        document.LoadXml(reader["xmlData"].ToString());
                }
                reader.Close();

                if (document != null && document.DocumentElement != null)
                {
                    if (document.SelectSingleNode("rli/mecca_display") != null)
                    {
                        node = document.SelectSingleNode("rli/mecca_display");
                        switch (type.ToLower())
                        {
                            case "image":
                                if (node != null)
                                {
                                    if (node.Attributes["image"] != null)
                                        node.Attributes["image"].Value = data;
                                    else
                                    {
                                        name = document.CreateAttribute("image");
                                        name.Value = data;
                                        node.Attributes.Append(name);
                                    }
                                }
                                else
                                {
                                    node = document.CreateNode("element", "mecca_display", "");
                                    name = document.CreateAttribute("image");
                                    name.Value = data;
                                    node.Attributes.Append(name);
                                    document.DocumentElement.AppendChild(node);
                                }
                                break;
                            case "text":
                                if (node != null)
                                {
                                    if (node.Attributes["text"] != null)
                                        node.Attributes["text"].Value = data;
                                    else
                                    {
                                        name = document.CreateAttribute("text");
                                        name.Value = data;
                                        node.Attributes.Append(name);
                                    }
                                }
                                else
                                {
                                    node = document.CreateNode("element", "mecca_display", "");
                                    name = document.CreateAttribute("text");
                                    name.Value = data;
                                    node.Attributes.Append(name);
                                    document.DocumentElement.AppendChild(node);
                                }
                                break;
                        }
                    }
                    else
                    {
                        string newNode = "<rli><mecca_display " + type.ToLower() + "=" + "\"" + data + "\"" + "/></rli>";
                        XmlDocument doc = new XmlDocument();
                        doc.LoadXml(newNode);
                        XmlNode importNode = document.ImportNode(doc.DocumentElement.FirstChild, true);
                        document.DocumentElement.AppendChild(importNode);
                    }
                }
                else
                {
                    string xmlData = string.Empty;
                    switch (type.ToLower())
                    {
                        case "image":
                            xmlData = "<rli><mecca_display image=" + "\"" + data + "\"" + "/></rli>";
                            break;
                        case "text":
                            xmlData = "<rli><mecca_display text=" + "\"" + data + "\"" + "/></rli>";
                            break;
                    }
                    document.LoadXml(xmlData);
                }

                var updateCommand = CreateCommand("[dbo].[SP_Compass_RliXML]");
                updateCommand.CommandType = CommandType.StoredProcedure;
                updateCommand.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                updateCommand.Parameters.Add(new SqlParameter("@type", "update"));
                updateCommand.Parameters.Add("@xmlValue", SqlDbType.Xml).Value = document.OuterXml.ToString();

                using var updateReader = await updateCommand.ExecuteReaderAsync();
                while (updateReader.Read())
                {
                    result = DbHelper.DBValueToInt(updateReader["retValue"]);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        public virtual async Task<int> InserUpdateAeroplaneTyes(int configurationId, string aeroplanTypes, Guid userID)
        {
            int result = 0;
            try
            {
                var command = CreateCommand("[dbo].[SP_Insert_Updaye_AeroplanTypes]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@aeroplanTypes", aeroplanTypes));
                result = await command.ExecuteNonQueryAsync();
            }
            catch(Exception ex)
            {
                throw;
            }
            return result;
        }
        #endregion

        #region Timezone
        /// <summary>
        /// 1. Method to return available locations for timezone view
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<TimezoneLocationDTO> GetAvailableTimezoneLocations(int configurationId)
        {
            TimezoneLocationDTO timezone = new TimezoneLocationDTO();
            timezone.TimeZoneLocations = new List<CityDetails>();

            var command = CreateCommand("[dbo].[SP_Timezone_GetAvailableTimeoneLocation]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));

            try
            {
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    CityDetails details = new CityDetails();
                    string cities = string.Empty;
                    string[] data = null;
                    if (!reader.IsDBNull(1))
                    {
                        details.GeoRefid = int.Parse(reader.GetString(1));
                        cities = reader.GetString(0);
                        data = !string.IsNullOrWhiteSpace(cities) ? cities.Split(",") : null;
                        if (data != null)
                        {
                            details.Name = data?[0];
                            details.State = data.Length == 3 ? data?[1] : "";
                            details.Country = data.Length == 3 ? data?[2] : data.Length == 2 ? data[1] : "";
                            timezone.TimeZoneLocations.Add(details);
                        }
                    }
                }
                reader.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return timezone;
        }

        /// <summary>
        /// 1. API will either add or remove configurations to the timezone table
        /// 2. Get the list of Locations from Georef table where isTimezonePoi = 1
        /// 3. If status is add, then add new node to the XML with data from Georef table.
        /// 4. If status is remove then delete the node from the XML which has the georef ID.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="listGeoRefId"></param>
        /// <param name="status"></param>
        /// <returns></returns>
        public virtual async Task<int> UpdateTimezoneLocations(int configurationId, List<string> listGeoRefId, string status)
        {
            List<int> returnValue = new List<int>();
            int result = 0;
            try
            {
                var command = CreateCommand("[dbo].[SP_Timezone_UpdateTimezoneLocation]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@InputList", String.Join(",", listGeoRefId)));
                command.Parameters.Add(new SqlParameter("@type", status));

                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (reader.Read())
                    {
                        returnValue.Add(reader.GetInt32(0));
                    }
                }

                if (returnValue.Count > 0 && returnValue.IndexOf(0) == -1)
                    result = 1;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        /// <summary>
        /// 1. Get timezone colors
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<IEnumerable<string>> GetTimezoneColors(int configurationId)
        {
            var timezoneColors = new List<string>();
            try
            {
                var command = CreateCommand("[dbo].[SP_Timezone_ColorsData]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@type", "get"));
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    timezoneColors.Add(reader["Departure_Color"].ToString());
                    timezoneColors.Add(reader["Destination_Color"].ToString());
                    timezoneColors.Add(reader["Present_Color"].ToString());
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return timezoneColors;
        }

        /// <summary>
        /// 1. Update timezone colors
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<int> UpdateTimezoneColors(int configurationId, string color, string node)
        {
            int result = 0;
            try
            {
                var command = CreateCommand("[dbo].[SP_Timezone_ColorsData]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@color", color));
                command.Parameters.Add(new SqlParameter("@nodeName", node));
                command.Parameters.Add(new SqlParameter("@type", "update"));
                result = await command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }
        #endregion

        #region WorldClock
        /// <summary>
        /// 1. Method to return available locations for worldclock view
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<WorldClockLocationsDTO> GetAvailableWorlclockLocations(int configurationId)
        {
            WorldClockLocationsDTO worldClock = new WorldClockLocationsDTO();
            worldClock.WorldclockLocations = new List<CityDetails>();

            var command = CreateCommand("[dbo].[SP_WorldClock_GetAvailableAndAlternateWorldClockLocations]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@type", "available"));

            try
            {
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    if (!reader.IsDBNull(1))
                    {
                        CityDetails details = new CityDetails();
                        string cities = string.Empty;
                        string[] data = null;
                        details.GeoRefid = DbHelper.DBValueToInt(reader["geoRefId"]);
                        cities = DbHelper.StringFromDb(reader["city"]);
                        data = !string.IsNullOrWhiteSpace(cities) ? cities.Split(",") : null;
                        if (data != null)
                        {
                            details.Name = data?[0];
                            details.State = data.Length == 3 ? data?[1] : "";
                            details.Country = data.Length == 3 ? data?[2] : data.Length == 2 ? data[1] : "";
                            worldClock.WorldclockLocations.Add(details);
                        }
                    }
                }
                reader.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return worldClock;
        }

        /// <summary>
        /// 1. Method to get all alternate locations for worldclock view
        /// 2 These locations will be considered as default locations
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<WorldClockLocationsDTO> GetAlternateWorlclockLocations(int configurationId)
        {
            WorldClockLocationsDTO worldClock = new WorldClockLocationsDTO();
            worldClock.WorldclockLocations = new List<CityDetails>();

            var command = CreateCommand("[dbo].[SP_WorldClock_GetAvailableAndAlternateWorldClockLocations]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@type", "alternate"));

            try
            {
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    CityDetails details = new CityDetails();
                    string cities = string.Empty;
                    string[] data = null;
                    details.GeoRefid = DbHelper.DBValueToInt(reader["geoRefId"]);
                    cities = DbHelper.StringFromDb(reader["city"]);
                    data = !string.IsNullOrWhiteSpace(cities) ? cities.Split(",") : null;
                    if (data != null)
                    {
                        details.Name = data?[0];
                        details.State = data.Length == 3 ? data?[1] : "";
                        details.Country = data.Length == 3 ? data?[2] : data.Length == 2 ? data[1] : "";
                        worldClock.WorldclockLocations.Add(details);
                    }
                }
                reader.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return worldClock;
        }

        /// <summary>
        /// 1. Move cities in Worldclock XML to mentioned positions
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="geoRefId"></param>
        /// <param name="position"></param>
        /// <returns></returns>
        public virtual async Task<int> MoveSelectedWorldClockLocation(int configurationId, string geoRefId, int oldPositionNumber, int newPositionNumber)
        {
            XmlDocument document = new XmlDocument();
            int returnValue = 0;
            XmlNode xNode = null;
            XmlNode destinationNode = null;
            XmlNode defaultNode = null;
            XmlNodeList allNodeList;
            XmlNodeList defaultNodeList;
            try
            {
                var command = CreateCommand("[dbo].[SP_WorldClock_MoveWorldclockLocation]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@type", "get"));
                
                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (reader.Read())
                    {
                        document.LoadXml(reader["xmlData"].ToString());
                    }
                }
                if (document != null)
                {
                    allNodeList = document.SelectNodes("worldclock_cities/city");
                    defaultNodeList = document.SelectNodes("worldclock_cities/default_city");

                    if (document.SelectSingleNode("worldclock_cities/city[@geoRef='" + geoRefId + "']") != null)
                    {
                        xNode = document.SelectSingleNode("worldclock_cities/city[@geoRef='" + geoRefId + "']");
                    }
                    if (document.SelectSingleNode("worldclock_cities/default_city") != null)
                    {
                        defaultNode = document.SelectSingleNode("worldclock_cities/default_city");
                    }

                    if (xNode == null)
                    {
                        returnValue = 2;
                    }
                    else if (xNode != null)
                    {
                        if (newPositionNumber <= 0)
                        {
                            xNode.ParentNode.RemoveChild(xNode);
                            document.DocumentElement.InsertBefore(xNode, document.DocumentElement.FirstChild);
                        }
                        else
                        {
                            XmlNode updateNode;
                            if (oldPositionNumber > newPositionNumber)
                            {
                                updateNode = allNodeList[newPositionNumber];
                                xNode.ParentNode.RemoveChild(xNode);
                                document.DocumentElement.InsertBefore(xNode, updateNode);
                            }
                            else if (oldPositionNumber < newPositionNumber)
                            {
                                updateNode = allNodeList[newPositionNumber];
                                xNode.ParentNode.RemoveChild(xNode);
                                document.DocumentElement.InsertAfter(xNode, updateNode);
                            }
                        }

                        var updateCommand = CreateCommand("[dbo].[SP_WorldClock_MoveWorldclockLocation]");
                        updateCommand.CommandType = CommandType.StoredProcedure;
                        updateCommand.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                        updateCommand.Parameters.Add(new SqlParameter("@type", "update"));
                        updateCommand.Parameters.Add("@xmlData", SqlDbType.Xml).Value = document.OuterXml.ToString();
                        using (var readers = await updateCommand.ExecuteReaderAsync())
                        {
                            while (readers.Read())
                            {
                                returnValue = readers.GetInt32(0);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return returnValue;
        }

        /// <summary>
        /// 1. API will either add or remove configurations to the worldclock table
        /// 2. Get the list of Locations from Georef table where isworldclockpoi = 1
        /// 3. If status is add, then add new node to the XML with data from Georef table.
        /// 4. If status is remove then delete the node from the XML which has the georef ID.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="listGeoRefId"></param>
        /// <param name="status"></param>
        /// <returns></returns>
        public virtual async Task<int> UpdateWorldclockLocation(int configurationId, List<string> listGeoRefId, string status)
        {
            List<int> returnValue = new List<int>();
            int result = 0;
            try
            {
                if (listGeoRefId.Count > 0)
                {
                    foreach (var id in listGeoRefId)
                    {
                        var command = CreateCommand("[dbo].[SP_WorldClock_UpdateWorldclockLocation]");
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                        command.Parameters.Add(new SqlParameter("@InputList", id));
                        command.Parameters.Add(new SqlParameter("@type", status));

                        using (var reader = await command.ExecuteReaderAsync())
                        {
                            while (reader.Read())
                            {
                                returnValue.Add(reader.GetInt32(0));
                            }
                        }
                    }
                }
                else
                {
                    var command = CreateCommand("[dbo].[SP_WorldClock_UpdateWorldclockLocation]");
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                    command.Parameters.Add(new SqlParameter("@InputList", "0"));
                    command.Parameters.Add(new SqlParameter("@type", status));
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (reader.Read())
                        {
                            returnValue.Add(reader.GetInt32(0));
                        }
                    }
                }
                if (returnValue.Count > 0 && returnValue.IndexOf(0) == -1)
                    result = 1;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        /// <summary>
        /// 1. API to add new alternate location
        /// 2. If index is 0, then add as first default node
        /// 3. If index is 0, then remove first default node before adding new node
        /// 4. If index is 1, then add as second default node
        /// 5. If index is 1, then remove the second default node before adding the new node
        /// 6. There will be only 2 default nodes at max
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="index"></param>
        /// <param name="geoRefId"></param>
        /// <returns></returns>
        public virtual async Task<int> AddAlternateWorldclockCity(int configurationId, int index, int geoRefId)
        {
            int result = 0;
            string cityName = string.Empty;
            XmlDocument document = new XmlDocument();
            XmlNode defaultNode = null;
            var command = CreateCommand("[dbo].[SP_WorldClock_AddAlternateWorldClockCity]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
            command.Parameters.Add(new SqlParameter("@inputGeoRefId", geoRefId));
            command.Parameters.Add(new SqlParameter("@type", "get"));

            try
            {
                using var reader = await command.ExecuteReaderAsync();
                while (reader.Read())
                {
                    if (!string.IsNullOrWhiteSpace(reader["xmlData"].ToString()))
                        document.LoadXml(reader["xmlData"].ToString());
                    cityName = DbHelper.StringFromDb(reader["cityName"]);
                }
                reader.Close();

                if (document != null)
                {
                    XmlNodeList xmlNodeList = null;
                    if (document.SelectSingleNode("worldclock_cities/default_city") != null)
                    {
                        xmlNodeList = document.SelectNodes("worldclock_cities/default_city");
                    }
                    XmlNode newNode = document.CreateNode("element", "default_city", "");
                    XmlAttribute name = document.CreateAttribute("name");
                    name.Value = cityName;
                    XmlAttribute geoRef = document.CreateAttribute("geoRef");
                    geoRef.Value = geoRefId.ToString();
                    newNode.Attributes.Append(name);
                    newNode.Attributes.Append(geoRef);
                    if (xmlNodeList != null)
                    {
                        if (index == 1)
                        {
                            defaultNode = xmlNodeList[index];
                            defaultNode.ParentNode.RemoveChild(defaultNode);
                            document.DocumentElement.InsertAfter(newNode, document.DocumentElement.LastChild);
                        }
                        else if (index == 0)
                        {
                            defaultNode = xmlNodeList[index];
                            XmlNode node = xmlNodeList[index + 1];
                            defaultNode.ParentNode.RemoveChild(defaultNode);
                            document.DocumentElement.InsertBefore(newNode, node);
                        }
                        else
                        {
                            document.DocumentElement.AppendChild(newNode);
                        }
                    }
                    else
                    {
                        document.LoadXml("<worldclock_cities></worldclock_cities>");
                        document.DocumentElement.AppendChild(newNode);
                    }

                    var updateCommand = CreateCommand("[dbo].[SP_WorldClock_AddAlternateWorldClockCity]");
                    updateCommand.CommandType = CommandType.StoredProcedure;
                    updateCommand.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                    updateCommand.Parameters.Add(new SqlParameter("@inputGeoRefId", geoRefId));
                    updateCommand.Parameters.Add(new SqlParameter("@type", "update"));
                    updateCommand.Parameters.Add("@xmlValue", SqlDbType.Xml).Value = document.OuterXml.ToString();

                    using var updateReader = await updateCommand.ExecuteReaderAsync();
                    while (updateReader.Read())
                    {
                        result = updateReader.GetInt32(0);
                    }
                    updateReader.Close();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }
        #endregion

        #region Flight Info/Broadcast/Your Flight
        /// <summary>
        /// 1. Get flight info parameters
        /// 2. Match the info from the XML with the feature set table
        /// 3. If value is available, then map the display name
        /// 4. Return the display names for values available in the XML
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<Dictionary<FlightInfoParams, List<string>>> GetFlightInfoParameters(string pageName, int configurationId)
        {
            Dictionary<FlightInfoParams, List<string>> parameters = new Dictionary<FlightInfoParams, List<string>>();
            List<string> xmlNames = new List<string>();
            string displayname = string.Empty;
            FlightInfoParams infoParams = new FlightInfoParams();
            try
            {
                var command = CreateCommand("[dbo].[SP_FlightInfo_GetFlightInfoParameters]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@pageName", pageName));
                command.Parameters.Add(new SqlParameter("@type", "get"));
                DataTable dataTable = new DataTable();
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    displayname = reader["xmldisplayName"].ToString();
                    infoParams.DisplayName = reader["infoParamDisplay"].ToString();
                    infoParams.Name = reader["infoParamName"].ToString();

                }
                reader.Close();
                displayname = displayname.TrimEnd(',');

                xmlNames = displayname.Split(",").ToList();
                if (xmlNames.Count > 0 && !string.IsNullOrWhiteSpace(infoParams.DisplayName) && !string.IsNullOrWhiteSpace(infoParams.Name))
                {
                    parameters.Add(infoParams, xmlNames);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return parameters;
        }

        /// <summary>
        /// 1. Map flight info display names
        /// 2. Get list of flight info display names from Feature set table
        /// 3. Cross check display names with names from Featureset
        /// 4. If its available, then map the values as return values
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<Dictionary<string, string>> GetAvailableFlightInfoParameters(string pageName, int configurationId)
        {
            Dictionary<string, string> parameters = new Dictionary<string, string>();
            string displayname = string.Empty;
            string names = string.Empty;
            try
            {
                var command = CreateCommand("[dbo].[SP_FlightInfo_GetAvailableFlightInfoParameters]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    displayname = reader["infoParamDisplay"].ToString();
                    names = reader["infoParamName"].ToString();
                }
                reader.Close();

                if (!string.IsNullOrWhiteSpace(names) && !string.IsNullOrWhiteSpace(displayname))
                {
                    parameters.Add(names, displayname);
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return parameters;
        }

        /// <summary>
        /// 1. Add new parameters to flight info
        /// 2. Parameters can be repeated
        /// 3. Cross verify parameters in featureset and then update in info items xml
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="listFlightInfoParams"></param>
        /// <returns></returns>
        public virtual async Task<int> AddNewFlighInfoParams(string pageName, int configurationId, List<string> listFlightInfoParams)
        {
            XmlDocument document = new XmlDocument();
            XmlNodeList flightInfoNodeList;
            string names = string.Empty;
            string displayNames = string.Empty;
            string selectedParams = string.Empty;
            string infoItemType = string.Empty;            
            int result = 0;
            try
            {
                var command = CreateCommand("[dbo].[SP_FlightInfo_GetFlightInfoParameters]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@ConfigurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@pageName", pageName));
                command.Parameters.Add(new SqlParameter("@type", "get"));
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    names = reader["infoParamName"].ToString();
                    displayNames = reader["infoParamDisplay"].ToString();
                    selectedParams = reader["xmldisplayName"].ToString();
                    if (!string.IsNullOrWhiteSpace(reader["xmlData"].ToString()))
                        document.LoadXml(reader["xmlData"].ToString());
                }
                reader.Close();
                List<string> flightInfoNames = new List<string>();
                List<string> flightInfoDisplayNames = new List<string>();
                List<string> flightInfoselectedParams = new List<string>();

                if (!string.IsNullOrWhiteSpace(names) && !string.IsNullOrWhiteSpace(displayNames))
                {
                    flightInfoNames = names.Split(",").ToList();
                    flightInfoDisplayNames = displayNames.Split(",").ToList();
                }
                else
                    return 0;

                if(!string.IsNullOrWhiteSpace(selectedParams))
                {
                    selectedParams = selectedParams.TrimEnd(',');
                    flightInfoselectedParams = selectedParams.Split(",").ToList();
                }

                if(pageName.ToLower() == "flightinfo")
                {
                    infoItemType = "default_flight_info";
                }
                else if (pageName.ToLower() == "broadcast")
                {
                    infoItemType = "broadcast";
                }
                else if (pageName.ToLower() == "yourflight")
                {
                    infoItemType = "yourflight";
                }

                if (document != null && document.DocumentElement != null)
                {
                    flightInfoNodeList = document.SelectNodes("infoitems/infoitem[@" + infoItemType + "]");
                    XmlNode lastNode = flightInfoNodeList[flightInfoNodeList.Count - 1];

                    for (int i = 0; i < listFlightInfoParams.Count; i++)
                    {
                        for (int j = 0; j < flightInfoDisplayNames.Count; j++)
                        {
                            if (listFlightInfoParams[i].ToLower().Trim() == flightInfoDisplayNames[j].ToLower().Trim())
                            {
                                string node = "<infoitems><infoitem " + infoItemType + "= \"" + "true" + "\">" + flightInfoNames[j].Trim() + "</infoitem></infoitems>";
                                XmlDocument doc = new XmlDocument();
                                doc.LoadXml(node);
                                XmlNode importNode = document.ImportNode(doc.DocumentElement.FirstChild, true);
                                document.DocumentElement.AppendChild(importNode);

                                XmlNode newNode = document.DocumentElement.LastChild;
                                newNode.ParentNode.RemoveChild(newNode);
                                document.DocumentElement.InsertAfter(newNode, lastNode);

                                flightInfoNodeList = document.SelectNodes("infoitems/infoitem[@" + infoItemType + "]");
                                lastNode = flightInfoNodeList[flightInfoNodeList.Count - 1];
                            }
                        }
                    }
                }
                else
                {
                    for (int i = 0; i < listFlightInfoParams.Count; i++)
                    {
                        for (int j = 0; j < flightInfoDisplayNames.Count; j++)
                        {
                            if (listFlightInfoParams[i].ToLower().Trim() == flightInfoDisplayNames[j].ToLower().Trim())
                            {
                                if (document.DocumentElement == null)
                                {
                                    string node = "<infoitems><infoitem " + infoItemType + "= \"" + "true" + "\">" + flightInfoNames[j].Trim() + "</infoitem></infoitems>";
                                    document.LoadXml(node);
                                }
                                else
                                {
                                    string node = "<infoitems><infoitem " + infoItemType + "= \"" + "true" + "\">" + flightInfoNames[j].Trim() + "</infoitem></infoitems>";
                                    XmlDocument doc = new XmlDocument();
                                    doc.LoadXml(node);
                                    XmlNode importNode = document.ImportNode(doc.DocumentElement.FirstChild, true);
                                    document.DocumentElement.AppendChild(importNode);
                                }
                            }
                        }
                    }
                }
                var updateCommand = CreateCommand("[dbo].[SP_FlightInfo_GetFlightInfoParameters]");
                updateCommand.CommandType = CommandType.StoredProcedure;
                updateCommand.Parameters.Add(new SqlParameter("@ConfigurationId", configurationId));
                updateCommand.Parameters.Add(new SqlParameter("@pageName", pageName));
                updateCommand.Parameters.Add(new SqlParameter("@type", "update"));
                updateCommand.Parameters.Add("@xmlData", SqlDbType.Xml).Value = document.OuterXml.ToString();
                using var updateReader = await updateCommand.ExecuteReaderAsync();
                while (await updateReader.ReadAsync())
                {
                    result = updateReader.GetInt32(0);
                }
                updateReader.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        /// <summary>
        /// 1. Move positions of nodes based on user input
        /// 2. Nodes position starts based on 0
        /// 3. Once node is moved to new position update the XML
        /// 4. If node position is less than 0, pick first node
        /// 5. If node position is greater than the number of nodes, pick last node.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="fromPosition"></param>
        /// <param name="toPosition"></param>
        /// <returns></returns>
        public virtual async Task<int> MoveFlightInfoParameterPosition(string pageName, int configurationId, int fromPosition, int toPosition)
        {
            int result = 0;
            string infoItemType = string.Empty;
            XmlDocument document = new XmlDocument();
            try
            {
                var command = CreateCommand("[dbo].[SP_FlightInfo_MoveFlightInfoLocation]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@type", "get"));

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    document.LoadXml(reader["InfoItems"].ToString());
                }
                reader.Close();

                if (pageName.ToLower() == "flightinfo")
                {
                    infoItemType = "default_flight_info";
                }
                else if (pageName.ToLower() == "broadcast")
                {
                    infoItemType = "broadcast";
                }
                else if (pageName.ToLower() == "yourflight")
                {
                    infoItemType = "yourflight";
                }

                if (document != null)
                {
                    XmlNodeList flightInfoNodeList = document.SelectNodes("infoitems/infoitem[@" + infoItemType + "]");
                    XmlNode fromNode = null;
                    XmlNode toNode = null;

                    fromNode = flightInfoNodeList[fromPosition];
                    
                    if (toPosition <= 0)
                    {
                        fromNode.ParentNode.RemoveChild(fromNode);
                        flightInfoNodeList = document.SelectNodes("infoitems/infoitem[@" + infoItemType + "]");
                        document.DocumentElement.InsertBefore(fromNode, flightInfoNodeList[0]);
                    }
                    else
                    {
                        fromNode.ParentNode.RemoveChild(fromNode);
                        flightInfoNodeList = document.SelectNodes("infoitems/infoitem[@" + infoItemType + "]");
                        toNode = flightInfoNodeList[toPosition];
                        document.DocumentElement.InsertBefore(fromNode, toNode);
                    }


                    var updateCommand = CreateCommand("[dbo].[SP_FlightInfo_MoveFlightInfoLocation]");
                    updateCommand.CommandType = CommandType.StoredProcedure;
                    updateCommand.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                    updateCommand.Parameters.Add(new SqlParameter("@type", "update"));
                    updateCommand.Parameters.Add("@xmlData", SqlDbType.Xml).Value = document.OuterXml.ToString();
                    using (var readers = await updateCommand.ExecuteReaderAsync())
                    {
                        while (readers.Read())
                        {
                            result = readers.GetInt32(0);
                        }
                    }
                }
            }

            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }

        /// <summary>
        /// 1. API to remove flight info parameter
        /// 2. The nodeIndex input will have the node index
        /// 3. The flight parameter in the input index will be removed from the XML
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="nodeIndex"></param>
        /// <returns></returns>
        public virtual async Task<int> RemoveSelectedFlightInfoParameter(string pageName, int configurationId, int nodeIndex)
        {
            int result = 0;
            string infoItemType = string.Empty;
            XmlDocument document = new XmlDocument();
            XmlNodeList flightInfoNodeList = null;
            try
            {
                var command = CreateCommand("[dbo].[SP_FlightInfo_MoveFlightInfoLocation]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@type", "get"));

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    document.LoadXml(reader["InfoItems"].ToString());
                }
                reader.Close();

                if (pageName.ToLower() == "flightinfo")
                {
                    infoItemType = "default_flight_info";
                }
                else if (pageName.ToLower() == "broadcast")
                {
                    infoItemType = "broadcast";
                }
                else if (pageName.ToLower() == "yourflight")
                {
                    infoItemType = "yourflight";
                }

                if (document != null)
                {
                    flightInfoNodeList = document.SelectNodes("infoitems/infoitem[@" + infoItemType + "]");
                    XmlNode removeNode = null;
                    if (nodeIndex >= flightInfoNodeList.Count)
                    {
                        removeNode = flightInfoNodeList[flightInfoNodeList.Count];
                        removeNode.ParentNode.RemoveChild(removeNode);
                    }
                    else if (nodeIndex <= 0)
                    {
                        removeNode = flightInfoNodeList[0];
                        removeNode.ParentNode.RemoveChild(removeNode);
                    }
                    else
                    {
                        removeNode = flightInfoNodeList[nodeIndex];
                        removeNode.ParentNode.RemoveChild(removeNode);
                    }

                    var updateCommand = CreateCommand("[dbo].[SP_FlightInfo_MoveFlightInfoLocation]");
                    updateCommand.CommandType = CommandType.StoredProcedure;
                    updateCommand.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                    updateCommand.Parameters.Add(new SqlParameter("@type", "update"));
                    updateCommand.Parameters.Add("@xmlData", SqlDbType.Xml).Value = document.OuterXml.ToString();
                    using (var readers = await updateCommand.ExecuteReaderAsync())
                    {
                        while (readers.Read())
                        {
                            result = readers.GetInt32(0);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }
        public virtual async Task<int> RemoveSelectedParameters(string pageName, int configurationId, List<string> nodeIndexList)
        {
            int result = 0;
            string infoItemType = string.Empty;
            XmlDocument document = new XmlDocument();
            XmlNodeList flightInfoNodeList = null;
            try
            {
                var command = CreateCommand("[dbo].[SP_FlightInfo_MoveFlightInfoLocation]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@type", "get"));

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    document.LoadXml(reader["InfoItems"].ToString());
                }
                reader.Close();

                if (pageName.ToLower() == "flightinfo")
                {
                    infoItemType = "default_flight_info";
                }
                else if (pageName.ToLower() == "broadcast")
                {
                    infoItemType = "broadcast";
                }
                else if (pageName.ToLower() == "yourflight")
                {
                    infoItemType = "yourflight";
                }

                if (document != null)
                {
                    flightInfoNodeList = document.SelectNodes("infoitems/infoitem[@" + infoItemType + "]");

                    for (int i = 0; i < nodeIndexList.Count; i++)
                    {
                        int nodeIndex = Convert.ToInt32(nodeIndexList[i]);
                        XmlNode removeNode = null;
                        if (nodeIndex >= flightInfoNodeList.Count)
                        {
                            removeNode = flightInfoNodeList[flightInfoNodeList.Count];
                            removeNode.ParentNode.RemoveChild(removeNode);
                        }
                        else if (nodeIndex <= 0)
                        {
                            removeNode = flightInfoNodeList[0];
                            removeNode.ParentNode.RemoveChild(removeNode);
                        }
                        else
                        {
                            removeNode = flightInfoNodeList[nodeIndex];
                            removeNode.ParentNode.RemoveChild(removeNode);
                        }
                    }

                    var updateCommand = CreateCommand("[dbo].[SP_FlightInfo_MoveFlightInfoLocation]");
                    updateCommand.CommandType = CommandType.StoredProcedure;
                    updateCommand.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                    updateCommand.Parameters.Add(new SqlParameter("@type", "update"));
                    updateCommand.Parameters.Add("@xmlData", SqlDbType.Xml).Value = document.OuterXml.ToString();
                    using (var readers = await updateCommand.ExecuteReaderAsync())
                    {
                        while (readers.Read())
                        {
                            result = readers.GetInt32(0);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }
        #endregion

        #region Makkah
        /// <summary>
        /// 1. Method to get all makkah data
        /// 2. Makkah data include Secondary pointer location, prayer time location, pointer calculation method, and Makkah values
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<MakkahData> GetMakkahValues(int configurationId)
        {
            MakkahData makkahData = new MakkahData();
            makkahData.Cities = new List<CityDetails>();
            makkahData.MakkahValues = new List<string>();
            List<string> makkahValues = new List<string>();
            try
            {
                var command = CreateCommand("[dbo].[SP_Makkah_GetMakkahData]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    makkahValues.Add(reader.GetString(0));
                }
                reader.Close();

                for(int i = 0; i < 2; i++)
                {
                    CityDetails details = new CityDetails();
                    string[] data = null;
                    data = makkahValues[i].Split(",");
                    details.GeoRefid = int.Parse(data[0]);
                    details.Name = data?[1];
                    details.State = data.Length == 4 ? data?[2] : "";
                    details.Country = data.Length == 4 ? data?[3] : data.Length == 3 ? data[2] : "";
                    makkahData.Cities.Add(details);
                }

                makkahData.PrayerTimeCaluculation = makkahValues[2];

                if (makkahValues.Count > 3)
                    makkahData.MakkahValues.Add(makkahValues[3]);
                if (makkahValues.Count > 4)
                    makkahData.MakkahValues.Add(makkahValues[4]);
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return makkahData;
        }
        /// <summary>
        /// 1. Get makkah prayertime locations
        /// 2. Get values from Makkah table and cross reference with Feature set table
        /// 3. If Makkah location display name is availabel in feature set, then display the same.
        /// 4. There can be multiple location data
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<List<MakkahPrayerCalculationTypes>> GetMakkahPrayertimes(int configurationId)
        {
            List<MakkahPrayerCalculationTypes> makkahPrayerCalculations = new List<MakkahPrayerCalculationTypes>();
            try
            {
                var command = CreateCommand("[dbo].[SP_Makkah_GetMakkahPrayerTimes]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                
                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    MakkahPrayerCalculationTypes makkahPrayer = new MakkahPrayerCalculationTypes();
                    makkahPrayer.MakkahTypeName = DbHelper.DBValueToString(reader["MakkahTypeName"]);
                    makkahPrayer.MakkahDisplayName = DbHelper.DBValueToString(reader["MakkahDisplayName"]);
                    makkahPrayerCalculations.Add(makkahPrayer);
                }
                return makkahPrayerCalculations;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// 1.Get available Makkah locations from XML
        /// 2. Get the georef ID from XML and cross reference the Georef table and show the value
        /// 3. if no geo ref ID is available then show as Closest locaton
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<MakkahLocations> GetMakkahLocation(int configurationId, string type)
        {
            MakkahLocations locations = new MakkahLocations();
            locations.AvailableMakkahLocations = new List<CityDetails>();
            try
            {
                var command = CreateCommand("[dbo].[SP_Makkah_GetMakkahLocations]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@type", type));

                using var reader = await command.ExecuteReaderAsync();
                while(await reader.ReadAsync())
                {
                    CityDetails details = new CityDetails();
                    string cities = string.Empty;
                    string[] data = null;
                    details.GeoRefid = reader.GetInt32(0);
                    cities = reader.GetString(1);
                    data = !string.IsNullOrWhiteSpace(cities) ? cities.Split(",") : null;
                    if (data != null)
                    {
                        details.Name = data?[0];
                        details.State = data.Length == 3 ? data?[1] : "";
                        details.Country = data.Length == 3 ? data?[2] : data.Length == 2 ? data[1] : "";
                        locations.AvailableMakkahLocations.Add(details);
                    }
                }
                reader.Close();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return locations;
        }

        /// <summary>
        /// 1. Method to update makkah location and prayer time location
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="data"></param>
        /// <param name="type"></param>
        /// <returns></returns>
        public virtual async Task<int> UpdateMakkahLocationAndPrayerTimeLocation(int configurationId, string data, string type)
        {
            int result = 0;

            try
            {
                var command = CreateCommand("[dbo].[SP_Makkah_UpdateMakkahLocationAndPrayerTimeLocation]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new SqlParameter("@configurationId", configurationId));
                command.Parameters.Add(new SqlParameter("@data", data));
                command.Parameters.Add(new SqlParameter("@type", type));
                result = await command.ExecuteNonQueryAsync();
            }
            catch (Exception ex)
            {
                throw ex;
            }

            return result;
        }

        #endregion
        #endregion
    }
}
