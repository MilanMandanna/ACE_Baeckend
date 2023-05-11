using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.ASXSwg
{
    [DataProperty(TableName = "tbwgtext")]
    public class ASXIWorldGuideText
    {
        [DataProperty] public int TextID { get; set; }
        [DataProperty] public string Text_EN { get; set; }
        [DataProperty] public string Text_FR { get; set; }
        [DataProperty] public string Text_DE { get; set; }
        [DataProperty] public string Text_ES { get; set; }
        [DataProperty] public string Text_NL { get; set; }
        [DataProperty] public string Text_IT { get; set; }
        [DataProperty] public string Text_EL { get; set; }
        [DataProperty] public string Text_JA { get; set; }
        [DataProperty] public string Text_ZH { get; set; }
        [DataProperty] public string Text_KO { get; set; }
        [DataProperty] public string Text_ID { get; set; }
        [DataProperty] public string Text_AR { get; set; }
        [DataProperty] public string Text_TR { get; set; }
        [DataProperty] public string Text_MS { get; set; }
        [DataProperty] public string Text_FI { get; set; }
        [DataProperty] public string Text_HI { get; set; }
        [DataProperty] public string Text_RU { get; set; }
        [DataProperty] public string Text_PT { get; set; }
        [DataProperty] public string Text_TH { get; set; }
        [DataProperty] public string Text_RO { get; set; }
        [DataProperty] public string Text_SR { get; set; }
        [DataProperty] public string Text_SV { get; set; }
        [DataProperty] public string Text_HU { get; set; }
        [DataProperty] public string Text_HE { get; set; }
        [DataProperty] public string Text_PL { get; set; }
        [DataProperty] public string Text_HK { get; set; }
        [DataProperty] public string Text_SM { get; set; }
        [DataProperty] public string Text_TO { get; set; }
        [DataProperty] public string Text_CS { get; set; }
        [DataProperty] public string Text_DA { get; set; }
        [DataProperty] public string Text_IS { get; set; }
        [DataProperty] public string Text_VI { get; set; }

    }
}
