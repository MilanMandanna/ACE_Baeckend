using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Models;
using backend.DataLayer.Repository.Contracts;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.SqlServer
{
    public class OperatorRepository : SimpleRepository<Operator>, IOperatorRepository
    {
        public OperatorRepository()
        {

        }
        public OperatorRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction)
        {
        }
    }
}
