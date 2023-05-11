using AutoMapper;
using backend.BusinessLayer.Contracts;
using backend.DataLayer.Models.Roles_Claims;
using backend.DataLayer.Repository.Extensions;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Mappers.DataTransferObjects.Generic;
using backend.Mappers.DataTransferObjects.Manage;
using backend.Mappers.DataTransferObjects.User;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Linq;
using backend.DataLayer.Models;

namespace backend.BusinessLayer.Services
{
    public class MenuService : IMenuService

    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        public MenuService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<List<UserMenu>> GetMenusByUserId(Guid userId)
        {
            using var context = _unitOfWork.Create;
            List<UserMenu> menus = await context.Repositories.MenuRepository.GetMenusByUserId(userId);
            return menus;
        }

    }
}

