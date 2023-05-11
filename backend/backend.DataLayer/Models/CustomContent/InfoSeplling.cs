using backend.DataLayer.Models.Configuration;
using System;
using System.Collections.Generic;
using System.Dynamic;
using System.Text;
using System.Text.Json.Serialization;

namespace backend.DataLayer.Models.CustomContent
{
    public class InfoSeplling
    {
        public int InfoId { get; set; }
        public int InfoSpellingId { get; set; }
        public int LanguageId { get; set; }
    }

    public class InfoSepllingDisplay
    {
        public List<Language> Headers { get; set; }
        public List<dynamic> Spellings { get; set; }
    }

    public class KeyValues
    {
        public int Key { get; set; }
        public string  Value { get; set; }
    }
}
