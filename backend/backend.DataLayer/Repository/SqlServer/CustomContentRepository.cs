using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Xml;
using backend.DataLayer.Helpers;
using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.SqlServer.Queries;
using Microsoft.AspNetCore.Mvc;
using System.Xml.Serialization;
using System.IO;
using backend.DataLayer.Models.CustomContent;
using System.Dynamic;
using System.Reflection;

namespace backend.DataLayer.Repository.SqlServer
{
    public class CustomContentRepository : SimpleRepository<Configuration>, ICustomContentRepository
    {
        public CustomContentRepository(SqlConnection context, SqlTransaction transaction) :
            base(context, transaction)
        { }

        public CustomContentRepository()
        { }

        public virtual async Task<int> DeleteImage(int configurationId, int imageId)
        {
            try
            {
               
                var commandMapDelete = CreateCommand("[dbo].[sp_image_management_DeleteImage]", CommandType.StoredProcedure);
                commandMapDelete.Parameters.AddWithValue("@imageId", imageId);
                commandMapDelete.Parameters.AddWithValue("@configurationId", configurationId);
                 await commandMapDelete.ExecuteNonQueryAsync();

                //var commandDeleteRes = CreateCommand(" DELETE FROM tblImageResMap WHERE ImageId=@imageId AND ConfigurationID=@configurationId ");
                //commandDeleteRes.Parameters.AddWithValue("@imageId", imageId);
                //commandDeleteRes.Parameters.AddWithValue("@configurationId", configurationId);
                //result = await commandDeleteRes.ExecuteNonQueryAsync();

                //var commandDelete = CreateCommand(" DELETE FROM tblImage WHERE ImageId=@imageId ");
                //commandDelete.Parameters.AddWithValue("@imageId", imageId);
                //commandDelete.Parameters.AddWithValue("@configurationId", configurationId);
                //result = await commandDelete.ExecuteNonQueryAsync();

                return 1;
            }
            catch (Exception ex)
            {
                throw ex;
            }

        }

        public virtual async Task<List<ImageDetails>> GetConfigImages(int configurationId, int type)
        {

            string sql = @"[dbo].[sp_image_management_GetConfigImages]";
            var command = CreateCommand(sql, CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@type", type);
            List<ImageDetails> imageDetails = new List<ImageDetails>();
            using (var reader = await command.ExecuteReaderAsync())
            {
                ImageDetails image;
                while (await reader.ReadAsync())
                {
                    image = new ImageDetails();
                    image.ImageId = reader.GetInt32("ImageId");
                    image.ImageName = reader.GetString("ImageName");
                    image.ImageURL = reader.GetString("OriginalImagePath");
                    image.IsSelected = reader.GetBoolean("IsSelected");
                    imageDetails.Add(image);
                }
            }
            return imageDetails;
        }

        public virtual async Task<ImageDetails> GetImageDetails(int configurationId, int imageId)
        {
            string sql = @"[dbo].[sp_image_management_GetImageDetails]";
            var command = CreateCommand(sql, CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@ImageId", imageId);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            ImageDetails image = new ImageDetails();
            using (var reader = await command.ExecuteReaderAsync())
            {

                if (await reader.ReadAsync())
                {
                    image.ImageName = reader.GetString("ImageName");
                    image.ImageURL = reader.GetString("OriginalImagePath");
                }
            }
            return image;
        }

        public virtual async Task<int> GetMaxImageId()
        {
            string sql =
                @"SELECT ISNULL(MAX(ImageId),0) FROM tblImage";
            var command = CreateCommand(sql);

            int imageId = 0;
            using (var reader = await command.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    imageId = reader.GetInt32(0);
                }
            }
            return imageId;
        }

        public virtual async Task<int> InsertImages(int configurationId, int imageId, string imageName, string guidFileName, string imageURL, int type)
        {

            var result = 0;
            string sql =
                @"[dbo].[sp_image_management_InsertImages]";

            var insertCommand = CreateCommand(sql, CommandType.StoredProcedure);
            insertCommand.Parameters.AddWithValue("@configurationId", configurationId);
            insertCommand.Parameters.AddWithValue("@imageId", imageId);
            insertCommand.Parameters.AddWithValue("@imageName", imageName);
            insertCommand.Parameters.AddWithValue("@guidFileName", guidFileName);
            insertCommand.Parameters.AddWithValue("@imageURL", imageURL);
            insertCommand.Parameters.AddWithValue("@type", type);
            result = await insertCommand.ExecuteNonQueryAsync();

            return result > 0 && result > 0 ? 1 : 0;
        }

        public virtual async Task<int> InsertResolutionSpecImage(int configurationId, int imageId, int? resolutionId, string imageURL)
        {
            var result = 0;
            string sql =
                @"[dbo].[sp_image_management_InsertResolutionSpecImage]";
            var insertCommand = CreateCommand(sql, CommandType.StoredProcedure);
            insertCommand.Parameters.AddWithValue("@configurationId", configurationId);
            insertCommand.Parameters.AddWithValue("@imageId", imageId);
            insertCommand.Parameters.AddWithValue("@resolutionId", resolutionId);
            insertCommand.Parameters.AddWithValue("@imageURL", imageURL);
            result = await insertCommand.ExecuteNonQueryAsync();

            return result > 0 && result > 0 ? 1 : 0;
        }

        public virtual async Task<Dictionary<int, string>> GetResolutions()
        {
            Dictionary<int, string> lstRes = new Dictionary<int, string>();
            string sql =
                @"[dbo].[sp_image_management_GetResolutions]";
            var command = CreateCommand(sql, CommandType.StoredProcedure);
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    lstRes.Add(reader.GetInt32("ID"), reader.GetString("resolution"));
                }
            }
            return lstRes;
        }

        public virtual async Task<string> SetConfigImage(int configurationId, string imageIds, int type, int scriptId, int index)
        {
            var result = 0;
            List<string> lstRes = new List<string>();
            //set default values

            var updateCommandDefault = CreateCommand("[dbo].[sp_image_management_ReSetConfigImage]", CommandType.StoredProcedure);
            updateCommandDefault.Parameters.AddWithValue("@configurationId", configurationId);
            updateCommandDefault.Parameters.AddWithValue("@type", type);
            result = await updateCommandDefault.ExecuteNonQueryAsync();

            foreach (var imageId in imageIds.Trim().Split(','))
            {
                var updateCommand = CreateCommand("[dbo].[sp_image_management_SetConfigImage]", CommandType.StoredProcedure);
                updateCommand.Parameters.AddWithValue("@configurationId", configurationId);
                updateCommand.Parameters.AddWithValue("@type", type);
                updateCommand.Parameters.AddWithValue("@imageId", imageId);
                result = await updateCommand.ExecuteNonQueryAsync();
            }
            if (type == (int)ImageType.Script)
            {
                //select the image names from image ids and 
                //update script tag for file name

                foreach (var imageId in imageIds.Split(','))
                {
                    var selectCommand = CreateCommand(@"[dbo].[sp_image_management_GetImageDetails]", CommandType.StoredProcedure);

                    selectCommand.Parameters.AddWithValue("@ImageId", imageId);
                    selectCommand.Parameters.AddWithValue("@configurationId", configurationId);
                    using (var reader = await selectCommand.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            lstRes.Add(DbHelper.StringFromDb(reader["ImageName"]));
                        }
                    }
                }

                return string.Join(";", lstRes.ToArray());

            }
            return result.ToString();
        }

        public virtual async Task<Dictionary<string, int>> GetImageCount(int configurationId)
        {
            Dictionary<string, int> lstRes = new Dictionary<string, int>();
            string sql =
                @"[dbo].[sp_image_management_GetImageCount]";
            var command = CreateCommand(sql, CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);

            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    lstRes.Add(reader.GetString("ImageType").ToLower(), reader.GetInt32("imageCount"));
                }
            }
            return lstRes;
        }

        public virtual async Task<List<ImageDetails>> PreviewImages(int configurationId, int imageId, int type)
        {
            string sql = @"[dbo].[sp_image_management_PreviewImages]";
            var command = CreateCommand(sql, CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@imageId", imageId);
            List<ImageDetails> imageDetails = new List<ImageDetails>();
            using (var reader = await command.ExecuteReaderAsync())
            {
                string defaultRes = string.Empty;
                ImageDetails image;
                while (await reader.ReadAsync())
                {
                    image = new ImageDetails();
                    image.ReslutionId = reader.GetInt32("ResolutionId");
                    image.ImageURL = reader.GetString("ImagePath");
                    if (string.IsNullOrEmpty(defaultRes))
                        defaultRes = reader.GetString("resolution");
                    image.DefaultResolution = defaultRes;
                    image.ResolutionValue = reader.GetString("resolution");
                    image.ResolutionDesc = DbHelper.StringFromDb(reader["Description"]);
                    imageDetails.Add(image);
                }
            }
            return imageDetails;
        }
      
        public virtual async Task<int> UpdateResolutionSpecImage(int configurationId, int imageId, int? resolutionId, string imageURL)
        {
            var result = 0;
            string sql = @"[dbo].[sp_image_management_UpdateResolutionSpecImage]";
            var command = CreateCommand(sql, CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@imageId", imageId);
            command.Parameters.AddWithValue("@resolutionId", resolutionId);
            command.Parameters.AddWithValue("@imageURL", imageURL);
            result = await command.ExecuteNonQueryAsync();

            return result > 0 && result > 0 ? 1 : 0;
        }

        public virtual async Task<List<string>> GetResolutionText(int configurationId, string resolutionId)
        {
            List<string> result = new List<string>();
            string sql = string.Empty;
            // -1 => fetched the default resolution id to display in UI, else fetched the resolution as per the resolution id
            // its to differentiate the images to be loaded in the Manage Images screen or Reolution spec image screen
            var command = CreateCommand(@"[dbo].[sp_image_management_GetResolutionText]", CommandType.StoredProcedure);

            if (resolutionId == "-1")
            {
                command.Parameters.AddWithValue("@resolutionId", -1);
            }
            else
            {
                command.Parameters.AddWithValue("@resolutionId", Convert.ToInt32(resolutionId));
            }
            using (var reader = await command.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    result.Add(DbHelper.StringFromDb(reader["resolution"]));
                }
            }
            return result;
        }

        public async Task<int> RenameFile(int configurationId, int imageId, int type, string fileName)
        {
            var result = 0;
            var command = CreateCommand(@"[dbo].[sp_image_management_RenameFile]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@imageId", imageId);
            command.Parameters.AddWithValue("@fileName", fileName);
            command.Parameters.AddWithValue("@type", type);
            result = await command.ExecuteNonQueryAsync();

            return result > 0 && result > 0 ? 1 : 0;
        }

        #region - High Focus and Ultra High Focus city funtions

        //Map Package 
        /// <summary>
        /// Get All Cities
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<List<City>> GetAllCities(int configurationId, string type)
        {
            var command = CreateCommand(@"[dbo].[SP_AsxiInset_GetCities]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@type", "all");
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@cityType", type);
            List<City> cities = new List<City>();

            using (var reader = await command.ExecuteReaderAsync())
            {
                City city;
                while (await reader.ReadAsync())
                {
                    city = new City();
                    city.ASXiInsetID = reader.GetInt32("ASXiInsetID");
                    city.InsetName = reader.GetString("InsetName");
                    city.IsHf = reader.GetBoolean("IsHf");
                    city.IsUHf = reader.GetBoolean("IsUHf");
                    cities.Add(city);
                }
            }
            return cities;

        }


        /// <summary>
        /// Get High focus cities
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public virtual async Task<List<City>> GetSelectedHFCities(int configurationId)
        {
            var command = CreateCommand(@"[dbo].[SP_AsxiInset_GetCities]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@type", "hf");
            command.Parameters.AddWithValue("@configurationId", configurationId);

            List<City> cities = new List<City>();

            using (var reader = await command.ExecuteReaderAsync())
            {
                City city;
                while (await reader.ReadAsync())
                {
                    city = new City();
                    city.ASXiInsetID = reader.GetInt32("ASXiInsetID");
                    city.InsetName = reader.GetString("InsetName");
                    city.IsHf = reader.GetBoolean("IsHf");
                    cities.Add(city);
                }
            }
            return cities;
        }
        public virtual async Task<int> SelectHFCity(int configurationId, int[] cities)
        {
            int result = 0;
            foreach (var city in cities)
            {
                
                var command = CreateCommand(@"[dbo].[SP_AsxiInset_UpdateCity]", CommandType.StoredProcedure);
                command.Parameters.AddWithValue("@type", "hf");
                command.Parameters.AddWithValue("@configurationId", configurationId);
                command.Parameters.AddWithValue("@ASXiInsetID", city);
                command.Parameters.AddWithValue("@selected", 1);
                command.Parameters.AddWithValue("@action", "insert");
                result = await command.ExecuteNonQueryAsync();
            }
            return result;

        }

        public virtual async Task<int> DeleteHFCity(int configurationId, int aSXiInsetID)
        {
            int result = 0;

            var command = CreateCommand(@"[dbo].[SP_AsxiInset_UpdateCity]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@type", "hf");
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@ASXiInsetID", aSXiInsetID);
            command.Parameters.AddWithValue("@selected", 0);
            command.Parameters.AddWithValue("@action", "delete");
            result = await command.ExecuteNonQueryAsync();

            return result;

        }

        public virtual async Task<int> DeleteAllHFCities(int configurationId, int[] aSXiInsetIDs)
        {
            int result = 0;
            foreach (var aSXiInsetID in aSXiInsetIDs)
            {
                var command = CreateCommand(@"[dbo].[SP_AsxiInset_UpdateCity]", CommandType.StoredProcedure);
                command.Parameters.AddWithValue("@type", "hf");
                command.Parameters.AddWithValue("@configurationId", configurationId);
                command.Parameters.AddWithValue("@selected", 0);
                command.Parameters.AddWithValue("@ASXiInsetID", aSXiInsetID);
                command.Parameters.AddWithValue("@action", "delete");
                result = await command.ExecuteNonQueryAsync();
            }

            return result;

        }

        //Ultra High focus
        public virtual async Task<List<City>> GetSelectedUHFCities(int configurationId)
        {
            var command = CreateCommand(@"[dbo].[SP_AsxiInset_GetCities]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@type", "uhf");
            command.Parameters.AddWithValue("@configurationId", configurationId);
            List<City> cities = new List<City>();

            using (var reader = await command.ExecuteReaderAsync())
            {
                City city;
                while (await reader.ReadAsync())
                {
                    city = new City();
                    city.ASXiInsetID = reader.GetInt32("ASXiInsetID");
                    city.InsetName = reader.GetString("InsetName");
                    city.IsUHf = reader.GetBoolean("IsUHf");
                    cities.Add(city);
                }
            }
            return cities;
        }
        public virtual async Task<int> SelectUHFCity(int configurationId, int[] cities)
        {
            int result = 0;
            foreach (var city in cities)
            {
                var command = CreateCommand(@"[dbo].[SP_AsxiInset_UpdateCity]", CommandType.StoredProcedure);
                command.Parameters.AddWithValue("@type", "uhf");
                command.Parameters.AddWithValue("@configurationId", configurationId);
                command.Parameters.AddWithValue("@selected", 1);
                command.Parameters.AddWithValue("@ASXiInsetID", city);
                command.Parameters.AddWithValue("@action", "insert");
                result = await command.ExecuteNonQueryAsync();
            }
            return result;

        }

        public virtual async Task<int> DeleteUHFCity(int configurationId, int aSXiInsetID)
        {
            int result = 0;

            var command = CreateCommand(@"[dbo].[SP_AsxiInset_UpdateCity]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@type", "uhf");
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@selected", 0);
            command.Parameters.AddWithValue("@ASXiInsetID", aSXiInsetID);
            command.Parameters.AddWithValue("@action", "delete");
            result = await command.ExecuteNonQueryAsync();

            return result;

        }

        public virtual async Task<int> DeleteAllUHFCities(int configurationId, int[] aSXiInsetIDs)
        {
            int result = 0;
            foreach (var aSXiInsetID in aSXiInsetIDs)
            {
                var command = CreateCommand(@"[dbo].[SP_AsxiInset_UpdateCity]", CommandType.StoredProcedure);
                command.Parameters.AddWithValue("@type", "uhf");
                command.Parameters.AddWithValue("@configurationId", configurationId);
                command.Parameters.AddWithValue("@selected", 0);
                command.Parameters.AddWithValue("@ASXiInsetID", aSXiInsetID);
                command.Parameters.AddWithValue("@action", "delete");
                result = await command.ExecuteNonQueryAsync();
            }

            return result;

        }
        #endregion

        public virtual async Task<List<PlaceName>> GetPlaceNames(int configurationId)
        {
            var command = CreateCommand("[dbo].[sp_placenames_getplacenames]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            List<PlaceName> placeNames = new List<PlaceName>();
            using (var reader = await command.ExecuteReaderAsync())
            {
                PlaceName placeName;
                while (await reader.ReadAsync())
                {
                    placeName = new PlaceName();
                    placeName.Name = DbHelper.StringFromDb(reader["Description"]);
                    placeName.GeoRefId= DbHelper.DBValueToInt(reader["GeoRefId"]);
                    placeName.Id= DbHelper.DBValueToInt(reader["ID"]);
                    placeName.CountryName = DbHelper.StringFromDb(reader["CountryName"]);
                    placeName.RegionName = DbHelper.StringFromDb(reader["RegionName"]);
                    placeNames.Add(placeName);

                }
            }

            return placeNames;
        }

        public virtual async Task<List<PlaceNameLanguage>> GetPlaceNameInfo(int configurationId, int placeNameId)
        {
            var command = CreateCommand("[dbo].[sp_placenames_getplacenamespelling]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@geoRefId", placeNameId);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            List<PlaceNameLanguage> placeNames = new List<PlaceNameLanguage>();
            using (var reader = await command.ExecuteReaderAsync())
            {
                PlaceNameLanguage placeName;
                while (await reader.ReadAsync())
                {
                    placeName = new PlaceNameLanguage();
                    placeName.SpellingId = DbHelper.DBValueToInt(reader["SpellingID"]);
                    placeName.LanguageName = DbHelper.StringFromDb(reader["Name"]);
                    placeName.PlaceNameValue = DbHelper.StringFromDb(reader["UnicodeStr"]);
                    placeNames.Add(placeName);
                }
            }

            return placeNames;
        }

        public virtual async Task<List<PlaceCatType>> GetCatTypes(int configurationId, int placeNameId)
        {
            var command = CreateCommand("[dbo].[sp_placenames_getcattypes]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@placeNameId", placeNameId);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            List<PlaceCatType> placeCatTypes = new List<PlaceCatType>();
            using (var reader = await command.ExecuteReaderAsync())
            {
                PlaceCatType catType;
                while (await reader.ReadAsync())
                {
                    catType = new PlaceCatType();
                    catType.CatTypeId = DbHelper.DBValueToInt(reader["CategoryTypeID"]);
                    catType.CatTypeDesc = DbHelper.StringFromDb(reader["Description"]);
                    catType.isSelected = DbHelper.BoolFromDb(reader["isSelected"]);
                    placeCatTypes.Add(catType);
                }
            }

            return placeCatTypes;
        }

        public virtual async Task<List<Visibility>> GetVisibility(int configurationId, int placeNameGeoRefId)
        {
            var command = CreateCommand("[dbo].[sp_placenames_getvisibility]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@geoRefId", placeNameGeoRefId);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            List<Visibility> visibilities = new List<Visibility>();
            using (var reader = await command.ExecuteReaderAsync())
            {
                Visibility visibility;
                while (await reader.ReadAsync())
                {
                    visibility = new Visibility();
                    visibility.VisibilityId = DbHelper.DBValueToInt(reader["appearanceid"]);
                    visibility.Resolution = DbHelper.DBValueToInt(reader["resolution"]);
                    visibility.Priority = DbHelper.DBValueToInt(reader["Priority"]);
                    visibility.IsExcluded = DbHelper.BoolFromDb(reader["exclude"]);
                    visibilities.Add(visibility);
                }
            }

            return visibilities;
        }

        public virtual async Task<int> UpdatePlaceNameCatType(int configurationId, int placeNameId, ListModlist listModData)
        {
            int result = 0;
            DataTable modListTable = new DataTable();
            modListTable.Columns.Add("id", typeof(int));
            modListTable.Columns.Add("row", typeof(int));
            modListTable.Columns.Add("column", typeof(int));
            modListTable.Columns.Add("resolution", typeof(int));
            int i = 1;
            listModData.ModlistArray.ForEach(modlist =>
            {

                modListTable.Rows.Add(i, modlist.Row, modlist.Column, modlist.Resolution);
                i++;

            });

            var updateCommand = CreateCommand("[dbo].[sp_placenames_updatecattype]",CommandType.StoredProcedure);
            updateCommand.Parameters.AddWithValue("@configurationId", configurationId);
            updateCommand.Parameters.AddWithValue("@placeNameId", placeNameId);
            updateCommand.Parameters.AddWithValue("@catTypeId", listModData.CatType);
            updateCommand.Parameters.AddWithValue("@modlistinfo", modListTable);
            result = await updateCommand.ExecuteNonQueryAsync();
            return result;
        }
        public virtual async Task<PlaceName> GetLatLonValue(int placeNameId  ,int geoRefId)
        {
            var command = CreateCommand("[dbo].[sp_placenames_GetLatLonValue]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@placeNameId", placeNameId);
            command.Parameters.AddWithValue("@geoRefId", geoRefId);
            PlaceName placeNames = new PlaceName();
            using (var reader = await command.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                {
                    placeNames.Lat1 = DbHelper.DBValueToString(reader["Lat"]);
                    placeNames.Lon1 = DbHelper.DBValueToString(reader["Lon"]);
                }
                return placeNames;
            }
        }

        public virtual async Task<int> SavePlaceNameSpelling(int configurationId, int placeNameGeoRefId, PlaceNameLanguage[] placeNameLanguages)
        {
            int result = 0;
            foreach (var item in placeNameLanguages.ToList())
            {
                var updateCommand = CreateCommand("[dbo].[sp_placenames_insert_update_spelling]", CommandType.StoredProcedure);
                updateCommand.Parameters.AddWithValue("@configurationId", configurationId);
                updateCommand.Parameters.AddWithValue("@geoRefId", placeNameGeoRefId);
                updateCommand.Parameters.AddWithValue("@placeName", item.PlaceNameValue);
                updateCommand.Parameters.AddWithValue("@spellingId", item.SpellingId);
                result = await updateCommand.ExecuteNonQueryAsync();
                if(result==0)
                    return 0;
            }
            return result;

        }

        public virtual async Task<PlaceName> GetAdvancedPlaceNameInfo(int configurationId, int placeNameId)
        {
            var command = CreateCommand("[dbo].[sp_placenames_getplacenameinfo]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@placeNameId", placeNameId);
            PlaceName placeName = new PlaceName();
            using (var reader = await command.ExecuteReaderAsync())
            {
                if (await reader.ReadAsync())
                { 
                    placeName.Lat1= DbHelper.DBValueToString(reader["Lat1"]);
                    placeName.Lon1 = DbHelper.DBValueToString(reader["Lon1"]);
                    placeName.Lat2 = DbHelper.DBValueToString(reader["Lat2"]);
                    placeName.Lon2 = DbHelper.DBValueToString(reader["Lon2"]);
                    placeName.CountryId = DbHelper.IntFromDb(reader["CountryID"]);
                    placeName.CountryName = DbHelper.DBValueToString(reader["Description"]);
                    placeName.RegionId = DbHelper.IntFromDb(reader["RegionID"]);
                    placeName.RegionName = DbHelper.DBValueToString(reader["RegionName"]);
                    placeName.SegmentId = DbHelper.IntFromDb(reader["SegId"]);
                    placeName.Id = DbHelper.DBValueToInt(reader["ID"]);
                    placeName.GeoRefId = DbHelper.DBValueToInt(reader["GeoRefId"]);

                }
            }
            return placeName;
        }

        public virtual async Task<Dictionary<int, int>> SavePlaceInfo(int configurationId, ListModlistsave placeName)
        {
            try
            {
                Dictionary<int, int> keyValuePairs = new Dictionary<int, int>();
                int result = 0;
                DataTable modListTable = new DataTable();
                modListTable.Columns.Add("id", typeof(int));
                modListTable.Columns.Add("row", typeof(int));
                modListTable.Columns.Add("column", typeof(int));
                modListTable.Columns.Add("resolution", typeof(int));
                int i = 1;
                placeName.ModlistArrayPlaceName.ForEach(modlist =>
                {

                    modListTable.Rows.Add(i, modlist.Row, modlist.Column, modlist.Resolution);
                    i++;

                });
                var updateCommand = CreateCommand("[dbo].[sp_placenames_insertupdategeoref]", CommandType.StoredProcedure);
                updateCommand.Parameters.AddWithValue("@configurationId", configurationId);
                updateCommand.Parameters.AddWithValue("@geoRefId", placeName.GeoRefId);
                updateCommand.Parameters.AddWithValue("@id", placeName.Id);
                updateCommand.Parameters.AddWithValue("@name", placeName.Name);
                updateCommand.Parameters.AddWithValue("@regionId", placeName.RegionId == 0 ? null : placeName.RegionId);
                updateCommand.Parameters.AddWithValue("@countryId", placeName.CountryId == 0 ? null : placeName.CountryId);
                updateCommand.Parameters.AddWithValue("@covSegmentId", placeName.SegmentId);
                updateCommand.Parameters.AddWithValue("@lat1", placeName.Lat1);
                updateCommand.Parameters.AddWithValue("@lon1", placeName.Lon1);
                updateCommand.Parameters.AddWithValue("@lan2", placeName.Lat2);
                updateCommand.Parameters.AddWithValue("@lon2", placeName.Lon2);
                updateCommand.Parameters.AddWithValue("@modlistinfo", modListTable);
                using (var reader = await updateCommand.ExecuteReaderAsync())
                {
                    if (await reader.ReadAsync())
                    {
                        keyValuePairs.Add(DbHelper.DBValueToInt(reader[0]), DbHelper.DBValueToInt(reader[1]));
                    }
                }
                return keyValuePairs;
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }

        public virtual async Task<int> SaveVisibility(int configurationId, int PlaceNameGeoRefId, Visibility[] visibilities, ListModlistVisiblity listModlistInfosaveVisiblity)
        {
            int result = 0;
            DataTable modListTable = new DataTable();
            modListTable.Columns.Add("id", typeof(int));
            modListTable.Columns.Add("row", typeof(int));
            modListTable.Columns.Add("column", typeof(int));
            modListTable.Columns.Add("resolution", typeof(int));
            int i = 1;
            listModlistInfosaveVisiblity.ModlistArrayVisiblity.ForEach(modlist =>
            {

                modListTable.Rows.Add(i, modlist.Row, modlist.Column, modlist.Resolution);
                i++;

            });
            foreach (var item in visibilities.ToList())
            {
                var updateCommand = CreateCommand("[dbo].[sp_placenames_insert_update_appearance]", CommandType.StoredProcedure);
                updateCommand.Parameters.AddWithValue("@configurationId", configurationId);
                updateCommand.Parameters.AddWithValue("@geoRefId", PlaceNameGeoRefId);
                updateCommand.Parameters.AddWithValue("@appearanceId", item.VisibilityId);
                updateCommand.Parameters.AddWithValue("@isExclude", Convert.ToInt32(item.IsExcluded));
                updateCommand.Parameters.AddWithValue("@priority", item.Priority);
                updateCommand.Parameters.AddWithValue("@modlistinfo", modListTable);
                result = await updateCommand.ExecuteNonQueryAsync();
                if (result == 0)
                    return 0;
            }
            return result;
        }

        public virtual async Task<List<dynamic>> GetInfoSpelling(int configurationId, List<Language> languages)
        {
            InfoSeplling infoSeplling;
            List<dynamic> infoSepllings = new List<dynamic>();
            try
            {

            var command = CreateCommand(@"[dbo].[sp_infoSpelling_getInfoSpelling]", CommandType.StoredProcedure);
            command.Parameters.AddWithValue("@configurationId", configurationId);
            command.Parameters.AddWithValue("@languages", string.Join(", ", languages.Select(x => $"[{x.Name}]")));
            command.CommandTimeout = 0;
            

          
            using (var reader = await command.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    infoSeplling = new InfoSeplling();
                    infoSeplling.InfoId = DbHelper.DBValueToInt(reader["Infoid"]);

                    var obj = convertToExpando(infoSeplling);
                    foreach (var lang in languages)
                    {
                        AddProperty(obj, lang.Name, DbHelper.DBValueToStringWithEmpty(reader[lang.Name]));
                    }
                    infoSepllings.Add(obj);
                }
            } 
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return infoSepllings;
        }


        public static dynamic convertToExpando(object obj)
        {
            //Get Properties Using Reflections
            BindingFlags flags = BindingFlags.Public | BindingFlags.Instance;
            PropertyInfo[] properties = obj.GetType().GetProperties(flags);

            //Add Them to a new Expando
            dynamic expando = new ExpandoObject();
            foreach (PropertyInfo property in properties)
            {
                AddProperty(expando, property.Name, property.GetValue(obj));
            }

            return expando;
        }

        public static void AddProperty(ExpandoObject expando, string propertyName, object propertyValue)
        {
            //Take use of the IDictionary implementation
            var expandoDict = expando as IDictionary<String, object>;
            if (expandoDict.ContainsKey(propertyName))
                expandoDict[propertyName] = propertyValue;
            else
                expandoDict.Add(propertyName, propertyValue);
        }

        public async Task<int> UpdateInfoSpelling(int configurationId, int infoId, int languageId, string spelling)
        {
            try
            {
                var command = CreateCommand(@"[dbo].[sp_infoSpelling_insertupdateInfoSpelling]", CommandType.StoredProcedure);
                command.Parameters.AddWithValue("@configurationId", configurationId);
                command.Parameters.AddWithValue("@infoId", infoId);
                command.Parameters.AddWithValue("@languageId", languageId);
                command.Parameters.AddWithValue("@spelling", spelling);
                using (var reader = await command.ExecuteReaderAsync())
                {
                    if (reader.HasRows && await reader.ReadAsync())
                    {
                        infoId = DbHelper.DBValueToInt(reader["Infoid"]);
                    }
                }
                return infoId;
            }
            catch
            {
                return -1;
            }

        }
    }
}

