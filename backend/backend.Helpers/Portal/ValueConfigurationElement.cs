using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;

namespace backend.Helpers.Portal
{
    public class ValueConfigurationElement : ConfigurationElement
    {
        [ConfigurationProperty("value", IsRequired = true, IsKey = true)]
        public string Value
        {
            get { return this["value"] as string; }
            set { this["value"] = value; }
        }
    }
}
