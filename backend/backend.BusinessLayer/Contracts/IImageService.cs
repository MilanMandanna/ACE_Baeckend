using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts
{
    public interface IImageService
    {
        public Task<IActionResult> GetAircraftCover(string manufacturerName, string model, string aircraftId = "", HttpContext context = null);

        public IActionResult GetDefaultCover(string imageType, HttpContext context);

        public Task<IActionResult> GetUserCover(string userId, HttpContext context);

        public IActionResult GetDefaultCoverImage(string image_type, string asset_type, HttpContext context);

        public IActionResult GetAircraftCoverImage(string modelName, string assetId, string folderPath, string assetType = "", HttpContext context = null);

        public Task<IActionResult> GetCustomAircraftCover(string tailNumber, HttpContext context = null);

    }
}
