using backend.DataLayer.Models;
using backend.DataLayer.Repository.Contracts.Actions;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Repository.Contracts
{
    public interface IProductRepository:
        IInsertAsync<Product>,
        IUpdateAsync<Product>,
        IDeleteAsync<Product>,
        IFilterAsync<Product>,
        IFindAllAsync<Product>
    {
    }
}
