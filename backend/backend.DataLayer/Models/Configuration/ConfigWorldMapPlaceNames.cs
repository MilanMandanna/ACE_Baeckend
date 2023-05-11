﻿using System;
using System.Collections.Generic;
using System.Text;
using backend.DataLayer.Helpers.Database;

namespace backend.DataLayer.Models.Configuration
{
    [DataProperty(TableName = "cust.tblWorldMapPlaceNames")]
    public class ConfigWorldMapPlaceNames
    {
        [DataProperty(PrimaryKey = true)]
        public int PlaceNameID { get; set; }

        [DataProperty]
        public string PlaceNames { get; set; }
    }
}
