using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Helpers
{
    public class Configuration
    {
        public static Configuration Instance = null;
        public string ConnectionString { get; set; }
        public string WebRootPath { get; set; }
        public string AzureWebJobsStorage { get; set; }
        public string AzureWebJobsQueue { get; set; }
        public string AzureExportBlobStorage { get; set; }
        public string AzureExportBlobStorageContainer { get; set; }

        public string AzureImportBlobStorageContainer { get; set; }
        public string AzureBlobStorageContainerforCustomContents { get; set; }
        public string AzureBlobStorageContainerforHiFocusMapInsets { get; set; }
        public string AzureBlobStorageContainerforImages { get; set; }
        public string AzureBlobStorageContainerforCollinsAdminAssets { get; set; }    
        public string AzureFileUploadPath { get; set; }
        /// <summary>
        /// Used to run the thread in the interval to check the config ids that are queued for locking (in minutes)
        /// </summary>
        public int IntervalTimeForCheckQueuedLockConfig { get; set; }

        /// <summary>
        /// Waiting time for the config before lock/merge, lock merge will initiated only when the config is not updated given time (in hour)
        /// </summary>
        public int ConfigUpdatesWaitingTimeBeforeLock { get; set; }
	    //Authorization Token Configuration items
        public string TokenIssuer { get; set; }
        public string TokenApi { get; set; }
        public string TokenSecret { get; set; }
        public string TokenAudience { get; set; }
        public string TokenValidateLifetime { get; set; }	
        public string LocalTempStorageRoot { get; set; }
        public string AzureBlobStorageContainerforVersionUpdates { get; set; }
        public string AzureBlobURL { get; set; }
    }
}
