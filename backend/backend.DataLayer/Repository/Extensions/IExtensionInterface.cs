using backend.DataLayer.Repository.Contracts.Actions;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;

namespace backend.DataLayer.Repository.Extensions
{
    /**
     * Defines base interface that extension methods can inherit from to get access to the database
     **/
    public interface IExtensionInterface
    {
        SqlCommand CreateCommand(string query, System.Data.CommandType commandType = System.Data.CommandType.Text);
    }
}
