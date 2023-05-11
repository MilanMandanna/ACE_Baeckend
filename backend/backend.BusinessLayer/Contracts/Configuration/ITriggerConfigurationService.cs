using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json.Linq;

namespace backend.BusinessLayer.Contracts.Configuration
{
    public interface ITriggerConfigurationService
    {

        Task<IEnumerable<Trigger>> GetAllTriggers(int configurationId);
        Task<IEnumerable<TriggerParameter>> GetAllTriggerParameters(int configurationId);
        Task<DataCreationResultDTO> RemoveTrigger(int configurationId, string triggerId);
        Task<DataCreationResultDTO> AddTrigger(int configurationId, Trigger triggerData);
        Task<DataCreationResultDTO> UpdateTrigger(int configurationId, Trigger triggerData);
        DataCreationResultDTO ValidateTrigger(Trigger triggerData);
        DataCreationResultDTO BuildTriggerCondition(Trigger triggerData);


    }
}
