using System.ComponentModel;

namespace backend.DataLayer.Models.Configuration
{
    public enum VenueNextPartNumberCollection
    {
        [Description("HD Briefings Config (hdbrfcfg)")]
        hdbrfcfg = 1,

        [Description("HD Briefings Config CII")]
        hdbrfcfgCII = 2,

        [Description("HD Briefings Content (hdbrfcnt)")]
        hdbrfcnt = 3,

        [Description("HD Briefings Content CII")]
        hdbrfcntCII = 4,

        [Description("Customer Content (mcc)")]
        mcc = 5,

        [Description("Configuration (mcfg)")]
        mcfg = 6,

        [Description("Content (mcnt)")]
        mcnt = 7,

        [Description("Data (mdata)")]
        mdata = 8,

        [Description("Insets (minsets)")]
        minsets = 9,

        [Description("Mobile Configuration (mmobilecc)")]
        mmobilecc = 10,

        [Description("Timezone Database (mtz)")]
        mtz = 11,
    }
}
