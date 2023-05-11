using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.User;

namespace backend.BusinessLayer.Contracts.Configuration
{
    public interface IGlobalConfigurationService
    {
        Task<IEnumerable<LanguageDTO>> GetConfigurationLanguages();
        Task<IEnumerable<SelectedLanguageDTO>> GetSelectedLanguages(int configurationId);
        Task<DataCreationResultDTO> AddLanguages(int configurationId, string[] languages);
        Task<DataCreationResultDTO> RemoveLanguage(int configurationId, string languageCode);
        Task<DataCreationResultDTO> MoveLanguageCodeToPosition(int configurationId, string languageCode, int position);
        Task<DataCreationResultDTO> UpdateLanguagesSetting(int configurationId, string languageCode, string name, string value);
        Task<DataCreationResultDTO> SetLanguageAsDefault(int configurationId, string languageCode);

        Task<IEnumerable<FontFileDTO>> GetConfigurationFonts(int configurationId);
        Task<DataCreationResultDTO> SetFontFileSeletedForConfiguration(int configurationId, int fontFileId, UserListDTO currentUser);

    }
}
