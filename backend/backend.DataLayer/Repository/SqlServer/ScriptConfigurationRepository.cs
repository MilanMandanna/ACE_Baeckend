using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Xml;
using backend.DataLayer.Helpers;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer.Queries;
using Microsoft.AspNetCore.Mvc;
using System.Xml.Serialization;
using System.IO;

namespace backend.DataLayer.Repository.SqlServer
{
    public class ScriptConfigurationRepository : SimpleRepository<Configuration>, IScriptConfigurationRepository
    {
        public ScriptConfigurationRepository(SqlConnection context, SqlTransaction transaction) :
            base(context, transaction)
        { }

        public ScriptConfigurationRepository()
        { }

        public virtual async Task<List<ScriptConfiguration>> GetScripts(int configurationId)
        {
       
             var command = CreateCommand("[dbo].[SP_GetScripts]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            List<ScriptConfiguration> lstScript = new List<ScriptConfiguration>();
            ScriptConfiguration script;
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    script = new ScriptConfiguration();
                    script.ScriptName = reader.GetString(0);
                    script.ScriptId = reader.GetInt32(1);
                    lstScript.Add(script);
                }
            }

            return lstScript;
        }

        public virtual async Task<List<ScriptForcedLanguage>> GetForcedLanguages(int configurationId, int scriptId)
        {
            try
            {
                var oldLanguageCommand = CreateCommand("[dbo].[SP_GetSelectLangOverride]");
                oldLanguageCommand.CommandType = CommandType.StoredProcedure;
                oldLanguageCommand.Parameters.AddWithValue("@configurationId", configurationId);
                oldLanguageCommand.Parameters.AddWithValue("@scriptId", scriptId);
                string oldLanguage = string.Empty;
                using (var reader = await oldLanguageCommand.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        oldLanguage = reader.GetString(0);
                    }
                }
                List<string> existingLangauages = new List<string>();

                if (!string.IsNullOrEmpty(oldLanguage))
                {
                    existingLangauages = oldLanguage.Split(',').ToList();
                }


                var command = CreateCommand("[dbo].[SP_script_GetForcedLanguages]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                string langList = string.Empty;
                string defaultLang = string.Empty;
                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        langList = reader.GetString(0);
                        defaultLang = reader.GetString(1);
                    }
                }

                List<String> Items = langList.Split(",").Select(p => (!string.IsNullOrEmpty(p.Trim()) && p.Length > 1) ? p.Trim().Substring(1).Trim() : p.Trim()).ToList();

                string combindedString = string.Join(",", Items.ToArray()) ;


                var commandSelect = CreateCommand("[dbo].[SP_script_GetLang]");
                commandSelect.CommandType = CommandType.StoredProcedure;
                commandSelect.Parameters.AddWithValue("@combindedString", combindedString.ToLower());
                Dictionary<string, string> lstLangs = new Dictionary<string, string>();
                List<ScriptForcedLanguage> scriptForcedLanguages = new List<ScriptForcedLanguage>();
                ScriptForcedLanguage forcedLanguage = null;
                using (var reader = await commandSelect.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        forcedLanguage = new ScriptForcedLanguage();
                        forcedLanguage.LanguageName = DbHelper.StringFromDb(reader["LanguageName"]);
                        forcedLanguage.LanguageCode = DbHelper.StringFromDb(reader["TwoletterID"]);
                        if (forcedLanguage.LanguageName.ToLower() == defaultLang.TrimStart('e').ToLower())
                        {
                            forcedLanguage.IsDefault = true;
                        }
                        if (existingLangauages.Contains(forcedLanguage.LanguageCode))
                        {
                            forcedLanguage.isSelected = true;
                        }
                        scriptForcedLanguages.Add(forcedLanguage);
                    }
                }
                return scriptForcedLanguages;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<int> RemoveScript(int configurationId, int scriptId)
        {
            try
            {
                IEnumerable<Mode> modes;
                var commandMode = CreateCommand("[dbo].[SP_RemoveScript]");
                commandMode.CommandType = CommandType.StoredProcedure;
                commandMode.Parameters.AddWithValue("@configurationId", configurationId);
                using (var reader = await commandMode.ExecuteReaderAsync())
                {
                    modes = await DatabaseMapper.Instance.FromReaderAsync<Mode>(reader);
                }
                if (modes.Any(x => x.ScriptId == Convert.ToString(scriptId)))
                {
                    throw new Exception("Script is referenced in Modes.");
                }
                var result = 0;

                var command = CreateCommand("[dbo].[SP_RemoveScriptDefs]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                command.Parameters.AddWithValue("@scriptId", scriptId);

                result = await command.ExecuteNonQueryAsync();
                return result > 0 && result > 0 ? 1 : 0;
            }
            catch(Exception ex)
            {
                throw ex;
            }

        }

        public virtual async Task<int> SaveScript(int configurationId, string scriptName,int scriptID)
        {
            var result = 0;

            //1.get the script def id
            //2. if not exists
            //  2.1. insert new def and maping table
            //3. if exists update the script def
            int retScriptId = 0;
            try
            {
                var lstSripts = await GetScripts(configurationId);
                var match = lstSripts.FirstOrDefault(x => x.ScriptName.Contains(scriptName, StringComparison.OrdinalIgnoreCase) && x.ScriptId != scriptID);
                if (match != null)
                {
                    return -1;
                }
                if (scriptID != 0)
                {

                    var commandUpdate = CreateCommand("[dbo].[SP_SaveScript]");
                    commandUpdate.CommandType = CommandType.StoredProcedure;
                    commandUpdate.Parameters.AddWithValue("@configurationId", configurationId);
                    commandUpdate.Parameters.AddWithValue("@scriptId", scriptID);
                    commandUpdate.Parameters.AddWithValue("@scriptName", scriptName);
                    result = commandUpdate.ExecuteNonQuery();
                    return scriptID;
                }
                int scriptDefId = 0;

                var cmdGetScriptDefId = CreateCommand("[dbo].[SP_script_SaveScript]");
                cmdGetScriptDefId.CommandType = CommandType.StoredProcedure;
                cmdGetScriptDefId.Parameters.AddWithValue("@configurationId", configurationId);

                using (var reader = await cmdGetScriptDefId.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        scriptDefId = reader.GetInt32(0);
                    }
                }
                if (scriptDefId == 0)
                {
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.LoadXml("<script_defs><script id=\"1\" name=\"" + scriptName.ToUpper().Trim() + "\"></script></script_defs>");

                    var insertCommand = CreateCommand("[dbo].[SP_XmlSaveScript]");
                    insertCommand.CommandType = CommandType.StoredProcedure;
                    insertCommand.Parameters.AddWithValue("@xml", xmlDoc.OuterXml);
                    using (var reader = await insertCommand.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            scriptDefId = DbHelper.DBValueToInt(reader[0]);
                        }
                    }

                    if (scriptDefId > 0)
                    {

                        var inserMappingCommand = CreateCommand("[dbo].[SP_XmlInsertSaveScript]");
                        inserMappingCommand.CommandType = CommandType.StoredProcedure;
                        inserMappingCommand.Parameters.AddWithValue("@configId", configurationId);
                        inserMappingCommand.Parameters.AddWithValue("@scriptDefId", scriptDefId);
                        inserMappingCommand.ExecuteNonQuery();

                    }
                    retScriptId = 1;
                }
                else
                {

                    var command = CreateCommand("[dbo].[SP_MaxScriptId]");
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@configurationId", configurationId);
                    int maxScriptId = 0;
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            maxScriptId = reader.GetInt32(0);
                        }
                    }

                    if (maxScriptId == 0)//new script id 
                    {
                        XmlDocument xmlDoc = new XmlDocument();
                        xmlDoc.LoadXml("<script id=\"1\" name=\"" + scriptName.ToUpper().Trim() + "\"></script>");
                        var insertScriptCommand = CreateCommand("[dbo].[SP_MaxScriptIdDefs]");
                        insertScriptCommand.CommandType = CommandType.StoredProcedure;
                        insertScriptCommand.Parameters.AddWithValue("@configurationId", configurationId);
                        insertScriptCommand.Parameters.AddWithValue("@xmlScript", xmlDoc.OuterXml);
                        result = insertScriptCommand.ExecuteNonQuery();
                        retScriptId = 1;

                    }
                    else
                    {
                        //insert or update
                        if (scriptID == 0)
                        {
                            //insert
                            XmlDocument xmlDoc = new XmlDocument();
                            int scriptId = maxScriptId + 1;
                            xmlDoc.LoadXml("<script id=\"" + scriptId + "\" name=\"" + scriptName.ToUpper().Trim() + "\"></script>");

                            var insertScriptCommand = CreateCommand("[dbo].[SP_script_ScriptDef]");
                            insertScriptCommand.CommandType = CommandType.StoredProcedure;
                            insertScriptCommand.Parameters.AddWithValue("@configurationId", configurationId);
                            insertScriptCommand.Parameters.AddWithValue("@xmlScript", xmlDoc.OuterXml);
                            result = insertScriptCommand.ExecuteNonQuery();
                            retScriptId = scriptId;
                        }
                    }

                }
                return retScriptId;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<ScriptItemCreationResult> SaveScriptItem(ScriptItem scriptItem, int scriptId, int configurationId)
        {

            //var result = 0;
            ScriptItemCreationResult result = new ScriptItemCreationResult();
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            XmlWriterSettings settings = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;

            XmlWriter xmlWriter = XmlWriter.Create(sb, settings);
            var ns = new XmlSerializerNamespaces(new[] { XmlQualifiedName.Empty });
            var serializer = new XmlSerializer(scriptItem.GetType());
            serializer.Serialize(xmlWriter, scriptItem, ns);

            XmlDocument xmlDoc = new XmlDocument();
            xmlDoc.LoadXml(sb.ToString());




            XmlDocument scriptItems = await GetScriptItems(configurationId, scriptId);

            XmlNode importNode = scriptItems.ImportNode(xmlDoc.DocumentElement, true);


            if (Convert.ToInt32(scriptItem.Index) == -1)//Add new child
            {
                scriptItems.DocumentElement.AppendChild(importNode);
                scriptItem.Index = Convert.ToString(scriptItems.DocumentElement.ChildNodes.Count - 1);
                result.Id= Convert.ToString(scriptItems.DocumentElement.ChildNodes.Count - 1);
            }
            else
            {
                var oldNode = scriptItems.SelectNodes("/script/item").Item(Convert.ToInt32(scriptItem.Index));
                scriptItems.ChildNodes.Item(0).ChildNodes.Item(Convert.ToInt32(scriptItem.Index)).ParentNode.ReplaceChild(importNode, oldNode);
                result.Id = scriptItem.Index;

            }
            result.Result = await SaveScriptItems(configurationId, scriptId, scriptItems);
            return result;

        }

        public virtual async Task<int> RemoveScriptItem(int index, int scriptId, int configurationId)
        {
            var result = 0;
            


            XmlDocument xmlNodes = await GetScriptItems(configurationId, scriptId);
            var xmlNodeList = xmlNodes.SelectSingleNode("/script");
            var node = xmlNodeList.ChildNodes.Item(index);
            node.ParentNode.RemoveChild(node);

            result = await SaveScriptItems(configurationId, scriptId, xmlNodes);

            return result > 0 && result > 0 ? 1 : 0;

        }

        public virtual async Task<List<ScriptItemDisplay>> GetScriptItemsByScript(int scriptId, int configurationId)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_GetScriptItemsByScript]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                command.Parameters.AddWithValue("@scriptId", scriptId);
                List<ScriptItemDisplay> scriptItems = new List<ScriptItemDisplay>();
                ScriptItemDisplay scriptItemDisplay;
                using (var reader = await command.ExecuteReaderAsync())
                {
                    int index = 0;
                    while (await reader.ReadAsync())
                    {
                        scriptItemDisplay = new ScriptItemDisplay();
                        scriptItemDisplay.DisplayName = reader.GetString(0);
                        scriptItemDisplay.Index = index;
                        scriptItems.Add(scriptItemDisplay);
                        index++;
                    }
                }
                var itemType = await GetScriptItemTypes(configurationId);
                foreach (var item in scriptItems)
                {   

                    var match = itemType.FirstOrDefault(x => x.Name.Contains(item.DisplayName, StringComparison.OrdinalIgnoreCase));
                    if (match != null)
                    {
                        item.DisplayName = itemType.Where(o => o.Name.ToLower() == item.DisplayName.ToLower()).ToList()[0].DisplayName;
                    }

                }
                return scriptItems;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
        public virtual async Task<ScriptItem> GetScriptItemDetails(int scriptId, int index,  int configurationId)
        {
            var xmlScriptItems = await GetScriptItems(configurationId, scriptId);
            var xmlNodeList = xmlScriptItems.SelectSingleNode("/script");
            XmlNode node = xmlNodeList.ChildNodes.Item(index);
            ScriptItem scriptItem = new ScriptItem();
            var serializer = new XmlSerializer(scriptItem.GetType());
            MemoryStream stm = new MemoryStream();
            StreamWriter stw = new StreamWriter(stm);
            stw.Write(node.OuterXml);
            stw.Flush();
            stm.Position = 0;

            ScriptItem result = serializer.Deserialize(stm) as ScriptItem;
            if (!string.IsNullOrEmpty(result.TriggerId))
            {
                var triggerInfo = await GetTrigger(configurationId, result.TriggerId);
                result.TriggerName = triggerInfo.ToList()[0].Name;
            }
            if (!string.IsNullOrEmpty(result.LanguageInCycle))
            {
                var laguages = await GetLanguagesOverride(configurationId);
                result.LanguageName = laguages.Where(o => o.LanguageCode == result.LanguageInCycle).ToList()[0].LanguageName;
            }
            var itemType = await GetScriptItemTypes(configurationId);

            var match = itemType.FirstOrDefault(x => x.Name.Contains(result.ItemType, StringComparison.OrdinalIgnoreCase));
            if (match != null)
            {
                result.ItemTypeText = itemType.Where(o => o.Name.ToLower() == result.ItemType.ToLower()).ToList()[0].DisplayName;
            }
            else
                result.ItemTypeText = result.ItemType;
            result.Index = index.ToString();
            return result;
        }

        public async Task<IEnumerable<Trigger>> GetTrigger(int configurationId, string triggerId)
        {
            var command = CreateCommand("cust.SP_Trigger_Get", System.Data.CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@triggerId", triggerId);
            using (var reader = await command.ExecuteReaderAsync())
            {
                return await DatabaseMapper.Instance.FromReaderAsync<Trigger>(reader);
            }
        }
        public virtual async Task<int> SetForcedLanguage(int configurationId, int scriptId, string twoLetterlanguageCodes)
        {
            var result = 0;
            try
            {
                var command = CreateCommand("[dbo].[SP_Script_SetForcedLanguage]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                command.Parameters.AddWithValue("@scriptId", scriptId);
                string oldLanguage = string.Empty;
                using (var reader = await command.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        oldLanguage = reader.GetString(0);
                    }
                }
                if (!string.IsNullOrEmpty(oldLanguage))
                {
                    if (string.IsNullOrEmpty(twoLetterlanguageCodes))
                    {

                        var commandDelete = CreateCommand("[dbo].[SP_RemoveForcedLang]");
                        commandDelete.CommandType = CommandType.StoredProcedure;
                        commandDelete.Parameters.AddWithValue("@configurationId", configurationId);
                        commandDelete.Parameters.AddWithValue("@scriptId", scriptId);
                        result = commandDelete.ExecuteNonQuery();
                        return result > 0 && result > 0 ? 1 : 0;
                    }
                }
                if (string.IsNullOrEmpty(oldLanguage))
                {

                    var commandInsert = CreateCommand("[dbo].[SP_script_OldLanguage]");
                    commandInsert.CommandType = CommandType.StoredProcedure;
                    commandInsert.Parameters.AddWithValue("@configurationId", configurationId);
                    commandInsert.Parameters.AddWithValue("@scriptId", scriptId);
                    commandInsert.Parameters.AddWithValue("@twoLetterlanguageCodes", twoLetterlanguageCodes.Trim());
                    result = commandInsert.ExecuteNonQuery();
                }
                else
                {

                    var commandUpdate = CreateCommand("[dbo].[SP_UpdateOldLanguage]");
                    commandUpdate.CommandType = CommandType.StoredProcedure;
                    commandUpdate.Parameters.AddWithValue("@configurationId", configurationId);
                    commandUpdate.Parameters.AddWithValue("@scriptId", scriptId);
                    commandUpdate.Parameters.AddWithValue("@twoLetterlanguageCodes", twoLetterlanguageCodes.Trim());
                    result = commandUpdate.ExecuteNonQuery();

                }
                return result > 0 && result > 0 ? 1 : 0;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
        public virtual async Task<List<ScriptItemType>> GetScriptItemTypes(int configurationId)
        {
            var names = "";
            var displayNames = "";
            try
            {
                var command = CreateCommand("[dbo].[SP_GetScriptItemTypes]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                string scriptType = string.Empty;
                using (var reader = await command.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        names = reader.GetString(0);
                        displayNames = reader.GetString(1);
                    }
                }
                string[] parameterNames = names.Split(',');
                string[] parameterDisplayNames = displayNames.Split(',');
                var parameters = parameterNames.Zip(parameterDisplayNames, (namesArray, displaynamesArray) => new { Name = namesArray, displayName = displaynamesArray });
                var result = new List<ScriptItemType>();
                foreach (var parameter in parameters)
                {
                    var tickerParam = new ScriptItemType();
                    tickerParam.Name = parameter.Name;
                    tickerParam.DisplayName = parameter.displayName;
                    result.Add(tickerParam);
                }
                return result;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<List<ScriptForcedLanguage>> GetLanguagesOverride(int configurationId)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_GetLanguagesOverride]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                string langList = string.Empty;
                string defaultLang = string.Empty;
                using (var reader = await command.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        langList = reader.GetString(0);
                        defaultLang = reader.GetString(1);
                    }
                }

                List<String> Items = langList.Split(",").Select(p => (!string.IsNullOrEmpty(p) && p.Length > 1) ? p.Substring(1) : p).ToList();

                string combindedString = string.Join(",", Items.ToArray());


                var commandSelect = CreateCommand("[dbo].[SP_GetSelectLangOverrideCombinedString]");
                commandSelect.CommandType = CommandType.StoredProcedure;
                commandSelect.Parameters.AddWithValue("@combindedString", combindedString);
                Dictionary<string, string> lstLangs = new Dictionary<string, string>();
                List<ScriptForcedLanguage> scriptForcedLanguages = new List<ScriptForcedLanguage>();
                ScriptForcedLanguage forcedLanguage = null;
                using (var reader = await commandSelect.ExecuteReaderAsync())
                {
                    while (await reader.ReadAsync())
                    {
                        forcedLanguage = new ScriptForcedLanguage();
                        forcedLanguage.LanguageName = reader.GetString(0);
                        forcedLanguage.LanguageCode = reader.GetString(1).ToLower();
                        if (forcedLanguage.LanguageName.ToLower() == defaultLang.TrimStart('e').ToLower())
                        {
                            forcedLanguage.IsDefault = true;
                        }
                        scriptForcedLanguages.Add(forcedLanguage);
                    }
                }
                return scriptForcedLanguages;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<List<ScriptConfigFlightInfo>> GetFlightInfoView(int configurationId, int scriptId, int index)
        {

 

            var xmlScriptItems = await GetScriptItems(configurationId, scriptId);
            var xmlNodeList = xmlScriptItems.SelectSingleNode("/script");
            XmlNode node = xmlNodeList.ChildNodes.Item(index);
            ScriptItem scriptItem = new ScriptItem();
            var serializer = new XmlSerializer(scriptItem.GetType());
            MemoryStream stm = new MemoryStream();
            StreamWriter stw = new StreamWriter(stm);
            stw.Write(node.OuterXml);
            stw.Flush();
            stm.Position = 0;

            ScriptItem selectedItem = serializer.Deserialize(stm) as ScriptItem;
            try
            {
                var commandAvailableInfo = CreateCommand("[dbo].[SP_GetFlightInfoView]");
                commandAvailableInfo.CommandType = CommandType.StoredProcedure;
                commandAvailableInfo.Parameters.AddWithValue("@configurationId", configurationId);

                List<ScriptConfigFlightInfo> lstFlightInfo = new List<ScriptConfigFlightInfo>();

                using (var reader = await commandAvailableInfo.ExecuteReaderAsync())
                {
                    ScriptConfigFlightInfo scriptConfigFlightInfo;
                    while (await reader.ReadAsync())
                    {
                        scriptConfigFlightInfo = new ScriptConfigFlightInfo();
                        var infoName = reader.GetString(0);
                        scriptConfigFlightInfo.InfoName = infoName;
                        if (infoName == selectedItem.InfoPage)
                        {
                            scriptConfigFlightInfo.isSelected = true;
                        }
                        lstFlightInfo.Add(scriptConfigFlightInfo);

                    }
                }

                return lstFlightInfo;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<List<ScriptConfigFlightInfoParams>> GetSelectedFlightInfoViewParameters(int configurationId, int scriptId, int index)
        {
            var xmlScriptItems = await GetScriptItems(configurationId, scriptId);
            var xmlNodeList = xmlScriptItems.SelectSingleNode("/script");

            XmlNode node = xmlNodeList.ChildNodes.Item(index);
            ScriptItem scriptItem = new ScriptItem();
            var serializer = new XmlSerializer(scriptItem.GetType());
            MemoryStream stm = new MemoryStream();
            StreamWriter stw = new StreamWriter(stm);
            stw.Write(node.OuterXml);
            stw.Flush();
            stm.Position = 0;

            ScriptItem selectedItem = serializer.Deserialize(stm) as ScriptItem;

            List<string> Infoparams= selectedItem.InfoItems.Trim().Split(',').ToList();
            List<ScriptConfigFlightInfoParams> lstInfoParams = new List<ScriptConfigFlightInfoParams>();
            ScriptConfigFlightInfoParams scriptConfigFlightInfo;
            foreach (var item in Infoparams)
            {
                if (!string.IsNullOrEmpty(item))
                {
                    scriptConfigFlightInfo = new ScriptConfigFlightInfoParams();
                    scriptConfigFlightInfo.DisplayName = item.Trim('\t', '\n').TrimStart('e');
                    scriptConfigFlightInfo.ParamName = item;
                    lstInfoParams.Add(scriptConfigFlightInfo);
                }
            }

            return lstInfoParams;
        }

        public virtual async Task<List<ScriptConfigFlightInfoParams>> GetFlightInfoViewParameters(int configurationId, int scriptId, int index,string viewName)
        {
            //var xmlScriptItems = await GetScriptItems(configurationId, scriptId);
            //var xmlNodeList = xmlScriptItems.SelectSingleNode("/script");

            //XmlNode node = xmlNodeList.ChildNodes.Item(index);
            //ScriptItem scriptItem = new ScriptItem();
            //var serializer = new XmlSerializer(scriptItem.GetType());
            //MemoryStream stm = new MemoryStream();
            //StreamWriter stw = new StreamWriter(stm);
            //stw.Write(node.OuterXml);
            //stw.Flush();
            //stm.Position = 0;

            //ScriptItem selectedItem = serializer.Deserialize(stm) as ScriptItem;

            //List<string> Infoparams = selectedItem.InfoItems.Trim().Split(',').ToList();
           
            var command = CreateCommand("[dbo].[SP_GetFlightInfoViewParam]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@viewName", viewName);
            string Infoparams = string.Empty;
            using (var reader = await command.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    Infoparams = reader.GetString(0);
                }
            }
            List<ScriptConfigFlightInfoParams> lstInfoParams = new List<ScriptConfigFlightInfoParams>();
            ScriptConfigFlightInfoParams scriptConfigFlightInfo;
            foreach (var item in Infoparams.Split(','))
            {
                if (!string.IsNullOrEmpty(item))
                {
                    scriptConfigFlightInfo = new ScriptConfigFlightInfoParams();
                    scriptConfigFlightInfo.DisplayName = item.Trim('\t', '\n').TrimStart('e');
                    scriptConfigFlightInfo.ParamName = item;
                    lstInfoParams.Add(scriptConfigFlightInfo);
                }
            }

            return lstInfoParams;
        }

        public virtual async Task<List<ScriptConfigFlightInfoParams>> GetAvailableInfoParameters(int configurationId, int scriptId, int index,string viewName)
        {

            //var xmlScriptItems = await GetScriptItems(configurationId, scriptId);
            //var xmlNodeList = xmlScriptItems.SelectSingleNode("/script");

            //XmlNode node = xmlNodeList.ChildNodes.Item(index);
            //ScriptItem scriptItem = new ScriptItem();
            //var serializer = new XmlSerializer(scriptItem.GetType());
            //MemoryStream stm = new MemoryStream();
            //StreamWriter stw = new StreamWriter(stm);
            //stw.Write(node.OuterXml);
            //stw.Flush();
            //stm.Position = 0;

            //ScriptItem selectedItem = serializer.Deserialize(stm) as ScriptItem;

            var selectedParams = await GetFlightInfoViewParameters(configurationId, scriptId, index, viewName);

            
            var command = CreateCommand("[dbo].[SP_GetFlightInfoViewParameters]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            List<ScriptConfigFlightInfoParams> lstParams = new List<ScriptConfigFlightInfoParams>();
            using (var reader = await command.ExecuteReaderAsync())
            {
                ScriptConfigFlightInfoParams scriptConfigFlightInfoParams;
                while (await reader.ReadAsync())
                {
                    scriptConfigFlightInfoParams = new ScriptConfigFlightInfoParams();

                    var name = reader.GetString(0).Trim('\t', '\n');
                    if (selectedParams.Any(i => i.ParamName == name))
                    {
                        scriptConfigFlightInfoParams.isSelected = true;
                    }
                    scriptConfigFlightInfoParams.ParamName = name;
                    scriptConfigFlightInfoParams.DisplayName = name.TrimStart('e');
                    lstParams.Add(scriptConfigFlightInfoParams);
                }
            }
            return lstParams;
        }

        public virtual async Task<int> FlightInfoViewUpdateParameters(int configurationId, int scriptId, int index, string infoName, string selectedParameters)
        {
            int result = 0;


            var xmlScriptItems = await GetScriptItems(configurationId, scriptId);
            var xmlNodeList = xmlScriptItems.SelectSingleNode("/script");

            XmlNode node = xmlNodeList.ChildNodes.Item(index);
            ScriptItem scriptItem = new ScriptItem();
            var serializer = new XmlSerializer(scriptItem.GetType());
            MemoryStream stm = new MemoryStream();
            StreamWriter stw = new StreamWriter(stm);
            stw.Write(node.OuterXml);
            stw.Flush();
            stm.Position = 0;
            var infoItems = selectedParameters;
            ScriptItem selectedItem = serializer.Deserialize(stm) as ScriptItem;
            if (selectedItem.InfoPage == infoName)
            {
                //infoItems = selectedParameters + "," + selectedItem.InfoItems;
                selectedItem.InfoItems = infoItems;
            }

            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            XmlWriterSettings settings = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;

            XmlWriter xmlWriter = XmlWriter.Create(sb, settings);
            var ns = new XmlSerializerNamespaces(new[] { XmlQualifiedName.Empty });
            serializer = new XmlSerializer(scriptItem.GetType());
            serializer.Serialize(xmlWriter, selectedItem, ns);

            XmlDocument xmlDoc = new XmlDocument();
            xmlDoc.LoadXml(sb.ToString());

            //XmlDocument scriptItems = await GetScriptItems(configurationId, scriptId);

            XmlNode importNode = xmlScriptItems.ImportNode(xmlDoc.DocumentElement, true);
            var oldNode = xmlScriptItems.SelectNodes("/script/item").Item(index);
            xmlScriptItems.ChildNodes.Item(0).ChildNodes.Item(index).ParentNode.ReplaceChild(importNode, oldNode);
            result = await SaveScriptItems(configurationId, scriptId, xmlScriptItems);
            try
            {
                var commandUpdateViewInfo = CreateCommand("[dbo].[SP_FlightInfoViewUpdateParameters]");
                commandUpdateViewInfo.CommandType = CommandType.StoredProcedure;
                commandUpdateViewInfo.Parameters.AddWithValue("@configurationId", configurationId);
                commandUpdateViewInfo.Parameters.AddWithValue("@infoName", infoName);
                commandUpdateViewInfo.Parameters.AddWithValue("@infoItems", infoItems);
                result = await commandUpdateViewInfo.ExecuteNonQueryAsync();

                return result > 0 && result > 0 ? 1 : 0;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<int> FlightInfoAddView(int configurationId, string infoName)
        {
            var result = 0;
            try
            {
                var commandAvailableInfo = CreateCommand("[dbo].[SP_Script_CountFlightInfoAddView]");
                commandAvailableInfo.CommandType = CommandType.StoredProcedure;
                commandAvailableInfo.Parameters.AddWithValue("@configurationId", configurationId);
                commandAvailableInfo.Parameters.AddWithValue("@infoName", infoName);
                var count = 0;
                using (var reader = await commandAvailableInfo.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        count = reader.GetInt32(0);
                    }
                }

                if (count > 0)
                {
                    throw new Exception("Flight view name already exists.");
                }

                var strXml = "<infopage infoitems=\"\" name=\"" + infoName + "\" />";


                var command = CreateCommand("[dbo].[SP_FlightInfo]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                command.Parameters.AddWithValue("@strXml", strXml);
                result = await command.ExecuteNonQueryAsync();
                return result > 0 && result > 0 ? 1 : 0;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<IEnumerable<Trigger>> GetTriggers(int configurationId)
        {
            IEnumerable<Trigger> triggers;

            var command = CreateCommand("[dbo].[SP_GetTriggers]");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@configurationId", configurationId);
            using (var reader = await command.ExecuteReaderAsync())
            {
                triggers = await DatabaseMapper.Instance.FromReaderAsync<Trigger>(reader);
            }

            return triggers;
        }

        public virtual async Task<int> SetFlightInfoViewForItem(int configurationId, int scriptId, int index, string selectedInfo)
        {
            int result = 0;


            var cmdGetSelectedInfoParams = CreateCommand("[dbo].[SP_SetFlightInfoViewForItem]");
            cmdGetSelectedInfoParams.CommandType = CommandType.StoredProcedure;
            cmdGetSelectedInfoParams.Parameters.AddWithValue("@ConfigurationID", configurationId);
            cmdGetSelectedInfoParams.Parameters.AddWithValue("@selectedInfo", selectedInfo.ToUpper());

            var selectedViewParams = string.Empty;

            using (var reader = await cmdGetSelectedInfoParams.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    selectedViewParams = reader.GetString(0);
                }
            }

            

            var xmlScriptItems = await GetScriptItems(configurationId, scriptId);
            var xmlNodeList = xmlScriptItems.SelectSingleNode("/script");

            XmlNode node = xmlNodeList.ChildNodes.Item(index);
            ScriptItem scriptItem = new ScriptItem();
            var serializer = new XmlSerializer(scriptItem.GetType());
            MemoryStream stm = new MemoryStream();
            StreamWriter stw = new StreamWriter(stm);
            stw.Write(node.OuterXml);
            stw.Flush();
            stm.Position = 0;
            ScriptItem selectedItem = serializer.Deserialize(stm) as ScriptItem;

            selectedItem.InfoItems = selectedViewParams;
            selectedItem.InfoPage = selectedInfo;
            scriptItem.Index = index.ToString();
            //deserialize and save it
            System.Text.StringBuilder sb = new System.Text.StringBuilder();
            XmlWriterSettings settings = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;

            XmlWriter xmlWriter = XmlWriter.Create(sb, settings);
            var ns = new XmlSerializerNamespaces(new[] { XmlQualifiedName.Empty });
            serializer = new XmlSerializer(scriptItem.GetType());
            serializer.Serialize(xmlWriter, selectedItem, ns);

            XmlDocument xmlDoc = new XmlDocument();
            xmlDoc.LoadXml(sb.ToString());

            XmlNode importNode = xmlScriptItems.ImportNode(xmlDoc.DocumentElement, true);
            var oldNode = xmlScriptItems.SelectNodes("/script/item").Item(index);
            xmlScriptItems.ChildNodes.Item(0).ChildNodes.Item(index).ParentNode.ReplaceChild(importNode, oldNode);
            result = await SaveScriptItems(configurationId, scriptId, xmlScriptItems);

            return result > 0 && result > 0 ? 1 : 0;
        }


        private async Task<XmlDocument> GetScriptItems(int configurationId, int scriptId)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_GetScriptItems]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@ConfigurationID", configurationId);
                command.Parameters.AddWithValue("@scriptId", scriptId);

                string xmlScriptItems = string.Empty;
                using (var reader = await command.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        xmlScriptItems = reader.GetString(0);
                    }
                }

                XmlDocument document = new XmlDocument();
                document.LoadXml(xmlScriptItems);

                XmlNodeList nodeList = document.SelectNodes("script/item");
                return document;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        private async Task<int> SaveScriptItems(int configurationId, int scriptId, XmlDocument xmlNodeList)
        {
            try
            {
                XmlDocument document = new XmlDocument();
                int result = await RemoveScriptItems(configurationId, scriptId);
                string strXmlitem = string.Empty;
                foreach (XmlNode node in xmlNodeList.ChildNodes[0].ChildNodes)
                {
                    strXmlitem += node.OuterXml + ",";
                }

                //replace with curren item list for the script


                var command = CreateCommand("[dbo].[SP_SaveScriptItems]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                command.Parameters.AddWithValue("@strXmlitem", strXmlitem.TrimEnd(','));
                command.Parameters.AddWithValue("@scriptId", scriptId);
                result = await command.ExecuteNonQueryAsync();
                return result > 0 && result > 0 ? 1 : 0;
                //command.Parameters.AddWithValue("@xmlScriptItem", xmlDoc.OuterXml);
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        private async Task<int> RemoveScriptItems(int configurationId, int scriptId)
        {
            try
            {
                var command = CreateCommand("[dbo].[SP_RemoveSCriptItems]");
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@configurationId", configurationId);
                command.Parameters.AddWithValue("@scriptId", scriptId);

                var result = await command.ExecuteNonQueryAsync();
                return result > 0 && result > 0 ? 1 : 0;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<List<ScriptItemDisplay>> MoveItemToPosition(int configurationId, int scriptId, int currentPoistion, int toPosition)
        {
            XmlDocument scriptItems = await GetScriptItems(configurationId, scriptId);

            XmlNodeList xmlNodeList = scriptItems.SelectNodes("/script/item");
            if (toPosition != currentPoistion)
            {
                if (toPosition > currentPoistion)
                {
                    XmlNode xmlNode = xmlNodeList.Item(currentPoistion);
                    XmlNode xmlNodeToPosition = xmlNodeList.Item(toPosition);
                    xmlNode.ParentNode.RemoveChild(xmlNode);
                    xmlNodeList.Item(toPosition).ParentNode.InsertAfter(xmlNode, xmlNodeToPosition);
                }
                else
                {
                    XmlNode xmlNode = xmlNodeList.Item(currentPoistion);
                    XmlNode xmlNodeToPosition = xmlNodeList.Item(toPosition);
                    xmlNode.ParentNode.RemoveChild(xmlNode);
                    xmlNodeList.Item(toPosition).ParentNode.InsertBefore(xmlNode, xmlNodeToPosition);
                }
            }

            var result = await SaveScriptItems(configurationId, scriptId, scriptItems);
            return await GetScriptItemsByScript(scriptId, configurationId);
        }
    }
}
