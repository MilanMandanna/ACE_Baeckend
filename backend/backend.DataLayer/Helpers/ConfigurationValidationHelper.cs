using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using backend.Helpers.Validator;
using backend.Logging.Contracts;

namespace backend.DataLayer.Helpers
{
    public class ConfigurationValidationHelper
    {
        public static  FileUploadResult ConfigurationValidation(FileUploadType ft, ILoggerManager _logger)
        {
            var ASXi3andASXi4_partNumbers = new List<string>() {
                        "810-0547",
                        "810-0581"};

            var ASXi4_partNumbers = new List<string>() {
                        "810-0668",
                        "810-0643"};

            var ASXi5_partNumbers = new List<string>() {
                        "810-0669"};

            var uploadResult = new FileUploadResult();

            //Extract custom.xml, AsxiProfile and IpadConfig.xml and Pack into a zip
            //This files will loaded to the Database
            AsxiConfig asxiconfig = new AsxiConfig();
            CustomConfig customConfig = new CustomConfig();
            CustomConfig ipadcustomConfig = new CustomConfig();
            BuildPackageHelper bo = new BuildPackageHelper();
            var importFiles = Directory.GetFiles(ft.extractedBuildPath, "*.*", SearchOption.AllDirectories).Where(f => f.EndsWith(".xml")||f.EndsWith(".sqlite3"));
            string initialImportFiles = ft.extractedBuildPath + "//initialImportFiles";
            string initialImportFileszip = ft.extractedBuildPath + "//initialImportFiles.zip";
            if (!Directory.Exists(initialImportFiles))
                Directory.CreateDirectory(initialImportFiles);
            foreach (string importFile in importFiles)
            {
                if (importFile.Contains("custom.xml"))
                {
                    if (importFile.Contains("ipadconfig") && !importFile.Contains("airshow"))
                    {
                        ipadcustomConfig.Name = "IpadConfig Custom.xml";
                        ipadcustomConfig.path = importFile;
                        ipadcustomConfig.configVersion = XmlHelper.getConfigVersion(importFile);
                        ipadcustomConfig.mapPackageName = XmlHelper.getMapPakageName(importFile);
                        File.Copy(importFile, Path.Combine(initialImportFiles, Path.GetFileName(importFile)), true);
                    }
                    else if (!importFile.Contains("ipadconfig"))
                    {
                        customConfig.Name = "Normal Custom.xml";
                        customConfig.path = importFile;
                        customConfig.configVersion = XmlHelper.getConfigVersion(importFile);
                        customConfig.mapPackageName = XmlHelper.getMapPakageName(importFile);
                    }
                    else
                        File.Delete(importFile);

                }
                if (importFile.Contains("asxiconfigpartnum.xml"))
                {
                    asxiconfig.Name = "Part Number";
                    asxiconfig.partNumber = XmlHelper.getPartNumber(importFile);
                }
                if (importFile.Contains("asxiprofile.xml"))
                {
                    asxiconfig.Name = "Part Number";
                    File.Copy(importFile, Path.Combine(initialImportFiles, Path.GetFileName(importFile)), true);
                }
                if (importFile.Contains("ipadconfig.xml"))
                {
                    File.Copy(importFile, Path.Combine(initialImportFiles, Path.GetFileName(importFile)), true);
                }
                if (importFile.Contains("asxinfo.sqlite3"))
                {
                    File.Copy(importFile, Path.Combine(initialImportFiles, Path.GetFileName(importFile)), true);
                }
            }
            ZipFile.CreateFromDirectory(initialImportFiles, initialImportFileszip);
            ft.configPathforWebjob = initialImportFileszip;
            _logger.LogInfo(customConfig.Name);
            _logger.LogInfo(customConfig.configVersion);
            _logger.LogInfo(customConfig.mapPackageName);
            _logger.LogInfo("#####################################");
            _logger.LogInfo(ipadcustomConfig.Name);
            _logger.LogInfo(ipadcustomConfig.configVersion);
            _logger.LogInfo(ipadcustomConfig.mapPackageName);
            _logger.LogInfo("#####################################");
            _logger.LogInfo(asxiconfig.Name);
            _logger.LogInfo(asxiconfig.partNumber);

           if (ft.ismmobileccPresent && !(ipadcustomConfig.Name.Equals("IpadConfig Custom.xml")))
            {
                uploadResult.IsError = false;
                uploadResult.Message = "ASXi3";
                ASXI3_Structure(ft.extractedBuildPath, _logger);
            }
            else if ((customConfig.configVersion == "3.0 3D Hybrid") && (ipadcustomConfig.configVersion == "4.4"))
            {
                uploadResult.IsError = false;
                uploadResult.Message = "ASXi3 & ASi5";
                //Build Structure of ASXI3 and ASXI5 (Combo would be same)
                ASXI4_Structure(ft.extractedBuildPath, _logger);
            }
            else if (ft.ismmobileccPresent)
            {
                //ICS
                uploadResult.IsError = false;
                uploadResult.Message = "ASXi4";
                //Build Structure of ASXI3 and ASXI4 (Combo would be same)
                ASXI4_Structure(ft.extractedBuildPath, _logger);
            }
            else if (ASXi5_partNumbers.Any(s => s.Contains(asxiconfig.partNumber.Substring(0, 7))))
            {
                uploadResult.IsError = false;
                uploadResult.Message = "ASXi5";
                //Build Structure of ASXI3 and ASXI4 (Combo would be same)
                ASXI4_Structure(ft.extractedBuildPath, _logger);
            }
            else if ((ASXi3andASXi4_partNumbers.Any(s => s.Contains(asxiconfig.partNumber.Substring(0, 7)))))
            {
                uploadResult.IsError = false;
                uploadResult.Message = "ASXi3 & ASi4";
                //Build Structure of ASXI3 and ASXI4 (Combo would be same)
                ASXI3_Structure(ft.extractedBuildPath, _logger);
            }
            else
            {
                uploadResult.IsError = true;
                uploadResult.Message = "Unknown Configuration !";
                if (Directory.Exists(ft.extractedBuildPath))
                {
                    Directory.Delete(ft.extractedBuildPath, true);
                }
            }
            return uploadResult;
        }

        public static void ASXI3_Structure(string extractedpath, ILoggerManager _logger)
        {
            DirectoryInfo di = new DirectoryInfo(extractedpath);
            var supportedExtensions = new[] { ".tgz", ".cii", ".zip" };
            FileInfo[] fileRead = di.GetFiles("*", SearchOption.AllDirectories).Where(f => supportedExtensions.Contains(f.Extension.ToLower())).ToArray();
            foreach (FileInfo fr in fileRead)
            {
                if (fr.Name.StartsWith("bmp"))
                {
                    if (fr.Name.EndsWith(supportedExtensions[0]) || fr.Name.EndsWith(supportedExtensions[1]) || fr.Name.EndsWith(supportedExtensions[2]))
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo("bmp present");
                    }
                    else
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo(" Wrong extension");
                    }
                }
                else if (fr.Name.StartsWith("mmcdp"))
                {
                    if (fr.Name.EndsWith(supportedExtensions[0]) || fr.Name.EndsWith(supportedExtensions[1]) || fr.Name.EndsWith(supportedExtensions[2]))
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo("mmcdp present");
                    }
                    else
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo(" Wrong extension");
                    }
                }
                else if (fr.Name.StartsWith("mmcfgp"))
                {
                    if (fr.Name.EndsWith(supportedExtensions[0]) || fr.Name.EndsWith(supportedExtensions[1]) || fr.Name.EndsWith(supportedExtensions[2]))
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo("mmcfgp present");
                    }
                    else
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo(" Wrong extension");
                    }
                }
                else if (fr.Name.StartsWith("mmcntp"))
                {
                    if (fr.Name.EndsWith(supportedExtensions[0]) || fr.Name.EndsWith(supportedExtensions[1]) || fr.Name.EndsWith(supportedExtensions[2]))
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo("mmcntp present");
                    }
                    else
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo(" Wrong extension");
                    }
                }
                else if (fr.Name.StartsWith("mmdbp"))
                {
                    if (fr.Name.EndsWith(supportedExtensions[0]) || fr.Name.EndsWith(supportedExtensions[1]) || fr.Name.EndsWith(supportedExtensions[2]))
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo("mmdbp present");
                    }
                    else
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo(" Wrong extension");
                    }
                }
                else
                {
                    _logger.LogInfo(fr.Name);
                    _logger.LogInfo(" File is not related");
                }
            }

        }

        public static void ASXI4_Structure(string extractedpath, ILoggerManager _logger)
        {
            DirectoryInfo di = new DirectoryInfo(extractedpath);
            var supportedExtensions = new[] { ".tgz", ".cii" };
            FileInfo[] fileRead = di.GetFiles("*", SearchOption.AllDirectories).Where(f => supportedExtensions.Contains(f.Extension.ToLower())).ToArray();
            foreach (FileInfo fr in fileRead)
            {
                if (fr.Name.StartsWith("mcc"))
                {
                    if (fr.Name.EndsWith(supportedExtensions[0]) || fr.Name.EndsWith(supportedExtensions[1]))
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo("mcc present");
                    }
                    else
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo(" Wrong extension");
                    }
                }
                else if (fr.Name.StartsWith("mcfg"))
                {
                    if (fr.Name.EndsWith(supportedExtensions[0]) || fr.Name.EndsWith(supportedExtensions[1]))
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo("mcfg present");
                    }
                    else
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo(" Wrong extension");
                    }
                }
                else if (fr.Name.StartsWith("mdata"))
                {
                    if (fr.Name.EndsWith(supportedExtensions[0]) || fr.Name.EndsWith(supportedExtensions[1]))
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo("mdata present");
                    }
                    else
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo(" Wrong extension");
                    }
                }
                else if (fr.Name.StartsWith("minsets"))
                {
                    if (fr.Name.EndsWith(supportedExtensions[0]) || fr.Name.EndsWith(supportedExtensions[1]))
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo("minsets present");
                    }
                    else
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo(" Wrong extension");
                    }
                }
                else if (fr.Name.StartsWith("mmobilecc"))
                {
                    if (fr.Name.EndsWith(supportedExtensions[0]) || fr.Name.EndsWith(supportedExtensions[1]))
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo(" mmobilecc present");
                    }
                    else
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo(" Wrong extension");
                    }
                }
                else if (fr.Name.StartsWith("mtz"))
                {
                    if (fr.Name.EndsWith(supportedExtensions[0]) || fr.Name.EndsWith(supportedExtensions[1]))
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo("mtz present");
                    }
                    else
                    {
                        _logger.LogInfo(fr.Name);
                        _logger.LogInfo(" Wrong extension");
                    }
                }
                else
                {
                    _logger.LogInfo(fr.Name);
                    _logger.LogInfo(" File is not related");
                }
            }

        }
    }
   
}
