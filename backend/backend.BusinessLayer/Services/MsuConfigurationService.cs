using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models.Fleet;
using backend.DataLayer.UnitOfWork.Contracts;

namespace backend.BusinessLayer.Services
{
    public class MsuConfigurationService : IMsuConfigurationService
    {
        private readonly IUnitOfWork _unitOfWork;

        public MsuConfigurationService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public MsuConfiguration FindMsuConfigurationById(string id)
        {
            using var context = _unitOfWork.Create;
            return context.Repositories.MsuConfigurationRepository.Find(id);
        }

        public async Task<List<MsuConfiguration>> GetAll(string aircraft_id)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.MsuConfigurationRepository.GetAll(aircraft_id);
        }
    }
}
