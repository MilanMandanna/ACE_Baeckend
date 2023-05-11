using System;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Text;
using backend.DataLayer.Models.Configuration;

namespace backend.DataLayer.Helpers
{
    public static class TileMathHelper
    {

        static double MetersPerDeg = 1801.15273775f * 60.0f;
        static float MaxLatDeg = 90.0f;
        static float MaxLonDeg = 180.0f;

        static public PointF PixelPosToMetersGeoPos(PointF pixelPos, double scaleOfArcsecPerPixel,string mapPackageType)
        {

            //MetersPerDeg for Landsat7 = 1801.15273775f
            //MetersPerDeg for Landsat8 = 1851.9939618f
            //Defaulted to 1801.15273775f, if we have any other mappackage type is there in future, it should change
            MetersPerDeg = mapPackageType == "landsat7" ? 1801.15273775f * 60.0f :
                           mapPackageType == "landsat8" ? 1851.9939618f * 60.0f :
                           1801.15273775f * 60.0f;
            PointF objPointF = new PointF();

            objPointF.X = (float)(((pixelPos.X * scaleOfArcsecPerPixel) / MetersPerDeg) - MaxLonDeg);
            objPointF.Y = (float)-(((pixelPos.Y * scaleOfArcsecPerPixel) / MetersPerDeg) - MaxLatDeg);

            return objPointF;
        }

        static public double GetLatForRowCol(int row, int col, double scaleOfArcsecPerPixel,string mapPackageType)
        {
            PointF pixelPos = new PointF(col * 512, row * 512);
            PointF geoPos = PixelPosToMetersGeoPos(pixelPos, scaleOfArcsecPerPixel,mapPackageType);

            return geoPos.Y;
        }

        static public double GetLonForRowCol(int row, int col, double scaleOfArcsecPerPixel, string mapPackageType)
        {
            PointF pixelPos = new PointF(col * 512, row * 512);
            PointF geoPos = PixelPosToMetersGeoPos(pixelPos, scaleOfArcsecPerPixel, mapPackageType);

            return geoPos.X;
        }
        static public ASXiInset GetTileBoundaries(ASXiInset aSXiInset, string pathToFolder)
        {

            int startCol = Int32.MaxValue;
            int endCol = 0;
            int startRow = Int32.MaxValue;
            int endRow = 0;
            string[] stringRowFolderNames = System.IO.Directory.GetDirectories(pathToFolder);
            foreach (string row in stringRowFolderNames)
            {
                DirectoryInfo rowInfo = new DirectoryInfo(row);
                string tmpRowDirName = rowInfo.Name;

                int rowNum = Convert.ToInt32(tmpRowDirName);
                if (rowNum > endRow)
                    endRow = rowNum;
                if (rowNum < startRow)
                    startRow = rowNum;

                if (startCol == Int32.MaxValue && endCol == 0)
                {
                    string[] stringFileNames;
                    stringFileNames = System.IO.Directory.GetFiles(row);
                    foreach (string tileName in stringFileNames)
                    {
                        FileInfo tmpInfo = new FileInfo(tileName);
                        string tmpFileName = tmpInfo.Name;
                        if (!tmpFileName.Contains("jpg"))
                            continue;
                        string removeStr = string.Format("t{0}_{1}_", aSXiInset.Zoom, rowNum);

                        tmpFileName = tmpFileName.Replace(removeStr, "");
                        tmpFileName = tmpFileName.Replace(".jpg", "");

                        int colNum = 0;
                        if (!int.TryParse(tmpFileName, out colNum))
                        {
                            throw new Exception("Issue with tile " + tileName);
                        }
                        if (colNum > endCol)
                            endCol = colNum;
                        if (colNum < startCol)
                            startCol = colNum;

                    }
                }
            }
            aSXiInset.ColStart = startCol;
            aSXiInset.RowStart = startRow;
            aSXiInset.ColEnd = endCol;
            aSXiInset.RowEnd = endRow;
            aSXiInset.LatStart = GetLatForRowCol(startRow, startCol, aSXiInset.Zoom,aSXiInset.MapPackageType);
            aSXiInset.LongStart= GetLonForRowCol(startRow, startCol, aSXiInset.Zoom,aSXiInset.MapPackageType);

            aSXiInset.LatEnd = GetLatForRowCol(endRow + 1, endCol + 1, aSXiInset.Zoom,aSXiInset.MapPackageType);
            aSXiInset.LongEnd = GetLonForRowCol(endRow + 1, endCol + 1, aSXiInset.Zoom,aSXiInset.MapPackageType);
            getCDataString(pathToFolder, aSXiInset);
            return aSXiInset;
        }
        static public int getBitmapByteSize(int startCol, int endCol)
        {
            int width = (int)(((1 * (endCol - startCol + 1) + 31) / 32) * 4);
            return width;
        }
        static public byte reverseByte(byte originalByte)
        {
            int result = 0;
            for (int i = 0; i < 8; i++)
            {
                result = result << 1;
                result += originalByte & 1;
                originalByte = (byte)(originalByte >> 1);
            }

            return (byte)result;
        }

        static public void getCDataString(string tilePath, ASXiInset aSXiInset)
        {
            
            //create bmp data so app knows which tiles it can and cannot display on insets
            //int byteCount = getBitmapByteSize(startCol, endCol);
            int byteCount = getBitmapByteSize(aSXiInset.ColStart, aSXiInset.ColEnd);
            bool needsMapping = false;
            //creating fake BMP data so app know which tiles it can and cannot display on insets
            string cdataStr = "";
            int count = 0;
            //go through each row and column.
            for (int i = aSXiInset.RowStart; i <= aSXiInset.RowEnd; i++)
            {
                BitArray rowBits = new BitArray(byteCount * 8);
                for (int j = aSXiInset.ColStart; j <= aSXiInset.ColEnd; j++)
                {
                    string currTile = string.Format("{0}\\{2}\\t{1}_{2}_{3}.jpg", tilePath, aSXiInset.Zoom, i, j);
                    if (!File.Exists(currTile))
                        needsMapping = true;

                    rowBits[j - aSXiInset.ColStart] = File.Exists(currTile);
                }

                byte[] tmpByteChange = new byte[rowBits.Length / 8];
                rowBits.CopyTo(tmpByteChange, 0);

                for (int t = 0; t < tmpByteChange.Length; t++)
                {
                    //need to reverse each byte to account for BMP format
                    tmpByteChange[t] = reverseByte(tmpByteChange[t]);
                }

                string tmpDataStr = BitConverter.ToString(tmpByteChange).Replace('-', ' ');
                if (count == 0)
                    cdataStr += "\n" + tmpDataStr;
                else
                    cdataStr += " " + tmpDataStr;

                count += byteCount;
                if (count >= 64)
                    count = 0;
            }

            if (!needsMapping)
            {
                cdataStr = "";
            }

            aSXiInset.Cdata = cdataStr;
        }
    }
}
