using backend.Helpers.Portal;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;

namespace backend.Helpers.Portal
{
    public class PortalConfigurationSection :  ConfigurationSection
    {
        [ConfigurationProperty("fileType")]
        public TypeCollection FileType => this["fileType"] as TypeCollection;

        [ConfigurationProperty("localImageStorage")]
        public ValueConfigurationElement LocalImageStorage => (ValueConfigurationElement)this["localImageStorage"];


        [ConfigurationProperty("localConfigurationImageStorage")]
        public ValueConfigurationElement LocalConfigurationImageStorage => (ValueConfigurationElement)this["localConfigurationImageStorage"];

        [ConfigurationProperty("portalBackgroundServiceEnabled")]
        public ValueConfigurationElement PortalBackgroundServiceEnabled => (ValueConfigurationElement)this["portalBackgroundServiceEnabled"];


        [ConfigurationProperty("portalFEUrl")]
        public ValueConfigurationElement PortalFEUrl => (ValueConfigurationElement)this["portalFEUrl"];


        [ConfigurationProperty("manifestUpdateInterval")]
        public ValueConfigurationElement ManifestUpdateInterval => (ValueConfigurationElement)this["manifestUpdateInterval"];

        [ConfigurationProperty("showHelpPage")]
        public ValueConfigurationElement ShowHelpPage => (ValueConfigurationElement)this["showHelpPage"];

        //[ConfigurationProperty("tokenAudience")]
        //public ValueConfigurationElement TokenAudience => (ValueConfigurationElement)this["tokenAudience"];

        //[ConfigurationProperty("tokenApi")]
        //public ValueConfigurationElement TokenApi => (ValueConfigurationElement)this["tokenApi"];

        //[ConfigurationProperty("tokenIssuer")]
        //public ValueConfigurationElement TokenIssuer => (ValueConfigurationElement)this["tokenIssuer"];

        //[ConfigurationProperty("tokenExpirationMinutes")]
        //public ValueConfigurationElement TokenExpirationMinutes => (ValueConfigurationElement)this["tokenExpirationMinutes"];

        //[ConfigurationProperty("tokenValidateLifetime")]
        //public ValueConfigurationElement TokenValidateLifetime => (ValueConfigurationElement)this["tokenValidateLifetime"];

        [ConfigurationProperty("systemTokenExpirationMinutes")]
        public ValueConfigurationElement SystemTokenExpirationMinutes => (ValueConfigurationElement)this["systemTokenExpirationMinutes"];

        //[ConfigurationProperty("tokenSecret")]
        //public ValueConfigurationElement TokenSecret => (ValueConfigurationElement)this["tokenSecret"];

        [ConfigurationProperty("minUserPassLenght")]
        public ValueConfigurationElement MinUserPassLenght => (ValueConfigurationElement)this["minUserPassLenght"];

        [ConfigurationProperty("maxUserPassLenght")]
        public ValueConfigurationElement MaxUserPassLenght => (ValueConfigurationElement)this["maxUserPassLenght"];

        [ConfigurationProperty("publish")]
        public ValueConfigurationElement PublishContainerName => (ValueConfigurationElement)this["publish"];
        [ConfigurationProperty("cmspublish")]
        public ValueConfigurationElement CmsPublishContainerName => (ValueConfigurationElement)this["cmspublish"];

        [ConfigurationProperty("resetTokenExpirationTimeHours")]
        public ValueConfigurationElement ResetTokenExpirationTimeHours => (ValueConfigurationElement)this["resetTokenExpirationTimeHours"];

        [ConfigurationProperty("expirationManageTriggerTime")]
        public ValueConfigurationElement ExpirationManageTriggerTime => (ValueConfigurationElement)this["expirationManageTriggerTime"];


        [ConfigurationProperty("logEventExpirationDays")]
        public ValueConfigurationElement LogEventExpirationDays => (ValueConfigurationElement)this["logEventExpirationDays"];

    }
}
