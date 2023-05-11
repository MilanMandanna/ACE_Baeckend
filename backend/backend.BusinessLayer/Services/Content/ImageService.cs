using Ace.DataLayer.Models.DataStructures;
using backend.BusinessLayer.Contracts;
using backend.Helpers.Azure;
using backend.Logging.Contracts;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Services
{
    public class ImageService : IImageService
    {
        private readonly ILoggerManager _logger;
        private readonly IAzureBlobService _azureBlobService;

        public ImageService(IAzureBlobService azureBlobService, ILoggerManager logger)
        {
            _azureBlobService = azureBlobService;
            _logger = logger;
        }

        /**
         * Retrieves the image for a specific aircraft or type of aircraft. If aircraftId is specified,
         * then a custom image for the aircraft is queried from the Azure blob storage. If not found or not specified
         * then the manufacturer and model are used to look up an image in local storage. If those fail then
         * the default aircraft cover image is provided
         * @param manufacturerName [in] Aircraft manufacturer (e.g. Boeing, Airbus)
         * @param model [in] Aircraft Model (e.g. 777, A319)
         * @param aircraftId [in] Tail number of the aircraft (e.g. NR753)
         **/
        public async Task<IActionResult> GetAircraftCover(string manufacturerName, string model, string aircraftId = "", HttpContext context = null)
        {
            // no aircraft, look up the manufacturer/model or default image
            if (string.IsNullOrWhiteSpace(aircraftId))
            {
                string folderPath = AzureFileHelper.GetAircraftLocalImagePath(manufacturerName, context);
                return GetAircraftCoverImage("", model, folderPath, "Aircraft", context);
            }

            // lookup the custom aircraft image or get the manufacturer/model/default
            IActionResult result = await GetCustomAircraftCover(aircraftId, context);
            if (result == null)
            {
                string folderPath = AzureFileHelper.GetAircraftLocalImagePath(manufacturerName, context);
                return GetAircraftCoverImage("", model, folderPath, "Aircraft", context);
            }

            return result;
        }

        /**
         * Retrieves the default image for a given image type.
         * @param imageType [in]
         **/
        public IActionResult GetDefaultCover(string imageType, HttpContext context)
        {
            return GetDefaultCoverImage("", imageType, context);
        }

        /**
         * Retrieves the image cover to be used for a user. This queries the configured
         * Azure blob storage for the specific user and if not found then
         * returns the default cover image
         * @param user_id [in] Username to get the cover image for (e.g. "roger.smith", "admin", etc.)
         **/
        public async Task<IActionResult> GetUserCover(string userId, HttpContext context)
        {
            // the updated Azure API doesn't have a way to check if a folder exists, the quickest way to see if a "folder"
            // exists is to try and get the items we think will be in it.
            string basePath = $"0-{(int)AssetType.PortalUser}-{userId}/images/0-{(int)AssetType.PortalUser}-{userId}";
            Stream blobStream = await _azureBlobService.TryBlobs(new string[] {
                $"{basePath}.png",
                $"{basePath}.jpg",
                $"{basePath}.jpeg"
                });
            if (blobStream != null) return new FileStreamResult(blobStream, "image/jpeg");

            return GetDefaultCoverImage("", "user", context);

        }

        /**
         * Retrieves a file from the local file system that should be used as a default image.
         * @param image_type [in] ?? Remove this ?? It looks like Stage rarely used this parameter
         * @param asset_type [in] such things as "folder", "aircraft" "user"
         * @param context [in] Current HTTP context
         **/
        public IActionResult GetDefaultCoverImage(string image_type, string asset_type, HttpContext context)
        {
            string file;
            string folderPath = AzureFileHelper.GetDefaultImagePath(context);
            string[] files = Directory.GetFiles(folderPath, !string.IsNullOrEmpty(image_type) ? $"default{image_type}.png" : $"default_{asset_type}.png", SearchOption.TopDirectoryOnly);
            if (files.Length > 0)
                file = files[0];
            else
            {
                _logger.LogWarn(String.Format(
                    "No default image found for image type[%s] and asset type[%s]", image_type, asset_type));
                return new NotFoundResult();
            }

            FileStream fileStream = new FileStream(file, FileMode.Open, FileAccess.Read, FileShare.Read);
            return new FileStreamResult(fileStream, "image/jpeg");
        }

        /**
         * Helper function to get an aircraft image based on the manufacturer and model from local storage on the server
         * @param modelName [in] Model of the aircraft
         * @param assetId [in] Asset group, contains the manufacturer
         * @param folderPath [in] Base path to search in
         * @param assetType [in] Asset type to search for (e.g. _Aircraft)
         * @param context [in] Current http context
         **/
        public IActionResult GetAircraftCoverImage(string modelName, string assetId, string folderPath, string assetType = "", HttpContext context = null)
        {
            if (!string.IsNullOrWhiteSpace(assetType))
                assetType = $"_{assetType}";
            string[] files = { };
            if (Directory.Exists(folderPath))
            {
                files = Directory.GetFiles(folderPath, $"{assetId}.*", SearchOption.TopDirectoryOnly);
                if (!files.Any())
                    files = Directory.GetFiles(folderPath, $"{modelName}.*", SearchOption.TopDirectoryOnly);
            }

            if (!Directory.Exists(folderPath) || !files.Any())
            {
                folderPath = AzureFileHelper.GetDefaultImagePath(context);
                files = Directory.GetFiles(folderPath, $"default{assetType}.png", SearchOption.TopDirectoryOnly);
            }
            if (!files.Any()) return null;

            FileStream fileStream = new FileStream(files[0], FileMode.Open, FileAccess.Read, FileShare.Read);
            return new FileStreamResult(fileStream, "image/jpeg");
        }

        /**
         * Helper function to check for a custom aircraft image in Azure. This queries the azure blob storage for the aircraft image
         * based on the tail number
         * @param tailNumber [in] Tail number of the aircraft
         * @param context [in] Current http context servicing a request
         **/
        public async Task<IActionResult> GetCustomAircraftCover(string tailNumber, HttpContext context = null)
        {
            string basePath = $"0-{(int)AssetType.AircraftImage}-{tailNumber}/images/0-{(int)AssetType.AircraftImage}-{tailNumber}";
            Stream blobStream = await _azureBlobService.TryBlobs(new string[]
            {
                $"{basePath}.png",
                $"{basePath}.jpg",
                $"{basePath}.jpeg"
            });

            if (blobStream == null) return null;

            return new FileStreamResult(blobStream, "image/jpeg");
        }
    }
}
