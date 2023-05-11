using Ace.DataLayer.Models;
using backend.BusinessLayer.Contracts;
using backend.Logging.Contracts;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.Mappers.DataTransferObjects.Aircraft;
using AutoMapper;
using Microsoft.AspNetCore.Authorization;
using backend.BusinessLayer.Authorization;
using backend.Mappers.DataTransferObjects.Generic;
using backend.DataLayer.Models.DownloadPreferences;
using backend.Helpers.Fleet;
using backend.Helpers.Portal;
using System.Configuration;
using System.Linq;
using System;
using backend.Mappers.DataTransferObjects.User;
using backend.DataLayer.Models.CustomContent;
using backend.DataLayer.Models;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AircraftController : PortalController
    {
        private readonly IAircraftService _aircraftService;
        private readonly IDownloadPreferencesService _preferencesService;
        private readonly ILoggerManager _logger;
        private readonly IMapper _mapper;

        public AircraftController(IAircraftService aircraftService, IDownloadPreferencesService preferencesService, ILoggerManager logger, IMapper mapper)
        {
            _aircraftService = aircraftService;
            _preferencesService = preferencesService;
            _logger = logger;
            _mapper = mapper;
        }

        [HttpGet]
        [Route("{tailNumber}")]
        [Authorize(Policy = PortalPolicy.ViewAircraft)]
        public async Task<ActionResult<AircraftDTO>> GetAircraft(string tailNumber)
        {
            try
            {
                return await _aircraftService.GetAircraftDetails(tailNumber);
            }
            catch (Exception ex)
            {
                _logger.LogError("request failed: " + ex);
                return NoContent();
            }
        }

        [HttpDelete]
        [Route("{tailNumber}")]
        public async Task<ActionResult<AircraftDTO>> DeleteSomething(string tailNumber)
        {
            return null;
        }

        [HttpGet]
        [Route("all")]
        public async Task<List<AircraftListDTO>> GetAllAircraft()
        {
            // todo: this is just for debug
            List<Aircraft> all = await _aircraftService.FindAllAircraft();
            List<AircraftListDTO> result = new List<AircraftListDTO>();

            return _mapper.Map<List<AircraftListDTO>>(all);
        }

        [HttpGet]
        [Route("{tailNumber}/connectivity_types")]
        [Authorize(Policy = PortalPolicy.EditAircraft)]
        public List<ItemWithSelectionDTO> GetAircraftConnectivityTypes(string tailNumber)
        {
            return _aircraftService.GetAircraftConnectivityTypes(tailNumber);
        }

        [HttpPost]
        [Route("{tailNumber}/connectivity_types/select/{isSelected:bool}/connectiontype/{connectionTypeName}")]
        [Authorize(Policy = PortalPolicy.EditAircraft)]
        public SelectionResultDTO SetAircraftConnectivityType(string tailNumber, bool isSelected, string connectionTypeName)
        {
            return _aircraftService.SetAircraftConnectivityType(tailNumber, isSelected, connectionTypeName);
        }

        [HttpGet]
        [Route("downloadpreferences")]
        [Authorize]
        public async Task<List<DownloadPreference>> GetDownloadPreferences()
        {
            return await _preferencesService.GetDownloadPreferences();
        }

        [HttpGet]
        [Route("{tailNumber}/downloadpreferences")]
        [Authorize(Policy = PortalPolicy.ViewAircraft)]
        public async Task<List<DownloadPreferenceAssignmentDTO>> GetAircraftDownloadPreferences(string tailNumber)
        {
            return await _preferencesService.GetAircraftDownloadPreferences(tailNumber);
        }

        [HttpPost]
        [Route("{tailNumber}/select/{selected:bool}/downloadpreference/{downloadPreferenceName}/type/{type}")]
        [Authorize(Policy = PortalPolicy.EditAircraft)]
        public async Task<SelectionResultDTO> SelectAircraftDownloadPreference(string tailNumber, bool selected, string downloadPreferenceName, string type)
        {
            return await _preferencesService.SelectAircraftDownloadPreference(tailNumber, selected, downloadPreferenceName, type);
        }

        [HttpGet]
        [Route("manufacturers")]
        public ActionResult<List<NameListDTO>> GetManufacturers()
        {
            List<NameListDTO> results = new List<NameListDTO>();
            TypeCollection models = FleetConfiguration.Instance.Models;
            foreach (KeyValueConfigurationElement element in models)
            {
                results.Add(new NameListDTO { Name = element.Key });
            }
            return Ok(results);
        }

        [HttpGet]
        [Route("manufacturers/{manufacturerName}/models")]
        public ActionResult<List<NameListDTO>> GetManufacturerModels(string manufacturerName)
        {
            List<NameListDTO> results = new List<NameListDTO>();
            TypeCollection models = FleetConfiguration.Instance.Models;
            foreach (KeyValueConfigurationElement element in models)
            {
                if (element.Key == manufacturerName)
                {
                    results.AddRange(element.Value.Split(';').Select(s => new NameListDTO { Name = s }));
                    return Ok(results);
                }

            }
            return NoContent();
        }

        [HttpPost]
        [Route("update")]
        [Authorize(Policy = PortalPolicy.ManageSiteSettings)]
        public async Task<ActionResult<DataCreationResultDTO>> SaveAircraft([FromBody] AircraftListDTO aircraft)
        {
            try
            {
                UserListDTO user = GetCurrentUser();
                return await _aircraftService.Update(aircraft, user);
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }



        [HttpGet]
        [Route("manage/{roleId}")]
        [Authorize(Policy = PortalPolicy.ManageAccounts)]
        public async Task<ActionResult<IEnumerable<AircraftListDTO>>> GetAircraftsByUserRole(string roleId)
        {
            try
            {
                return Ok(await _aircraftService.GetAircraftsByRoleID(roleId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Error Occured" + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("{aircraftid}/users")]
        [Authorize(Policy = PortalPolicy.ManageRoleAssignment)]
        public async Task<ActionResult<IEnumerable<UserListDTO>>> GetUsersByAircraftRights(string aircraftID)
        {
            try
            {
                Guid aircraftid = Guid.Parse(aircraftID);
                return Ok(await _aircraftService.GetUsersByAircraftRights(aircraftid));
            }
            catch (Exception ex)
            {
                _logger.LogError("Error Occured" + ex);
                return NoContent();
            }
        }

        /// <summary>
        /// EndPoint to delete an existing Aircraft
        /// </summary>
        /// <param name="roleId"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("delete")]
        [Authorize(Policy = PortalPolicy.AdministerAircraft)]
        public async Task<ActionResult<DataCreationResultDTO>> DeleteAircraft([FromBody]string aircraftId)
        {
            try
            {
                Guid aircraftID = Guid.Parse(aircraftId);
                return Ok(await _aircraftService.DeleteAircraft(aircraftID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request Failed" + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("{tailNumber}/subscription/select/{subscriptionId}")]
        [Authorize(Policy = PortalPolicy.EditAircraft)]
        public async Task<ActionResult<DataCreationResultDTO>> SelectSubscription(string tailNumber, string subscriptionId)
        {
            try
            {
                Guid subscriptionIdGuid = Guid.Parse(subscriptionId);
                return Ok(await _aircraftService.SelectSubscription(tailNumber, subscriptionIdGuid));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("{tailNumber}/subscription/deactivate")]
        [Authorize(Policy = PortalPolicy.EditAircraft)]
        public async Task<ActionResult<DataCreationResultDTO>> DeactivateSubscription(string tailNumber)
        {
            try
            {
                return Ok(await _aircraftService.DeactivateSubscription(tailNumber));
            }
            catch (Exception ex)
            {
                _logger.LogError("request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("PartNumber/{configurationDefinitionId}/{partNumberCollectionId}/{tailNumber}")]
        [Authorize(Policy = PortalPolicy.ManageAircraft)]
        public async Task<ActionResult<List<BuildDefaultPartnumber>>>ConfigurationDefinitionPartNumber(int configurationDefinitionId, int partNumberCollectionId,string tailNumber)
        {
            try
            {
                return Ok(await _aircraftService.ConfigurationDefinitionPartNumber(configurationDefinitionId, partNumberCollectionId, tailNumber));
            }
            catch (Exception ex)
            {
                _logger.LogError("request failed: " + ex);
                return NoContent();
            }
        }

        

        [HttpPost]
        [Route("update/partNumber")]
        [Authorize(Policy = PortalPolicy.ManageAircraft)]
        public async Task<ActionResult<DataCreationResultDTO>> ConfigurationDefinitionUpdatePartNumber([FromBody] PartNumber partNumberInfo)
        {

            try
            {
                return Ok(await _aircraftService.ConfigurationDefinitionUpdatePartNumber(partNumberInfo));
            }
            catch (Exception ex)
            {
                _logger.LogError("request failed: " + ex);
                return NoContent();
            }
        }
        [HttpGet]
        [Route("PartNumber/{outputTypeID}")]
        [Authorize(Policy = PortalPolicy.ManageAircraft)]
        public async Task<ActionResult<List<BuildDefaultPartnumber>>>GetDefaultPartNumber( int outputTypeID)
        {
            try
            {
                return Ok(await _aircraftService.GetDefaultPartNumber(outputTypeID));
            }
            catch (Exception ex)
            {
                _logger.LogError("request failed: " + ex);
                return NoContent();
            }
        }
    }
}
