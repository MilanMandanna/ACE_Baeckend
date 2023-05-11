using backend.DataLayer.Models.DownloadPreferences;
using backend.Mappers.DataTransferObjects.Aircraft;
using backend.Mappers.DataTransferObjects.Generic;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts
{
    /**
     * Interface for a service to manipulate aircraft download preferences
     **/ 
    public interface IDownloadPreferencesService
    {

        Task<List<DownloadPreference>> GetDownloadPreferences();

        Task<List<DownloadPreferenceAssignmentDTO>> GetAircraftDownloadPreferences(string tailNumber);

        Task<SelectionResultDTO> SelectAircraftDownloadPreference(string tailNumber, bool selected, string downloadPreferenceName, string type);

        Task<List<String>> GetConnectivityTypesofInstallation(Guid installationType);

        Task<List<DownloadPreference>> GetDownloadPreferencesOfType(Guid installationType);

    }
}
