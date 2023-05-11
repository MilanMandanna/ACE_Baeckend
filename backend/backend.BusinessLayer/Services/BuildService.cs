using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using AutoMapper;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models.Build;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Helpers.Azure;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;

namespace backend.BusinessLayer.Services
{
    public class BuildService : IBuildService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private ILoggerManager _logger;
        private Helpers.Configuration _configuration;

        public BuildService(IUnitOfWork unitOfWork, IMapper mapper, ILoggerManager logger, Helpers.Configuration configuration)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
            _configuration = configuration;
        }

        public async Task<IEnumerable<BuildProgress>> BuildProgress(string[] taskIds)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.TaskRepository.GetBuildProgress(taskIds);
        }

        public async Task<DataCreationResultDTO> CancelBuild(string taskId)
        {
            using var context = _unitOfWork.Create;
            var result =  await context.Repositories.TaskRepository.CancelBuild(new Guid(taskId));
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Task is set to Cancel" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Cancelling the task" };

        }

        public async Task<DataCreationResultDTO> DeleteBuild(string taskId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.TaskRepository.DeleteBuild(new Guid(taskId));
            if (result > 0)
            {
                string containerName = _configuration.AzureExportBlobStorageContainer;
                string connectionString = _configuration.AzureExportBlobStorage;
                string fileName = taskId + ".zip";
                string logfileName = taskId + "-logs.zip";
                await AzureFileHelper.RemoveFile(connectionString, containerName, fileName);
                await AzureFileHelper.RemoveFile(connectionString, containerName, logfileName);
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Build has been deleted" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error deleting the build" };
        }

        public async Task<string> GetErrorLog(string taskId)
        {
            using var context = _unitOfWork.Create;
            var errorlog =  await context.Repositories.TaskRepository.GetErrorLog(new Guid(taskId));
            return errorlog;
        }

        public async Task<BuildProgress> GetActiveImportStatus(string pageName, string configurationId)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.TaskRepository.GetActiveImportStatus(pageName, configurationId);
        }
    }
}
