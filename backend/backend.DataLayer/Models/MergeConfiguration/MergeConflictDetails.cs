using System.Collections.Generic;

namespace backend.DataLayer.Models.MergeConfiguration
{
    public class MergeConflictDetails
    {
        public int ID { get; set; }
        public string ContentType { get; set; }
        public int ContentID { get; set; }
        public string Description { get; set; }
        public string DisplayName { get; set; }
        public string ParentValue { get; set; }
        public string ChildValue { get; set; }
        public string SelectedValue { get; set; }
    }
}
