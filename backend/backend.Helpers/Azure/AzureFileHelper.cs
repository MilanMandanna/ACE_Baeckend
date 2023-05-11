using Azure.Storage;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Queues;
using Azure.Storage.Sas;
using backend.Helpers.Portal;
using backend.Helpers.Runtime;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Threading.Tasks;

namespace backend.Helpers.Azure
{
    public class AzureFileHelper
    {
        private static string GetPublishContainer()
        {
            if (PortalConfiguration.Instance != null) return PortalConfiguration.Instance.PublishContainerName.Value;
            return null;
        }
        public static string GetDefaultImagePath()
        {
            string folderpath = Path.Combine(PortalConfiguration.Instance.LocalConfigurationImageStorage.Value, "Default");
            folderpath = Path.Combine(RuntimeConfiguration.ContentRootPath, folderpath.TrimStart('\\'));
            return folderpath;
        }

        public static string GetAircraftLocalImagePath(string manufacturerName)
        {
            string folderpath = Path.Combine(PortalConfiguration.Instance.LocalConfigurationImageStorage.Value, "Fleet", manufacturerName);
            folderpath = Path.Combine(RuntimeConfiguration.ContentRootPath, folderpath.TrimStart('\\'));
            return folderpath;
        }

        public static string GetAircraftLocalImagePath(string manufacturerName, HttpContext context)
        {
            if (context == null || context.Request == null) return "";
            string folderpath = Path.Combine(PortalConfiguration.Instance.LocalConfigurationImageStorage.Value, "Fleet", manufacturerName);
            folderpath = Path.Combine(RuntimeConfiguration.WebRootPath, folderpath.TrimStart('\\'));
            return folderpath;
        }

        public static string GetDefaultImagePath(HttpContext context) {
            if (context == null || context.Request == null) return GetDefaultImagePath();
            string folderpath = Path.Combine(PortalConfiguration.Instance.LocalConfigurationImageStorage.Value, "Default");
            folderpath = Path.Combine(RuntimeConfiguration.WebRootPath, folderpath.TrimStart('\\'));
            return folderpath;
        }

        public static async Task UploadBlob(string connectionString, string containerName, string blobName, string localFile)
        {
            try
            {
                BlobServiceClient blobServiceClient = new BlobServiceClient(connectionString);
                BlobContainerClient containerClient = blobServiceClient.GetBlobContainerClient(containerName);
                containerClient.CreateIfNotExists();
                BlobClient blobClient = containerClient.GetBlobClient(blobName);
                await blobClient.UploadAsync(localFile, true);
            }
            catch(Exception ex)
            {
                throw ex;
            }
        }
        public static async Task UploadBuildinBlob(string connectionString, string containerName,  IFormFile file)
        {
            var containerClient = new BlobContainerClient(connectionString, containerName);
            var blockClient = containerClient.GetBlobClient(file.FileName);
             await blockClient.UploadAsync(file.OpenReadStream());
                File.Delete(file.FileName);
        }

        public static async Task<Uri> UploadFileBlobToPath(string connectionString, string containerName, byte[] file, string fileName, string filePath)
        {
            var containerClient = new BlobContainerClient(connectionString, containerName);
            var blockClient = containerClient.GetBlobClient(filePath + '/' + fileName);
            Stream stream = new MemoryStream(file);
            BlobSasBuilder sasBuilder = new BlobSasBuilder()
            {
                BlobContainerName = containerClient.Name,
                ExpiresOn = DateTimeOffset.MaxValue,
                Resource = "c"
            };
            sasBuilder.SetPermissions(BlobContainerSasPermissions.All);
            await blockClient.UploadAsync(stream);
            var sqsURI = blockClient.GenerateSasUri(sasBuilder);
            return sqsURI;
        }

        public static async Task<Stream> DownloadFileBlobToPath(string connectionString, string containerName,string filePath)
        {
            var containerClient = new BlobContainerClient(connectionString, containerName);
            var blockClient = containerClient.GetBlobClient(filePath);

            return await blockClient.OpenReadAsync();
        }

        public static async Task DownloadFromBlob(string connectionString, string containerName, string pathOut, string blobName)
        {
            try
            {
                BlobServiceClient blobServiceClient = new BlobServiceClient(connectionString);
                BlobContainerClient containerClient = blobServiceClient.GetBlobContainerClient(containerName);
                BlobClient blobClient = containerClient.GetBlobClient(blobName);
                using (FileStream file = File.OpenWrite(pathOut))
                {
                    await blobClient.DownloadToAsync(file);
                }
            }catch(Exception ex)
            {
                throw ex;
            }
        }
        public static async Task WriteToQueue(string connectionString, string queueName, string message)
        {
            var options = new QueueClientOptions();
            //options.MessageEncoding = QueueMessageEncoding.None;
            QueueClient queueClient = new QueueClient(connectionString, queueName, options);
            await queueClient.CreateIfNotExistsAsync();

            if (queueClient.Exists())
            {
                await queueClient.SendMessageAsync(message);
            }
        }
        public static string  getFilePath(string connectionString, string containerName, string blobName, string localFile)
        {
            BlobServiceClient blobServiceClient = new BlobServiceClient(connectionString);
            BlobContainerClient containerClient = blobServiceClient.GetBlobContainerClient(containerName);
            BlobClient blobClient = containerClient.GetBlobClient(blobName);
            string filPath = blobClient.Uri.ToString();
            return filPath;

        }

        public async static Task<bool> RemoveFile(string connectionString, string containerName, string filePath)
        {
            try
            {
                BlobServiceClient blobServiceClient = new BlobServiceClient(connectionString);
                var blobContainer = blobServiceClient.GetBlobContainerClient(containerName);
                var blobClient = blobContainer.GetBlobClient(filePath);
                //you can check if the container exists or not, then determine to delete 
                //if the file it self is not present there is no point of deleting, this scenerio occurs when 
                //we are depoying the data in multiple envrionments. we loose the track of the files as the storage 
                //accounts are different from DEV to Production. To avoid this scenerio we are making sure that container has file or not
                if (!blobClient.Exists()) return true;
                //DeleteSnapshotsOption test = DeleteSnapshotsOption.IncludeSnapshots;
                return await blobClient.DeleteIfExistsAsync(DeleteSnapshotsOption.IncludeSnapshots);
            }
            catch (Exception ex)
            {
                return false;
            }
        }
		
        public async static Task<Stream> OpenBlobStream(string connectionString, string containerName, string blobName)
        {
            var client = new BlobServiceClient(connectionString);
            var container = client.GetBlobContainerClient(containerName);
            var blob = container.GetBlobClient(blobName);
            return await blob.OpenReadAsync();
        }		

        /// <summary>
        /// 1. Method to upload data to azure storage container.
        /// 2. If any errors are there then the URL will be updated with true.
        /// 3. If no errors are there then the URL will be updated in the database.
        /// </summary>
        /// <param name="connectionString"></param>
        /// <param name="containerName"></param>
        /// <param name="file"></param>
        /// <param name="fileName"></param>
        /// <param name="filePath"></param>
        /// <returns></returns>
        public async static Task<List<KeyValuePair<string, string>>> UploadFiles(string connectionString, string containerName, byte[] file, string fileName, string filePath)
        {
            string errorMessage = string.Empty;
            string url;
            try
            {
                var blobClientOptions = new BlobClientOptions()
                {
                    Retry = { MaxRetries = 0, NetworkTimeout = TimeSpan.FromHours(5) }
                };
                var containerClient = new BlobContainerClient(connectionString, containerName, blobClientOptions);

                var blobClient = containerClient.GetBlobClient(filePath + fileName);
                Stream stream = new MemoryStream(file);
                BlobSasBuilder sasBuilder = new BlobSasBuilder()
                {
                    BlobContainerName = containerClient.Name,
                    ExpiresOn = DateTimeOffset.MaxValue,
                    Resource = "c"
                };
                sasBuilder.SetPermissions(BlobContainerSasPermissions.All);
                await blobClient.UploadAsync(stream, overwrite: true);
                var sqsURI = blobClient.GenerateSasUri(sasBuilder);
                url = sqsURI.AbsoluteUri.ToString();
            }
            catch (Exception ex)
            {
                url = "error";
                errorMessage = ex.Message;
            }
            return new List<KeyValuePair<string, string>>()
            { 
                KeyValuePair.Create(url, errorMessage)
            };
        }

        public async static Task<string> GetSASURL(string fileName, string fileDetails, string containerName, string connectionString)
        {
            string url = string.Empty;
            try
            {
                var containerClient = new BlobContainerClient(connectionString, containerName);
                var blobClient = containerClient.GetBlobClient(fileDetails);
                BlobSasBuilder sasBuilder = new BlobSasBuilder()
                {
                    BlobContainerName = containerClient.Name,
                    ExpiresOn = DateTimeOffset.MaxValue,
                    Resource = "c"
                };
                sasBuilder.SetPermissions(BlobContainerSasPermissions.All);
                var sqsURI = blobClient.GenerateSasUri(sasBuilder);
                url = sqsURI.AbsoluteUri.ToString();
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return url;
        }

        public static string getBlobNameFromURL(string url)
        {
            string blobName;
            try
            {
                BlobUriBuilder blobUriBuilder = new BlobUriBuilder(new Uri(url));
                blobName = blobUriBuilder.BlobName;
            }
            catch (Exception ex)
            {
                throw ex;
            }
            return blobName;
        }
        public static bool BlobExists(string connectionString, string containerName, string blobName)
        {
            bool exists = false;
            try
            {
                var containerClient = new BlobContainerClient(connectionString, containerName);
                var blobClient = containerClient.GetBlobClient(blobName);
                if(blobClient.Exists())
                {
                    exists = true;
                }
            }
            catch (Exception ex)
            {
                throw ex;
               
            }
            return exists;
            
        }
    }
}
