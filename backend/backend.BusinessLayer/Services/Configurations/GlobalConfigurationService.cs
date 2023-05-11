using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using backend.BusinessLayer.Contracts.Configuration;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Extensions;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.User;

namespace backend.BusinessLayer.Services.Configurations
{
    public class GlobalConfigurationService : IGlobalConfigurationService
    {

        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private ILoggerManager _logger;
        public GlobalConfigurationService(IUnitOfWork unitOfWork, IMapper mapper, ILoggerManager logger)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
        }

        /// <summary>
        /// Get the list of all the languages corresponding to the configuraton.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<IEnumerable<LanguageDTO>> GetConfigurationLanguages()
        {
            using var context = _unitOfWork.Create;
            var languages = await context.Repositories.GlobalConfigurationRepository.GetAllLanguages();
            var result = _mapper.Map<IEnumerable<Language>, IEnumerable<LanguageDTO>>(languages);
            return result;
        }

        /// <summary>
        /// Gte all the languages with attributes like unit,clock etc under global/language_set tag for the corresponding confguration.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<IEnumerable<SelectedLanguageDTO>> GetSelectedLanguages(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var selectedLanguages = await context.Repositories.GlobalConfigurationRepository.GetSelectedLanguages(configurationId);
            var result = _mapper.Map<IEnumerable<SelectedLanguage>, IEnumerable<SelectedLanguageDTO>>(selectedLanguages);
            return result;
        }

        /// <summary>
        /// add one more languages to  global/language_set tag.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="languages"> single 2 letter language code or 2 letter language code as comma seperated list.</param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> AddLanguages(int configurationId, string[] languages)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.GlobalConfigurationRepository.AddLanguages(configurationId, languages.ToList());
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Language/s has been added" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Adding Languages" };
        }

        /// <summary>
        ///   removed languages from  global/language_set tag.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="languageCode"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> RemoveLanguage(int configurationId, string languageCode)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.GlobalConfigurationRepository.RemoveLanguage(configurationId, languageCode);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Language has been removed" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Removing Language" };
        }

        /// <summary>
        /// Reposition language order under  global/language_set tag.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="languageCode"></param>
        /// <param name="position"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> MoveLanguageCodeToPosition(int configurationId, string languageCode, int position)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.GlobalConfigurationRepository.MoveLanguageCodeToPosition(configurationId, languageCode, position);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Language has been Moved to Position " + Convert.ToString(position + 1) };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Re-Positioning Language" };
        }


        /// <summary>
        /// update the clock,decimal,grouping,units,interactive clock, interactive units values for the given language.
        /// If the language code is "global", updates all the language's attributes under the global tag.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="languageCode"></param>
        /// <param name="name"></param>
        /// <param name="value"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> UpdateLanguagesSetting(int configurationId, string languageCode, string name, string value)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.GlobalConfigurationRepository.UpdateLanguagesSetting(configurationId, languageCode, name, value);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Language has been Updated" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Updating Language" };
        }

        /// <summary>
        /// update the /global/language_set/@default tag with given language code.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="languageCode"></param>
        /// <returns></returns>

        public async Task<DataCreationResultDTO> SetLanguageAsDefault(int configurationId, string languageCode)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.GlobalConfigurationRepository.SetLanguageAsDefault(configurationId, languageCode);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Language has been Set as Default" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Setting Language as Default" };
        }

        /// <summary>
        /// set the font file as selected for configuratio id.
        /// If the fontfileselectionmap is already present then update the same mapping with new font file id. Otherwise create new mapping.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="fontFileId"></param>
        /// <param name="currentUser"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> SetFontFileSeletedForConfiguration(int configurationId, int fontFileId, UserListDTO currentUser)
        {
            using var context = _unitOfWork.Create;
            int fontSelectionMap = await context.Repositories.FontConfigurationMappingRepository.GetFontSelectionMappingCountForConfiguration(configurationId);
            var fontFileSelection = await context.Repositories.FontConfigurationMappingRepository.GetFontSelectionIdForFont(fontFileId);
            if (fontSelectionMap > 0 && fontFileSelection != null)
            {
                var fontFileSelectionConfiguration = (await context.Repositories.FontConfigurationMappingRepository.FilterAsync("ConfigurationID", configurationId)).FirstOrDefault();
                var updateData = _mapper.Map<FontConfigurationMapping>(fontFileSelectionConfiguration);

                if (updateData != null)
                {
                    updateData.PreviousFontFileSelectionID = updateData.FontFileSelectionID;
                    updateData.FontFileSelectionID = fontFileSelection.FontFileSelectionID;
                    updateData.LastModifiedBy = currentUser.Id.ToString();

                    int updateResult = await context.Repositories.FontConfigurationMappingRepository.UpdateFontSelectionMapping(configurationId,updateData);
                    if (updateResult > 0)
                    {
                        await context.SaveChanges();
                        return new DataCreationResultDTO { IsError = false, Message = "Font File Selection Updated" };
                    }
                }
                return new DataCreationResultDTO { IsError = true, Message = "Error Updating Font File Selection" };

            }
            else
            {
                var fontConfigurationMapping = new FontConfigurationMapping
                {
                    ConfigurationID = configurationId,
                    FontFileSelectionID = fontFileSelection != null ? fontFileSelection.FontFileSelectionID : 0,
                    PreviousFontFileSelectionID = null,
                    IsDeleted = false,
                    LastModifiedBy = currentUser != null && currentUser.Id.ToString() != null ? currentUser.Id.ToString() : Guid.Empty.ToString(),
                    Action = ""
                };

                int updateResult = await context.Repositories.FontConfigurationMappingRepository.InsertAsync(fontConfigurationMapping);
                if (updateResult > 0)
                {
                    await context.SaveChanges();
                    return new DataCreationResultDTO { IsError = false, Message = "New Font File Selection Created" };
                }
                return new DataCreationResultDTO { IsError = true, Message = "Error Creating Font File Selection" };

            }

        }

        /// <summary>
        /// get the list of fonts for the correspondingconfiguration.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>

        public async Task<IEnumerable<FontFileDTO>> GetConfigurationFonts(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var fonts = await context.Repositories.GlobalConfigurationRepository.GetFonts(configurationId);
            var result = _mapper.Map<IEnumerable<FontFile>, IEnumerable<FontFileDTO>>(fonts);
            
            return result;
        }
    }
}
