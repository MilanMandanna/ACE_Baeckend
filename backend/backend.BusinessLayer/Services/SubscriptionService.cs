using AutoMapper;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models.Subscription;
using backend.DataLayer.UnitOfWork.Contracts;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using backend.DataLayer.Repository.Extensions;
using backend.Mappers.DataTransferObjects.Subscription;
using backend.Mappers.DataTransferObjects.Generic;
using Newtonsoft.Json.Schema;
using Newtonsoft.Json.Linq;
using System.Linq;
using Newtonsoft.Json;

namespace backend.BusinessLayer.Services
{
    public class SubscriptionService : ISubscriptionService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public SubscriptionService(IUnitOfWork unitOfWOrk, IMapper mapper)
        {
            _unitOfWork = unitOfWOrk;
            _mapper = mapper;
        }

        #region Subscriptions

        /**
         * Gets all the subscriptions (including obsolete ones)
         **/
        public async Task<List<Subscription>> GetAllSubscriptions()
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.Simple<Subscription>().FindAllAsync();
        }

        /**
         * Gets all active (not-obsolete) subscriptions
         **/
        public async Task<List<SubscriptionDTO>> GetActiveSubscriptions()
        {
            using var context = _unitOfWork.Create;
            List<Subscription> active = await context.Repositories.Subscriptions.FindObsoleteAsync(false);
            return _mapper.Map<List<SubscriptionDTO>>(active);
        }

        /**
         * Handles creating a new subscription
         **/
        public async Task<DataCreationResultDTO> CreateSubscription(FormCreateSubscriptionDTO formData)
        {
            if (formData == null) return new DataCreationResultDTO { IsError = true, Message = "invalid form data" };
            if (formData.Name == null) return new DataCreationResultDTO { IsError = true, Message = "invalid name" };

            Subscription subscription = new Subscription
            {
                Id = Guid.NewGuid(),
                Name = formData.Name,
                Description = formData.Description,
                DateCreated = DateTime.Now,
                IsObsolete = false
            };

            using var context = _unitOfWork.Create;
            await context.Repositories.Subscriptions.InsertAsync(subscription);
            await context.SaveChanges();


            return new DataCreationResultDTO { Id = subscription.Id };
        }

        /**
         * Handles updating a subscription
         **/
        public async Task<DataCreationResultDTO> UpdateSubscription(FormUpdateSubscriptionDTO formData)
        {
            if (formData == null) return new DataCreationResultDTO { IsError = true, Message = "invalid form data" };

            using var context = _unitOfWork.Create;
            Subscription subscription = await context.Repositories.Subscriptions.FindByIdAsync(formData.Id);
            if (subscription == null) return new DataCreationResultDTO { IsError = true, Message = "subscription not found" };

            _mapper.Map<FormUpdateSubscriptionDTO, Subscription>(formData, subscription);
            await context.Repositories.Subscriptions.UpdateAsync(subscription);
            await context.SaveChanges();

            return new DataCreationResultDTO { Id = subscription.Id };
        }

        #endregion

        #region Subscription Features

        /**
         * Provides a listing of all subscription features including obsolete ones
         **/
        public async Task<List<SubscriptionFeature>> GetAllSubscriptionFeatures()
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.SubscriptionFeatures.FindAllAsync();
        }

        /**
         * Provides a listing of all active subscription features
         **/
        public async Task<List<SubscriptionFeature>> GetAllActiveSubscriptionFeatures()
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.SubscriptionFeatures.FindObsoleteAsync(false);
        }

        #endregion

        #region Feature Assignments

        /**
         * Returns all feature assignments, should really only be used for debugging
         **/
        public async Task<List<SubscriptionFeatureAssignment>> GetAllFeatureAssignments()
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.SubscriptionFeatureAssignments.FindAllAsync();
        }

        /**
         * Provides a listing of all subscription features assigned to a subscription
         **/
        public async Task<List<SubscriptionFeatureAssignmentDTO>> GetSubscriptionFeatures(IDRequestDTO subscriptionId)
        {
            if (subscriptionId == null) return new List<SubscriptionFeatureAssignmentDTO>();

            using var context = _unitOfWork.Create;
            IEnumerable<SubscriptionFeatureAssignment> assignments = await context.Repositories.SubscriptionFeatureAssignments.FindBySubscriptionId(subscriptionId.Id);
            List<SubscriptionFeatureAssignmentDTO> results = _mapper.Map<List<SubscriptionFeatureAssignmentDTO>>(assignments);

            foreach (var result in results)
            {
                SubscriptionFeature feature = await context.Repositories.SubscriptionFeatures.FindByIdAsync(result.SubscriptionFeatureId);
                result.Name = feature.Name;
                result.EditorJSONSchema = feature.EditorJSONSchema;
                result.DefaultJSON = feature.DefaultJSON;
            }

            return results;
        }

       

        /**
         * Handles removing a subscription feature from a subscription
         **/
        public async Task<DataCreationResultDTO> RemoveSubscriptionFeatureAssignment(IDRequestDTO subscriptionFeatureAssignmentId)
        {
            if (subscriptionFeatureAssignmentId.Id.Equals(Guid.Empty)) return new DataCreationResultDTO { IsError = true, Message = "invalid subscription feature" };

            using var context = _unitOfWork.Create;
            SubscriptionFeatureAssignment assignment = await context.Repositories.SubscriptionFeatureAssignments.FindByIdAsync(subscriptionFeatureAssignmentId.Id);
            if (assignment == null) return new DataCreationResultDTO { IsError = true, Message = "invalid assignment" };

            await context.Repositories.SubscriptionFeatureAssignments.DeleteAsync(assignment);
            await context.SaveChanges();

            return new DataCreationResultDTO { Id = assignment.Id };
        }

        #endregion

        #region JSON Validation

        /**
         * Interface through which a json configuration string can be validated against a specific feature
         **/
        public async Task<ValidationResultDTO> ValidateJSON(JSONValidationRequestDTO request)
        {
            if (request == null) return new ValidationResultDTO { IsValid = false, Details = "no data to validate" };
            if (request.JSONData == null) return new ValidationResultDTO { IsValid = false, Details = "no json data provided" };

            using var context = _unitOfWork.Create;
            SubscriptionFeature feature = await context.Repositories.SubscriptionFeatures.FindByIdAsync(request.SubscriptionFeatureId);
            if (feature == null) return new ValidationResultDTO { IsValid = false, Details = "invalid feature" };

            try
            {
                JSchema schema = JSchema.Parse(feature.EditorJSONSchema);
                JToken token = JToken.Parse(request.JSONData);
                bool isValid = token.IsValid(schema, out IList<string> errors);
                string details = string.Join("\n", errors);
                return new ValidationResultDTO { IsValid = isValid, Details = details };
            }
            catch (Exception ex)
            {
                return new ValidationResultDTO { IsValid = false, Details = ex.ToString() };
            }
        }

        #endregion

        /**
         * Builds and retrieves a subscription details object for a subscription. A details object
         * contains all the information about the subscription as well as the features currently associated with the
         * subscription
         **/
        public async Task<SubscriptionDetailsDTO> GetSubscriptionDetails(IDRequestDTO subscriptionId)
        {
            using var context = _unitOfWork.Create;
            Subscription subscription = await context.Repositories.Subscriptions.FindByIdAsync(subscriptionId.Id);
            if (subscription == null) return null;

            SubscriptionDetailsDTO details = _mapper.Map<SubscriptionDetailsDTO>(subscription);
            IEnumerable<SubscriptionFeatureAssignment> features = await context.Repositories.SubscriptionFeatureAssignments.FindBySubscriptionId(subscription.Id);
            details.Features = _mapper.Map<List<SubscriptionFeatureAssignmentDTO>>(features);
            List<SubscriptionFeature> allFeatures = await context.Repositories.SubscriptionFeatures.FindObsoleteAsync(false);

            foreach (var feature in details.Features)
            {
                var definition = allFeatures.Where((x) => x.Id == feature.SubscriptionFeatureId).DefaultIfEmpty(null).FirstOrDefault();
                if (definition == null) continue;

                feature.Name = definition.Name;
                feature.EditorJSONSchema = definition.EditorJSONSchema;
                feature.DefaultJSON = definition.DefaultJSON;
                feature.Description = definition.Description;
            }

            return details;
        }

        /**
         * Method to update a subscription and its set of assigned features. Will validate that the 
         * configuration json provided for the assignment is valid and kick back an error if it is not
         */
        public async Task<DataCreationResultDTO> UpdateSubscriptionDetails(SubscriptionDetailsDTO details)
        {
            if (details == null) return new DataCreationResultDTO { IsError = true, Message = "invalid request" };
            using var context = _unitOfWork.Create;

            foreach (var feature in details.Features)
            {
                SubscriptionFeature internalFeature = await context.Repositories.SubscriptionFeatures.FindByIdAsync(feature.SubscriptionFeatureId);
                if (internalFeature == null) return new DataCreationResultDTO { IsError = true, Message = "feature not found" };

                try
                {
                    JSchema schema = JSchema.Parse(internalFeature.EditorJSONSchema);
                    JToken token = JToken.Parse(feature.ConfigurationJSON);
                    bool isValid = token.IsValid(schema, out IList<string> errors);

                    if (!isValid)
                    {
                        string errorText = string.Join("\n", errors);
                        return new DataCreationResultDTO { IsError = true, Message = "feature json validation failed" + errorText };
                    }
                }
                catch (JsonReaderException ex)
                {
                    return new DataCreationResultDTO { IsError = true, Message = $"{feature.Name} json validation failed: {ex.Message}" };
                }
                catch (Exception ex)
                {
                    return new DataCreationResultDTO { IsError = true, Message = "feature json validation failed:" + ex };
                }
            }

            // new record
            if (details.Id == Guid.Empty)
            {
                // data validation
                if (String.IsNullOrWhiteSpace(details.Name)) return new DataCreationResultDTO { IsError = true, Message = "invalid name" };
                if (String.IsNullOrWhiteSpace(details.Description)) return new DataCreationResultDTO { IsError = true, Message = "invalid description" };

                // create the records and insert them
                Subscription subscription = _mapper.Map<Subscription>(details);
                subscription.Id = Guid.NewGuid();
                subscription.DateCreated = DateTime.Now;
                subscription.IsObsolete = false;
                await context.Repositories.Subscriptions.InsertAsync(subscription);

                foreach (var feature in details.Features)
                {
                    SubscriptionFeatureAssignment assignment = _mapper.Map<SubscriptionFeatureAssignment>(feature);
                    assignment.Id = Guid.NewGuid();
                    assignment.SubscriptionId = subscription.Id;
                    await context.Repositories.SubscriptionFeatureAssignments.InsertAsync(assignment);
                }
                await context.SaveChanges();

                return new DataCreationResultDTO { Id = subscription.Id };
            }
            else
            {
                Subscription subscription = await context.Repositories.Subscriptions.FindByIdAsync(details.Id);
                if (subscription == null) return new DataCreationResultDTO { IsError = true, Message = "invalid subscription" };
                if (String.IsNullOrWhiteSpace(details.Name)) return new DataCreationResultDTO { IsError = true, Message = "invalid name" };
                if (String.IsNullOrWhiteSpace(details.Description)) return new DataCreationResultDTO { IsError = true, Message = "invalid description" };

                _mapper.Map<SubscriptionDetailsDTO, Subscription>(details, subscription);
                await context.Repositories.Subscriptions.UpdateAsync(subscription);

                IEnumerable<SubscriptionFeatureAssignment> assignments = await context.Repositories.SubscriptionFeatureAssignments.FindBySubscriptionId(subscription.Id);

                var toDelete = assignments.Where((x) => details.Features.Where((y) => y.Id == x.Id).Count() == 0).ToList();
                var toUpdate = assignments.Where((x) => toDelete.Contains(x) == false).ToList();
                var toInsert = details.Features.Where((x) => assignments.Where((y) => y.Id == x.Id).Count() == 0).ToList();

                foreach (var assignment in toDelete)
                {
                    await context.Repositories.SubscriptionFeatureAssignments.DeleteAsync(assignment);
                }

                foreach (var update in toUpdate)
                {
                    SubscriptionFeatureAssignmentDTO feature = details.Features.Where((x) => x.Id == update.Id).First();
                    if (feature == null) continue;

                    _mapper.Map<SubscriptionFeatureAssignmentDTO, SubscriptionFeatureAssignment>(feature, update);
                    await context.Repositories.SubscriptionFeatureAssignments.UpdateAsync(update);
                }

                foreach (var insert in toInsert)
                {
                    SubscriptionFeatureAssignment assignment = _mapper.Map<SubscriptionFeatureAssignment>(insert);
                    assignment.Id = Guid.NewGuid();
                    assignment.SubscriptionId = subscription.Id;
                    await context.Repositories.SubscriptionFeatureAssignments.InsertAsync(assignment);
                }

                await context.SaveChanges();

                return new DataCreationResultDTO { Id = subscription.Id };
            }
        }
    }
}
