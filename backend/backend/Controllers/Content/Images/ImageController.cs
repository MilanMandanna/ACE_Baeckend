using backend.BusinessLayer.Contracts;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;


namespace backend.Controllers.Content.Images
{
    /**
     * Controller for providing images for the users and aircraft defined in the system. Customized user and aircraft images are uploaded
     * to Azure blob storage so this API is responsible for retrieving them. No authorization checks are done in this controller.
     **/ 
    [Route("api/[controller]")]
    [ApiController]
    public class ImageController : PortalController
    {
        private IImageService _imageService;

        public ImageController(IImageService imageService)
        {
            _imageService = imageService;
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
        [Route("fleet/{manufacturerName}/{model}/{aircraftId?}")]
        public async Task<IActionResult> GetAircraftCover(string manufacturerName, string model, string aircraftId = "")
        {
            return await _imageService.GetAircraftCover(manufacturerName, model, aircraftId, HttpContext);
        }

        /**
         * Retrieves the default image for a given image type.
         * @param imageType [in]
         **/
        [Route("default/{imageType}")]
        public IActionResult GetDefaultCover(string imageType)
        {
            return _imageService.GetDefaultCover(imageType, HttpContext);
        }

        /**
         * Retrieves the image cover to be used for a user. This queries the configured
         * Azure blob storage for the specific user and if not found then
         * returns the default cover image
         * @param user_id [in] Username to get the cover image for (e.g. "roger.smith", "admin", etc.)
         **/ 
        [Route("users/{userId}")]
        public async Task<IActionResult> GetUserCover(string userId)
        {
            return await _imageService.GetUserCover(userId, HttpContext);
        }

    }
}
