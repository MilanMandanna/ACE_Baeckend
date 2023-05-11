
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace backend.DataLayer.Authentication
{
    /**
     * Class that is used to hold the JWT payload information
     * received from the stage identity server
     **/
    public class PortalJWTPayload
    {
        private List<PortalClaim> _claims;

        [JsonProperty("aud")]
        public string Audience { get; set; }

        public List<PortalClaim> Claims
        {
            get { return _claims ?? (_claims = new List<PortalClaim>()); }
            set { _claims = value; }
        }

        [JsonProperty("jti")]
        public Guid Id { get; set; }

        [JsonProperty("iat")]
        public long IssuedAt { get; set; }

        [JsonProperty("exp")]
        public long ExpiresAt { get; set; }

        [JsonProperty("iss")]
        public string Issuer { get; set; }

        [JsonProperty("unique_name")]
        public string UserName { get; set; }
    }
}
