using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models;
using backend.DataLayer.UnitOfWork.Contracts;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading.Tasks;
using backend.DataLayer.Repository.Extensions;

namespace backend.BusinessLayer.Services
{
    public class ProductService : IProductService
    {
        private readonly IUnitOfWork _unitOfWork;

        public ProductService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }
        public async Task<IEnumerable<Product>> FindAllProducts()
        {
            using var context = _unitOfWork.Create;
            var records = await context.Repositories.ProductRepository.FindAllAsync();
            return records;
        }
    }
}
