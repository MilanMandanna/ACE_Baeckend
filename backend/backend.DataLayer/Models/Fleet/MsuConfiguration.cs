using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Fleet
{
    public class MsuConfiguration 
    {
        public virtual Guid Id { get; set; }

        public virtual string TailNumber { get; set; }
        public virtual string FileName { get; set; }
        public virtual string ConfigurationBody { get; set; }

        public virtual DateTimeOffset DateCreated { get; set; }
    }
}
