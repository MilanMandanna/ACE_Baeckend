using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts;
using backend.BusinessLayer.Contracts.Configuration;
using backend.DataLayer.Models.CustomContent;
using backend.DataLayer.Models.Subscription;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Operator;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Drawing.Imaging;
using System.Net.Http.Headers;
using System.Threading.Tasks;

namespace backend.Controllers
{

    [Route("api/[controller]")]
    [ApiController]
    public class CustomContentController : PortalController
    {
        private ICustomContentService _customContentService;
        private ILoggerManager _logger;
        public CustomContentController(ICustomContentService customContentService, ILoggerManager logger)
        {
            _customContentService = customContentService;
            _logger = logger;
        }

        [HttpPost]
        [Route("{configurationId}/imageupload/{type}/{imageId}/{resolutionId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UploadImage(int configurationId,int type,string imageId,string resolutionId)
        {
            try
            {
                var file = Request.Form.Files[0];
                if (file == null)
                    return BadRequest();

                return Ok(await _customContentService.UploadImageToAzure(configurationId, file,type,imageId,resolutionId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }


        [HttpGet]
        [Route("{configurationId}/getResolutionText/{resolutionId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<string>>> GetResolutionText(int configurationId,string resolutionId)
        {
            try
            {
                return Ok(await _customContentService.GetResolutionText(configurationId,resolutionId));

            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("{configurationId}/getconfigimages/{type}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<ImageDetails>>> GetConfigImages(int configurationId, int type)
        {
            try
            {
                var result = await _customContentService.GetConfigImages(configurationId, type);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("{configurationId}/removeimage/{imageId}/{type}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> DeleteImage(int configurationId, int imageId, int type)
        {
            try
            {
                var result = await _customContentService.DeleteImage(configurationId, imageId,type);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpGet]
        [Route("{configurationId}/setImage/{imageIds}/{type}/{scriptId}/{index}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> SetConfigImage(int configurationId, string imageIds, int type, int scriptId, int index)
        {
            try
            {
                var result = await _customContentService.SetConfigImage(configurationId, imageIds, type,scriptId,index);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpGet]
        [Route("{configurationId}/getImageCount")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<Dictionary<string,int>>> GetImageCount(int configurationId)
        {
            try
            {
                var result = await _customContentService.GetImageCount(configurationId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpGet]
        [Route("{configurationId}/getImagePreview/{imageId}/{type}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<ImageDetails>>> PreviewImages(int configurationId, int imageId, int type)
        {
            try
            {
                var result = await _customContentService.PreviewImages(configurationId,imageId, type);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpGet]
        [Route("{configurationId}/getAllCities/{type}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<City>>> GetAllCities(int configurationId, string type)
        {
            try
            {
                return Ok(await _customContentService.GetAllCities(configurationId, type));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }
            [HttpGet]
            [Route("{configurationId}/renameFile/{imageId}/{type}/{fileName}")]
            [Authorize(Policy = PortalPolicy.EditConfiguration)]
            public async Task<ActionResult<DataCreationResultDTO>> RenameFile(int configurationId, int imageId, int type, string fileName)
            {
                try
                {
                    var result = await _customContentService.RenameFile(configurationId, imageId, type, fileName);
                    return result;
                }
                catch (Exception ex)
                {
                    _logger.LogError("Request failed: " + ex);
                    return NoContent();
                }
            }
        [HttpGet]
        [Route("{configurationId}/getSelectedHFCities")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<City>>> GetSelectedHFCities(int configurationId)
        {
            try
            {
               return Ok(await _customContentService.GetSelectedHFCities(configurationId));
            }
        
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpPost]
        [Route("{configurationId}/cities/HFselected/add")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> SelectHFCity(int configurationId, int[] cities)
        {
            try
            {
                return Ok(await _customContentService.SelectHFCity(configurationId, cities));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{configurationId}/removeHFcity/{aSXiInsetID}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> DeleteHFCity(int configurationId, int aSXiInsetID)
        {
            try
            {
                return Ok(await _customContentService.DeleteHFCity(configurationId, aSXiInsetID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpPost]
        [Route("{configurationId}/removeAllHFcities")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> DeleteAllHFCities(int configurationId, int[] aSXiInsetIDs)
        {
            try
            {
                var result = await _customContentService.DeleteAllHFCities(configurationId, aSXiInsetIDs);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpGet]
        [Route("{configurationId}/getSelectedUHFCities")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<City>>> GetSelecteUHFCities(int configurationId)
        {
            try
            {
                return Ok(await _customContentService.GetSelectedUHFCities(configurationId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpPost]
        [Route("{configurationId}/cities/UHFselected/add")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> SelectUHFCity(int configurationId, int[] cities)
        {
            try
            {
                var result = await _customContentService.SelectUHFCity(configurationId, cities);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }
        }

        [HttpPost]
        [Route("{configurationId}/removeUHFcity/{aSXiInsetID}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> DeleteUHFCity(int configurationId, int aSXiInsetID)
        {
            try
            {
                var result = await _customContentService.DeleteUHFCity(configurationId, aSXiInsetID);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpPost]
        [Route("{configurationId}/removeAllUHFcities")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> DeleteAllUHFCities(int configurationId, int[] aSXiInsetIDs)
        {
            try
            {
                var result = await _customContentService.DeleteAllUHFCities(configurationId, aSXiInsetIDs);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        #region PlaceNames

        [HttpGet]
        [Route("{configurationId}/loadplacenames")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<PlaceName>>> GetPlaceNames(int configurationId)
        {
            try
            {
                return Ok(await _customContentService.GetPlaceNames(configurationId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpGet]
        [Route("{configurationId}/getplacenamespellinginfo/{placeNameId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<PlaceNameLanguage>>> GetPlaceNameInfo(int configurationId,int placeNameId)
        {
            try
            {
                return Ok(await _customContentService.GetPlaceNameInfo(configurationId,placeNameId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpGet]
        [Route("{configurationId}/getcattypes/{placeNameId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<PlaceCatType>>> GetCatTypes(int configurationId,int placeNameId)
        {
            try
            {
                return Ok(await _customContentService.GetCatTypes(configurationId,placeNameId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpGet]
        [Route("{configurationId}/getvisibilityinfo/{placeNameGeoRefId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<List<Visibility>>> GetVisibility(int configurationId, int placeNameGeoRefId)
        {
            try
            {
                return Ok(await _customContentService.GetVisibility(configurationId, placeNameGeoRefId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpPost]
        [Route("{configurationId}/updateCatType/{placeNameId}/{catType}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdatePlaceNameCatType(int configurationId, int placeNameId,int catType)
        {
            try
            {
                return Ok(await _customContentService.UpdatePlaceNameCatType(configurationId, placeNameId, catType,GetCurrentUser().Id));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpPost]
        [Route("{configurationId}/saveplacenamespelling/{placeNameGeoRefId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> SavePlaceNameSpelling(int configurationId, int placeNameGeoRefId, PlaceNameLanguage[] placeNameLanguages)
        {
            try
            {
                return Ok(await _customContentService.SavePlaceNameSpelling(configurationId, placeNameGeoRefId, placeNameLanguages));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }


        [HttpGet]
        [Route("{configurationId}/getadvancedplacenameinfo/{placeNameId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<PlaceName>> GetAdvancedPlaceNameInfo(int configurationId,int placeNameId)
        {
            try
            {
                return Ok(await _customContentService.GetAdvancedPlaceNameInfo(configurationId, placeNameId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpPost]
        [Route("{configurationId}/saveplacename")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultPlaceName>> SavePlaceInfo(int configurationId, PlaceName placeName )
        {
            try
            {
                return Ok(await _customContentService.SavePlaceInfo(configurationId, placeName, GetCurrentUser().Id));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpPost]
        [Route("{configurationId}/savevisibility/{placeNameGeoRefId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> SaveVisibility(int configurationId, int placeNameGeoRefId, Visibility[] visibilities)
        {
            try
            {
                return Ok(await _customContentService.SaveVisibility(configurationId, placeNameGeoRefId, visibilities, GetCurrentUser().Id));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }
        #endregion

        #region InfoSeplling

        [HttpGet]
        [Route("{configurationId}/getInfoSpelling")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<InfoSepllingDisplay>> GetInfoSpelling(int configurationId)
        {
            try
            {
                return Ok(await _customContentService.GetInfoSpelling(configurationId));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }

        [HttpPost]
        [Route("{configurationId}/updateInfoSpelling/{infoId}")]
        [Authorize(Policy = PortalPolicy.EditConfiguration)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateInfoSpelling(int configurationId, int infoId, [FromBody]KeyValues[] keyVal)
        {
            try
            {
                return Ok(await _customContentService.UpdateInfoSpelling(configurationId, infoId, keyVal));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NoContent();
            }

        }
        #endregion

    }
}
