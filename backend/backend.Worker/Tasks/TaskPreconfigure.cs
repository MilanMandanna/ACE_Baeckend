using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using Newtonsoft.Json;
using backend.Worker.Data;

namespace backend.Worker.Tasks
{
    /**
     * The purpose of this task is to download and cache as much information from the server or cloud services that we need locally.
     * This is handy during development since if the task doing the work can handle accessing data from a cache then
     * each development run does not need to download the data over and over
     **/
    // todo: this may not be needed anymore
    public class TaskPreconfigure
    {
        public async Task<int> Run(TaskEnvironment environment, List<string> args)
        {
            /**
             * pseudocode:
             * - check for preconfigure.json
             * - if the file exists and the build id in it is different from the current build id
             * - - wipe out the contents of the temp storage directory
             * - get information about the build from the server
             * - download any support files specified in the build from the cloud or other sources
             * - record build information and downloaded files in a new preconfigure.json
             **/
            return 0;
        }

    }
}
