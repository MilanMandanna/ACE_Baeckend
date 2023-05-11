using System.Collections.Generic;
using Ace.DataLayer.Models;

namespace Ace.DataLayer.Interfaces
{
    public interface ISelectable: INamedElement
    {
        ICollection<Aircraft> Aircrafts { get; set; }
    }
}