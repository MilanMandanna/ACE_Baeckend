using Ace.DataLayer.Models;
using AutoMapper;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Fleet;
using backend.DataLayer.Models.Subscription;
using backend.Mappers.DataTransferObjects.Aircraft;
using backend.Mappers.DataTransferObjects.Operator;
using backend.Mappers.DataTransferObjects.User;
using backend.Mappers.DataTransferObjects.Subscription;
using backend.DataLayer.Models.Roles_Claims;
using backend.Mappers.DataTransferObjects.Manage;
using backend.DataLayer.Models.Configuration;
using backend.Mappers.DataTransferObjects.ASXInfo;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.DataLayer.Models.Build;
using backend.Mappers.DataTransferObjects.Task;
using backend.Mappers.DataTransferObjects.ASXSwg;
using System.Collections.Generic;

namespace backend.Mappers
{
    public class Maps : Profile
    {
        public Maps()
        {
            CreateMap<Aircraft, AircraftListDTO>().ReverseMap();
            CreateMap<Aircraft, AircraftDTO>().ReverseMap();
            CreateMap<AircraftConfiguration, AircraftConfigurationDTO>().ReverseMap();
            CreateMap<MsuConfiguration, MsuConfigurationDto>().ReverseMap();
            CreateMap<Operator, OperatorListDTO>().ReverseMap();
            CreateMap<Operator, OperatorDTO>().ReverseMap();
            CreateMap<User, UserListDTO>().ReverseMap();
            CreateMap<User, FormCreateUserDTO>().ReverseMap();
            CreateMap<Subscription, SubscriptionDTO>().ReverseMap();
            CreateMap<Subscription, FormUpdateSubscriptionDTO>().ReverseMap();
            CreateMap<SubscriptionFeatureAssignment, SubscriptionFeatureAssignmentDTO>().ReverseMap();
            CreateMap<Subscription, SubscriptionDetailsDTO>().ReverseMap();
            CreateMap<UserRoles, RoleDTO>().ReverseMap();
            CreateMap<UserRoles, AdminRoleDTO>().ReverseMap();
            CreateMap<UserClaims, AdminClaimDTO>().ReverseMap();
            CreateMap<UserClaims, ClaimsListDTO>().ReverseMap();
            CreateMap<Configuration, ConfigurationDefinitionVersionDTO>()
                .ForMember(dest => dest.LockDate, m => m.MapFrom(src => src.LockDate.Date.ToShortDateString())).ReverseMap();
            CreateMap<ConfigurationName, ConfigurationDefinitionVersionDTO>()
               .ForMember(dest => dest.LockDate, m => m.MapFrom(src => src.LockDate.Date.ToShortDateString())).ReverseMap();
            CreateMap<UserConfigurationDefinition, UserConfigurationDefinitionDTO>().ReverseMap();
            CreateMap<Language, LanguageDTO>().ReverseMap();
            CreateMap<SelectedLanguage, SelectedLanguageDTO>().ReverseMap();
            CreateMap<BuildEntry, BuildsDTO>().ForMember(dest => dest.DateStarted, m => m.MapFrom(src => src.DateStarted.Date.ToShortDateString())).ReverseMap();

            /*
             * Mappings for exporting from the database to an asxinfo.sqlite3 database
             * todo: remove these by refactoring the asxinfo development export to work the same
             * as the product database exports
             */
            CreateMap<AirportInfo, ASXInfoAirportInfo>()
                .ForMember((dest) => dest.PointGeoRefId, (m) => m.MapFrom((src) => src.GeoRefID))
                .ReverseMap();
            CreateMap<Country, ASXInfoCountry>().ReverseMap();
            CreateMap<Font, ASXInfoFont>().ReverseMap();
            CreateMap<FontCategory, ASXInfoFontCategory>().ReverseMap();
            CreateMap<FontFamily, ASXInfoFontFamily>().ReverseMap();
            CreateMap<FontMarker, ASXInfoFontMarker>().ReverseMap();
            CreateMap<GeoRef, ASXInfoGeoRefId>()
                .ForMember(dest => dest.GeoRefIdCatTypeId, m => m.MapFrom(src => src.AsxiCatTypeId))
                .ForMember(dest => dest.ISearch, m => m.MapFrom(src => src.isInteractiveSearch))
                .ForMember(dest => dest.RLIPOI, m => m.MapFrom(src => src.isRliPoi))
                .ForMember(dest => dest.IPOI, m => m.MapFrom(src => src.isInteractivePoi))
                .ForMember(dest => dest.WCPOI, m => m.MapFrom(src => src.isWorldClockPoi))
                .ForMember(dest => dest.MakkahPOI, m => m.MapFrom(src => src.isMakkahPoi))
                .ForMember(dest => dest.ClosestPOI, m => m.MapFrom(src => src.isClosestPoi))
                .ForMember(dest => dest.LayerDisplay, m => m.MapFrom(src => src.MapStatsAppearance))
                .ReverseMap();
            CreateMap<GeoRefCategoryType, ASXInfoGeoRefIdCateType>()
                .ForMember(dest => dest.GeoRefIdCatTypeId, m => m.MapFrom(src => src.GeoRefCategoryTypeID_ASXIAndroid))
                .ReverseMap();
            CreateMap<Language, ASXInfoLanguage>()
                .ForMember(dest => dest.Name, m => m.MapFrom(src => src.Name.ToUpper()))
                .ForMember(dest => dest.TwoLetterID, m => m.MapFrom(src => src.TwoLetterID_ASXi.ToUpper()))
                .ForMember(dest => dest.ThreeLetterID, m => m.MapFrom(src => src.ThreeLetterID_ASXi.ToUpper()))
                .ReverseMap();
            CreateMap<RegionSpelling, ASXInfoRegion>().ReverseMap();
            CreateMap<FontFile, FontFileDTO>().ReverseMap();
            CreateMap<WorldGuideContent, ASXIWorldGuideContent>().ReverseMap();
            CreateMap<WorldGuideImage, ASXIWorlguideImage>().ReverseMap();
            CreateMap<WorldGuideText, ASXIWorldGuideText>().ReverseMap();
            CreateMap<WorldGuideType,ASXIWorldGuideType>().ReverseMap();
        }

    }
}
