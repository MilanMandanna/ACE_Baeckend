using System.Collections.Generic;
using System.Threading.Tasks;

namespace backend.DataLayer.Repository.Contracts.Actions
{
    public interface IRead<T, X> where T : class
    {
        Task<IEnumerable<T>> FindAll();
        T Find(X id);
    }
}
