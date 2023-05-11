using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using backend.BusinessLayer.Contracts;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Services.Azure
{
    /**
     * Simple service that encapsulates and provides access to the Azure blob storage container
     **/ 
    public class AzureBlobService : IAzureBlobService
    {
        private string _connectionString = "DefaultEndpointsProtocol=https;AccountName=rcdevlivestore;AccountKey=i+ja+GgfrAERuJtgedc+o/32A7qr3mei8L3mw1oMCrtKGqg38gu9xVeT9aDKIQdRkJvzkhlNJC45tif9naCBPA==";
        private string _containerName = "release";
        private BlobServiceClient _client;
        private BlobContainerClient _container;

        public AzureBlobService()
        {
            _connectionString = ConfigurationManager.AppSettings.Get("LiveSyncStorageConnectionString");
            _containerName = ConfigurationManager.AppSettings.Get("AzureBlobContainerName");

            _client = new BlobServiceClient(_connectionString);
            _container = _client.GetBlobContainerClient(_containerName);
        }

        /**
         * Queries each item in the given array and returns upon finding the first one that could be opened
         * @param paths [in] Array of paths to try and get
         **/ 
        public async Task<Stream> TryBlobs(string[] paths)
        {
            
            foreach (string path in paths) {
                Stream attempt = await OpenBlobStream(path);
                if (attempt != null) return attempt;
            }
            return null;
        }

        /**
         * Opens a stream to the given blob. Returns null if the blob does not exist
         * @param path [in] Path to the blob
         **/ 
        public async Task<Stream> OpenBlobStream(string path)
        {
            BlobClient blob = _container.GetBlobClient(path);

            var exists = await blob.ExistsAsync();
            if (!exists)
            {
                return null;
            }

            return await blob.OpenReadAsync();
        }

        /**
         * Returns an indication whether a blob at the given path exists
         * @param path [in] Path to the blob to check
         **/ 
        public async Task<Boolean> BlobExists(string path)
        {
            BlobClient blob = _container.GetBlobClient(path);
            return await blob.ExistsAsync();
        }

        public async Task<Stream> OpenBlobStream(string connectionString, string containerName, string blobName)
        {
            var client = new BlobServiceClient(connectionString);
            var container = client.GetBlobContainerClient(containerName);
            var blob = container.GetBlobClient(blobName);
            return await blob.OpenReadAsync();
        }

    }
}
