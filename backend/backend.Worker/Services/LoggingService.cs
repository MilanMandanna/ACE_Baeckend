using System;
using NLog;
using System.IO;
using backend.Logging.Services;
using NLog.Targets;
using Microsoft.Extensions.DependencyInjection;
using backend.Logging.Contracts;

namespace backend.Worker.Services
{
    public class LoggingService
    {
        private string _logDirectory;
        private string _logFileName;
        public ILoggerManager logger { get; private set; }

        public LoggingService()
        {
            ConfigureLogging();
        }

        void ConfigureLogging()
        {
            LogManager.LoadConfiguration(String.Concat(Directory.GetCurrentDirectory(), "/nlog.config"));
            logger = new LoggerService();
        }

        public void setLogDirectory(string logDirectory)
        {
            _logDirectory = logDirectory;
            LogManager.Configuration.Variables["LogDirectory"] = logDirectory;
            LogManager.ReconfigExistingLoggers();
        }

        public void setLogFileName(string logFileName)
        {
            _logFileName = logFileName;
             var target = (FileTarget)LogManager.Configuration.FindTargetByName("allfile");
            target.FileName = logFileName;
            LogManager.ReconfigExistingLoggers();
        }
    }
}
