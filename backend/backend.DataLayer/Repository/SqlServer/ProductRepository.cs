using backend.DataLayer.Models;
using backend.DataLayer.Repository.Contracts;
using System.Data.SqlClient;

namespace backend.DataLayer.Repository.SqlServer
{
    public class ProductRepository : 
        SimpleRepository<Product>,
        IProductRepository
    {
        public ProductRepository(SqlConnection context, SqlTransaction transaction)
            :base(context, transaction)
        {
        }

    }
}
