using Microsoft.AspNetCore.Routing;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Helpers
{
    public class HttpHelper
    {
        /**
         * Searches the specified route data for the first instance of one of the parameter names and returns its value
         **/
        public static string FindRouteParameter(RouteData routeData, string[] parameterNames)
        {
            foreach(var key in routeData.Values.Keys)
            {
                foreach(var parameter in parameterNames)
                {
                    if (key == parameter)
                    {
                        return (string) routeData.Values[key];
                    }
                }
            }

            return null;
        }

        public static string FindRouteParameter(RouteData routeData, string parameterName)
        {
            foreach(var key in routeData.Values.Keys)
            {
                if (key == parameterName)
                    return (string)routeData.Values[key];
            }
            return null;
        }
    }
}
