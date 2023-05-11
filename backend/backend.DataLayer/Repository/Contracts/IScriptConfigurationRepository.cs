using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Extensions;
using Microsoft.AspNetCore.Mvc;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IScriptConfigurationRepository :
        IInsertAsync<Configuration>,
        IUpdateAsync<Configuration>,
        IDeleteAsync<Configuration>,
        IFilterAsync<Configuration>
    {
        Task<List<ScriptConfiguration>> GetScripts(int configurationId);
        Task<int> RemoveScript(int configurationId, int scriptId);
        Task<List<ScriptForcedLanguage>> GetForcedLanguages(int configurationId, int scriptId);
        Task<int> SetForcedLanguage(int configurationId, int scriptId, string twoLetterlanguageCodes);
        Task<int> SaveScript(int configurationId, string scriptName,int scriptID);
        Task<List<ScriptItemDisplay>> GetScriptItemsByScript(int scriptId, int configurationId);
        Task<ScriptItem> GetScriptItemDetails(int scriptId,int index,  int configurationId);
        Task<int> RemoveScriptItem(int index, int scriptId, int configurationId);
        Task<ScriptItemCreationResult> SaveScriptItem(ScriptItem scriptItem, int scriptId, int configurationId);
        Task<List<ScriptItemType>> GetScriptItemTypes(int configurationId);
        Task<List<ScriptForcedLanguage>> GetLanguagesOverride(int configurationId);
        Task<List<ScriptConfigFlightInfo>> GetFlightInfoView(int configurationId, int scriptId, int index);
        Task<List<ScriptConfigFlightInfoParams>> GetFlightInfoViewParameters(int configurationId, int scriptId, int index,string viewName);
        Task<List<ScriptConfigFlightInfoParams>> GetAvailableInfoParameters(int configurationId, int scriptId, int index, string viewName);
        Task<int> FlightInfoViewUpdateParameters(int configurationId, int scriptId, int index, string infoName, string selectedParameters);
        Task<int> FlightInfoAddView(int configurationId, string infoName);
        Task<IEnumerable<Trigger>> GetTriggers(int configurationId);
        Task<int> SetFlightInfoViewForItem(int configurationId, int scriptId, int index, string selectedInfo);
        Task<List<ScriptItemDisplay>> MoveItemToPosition(int configurationId, int scriptId, int currentPoistion, int toPosition);
    }
}
