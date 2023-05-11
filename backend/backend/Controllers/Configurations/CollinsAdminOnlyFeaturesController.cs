using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts.Configuration;
using backend.DataLayer.Models.Configuration;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace backend.Controllers.Configurations
{
    [Route("api/[controller]")]
    [ApiController]
    public class CollinsAdminOnlyFeaturesController : PortalController
    {
        private ICollinsAdminOnlyFeaturesService _collinsadminOnlyfeaturesService;
        private ILoggerManager _logger;

        public CollinsAdminOnlyFeaturesController(ICollinsAdminOnlyFeaturesService collinsadminOnlyfeaturesService, ILoggerManager logger)
        {
            _collinsadminOnlyfeaturesService = collinsadminOnlyfeaturesService;
            _logger = logger;
        }

        /// <summary>
        /// 1. Method to get the details of the admin items.
        /// 2. It will return a list of string.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/adminItems")]
        [Authorize(Policy = PortalPolicy.AdministerAircraft)]
        public async Task<ActionResult<List<string>>> GetCollinsAdminItems(string configurationId)
        {
            try
            {
                return Ok(await _collinsadminOnlyfeaturesService.GetCollinsAdminItems(int.Parse(configurationId)));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        /// <summary>
        /// 1. Get the download details of the selected page.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("{configurationId}/downloaddetails/page/{pageName}")]
        [Authorize(Policy = PortalPolicy.AdministerAircraft)]
        public async Task<ActionResult<List<AdminOnlyDownloadDetails>>> GetDownloadDetails(string configurationId, string pageName)
        {
            try
            {
                return Ok(await _collinsadminOnlyfeaturesService.GetDownloadDetails(int.Parse(configurationId), pageName));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        #region
        [HttpPost]
        /// Download the uploaded artefacts based on revison history
        /// 
        [Route("{configurationid}/revision")]
        [Authorize(Policy = PortalPolicy.AdministerAircraft)]
        public async Task<ActionResult> DownloadCollinsAdminArtifacts(string configurationid, [FromBody] string[] inputData)
        {
            try
            {
                return Ok(await _collinsadminOnlyfeaturesService.DownloadArtifactsByRevision(Int32.Parse(configurationid), inputData));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed :" + ex);
                return NoContent();

            }
        }

        [HttpGet]
        [Route("{configurationId}/DownloadInsets")]
        [Authorize(Policy = PortalPolicy.AdministerAircraft)]
        public async Task<ActionResult> DownloadInsets(string configurationId)
        {
            try
            {
                return await _collinsadminOnlyfeaturesService.DownloadInsetsByRevision(int.Parse(configurationId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }
        #endregion

        #region Required Feature Upload

        /// <summary>
        /// TO DO ---- Insets and placenames to be added
        /// 1. Method to upload files to azure storage container
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="pageName"></param>
        /// <returns></returns>
        [HttpPost]
        [Route("{configurationId}/{pageName}/upload")]
        [Authorize(Policy = PortalPolicy.AdministerAircraft)]
        public async Task<ActionResult<DataCreationResultDTO>> UploadRequiredFeatures(string configurationId, string pageName)
        {
            string tempPathtoSave = string.Empty;
            string sourceName = string.Empty;

            switch (pageName.ToLower())
            {
                case "citypopulation":
                    sourceName = "CityPopulationSourcefiles";
                    break;
                case "newairport":
                    sourceName = "AiportSourceFiles";
                    break;
                case "addnewwgcities":
                    sourceName = "WGCitiesDataSources";
                    break;
                case "flight data configuration":
                    sourceName = "FlightDataSourceFiles";
                    break;
                case "system config":
                    sourceName = "SystemConfigSourceFiles";
                    break;
                case "site identification":
                    sourceName = "SiteIdentificationSourceFiles";
                    break;
                case "acars configuration":
                    sourceName = "ACARSSourceFiles";
                    break;
                case "flight phase profile":
                    sourceName = "FlightPhaseSourceFiles";
                    break;
                case "sizes configuration":
                    sourceName = "SizeConfigurationSourceFiles";
                    break;
                case "resolution":
                    sourceName = "ResolutionMapSourceFiles";
                    break;
                case "3d":
                    sourceName = "Content3dSourceFiles";
                    break;
                case "content mobile configuration":
                    sourceName = "ContentMobileSourceFiles";
                    break;
                case "briefings configuration":
                    sourceName = "BriefingsConfiguration";
                    break;
                case "flight deck controller menu":
                    sourceName = "FlightDeckConfiguration";
                    break;
                case "ces":
                    sourceName = "CESScripts";
                    break;
                case "installation scripts venue next":
                    sourceName = "VenueNextScripts";
                    break;
                case "timezone database":
                    sourceName = "TimezoneDatabase";
                    break;
                case "placenames":
                    sourceName = "NewPlaceNamesSourceFiles";
                    break;
                case "mobile configuration platform":
                    sourceName = "Mobileconfiguration";
                    break;
                case "content 3d aircraft models":
                    sourceName = "AircraftModels";
                    break;
                case "ticker ads configuration":
                    sourceName = "TickerAdsConfiguration";
                    break;
                case "mmobilecc configuration":
                    sourceName = "MmobileccConfiguration";
                    break;
                case "discrete inputs":
                    sourceName = "Discrete Inputs";
                    break;
                case "fdc map menu list":
                    sourceName = "FDCMapMenuListConfig";
                    break;
                case "insets":
                    sourceName = "HiFocusMapInsets";
                    break;

                case "info spelling":
                    sourceName = "InfoSpelling";
                    break;

                case "font data":
                    sourceName = "Font Data";
                    break;
                case "customxml":
                    sourceName = "Custom XML";
                    break;
					
                default:
                    sourceName = pageName;
                    break;
            }
            try
            {
                tempPathtoSave = Path.Join(Path.GetTempFileName() + sourceName);

                if (Directory.Exists(tempPathtoSave)) Directory.Delete(tempPathtoSave, true);
                Directory.CreateDirectory(tempPathtoSave);

                var file = Request.Form.Files[0];
                if (file == null)
                {
                    return BadRequest();
                }
                else
                {
                    using (var stream = new FileStream(Path.Combine(tempPathtoSave, file.FileName), FileMode.Create))
                    {
                        await file.CopyToAsync(stream);
                    }
                }
                var mapPackageType = Request.Form["mapPackageType"].ToString();
                return Ok(await _collinsadminOnlyfeaturesService.UploadRequiredFeatures(int.Parse(configurationId), tempPathtoSave, pageName, mapPackageType, GetCurrentUser().Id));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                if (Directory.Exists(tempPathtoSave)) Directory.Delete(tempPathtoSave, true);
                return NoContent();
            }
        }
        #endregion

        [HttpGet]
        [Route("{configurationId}/{pageName}/errorlog")]
        [Authorize(Policy = PortalPolicy.AdministerAircraft)]
        public async Task<ActionResult<string>> GetErrorLog(string configurationId, string pageName)
        {
            try
            {
                return Ok(await _collinsadminOnlyfeaturesService.GetErrorLog(int.Parse(configurationId), pageName));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

    }
}

