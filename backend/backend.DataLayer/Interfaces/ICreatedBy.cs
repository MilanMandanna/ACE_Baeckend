using System;
using Ace.DataLayer.Models;

namespace Ace.DataLayer.Interfaces
{
    public interface ICreatedBy
    {
        // PortalUser CreatedByUser { get; set; }
        Guid CreatedByUserId { get; set; }
    }
}