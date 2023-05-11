using System;

namespace backend.Helpers
{
    public class ModListHelper
    {
        public ModListData ModlistCalculator( float lat ,float lon, double resolution, string landSatType)
        {
            ModListData modListData = new ModListData();

            double landSatValue = landSatType.ToLower() == "temlandsat7" ? 1801.15273775 : 1851.99396180872;
            double tile_height = 512.0;
            double tile_width = 512.0;
            double degrees_per_minute = landSatValue * 60.0;
            modListData.Row = Math.Floor(((((-1 * lat) + 90.0) * degrees_per_minute) / resolution) / tile_height);
            modListData.Column = Math.Floor((((lon + 180.0) * degrees_per_minute) / resolution) / tile_width);
            modListData.Resolution = resolution;
            return modListData;
        }
    }
}
