namespace backend.DataLayer.Repository.Contracts.Actions
{
    public interface IRemove<T>
    {
        void Remove(T id);
    }
}
