using System;
using Ace.DataLayer.Models;

namespace Ace.DataLayer.Interfaces
{
    public interface IAircraftSelection
    {
        Aircraft Aircraft { get; set; }
        int AircraftId { get; set; }

    }
}