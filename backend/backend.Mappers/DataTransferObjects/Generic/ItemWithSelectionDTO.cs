using backend.DataLayer.Models;
using backend.DataLayer.Models.DataStructure;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Generic
{
    public class ItemWithSelectionDTO
    {
        public SelectionState IsSelected { get; set; }

        public string Name { get; set; }

        public string Title { get; set; }
    }
}
