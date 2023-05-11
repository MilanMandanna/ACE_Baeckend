using System.ComponentModel;

namespace backend.DataLayer.Models.Configuration
{
    public enum VenueHybridPartNumberCollection
    {
        [Description("HD Briefings Config (hdbrfcfg)")]
        hdbrfcfg = 12,

        [Description("HD Briefings Config CII")]
        hdbrfcfgCII = 13,

        [Description("HD Briefings Content (hdbrfcnt)")]
        hdbrfcnt = 14,

        [Description("HD Briefings Content CII")]
        hdbrfcntCII = 15,

        [Description("Audio / Video Briefings (avb)")]
        avb = 16,

        [Description("Audio / Video Briefings CII")]
        avbCII = 17,

        [Description("Briefings Config (brfcfg)")]
        brfcfg = 18,

        [Description("Briefings Config CII")]
        brfcfgCII = 19,
		
		[Description("Timezone Database (mmcdp)")]
        mmcdp = 28,

        [Description("Timezone Database CII")]
        mmcdpCII = 29,

        [Description("Blue Marble Map Package (bmp)")]
        bmp = 20,

        [Description("Blue Marble Map Package CII")]
        bmpCII = 21,
		
        [Description("Insets (minsets)")]
        minsets = 32,

        [Description("Content (mmcntp)")]
        mmcntp=24,

        [Description("Content CII")]
        mmcntpCII = 25,

        [Description("Configuration (mmcfgp)")]
        mmcfgp = 22,

        [Description("Configuration CII")]
        mmcfgpCII = 23,

        [Description("Data (mmdbp)")]
        mmdbp = 26,

        [Description("Data CII")]
        mmdbpCII = 27
    }
}
