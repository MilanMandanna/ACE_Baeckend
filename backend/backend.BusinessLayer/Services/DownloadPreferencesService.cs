using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models.DownloadPreferences;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Mappers.DataTransferObjects.Aircraft;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using System.Linq;
using backend.Mappers.DataTransferObjects.Generic;
using System.Configuration;
using backend.Helpers.Fleet;
using backend.DataLayer.Models.DataStructure;
using backend.Helpers.Portal;
using Ace.DataLayer.Models;

namespace backend.BusinessLayer.Services
{
    /**
     * Class that provides access to the download preferences for an aircraft.
     * Methods are also exposed that allow the download preferences to be updated
     **/
    public class DownloadPreferencesService : IDownloadPreferencesService
    {
        private readonly IUnitOfWork _unitOfWork;

        public DownloadPreferencesService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        /**
         * Gets the full list of download preferences available for an aircraft as well as the selected
         * sync state for each asset type.
         **/
        public async Task<List<DownloadPreferenceAssignmentDTO>> GetAircraftDownloadPreferences(string tailNumber)
        {
            using var context = _unitOfWork.Create;
            var aircraft = context.Repositories.AircraftRepository.FindByTailNumber(tailNumber);
            var result = new List<DownloadPreferenceAssignmentDTO>();
            if (aircraft == null) return result;

            List<DownloadPreference> all = await context.Repositories.DownloadPreferences.GetAll();
            List<DownloadPreferenceAssignment> assignments = await context.Repositories.DownloadPreferences.GetAircraftDownloadPreferences(tailNumber);
            List<string> selectedTypes = aircraft.ConnectivityTypes?.Split(";").Where(x => !string.IsNullOrEmpty(x)).ToList();
            List<KeyValueConfigurationElement> available = (from KeyValueConfigurationElement element in FleetConfiguration.Instance.AircraftConnectivityTypes select element).ToList();

            foreach (var preference in all)
            {
                result.Add(new DownloadPreferenceAssignmentDTO
                {
                    Id = preference.Id,
                    Name = preference.Name,
                    Title = preference.Title,
                    PreferenceList = new List<ItemWithSelectionDTO>()
                });
            }

            if (selectedTypes != null)
            {
                foreach (var assignment in result)
                {
                    foreach (var type in selectedTypes)
                    {
                        ItemWithSelectionDTO subItem = new ItemWithSelectionDTO
                        {
                            Name = type,
                            Title = available.SingleOrDefault(x => x.Key == type)?.Value,
                            IsSelected = SelectionState.NotSelected
                        };

                        var preference = all.Where(x => x.Name == assignment.Name).FirstOrDefault();
                        var assign = assignments.Where(x => x.DownloadPreferenceId == preference?.Id).FirstOrDefault();
                        if (assign != null && assign.PreferenceList.Contains(type))
                        {
                            subItem.IsSelected = SelectionState.Selected;
                        }

                        assignment.PreferenceList.Add(subItem);
                    }
                }
            }

            return result.OrderBy(x => x.Name).ToList();
        }

        /**
         * Returns the full list of global download preferences
         **/
        public async Task<List<DownloadPreference>> GetDownloadPreferences()
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.DownloadPreferences.GetAll();
        }

        /**
        * Returns the list of global download preferences of InstallationType
        **/
        public async Task<List<DownloadPreference>> GetDownloadPreferencesOfType(Guid installationType)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.DownloadPreferences.GetDownloadPreferencesOfType(installationType);
        }


        /**
        * Returns the filtered list of connection types based on the InstallationType
        **/
        public async Task<List<String>> GetConnectivityTypesofInstallation(Guid installationType)
        {
            using var context = _unitOfWork.Create;
            return await context.Repositories.DownloadPreferences.getConnectivityTypes(installationType);
        }

        /**
         * Updates a single download preference for an aircraft.
         **/
        public async Task<SelectionResultDTO> SelectAircraftDownloadPreference(string tailNumber, bool selected, string downloadPreferenceName, string type)
        {
            using var context = _unitOfWork.Create;

            SelectionResultDTO result = new SelectionResultDTO { IsSelected = SelectionState.NotSelected };
            var aircraft = context.Repositories.AircraftRepository.FindByTailNumber(tailNumber);
            if (aircraft == null) return result;

            DownloadPreference preference = await context.Repositories.DownloadPreferences.GetByName(downloadPreferenceName);
            if (preference == null) return result;

            DownloadPreferenceAssignment assignment = await context.Repositories.DownloadPreferences.GetAircraftDownloadPreference(tailNumber, preference.Id);

            if (selected)
            {
                if (assignment != null)
                {
                    if (!assignment.PreferenceList.Contains(type))
                    {
                        assignment.PreferenceList = string.Join(";", assignment.PreferenceList, type).TrimStart(',');
                        await context.Repositories.DownloadPreferences.Update(assignment);
                        await context.SaveChanges();
                    }
                }
                else
                {
                    assignment = new DownloadPreferenceAssignment
                    {
                        AircraftId = aircraft.Id,
                        DownloadPreferenceId = preference.Id,
                        PreferenceList = type
                    };
                    await context.Repositories.DownloadPreferences.Insert(assignment);
                    await context.SaveChanges();
                }

                result.IsSelected = SelectionState.Selected;
            }
            else
            {
                if (assignment != null)
                {
                    if (assignment.PreferenceList.Contains(type))
                    {
                        IEnumerable<string> updatedTypes = assignment.PreferenceList.Split(";").Where(x => x != type);
                        assignment.PreferenceList = string.Join(";", updatedTypes);
                        await context.Repositories.DownloadPreferences.Update(assignment);
                        await context.SaveChanges();
                    }
                }

                result.IsSelected = SelectionState.NotSelected;
            }

            return result;
        }
    }
}
