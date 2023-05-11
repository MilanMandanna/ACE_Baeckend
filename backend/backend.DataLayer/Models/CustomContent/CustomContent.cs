using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.CustomContent
{
    public class CustomContent
    {
        public string FileName { get; set; }
        public string FileSize { get; set; }
        public string FileType { get; set; }
        public string FileAsBase64 { get; set; }
        public byte[] FileAsByteArray { get; set; }
    }

    public class ImageDetails
    {
        public int ImageId { get; set; }
        public string ImageName { get; set; }
        public string ImageURL { get; set; }
        public int ReslutionId { get; set; }
        public string ResolutionValue { get; set; }
        public string ResolutionDesc { get; set; }
        public bool IsSelected { get; set; }
        public string DefaultResolution { get; set; }
    }

    public enum ImageType
    {
        Logo = 1,
        Splash = 2,
        Script = 3
    }

    public class PlaceName
    {
        public int Id { get; set; }
        public int GeoRefId { get; set; }
        public string Name { get; set; }
        public string Lat1 { get; set; }
        public string Lon1 { get; set; }
        public string Lat2 { get; set; }
        public string Lon2 { get; set; }
        public int? RegionId { get; set; }
        public int? CountryId { get; set; }
        public string CountryName { get; set; }
        public string RegionName { get; set; }
        public int? SegmentId { get; set; }
    }

    public class PlaceNameLanguage
    {
        public int SpellingId { get; set; }
        public string LanguageName { get; set; }
        public string PlaceNameValue { get; set; }
    }

    public class PlaceCatType
    {
        public int CatTypeId { get; set; }
        public bool isSelected { get; set; }
        public string CatTypeDesc { get; set; }
    }

    public class Visibility
    {
        public int VisibilityId { get; set; }
        public int Resolution { get; set; }
        public bool IsExcluded { get; set; }
        public int Priority { get; set; }
    }

    public class DataCreationResultPlaceName
    {
        public Guid Id { get; set; }

        public bool IsError { get; set; }

        public string Message { get; set; }

        public int ReturnId { get; set; }
        public int ReturnGeoRefId { get; set; }
    }
    public class ModlistLatLon 
    {
        public string Lat1 { get; set; }
        public string Lon1 { get; set; }
        public int  CatType { get; set; }
    }
      public class  ListModlist : ModlistLatLon
    {
        public List<ModlistInfo> ModlistArray { get; set; }

    }
    public class ListModlistsave : PlaceName
    {
        public List<ModlistInfo> ModlistArrayPlaceName { get; set; }

    }
    public class ListModlistVisiblity 
    { 
        public List<ModlistInfo> ModlistArrayVisiblity { get; set; }
    }



}
