using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Repository.Contracts
{
    public interface ISimpleRepositoryBase { }

    public interface ISimpleRepository<T> :
        ISimpleRepositoryBase,
        IInsertAsync<T>,
        IUpdateAsync<T>,
        IFilterAsync<T>,
        IFirstAsync<T>,
        IFirstMappedAsync<T>,
        IFilterMappedAsync<T>,
        IFindAllAsync<T>,
        IDeleteAsync<T>,
        IFindByStringDataPropertyAsync<T>,
        IFindByIDAsync<T>


    {

        int Insert(T value);

    }
}
