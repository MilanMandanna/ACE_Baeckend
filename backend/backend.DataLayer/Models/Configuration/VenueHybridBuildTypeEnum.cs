using System.ComponentModel;

namespace backend.DataLayer.Models.Configuration
{
    public enum VenueHybridBuildTypeEnum
    {
        [Description("HD_Briefings_Config")]
        hdbrfcfg = 12,

        [Description("HD_Briefings_Content")]
        hdbrfcnt = 14,
		
		[Description("Timezone Database (mmcdp)")]
        mmcdp = 28,

        [Description("Blue Marble Map Package (bmp)")]
        bmp = 20,
        
		[Description("Map_Insets")]
        minsets = 32,

        [Description("Audio/_Video_ Briefings")]
        avb = 16,

        [Description("Briefings_Config ")]
        brfcfg = 18,

        [Description("Content (mmcntp) ")]
        mmcntp = 24,

        [Description("Content (mmcfgp) ")]
        mmcfgp = 22,

        [Description("Data (mmdbp)")]
        mmdbp = 26

    }
}
