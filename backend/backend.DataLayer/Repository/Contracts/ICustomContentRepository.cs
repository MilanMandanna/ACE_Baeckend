using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.CustomContent;
using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    public interface ICustomContentRepository
    {
        Task<int> InsertImages(int configurationId,int imageId, string imageName,string guidFileName, string imageURL,int type);
        Task<ImageDetails> GetImageDetails(int configurationId, int imageId);
        Task<List<ImageDetails>> GetConfigImages(int configurationId, int type);
        Task<int> DeleteImage(int configurationId, int imageId);
        Task<Dictionary<int, string>> GetResolutions();
        Task<int> GetMaxImageId();
        Task<string> SetConfigImage(int configurationId, string imageIds, int type, int scriptId, int index);
        Task<Dictionary<string, int>> GetImageCount(int configurationId);
        Task<List<ImageDetails>> PreviewImages(int configurationId, int imageId, int type);
        Task<int> InsertResolutionSpecImage(int configurationId, int imageId, int? resolutionId, string imageURL);
        Task<int> UpdateResolutionSpecImage(int configurationId, int imageId, int? resolutionId, string imageURL);
        Task<List<string>> GetResolutionText(int configurationId,string resolutionId);
        Task<int> RenameFile(int configurationId, int imageId, int type, string fileName);
        Task<PlaceName> GetLatLonValue( int placeNameId  ,int geoRefId);
        /// <summary>
        /// Map Configuration
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        Task<List<City>> GetAllCities(int configurationId, string type);


        /// <summary>
        /// Map Configuration
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        Task<List<City>> GetSelectedHFCities(int configurationId);

        /// <summary>
        /// Map Configuration
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        Task<int> SelectHFCity(int configurationId, int[] cities);
        Task<int> DeleteHFCity(int configurationId, int aSXiInsetID);
        Task<int> DeleteAllHFCities(int configurationId, int[] aSXiInsetIDs);

        //High focus
        Task<List<City>> GetSelectedUHFCities(int configurationId);
        Task<int> SelectUHFCity(int configurationId, int[] cities);
        Task<int> DeleteUHFCity(int configurationId, int aSXiInsetID);
        Task<int> DeleteAllUHFCities(int configurationId, int[] aSXiInsetIDs);

        Task<List<PlaceName>> GetPlaceNames(int configurationId);
        Task<List<PlaceNameLanguage>> GetPlaceNameInfo(int configurationId,int placeNameId);
        Task<List<PlaceCatType>> GetCatTypes(int configurationId, int placeNameId);

        Task<List<Visibility>> GetVisibility(int configurationId, int placeNameGeoRefId);

        Task<int> UpdatePlaceNameCatType(int configurationId, int placeNameId, ListModlist listModData);

        Task<int> SavePlaceNameSpelling(int configurationId, int placeNameGeoRefId, PlaceNameLanguage[] placeNameLanguages);

        Task<PlaceName> GetAdvancedPlaceNameInfo(int configurationId, int placeNameId);

        Task<Dictionary<int, int>> SavePlaceInfo(int configurationId, ListModlistsave placeName);

        Task<int> SaveVisibility(int configurationId, int PlaceNameGeoRefId, Visibility[] visibilities , ListModlistVisiblity listModlistInfosaveVisiblity);

        Task<List<dynamic>> GetInfoSpelling(int configurationId, List<Language> languages);

        Task<int> UpdateInfoSpelling(int configurationId, int infoId, int languageId, string spelling);
    }
}
