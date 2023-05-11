using CsvHelper.Configuration;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Configuration
{
    public class InfoSpellingDTO
    {
      

        public string InfoId { get; set; }

        public string Lang_EN { get; set; }

        public string Lang_FR { get; set; }

        public string Lang_DE { get; set; }

        public string Lang_ES { get; set; }

        public string Lang_ZH { get; set; }

        public string Lang_AR { get; set; }

        public string Lang_RU { get; set; }

        public string Lang_PT { get; set; }
        public string Lang_DU { get; set; }
        public string Lang_IT { get; set; }
        public string Lang_GK { get; set; }
        public string Lang_JA { get; set; }
        public string Lang_KO { get; set; }
        public string Lang_BA { get; set; }
        public string Lang_TU { get; set; }
        public string Lang_MA { get; set; }
        public string Lang_FI { get; set; }
        public string Lang_HI { get; set; }
        public string Lang_TI { get; set; }
        public string Lang_RO { get; set; }
        public string Lang_SE { get; set; }
        public string Lang_SW { get; set; }
        public string Lang_HU { get; set; }
        public string Lang_HE { get; set; }
        public string Lang_PL { get; set; }
        public string Lang_CC { get; set; }
        public string Lang_VN { get; set; }
        public string Lang_SA { get; set; }
        public string Lang_CZ { get; set; }
        public string Lang_TO { get; set; }
        public string Lang_DA { get; set; }
        public string Lang_IC { get; set; }
        public string Lang_KK { get; set; }
        public string Lang_FA { get; set; }
        public string Lang_TK { get; set; }
        public string Lang_BN { get; set; }
        public string Lang_MN { get; set; }
        public string Lang_BO { get; set; }
        public string Lang_AZ { get; set; }
        public string Lang_EP { get; set; }
        public string Lang_LS { get; set; }
        public string Lang_NO { get; set; }
        public string Lang_LK { get; set; }
    }

    public class InfoSpellingDTOMap : ClassMap<InfoSpellingDTO>
    {
        public InfoSpellingDTOMap()
        {
            Map(m => m.InfoId).Name("InfoId");
            Map(m => m.Lang_EN).Name("ENGLISH");
            Map(m => m.Lang_FR).Name("FRENCH");
            Map(m => m.Lang_DE).Name("GERMAN");
            Map(m => m.Lang_ES).Name("SPANISH");
            Map(m => m.Lang_DU).Name("DUTCH");
            Map(m => m.Lang_IT).Name("ITALIAN");
            Map(m => m.Lang_GK).Name("GREEK");
            Map(m => m.Lang_JA).Name("JAPANESE");
            Map(m => m.Lang_ZH).Name("TRAD_CHINESE");
            Map(m => m.Lang_KO).Name("KOREAN");
            Map(m => m.Lang_BA).Name("BAHASA");
            Map(m => m.Lang_AR).Name("ARABIC");
            Map(m => m.Lang_TU).Name("TURKISH");
            Map(m => m.Lang_MA).Name("MALAY");
            Map(m => m.Lang_FI).Name("FINNISH");
            Map(m => m.Lang_HI).Name("HINDI");
            Map(m => m.Lang_RU).Name("RUSSIAN");
            Map(m => m.Lang_PT).Name("PORTUGUESE");
            Map(m => m.Lang_TI).Name("THAI");
            Map(m => m.Lang_RO).Name("ROMANIAN");
            Map(m => m.Lang_SE).Name("SERBIAN");
            Map(m => m.Lang_SW).Name("SWEDISH");
            Map(m => m.Lang_HU).Name("HUNGARIAN");
            Map(m => m.Lang_HE).Name("HEBREW");
            Map(m => m.Lang_PL).Name("POLISH");
            Map(m => m.Lang_CC).Name("SIMP_CHINESE");
            Map(m => m.Lang_VN).Name("VIETNAMESE");
            Map(m => m.Lang_SA).Name("SAMOAN");
            Map(m => m.Lang_TO).Name("TONGAN");
            Map(m => m.Lang_CZ).Name("CZECH");
            Map(m => m.Lang_DA).Name("DANISH");
            Map(m => m.Lang_IC).Name("ICELANDIC");
            Map(m => m.Lang_KK).Name("KAZAKH");
            Map(m => m.Lang_FA).Name("DARI");
            Map(m => m.Lang_TK).Name("TURKMEN");
            Map(m => m.Lang_BN).Name("BENGALI");
            Map(m => m.Lang_MN).Name("MONGOLIAN");
            Map(m => m.Lang_BO).Name("TIBETAN");
            Map(m => m.Lang_AZ).Name("AZERI");
            Map(m => m.Lang_EP).Name("EUROPEAN_PORTUGUESE");
            Map(m => m.Lang_LS).Name("LATIN_SPANISH");
            Map(m => m.Lang_NO).Name("NORWEGIAN");
            Map(m => m.Lang_LK).Name("LATIN_KAZAKH");
        }
    }
}
