using Ace.DataLayer.Models;
using backend.DataLayer.Models;
using backend.Helpers.Validator;
using backend.Mappers.DataTransferObjects.Aircraft;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using backend.DataLayer.Models.CustomContent;

namespace backend.BusinessLayer.Contracts
{
    public interface IAircraftService
    {
        Task<List<Aircraft>> FindAllAircraft();

        Aircraft FindAircraftById(Guid id);

        Aircraft FindAircraftByTailNumber(String tailNumber);

        Task<DataCreationResultDTO> Update(AircraftListDTO aircraft, UserListDTO currentUser);

        void Update(Aircraft aircraft);

        // Connectivity types
        List<ItemWithSelectionDTO> GetAircraftConnectivityTypes(string tailNumber);
        SelectionResultDTO SetAircraftConnectivityType(string tailNumber, bool isSelected, string connectionTypeName);

        Task<List<AircraftListDTO>> GetAircraftsByRoleID(string roleId);

        Task<IEnumerable<UserListDTO>> GetUsersByAircraftRights(Guid aircraftID);

        Task<DataCreationResultDTO> DeleteAircraft(Guid aircraftID);

        Task<AircraftDTO> GetAircraftDetails(string tailNumber);

        Task<DataCreationResultDTO> SelectSubscription(string tailNumber, Guid subscriptionId);

        Task<DataCreationResultDTO> DeactivateSubscription(string tailNumber);

        Task<Aircraft> GetAircraftByConfigurationId(int configurationId);
        Task<Product> GetAircraftsProduct(Guid aircraftID);

        Task<List<BuildDefaultPartnumber>> ConfigurationDefinitionPartNumber(int configurationDefinitionId,int partNumberCollectionId,string tailNumber);

        Task<DataCreationResultDTO> ConfigurationDefinitionUpdatePartNumber(PartNumber partNumberInfo);
        Task<List<BuildDefaultPartnumber>> GetDefaultPartNumber( int outputTypeID);


    }
}
