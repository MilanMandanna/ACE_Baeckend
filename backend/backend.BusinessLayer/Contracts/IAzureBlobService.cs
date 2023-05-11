using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts
{
    public interface IAzureBlobService
    {
        public Task<Stream> TryBlobs(string[] paths);

        public Task<Stream> OpenBlobStream(string path);

        public Task<Boolean> BlobExists(string path);

        public Task<Stream> OpenBlobStream(string connectionString, string containerName, string blobName);

    }
}
