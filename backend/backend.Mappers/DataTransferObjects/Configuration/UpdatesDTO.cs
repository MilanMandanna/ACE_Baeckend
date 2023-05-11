using System;
namespace backend.Mappers.DataTransferObjects.Configuration
{
    public class UpdatesDTO
    {
        public int Updates { get; set; }
        public bool HasConflicts { get; set; }
    }
}
