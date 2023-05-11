using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using Ace.DataLayer.Models.DataStructures;
using Ace.DataLayer.Interfaces;

namespace Ace.DataLayer.Models
{
    public class DocumentFolder :
        ICreatedElement,
        INamedElement, 
        ITitleElement,
        IModifiedElement, 
        ISelectable, 
        ICreatedBy,
        IParentFolder,
        IAssetType, INamed
    {
        private ICollection<Aircraft> _aircrafts;
        private ICollection<DocumentFile> _documentFiles;
        private ICollection<DocumentFolder> _childDocumentFolders;

        public virtual ICollection<Aircraft> Aircrafts
        {
            get { return _aircrafts ?? (_aircrafts = new Collection<Aircraft>()); }
            set { _aircrafts = value; }
        }

        public AssetType AssetType => AssetType.DocumentFolder;
      //  public virtual PortalUser CreatedByUser { get; set; }

        public virtual Guid CreatedByUserId { get; set; }

        public virtual DateTimeOffset DateCreated { get; set; }
        public virtual string ModifiedBy { get; set; }
        public virtual DateTimeOffset? DateModified { get; set; }

        public virtual ICollection<DocumentFile> DocumentFiles
        {
            get { return _documentFiles ?? (_documentFiles = new Collection<DocumentFile>()); }
            set { _documentFiles = value; }
        }

        public virtual Guid Id { get; set; }

        public virtual string Name { get; set; }

      //  public virtual Operator Operator { get; set; }
        //public virtual string PinCode { get; set; }

        public virtual Guid OperatorId { get; set; }
        public virtual string Title { get; set; }
        public virtual string CoverImage { get; set; }

        public virtual DocumentFolder ParentFolder { get; set; }
        public virtual Guid? ParentFolderId { get; set; }

        public virtual ICollection<DocumentFolder> ChildDocumentFolders
        {
            get { return _childDocumentFolders ?? (_childDocumentFolders = new Collection<DocumentFolder>()); }
            set { _childDocumentFolders = value; }
        }

        int IElement.Id { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        Guid IParentFolder.ParentFolderId { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
    }
}