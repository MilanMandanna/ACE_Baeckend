using System;
using System.Collections.Generic;
using System.Text;

namespace Ace.DataLayer.Interfaces
{
    public interface INotDeleteble : IElement
    {
        bool IsDeleted { get; set; }
    }
}
