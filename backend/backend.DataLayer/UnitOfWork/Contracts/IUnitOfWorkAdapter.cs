using System;
using System.Threading.Tasks;

namespace backend.DataLayer.UnitOfWork.Contracts
{
    public interface IUnitOfWorkAdapter : IDisposable
    {
        IUnitOfWorkRepository Repositories { get; }
        Task SaveChanges();

        void Save();
    }
}
