using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Contracts;
using System.Data.SqlClient;

namespace backend.DataLayer.Repository.SqlServer
{
    public class PlatformRepository : SimpleRepository<Platform>, IPlatformRepository
    {
        public PlatformRepository(SqlConnection context, SqlTransaction transaction) : base(context, transaction) { }
    }
}
