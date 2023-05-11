using AutoMapper;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.UnitOfWork.Contracts;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Services
{
    public class TaskService : ITaskService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public TaskService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<DataLayer.Models.Task.Task> createTask(Guid taskTypeID, Guid userID, Guid taskStatusID, float percentageComplete, string detailedStatus, int azureBuildID)
        {
           using var context = _unitOfWork.Create;
           DataLayer.Models.Task.Task t = await context.Repositories.TaskRepository.createTask(taskTypeID, userID, taskStatusID, percentageComplete, detailedStatus, azureBuildID);
           await context.SaveChanges();
           return t;
        }

        public async Task<IEnumerable<DataLayer.Models.Task.Task>> getPendingTasks(string type, Guid ID)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.TaskRepository.getPendingTasks(type, ID);           
            
        }

        public async Task<DataLayer.Models.Task.Task> updateTask(Guid taskID, Guid taskStatusID, float percentageComplete, string detailedStatus)
        {
            using var context = _unitOfWork.Create;
            DataLayer.Models.Task.Task t = await context.Repositories.TaskRepository.updateTask(taskID, taskStatusID, percentageComplete, detailedStatus);
            await context.SaveChanges();
            return t;
        }

        
    }
}
