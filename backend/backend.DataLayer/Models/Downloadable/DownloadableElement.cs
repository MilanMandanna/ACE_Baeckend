using System;
using System.Collections.Generic;
using System.Linq;
using Ace.DataLayer.Models;
using Ace.DataLayer.Interfaces;

namespace Ace.DataLayer.Models
{
    public class DownloadableElement : IAircraftSelection, INamedElement
    {
        public DownloadableElement()
        {
            Id = Guid.NewGuid();
        }

        public virtual Aircraft Aircraft { get; set; }
        public virtual Guid AircraftId { get; set; }

        public string DownloadPreferences { get; set; }
        public virtual Guid Id { get; set; }

        public string Name { get; set; }
        public virtual int Order { get; set; }
        int IAircraftSelection.AircraftId { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        int IElement.Id { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
    }   
}