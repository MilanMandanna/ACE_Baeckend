using backend.BusinessLayer.Authentication;
using backend.BusinessLayer.Authorization;
using backend.BusinessLayer.Authorization.Handlers;
using backend.BusinessLayer.Contracts;
using backend.BusinessLayer.Contracts.Configuration;
using backend.BusinessLayer.Contracts.Content;
using backend.BusinessLayer.Contracts.CustomContent;
using backend.BusinessLayer.Services;
using backend.BusinessLayer.Services.Azure;
using backend.BusinessLayer.Services.Configurations;
using backend.BusinessLayer.Services.Content;
using backend.BusinessLayer.Services.Export;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.DataLayer.UnitOfWork.SqlServer;
using backend.Extensions;
using backend.Helpers;
using backend.Helpers.Runtime;
using backend.Mappers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using NLog;
using System;
using System.IO;

namespace backend
{
    public class Startup
    {
        public Startup(IConfiguration configuration, IWebHostEnvironment env)
        {
            LogManager.LoadConfiguration(String.Concat(Directory.GetCurrentDirectory(), "/nlog.config"));
            var builder = new ConfigurationBuilder()
                .SetBasePath(env.ContentRootPath)
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
                .AddJsonFile($"Config/{env.EnvironmentName}.json", optional: false, reloadOnChange: true)
                .AddEnvironmentVariables();
            configuration = builder.Build();
            Configuration = configuration;

            RuntimeConfiguration.ContentRootPath = env.ContentRootPath;
            RuntimeConfiguration.WebRootPath = env.WebRootPath;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddAuthentication(options => PortalAuthenticationOptions.Configure(options))
                .AddJwtBearer(options => PortalJwtBearerOptions.Configure(options, Configuration.GetSection("Configuration").Get<Configuration>()));

            services.AddAuthorization(options => PortalAuthorizationOptions.Configure(options));

            services.ConfigureLoggingService();
            services.AddControllers();
            services.AddSingleton(Configuration.GetSection("Configuration").Get<Configuration>());
            services.AddTransient<IUnitOfWork, UnitOfWorkSqlServer>();
            services.AddTransient<IUserService, UserService>();
            services.AddTransient<IProductService, ProductService>();
            services.AddTransient<IAircraftService, AircraftService>();
            services.AddTransient<IMsuConfigurationService, MsuConfigurationService>();
            services.AddTransient<IImageService, ImageService>();
            services.AddSingleton<IAzureBlobService, AzureBlobService>();
            services.AddTransient<IOperatorService, OperatorService>();
            services.AddTransient<IDownloadPreferencesService, DownloadPreferencesService>();
            services.AddTransient<ISubscriptionService, SubscriptionService>();
            services.AddTransient<IManageService, ManageService>();
            services.AddTransient<IConfigurationService, ConfigurationService>();
            services.AddTransient<IGlobalConfigurationService, GlobalConfigurationService>();
            services.AddTransient<IMapsConfigurationService, MapsConfigurationService>();
            services.AddTransient<ITriggerConfigurationService, TriggerConfigurationService>();
            services.AddTransient<IModesConfigurationService, ModesConfigurationService>();
            services.AddTransient<ITickerConfigurationService, TickerConfigurationService>();
            services.AddTransient<IExportService, ExportService>();
            services.AddTransient<IImportService, ImportService>();
            services.AddTransient<ITaskService, TaskService>();
            services.AddTransient<IViewsConfigurationService, ViewsConfigurationService>();
            services.AddTransient<IScriptConfigurationService, ScriptConfigurationService>();
            services.AddTransient<ICustomContentService, CustomContentService>();
            services.AddTransient<ICollinsAdminOnlyFeaturesService, CollinsAdminOnlyFeaturesService>();
            services.AddTransient<IAirportService, AirportService>();
            services.AddTransient<ICountryService, CountryService>();
            services.AddTransient<IRegionService, RegionService>();
            services.AddTransient<IBuildService, BuildService>();
            services.AddTransient<IMergeConfigurationService, MergeConfigurationService>();
            services.AddTransient<IMenuService, MenuService>();


            services.AddAutoMapper(typeof(Maps));
            services.AddCors();
            services.AddHttpContextAccessor();

            services.AddSingleton<IAuthorizationHandler, PortalAuthorizationHandler>();
            services.AddSingleton<IAuthorizationHandler, PortalOperatorAuthorizationHandler>();
            services.AddSingleton<IAuthorizationHandler, PortalAircraftAuthorizationHandler>();
            services.AddSingleton<IAuthorizationHandler, PortalConfigurationAuthorizationHandler>();

            services.Configure<FormOptions>(opt =>
            {
                opt.MultipartBodyLengthLimit = Int32.MaxValue;
            });
            services.Configure<IISServerOptions>(options =>
            {
                options.MaxRequestBodySize = Int32.MaxValue; // or your desired value
            });
            services.Configure<KestrelServerOptions>(options =>
            {
                options.Limits.MaxRequestBodySize = Int32.MaxValue; // if don't set default value is: 30 MB
            });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {

            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            app.UseRouting();
            app.UseHsts();
            app.UseHttpsRedirection();
            app.UseCors(option => option.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());

            app.UseAuthentication();
            app.UseAuthorization();
            app.UseMiddleware<PortalAuthorizationMiddleware>();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });

        }
    }
}
