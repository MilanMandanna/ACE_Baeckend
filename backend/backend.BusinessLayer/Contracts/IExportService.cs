using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts
{
    public interface IExportService
    {

        Task<DataCreationResultDTO> ExportDevelopmentConfig(int configurationId, UserListDTO user);

        Task<ActionResult> DownloadProduct(int configurationId, UserListDTO user);

        Task<ActionResult> DownloadProductByDefinition(int configurationDefinitionId, UserListDTO user);
    }
}
