using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Mappers.DataTransferObjects.Operator
{
    public class OperatorListDTO
    {
        public Guid Id { get; set; }
        public Guid CreatedByUserId { get; set; }
        public DateTimeOffset DateCreated { get; set; }
        public bool IsDeleted { get; set; }
        public string Name { get; set; }
        public int Salutation { get; set; }
        public int SecondarySalutation { get; set; }
        public bool IsTest { get; set; }
    }
}
