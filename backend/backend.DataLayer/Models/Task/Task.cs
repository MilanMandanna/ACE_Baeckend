using System;
using System.Collections.Generic;
using System.Text;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Task
{
    public class Task
    {
        [DataProperty]
        public Guid ID { get; set; }
        [DataProperty]
        public Guid TaskStatusID { get; set; }
        [DataProperty]
        public string DetailedStatus { get; set; }
                
    }

}
