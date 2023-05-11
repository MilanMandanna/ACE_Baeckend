using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using backend.BusinessLayer.Contracts;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Task;

namespace backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TaskController :  PortalController
    {
        private readonly ITaskService _taskService;
        private readonly ILoggerManager _logger;

        public TaskController(ITaskService taskService, ILoggerManager logger)
        {
            _taskService = taskService;
            _logger = logger;
        }

        /// <summary>
        /// Creates new task into the database. 
        /// </summary>
        /// <param name="task"></param>
        /// <returns>Newly created object</returns>
        [HttpPost]
        [Route("create")]        
        public async Task<ActionResult<backend.DataLayer.Models.Task.Task>> createTask(TaskInput task )
        {            
            try
            {
                return Ok(await _taskService.createTask(task.TaskTypeID, task.UserID, task.TaskStatusID, task.PercentageComplete, task.DetailedStatus, task.AzureBuildID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Error Occured" + ex);
                return NoContent();
            }

        }
      

        /// <summary>
        /// Updates the status, percentage and details of the task
        /// </summary>
        /// <param name="task"></param>
        /// <returns>Updated Task</returns>
        [HttpPost]
        [Route("update")]
        public async Task<ActionResult<backend.DataLayer.Models.Task.Task>> updateTask(TaskInput task)
        {           
            try
            {                
                return Ok(await _taskService.updateTask(task.TaskID,  task.TaskStatusID, task.PercentageComplete, task.DetailedStatus));
            }
            catch (Exception ex)
            {
                _logger.LogError("Error Occured" + ex);
                return NoContent();
            }
        }

        /// <summary>
        /// Returns list of tasks based on the ID type ("USER", "Configuration","Aircraft"..etc ) passed.
        /// </summary>
        /// <param name="ID"></param>
        /// <returns></returns>
        [HttpGet]
        [Route("Pending")]
        public async Task<ActionResult<IEnumerable<backend.DataLayer.Models.Task.Task>>> pendingTasks(QueryID ID)
        {            
            try
            {
                return Ok(await _taskService.getPendingTasks(ID.IDType, ID.ID));
            }
            catch (Exception ex)
            {
                _logger.LogError("Error Occured" + ex);
                return NoContent();
            }
        }        
  
    }

    // Input jason structure for get pending tasks
    public class QueryID
    {
        public Guid ID { get; set; }
        public String IDType { get; set; }
    }

    // Input jason structure
    public class TaskInput
    {
        public Guid TaskID { get; set; }
        public Guid TaskTypeID { get; set; }
        public Guid UserID { get; set; }
        public Guid TaskStatusID { get; set; }
        public float PercentageComplete { get; set; }
        public string DetailedStatus { get; set; }
        public int AzureBuildID { get; set; }
    }
}
