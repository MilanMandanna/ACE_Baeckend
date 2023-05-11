namespace backend.DataLayer.UnitOfWork.Contracts
{
    public interface IUnitOfWork
    {
        IUnitOfWorkAdapter Create { get; }
    }
}
