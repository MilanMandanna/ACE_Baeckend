using backend.BusinessLayer.Contracts.Configuration;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Services.Configurations
{
    public class ScriptConfigurationService: IScriptConfigurationService
    {
        private readonly IUnitOfWork _unitOfWork;
        private ILoggerManager _logger;

        public ScriptConfigurationService(IUnitOfWork unitOfWork, ILoggerManager logger)
        {
            _unitOfWork = unitOfWork;
            _logger = logger;
        }
        public async Task<List<ScriptConfiguration>> GetScripts(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.GetScripts(configurationId);
            return result;
        }

        public async Task<DataCreationResultDTO> RemoveScript(int configurationId,int scriptId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.RemoveScript(configurationId,scriptId);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Script has been removed" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Removing Script" };
        }

        public async Task<List<ScriptForcedLanguage>> GetForcedLanguages(int configurationId, int scriptId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.GetForcedLanguages(configurationId, scriptId);
            return result;
        }

        public async Task<DataCreationResultDTO> SetForcedLanguage(int configurationId, int scriptId, string twoLetterlanguageCodes)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.SetForcedLanguage(configurationId,scriptId, twoLetterlanguageCodes);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Forced language has been updated" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error updating Forced language " };
        }

        public async Task<ScriptItemCreationResult> SaveScript(int configurationId, string scriptName, int scriptID)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.SaveScript(configurationId, scriptName, scriptID);
            if (result > 0)
            {
                await context.SaveChanges();
                return new ScriptItemCreationResult { IsError = false, Message = "Script Saved Successfully", Id = result.ToString() };

            }
            else if (result == -1)
                return new ScriptItemCreationResult { IsError = true, Message = "Script name already exists..!", Id = result.ToString() };
            return new ScriptItemCreationResult { IsError = true, Message = "Error Saving script " };
        }

        public async Task<List<ScriptItemDisplay>> GetScriptItemsByScript(int scriptId, int configurationId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.GetScriptItemsByScript(scriptId, configurationId);
            return result;
        }

        public async Task<ScriptItem> GetScriptItemDetails(int scriptId,int index, int configurationId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.GetScriptItemDetails(scriptId,index,  configurationId);
            return result;
        }

        public async Task<DataCreationResultDTO> RemoveScriptItem(int index, int scriptId, int configurationId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.RemoveScriptItem(index, scriptId, configurationId);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Script item removed Successfully" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error remving script item " };
        }

        public async Task<ScriptItemCreationResult> SaveScriptItem(ScriptItem scriptItem, int scriptId, int configurationId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.SaveScriptItem(scriptItem, scriptId, configurationId);
            if (Convert.ToInt32(result.Id) >= 0)
            {
                await context.SaveChanges();
                return new ScriptItemCreationResult { IsError = false, Message = "Script item Saved Successfully", Id = result.Id.ToString() };

            }
            return new ScriptItemCreationResult { IsError = true, Message = "Error Saving script item " };
        }

        public async Task<List<ScriptItemType>> GetScriptItemTypes(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.GetScriptItemTypes(configurationId);
            return result;
        }

        public async Task<List<ScriptForcedLanguage>> GetLanguagesOverride(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.GetLanguagesOverride(configurationId);
            return result;
        }

        public async Task<List<ScriptConfigFlightInfo>> GetFlightInfoView(int configurationId, int scriptId, int index)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.GetFlightInfoView(configurationId,scriptId,index);
            return result;
        }

        public async Task<List<ScriptConfigFlightInfoParams>> GetFlightInfoViewParameters(int configurationId, int scriptId, int index, string viewName)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.GetFlightInfoViewParameters(configurationId, scriptId, index,viewName);
            return result;
        }

        public async Task<List<ScriptConfigFlightInfoParams>> GetAvailableInfoParameters(int configurationId, int scriptId, int index, string viewName)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.GetAvailableInfoParameters(configurationId, scriptId, index,viewName);
            return result;
        }

        public async Task<DataCreationResultDTO> FlightInfoViewUpdateParameters(int configurationId, int scriptId, int index, string infoName, string selectedParameters)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.FlightInfoViewUpdateParameters(configurationId, scriptId, index, infoName, selectedParameters);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Parameter updated Saved Successfully" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Saving Parameter " };
        }

        public async Task<DataCreationResultDTO> FlightInfoAddView(int configurationId, string infoName)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.FlightInfoAddView(configurationId, infoName);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "View added Successfully" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Saving View " };
        }

        public async Task<IEnumerable<Trigger>> GetTriggers(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.GetTriggers(configurationId);
            return result;
        }

        public async Task<DataCreationResultDTO> SetFlightInfoViewForItem(int configurationId, int scriptId, int index, string selectedInfo)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.SetFlightInfoViewForItem(configurationId, scriptId, index, selectedInfo);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Info updated Successfully" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Saving Info " };
        }

        public async Task<List<ScriptItemDisplay>> MoveItemToPosition(int configurationId, int scriptId, int currentPoistion, int toPosition)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ScriptConfigurationRepository.MoveItemToPosition(configurationId, scriptId, currentPoistion, toPosition);
            await context.SaveChanges();
            return result;
        }
    }
}
