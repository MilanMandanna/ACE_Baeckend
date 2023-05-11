using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Generic
{
    /** tbd */
    public class DataCreationResultDTO
    {
        public Guid Id { get; set; }

        public bool IsError { get; set; }

        public string Message { get; set; }
    }
}
