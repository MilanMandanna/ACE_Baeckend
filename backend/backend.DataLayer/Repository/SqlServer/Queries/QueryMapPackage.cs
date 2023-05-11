using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Repository.SqlServer.Queries
{
    public class QueryMapPackage
    {
        public static string SQL_GetAllCities= @"SELECT dbo.tblASXiInset.* " +
            "FROM tblASXiInset INNER JOIN tblASXiInsetMap ON tblASXiInset.ASXiInsetID = tblASXiInsetMap.ASXiInsetID " +
            "WHERE tblASXiInsetMap.ConfigurationID = @configurationId ";
    }
}
