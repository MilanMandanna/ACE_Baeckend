using Ace.DataLayer.Models;
using backend.DataLayer.Repository.Contracts.Actions;
using System;
using System.Collections.Generic;
using System.Text;
using backend.DataLayer.Models.Fleet;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IMsuConfigurationRepository : IRead<MsuConfiguration, string>
    {
        MsuConfiguration GetActive(string aircraft_id);
        Task<List<MsuConfiguration>> GetAll(string aircraft_id);     

    }
}
