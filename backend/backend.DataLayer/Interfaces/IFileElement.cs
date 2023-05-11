using Ace.DataLayer.Models.DataStructures;
namespace Ace.DataLayer.Interfaces
{
    public interface IFileElement : INamedElement
    {
        string FileName { get; set; }
        long FileSize { get; set; }
        string FileType { get; }
        FileStorageType FileStorageType { get; set; }
    }
}