using backend.Logging.Contracts;
using backend.Logging.Services;
using Microsoft.Extensions.DependencyInjection;

namespace backend.Extensions
{
    public static class ServiceExtensions
    {
        public static void ConfigureLoggingService(this IServiceCollection services)
        {
            services.AddSingleton<ILoggerManager, LoggerService>();
        }
    }
}
