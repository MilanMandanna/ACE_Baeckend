using System;
using System.Collections.Generic;
using System.Text;
using Newtonsoft.Json;

namespace backend.Mappers.DataTransferObjects.Aircraft
{
    public class MsuConfigurationDto
    {

        public Guid Id { get; set; }
       
        [JsonProperty("file_name")]
        public string FileName { get; set; }        

        [JsonProperty("date_created")]
        public DateTimeOffset DateCreated { get; set; }
    }
}
