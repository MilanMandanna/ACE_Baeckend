using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;

namespace backend.DataLayer.Repository.SqlServer
{
    public interface IRepository { }

    public abstract class Repository : IRepository
    {
        protected SqlConnection _context;
        protected SqlTransaction _transaction;

        public SqlCommand CreateCommand(string query, System.Data.CommandType commandType = System.Data.CommandType.Text)
        {
            var command = new SqlCommand(query, _context, _transaction);
            command.CommandType = commandType;
            return command;
        }

        public SqlCommand CreateCommand()
        {
            return new SqlCommand(null, _context, _transaction);
        }

        

    }
}
