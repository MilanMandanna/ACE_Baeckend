using backend.BusinessLayer.Contracts.Configuration;
using backend.BusinessLayer.Mappers;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Services.Configurations
{
    public class ViewsConfigurationService : IViewsConfigurationService
    {
        private readonly IUnitOfWork _unitOfWork;
        public ViewsConfigurationService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        #region Public Methods

        #region views
        /// <summary>
        /// 1. To get all the view from the table
        /// 2. Input is configuration ID
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns>ConfigurationViewDTO</returns>
        public async Task<ConfigurationViewDTO> GetAllViewDetails(int configurationId, string type)
        {
            ConfigurationViewDTO _configurationViewDTO = new ConfigurationViewDTO();
            using var context = _unitOfWork.Create;
            _configurationViewDTO = await context.Repositories.ViewsConfigurationRepository.GetAllViewDetails(configurationId, type);
            return _configurationViewDTO;
        }

        /// <summary>
        /// 1. Update quick select value for selected view
        /// 2. Preset can be set max for 3 views
        /// 3. If max preset is reached error will be shown
        /// 4. If not preset will be updated
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="viewName"></param>
        /// <param name="updatedValue"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> UpdateSelectedView(int configurationId, string viewName, string updatedValue)
        {
            DataCreationResultDTO dataCreationResult = new DataCreationResultDTO();
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ViewsConfigurationRepository.UpdateSelectedView(configurationId, viewName, updatedValue);
            if (result == 2)
            {
                dataCreationResult.IsError = true;
                dataCreationResult.Message = "Max preset reached";
            }
            else if (result > 0)
            {
                await context.SaveChanges();
                dataCreationResult.IsError = false;
                dataCreationResult.Message = viewName + " Preset has been updated to " + updatedValue;
            }
            else
            {
                dataCreationResult.IsError = true;
                dataCreationResult.Message = "Preset updation failed";
            }
            return dataCreationResult;
        }

        /// <summary>
        /// 1. To delete selected view
        /// 2. Enable status of the view will be updated to false
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="viewName"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> DisableSelectedView(int configurationId, string viewName)
        {
            DataCreationResultDTO dataCreationResult = new DataCreationResultDTO();
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ViewsConfigurationRepository.DisableSelectedView(configurationId, viewName);

            if (result > 0)
            {
                await context.SaveChanges();
                dataCreationResult.IsError = false;
                dataCreationResult.Message = viewName + " enable status has been updated";
            }
            else
            {
                dataCreationResult.IsError = true;
                dataCreationResult.Message = viewName + " enable status updation failed";
            }
            return dataCreationResult;
        }

        /// <summary>
        /// 1. Add new view or updated view to enable true
        /// 2. If no view with given name is available, new view will be added
        /// 3. If a view with given name exists and if view is enable status is false, then enable status will be updated to true
        /// 4. If given view's enable status is true, then it will not be updated
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="views"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> AddSelectedView(int configurationId, string[] views)
        {
            DataCreationResultDTO dataCreationResultDTO = new DataCreationResultDTO();
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ViewsConfigurationRepository.AddSelectedView(configurationId, views.ToList());
            if (result > 0)
            {
                await context.SaveChanges();
                dataCreationResultDTO.IsError = false;
                dataCreationResultDTO.Message = "Success";
            } 
            else
            {
                dataCreationResultDTO.IsError = true;
                dataCreationResultDTO.Message = "failure";
            }
            return dataCreationResultDTO;
        }

        /// <summary>
        /// 1. Move selected view to new position
        /// 2. If position is less than 0, move to top position
        /// 3. If position is greater than available view, move to last position
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="viewName"></param>
        /// <param name="positionNumber"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> MoveSelectedView(int configurationId, string viewName, int oldPositionNumber, int newPositionNumber)
        {
            DataCreationResultDTO dataCreationResultDTO = new DataCreationResultDTO();
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ViewsConfigurationRepository.MoveSelectedView(configurationId, viewName, oldPositionNumber, newPositionNumber);
            if (result == 2)
            {
                dataCreationResultDTO.IsError = false;
                dataCreationResultDTO.Message = "Node is not enabled";
            }
            else if (result > 0)
            {
                await context.SaveChanges();
                dataCreationResultDTO.IsError = false;
                dataCreationResultDTO.Message = "Node successfully repositioned";
            }
            else
            {
                dataCreationResultDTO.IsError = true;
                dataCreationResultDTO.Message = "Node repositioning failed";
            }
            return dataCreationResultDTO;
        }
        #endregion

        #region Get available locations
        /// <summary>
        /// 1. To get list of cities available for the given config ID
        /// 2. Three default values will be there in the list
        /// 3. The values are Departure, Destination and Current location
        /// 4. After deafults other values will follow.
        /// 5. This API will return values for Compass, Timezone and Worldclock
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<ConfigAvailableLocationsDTO> GetLocationsForViewType(int configurationId, string type)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ViewsConfigurationRepository.GetLocationsForViewType(configurationId, type);
        }
        #endregion

        #region Compass
        /// <summary>
        /// 1. Method to return available locations for compass view
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<CompassLocationsDTO> GetAvailableCompassLocation(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return  await context.Repositories.ViewsConfigurationRepository.GetAvailableCompassLocation(configurationId);
        }

        /// <summary>
        /// 1. Get available airplane types from compass API
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<AirplaneData> GetAirplaneTypes(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ViewsConfigurationRepository.GetAirplaneTypes(configurationId);
        }
        /// <summary>
        /// 1. Get the airplane types from tblConfigurationComponents table
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<AirplaneData> GetAvailableAirplaneTypes(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ViewsConfigurationRepository.GetAvailableAirplaneTypes(configurationId);
        }

        /// <summary>
        /// 1. Add airplane types from configurationcomponents table to the RLI table xml
        /// 2. Get airplane name based on airplane ID
        /// 3. If already xml has values then get names which are not present in xml
        /// 4. Add values to the airplane tag in the xml and update the table 
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="airplaneIds"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> AddCompassAirplaneTypes(int configurationId, List<string> airplaneIds)
        {
            DataCreationResultDTO resultDTO = new DataCreationResultDTO();
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ViewsConfigurationRepository.AddCompassAirplaneTypes(configurationId, airplaneIds);

            if (result > 0)
            {
                await context.SaveChanges();
                resultDTO.IsError = false;
                resultDTO.Message = "Success";
            }
            else
            {
                resultDTO.IsError = true;
                resultDTO.Message = "Failure";
            }
            return resultDTO;
        }

        /// <summary>
        /// 1. Method to get all the colors for the compass colors
        /// 2. Total there are 7 colors saved in the XML
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<CompassColors> GetCompassColors(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ViewsConfigurationRepository.GetCompassColors(configurationId);
        }

        /// <summary>
        /// 1. Update compass locations
        /// 2. There are 2 locations
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="color"></param>
        /// <param name="nodeName"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> UpdateCompassColors(int configurationId, string color, string nodeName)
        {
            DataCreationResultDTO dataCreationResultDTO = new DataCreationResultDTO();
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ViewsConfigurationRepository.UpdateCompassColors(configurationId, color, nodeName);

            if (result > 0)
            {
                await context.SaveChanges();
                dataCreationResultDTO.IsError = false;
                dataCreationResultDTO.Message = "Success";
            }
            else
            {
                dataCreationResultDTO.IsError = true;
                dataCreationResultDTO.Message = "Failure";
            }

            return dataCreationResultDTO;
        }

        /// <summary>
        /// 1. Update compass locations
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="index"></param>
        /// <param name="geoRefId"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> UpdateCompassLocation(int configurationId, int index, int geoRefId)
        {
            DataCreationResultDTO resultDTO = new DataCreationResultDTO();
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ViewsConfigurationRepository.UpdateCompassLocation(configurationId, index, geoRefId);
            if (result > 0)
            {
                await context.SaveChanges();
                resultDTO.IsError = false;
                resultDTO.Message = "Success";
            }
            else
            {
                resultDTO.IsError = true;
                resultDTO.Message = "Failure";
            }
            return resultDTO;
        }

        /// <summary>
        /// 1. Get makkah text and images values
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<List<string>> getCompassMakkahValues(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ViewsConfigurationRepository.getCompassMakkahValues(configurationId);
        }

        /// <summary>
        /// 1. Update compass values
        /// 2. These values effect both compass and Makkah screens
        /// 3. The values are image and text
        /// 4. Values for these are true and false
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="type"></param>
        /// <param name="data"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> UpdateCompassValues(int configurationId, string type, string data)
        {
            DataCreationResultDTO dataCreationResult = new DataCreationResultDTO();
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ViewsConfigurationRepository.UpdateCompassValues(configurationId, type, data);
            if (result > 0)
            {
                await context.SaveChanges();
                dataCreationResult.IsError = false;
                dataCreationResult.Message = "Success";
            }
            else
            {
                dataCreationResult.IsError = true;
                dataCreationResult.Message = "Failure";
            }
            return dataCreationResult;
        }
        #endregion

        #region Timezone
        /// <summary>
        /// 1. Method to return available locations for timezone view
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<TimezoneLocationDTO> GetAvailableTimezoneLocations(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ViewsConfigurationRepository.GetAvailableTimezoneLocations(configurationId);
        }

        /// <summary>
        /// 1. API will either add or remove configurations to the timezone table
        /// 2. Get the list of Locations from Georef table where isTimezonePoi = 1
        /// 3. If status is add, then add new node to the XML with data from Georef table.
        /// 4. If status is remove then delete the node from the XML which has the georef ID.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="listGeoRefId"></param>
        /// <param name="status"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> UpdateTimezoneLocations(int configurationId, string[] listGeoRefId, string status)
        {
            DataCreationResultDTO resultDTO = new DataCreationResultDTO();
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ViewsConfigurationRepository.UpdateTimezoneLocations(configurationId, listGeoRefId.ToList(), status);
            if (result > 0)
            {
                await context.SaveChanges();
                resultDTO.IsError = false;
                resultDTO.Message = "Success";
            }
            else
            {
                resultDTO.IsError = true;
                resultDTO.Message = "Failure";
            }
            return resultDTO;
        }

        /// <summary>
        /// 1. Get all timeone colors
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<IEnumerable<string>> GetTimezoneColors(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ViewsConfigurationRepository.GetTimezoneColors(configurationId);
        }

        /// <summary>
        /// 1. Update timeone colors
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="color"></param>
        /// <param name="node"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> UpdateTimezoneColors(int configurationId, string color, string node)
        {
            DataCreationResultDTO result = new DataCreationResultDTO();
            using var context = _unitOfWork.Create;
            var response = await context.Repositories.ViewsConfigurationRepository.UpdateTimezoneColors(configurationId, color, node);
            if (response > 0)
            {
                await context.SaveChanges();
                result.IsError = false;
                result.Message = "Success";
            }
            else
            {
                result.IsError = true;
                result.Message = "Failure";
            }
            return result;
        }
        #endregion

        #region WorldClock
        /// <summary>
        /// 1. Method to return available locations for worldclock view
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<WorldClockLocationsDTO> GetAvailableWorlclockLocations(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ViewsConfigurationRepository.GetAvailableWorlclockLocations(configurationId);
        }
        /// <summary>
        /// 1. Method to get all alternate locations for worldclock view
        /// 2 These locations will be considered as default locations
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<WorldClockLocationsDTO> GetAlternateWorlclockLocations(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ViewsConfigurationRepository.GetAlternateWorlclockLocations(configurationId);
        }
        /// <summary>
        /// 1. Move cities in Worldclock XML to mentioned positions
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="geoRefId"></param>
        /// <param name="position"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> MoveSelectedWorldClockLocation(int configurationId, string geoRefId, int oldPositionNumber, int newPositionNumber)
        {
            DataCreationResultDTO resultDTO = new DataCreationResultDTO();
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ViewsConfigurationRepository.MoveSelectedWorldClockLocation(configurationId, geoRefId, oldPositionNumber, newPositionNumber);

            if (result == 2)
            {
                resultDTO.IsError = false;
                resultDTO.Message = "Node is not enabled";
            }
            else if (result > 0)
            {
                await context.SaveChanges();
                resultDTO.IsError = false;
                resultDTO.Message = "Node successfully repositioned";
            }
            else
            {
                resultDTO.IsError = true;
                resultDTO.Message = "Node repositioning failed";
            }
            return resultDTO;
        }

        /// <summary>
        /// 1. API will either add or remove configurations to the worldclock table
        /// 2. Get the list of Locations from Georef table where isworldclockpoi = 1
        /// 3. If status is add, then add new node to the XML with data from Georef table.
        /// 4. If status is remove then delete the node from the XML which has the georef ID.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="listGeoRefId"></param>
        /// <param name="status"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> UpdateWorldclockLocation(int configurationId, string[] listGeoRefId, string status)
        {
            DataCreationResultDTO resultDTO = new DataCreationResultDTO();
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ViewsConfigurationRepository.UpdateWorldclockLocation(configurationId, listGeoRefId.ToList(), status);
            if (result > 0)
            {
                await context.SaveChanges();
                resultDTO.IsError = false;
                resultDTO.Message = "Success";
            }
            else
            {
                resultDTO.IsError = true;
                resultDTO.Message = "Failure";
            }
            return resultDTO;
        }

        /// <summary>
        /// 1. API to add new alternate location
        /// 2. If index is 0, then add as first default node
        /// 3. If index is 0, then remove first default node before adding new node
        /// 4. If index is 1, then add as second default node
        /// 5. If index is 1, then remove the second default node before adding the new node
        /// 6. There will be only 2 default nodes at max
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="index"></param>
        /// <param name="geoRefId"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> AddAlternateWorldclockCity(int configurationId, int index, int geoRefId)
        {
            DataCreationResultDTO resultDTO = new DataCreationResultDTO();
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ViewsConfigurationRepository.AddAlternateWorldclockCity(configurationId, index, geoRefId);
            if (result > 0)
            {
                await context.SaveChanges();
                resultDTO.IsError = false;
                resultDTO.Message = "Success";
            }
            else
            {
                resultDTO.IsError = true;
                resultDTO.Message = "Failure";
            }
            return resultDTO;
        }
        #endregion

        #region Flight Info/Broadcast/Your Flight
        /// <summary>
        /// 1. Get flight info parameters
        /// 2. Match the info from the XML with the feature set table
        /// 3. If value is available, then map the display name
        /// 4. Return the display names for values available in the XML
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<List<string>> GetFlightInfoParameters (string pageName, int configurationId)
        {
            List<string> parameters = new List<string>();
            Dictionary<FlightInfoParams, List<string>> flightInfo = new Dictionary<FlightInfoParams, List<string>>();
            using var context = _unitOfWork.Create;
            ViewConfigurationMapper _viewConfigurationMapper = new ViewConfigurationMapper();
            flightInfo = await context.Repositories.ViewsConfigurationRepository.GetFlightInfoParameters(pageName, configurationId);

            if (flightInfo != null && flightInfo.Count > 0)
            {
                parameters = _viewConfigurationMapper.MapFlightInfoParams(flightInfo);
            }
            else
            {
                parameters = null;
            }

            return parameters;
        }

        /// <summary>
        /// 1. Map flight info display names
        /// 2. Get list of flight info display names from Feature set table
        /// 3. Cross check display names with names from Featureset
        /// 4. If its available, then map the values as return values
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<List<string>> GetAvailableFlightInfoParameters(string pageName, int configurationId)
        {
            List<string> parameters = new List<string>();
            Dictionary<string, string> flightInfo = new Dictionary<string, string>();
            using var context = _unitOfWork.Create;
            ViewConfigurationMapper _viewConfigurationMapper = new ViewConfigurationMapper();
            flightInfo = await context.Repositories.ViewsConfigurationRepository.GetAvailableFlightInfoParameters(pageName, configurationId);

            if (flightInfo != null && flightInfo.Count > 0)
            {
                parameters = _viewConfigurationMapper.MapFlightInfoAvailableParams(flightInfo);
            }
            else
            {
                parameters = null;
            }

            return parameters;
        }

        /// <summary>
        /// 1. Add new parameters to flight info
        /// 2. Parameters can be repeated
        /// 3. Cross verify parameters in featureset and then update in info items xml
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="listFlightInfoParams"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> AddNewFlighInfoParams(string pageName, int configurationId, List<string> listFlightInfoParams)
        {
            using var context = _unitOfWork.Create;
            DataCreationResultDTO resultDTO = new DataCreationResultDTO();
            var result = await context.Repositories.ViewsConfigurationRepository.AddNewFlighInfoParams(pageName, configurationId, listFlightInfoParams);
            if(result > 0)
            {
                await context.SaveChanges();
                resultDTO.IsError = false;
                resultDTO.Message = "Success";
            }
            else
            {
                resultDTO.IsError = true;
                resultDTO.Message = "Failure";
            }
            return resultDTO;
        }

        /// <summary>
        /// 1. Move positions of nodes based on user input
        /// 2. Nodes position starts based on 0
        /// 3. Once node is moved to new position update the XML
        /// 4. If node position is less than 0, pick first node
        /// 5. If node position is greater than the number of nodes, pick last node.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="fromPosition"></param>
        /// <param name="toPosition"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> MoveFlightInfoParameterPosition(string pageName, int configurationId, int fromPosition, int toPosition)
        {
            using var context = _unitOfWork.Create;
            DataCreationResultDTO resultDTO = new DataCreationResultDTO();
            var result = await context.Repositories.ViewsConfigurationRepository.MoveFlightInfoParameterPosition(pageName, configurationId, fromPosition, toPosition);
            if (result > 0)
            {
                await context.SaveChanges();
                resultDTO.IsError = false;
                resultDTO.Message = "Success";
            }
            else
            {
                resultDTO.IsError = true;
                resultDTO.Message = "Failure";
            }
            return resultDTO;
        }

        /// <summary>
        /// 1. API to remove flight info parameter
        /// 2. The nodeIndex input will have the node index
        /// 3. The flight parameter in the input index will be removed from the XML
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="nodeIndex"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> RemoveSelectedFlightInfoParameter(string pageName, int configurationId, int nodeIndex)
        {
            using var context = _unitOfWork.Create;
            DataCreationResultDTO resultDTO = new DataCreationResultDTO();
            var result = await context.Repositories.ViewsConfigurationRepository.RemoveSelectedFlightInfoParameter(pageName, configurationId, nodeIndex);
            if (result > 0)
            {
                await context.SaveChanges();
                resultDTO.IsError = false;
                resultDTO.Message = "Success";
            }
            else
            {
                resultDTO.IsError = true;
                resultDTO.Message = "Failure";
            }
            return resultDTO;
        }
        /// <summary>
        /// API to remove selected list of parametrs from the xml
        /// </summary>
        /// <param name="pageName"></param>
        /// <param name="configurationId"></param>
        /// <param name="listFlightInfoParams"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> RemoveSelectedParameters(string pageName, int configurationId, List<string> nodeIndexList)
        {
            using var context = _unitOfWork.Create;
            DataCreationResultDTO resultDTO = new DataCreationResultDTO();
            var result = await context.Repositories.ViewsConfigurationRepository.RemoveSelectedParameters(pageName, configurationId, nodeIndexList);
            if (result > 0)
            {
                await context.SaveChanges();
                resultDTO.IsError = false;
                resultDTO.Message = "Success";
            }
            else
            {
                resultDTO.IsError = true;
                resultDTO.Message = "Failure";
            }
            return resultDTO;
        }
        #endregion

        #region Makkah
        /// <summary>
        /// 1. Method to get all makkah data
        /// 2. Makkah data include Secondary pointer location, prayer time location, pointer calculation method, and Makkah values
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<MakkahData> GetMakkahValues(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ViewsConfigurationRepository.GetMakkahValues(configurationId);
        }

        /// <summary>
        /// 1. Get makkah prayertime locations
        /// 2. Get values from Makkah table and cross reference with Feature set table
        /// 3. If Makkah location display name is availabel in feature set, then display the same.
        /// 4. There can be multiple location data
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<List<MakkahPrayerCalculationTypes>> GetMakkahPrayertimes(int configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ViewsConfigurationRepository.GetMakkahPrayertimes(configurationId);
        }

        /// <summary>
        /// 1.Get available Makkah locations from XML
        /// 2. Get the georef ID from XML and cross reference the Georef table and show the value
        /// 3. if no geo ref ID is available then show as Closest locaton
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<MakkahLocations> GetMakkahLocation(int configurationId, string type)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.ViewsConfigurationRepository.GetMakkahLocation(configurationId, type);
        }

        public async Task<DataCreationResultDTO> UpdateMakkahLocationAndPrayerTimeLocation(int configurationId, string data, string type)
        {
            DataCreationResultDTO resultDTO = new DataCreationResultDTO();

            using var context = _unitOfWork.Create;
            var result = await context.Repositories.ViewsConfigurationRepository.UpdateMakkahLocationAndPrayerTimeLocation(configurationId, data, type);
            
            if (result > 0)
            {
                await context.SaveChanges();
                resultDTO.IsError = false;
                resultDTO.Message = "Success";
            }
            else
            {
                resultDTO.IsError = true;
                resultDTO.Message = "Failure";
            }
            return resultDTO;
        }
        #endregion

        #endregion
    }
}
