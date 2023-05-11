using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Repository.Contracts.Actions
{
    public interface IUpdate<T> where T : class
    {
        void Update(T t);
    }
}
