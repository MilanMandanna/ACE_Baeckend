using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts.Configuration;
using backend.DataLayer.Models.Configuration;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace backend.Controllers.Configurations
{
    /*
     * Controller to handle API for View
     */
    [Route("api/[controller]")]
    [ApiController]
    public class ViewConfigurationController : PortalController
    {
        private ILoggerManager _logger;
        private IViewsConfigurationService _viewsConfigurationService;

        public ViewConfigurationController(ILoggerManager logger, IViewsConfigurationService viewsConfigurationService)
        {
            _logger = logger;
            _viewsConfigurationService = viewsConfigurationService;
        }

        #region Views
        /// <summary>
        /// 1. To get all the view from the table
        /// 2. Input is configuration ID
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/views")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<ConfigurationViewDTO>> GetAllViewDetails(string configurationId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetAllViewDetails(Int32.Parse(configurationId), "all"));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
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
        [HttpPost]
        [Route("{configurationId}/views/preset/{viewname}/to/{value}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateSelectedView(string configurationId, string viewName, string value)
        {
            try
            {
                return Ok(await _viewsConfigurationService.UpdateSelectedView(Int32.Parse(configurationId), viewName, value));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. To delete selected view
        /// 2. Enable status of the view will be updated to false
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="viewName"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/views/delete/{viewname}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> DisableSelectedView(string configurationId, string viewName)
        {
            try
            {
                return Ok(await _viewsConfigurationService.DisableSelectedView(Int32.Parse(configurationId), viewName));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
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
        [HttpPost]
        [Route("{configurationId}/views/add")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> AddSelectedView(string configurationId, string[] views)
        {
            try
            {
                return Ok(await _viewsConfigurationService.AddSelectedView(Int32.Parse(configurationId), views));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. Move selected view to new position
        /// 2. If position is less than 0, move to top position
        /// 3. If position is greater than available view, move to last position
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="viewName"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/views/move/{viewname}/from/{oldPosition}/to/{newPosition}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> MoveSelectedView(string configurationId, string viewName, string oldPosition, string newPosition)
        {
            try
            {
                return Ok(await _viewsConfigurationService.MoveSelectedView(int.Parse(configurationId), viewName, int.Parse(oldPosition), int.Parse(newPosition)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. To get all disabled the view from the table
        /// 2. Input is configuration ID
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/views/get")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<ConfigurationViewDTO>> GetViewsDetails(string configurationId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetAllViewDetails(Int32.Parse(configurationId), "disabled"));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }
        #endregion

        #region Get available locations
        /// <summary>
        /// 1. To get list of cities available for the given config ID
        /// 2. Three default values will be there in the list
        /// 3. The values are Departure, Destination and Current location
        /// 4. After defaults other values will follow.
        /// 5. This API will return values for Compass, Timezone and Worldclock
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/locations/{type}/available")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]

        public async Task<ActionResult<ConfigAvailableLocationsDTO>> GetLocationsForViewType(string configurationId, string type)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetLocationsForViewType(int.Parse(configurationId), type));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }
        #endregion

        #region Compass
        /// <summary>
        /// 1. API to get all available locations for compass view
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/compass/locations")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<CompassLocationsDTO>> GetAvailableCompassLocation(string configurationId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetAvailableCompassLocation(Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. Get available airplane types from compass API
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/compass/airplanetypes")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<AirplaneData>> GetAirplaneTypes(string configurationId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetAirplaneTypes(Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. Get the airplane types from tblConfigurationComponents table
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/compass/airplanetypes/available")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<AirplaneData>> GetAvailableAirplaneTypes(string configurationId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetAvailableAirplaneTypes(Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
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
        [HttpPost]
        [Route("{configurationId}/compass/airplanetypes")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> AddCompassAirplaneTypes(string configurationId, List<string> airplaneIds)
        {
            try
            {
                return Ok(await _viewsConfigurationService.AddCompassAirplaneTypes(Int32.Parse(configurationId), airplaneIds));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. Method to get all the colors for the compass colors
        /// 2. Total there are 7 colors saved in the XML
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/compass/colors")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<CompassColors>> GetCompassColors(string configurationId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetCompassColors(Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. Method to update colors for compass
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="color"></param>
        /// <param name="nodeName"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/compass/colors/{color}/node/{nodeName}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]

        public async Task<ActionResult<DataCreationResultDTO>> UpdateCompassColors(string configurationId, string color, string nodeName)
        {
            try
            {
                return Ok(await _viewsConfigurationService.UpdateCompassColors(int.Parse(configurationId), color, nodeName));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. Update compass locations
        /// 2. There are 2 locations
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="index"></param>
        /// <param name="geoRefId"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/compass/location/set/{index}/to/{geoRefId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateCompassLocation(string configurationId, string index, string geoRefId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.UpdateCompassLocation(Int32.Parse(configurationId), int.Parse(index), Int32.Parse(geoRefId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. Get makkah text and images values
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/compass/makkah/values")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<string>>> getCompassMakkahValues(string configurationId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.getCompassMakkahValues(Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
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
        [HttpPost]
        [Route("{configurationId}/compass/values/{type}/to/{data}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateCompassValues(string configurationId, string type, string data)
        {
            try
            {
                return Ok(await _viewsConfigurationService.UpdateCompassValues(Int32.Parse(configurationId), type, data));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }
        #endregion

        #region Timezone
        /// <summary>
        /// 1. API to get all available locations for timezone view
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/timezone/locations")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<TimezoneLocationDTO>> GetAvailableTimezoneLocations(string configurationId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetAvailableTimezoneLocations(Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. API will add configurations to the timezone table
        /// 2. Get the list of Locations from Georef table where isTimezonePoi = 1
        /// 3. If status is add, then add new node to the XML with data from Georef table.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="listGeoRefId"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/timezone/locations/add")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> AddTimezoneLocations(string configurationId, string[] listGeoRefId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.UpdateTimezoneLocations(Int32.Parse(configurationId), listGeoRefId, "add"));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. API will remove configurations to the timezone table
        /// 2. Get the list of Locations from Georef table where isTimezonePoi = 1
        /// 3. If status is remove then delete the node from the XML which has the georef ID.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="listGeoRefId"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/timezone/locations/delete")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> RemoveTimezoneLocations(string configurationId, string[] listGeoRefId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.UpdateTimezoneLocations(Int32.Parse(configurationId), listGeoRefId, "remove"));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. Get all timeone colors
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/timezone/colors")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<IEnumerable<string>>> GetTimezoneColors(string configurationId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetTimezoneColors(int.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. Update timeone colors
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="color"></param>
        /// <param name="node"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/timezone/colors/{color}/node/{node}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateTimezoneColors(string configurationId, string color, string node)
        {
            try
            {
                return Ok(await _viewsConfigurationService.UpdateTimezoneColors(int.Parse(configurationId), color, node));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }
        #endregion

        #region WorldClock
        /// <summary>
        /// 1. API to get all available locations for worldclock view
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/worldclock/locations")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<WorldClockLocationsDTO>> GetAvailableWorlclockLocations(string configurationId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetAvailableWorlclockLocations(Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. API to get all alternate locations for worldclock view
        /// 2 These locations will be considered as default locations
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/worldclock/alternates")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<WorldClockLocationsDTO>> GetAlternateWorlclockLocations(string configurationId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetAlternateWorlclockLocations(Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. Move cities in Worldclock XML to mentioned positions
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="geoRefId"></param>
        /// <param name="position"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/worldclock/move/{geoRefId}/from/{oldPosition}/to/{newPosition}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> MoveSelectedWorldClockLocation(string configurationId, string geoRefId, string oldPosition, string newPosition)
        {
            try
            {
                return Ok(await _viewsConfigurationService.MoveSelectedWorldClockLocation(int.Parse(configurationId), geoRefId, int.Parse(oldPosition), int.Parse(newPosition)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. API will add configurations to the worldclock table
        /// 2. Get the list of Locations from Georef table where isworldclockpoi = 1
        /// 3. If status is add, then add new node to the XML with data from Georef table.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="listGeoRefId"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/worldclock/locations/add")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> AddWorldclockLocation(string configurationId, string[] listGeoRefId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.UpdateWorldclockLocation(Int32.Parse(configurationId), listGeoRefId, "add"));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. API will remove configurations to the worldclock table
        /// 2. Get the list of Locations from Georef table where isworldclockpoi = 1
        /// 3. If status is remove then delete the node from the XML which has the georef ID.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="listGeoRefId"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/worldclock/locations/delete")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> RemoveWorldclockLocation(string configurationId, string[] listGeoRefId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.UpdateWorldclockLocation(Int32.Parse(configurationId), listGeoRefId, "remove"));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
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
        [HttpPost]
        [Route("{configurationId}/worldclock/alternate/set/{index}/to/{geoRefId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> AddAlternateWorldclockCity(string configurationId, string index, string geoRefId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.AddAlternateWorldclockCity(Int32.Parse(configurationId), int.Parse(index), Int32.Parse(geoRefId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. API to delete all world clock locations
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="listGeoRefId"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/worldclock/locations/delete/all")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> DeleteAllLocation(string configurationId)
        {
            string[] listGeoRefId = new string[0];
            try
            {
                return Ok(await _viewsConfigurationService.UpdateWorldclockLocation(Int32.Parse(configurationId), listGeoRefId, "all"));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
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
        [HttpGet]
        [Route("{configurationId}/{pageName}/parameters")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<string>>> GetFlightInfoParameters(string pageName, string configurationId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetFlightInfoParameters(pageName, Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. Map flight info display names
        /// 2. Get list of flight info display names from Feature set table
        /// 3. Cross check display names with names from Featureset
        /// 4. If its available, then map the values as return values
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/{pageName}/parameters/available")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<string>>> GetAvailableFlightInfoParameters(string pageName, string configurationId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetAvailableFlightInfoParameters(pageName, Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. Add new parameters to flight info
        /// 2. Parameters can be repeated
        /// 3. Cross verify parameters in featureset and then update in info items xml
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="flightInfoList"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/{pageName}/parameters")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> AddNewFlighInfoParams(string pageName, string configurationId, List<string> flightInfoList)
        {
            try
            {
                return Ok(await _viewsConfigurationService.AddNewFlighInfoParams(pageName, Int32.Parse(configurationId), flightInfoList));
            }
            catch(Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
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
        [HttpPost]
        [Route("{configurationId}/{pageName}/parameters/move/{fromPosition}/to/{toPosition}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> MoveFlightInfoParameterPosition(string pageName, string configurationId, string fromPosition, string toPosition)
        {
            try
            {
                return Ok(await _viewsConfigurationService.MoveFlightInfoParameterPosition(pageName, Int32.Parse(configurationId), Int32.Parse(fromPosition), Int32.Parse(toPosition)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. API to remove flight info parameter
        /// 2. The nodeIndex input will have the node index
        /// 3. The flight parameter in the input index will be removed from the XML
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="nodeIndex"></param>
        /// <returns></returns>
        [HttpDelete]
        [Route("{configurationId}/{pageName}/parameters/{nodeIndex}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> RemoveSelectedFlightInfoParameter(string pageName, string configurationId, string nodeIndex)
        {
            try
            {
                return Ok(await _viewsConfigurationService.RemoveSelectedFlightInfoParameter(pageName, Int32.Parse(configurationId), Int32.Parse(nodeIndex)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. API to remove your flight/broadcast parameters(sets of 3)
        /// 2. The list of flight parameters will be removed from the XML
        /// </summary>
        /// <param name="pageName"></param>
        /// <param name="configurationId"></param>
        /// <param name="nodeIndexList"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/{pageName}/parameters/delete")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> RemoveSelectedParameters(string pageName, string configurationId, List<string> nodeIndexList)
        {
            try
            {
                return Ok(await _viewsConfigurationService.RemoveSelectedParameters(pageName, Int32.Parse(configurationId), nodeIndexList));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }
        #endregion

        #region Makkah
        /// <summary>
        /// 1. Method to get all makkah data
        /// 2. Makkah data include Secondary pointer location, prayer time location, pointer calculation method, and Makkah values
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/makkah/values")]
        [Authorize(Policy =PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<MakkahData>> GetMakkahValues(string configurationId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetMakkahValues(Int32.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. Get makkah prayertime locations
        /// 2. Get values from Makkah table and cross reference with Feature set table
        /// 3. If Makkah location display name is availabel in feature set, then display the same.
        /// 4. There can be multiple location data
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/makkah/prayertimecalculations/available")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<MakkahPrayerCalculationTypes>>> GetMakkahPrayertimes(string configurationId)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetMakkahPrayertimes(int.Parse(configurationId)));
            }
            catch(Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1.Get available Makkah locations from XML
        /// 2. Get the georef ID from XML and cross reference the Georef table and show the value
        /// 3. if no geo ref ID is available then show as Closest locaton
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/makkah/locations/{type}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<MakkahLocations>> GetMakkahLocation(string configurationId, string type)
        {
            try
            {
                return Ok(await _viewsConfigurationService.GetMakkahLocation(Int32.Parse(configurationId), type));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. Update Makkah values
        /// 2. These values effect both compass and Makkah screens
        /// 3. The values are image and text
        /// 4. Values for these are true and false
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="type"></param>
        /// <param name="data"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/makkah/values/{type}/to/{data}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateMakkahValues(string configurationId, string type, string data)
        {
            try
            {
                return Ok(await _viewsConfigurationService.UpdateCompassValues(Int32.Parse(configurationId), type, data));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("{configurationId}/makkah/location/set/to/{data}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateMakkahLocations(string configurationId, string data)
        {
            try
            {
                return Ok(await _viewsConfigurationService.UpdateMakkahLocationAndPrayerTimeLocation(Int32.Parse(configurationId), data, "available"));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("{configurationId}/makkah/prayertime/set/to/{data}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateMakkahPrayerTimeLocations(string configurationId, string data)
        {
            try
            {
                return Ok(await _viewsConfigurationService.UpdateMakkahLocationAndPrayerTimeLocation(int.Parse(configurationId), data, "prayertime"));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("{configurationId}/makkah/calculation/set/to/{data}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateMakkahPrayerTimeCalculation(string configurationId, string data)
        {
            try
            {
                return Ok(await _viewsConfigurationService.UpdateMakkahLocationAndPrayerTimeLocation(int.Parse(configurationId), data, "calculation"));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }
        #endregion
    }
}