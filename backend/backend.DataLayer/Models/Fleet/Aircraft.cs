using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;
using System.Threading.Tasks;
using Ace.DataLayer.Interfaces;
using backend.DataLayer.Helpers;
using backend.DataLayer.Helpers.Database;

namespace Ace.DataLayer.Models
{


    [DataProperty(TableName = "dbo.Aircraft")]
    public class Aircraft : ICreatedElement/*, IModifiedElement*/, ICreatedBy, INotDeleteble
    {
        private ICollection<DownloadableElement> _downloadableElements;
        private ICollection<DocumentFolder> _selectedDocumentFolders;

        [DataProperty]
        public virtual DateTimeOffset DateCreated { get; set; }

        [DataProperty]
        public virtual DateTimeOffset DateModified { get; set; }

        [DataProperty]
        public virtual string Password { get; set; }

        [DataProperty]
        public virtual DateTimeOffset LastPasswordChange { get; set; }

        public virtual ICollection<DownloadableElement> DownloadableElements
        {
            get { return _downloadableElements ?? (_downloadableElements = new Collection<DownloadableElement>()); }
            set { _downloadableElements = value; }
        }


        [DataProperty(PrimaryKey = true)]
        public virtual Guid Id { get; set; }

        [DataProperty]
        public bool IsDeleted { get; set; }

        [DataProperty]
        public virtual String TailNumber { get; set; }

        [DataProperty]
        public virtual String SerialNumber { get; set; }

        [DataProperty]
        public virtual String ConnectivityTypes { get; set; }

        [DataProperty]
        public virtual int ContentDiskSpace { get; set; }

        [DataProperty]
        public virtual DateTimeOffset LastManifestCreatedDate { get; set; }

        [DataProperty]
        public virtual string Manufacturer { get; set; }

        [DataProperty]
        public virtual string Model { get; set; }

        [DataProperty]
        public virtual string ModifiedBy { get; set; }

        [DataProperty]
        public virtual Guid OperatorId { get; set; }

        public virtual ICollection<DocumentFolder> SelectedDocumentFolders
        {
            get { return _selectedDocumentFolders ?? (_selectedDocumentFolders = new Collection<DocumentFolder>()); }
            set { _selectedDocumentFolders = value; }
        }

        //public int CreatedByUserId { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        [DataProperty]
        public virtual Guid CreatedByUserId { get; set; }

        public static explicit operator Aircraft(Task<Aircraft> v)
        {
            throw new NotImplementedException();
        }

        int IElement.Id { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        Guid ICreatedBy.CreatedByUserId { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }

        [DataProperty]
        public long SelectedAssetsCount { get; set; }

        [DataProperty]
        public long SelectedAssetsSize { get; set; }

        [DataProperty]
        public Guid InstallationTypeID { get; set; }

        [DataProperty] public Guid ThirdPartyRoleID { get; set; }
       
    }
}
