using System;
using System.Collections.Generic;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
    public class Trigger
    {
        [DataProperty]
        public string Name { get; set; }
        [DataProperty]
        public string Id { get; set; }
        [DataProperty]
        public string Condition { get; set; }
        [DataProperty]
        public string Type { get; set; }
        [DataProperty]
        public string IsDefault { get; set; }

        //parameters objects can be either "(", ")", logical Operators like AND, OR, NOT or it can be of type TriggerParamater
        public List<object> parameters { get; set; }

    }
}
