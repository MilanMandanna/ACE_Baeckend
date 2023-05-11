using backend.DataLayer.Models.Subscription;
using backend.Mappers.DataTransferObjects.Subscription;
using System;
using System.Collections.Generic;

namespace backend.Mappers.DataTransferObjects.Aircraft
{
    public class AircraftDTO
    {

        public virtual DateTimeOffset DateCreated { get; set; }

        public virtual DateTimeOffset DateModified { get; set; }

        public virtual DateTimeOffset LastPasswordChange { get; set; }

        public virtual Guid Id { get; set; }

        public bool IsDeleted { get; set; }

        public virtual String TailNumber { get; set; }

        public virtual String SerialNumber { get; set; }

        public virtual String ConnectivityTypes { get; set; }

        public virtual int ContentDiskSpace { get; set; }

        public virtual DateTimeOffset LastManifestCreatedDate { get; set; }

        public virtual string Manufacturer { get; set; }

        public virtual string Model { get; set; }

        public virtual string ModifiedBy { get; set; }

        public virtual Guid OperatorId { get; set; }

        public long SelectedAssetsCount { get; set; }

        public long SelectedAssetsSize { get; set; }

        public Guid InstallationTypeID { get; set; }
        
        public Guid ThirdPartyRoleID { get; set; }

        public SubscriptionDTO Subscription { get; set; }

        public string OperatorName { get; set; }

        public bool IsReadOnly { get; set; }

        public ConfigurationDefinitionSetting ConfigurationDefinitionSettings { get; set; }

        public Guid CreatedByUserId { get; set; }
    }
}
