using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models.Subscription;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Subscription;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.Controllers
{
    /**
     * Controller for managing subscriptions and subscription features
     **/
    [Route("api/[controller]")]
    public class SubscriptionController : PortalController
    {
        private readonly ISubscriptionService _subscriptionService;
        private readonly ILoggerManager _logger;

        public SubscriptionController(ISubscriptionService subscriptionService, ILoggerManager logger)
        {
            _subscriptionService = subscriptionService;
            _logger = logger;
        }

        #region Subscriptions

        [HttpGet]
        [Route("all")]
        [Authorize]
        public async Task<ActionResult<List<Subscription>>> GetAllSubscriptions()
        {
            try
            {
                return Ok(await _subscriptionService.GetAllSubscriptions());
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("active")]
        [Authorize]
        public async Task<ActionResult<List<SubscriptionDTO>>> GetActiveSubscriptions()
        {
            try
            {
                return Ok(await _subscriptionService.GetActiveSubscriptions());
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        

        #endregion

        #region Subscription Features
        [HttpGet]
        [Route("features/all")]
        [Authorize]
        public async Task<ActionResult<List<SubscriptionFeature>>> GetAllSubscriptionFeatures()
        {
            try
            {
                return Ok(await _subscriptionService.GetAllSubscriptionFeatures());
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpGet]
        [Route("features/active")]
        [Authorize]
        public async Task<ActionResult<List<SubscriptionFeature>>> GetAllActiveSubscriptionFeatures()
        {
            try
            {
                return Ok(await _subscriptionService.GetAllActiveSubscriptionFeatures());
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }
        #endregion

       

        [HttpGet]
        [Route("details")]
        [Authorize]
        public async Task<ActionResult<SubscriptionDetailsDTO>> GetSubscriptionDetails(IDRequestDTO request)
        {
            try
            {
                return Ok(await _subscriptionService.GetSubscriptionDetails(request));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }

        [HttpPost]
        [Route("details")]
        [Authorize(Policy = PortalPolicy.ManageSiteSettings)]
        public async Task<ActionResult<DataCreationResultDTO>> UpdateSubscriptionDetails([FromBody] SubscriptionDetailsDTO details)
        {
            try
            {
                return Ok(await _subscriptionService.UpdateSubscriptionDetails(details));
            }
            catch (Exception ex)
            {
                _logger.LogError("Request failed: " + ex);
                return NotFound();
            }
        }
    }
}
