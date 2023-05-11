using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Manage
{
    public class ClaimsDTO
    {
        public Guid ID { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
    }
}
