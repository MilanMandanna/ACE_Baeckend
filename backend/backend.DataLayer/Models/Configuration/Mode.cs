using System;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
    public class Mode
    {
        [DataProperty]
        public string Name { get; set; }
        [DataProperty]
        public string Id { get; set; }
        [DataProperty]
        public string ScriptName { get; set; }
        [DataProperty]
        public string ScriptId { get; set; }
    }
}
