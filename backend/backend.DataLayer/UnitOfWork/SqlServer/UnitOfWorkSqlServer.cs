using backend.DataLayer.UnitOfWork.Contracts;
using backend.Helpers;
using System;

namespace backend.DataLayer.UnitOfWork.SqlServer
{
    public class UnitOfWorkSqlServer : IUnitOfWork
    {
        private readonly Configuration _configuration;

        public UnitOfWorkSqlServer(Configuration configuration = null)
        {
            _configuration = configuration;
        }
        public IUnitOfWorkAdapter Create
        {
            get
            {
                var connectionString = _configuration.ConnectionString;
                return new UnitOfWorkSqlServerAdapter(connectionString);
            }
        }
    }
}
