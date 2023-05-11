using backend.DataLayer.Models.Configuration;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IViewConfigurationReposiory
    {
        #region views
        Task<ConfigurationViewDTO> GetAllViewDetails(int configurationId, string type);
        Task<int> UpdateSelectedView(int configurationId, string viewName, string updatedValue);
        Task<int> DisableSelectedView(int configurationId, string viewName);
        Task<int> AddSelectedView(int configurationId, List<string> views);
        Task<int> MoveSelectedView(int configurationId, string viewName, int oldPositionNumber, int newPositionNumber);
        #endregion

        Task<ConfigAvailableLocationsDTO> GetLocationsForViewType(int configurationId, string type);

        #region Compass
        Task<CompassLocationsDTO> GetAvailableCompassLocation(int configurationId);
        Task<AirplaneData> GetAirplaneTypes(int configurationId);
        Task<AirplaneData> GetAvailableAirplaneTypes(int configurationId);
        Task<int> AddCompassAirplaneTypes(int configurationId, List<string> airplaneIds);
        Task<CompassColors> GetCompassColors(int configurationId);
        Task<int> UpdateCompassColors(int configurationId, string color, string nodeName);
        Task<int> UpdateCompassLocation(int configurationId, int index, int geoRefId);
        Task<List<string>> getCompassMakkahValues(int configurationId);
        Task<int> UpdateCompassValues(int configurationId, string type, string data);
        #endregion

        #region Timezone
        Task<TimezoneLocationDTO> GetAvailableTimezoneLocations(int configurationId);
        Task<int> UpdateTimezoneLocations(int configurationId, List<string> listGeoRefId, string status);
        Task<IEnumerable<string>> GetTimezoneColors(int configurationId);
        Task<int> UpdateTimezoneColors(int configurationId, string color, string node);
        #endregion

        #region WorldClock
        Task<WorldClockLocationsDTO> GetAvailableWorlclockLocations(int configurationId);
        Task<WorldClockLocationsDTO> GetAlternateWorlclockLocations(int configurationId);
        Task<int> MoveSelectedWorldClockLocation(int configurationId, string geoRefId, int oldPositionNumber, int newPositionNumber);
        Task<int> UpdateWorldclockLocation(int configurationId, List<string> listGeoRefId, string status);
        Task<int> AddAlternateWorldclockCity(int configurationId, int index, int geoRefId);
        #endregion

        #region Flight Info/Broadcast/Your Flight
        Task<Dictionary<FlightInfoParams, List<string>>> GetFlightInfoParameters(string pageName, int configurationId);
        Task<Dictionary<string, string>> GetAvailableFlightInfoParameters(string pageName, int configurationId);
        Task<int> AddNewFlighInfoParams(string pageName, int configurationId, List<string> listFlightInfoParams);
        Task<int> MoveFlightInfoParameterPosition(string pageName, int configurationId, int fromPosition, int toPosition);
        Task<int> RemoveSelectedFlightInfoParameter(string pageName, int configurationId, int nodeIndex);
        Task<int> RemoveSelectedParameters(string pageName, int configurationId, List<string> nodeIndexList);
        #endregion

        #region Makkah
        Task<MakkahData> GetMakkahValues(int configurationId);
        Task<List<MakkahPrayerCalculationTypes>> GetMakkahPrayertimes(int configurationId);
        Task<MakkahLocations> GetMakkahLocation(int configurationId, string type);
        Task<int> UpdateMakkahLocationAndPrayerTimeLocation(int configurationId, string data, string type);
        #endregion

        Task<int> InserUpdateAeroplaneTyes(int configurationId, string aeroplanTypes, Guid userID);
    }
}
