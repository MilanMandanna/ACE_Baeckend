using System;
using System.Collections.Generic;
using System.Text;

namespace backend.DataLayer.Repository.Contracts.Actions
{
    public interface ICreate<T> where T : class
    {
        void Create(T t);
    }
}
