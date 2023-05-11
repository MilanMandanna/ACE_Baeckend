using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Threading.Tasks;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Extensions;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IFontConfigurationMappingRepository:
        IInsertAsync<FontConfigurationMapping>,
        IUpdateAsync<FontConfigurationMapping>,
        IFindAllAsync<FontConfigurationMapping>,
        IFilterAsync<FontConfigurationMapping>

    {
        Task<int> GetFontSelectionMappingCountForConfiguration(int configurationId);
        Task<FontFileSelection> GetFontSelectionIdForFont(int fontFileId);
        Task<int> UpdateFontSelectionMapping(int configurationId, FontConfigurationMapping updateData);
        Task<List<FontInfo>> GetFontInfoForLangugaeId(int languageId, int geoRefCatTypeId, int resolution);


    }
}
