using backend.DataLayer.Models.DownloadPreferences;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts
{
    /**
     * Interface for a repository for accessing data related to aircraft download preferences
     **/ 
    public interface IDownloadPreferenceRepository
    {
        Task<List<DownloadPreference>> GetAll();

        Task<List<DownloadPreferenceAssignment>> GetAircraftDownloadPreferences(string tailNumber);

        Task<DownloadPreference> GetByName(string name);

        Task<DownloadPreferenceAssignment> GetAircraftDownloadPreference(string tailNumber, Guid downloadPreferenceId);

        Task<List<DownloadPreference>> GetDownloadPreferencesOfType(Guid installationTypeID);

        Task<List<String>> getConnectivityTypes(Guid installationTypeID);

        Task Update(DownloadPreferenceAssignment assignment);

        Task Insert(DownloadPreferenceAssignment assignment);
    }
}
