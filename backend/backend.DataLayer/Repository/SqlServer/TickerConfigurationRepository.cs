using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Xml;
using backend.DataLayer.Helpers;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer.Queries;

namespace backend.DataLayer.Repository.SqlServer
{
    public class TickerConfigurationRepository : Repository, ITickerConfigurationRepository
    {

        public TickerConfigurationRepository(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;
        }

        public TickerConfigurationRepository()
        { }

        public virtual async Task<Dictionary<string, object>> GetTicker(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_ticker_getticker]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            return await SQLHelper.GetSQLResultsForCommand(command);
        }

        public virtual async Task<int> UpdateTicker(int configurationId, string name, string value)
        {
            var result = 0;
            var command = CreateCommand("[dbo].[sp_ticker_gettickercount]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@name", name);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            var nameExists = (int)await command.ExecuteScalarAsync();
            if (nameExists > 0)
            {
                var updatecommand = CreateCommand("[dbo].[sp_ticker_update]", System.Data.CommandType.StoredProcedure);
                updatecommand.Parameters.AddWithValue("@configurationId", configurationId);
                updatecommand.Parameters.AddWithValue("@name", name);
                updatecommand.Parameters.AddWithValue("@value", value);
                result = await updatecommand.ExecuteNonQueryAsync();
            }
            else
            {
                throw new Exception(name + " does not exist in Ticker section");
            }
            return result;
        }

        public virtual async Task<int> CheckAndCreateTicker(int configurationId)
        {
            var command = CreateCommand("[dbo].[SP_CheckAndCreateTicker]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            var result = (int)await command.ExecuteScalarAsync();
            
            return result;
        }

        public virtual async Task<IEnumerable<TickerParameter>> GetAllTickerParameters(int configurationId)
        {
            var names = "";
            var displayNames = "";

            var result = new List<TickerParameter>();
            var command = CreateCommand("[dbo].[sp_ticker_getalltickerparam]", System.Data.CommandType.StoredProcedure);
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    names = reader.GetString(0);
                    displayNames = reader.GetString(1);
                }
            }
            string[] parameterNames = names.Split(',');
            string[] parameterDisplayNames = displayNames.Split(',');
            var parameters = parameterNames.Zip(parameterDisplayNames, (namesArray, displaynamesArray) => new { Name = namesArray, displayName = displaynamesArray });
            foreach (var parameter in  parameters)
            {
                var tickerParam = new TickerParameter();
                tickerParam.Name = parameter.Name;
                tickerParam.DisplayName = parameter.displayName;
                result.Add(tickerParam);
            }

            return result;
        }

        public virtual async Task<IEnumerable<string>> GetSelectedTickerParameters(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_ticker_getselectedtickerparam]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            var result = new List<String>();
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    result.Add(reader.GetString(0));
                }
            }
            return result;
        }

        public virtual async Task<int> AddTickerParameters(int configurationId, List<string> tickerParameters)
        {
            var removeresult = 0;
            foreach (var parameter in tickerParameters)
            {
                var tickerNode = "<infoitem ticker=\"true\">"+ parameter + "</infoitem>";
                if (IsTickerItemDisabled(configurationId, parameter).Result == 1)
                {
                    var command = CreateCommand("[dbo].[sp_ticker_removetickerparam]", System.Data.CommandType.StoredProcedure);
                    command.Parameters.AddWithValue("@configurationId", configurationId);
                    command.Parameters.AddWithValue("@tickeritem", parameter);
                    removeresult = await command.ExecuteNonQueryAsync();
                }

                XmlDocument document = new XmlDocument();
                XmlNodeList tickerNodeList = null;
                var result = 0;
                try
                {
                    var command = CreateCommand("[dbo].[sp_ticker_getinfoitems]", System.Data.CommandType.StoredProcedure);
                    command.Parameters.AddWithValue("@configurationId", configurationId);

                    using var reader = await command.ExecuteReaderAsync();
                    string xmlElement = string.Empty;
                    while (await reader.ReadAsync())
                    {
                        xmlElement= reader["InfoItems"].ToString();
                    }
                    if (string.IsNullOrEmpty(xmlElement))
                    {
                        xmlElement = "<infoitems><infoitem default_flight_info =\"true\">" + parameter + "</infoitem></infoitems>";
                        document.LoadXml(xmlElement);
                        reader.Close();
                    }
                    else
                    {
                        document.LoadXml(xmlElement);
                        reader.Close();

                        tickerNodeList = document.SelectNodes("infoitems/infoitem[@ticker]");

                        XmlDocument doc = new XmlDocument();
                        doc.LoadXml(tickerNode);
                        XmlNode insertNode = document.ImportNode(doc.DocumentElement, true);
                        document.DocumentElement.InsertAfter(insertNode, tickerNodeList[tickerNodeList.Count - 1]);
                    }

                    var updateCommand = CreateCommand("[dbo].[sp_ticker_addupdatetickerparam]", System.Data.CommandType.StoredProcedure);
                    updateCommand.Parameters.AddWithValue("@configurationId", configurationId);
                    updateCommand.Parameters.Add("@xmlValue", SqlDbType.Xml).Value = document.OuterXml.ToString();

                    result = await updateCommand.ExecuteNonQueryAsync();

                }
                catch (Exception ex)
                {
                    throw ex;
                }
                 if(result !> 0 && removeresult !> 0)
                {
                    return 0;
                }
            }
            return 1;

        }

        public virtual async Task<int> IsTickerItemDisabled(int configurationId, string tickerParameterName)
        {
            var command = CreateCommand("[dbo].[sp_ticker_istickeritemdisabled]", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@tickeritem", tickerParameterName);
            int result = (int)await command.ExecuteScalarAsync();
            return result;
        }

        public virtual async Task<int> RemoveTickerParameter(int configurationId, int position)
        {
            int result = 0;
            XmlDocument document = new XmlDocument();
            XmlNodeList tickerNodeList = null;
            try
            {
                var command = CreateCommand("[dbo].[sp_ticker_getinfoitems]", System.Data.CommandType.StoredProcedure);
                command.Parameters.AddWithValue("@configurationId", configurationId);

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    document.LoadXml(reader["InfoItems"].ToString());
                }
                reader.Close();

                tickerNodeList = document.SelectNodes("infoitems/infoitem[@ticker]");
                XmlNode removeNode = null;
                if (position <= 0)
                {
                    removeNode = tickerNodeList[0];
                }
                else if (position >= tickerNodeList.Count)
                {
                    removeNode = tickerNodeList[tickerNodeList.Count - 1];
                }
                else
                {
                    removeNode = tickerNodeList[position];
                }

                removeNode.ParentNode.RemoveChild(removeNode);
            
                var updateCommand = CreateCommand("[dbo].[sp_ticker_addupdatetickerparam]", System.Data.CommandType.StoredProcedure);
                updateCommand.Parameters.AddWithValue("@configurationId", configurationId);
                updateCommand.Parameters.Add("@xmlValue", SqlDbType.Xml).Value = document.OuterXml.ToString();

                result = await updateCommand.ExecuteNonQueryAsync();
            }

            catch (Exception ex)
            {
                throw ex;
            }
            return result;

        }

        public virtual async Task<int> MoveTickerParameterPosition(int configurationId, int fromPosition, int toPosition)
        {
            int result = 0;
            XmlDocument document = new XmlDocument();
            XmlNodeList tickerNodeList = null;
            try
            {
                var command = CreateCommand("[dbo].[sp_ticker_getinfoitems]", System.Data.CommandType.StoredProcedure);
                command.Parameters.AddWithValue("@configurationId", configurationId);

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    document.LoadXml(reader["InfoItems"].ToString());
                }
                reader.Close();

                tickerNodeList = document.SelectNodes("infoitems/infoitem[@ticker]");
                XmlNode fromNode = null;
                XmlNode toNode = null;
                if (fromPosition <= 0)
                {
                    fromNode = tickerNodeList[0];
                }
                else if (fromPosition >= tickerNodeList.Count)
                {
                    fromNode = tickerNodeList[tickerNodeList.Count - 1];
                }
                else
                {
                    fromNode = tickerNodeList[fromPosition];
                }

                if (toPosition >= tickerNodeList.Count)
                {
                    fromNode.ParentNode.RemoveChild(fromNode);
                    tickerNodeList = document.SelectNodes("infoitems/infoitem[@ticker]");
                    document.DocumentElement.InsertAfter(fromNode, tickerNodeList[tickerNodeList.Count - 1]);
                }
                else if (toPosition <= 0)
                {
                    fromNode.ParentNode.RemoveChild(fromNode);
                    tickerNodeList = document.SelectNodes("infoitems/infoitem[@ticker]");
                    document.DocumentElement.InsertBefore(fromNode, tickerNodeList[0]);
                }
                else if(toPosition == (tickerNodeList.Count - 1))
                {
                    fromNode.ParentNode.RemoveChild(fromNode);
                    tickerNodeList = document.SelectNodes("infoitems/infoitem[@ticker]");
                    toNode = tickerNodeList[toPosition - 1];
                    document.DocumentElement.InsertAfter(fromNode, toNode);
                }
                else
                {
                    fromNode.ParentNode.RemoveChild(fromNode);
                    tickerNodeList = document.SelectNodes("infoitems/infoitem[@ticker]");
                    toNode = tickerNodeList[toPosition];
                    document.DocumentElement.InsertBefore(fromNode, toNode);
                }

                var updateCommand = CreateCommand("[dbo].[sp_ticker_addupdatetickerparam]", System.Data.CommandType.StoredProcedure);
                updateCommand.Parameters.AddWithValue("@configurationId", configurationId);
                updateCommand.Parameters.Add("@xmlValue", SqlDbType.Xml).Value = document.OuterXml.ToString();

                result = await updateCommand.ExecuteNonQueryAsync();
            }

            catch (Exception ex)
            {
                throw ex;
            }
            return result;
        }
    }
}
