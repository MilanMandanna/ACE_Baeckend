using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Helpers
{
    public static class RemoveDuplicates
    {
        public static List<T> RemoveDuplicateItems<T>(List<T> items)
        {
            var result = new List<T>();
            var set = new HashSet<T>();
            for (int i = 0; i < items.Count; i++)
            {
                if (!set.Contains(items[i]))
                {
                    result.Add(items[i]);
                    set.Add(items[i]);
                }
            }
            return result;
        }
    }
}
