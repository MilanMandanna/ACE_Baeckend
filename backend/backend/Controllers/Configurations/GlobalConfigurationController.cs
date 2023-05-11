using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts.Configuration;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers.Configurations
{


    /**
     * Controller dedicated to handling high-level tasks associated with Global configurations,
     */
    [Route("api/[controller]")]
    [ApiController]
    public class GlobalConfigurationController : PortalController
    {

        private IGlobalConfigurationService _globalConfigurationService;
        private ILoggerManager _logger;

        public GlobalConfigurationController(IGlobalConfigurationService globalConfigurationService, ILoggerManager logger)
        {
            _globalConfigurationService = globalConfigurationService;
            _logger = logger;
        }


        [HttpGet]
        [Route("{configurationId}/fonts")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<FontFileDTO>>> GetConfigurationFonts(string configurationId)
        {
            try
            {
                return Ok(await _globalConfigurationService.GetConfigurationFonts(int.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{configurationId}/fonts/select/{fontFileId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> SetFontFileSeletedForConfiguration(string configurationId, string fontFileId)
        {
            try
            {
                return Ok(await _globalConfigurationService.SetFontFileSeletedForConfiguration(int.Parse(configurationId), int.Parse(fontFileId), GetCurrentUser()));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }



        [HttpGet]
        [Route("{configurationId}/languages")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<LanguageDTO>>> GetConfigurationLanguages()
        {
            try
            {
                return Ok(await _globalConfigurationService.GetConfigurationLanguages());
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("{configurationId}/languages/selected")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<SelectedLanguageDTO>>> GetSelectedLanguages(string configurationId)
        
        {
            try
            {
                return Ok(await _globalConfigurationService.GetSelectedLanguages(int.Parse(configurationId)));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{configurationId}/languages/selected/add")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> AddLanguages(string configurationId, string[] languages)
        {
            try
            {
                return Ok(await _globalConfigurationService.AddLanguages(int.Parse(configurationId), languages));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{configurationId}/languages/selected/remove/{languageCode}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> RemoveLanguage(string configurationId, string languageCode)
        {
            try
            {
                return Ok(await _globalConfigurationService.RemoveLanguage(int.Parse(configurationId), languageCode));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{configurationId}/languages/selected/{languageCode}/moveto/{position:int}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> MoveLanguageCodeToPosition(string configurationId, string languageCode, int position)
        {
            try
            {
                return Ok(await _globalConfigurationService.MoveLanguageCodeToPosition(int.Parse(configurationId), languageCode, position));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{configurationId}/languages/selected/{languageCode}/set/{name}/to/{value}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateLanguagesSetting(string configurationId, string languageCode, string name, string value)
        {
            try
            {
                return Ok(await _globalConfigurationService.UpdateLanguagesSetting(int.Parse(configurationId), languageCode, name, value));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{configurationId}/languages/selected/{languageCode}/default")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> SetLanguageAsDefault(string configurationId, string languageCode)
        {
            try
            {
                return Ok(await _globalConfigurationService.SetLanguageAsDefault(int.Parse(configurationId), languageCode));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }
    }
}
