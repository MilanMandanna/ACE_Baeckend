using Ace.DataLayer.Models;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts.Actions;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using backend.DataLayer.Repository.Extensions;
using backend.DataLayer.Models.CustomContent;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IAircraftRepository :
        IRead<Aircraft, string>,
        IFindByIDAsync<Aircraft>,
        IUpdateAsync<Aircraft>,
        IInsertAsync<Aircraft>,
        IDeleteAsync<Aircraft>,
        IFilterAsync<Aircraft>
    {
        public Aircraft FindByTailNumber(string tailNumber);

        public void Update(Aircraft aircraft);

        Task<IEnumerable<Aircraft>> FindByIds(Guid[] guids);

        public Task<IEnumerable<Operator>> GetOperators(Guid[] airaftIds);

        Task<IEnumerable<Aircraft>> GetAircraftByConfigurationId(int configurationId);
        Task<IEnumerable<Product>> GetAircraftsProduct(Guid aircraftID);

        Task<List<BuildDefaultPartnumber>> ConfigurationDefinitionPartNumber(int configurationDefinitionId, int partNumberCollectionId, string tailNumber);


        Task<int> ConfigurationDefinitionUpdatePartNumber(PartNumber partNumberInfo);
        Task<int> GetPartNumberCollectionId(int configurationDefnitionID);

        Task<int>SetTopLevelPartnumber(string copyFileName, int configurationDefinitionID);

        Task<int> GetPartnumberId(string name);

        Task<int> SaveExtractedPartnumber(int configurationDefinitionID, int partNumberId, string partNumber);
        Task<List<BuildDefaultPartnumber>> GetDefaultPartNumber(int outputTypeID);

    }   
        
}
