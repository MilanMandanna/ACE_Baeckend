using System;
using System.Collections.Generic;
using System.Text;

namespace Ace.DataLayer.Interfaces
{
    public interface ICreatedElement
    {
        DateTimeOffset DateCreated { get; set; }
    }
}
