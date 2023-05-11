using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.Xml.Serialization;

namespace backend.DataLayer.Models.Configuration
{
    public class ScriptConfiguration
    {
        public string ScriptName { get; set; }
        public int ScriptId { get; set; }
    }

    public class ScriptForcedLanguage
    {
        public string LanguageName { get; set; }
        public string LanguageCode { get; set; }
        public bool IsDefault { get; set; }
        public bool isSelected { get; set; }
    }

    [XmlRoot("item")]
    public class ScriptItem
    {
        [XmlAttribute(AttributeName = "type")]
        public string ItemType { get; set; }

        [XmlAttribute(AttributeName = "display_interval")]
        public string DisplayInterval { get; set; }

        [XmlAttribute(AttributeName = "filename")]
        public string FileName { get; set; }

        [XmlAttribute(AttributeName = "info_items")]
        public string InfoItems { get; set; }

        [XmlAttribute(AttributeName = "info_page")]
        public string InfoPage { get; set; }

        [XmlAttribute(AttributeName = "lang_in_cycle")]
        public string LanguageInCycle { get; set; }

        [XmlAttribute(AttributeName = "min_until_display")]
        public string MinsUntillDisplay { get; set; }

        [XmlAttribute(AttributeName = "provider")]
        public string Provider { get; set; }

        [XmlAttribute(AttributeName = "repeat_count")]
        public string RepeatCount { get; set; }

        [XmlAttribute(AttributeName = "sec_per_screen")]
        public string SecondsPerScreen { get; set; }

        [XmlAttribute(AttributeName = "show_first")]
        public string ShowFirst { get; set; }

        [XmlAttribute(AttributeName = "sub_type")]
        public string SubType { get; set; }

        [XmlAttribute(AttributeName = "ticker_visible")]
        public string TickerVisible { get; set; }

        [XmlAttribute(AttributeName = "triggeridref")]
        public string TriggerId { get; set; }

        [XmlAttribute(AttributeName = "zoom_res")]
        public string ZoomResolution { get; set; }
        [XmlIgnore]
        public string Index { get; set; }
        [XmlIgnore]
        public string ConfigId { get; set; }
        [XmlIgnore]
        public string ScriptId { get; set; }
        [XmlIgnore]
        public string TriggerName { get; set; }
        [XmlIgnore]
        public string LanguageName { get; set; }
        [XmlIgnore]
        public string ScriptName { get; set; }
        [XmlIgnore]
        public string ItemTypeText { get; set; }
    }

    public class ScriptItemDisplay
    {
        public int Index { get; set; }
        public string DisplayName { get; set; }
    }
    public class ScriptConfigFlightInfo
    {
        public string InfoName { get; set; }
        public bool isSelected { get; set; }
    }

    public class ScriptConfigFlightInfoParams
    {
        public string ParamName { get; set; }
        public string DisplayName { get; set; }
        public bool isSelected { get; set; }
    }
    public class ScriptItemCreationResult
    {
        public string Id { get; set; }

        public bool IsError { get; set; }

        public string Message { get; set; }
        public int Result { get; set; }
    }

    public class ScriptItemType
    {
        public string Name { get; set; }
        public string DisplayName { get; set; }
    }
}
