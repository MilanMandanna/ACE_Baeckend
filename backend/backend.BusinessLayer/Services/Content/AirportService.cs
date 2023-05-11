using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using backend.BusinessLayer.Contracts.CustomContent;
using backend.DataLayer.Models;
using backend.DataLayer.Models.Build;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Models.CustomContent;
using backend.DataLayer.Models.Task;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Generic;

namespace backend.BusinessLayer.Services.Content
{
    public class AirportService : IAirportService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private ILoggerManager _logger;
        public AirportService(IUnitOfWork unitOfWork, IMapper mapper, ILoggerManager logger)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
        }

        public async Task<IEnumerable<Airport>> getAllAirports(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var airports = await context.Repositories.AirportInfo.GetAllAirports(configurationId);
            return airports;

        }

        public async Task<DataCreationResultDTO> AddAirport(int configurationId, Airport airportInfo)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.AirportInfo.AddAirport(configurationId, airportInfo);
            if (result.Item1 > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = result.Item2 };
            }
            return new DataCreationResultDTO { IsError = true, Message = result.Item2 };
        }

        public async Task<DataCreationResultDTO> UpdateAirport(int configurationId, Airport airportInfo ,Guid userId)
        {
            using var context = _unitOfWork.Create;
            ListModlistInfo listModlistInfo = new ListModlistInfo();
            listModlistInfo.ModlistInfoArray = new List<ModlistInfo>();
            List<string> resolutions = new List<string>();
            Helpers.ModListHelper modListHelper = new Helpers.ModListHelper();
            Helpers.ModListData _modlistdata = new Helpers.ModListData();
            string landSatValue = await context.Repositories.AirportInfo.getlandsatvalue(configurationId);
            var data = await context.Repositories.ConfigurationRepository.GetFeature(configurationId, "Modlist-resolutions");
            resolutions = data.Value.Split(",").ToList();
            if (!string.IsNullOrWhiteSpace(landSatValue) && resolutions.Count > 0)
            {
                resolutions.ForEach(resolution =>
                {
                    ModlistInfo modlist = new ModlistInfo();
                    _modlistdata = modListHelper.ModlistCalculator(Convert.ToSingle(airportInfo.Lat), decimal.ToInt32(airportInfo.Lon), double.Parse(resolution), landSatValue);
                    modlist.Row = _modlistdata.Row;
                    modlist.Column = _modlistdata.Column;
                    modlist.Resolution = _modlistdata.Resolution;
                    listModlistInfo.ModlistInfoArray.Add(modlist);
                });
            }
            listModlistInfo.AirportInfoID = airportInfo.AirportInfoID;
            listModlistInfo.CityName = airportInfo.CityName;
            listModlistInfo.Country = airportInfo.Country;
            listModlistInfo.FourLetID = airportInfo.FourLetID;
            listModlistInfo.GeoRefID = airportInfo.GeoRefID;
            listModlistInfo.Lat = airportInfo.Lat;
            listModlistInfo.Lon = airportInfo.Lon;
            listModlistInfo.ThreeLetID = airportInfo.ThreeLetID;
            
            var result = await context.Repositories.AirportInfo.UpdateAirport(configurationId, listModlistInfo);
            if(result.Item1 > 0)
            {
                await context.SaveChanges();
                var definition = await context.Repositories.Simple<Configuration>().FirstAsync("ConfigurationID", configurationId);
                var taskType = await context.Repositories.Simple<TaskType>().FirstAsync("Name", "Build Modlist Json");


                if (definition == null)
                {
                    return new DataCreationResultDTO { IsError = false, Message = result.Item2 };

                }

                BuildQueueItem queue = new BuildQueueItem
                {
                    Debug = false,
                    Config = new BuildTask()
                };
                queue.Config.ID = Guid.NewGuid();
                queue.Config.ConfigurationID = configurationId;
                queue.Config.ConfigurationDefinitionID = definition.ConfigurationDefinitionId;
                queue.Config.TaskTypeID = taskType.ID;
                queue.Config.TaskStatusID = (int)DataLayer.Models.Task.TaskStatus.NotStarted;
                queue.Config.DateStarted = DateTime.Now;
                queue.Config.DateLastUpdated = DateTime.Now;
                queue.Config.PercentageComplete = 0f;
                queue.Config.StartedByUserID = userId;

                await context.Repositories.Simple<BuildTask>().InsertAsync(queue.Config);
                return new DataCreationResultDTO { IsError = false, Message = result.Item2 };
            }
            return new DataCreationResultDTO { IsError = true, Message = result.Item2 };

        }

        public async Task<IEnumerable<CityInfo>> GetAllCities(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var cities = await context.Repositories.AirportInfo.getAllCities(configurationId);
            return cities;

        }
    }
}
