using backend.DataLayer.Models.Configuration;
using System.Collections.Generic;
using System.Linq;

namespace backend.BusinessLayer.Mappers
{
    public class ViewConfigurationMapper
    {
        #region Flight info
        /// <summary>
        /// 1. Get flight info parameters
        /// 2. Match the info from the XML with the feature set table
        /// 3. If value is available, then map the display name
        /// 4. Return the display names for values available in the XML
        /// </summary>
        /// <param name="parameters"></param>
        /// <returns></returns>
        public List<string> MapFlightInfoParams(Dictionary<FlightInfoParams, List<string>> parameters)
        {
            List<string> flightParameters = new List<string>();
            List<string> flightInfo = new List<string>();

            var name = parameters.Keys.ToList();
            List<string> displayNames = name[0].DisplayName.Split(",").ToList();
            List<string> names = name[0].Name.Split(",").ToList();
            var list = parameters.Values.ToList();
            flightInfo = list[0].ToList();

            for (int i = 0; i < flightInfo.Count; i++)
            {
                for (int j = 0; j < names.Count; j++)
                {
                    if (flightInfo[i].ToString().Trim().ToLower() == names[j].ToString().Trim().ToLower())
                    {
                        flightParameters.Add(displayNames[j].ToString().Trim());
                    }
                }
            }

            return flightParameters;
        }

        /// <summary>
        /// 1. Map flight info parameters
        /// 2. Get flight info parameters names and display names
        /// 3. If display name is available in parameter names, then map display name as return object
        /// </summary>
        /// <param name="flightInfo"></param>
        /// <returns></returns>
        public List<string> MapFlightInfoAvailableParams(Dictionary<string, string> flightInfo)
        {
            List<string> flightParameters = new List<string>();
            List<string> displaNames = new List<string>();
            List<string> names = new List<string>();

            var values = flightInfo.Values.ToList();
            var keys = flightInfo.Keys.ToList();

            displaNames = values[0].Split(",").ToList();
            names = keys[0].Split(",").ToList();

            for (int i = 0; i < names.Count; i++)
            {
                flightParameters.Add(displaNames[i].Trim());
            }

            return flightParameters;
        }
        #endregion
    }
}
