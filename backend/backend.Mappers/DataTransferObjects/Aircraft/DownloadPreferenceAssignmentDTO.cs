using backend.Mappers.DataTransferObjects.Generic;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Aircraft
{
    /**
     * Data transfer object for passing download preference data to the client
     **/ 
    public class DownloadPreferenceAssignmentDTO
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
        public string Title { get; set; }
        public List<ItemWithSelectionDTO> PreferenceList { get; set; }
    }
}
