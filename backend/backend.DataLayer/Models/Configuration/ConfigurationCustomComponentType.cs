using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;

namespace backend.DataLayer.Models.Configuration
{
    public enum ConfigurationCustomComponentType
    {
        [Description("site identification")] 
        SiteIdentificationconfiguration = 1,

        [Description("system config")]
        SystemConfiguraiton = 2,

        [Description("flight data configuration")]
        FlightDataconfiguration = 3,

        [Description("timezone database")]
        TimezoneDatabaseconfiguration = 4,

        [Description("flight phase profile")]
        FlightPhaseconfiguration = 5,

        [Description("acars configuration")]
        ACARSDataconfiguration = 6,

        [Description("sizes configuration")]
        Sizesconfiguration = 7,

        [Description("3d")]
        Content3Dconfiguration = 8,

        [Description("content mobile configuration")]
        ContentMobileconfiguration = 9,

        [Description("Installation Scripts Venue Next")]
        VenueNextscripts = 10,

        [Description("ces")]
        CESscripts = 11,

        [Description("resolution")]
        ResolutionMapconfiguration = 12,

        [Description("briefings configuration")]
        Briefingsconfiguration = 13,

        [Description("flight deck controller menu")]
        FlightDeckconfiguration = 14,

        [Description("mobile configuration platform")]
        mobileconfigurationplatform = 15,

        [Description("Content ASXi3 Aircraft Models")]
        content3daircraftmodels = 16,

        [Description("ticker ads configuration")]
        tickeradsconfiguration = 17,

        [Description("mmobilecc configuration")]
        mmobileccconfiguration = 18,

        [Description("discrete inputs")]
        DiscreteInputs = 19,

        [Description("FDC Map Menu list")]
        FDCMapMenuList = 36,

        [Description("Textures")]
        Texturesconfiguration = 37,

        [Description("briefings (non hd)")]
        BriefingsNonHd = 28,

        [Description("Installation Scripts Venue Hybrid")]
        InstallationScriptsVenueHybrid = 35,

        [Description("map package blue marble")]
        MapPackageBlueMarble = 29,

        [Description("map package borderless blue marble")]
        MapPackageBorderlessBlueMarble = 30,

        [Description("content htse 1280x720")]
        ContentHtse1280x720 = 31,

        [Description("content asxi3 standard 3d")]
        ContentASXI3Standard3d = 32,

        [Description("content asxi3 aircraft models")]
        ContentASXI3AircraftModals = 33,

        [Description("font data")]
        FontData = 38,

        [Description("custom xml")]
        customXML = 39,
    }
}
