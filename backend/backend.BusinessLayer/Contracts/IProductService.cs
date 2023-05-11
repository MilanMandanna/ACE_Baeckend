using backend.DataLayer.Models;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;

namespace backend.BusinessLayer.Contracts
{
    public interface IProductService
    {
        Task<IEnumerable<Product>> FindAllProducts();
    }
}
