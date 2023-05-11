using System;
using System.Collections.Generic;
using System.Text;

namespace backend.Helpers.Validator
{
    public class FileUploadType
    {
        public bool ismmobileccPresent;

        public bool ismmcfgPresent;
        public string configPathforWebjob { get; set; }
        public string extractedBuildPath { get; set; }

        //Custom content files
        public CustomComponentFile _ccfile;

        public CustomComponentFile _ccBriefingsConfig;

        public CustomComponentFile _ccHDBriefings;

        public CustomComponentFile _ccBriefingsContent;

        public CustomComponentFile _ccConfigData;

        public CustomComponentFile _ccBuildSupportScripts;

        public CustomComponentFile _cciPadConfigzip;

        public CustomComponentFile _ccModels;

        public CustomComponentFile _ccTextures;

        public CustomComponentFile _ccTicker;

        
    }
}
