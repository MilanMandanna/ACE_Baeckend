using backend.DataLayer.Helpers.Database;
using backend.DataLayer.Repository.Contracts;
using backend.DataLayer.Repository.Extensions;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.SqlServer
{
    /**
     * Repository for a single type that provides standard Insert and Update functionality
     **/
    public class SimpleRepository<T> : Repository, ISimpleRepository<T> where T: class
    {
        public SimpleRepository()
        {
        }

        public SimpleRepository(SqlConnection context, SqlTransaction transaction)
        {
            _context = context;
            _transaction = transaction;
        }

        public virtual async Task<List<T>> FindAllAsync()
        {
            return await FindAllAsyncExtension.FindAllAsync(this);
        }

        public virtual async Task<T> FirstAsync(string name, object value)
        {
            return await FirstAsyncExtension.FirstAsync(this, name, value);
        }

        public virtual async Task<List<T>> FilterAsync(string fieldName, object value)
        {
            return await FilterAsyncExtension.FilterAsync(this, fieldName, value);
        }

        public virtual async Task<List<T>> FilterMappedAsync(int configurationId)
        {
            return await FilterMappedAsyncExtension.FilterMappedAsync(this, configurationId);
        }

        public virtual async Task<T> FirstMappedAsync(int configurationId)
        {
            return await FirstMappedAsyncExtension.FirstMappedAsync(this, configurationId);
        }

        public virtual async Task<int> InsertAsync(T value)
        {
            return await InsertAsyncExtension.InsertAsync(this, value);
        }

        public virtual async Task<int> UpdateAsync(T value)
        {
            return await UpdateAsyncExtension.UpdateAsync(this, value);
        }

        public virtual async Task<int> DeleteAsync(T record)
        {
            return await DeleteAsyncExtension.DeleteAsync(this, record);
        }

        public virtual int Insert(T data)
        {
            using (var command = CreateCommand(null))
            {
                DatabaseMapper.Instance.PrepareInsert(data, command);
                return command.ExecuteNonQuery();
            }
        }

        public virtual async Task<T> FindByIdAsync(Guid value)
        {
            return await IFindByAsyncExtension.FindByIdAsync(this, value);
        }

        public virtual async Task<T> FindByStringDataPropertyAsync(string value1, string value2)
        {
            return await FindByStringDataPropertyExtension.FindByStringDataPropertyAsync(this, value1, value2);

        }
    }
}
