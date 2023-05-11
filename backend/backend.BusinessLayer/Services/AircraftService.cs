using Ace.DataLayer.Models;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Helpers.Fleet;
using backend.Helpers.Portal;
using backend.Mappers.DataTransferObjects.Generic;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Threading.Tasks;
using System.Linq;
using backend.DataLayer.Models.DataStructure;
using backend.Mappers.DataTransferObjects.Aircraft;
using backend.DataLayer.Repository.Extensions;
using AutoMapper;
using backend.Mappers.DataTransferObjects.User;
using backend.BusinessLayer.Authorization;
using backend.DataLayer.Models.Roles_Claims;
using backend.Helpers;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.Subscription;
using backend.Mappers.DataTransferObjects.Subscription;
using Microsoft.AspNetCore.Mvc;
using backend.Helpers.Validator;
using System.IO;
using backend.Worker.Services;
using backend.Logging.Contracts;
using Microsoft.AspNetCore.Http;
using backend.Helpers.Azure;
using backend.DataLayer.Models.CustomContent;
namespace backend.BusinessLayer.Services
{
    public class AircraftService : IAircraftService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private ILoggerManager _logger;
        private Helpers.Configuration _configuration;
        static LoggingService _loggingService;


        public AircraftService(IUnitOfWork unitOfWork, IMapper mapper, ILoggerManager logger, Helpers.Configuration configuration)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
            _configuration = configuration;
        }


        public Aircraft FindAircraftByTailNumber(string tailNumber)
        {
            using var context = _unitOfWork.Create;
            return context.Repositories.AircraftRepository.FindByTailNumber(tailNumber);
        }

        public async Task<AircraftDTO> GetAircraftDetails(string tailNumber)
        {
            using var context = _unitOfWork.Create;
            var aircraft = (await context.Repositories.AircraftRepository.FilterAsync("TailNumber", tailNumber)).FirstOrDefault();
            if (aircraft == null) return null;

            var aircraftDetails = _mapper.Map<AircraftDTO>(aircraft);

            var oper = await context.Repositories.OperatorRepository.FindByIdAsync(aircraft.OperatorId);
            Subscription subscription = null;

            var aircraftConfiguration = await context.Repositories.Simple<AircraftConfigurationMapping>().FirstAsync("AircraftID", aircraft.Id);
            if (aircraftConfiguration != null)
            {
                var subscriptionAssignment = await context.Repositories.Simple<AirshowSubscriptionAssignment>().FirstAsync("ConfigurationDefinitionID", aircraftConfiguration.ConfigurationDefinitionID);
                if (subscriptionAssignment != null)
                {
                    subscription = await context.Repositories.Subscriptions.FindByIdAsync(subscriptionAssignment.SubscriptionID);

                }
                if (aircraftConfiguration.ConfigurationDefinitionID != 0)
                {
                    var configurationDefinitionSetting = await context.Repositories.Simple<ConfigurationDefinitionSetting>().FirstAsync("ConfigurationDefinitionID", aircraftConfiguration.ConfigurationDefinitionID);
                    if (configurationDefinitionSetting != null)
                    {
                        aircraftDetails.ConfigurationDefinitionSettings = configurationDefinitionSetting;
                    }
                }
            }

            if (oper != null) aircraftDetails.OperatorName = oper.Name;
            if (subscription != null)
            {
                aircraftDetails.Subscription = _mapper.Map<SubscriptionDTO>(subscription);
            }

            return aircraftDetails;
        }

        /// <summary>
        /// Returns All the aircrafts
        /// </summary>
        /// <returns></returns>
        public async Task<List<Aircraft>> FindAllAircraft()
        {
            List<Aircraft> result = new List<Aircraft>();

            using var context = _unitOfWork.Create;
            var records = await context.Repositories.AircraftRepository.FindAll();
            if (records?.Count() > 0)
            {
                foreach (var record in records)
                {
                    result.Add(record);
                }
            }
            Aircraft test = new Aircraft();
            test.Id = new System.Guid();
            result.Add(test);

            return result;
        }

        public async void Update(Aircraft aircraft)
        {
            using var context = _unitOfWork.Create;
            context.Repositories.AircraftRepository.Update(aircraft);
            await context.SaveChanges();
        }

        public List<ItemWithSelectionDTO> GetAircraftConnectivityTypes(string tailNumber)
        {
            Aircraft aircraft = FindAircraftByTailNumber(tailNumber);
            if (aircraft == null) return null;

            IEnumerable<string> selectedTypes = aircraft.ConnectivityTypes.Split(";").Where(x => !string.IsNullOrWhiteSpace(x));
            TypeCollection connectivityTypes = FleetConfiguration.Instance.AircraftConnectivityTypes;
            List<ItemWithSelectionDTO> result =
                (from KeyValueConfigurationElement element in connectivityTypes
                 select new ItemWithSelectionDTO
                 {
                     Name = element.Key,
                     Title = element.Value
                 }).ToList();

            foreach (var dto in result)
            {
                if (selectedTypes != null && selectedTypes.Contains(dto.Name))
                    dto.IsSelected = SelectionState.Selected;
                else
                    dto.IsSelected = SelectionState.NotSelected;
            }

            return result;
        }

        public SelectionResultDTO SetAircraftConnectivityType(string tailNumber, bool isSelected, string connectionTypeName)
        {
            SelectionResultDTO result = new SelectionResultDTO { IsSelected = SelectionState.NotSelected };
            Aircraft aircraft = FindAircraftByTailNumber(tailNumber);
            if (aircraft == null) return result;

            List<string> availableTypes = (from KeyValueConfigurationElement element in FleetConfiguration.Instance.AircraftConnectivityTypes select element.Key).ToList();
            if (!availableTypes.Contains(connectionTypeName)) return result;

            List<string> enabledTypes = aircraft.ConnectivityTypes?.Split(";").Where(x => !string.IsNullOrWhiteSpace(x)).ToList();
            bool alreadySelected = enabledTypes != null && enabledTypes.Contains(connectionTypeName);

            if (isSelected)
            {
                if (!alreadySelected)
                {

                    if (enabledTypes == null) enabledTypes = new List<string>();
                    enabledTypes.Add(connectionTypeName);
                    aircraft.ConnectivityTypes = string.Join(";", enabledTypes);
                    Update(aircraft);
                }

                result.IsSelected = SelectionState.Selected;
            }

            else
            {
                if (alreadySelected)
                {
                    aircraft.ConnectivityTypes = string.Join(";", enabledTypes.Where(x => x != connectionTypeName));
                    Update(aircraft);

                    // todo: clear download preferences for the selected types
                }

                result.IsSelected = SelectionState.NotSelected;
            }

            return result;
        }

        public Aircraft FindAircraftById(Guid id)
        {
            using var context = _unitOfWork.Create;
            return context.Repositories.AircraftRepository.Find(id.ToString());
        }

        public async Task<DataCreationResultDTO> Update(AircraftListDTO request, UserListDTO currentUser)
        {
            using var context = _unitOfWork.Create;

            if (string.IsNullOrWhiteSpace(request.TailNumber)) return new DataCreationResultDTO { IsError = true, Message = "invalid tail number" };
            if (string.IsNullOrWhiteSpace(request.SerialNumber)) return new DataCreationResultDTO { IsError = true, Message = "invalid serial number" };
            if (!request.OperatorId.Equals(Guid.Empty))
            {
                var oper = await context.Repositories.OperatorRepository.FindByIdAsync(request.OperatorId);
                if (oper == null) return new DataCreationResultDTO { IsError = true, Message = "invalid operator" };
            }

            if (request.Id.Equals(Guid.Empty))
            {
                var aircraft = (await context.Repositories.AircraftRepository.FilterAsync("TailNumber", request.TailNumber)).FirstOrDefault();
                if (aircraft != null) return new DataCreationResultDTO { IsError = true, Message = "aircraft with that tailnumber exists" };

                aircraft = _mapper.Map<Aircraft>(request);
                aircraft.Id = Guid.NewGuid();
                aircraft.ConnectivityTypes = "";
                aircraft.CreatedByUserId = currentUser.Id;
                aircraft.DateCreated = DateTime.Now;
                aircraft.DateModified = DateTime.Now;
                aircraft.IsDeleted = false;
                aircraft.InstallationTypeID = Guid.Parse("23825E21-652E-482E-8AB0-870FD67BA94B");//for now used the standard value from InstallationType Table 
                //need to figure it out and make changes accordingly
                // todo: need to figure out what to set these as these seem important (but not present in the ACE UX)
                //aircraft.InstallationTypeID = Guid.Empty;


                await context.Repositories.AircraftRepository.InsertAsync(aircraft);
                await context.SaveChanges();

                return new DataCreationResultDTO { Id = aircraft.Id };
            }
            else
            {
                var aircraft = (await context.Repositories.AircraftRepository.FilterAsync("TailNumber", request.TailNumber)).FirstOrDefault();
                if (aircraft == null) return new DataCreationResultDTO { IsError = true, Message = "aircraft with that tailnumber does not exist" };

                aircraft = _mapper.Map<Aircraft>(request);
                aircraft.DateModified = DateTime.Now;

                await context.Repositories.AircraftRepository.UpdateAsync(aircraft);
                await context.SaveChanges();

                return new DataCreationResultDTO { Id = aircraft.Id };
            }
        }


        /// <summary>
        /// Returns list of aircrafts associated with the role ID
        /// </summary>
        /// <param name="roleID"></param>
        /// <returns></returns>
        public async Task<List<AircraftListDTO>> GetAircraftsByRoleID(string roleID)
        {
            using var context = _unitOfWork.Create;
            List<AircraftListDTO> aircraftList = new List<AircraftListDTO>();
            var claims = await context.Repositories.UserClaimsRepository.FindByStringDataPropertyAsync("Name", PortalClaimType.ManageAircraft);
            Guid roleid = Guid.Parse(roleID);

            IEnumerable<UserRoleClaimsDetail> result = await context.Repositories.UserRoleClaimsRepository.GetUserRoleClaims(roleid, claims.ID);
            bool bGetAllAircrafts = false;
            if (result.Count() > 0)
            {
                var aircraftIds = new Dictionary<Guid, bool>();
                foreach (UserRoleClaimsDetail userRoleclaim in result)
                {
                    if (userRoleclaim.AircraftID == Guid.Empty)
                    {
                        bGetAllAircrafts = true;
                        break;
                    }
                    else
                    {
                        bool isReadOnly = isAircraftReadOnly(userRoleclaim.Name);
                        aircraftIds.Add(userRoleclaim.AircraftID, isReadOnly);
                    }
                }

                if (bGetAllAircrafts)
                {
                    var aircraft = await context.Repositories.AircraftRepository.FindAll();
                    aircraftList = _mapper.Map<List<Aircraft>, List<AircraftListDTO>>((List<Aircraft>)aircraft);
                    aircraftList.ForEach(c => c.isReadOnly = false);
                }
                else
                {
                    var aircraft = await context.Repositories.AircraftRepository.FindByIds(aircraftIds.Keys.ToArray());
                    aircraftList = _mapper.Map<List<Aircraft>, List<AircraftListDTO>>((List<Aircraft>)aircraft);
                    aircraftList.ForEach(c => c.isReadOnly = aircraftIds.GetValueOrDefault(c.Id, true));
                }
            }
            return aircraftList;
        }

        private bool isAircraftReadOnly(string claimName)
        {
            bool result = true;
            switch (claimName)
            {
                case PortalClaimType.ManageOperator:
                case PortalClaimType.ViewOperator:
                case PortalClaimType.ManageAircraft:
                case PortalClaimType.AdministerAircraft:
                case PortalClaimType.AdministerOperator:
                    result = true;
                    break;
                case PortalClaimType.ManageAccounts:
                    result = false;
                    break;
            }
            return result;
        }


        /// <summary>
        /// Returns list of users having rights to access the aircraft.
        /// </summary>
        /// <param name="aircraftID"></param>
        /// <returns></returns>
        public async Task<IEnumerable<UserListDTO>> GetUsersByAircraftRights(Guid aircraftID)
        {
            using var context = _unitOfWork.Create;
            List<UserListDTO> users = new List<UserListDTO>();
            var manageAircraftClaim = await context.Repositories.UserClaimsRepository.FindByStringDataPropertyAsync("Name", PortalClaimType.ManageAccounts);
            // todo: investigate this, I believe this list is missing a few claim types for where this api is used
            // refer to: https://alm.rockwellcollins.com/wiki/display/ASXIW/Rights+and+Roles
            var viewAircraftClaim = await context.Repositories.UserClaimsRepository.FindByStringDataPropertyAsync("Name", PortalClaimType.ManageAircraft);
            var result = await context.Repositories.UserRepository.GetUsersByObjectType(aircraftID, manageAircraftClaim.ID, viewAircraftClaim.ID, DataLayer.Repository.Contracts.ObjectType.Aircraft);
            if (result.Count() > 0)
            {
                users = RemoveDuplicates.RemoveDuplicateItems(_mapper.Map<List<User>, List<UserListDTO>>(result.ToList()));
            }
            return users;
        }


        /// <summary>
        /// Delets the aircraft
        /// </summary>
        /// <param name="aircraftID"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> DeleteAircraft(Guid aircraftID)
        {
            using var context = _unitOfWork.Create;
            var aircraft = await context.Repositories.AircraftRepository.FindByIdAsync(aircraftID);
            if (aircraft != null)
            {
                //set the flag to true
                aircraft.IsDeleted = true;
                //update the Aircraft table
                int updateResult = await context.Repositories.AircraftRepository.UpdateAsync(aircraft);
                if (updateResult > 0)
                {
                    //save changes if update is successfull
                    await context.SaveChanges();
                    return new DataCreationResultDTO { IsError = false, Message = "Aircraft has been deleted." };
                }
                else
                {
                    return new DataCreationResultDTO { IsError = true, Message = "Delete operation is failed." };
                }
            }
            else
            {
                return new DataCreationResultDTO { IsError = true, Message = "Aircraft not found." };
            }
        }

        public async Task<DataCreationResultDTO> DeactivateSubscription(string tailNumber)
        {
            using var context = _unitOfWork.Create;
            var aircraft = context.Repositories.AircraftRepository.FindByTailNumber(tailNumber);

            var aircraftConfiguration = await context.Repositories.Simple<AircraftConfigurationMapping>().FirstAsync("AircraftID", aircraft.Id);
            if (aircraftConfiguration == null) return new DataCreationResultDTO { IsError = true, Message = "An Airshow Configuration does not yet exist for this aircraft. Please contact an administrator" };

            var configurationDefinition = await context.Repositories.Simple<ConfigurationDefinition>().FirstAsync("ConfigurationDefinitionID", aircraftConfiguration.ConfigurationDefinitionID);
            if (configurationDefinition == null) return new DataCreationResultDTO { IsError = true, Message = "An Airshow Configuration does not yet exist for this aircraft. Please contact an administrator" };

            var assignment = await context.Repositories.Simple<AirshowSubscriptionAssignment>().FirstAsync("ConfigurationDefinitionID", configurationDefinition.ConfigurationDefinitionID);
            if (assignment == null) return new DataCreationResultDTO { IsError = true, Message = "Aircraft does have an active subscription" };

            assignment.IsActive = false;

            await context.Repositories.Simple<AirshowSubscriptionAssignment>().UpdateAsync(assignment);
            await context.SaveChanges();

            return new DataCreationResultDTO { Id = assignment.ID };
        }

        public async Task<DataCreationResultDTO> SelectSubscription(string tailNumber, Guid subscriptionId)
        {
            using var context = _unitOfWork.Create;
            var aircraft = context.Repositories.AircraftRepository.FindByTailNumber(tailNumber);
            if (aircraft == null) return new DataCreationResultDTO { IsError = true, Message = "Aircraft not found." };

            var subscription = await context.Repositories.Subscriptions.FindByIdAsync(subscriptionId);
            if (subscription == null) return new DataCreationResultDTO { IsError = true, Message = "Subscription not found." };

            AirshowSubscriptionAssignment assignment = null;

            var aircraftConfiguration = await context.Repositories.Simple<AircraftConfigurationMapping>().FirstAsync("AircraftID", aircraft.Id);
            if (aircraftConfiguration == null) return new DataCreationResultDTO { IsError = true, Message = "An Airshow Configuration does not yet exist for this aircraft. Please contact an administrator" };

            var configurationDefinition = await context.Repositories.Simple<ConfigurationDefinition>().FirstAsync("ConfigurationDefinitionID", aircraftConfiguration.ConfigurationDefinitionID);
            if (configurationDefinition == null) return new DataCreationResultDTO { IsError = true, Message = "An Airshow Configuration does not yet exist for this aircraft. Please contact an administrator" };

            assignment = await context.Repositories.Simple<AirshowSubscriptionAssignment>().FirstAsync("ConfigurationDefinitionID", configurationDefinition.ConfigurationDefinitionID);
            if (assignment == null)
            {
                assignment = new AirshowSubscriptionAssignment();
                assignment.ID = Guid.NewGuid();
                assignment.ConfigurationDefinitionID = configurationDefinition.ConfigurationDefinitionID;
                assignment.IsActive = true;
                assignment.SubscriptionID = subscription.Id;
                assignment.DateNextSubscriptionCheck = DateTime.Now.AddDays(30);
                await context.Repositories.Simple<AirshowSubscriptionAssignment>().InsertAsync(assignment);
                await context.SaveChanges();

                return new DataCreationResultDTO { Id = assignment.ID };
            }
            else
            {
                assignment.SubscriptionID = subscription.Id;
                assignment.DateNextSubscriptionCheck = DateTime.Now.AddDays(30);
                assignment.IsActive = true;

                await context.Repositories.Simple<AirshowSubscriptionAssignment>().UpdateAsync(assignment);
                await context.SaveChanges();

                return new DataCreationResultDTO { Id = assignment.ID };
            }
        }

        public async Task<Aircraft> GetAircraftByConfigurationId(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var aircrafts = await context.Repositories.AircraftRepository.GetAircraftByConfigurationId(configurationId);
            return aircrafts.Count() > 0 ? aircrafts.First() : null;
        }

        public async Task<Product> GetAircraftsProduct(Guid aircraftID)
        {
            using var context = _unitOfWork.Create;
            var prodcut = await context.Repositories.AircraftRepository.GetAircraftsProduct(aircraftID);
            return prodcut.Count() > 0 ? prodcut.First() : null;
        }

        public async Task<List<BuildDefaultPartnumber>> ConfigurationDefinitionPartNumber(int configurationDefinitionId,int partNumberCollectionId, string tailNumber)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.AircraftRepository.ConfigurationDefinitionPartNumber(configurationDefinitionId, partNumberCollectionId,tailNumber);
        }
        public async Task<List<BuildDefaultPartnumber>> GetDefaultPartNumber( int outputTypeID)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.AircraftRepository.GetDefaultPartNumber(outputTypeID);
        }



        public async Task<DataCreationResultDTO> ConfigurationDefinitionUpdatePartNumber(PartNumber partNumberInfo)
        {
            using var context = _unitOfWork.Create;
            int result = await context.Repositories.AircraftRepository.ConfigurationDefinitionUpdatePartNumber(partNumberInfo);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Partnumber updated successfully" };
            }
            return new DataCreationResultDTO { IsError = true, Message = "Partnumber updation failed" };

        }
    }




}


