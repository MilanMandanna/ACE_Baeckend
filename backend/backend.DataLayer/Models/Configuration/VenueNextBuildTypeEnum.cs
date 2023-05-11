using System.ComponentModel;

namespace backend.DataLayer.Models.Configuration
{
    public enum VenueNextBuildTypeEnum
    {
        [Description("HD_Briefings_Config")]
        hdbrfcfg = 1,

        [Description("HD_Briefings_Content")]
        hdbrfcnt = 2,

        [Description("Custom_Config")]
        mcc = 3,

        [Description("Configuration")]
        mcfg = 4,

        [Description("Content")]
        mcnt = 5,

        [Description("Database")]
        mdata = 6,

        [Description("Insets")]
        minsets = 7,

        [Description("Mobile_Configuration")]
        mmobilecc = 8,

        [Description("Timezone_database")]
        mtz = 9
    }
}
