using backend.Helpers.Validator;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts
{
    public interface IImportService
    {
        Task<DataCreationResultDTO> ImportInitialConfig(int configurationId, UserListDTO user, string filePath, string taskName);
        Task<DataCreationResultDTO> ImportCustomContent(int configurationId, FileUploadType fp, UserListDTO user);
    }

}
