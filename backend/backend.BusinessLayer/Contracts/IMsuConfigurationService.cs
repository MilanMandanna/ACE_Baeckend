using System;
using System.Collections.Generic;
using System.Text;
using backend.DataLayer.Models.Fleet;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts
{
    public interface IMsuConfigurationService
    {
        MsuConfiguration FindMsuConfigurationById(string id);
        Task<List<MsuConfiguration>> GetAll(string aircraft_id);
    }
}
