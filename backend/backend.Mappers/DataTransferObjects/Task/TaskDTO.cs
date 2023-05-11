using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Task
{
    public class TaskDTO
    {
        public Guid ID { get; set; }
        public string Name { get; set; }
        public string Status { get; set; }       
        public int Error { get; set; }
        public string ErrorDescription { get; set; } 
    }

}
