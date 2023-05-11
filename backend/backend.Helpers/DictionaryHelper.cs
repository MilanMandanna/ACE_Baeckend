using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Helpers
{
    public static class DictionaryHelper
    {
        public static bool AreDictionariesEqual(Dictionary<string, string> dict1, Dictionary<string, string> dict2)
        {
            bool equal = false;
            if (dict1.Count == dict2.Count) // Require equal count.
            {
                equal = true;
                foreach (var pair in dict1)
                {
                    string value;
                    if (dict2.TryGetValue(pair.Key, out value))
                    {
                        // Require value be equal.
                        if (value != pair.Value)
                        {
                            equal = false;
                            break;
                        }
                    }
                    else
                    {
                        // Require key be present.
                        equal = false;
                        break;
                    }
                }
            }
            return equal;
        }
    }
}
