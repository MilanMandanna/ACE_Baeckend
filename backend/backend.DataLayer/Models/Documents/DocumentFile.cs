using System;
using Ace.DataLayer.Interfaces;
using Ace.DataLayer.Models.DataStructures;

namespace Ace.DataLayer.Models
{
    public class DocumentFile : ICreatedElement,
                                INamedElement,
                                IModifiedElement, IFileElement, ICreatedBy, IAssetType
    {
        public AssetType AssetType => AssetType.Document;
    //    public virtual PortalUser CreatedByUser { get; set; }
        public virtual Guid CreatedByUserId { get; set; }
        public virtual DateTimeOffset DateCreated { get; set; }
        public virtual string ModifiedBy { get; set; }
        public virtual DateTimeOffset? DateModified { get; set; }
        public virtual DocumentFolder DocumentFolder { get; set; }
        public virtual Guid DocumentFolderId { get; set; }
        public string FileName { get; set; }
        public virtual long FileSize { get; set; }
        public string FileType { get; }
        public FileStorageType FileStorageType { get; set; }
        public virtual Guid Id { get; set; }
        public virtual string Name { get; set; }
        public virtual string Type { get; set; }
        int IElement.Id { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
    }
}