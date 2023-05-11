using System;
using System.Collections.Generic;
using System.Text;
using System.Net.Http;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Fleet
{
    public class MsuConfigurationBody
    {
        [DataProperty]
        public string Content { get;  set; }
        [DataProperty]
        public string FileName { get; set; }       
    }
}
