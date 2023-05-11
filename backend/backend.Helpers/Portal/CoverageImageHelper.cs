using backend.Helpers.Azure;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;

namespace backend.DataLayer.Helpers
{
    public class CoverImageHelper : ImageHelper
    {

        public static IActionResult  GetDefaultCoverImage(string image_type, string asset_type, HttpContext context)
        {
            /*string file;
            string folderPath = AzureFileHelper.GetDefaultImagePath(context);
            string[] files = Directory.GetFiles(folderPath, !string.IsNullOrEmpty(image_type) ? $"default{image_type}.png" : $"default_{asset_type}.png", SearchOption.TopDirectoryOnly);
            if (files.Length > 0)
                file = files[0];
            else return NotFound();

            /*FileStream fileStream = new FileStream(file, FileMode.Open, FileAccess.Read, FileShare.Read);
            HttpResponseMessage result = new HttpResponseMessage(HttpStatusCode.OK) { Content = new StreamContent(fileStream) };
            result.Content = new StreamContent(fileStream);
            result.Content.Headers.ContentType = new MediaTypeHeaderValue("image/jpeg");
            return result;*/
            //return new PhysicalFile()
            return null;
        }

    }
}
