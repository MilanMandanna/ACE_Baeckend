using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IGlobalConfigurationRepository
    {
        Task<IEnumerable<Language>> GetAllLanguages();
        Task<IEnumerable<FontFile>> GetFonts(int configurationId);
        Task<IEnumerable<SelectedLanguage>> GetSelectedLanguages(int configurationId);
        Task<int> AddLanguages(int configurationId, List<string> twoLetterLanguageCodes);
        Task<int> RemoveLanguage(int configurationId, string twoLetterLanguageCode);
        Task<int> MoveLanguageCodeToPosition(int configurationId, string languageCode, int position);
        Task<int> UpdateLanguagesSetting(int configurationId, string languageCode, string name, string value);
        Task<int> SetLanguageAsDefault(int configurationId, string languageCode);
    }
}
