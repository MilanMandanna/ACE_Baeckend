using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Build
{
    /**
     * Class that represents the data written to the azure build queue
     */
    public class BuildQueueItem
    {
        public BuildTask Config { get; set; }

        public Boolean Debug { get; set; }
    }
}
