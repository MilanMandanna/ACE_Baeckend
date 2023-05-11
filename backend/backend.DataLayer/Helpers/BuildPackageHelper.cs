using SharpCompress.Common;
using SharpCompress.Readers;
using System;
using System.IO;
using System.IO.Compression;
using System.Text.RegularExpressions;
using SevenZipExtractor;
using ICSharpCode.SharpZipLib.GZip;
using ICSharpCode.SharpZipLib.Tar;
using backend.Helpers.Validator;
using System.Diagnostics;
using System.Linq;

namespace backend.DataLayer.Helpers
{
    public class BuildPackageHelper
    {
        public string zipFileExtractor(string path)
        {
            //string fileName = Path.GetFileName(path);
            string resultPath = Regex.Replace(path, ".zip", "");
            if (!Directory.Exists(resultPath))
                Directory.CreateDirectory(resultPath);
            ZipFile.ExtractToDirectory(path, resultPath);
            //var dir = new DirectoryInfo(resultPath);
            //resultPath = Path.Combine(resultPath, dir.Name);
            return resultPath;
        }
        public string zipFileExtractor(string path, bool overwrite)
        {
            string resultPath = Regex.Replace(path, ".zip", "");
            if (!Directory.Exists(resultPath))
                Directory.CreateDirectory(resultPath);
            ZipFile.ExtractToDirectory(path, resultPath, overwrite);
            return resultPath;
        }
        public string tgzFileExtractor(string tgzFilePath)
        {
            //string fileName = Path.GetFileName(path);
            string resultPath = Regex.Replace(tgzFilePath, ".tgz", "");
            if (!Directory.Exists(resultPath))
                Directory.CreateDirectory(resultPath);
            using Stream stream = File.OpenRead(tgzFilePath);
            using var reader = ReaderFactory.Open(stream);
            while (reader.MoveToNextEntry())
            {
                if (!reader.Entry.IsDirectory)
                {
                    Console.WriteLine(reader.Entry.Key);
                    reader.WriteEntryToDirectory(resultPath, new ExtractionOptions()
                    {
                        ExtractFullPath = true,
                        Overwrite = true
                    });
                }
            }
            return resultPath;
        }

        public string tarFileExtractor(string tarFilePath)
        {
            string resultPath = Regex.Replace(tarFilePath, ".tar", "");
            if (!Directory.Exists(resultPath))
                Directory.CreateDirectory(resultPath);
            using Stream stream = File.OpenRead(tarFilePath);
            using var reader = ReaderFactory.Open(stream);
            while (reader.MoveToNextEntry())
            {
                if (!reader.Entry.IsDirectory)
                {
                    reader.WriteEntryToDirectory(resultPath, new ExtractionOptions()
                    {
                        ExtractFullPath = true,
                        Overwrite = true
                    });
                }
            }
            return resultPath;
        }
        public string imgFileExtractor(string imgFilePath)
        {
            string resultPath = Regex.Replace(imgFilePath, ".img", "");
            if (!Directory.Exists(resultPath))
                Directory.CreateDirectory(resultPath);
            byte[] file = File.ReadAllBytes(imgFilePath);
            MemoryStream memoryStream = new MemoryStream(file);
            using (ArchiveFile archiveFile = new ArchiveFile(memoryStream, SevenZipFormat.SquashFS))
            {

                foreach (SevenZipExtractor.Entry entry in archiveFile.Entries)
                {
                    string x = Path.Combine(resultPath, entry.FileName);
                    entry.Extract(x);
                }
            }
            return resultPath;
        }
        public void tarFileExtractot(string path)
        {
            //string fileName = Path.GetFileName(path);
            string resultPath = Regex.Replace(path, ".zip", "");
            if (!Directory.Exists(resultPath))
                Directory.CreateDirectory(resultPath);
            ZipFile.ExtractToDirectory(path, resultPath);

        }
        public void ArchiveBuildSupportScripts(string imgPath, string venuenextscripts)
        {
            string imgName = new DirectoryInfo(imgPath).Name;
            string tempScriptsPath = Path.Combine(venuenextscripts, imgName + "_scripts");
            if (!Directory.Exists(tempScriptsPath))
                Directory.CreateDirectory(tempScriptsPath);
            var buildScripts = Directory.GetFiles(imgPath, "*.sh*");
            foreach (var script in buildScripts)
            {
                File.Move(script, Path.Combine(tempScriptsPath, Path.GetFileName(script)));
            }
        }

        /// <summary>
        /// Creates a .tgz file using everything in the sourceDirectory. The .tgz file will be titled {tgzFileName}.tgz and will be located in targetDirectory.
        /// </summary>
        /// <param name="sourceDirectory">Directory to compress into a .tgz</param>
        /// <param name="tgzFileName">Name of .tgz file</param>
        /// <param name="targetDirectory">Directory where {tgzFileName}.tgz should be located.</param>
        /// <param name="deleteSourceDirectoryUponCompletion">Will delete sourceDirectory if <see langword="true"/></param>
        /// <returns>Path to .tgz file</returns>
        public string CreateTGZ(string sourceDirectory, string targetDirectory, bool deleteSourceDirectoryUponCompletion = false)
        {
            string tgzFileName = Path.GetFileName(sourceDirectory);
            if (!tgzFileName.EndsWith(".tgz"))
            {
                tgzFileName = tgzFileName + ".tgz";
            }
            using var outStream = File.Create(Path.Combine(targetDirectory, tgzFileName));
            using var gzoStream = new GZipOutputStream(outStream);
            var tarArchive = TarArchive.CreateOutputTarArchive(gzoStream);

            // Note that the RootPath is currently case sensitive and must be forward slashes e.g. "c:/temp"
            // and must not end with a slash, otherwise cuts off first char of filename
            tarArchive.RootPath = sourceDirectory.Replace('\\', '/');
            if (tarArchive.RootPath.EndsWith("/"))
            {
                tarArchive.RootPath = tarArchive.RootPath.Remove(tarArchive.RootPath.Length - 1);
            }

            AddDirectoryFilesToTGZ(tarArchive, sourceDirectory);

            if (deleteSourceDirectoryUponCompletion)
            {
                Directory.Delete(sourceDirectory, true);
            }

            var tgzPath = (tarArchive.RootPath + ".tgz").Replace('/', '\\');

            tarArchive.Close();
            return tgzPath;
        }

        private void AddDirectoryFilesToTGZ(TarArchive tarArchive, string sourceDirectory, string currentDirectory = "")
        {
            var pathToCurrentDirectory = Path.Combine(sourceDirectory, currentDirectory);

            // Write each file to the tgz.
            var filePaths = Directory.GetFiles(pathToCurrentDirectory);
            foreach (string filePath in filePaths)
            {
                var tarEntry = TarEntry.CreateEntryFromFile(filePath);
                tarArchive.WriteEntry(tarEntry, true);
            }

            // Write directories to tgz
            var directories = Directory.GetDirectories(pathToCurrentDirectory);
            foreach (string directory in directories)
            {
                TarEntry tarEntry = TarEntry.CreateEntryFromFile(directory);
                tarArchive.WriteEntry(tarEntry, false);
                AddDirectoryFilesToTGZ(tarArchive, pathToCurrentDirectory, new DirectoryInfo((directory)).Name);
            }
        }

        /// <summary>
        ///Discription: This function Compress a directory and returs the output path.
        /// </summary>
        /// <param name="path"></param>
        /// <returns>path+zip</returns>
        public string CreateZip(string path)
        {
            ZipFile.CreateFromDirectory(path, path + ".zip", CompressionLevel.Fastest, true);
            Directory.Delete(path, true);
            return path + ".zip";
        }

        public void CreateZipFile(string sourceFolderPath, string zipFilePath)
        {
            using (var zipStream = new FileStream(zipFilePath, FileMode.Create))
            {
                using (var zipArchive = new ZipArchive(zipStream, ZipArchiveMode.Create))
                {
                    // Recursively add all files and directories in the source folder to the archive
                    AddFolderToZip(zipArchive, sourceFolderPath, "");
                }
            }

            Directory.Delete(sourceFolderPath, true);
        }
        // Recursive function to add all files and directories to the zip archive
        private static void AddFolderToZip(ZipArchive zipArchive, string sourceFolder, string relativePath)
        {
            foreach (string filePath in Directory.GetFiles(sourceFolder))
            {
                string fileName = Path.GetFileName(filePath);
                string entryPath = Path.Combine(relativePath, fileName);
                ZipArchiveEntry entry = zipArchive.CreateEntry(entryPath, CompressionLevel.Optimal);
                using (Stream entryStream = entry.Open())
                {
                    using (FileStream fileStream = new FileStream(filePath, FileMode.Open))
                    {
                        fileStream.CopyTo(entryStream);
                    }
                }
            }

            foreach (string directoryPath in Directory.GetDirectories(sourceFolder))
            {
                string directoryName = Path.GetFileName(directoryPath);
                string entryPath = Path.Combine(relativePath, directoryName) + "/";
                ZipArchiveEntry entry = zipArchive.CreateEntry(entryPath);
                AddFolderToZip(zipArchive, directoryPath, entryPath);
            }
        }
        public void CopyFilesRecursively(string sourcePath, string targetPath)
        {
            //Now Create all of the directories
            foreach (string dirPath in Directory.GetDirectories(sourcePath, "*", SearchOption.AllDirectories))
            {
                Directory.CreateDirectory(dirPath.Replace(sourcePath, targetPath));
            }

            //Copy all the files & Replaces any files with the same name
            foreach (string newPath in Directory.GetFiles(sourcePath, "*.*", SearchOption.AllDirectories))
            {
                File.Copy(newPath, newPath.Replace(sourcePath, targetPath), true);
            }
        }
        public FileUploadType BuilDCustomContentPackages(string _buildPath)
        {
            FileUploadType _customContentFile = new FileUploadType
            {
                _cciPadConfigzip = new CustomComponentFile(),
                _ccBriefingsConfig = new CustomComponentFile(),
                _ccBriefingsContent = new CustomComponentFile(),
                _ccConfigData = new CustomComponentFile(),
                _ccHDBriefings = new CustomComponentFile(),
                _ccTextures = new CustomComponentFile(),
                _ccModels = new CustomComponentFile(),
                _ccBuildSupportScripts = new CustomComponentFile(),
                _ccTicker = new CustomComponentFile(),
            };

            //Extract the Build
            string BuildExtractedPath = zipFileExtractor(_buildPath);
            _customContentFile.extractedBuildPath = BuildExtractedPath;

            //Extract all available tgz files
            var filesTgz = Directory.GetFiles(BuildExtractedPath, "*.tgz*", SearchOption.AllDirectories);
            foreach (var f_tgz in filesTgz)
            {
                tgzFileExtractor(f_tgz);
                if (f_tgz.Contains("mmcfg"))
                {
                    _customContentFile.ismmcfgPresent = true;
                }
                else if (f_tgz.Contains("mmobilecc"))
                {
                    _customContentFile.ismmobileccPresent = true;
                }
            }

            //Extract all available img files
            var filesImg = Directory.GetFiles(BuildExtractedPath, "*.img*", SearchOption.AllDirectories);

            //Create buildSupportScript directory
            string venuenextscripts = Path.Join(BuildExtractedPath, "Venue_Next_Data_custom_component");
            if (!Directory.Exists(venuenextscripts))
                Directory.CreateDirectory(venuenextscripts);
            foreach (var f_img in filesImg)
            {
                string imgFilePath = imgFileExtractor(f_img);
                ArchiveBuildSupportScripts(imgFilePath, venuenextscripts);
                _customContentFile._ccBuildSupportScripts.IsFilePresent = true;
                _customContentFile._ccBuildSupportScripts.FileName = "Venue_Next_Data_custom_component";

            }
            _customContentFile._ccBuildSupportScripts.FilePath = CreateZip(venuenextscripts);

            //Find and extract iPadConfigzip
            var allZipfiles = Directory.GetFiles(BuildExtractedPath, "*.zip*", SearchOption.AllDirectories);
            string ipadConfigFolder = "";
            foreach (var iPadConfigzip in allZipfiles)
            {
                if (iPadConfigzip.EndsWith("ipadconfig.zip"))
                {
                    ipadConfigFolder = zipFileExtractor(iPadConfigzip);
                    _customContentFile._cciPadConfigzip.IsFilePresent = true;
                    _customContentFile._cciPadConfigzip.FileName = "ipadconfig";
                    File.Delete(iPadConfigzip);
                }
            }

            if (_customContentFile._cciPadConfigzip.IsFilePresent)
            {
                _customContentFile._cciPadConfigzip.FilePath = Path.Join(BuildExtractedPath, _customContentFile._cciPadConfigzip.FileName);
                if (!Directory.Exists(_customContentFile._cciPadConfigzip.FilePath))
                    Directory.CreateDirectory(_customContentFile._cciPadConfigzip.FilePath);
                var filesDB = Directory.GetFiles(ipadConfigFolder, "*.sqlite3*", SearchOption.AllDirectories);
                foreach (var fileDB in filesDB)
                {
                    File.Delete(fileDB);
                }
                CopyFilesRecursively(ipadConfigFolder, _customContentFile._cciPadConfigzip.FilePath);
                _customContentFile._cciPadConfigzip.FilePath = CreateZip(_customContentFile._cciPadConfigzip.FilePath);
            }

            //Extract the Flight Data from the build and packing into a zip
            var flightDatafoldersFound = Directory.GetDirectories(BuildExtractedPath, "config", SearchOption.AllDirectories);
            string flightDatafolderName = "";
            foreach (var flightDatafolder in flightDatafoldersFound)
            {
                if (Directory.Exists(Path.Combine(flightDatafolder, "FMS")) && File.Exists(Path.Combine(flightDatafolder, "acars.xml")) && File.Exists(Path.Combine(flightDatafolder, "arincdinputs.xml")) &&
                    File.Exists(Path.Combine(flightDatafolder, "asxiconfigpartnum.xml")) && File.Exists(Path.Combine(flightDatafolder, "FDCMapMenuListConfig.xml")) && File.Exists(Path.Combine(flightDatafolder, "asxiprofile.xml"))
                    && File.Exists(Path.Combine(flightDatafolder, "siteid.dat")) && File.Exists(Path.Combine(flightDatafolder, "tzdbase.dat")))
                {

                    _customContentFile._ccConfigData.IsFilePresent = true;
                    _customContentFile._ccConfigData.FileName = "Flight_Config_Data_custom_component";
                    flightDatafolderName = flightDatafolder;
                }
            }

            if (_customContentFile._ccConfigData.IsFilePresent)
            {
                _customContentFile._ccConfigData.FilePath = Path.Join(BuildExtractedPath, _customContentFile._ccConfigData.FileName);
                if (!Directory.Exists(_customContentFile._ccConfigData.FilePath))
                    Directory.CreateDirectory(_customContentFile._ccConfigData.FilePath);
                CopyFilesRecursively(flightDatafolderName, _customContentFile._ccConfigData.FilePath);
                _customContentFile._ccConfigData.FilePath = CreateZip(_customContentFile._ccConfigData.FilePath);
            }

            //Extract the Briefings from the build and packing into a zip

            //FDCBriefingsMenuList.xml
            var files_briefings = Directory.GetFiles(BuildExtractedPath, "*.*", SearchOption.AllDirectories);
            string briengDirectoryName = "";
            foreach (var f_briefing in files_briefings)
            {
                if (f_briefing.Contains("FDCBriefingsMenuListConfig.xml"))
                {
                    briengDirectoryName = Path.GetDirectoryName(f_briefing);
                    _customContentFile._ccBriefingsConfig.FileName = "config";
                    _customContentFile._ccBriefingsConfig.IsFilePresent = true;
                }

            }
            if (_customContentFile._ccBriefingsConfig.IsFilePresent)
            {
                _customContentFile._ccBriefingsConfig.FilePath = Path.Join(BuildExtractedPath, _customContentFile._ccBriefingsConfig.FileName);
                if (!Directory.Exists(_customContentFile._ccBriefingsConfig.FilePath))
                    Directory.CreateDirectory(_customContentFile._ccBriefingsConfig.FilePath);
                CopyFilesRecursively(briengDirectoryName, _customContentFile._ccBriefingsConfig.FilePath);
                // _customContentFile._ccBriefingsConfig.FilePath = CreateZip(_customContentFile._ccBriefingsConfig.FilePath);
            }

            //Extract the Briefings from the build and packing into a zip
            var files_briefingsContent = Directory.GetFiles(BuildExtractedPath, "*.mp4*", SearchOption.AllDirectories);
            string briengContentDirectoryName = "";
            foreach (var f_briefingContent in files_briefingsContent)
            {
                briengContentDirectoryName = Path.GetDirectoryName(f_briefingContent);
                _customContentFile._ccBriefingsContent.FileName = "content";
                _customContentFile._ccBriefingsContent.IsFilePresent = true;
            }
            if (_customContentFile._ccBriefingsContent.IsFilePresent)
            {
                _customContentFile._ccBriefingsContent.FilePath = Path.Join(BuildExtractedPath, _customContentFile._ccBriefingsContent.FileName);
                if (!Directory.Exists(_customContentFile._ccBriefingsContent.FilePath))
                    Directory.CreateDirectory(_customContentFile._ccBriefingsContent.FilePath);
                CopyFilesRecursively(briengContentDirectoryName, _customContentFile._ccBriefingsContent.FilePath);

                //_customContentFile._ccBriefingsContent.FilePath = CreateZip(_customContentFile._ccBriefingsContent.FilePath);
            }

            //Creating HD Briefing zip
            if (_customContentFile._ccBriefingsContent.IsFilePresent && _customContentFile._ccBriefingsConfig.IsFilePresent)
            {
                _customContentFile._ccHDBriefings.FileName = "briefings configuration";
                _customContentFile._ccHDBriefings.IsFilePresent = true;

                _customContentFile._ccHDBriefings.FilePath = Path.Join(BuildExtractedPath, _customContentFile._ccHDBriefings.FileName);
                string _ccHDBriefingsContentPath = Path.Join(_customContentFile._ccHDBriefings.FilePath, "content");
                string _ccHDBriefingsConfigPath = Path.Join(_customContentFile._ccHDBriefings.FilePath, "config");
                if (!Directory.Exists(_ccHDBriefingsContentPath))
                    Directory.CreateDirectory(_ccHDBriefingsContentPath);
                if (!Directory.Exists(_ccHDBriefingsConfigPath))
                    Directory.CreateDirectory(_ccHDBriefingsConfigPath);
                CopyFilesRecursively(_customContentFile._ccBriefingsContent.FilePath, _ccHDBriefingsContentPath);
                CopyFilesRecursively(_customContentFile._ccBriefingsConfig.FilePath, _ccHDBriefingsConfigPath);
                _customContentFile._ccHDBriefings.FilePath = CreateZip(_customContentFile._ccHDBriefings.FilePath);
                Directory.Delete(_customContentFile._ccBriefingsContent.FilePath, true);
                Directory.Delete(_customContentFile._ccBriefingsConfig.FilePath, true);
            }

            //Extract the textures from the build and packing into a zip
            var texturesfoldersFound = Directory.GetDirectories(BuildExtractedPath, "textures", SearchOption.AllDirectories);
            string textureDirectoryName = "";
            foreach (var texturesfolder in texturesfoldersFound)
            {
                textureDirectoryName = texturesfolder;
                _customContentFile._ccTextures.FileName = "Textures_Data_custom_component";
                _customContentFile._ccTextures.IsFilePresent = true;
            }

            if (_customContentFile._ccTextures.IsFilePresent)
            {
                _customContentFile._ccTextures.FilePath = Path.Join(BuildExtractedPath, _customContentFile._ccTextures.FileName);
                if (!Directory.Exists(_customContentFile._ccTextures.FilePath))
                    Directory.CreateDirectory(_customContentFile._ccTextures.FilePath);
                CopyFilesRecursively(textureDirectoryName, _customContentFile._ccTextures.FilePath);
                _customContentFile._ccTextures.FilePath = CreateZip(_customContentFile._ccTextures.FilePath);
            }


            //Extract the textures from the build and packing into a zip
            var modelsfoldersFound = Directory.GetDirectories(BuildExtractedPath, "models", SearchOption.AllDirectories);
            string modelsDirectoryName = "";
            foreach (var modelsfolder in modelsfoldersFound)
            {
                modelsDirectoryName = modelsfolder;
                _customContentFile._ccModels.FileName = "Aircraft_Models_Data_custom_component";
                _customContentFile._ccModels.IsFilePresent = true;
            }

            if (_customContentFile._ccModels.IsFilePresent)
            {
                _customContentFile._ccModels.FilePath = Path.Join(BuildExtractedPath, _customContentFile._ccModels.FileName);
                if (!Directory.Exists(_customContentFile._ccModels.FilePath))
                    Directory.CreateDirectory(_customContentFile._ccModels.FilePath);
                CopyFilesRecursively(modelsDirectoryName, _customContentFile._ccModels.FilePath);
                _customContentFile._ccModels.FilePath = CreateZip(_customContentFile._ccModels.FilePath);
            }

            //Extract the tickers from the build and packing into a zip
            var customerContentfoldersFound = Directory.GetDirectories(BuildExtractedPath, "customer_content", SearchOption.AllDirectories);
            string customerContentDirectoryName = "";
            foreach (var customercontentfolder in customerContentfoldersFound)
            {
                if (File.Exists(Path.Combine(customercontentfolder, "asxi-ad-config.xml")))
                {
                    customerContentDirectoryName = Path.GetDirectoryName(customercontentfolder);
                    _customContentFile._ccTicker.FileName = "Ticker_Ads_Data_custom_component";
                    _customContentFile._ccTicker.IsFilePresent = true;

                }
            }

            if (_customContentFile._ccTicker.IsFilePresent)
            {
                _customContentFile._ccTicker.FilePath = Path.Join(BuildExtractedPath, _customContentFile._ccTicker.FileName);
                if (!Directory.Exists(_customContentFile._ccTicker.FilePath))
                    Directory.CreateDirectory(_customContentFile._ccTicker.FilePath);
                CopyFilesRecursively(customerContentDirectoryName, _customContentFile._ccTicker.FilePath);
                _customContentFile._ccTicker.FilePath = CreateZip(_customContentFile._ccTicker.FilePath);
            }


            return _customContentFile;
        }

        /// <summary>
        /// Squash file (.img) will be created in the destination folder folder with destination filename
        /// </summary>
        /// <param name="sourceFolder"></param>
        /// <param name="destinationFolder"></param>
        /// <param name="destinationFileName"></param>
        /// <summary>
        /// Squash file (.img) will be created in the destination folder folder with destination filename
        /// </summary>
        /// <param name="sourceFolder"></param>
        /// <param name="destinationFolder"></param>
        /// <param name="destinationFileName"></param>
        public bool CreateSquashIMGFileSystem(string cygwinPath, string sourceFolder, string destinationFolder, string destinationFileName, out string message)
        {
            string returnString = string.Empty;
            try
            {
                var GetDirectory = Directory.GetParent(Directory.GetCurrentDirectory()).Parent.Parent.FullName;
                Process myProcess = new Process();
                myProcess.StartInfo.FileName = cygwinPath + "\\bin\\bash.exe";
                myProcess.StartInfo.WorkingDirectory = cygwinPath + "/bin/";
                myProcess.StartInfo.UseShellExecute = false;
                myProcess.StartInfo.RedirectStandardOutput = true;
                myProcess.StartInfo.CreateNoWindow = true;
                myProcess.StartInfo.RedirectStandardError = true;
                myProcess.StartInfo.ErrorDialog = true;
                string arg = String.Format("--login -i \"{0}\\assets\\bin\\mkSquashFile.sh\"  \"{1}\"  \"{2}\"   \"{3}\"", Directory.GetCurrentDirectory(), myProcess.StartInfo.WorkingDirectory, Path.GetFullPath(sourceFolder), Path.GetFullPath(destinationFolder) + "\\" + destinationFileName);
                myProcess.StartInfo.Arguments = arg.ToString();
                myProcess.Start();

                myProcess.OutputDataReceived += (object sender, DataReceivedEventArgs e) =>
                    returnString += "output>>" + e.Data;
                myProcess.BeginOutputReadLine();

                myProcess.ErrorDataReceived += (object sender, DataReceivedEventArgs e) =>
                returnString += "error>>" + e.Data;

                myProcess.BeginErrorReadLine();

                myProcess.WaitForExit();
                myProcess.Close();
            }
            catch (Exception ex)
            {
                returnString += "error>>" + ex.Message;
                message = returnString;
                return false;
            }
            message = returnString;
            return true;

        }



        public bool ChangeFileAccess(string cygwinPath, string buildDirecotry, string sourceFolder, string access, out string message)
        {
            string returnString = string.Empty;
            try
            {
                cygwinPath = Path.GetFullPath(cygwinPath);
                var GetDirectory = Directory.GetParent(Directory.GetCurrentDirectory()).Parent.Parent.FullName;
                Process myProcess = new Process();
                myProcess.StartInfo.FileName = cygwinPath + "\\bin\\bash.exe";
                myProcess.StartInfo.WorkingDirectory = cygwinPath + "/bin/";
                myProcess.StartInfo.UseShellExecute = false;
                myProcess.StartInfo.RedirectStandardOutput = true;
                myProcess.StartInfo.CreateNoWindow = false;
                myProcess.StartInfo.RedirectStandardError = true;
                myProcess.StartInfo.ErrorDialog = true;
                string arg = String.Format("--login -i \"{0}\\assets\\bin\\chmod.sh\"  \"{1}\"  \"{2}\"   \"{3}\"  \"{4}\"", Directory.GetCurrentDirectory(), myProcess.StartInfo.WorkingDirectory, Path.GetFullPath(sourceFolder), access, Path.GetFullPath(buildDirecotry));
                myProcess.StartInfo.Arguments = arg.ToString();
                myProcess.Start();

                myProcess.OutputDataReceived += (object sender, DataReceivedEventArgs e) =>
                    returnString += "output>>" + e.Data;
                myProcess.BeginOutputReadLine();

                myProcess.ErrorDataReceived += (object sender, DataReceivedEventArgs e) =>
                returnString += "error>>" + e.Data;
                myProcess.BeginErrorReadLine();

                myProcess.WaitForExit();
                myProcess.Close();

            }
            catch (Exception ex)
            {
                returnString += "error>>" + ex.Message;
                message = returnString;
                return false;
            }
            message = returnString;
            return true;
        }
        /// <summary>
        /// Creates the TGZ file with give filename into the targetdirectory
        /// (The tgz file Name should passed with extension)
        /// </summary>
        /// <param name="sourceDirectory"></param>
        /// <param name="tgzFileName"></param>
        /// <param name="targetDirectory"></param>
        /// <param name="deleteSourceDirectoryUponCompletion"></param>
        /// <returns></returns>
        public string CreateTGZ(string sourceDirectory, string tgzFileName, string targetDirectory, bool deleteSourceDirectoryUponCompletion = false)
        {

            using var outStream = File.Create(Path.Combine(targetDirectory, tgzFileName));
            using var gzoStream = new GZipOutputStream(outStream);
            var tarArchive = TarArchive.CreateOutputTarArchive(gzoStream);

            // Note that the RootPath is currently case sensitive and must be forward slashes e.g. "c:/temp"
            // and must not end with a slash, otherwise cuts off first char of filename
            tarArchive.RootPath = sourceDirectory.Replace('\\', '/');
            if (tarArchive.RootPath.EndsWith("/"))
            {
                tarArchive.RootPath = tarArchive.RootPath.Remove(tarArchive.RootPath.Length - 1);
            }

            AddDirectoryFilesToTGZ(tarArchive, sourceDirectory);

            if (deleteSourceDirectoryUponCompletion)
            {
                Directory.Delete(sourceDirectory, true);
            }

            var tgzPath = (tarArchive.RootPath + ".tgz").Replace('/', '\\');

            tarArchive.Close();
            return tgzPath;
        }

        public void zipFileExtractor(string zipfilePath, string destinationFolderPath, bool deleteSourceFileUponCompletion = false)
        {
            if (!Directory.Exists(destinationFolderPath))
                Directory.CreateDirectory(destinationFolderPath);
            ZipFile.ExtractToDirectory(zipfilePath, destinationFolderPath);
            if (deleteSourceFileUponCompletion)
                File.Delete(zipfilePath);
        }
    }
}

