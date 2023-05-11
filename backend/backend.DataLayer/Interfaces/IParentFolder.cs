using Ace.DataLayer.Models;

using System;

namespace Ace.DataLayer.Interfaces
{
    public interface IParentFolder
    {
        DocumentFolder ParentFolder { get; set; }
        Guid ParentFolderId { get; set; }
    }
}
