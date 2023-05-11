using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;

namespace backend.Helpers.Portal
{
    public class TypeCollection : ConfigurationElementCollection
    {
        public KeyValueConfigurationElement this[int index]
        {
            get { return (KeyValueConfigurationElement)BaseGet(index); }
            set
            {
                if (BaseGet(index) != null)
                    BaseRemoveAt(index);

                BaseAdd(index, value);
            }
        }

        protected override ConfigurationElement CreateNewElement()
        {
            return new KeyValueConfigurationElement("", null);
        }

        protected override object GetElementKey(ConfigurationElement element)
        {
            return ((KeyValueConfigurationElement)element).Key;
        }
    }
}
