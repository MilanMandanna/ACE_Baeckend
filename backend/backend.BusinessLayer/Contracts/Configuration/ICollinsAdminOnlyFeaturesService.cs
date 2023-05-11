using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.Subscription;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Operator;
using backend.Mappers.DataTransferObjects.User;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts.Configuration
{
    public interface ICollinsAdminOnlyFeaturesService
    {
        Task<DataDownloadResultDTO> DownloadArtifactsByRevision(int configurationId, string[] inputData);
        Task<List<string>> GetCollinsAdminItems(int configurationId);
        Task<List<AdminOnlyDownloadDetails>> GetDownloadDetails(int configurationId, string pageName);
        Task<DataCreationResultDTO> UploadRequiredFeatures(int configurationId, string tempPath, string pageName, string packageType, Guid userId);
        Task<string> GetErrorLog(int configurationId, string pageName);
        Task<ActionResult> DownloadInsetsByRevision(int configurationId);
    }
}
