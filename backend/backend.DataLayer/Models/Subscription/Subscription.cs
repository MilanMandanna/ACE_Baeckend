using backend.DataLayer.Helpers.Database;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Models.Subscription
{
    [DataProperty(TableName = "dbo.tblSubscription")]
    public class Subscription
    {
        [DataProperty(PrimaryKey = true)]
        public Guid Id { get; set; }

        [DataProperty]
        public string Name { get; set; }

        [DataProperty]
        public string Description { get; set; }

        [DataProperty]
        public bool IsObsolete { get; set; }

        [DataProperty]
        public DateTime DateCreated { get; set; }

        public Byte[] DateLastModified { get; set; }

    }
}
