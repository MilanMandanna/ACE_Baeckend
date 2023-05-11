using System;
namespace backend.DataLayer.Models.Configuration
{
    public class SelectedLanguage
    {
        public string TwoLetterLanguageCode { get; set; }
        public string Name { get; set; }
        public string Units { get; set; }
        public string Clock { get; set; }
        public string InteractiveUnits { get; set; }
        public string InteractiveClock { get; set; }
        public string Grouping { get; set; }
        public string Decimal { get; set; }
        public bool IsDefault { get; set; }

    }
}
