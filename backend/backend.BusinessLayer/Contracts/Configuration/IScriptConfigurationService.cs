using backend.DataLayer.Models;
using backend.DataLayer.Models.Configuration;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Operator;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;


namespace backend.BusinessLayer.Contracts.Configuration
{
    public interface IScriptConfigurationService
    {
        Task<List<ScriptConfiguration>> GetScripts(int configurationId);
        Task<DataCreationResultDTO> RemoveScript(int configurationId,int scriptId);
        Task<List<ScriptForcedLanguage>> GetForcedLanguages(int configurationId, int scriptId);
        Task<DataCreationResultDTO> SetForcedLanguage(int configurationId,int scriptId,string twoLetterlanguageCodes);
        Task<ScriptItemCreationResult> SaveScript(int configurationId ,string scriptName,int scriptID);
        Task<List<ScriptItemDisplay>> GetScriptItemsByScript(int scriptId, int configurationId);
        Task<ScriptItem> GetScriptItemDetails(int scriptId, int index,  int configurationId);
        Task<DataCreationResultDTO> RemoveScriptItem(int index, int scriptId, int configurationId);
        Task<ScriptItemCreationResult> SaveScriptItem(ScriptItem scriptItem, int scriptId, int configurationId);
        Task<List<ScriptItemType>> GetScriptItemTypes(int configurationId);
        Task<List<ScriptForcedLanguage>> GetLanguagesOverride(int configurationId);
        Task<List<ScriptConfigFlightInfo>> GetFlightInfoView(int configurationId, int scriptId, int index);
        Task<List<ScriptConfigFlightInfoParams>> GetFlightInfoViewParameters(int configurationId, int scriptId, int index, string viewName);
        Task<List<ScriptConfigFlightInfoParams>> GetAvailableInfoParameters(int configurationId, int scriptId, int index, string viewName);
        Task<DataCreationResultDTO> FlightInfoViewUpdateParameters(int configurationId, int scriptId, int index, string infoName, string selectedParameters);
        Task<DataCreationResultDTO> FlightInfoAddView(int configurationId, string infoName);
        Task<IEnumerable<Trigger>> GetTriggers(int configurationId);
        Task<DataCreationResultDTO> SetFlightInfoViewForItem(int configurationId, int scriptId, int index, string selectedInfo);
        Task<List<ScriptItemDisplay>> MoveItemToPosition(int configurationId, int scriptId, int currentPoistion, int toPosition);


    }
}

