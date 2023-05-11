using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Task
{
    public enum TaskStatus
    {
        NotStarted = 1,
        InProgress = 2,
        Failed = 3,
        Succeeded = 4
    }
}
