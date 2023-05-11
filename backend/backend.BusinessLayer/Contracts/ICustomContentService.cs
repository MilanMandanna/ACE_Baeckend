using backend.Mappers.DataTransferObjects.Generic;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using Azure;
using Azure.Storage.Blobs.Models;
using System.IO;
using backend.DataLayer.Models.CustomContent;

namespace backend.BusinessLayer.Contracts
{
    public interface ICustomContentService
    {
        Task<DataCreationResultDTO> UploadImageToAzure(int configurationId, IFormFile file,int type, string imageId, string resolutionId);

        Task<List<string>> GetResolutionText(int configurationId,string resolutionId);

        Task<List<ImageDetails>> GetConfigImages(int configurationId, int type);
        Task<DataCreationResultDTO> DeleteImage(int configurationId, int imageId, int type);
        Task<Dictionary<int, string>> GetResolutions();
        Task<DataCreationResultDTO> SetConfigImage(int configurationId, string imageIds,int type, int scriptId, int index);
        Task<Dictionary<string, int>> GetImageCount(int configurationId);
        Task<List<ImageDetails>> PreviewImages(int configurationId, int imageId, int type);
        Task<DataCreationResultDTO> RenameFile(int configurationId, int imageId, int type,string fileName);



        /// <summary>
        /// Maps Package
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        Task<List<City>> GetAllCities(int configurationId, string type);

        /// <summary>
        /// Maps Package
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        Task<List<City>> GetSelectedHFCities(int configurationId);

        Task<DataCreationResultDTO> SelectHFCity(int configurationId, int[] cities);
        Task<DataCreationResultDTO> DeleteHFCity(int configurationId,int aSXiInsetID);
        Task<DataCreationResultDTO> DeleteAllHFCities(int configurationId, int[] aSXiInsetIDs);

        //Ultra Highfocus
        Task<List<City>> GetSelectedUHFCities(int configurationId);
        Task<DataCreationResultDTO> SelectUHFCity(int configurationId, int[] cities);
        Task<DataCreationResultDTO> DeleteUHFCity(int configurationId, int aSXiInsetID);
        Task<DataCreationResultDTO> DeleteAllUHFCities(int configurationId, int[] aSXiInsetIDs);
        Task<List<PlaceName>> GetPlaceNames(int configurationId);
        Task<List<PlaceNameLanguage>> GetPlaceNameInfo(int configurationId, int placeNameId);

        Task<List<PlaceCatType>> GetCatTypes(int configurationId, int placeNameId);

        Task<List<Visibility>> GetVisibility(int configurationId, int placeNameGeoRefId);

        Task<DataCreationResultDTO> UpdatePlaceNameCatType(int configurationId, int placeNameId, int catType,Guid UserId);

        Task<DataCreationResultDTO> SavePlaceNameSpelling(int configurationId, int placeNameGeoRefId, PlaceNameLanguage[] placeNameLanguages);

        Task<PlaceName> GetAdvancedPlaceNameInfo(int configurationId, int placeNameId);

        Task<DataCreationResultPlaceName> SavePlaceInfo(int configurationId, PlaceName placeName , Guid userId);

        Task<DataCreationResultDTO> SaveVisibility(int configurationId, int PlaceNameGeoRefId, Visibility[] visibilities, Guid userId);

        Task<InfoSepllingDisplay> GetInfoSpelling(int configurationId);
        Task<DataCreationResultDTO> UpdateInfoSpelling(int configurationId, int infoId, KeyValues[] keyVal);
    }
}
