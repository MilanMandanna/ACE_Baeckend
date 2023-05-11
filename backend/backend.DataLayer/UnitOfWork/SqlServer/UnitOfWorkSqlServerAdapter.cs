using backend.DataLayer.UnitOfWork.Contracts;
using System.Data.SqlClient;
using System.Threading.Tasks;

namespace backend.DataLayer.UnitOfWork.SqlServer
{
    public class UnitOfWorkSqlServerAdapter : IUnitOfWorkAdapter
    {
        private SqlConnection _context { get; set; }
        private SqlTransaction _transaction { get; set; }
        public IUnitOfWorkRepository Repositories { get; set; }
        public UnitOfWorkSqlServerAdapter(string connectionString)
        {
            _context = new SqlConnection(connectionString);
            _context.Open();

            _transaction = _context.BeginTransaction();
            Repositories = new UnitOfWorkSqlServerRepositories(_context, _transaction);
        }

        public async Task SaveChanges()
        {
            await _transaction.CommitAsync();
        }

        public void Save()
        {
            _transaction.Commit();
        }

        public void Dispose()
        {
            if (_transaction != null)
            {
                _transaction.Dispose();
            }
            if (_context != null)
            {
                _context.Close();
                _context.Dispose();
            }
            Repositories = null;
        }
    }
}
