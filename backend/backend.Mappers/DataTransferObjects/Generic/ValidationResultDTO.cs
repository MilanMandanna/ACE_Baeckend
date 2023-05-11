using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Generic
{
    public class ValidationResultDTO
    {
        public bool IsValid { get; set; }

        public string Details { get; set; }
    }
}
