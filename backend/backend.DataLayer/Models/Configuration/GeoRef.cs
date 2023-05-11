using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "dbo.tblGeoRef")]
    public class GeoRef
    {
        [DataProperty(PrimaryKey = true)]
        public int ID { get; set; }
        [DataProperty] public int GeoRefID { get; set; }
        [DataProperty] public string Description { get; set; }
        public int NgaUfiId { get; set; }
        public int NgaUniId { get; set; }
        public int UsgsFeatureId { get; set; }
        [DataProperty] public int UnCodeId { get; set; }
        [DataProperty] public int SequenceId { get; set; }
        [DataProperty] public int CatTypeID { get; set; }
        [DataProperty] public int AsxiCatTypeId { get; set; }
        [DataProperty] public int PnType { get; set; }
        [DataProperty] public int RegionId { get; set; }
        [DataProperty] public int CountryId { get; set; }
        [DataProperty] public string StateId { get; set; }
        [DataProperty] public int TZStripId { get; set; }
        [DataProperty] public bool isAirport { get; set; }
        [DataProperty] public bool isAirportPoi { get; set; }
        [DataProperty] public bool isAttraction { get; set; }
        [DataProperty] public bool isCapitalCountry { get; set; }
        [DataProperty] public bool isCapitalState { get; set; }
        [DataProperty] public bool isClosestPoi { get; set; }
        [DataProperty] public bool isControversial { get; set; }
        [DataProperty] public bool isInteractivePoi { get; set; }
        [DataProperty] public bool isInteractiveSearch { get; set; }
        [DataProperty] public bool isMakkahPoi { get; set; }
        [DataProperty] public bool isRliPoi { get; set; }
        [DataProperty] public bool isShipWreck { get; set; }
        [DataProperty] public bool isSnapshot { get; set; }
        [DataProperty] public bool isSummit { get; set; }
        [DataProperty] public bool isTerrainLand { get; set; }
        [DataProperty] public bool isTerrainOcean { get; set; }
        [DataProperty] public bool isTimeZonePoi { get; set; }
        [DataProperty] public bool isWaterBody { get; set; }
        [DataProperty] public bool isWorldClockPoi { get; set; }
        [DataProperty] public bool isWGuide { get; set; }
        [DataProperty] public int Priority { get; set; }
        [DataProperty] public int AsxiPriority { get; set; }
        [DataProperty] public int MarkerId { get; set; }
        [DataProperty] public int AtlasMarkerId { get; set; }
        [DataProperty] public int MapStatsAppearance { get; set; }
        [DataProperty] public int PoiPanelStatsAppearance { get; set; }
        [DataProperty] public int RliAppearance { get; set; }
        [DataProperty] public bool KeepNew { get; set; }
        [DataProperty] public bool Display { get; set; }
        [DataProperty] public int CustomChangeBitMask { get; set; }

    }
}
