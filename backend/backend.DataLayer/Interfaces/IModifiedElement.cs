using System;
using System.Collections.Generic;
using System.Text;

namespace Ace.DataLayer.Interfaces
{
    public interface IModifiedElement : IElement
    {
        DateTimeOffset? DateModified { get; set; }
        string ModifiedBy { get; set; }
    }

    public interface IModifiedElementDto : IElement
    {
        DateTimeOffset? DateModified { get; set; }
        bool IsDateModifiedValid { get; set; }
    }
}
