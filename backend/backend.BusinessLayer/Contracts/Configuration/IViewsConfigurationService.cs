using backend.DataLayer.Models.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts.Configuration
{
    public interface IViewsConfigurationService
    {
        #region Views
        Task<ConfigurationViewDTO> GetAllViewDetails(int configurationId, string type);
        Task<DataCreationResultDTO> UpdateSelectedView(int configurationId, string viewName, string updatedValue);
        Task<DataCreationResultDTO> DisableSelectedView(int configurationId, string viewName);
        Task<DataCreationResultDTO> AddSelectedView(int configurationId, string[] views);
        Task<DataCreationResultDTO> MoveSelectedView(int configurationId, string viewName, int oldPositionNumber, int newPositionNumber);
        #endregion

        Task<ConfigAvailableLocationsDTO> GetLocationsForViewType(int configurationId, string type);
        
        #region Compass
        Task<CompassLocationsDTO> GetAvailableCompassLocation(int configurationId);
        Task<AirplaneData> GetAirplaneTypes(int configurationId);
        Task<AirplaneData> GetAvailableAirplaneTypes(int configurationId);
        Task<DataCreationResultDTO> AddCompassAirplaneTypes(int configurationId, List<string> airplaneIds);
        Task<CompassColors> GetCompassColors(int configurationId);
        Task<DataCreationResultDTO> UpdateCompassColors(int configurationId, string color, string nodeName);
        Task<DataCreationResultDTO> UpdateCompassLocation(int configurationId, int index, int geoRefId);
        Task<List<string>> getCompassMakkahValues(int configurationId);
        Task<DataCreationResultDTO> UpdateCompassValues(int configurationId, string type, string data);
        #endregion

        #region Timezone
        Task<TimezoneLocationDTO> GetAvailableTimezoneLocations(int configurationId);
        Task<DataCreationResultDTO> UpdateTimezoneLocations(int configurationid, string[] listGeoRefId, string status);
        #endregion

        #region WorldClock
        Task<WorldClockLocationsDTO> GetAvailableWorlclockLocations(int configurationId);
        Task<WorldClockLocationsDTO> GetAlternateWorlclockLocations(int configurationId);
        Task<DataCreationResultDTO> MoveSelectedWorldClockLocation(int configurationId, string geoRefId, int oldPositionNumber, int newPositionNumber);
        Task<DataCreationResultDTO> UpdateWorldclockLocation(int configurationId, string[] listGeoRefId, string status);
        Task<DataCreationResultDTO> AddAlternateWorldclockCity(int configurationId, int index, int geoRefId);
        Task<IEnumerable<string>> GetTimezoneColors(int configurationId);
        Task<DataCreationResultDTO> UpdateTimezoneColors(int configurationId, string color, string node);
        #endregion

        #region Flightinfo/Your Flight/Broadcast
        Task<List<string>> GetFlightInfoParameters(string pageName, int configurationId);
        Task<List<string>> GetAvailableFlightInfoParameters(string pageName, int configurationId);
        Task<DataCreationResultDTO> AddNewFlighInfoParams(string pageName, int configurationId, List<string> listFlightInfoParams);
        Task<DataCreationResultDTO> MoveFlightInfoParameterPosition(string pageName, int configurationId, int fromPosition, int toPosition);
        Task<DataCreationResultDTO> RemoveSelectedFlightInfoParameter(string pageName, int configurationId, int nodeIndex);
        Task<DataCreationResultDTO> RemoveSelectedParameters(string pageName, int configurationId, List<string> nodeIndexList);
        #endregion

        #region Makkah
        Task<MakkahData> GetMakkahValues(int configurationId);
        Task<List<MakkahPrayerCalculationTypes>> GetMakkahPrayertimes(int configurationId);
        Task<MakkahLocations> GetMakkahLocation(int configurationId, string type);
        Task<DataCreationResultDTO> UpdateMakkahLocationAndPrayerTimeLocation(int configurationId, string data, string type);
        #endregion
    }
}
