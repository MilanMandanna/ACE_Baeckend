using backend.DataLayer.Models.DataStructure;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Generic
{
    /**
     * Data transfer object for reporting selection results to the client
     **/ 
    public class SelectionResultDTO
    {
        public SelectionState IsSelected { get; set; }

    }
}
