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
using System.Net.Http;
using backend.DataLayer.Models.Fleet;
using System.Text;
using System;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MsuConfigurationController : PortalController
    {

        private readonly IAircraftService _aircraftService;
        private readonly IMsuConfigurationService _msuConfigurationService;
        private readonly IDownloadPreferencesService _preferencesService;
        private readonly ILoggerManager _logger;
        private readonly IMapper _mapper;

        public MsuConfigurationController(IAircraftService aircraftService, IMsuConfigurationService msuConfigurationService, IDownloadPreferencesService preferencesService, ILoggerManager logger, IMapper mapper)
        {
            _aircraftService = aircraftService;
            _msuConfigurationService = msuConfigurationService;
            _preferencesService = preferencesService;
            _logger = logger;
            _mapper = mapper;
        }

        [HttpGet]
        [Route("aircraft/{aircraft_id}/activemsuconfiguration")]
        public MsuConfigurationDto GetActive(string aircraft_id)
        {
            Guid aircraftid = Guid.Parse(aircraft_id);
            Aircraft aircraft = _aircraftService.FindAircraftById(aircraftid);
            if (aircraft == null) return null;

            // if (!IsInRole(GlobalAccountManagement) && !IsInRole(OperatorAccountManagement, aircraft.Operator.Name))
            //     return null;

            ///MsuConfiguration activeConfiguration = _cms.Repository.GetDbSet().Where(x => x.TailNumber == aircraft_id).OrderByDescending(x => x.DateCreated).FirstOrDefault();
            // return Mapper.Map<MsuConfigurationDto>(activeConfiguration);

            return null;
        }

        [HttpGet]
        [Route("aircraft/{aircraft_id}/msuconfigurationslist")]
        public async Task<List<MsuConfigurationDto>> GetAll(string aircraft_id)
        {
            Guid aircraftid = Guid.Parse(aircraft_id);
            Aircraft aircraft =  _aircraftService.FindAircraftById(aircraftid);
            if (aircraft == null) return null;
            //  if (!IsInRole(GlobalAccountManagement) && !IsInRole(OperatorAccountManagement, aircraft.Operator.Name))
            //      return null;

            List<MsuConfiguration>  list = await _msuConfigurationService.GetAll(aircraft_id);
            return _mapper.Map<List<MsuConfigurationDto>>(list);
            //return null;
        }


        [HttpGet]
        [Route("aircraft/{aircraft_id}/msuconfiguration/{configuration_id}")]
        public IActionResult GetConfigurationFile(string aircraft_id, string configuration_id)
        {
            Guid aircraftid = Guid.Parse(aircraft_id);
            Aircraft aircraft = _aircraftService.FindAircraftById(aircraftid);
            if (aircraft == null) return null;

        //   TODO: 
        //    if (!IsInRole(GlobalAccountManagement) && !IsInRole(OperatorAccountManagement, aircraft.Operator.Name))
        //        return null;

            MsuConfiguration msuconfiguration = _msuConfigurationService.FindMsuConfigurationById(configuration_id);
            var model = new MsuConfigurationBody();
            model.Content = msuconfiguration.ConfigurationBody;
            model.FileName = msuconfiguration.FileName;
            return new ObjectResult(model);     
          
        }
    }
}
