using backend.DataLayer.Models.Build;
using backend.Worker.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Threading.Tasks;

namespace backend.worker
{
    class Program
    {
        public static IConfiguration Configuration;

        /**
         * Configures the webjob host. Logging for the main application is just to the console, each individual
         * webjob task will get its own logger that will write to console and file
         */
        static async Task<int> Main(params string[] args)
        {
            var builder = Host.CreateDefaultBuilder(args);

            builder.ConfigureLogging((context, b) =>
            {
                b.AddConsole();
            });

            builder.ConfigureAppConfiguration((context, b) =>
            {
                String name = context.HostingEnvironment.EnvironmentName;
                b.AddJsonFile($"Config/{name}.json", optional: false, reloadOnChange: true);
                b.AddEnvironmentVariables();

                var configBuilder = new ConfigurationBuilder();
                configBuilder.AddJsonFile($"Config/{name}.json", optional: false, reloadOnChange: true);
                Program.Configuration = configBuilder.Build();
            });

            builder.ConfigureWebJobs(b =>
            {
                b.AddAzureStorageCoreServices();
                b.AddAzureStorage();
            });

            var host = builder.Build();
            using (host)
            {
               //await DebugJob();

               await host.RunAsync();
            }

            return 0;
        }

        static async Task DebugJob()
        {
            BuildQueueItem item = new BuildQueueItem();
            item.Debug = true;
            item.Config = new BuildTask();

            item.Config.ConfigurationDefinitionID = 1;
            item.Config.ConfigurationID = 112;
            item.Config.AircraftID = Guid.Empty;
            item.Config.AzureBuildID = 0;
            item.Config.ID = Guid.Parse("338AA271-B5C0-4602-A75C-B16CD4EE91D8");
            item.Config.TaskStatusID = 1; // not-started
                                          //item.Config.TaskTypeID = Guid.Parse("ED0D1E4E-CB7F-4356-B366-33FE4FB50129"); // export product database - thales
                                          //item.Config.TaskTypeID = Guid.Parse("D693AD3A-4575-464D-AC5F-353A0DB02146"); // export product database - pac3d
                                          //item.Config.TaskTypeID = Guid.Parse("0D67043D-E490-448E-AEB6-399CBE2F51B6"); // export product database - as4xxx
                                          //item.Config.TaskTypeID = Guid.Parse("00B9D873-5A19-43D7-B085-A7444A5BABF2"); // export product database - ceshtse
                                          // item.Config.TaskTypeID = Guid.Parse("C9B497C1-6400-418F-86A1-B15CF14C9218"); // export product datavase - Venue Next
                                          //item.Config.TaskTypeID = Guid.Parse("8A348BC6-B1F1-4197-8278-88B32AE1BB14"); // export product datavase - Venue Hybrid

            await QueueProcessor.DoExport(item, null);
        }
    }
}
