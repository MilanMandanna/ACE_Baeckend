using System;
using System.Collections.Generic;

namespace backend.DataLayer.Models.Configuration
{

    //This class contains the possible data each triggerParameter can have.
    //The data from Json is parsed to TriggerParameter object and added into paramters property of Trigger Object.
    public class TriggerParameter
    {
        public string Name { get; set; } //actual Name Used in Trigger Condition
        public string DisplayName { get; set; } // Name displayed onto UI screens
        public string EditorFieldType { get; set; } // Type can be 'popup', 'numeric','text', 'text-popup','date'.
                                                    // This type is used in UI to decide on the field Type to present
        public string EditorFieldFormat { get; set; } // Holds the value of Format if any, that the Field value should match.
                                                      //Also displayed in the UI for reference.
        public string EditorFieldValue { get; set; } // Actual Value of the Parameter. 
        public string Operator { get; set; }//Actual value of the operator
        public string EditorFieldValueUnit { get; set; } //Unit for the value

        public List<TriggerFieldValue> Operators { get; set; } //List of possible operators allowed for this trigger.
                                                             //This list is populated by the Operator value in the triggerParameterDataJson()
        public List<TriggerFieldValue> EditorFieldValues { get; set; } // List of possible values allowed.
                                                                       //This list is populetaed by EditorFieldValue. 
        public List<string> IATAList { get; set; }
        public List<string> ICAOList { get; set; }


        public TriggerParameter()
        {
        }


        public TriggerParameter(TriggerParameter other)
        {
            Name = other.Name;
            DisplayName = other.DisplayName;
            EditorFieldType = other.EditorFieldType;
            EditorFieldFormat = other.EditorFieldFormat;
            EditorFieldValue = other.EditorFieldValue;
            EditorFieldValueUnit = other.EditorFieldValueUnit;
            Operator = other.Operator;

            Operators = other.Operators;
            EditorFieldValues = other.EditorFieldValues;
            IATAList = other.IATAList;
            ICAOList = other.ICAOList;

        }

    }

    
    public class TriggerFieldValue
    {
        public string Name { get; set; }
        public string DisplayName { get; set; }
    }
}
