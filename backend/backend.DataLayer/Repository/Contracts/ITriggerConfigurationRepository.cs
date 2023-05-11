using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;
using Microsoft.AspNetCore.Mvc;

namespace backend.DataLayer.Repository.Contracts
{
    public interface ITriggerConfigurationRepository
    {
        Task<IEnumerable<Trigger>> GetAllTriggers(int configurationId);
        Task<int> AddTriggerItem(int configurationId, Trigger triggerData);
        Task<int> RemoveTrigger(int configurationId, string triggerId);
        Task<IEnumerable<Trigger>> GetTrigger(int configurationId, string triggerId);
    }
}
