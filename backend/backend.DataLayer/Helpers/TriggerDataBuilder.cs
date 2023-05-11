using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using backend.DataLayer.Models.Configuration;
using backend.Helpers.Portal;
using backend.Helpers.Runtime;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace backend.DataLayer.Helpers
{

	// Class to provide the data related to trigger parameter and conditions.
	// The posiible trigger parameter data is stored in triggerParameterDataJson
	// All the operators and other data like flightPhase, aircraft type information as stored in the respective Json as well.

	public class TriggerDataBuilder
    {
       public static List<TriggerParameter> loadTriggerData(List<string> iataList, List<string> icaoList)
        {
			List<TriggerFieldValue> triggerOperators = TriggerOperators();
			List<TriggerFieldValue> triggerFlightphases = TriggerFlightphases();
			List<TriggerFieldValue> triggerMiqatphases = TriggerMiqatphases();
			List<TriggerFieldValue> triggerDayofWeeks = TriggerDayofWeeks();
			List<TriggerFieldValue> triggerAircraftTypes = TriggerAircraftTypes();
			List<TriggerFieldValue> boolean = Boolean();

			
			List<TriggerParameter> triggerParameters = JsonConvert.DeserializeObject<List<TriggerParameter>>(triggerParameterDataJson());
			foreach(var param in triggerParameters)
            {
				if(param.EditorFieldType.Equals("popup"))
                {
					if (param.EditorFieldValue.Equals("flightphase"))
					{
						param.EditorFieldValues = triggerFlightphases.Cast<TriggerFieldValue>().ToList();
					}
					else if(param.EditorFieldValue.Equals("day_of_week"))
                    {
						param.EditorFieldValues = triggerDayofWeeks.Cast<TriggerFieldValue>().ToList();

					}
					else if (param.EditorFieldValue.Equals("miqat_phases"))
					{
						param.EditorFieldValues = triggerMiqatphases.Cast<TriggerFieldValue>().ToList();

					}
					else if (param.EditorFieldValue.Equals("aircraft_types"))
					{
						param.EditorFieldValues = triggerAircraftTypes.Cast<TriggerFieldValue>().ToList();

					}
					else if (param.EditorFieldValue.Equals("boolean"))
					{
						param.EditorFieldValues = boolean;

					}
					

				} else if(param.EditorFieldType.Equals("text-popup"))
                {
					if (param.EditorFieldValue.Equals("destination_iata") || param.EditorFieldValue.Equals("departure_iata"))
					{
						param.IATAList = iataList;

					}
					else if (param.EditorFieldValue.Equals("destination_icao") || param.EditorFieldValue.Equals("departure_icao"))
					{
						param.ICAOList = icaoList;

					}
				}

                if (param.Operator.Equals("all"))
                {
                    param.Operators = triggerOperators;

                }
				else if (param.Operator.Equals("none"))
                {
					param.Operators = null;
				}

				else 
				{
					var operatorsList = new List<TriggerFieldValue>();
					var operatorsNameList = param.Operator.Split(',');
					foreach(var op in operatorsNameList)
					{
						operatorsList.Add(triggerOperators.Where(ele => ele.Name.Equals(op)).First());

					}
					param.Operators = operatorsList;
					if(operatorsList.Count() == 1)
                    {
						param.Operator = triggerOperators.Where(ele => ele.Name.Equals(operatorsList[0].Name)).First().DisplayName;

					}

				}
				
			}
			return triggerParameters;

        }

		public static List<TriggerFieldValue> TriggerOperators()
        {
			return JsonConvert.DeserializeObject<List<TriggerFieldValue>>(triggerOperatorJson());
		}

		public static List<TriggerFieldValue> TriggerFlightphases()
        {
			return JsonConvert.DeserializeObject<List<TriggerFieldValue>>(triggerFlightPhaseJson());
		}

		public static List<TriggerFieldValue> TriggerMiqatphases()
        {
			return JsonConvert.DeserializeObject<List<TriggerFieldValue>>(triggerMiqatFlightPhaseJson());
		}

		public static List<TriggerFieldValue> TriggerDayofWeeks()
        {
			return JsonConvert.DeserializeObject<List<TriggerFieldValue>>(triggerDaysOfTheWeekJson());
		}

		public static List<TriggerFieldValue> TriggerAircraftTypes()
        {
			return JsonConvert.DeserializeObject<List<TriggerFieldValue>>(triggerAircraftTypesJson());
		}

		public static List<TriggerFieldValue> Boolean()
        {
			return JsonConvert.DeserializeObject<List<TriggerFieldValue>>(triggerBooleanJson());
		}

		public static List<TriggerFieldValue> TriggerPersonalities()
		{
			return JsonConvert.DeserializeObject<List<TriggerFieldValue>>(triggerPersonalityJson());
		}

		static string triggerParameterDataJson()
		{
			return "[ " +
			"{" +
				"'Name': 'GS'," +
				"'DisplayName': 'Ground Speed'," +
				"'EditorFieldType': 'numeric'," +
				"'EditorFieldFormat': 'none'," +
				"'EditorFieldValue': 'none'," +
				"'EditorFieldValueUnit': 'Knots'," +
				"'Operator': 'all'" +
			"}," +
			"{" +
				"'Name': 'ALT'," +
				"'DisplayName': 'Altitude'," +
				"'EditorFieldType': 'numeric'," +
				"'EditorFieldFormat ': 'none'," +
				"'EditorFieldValue ': 'none'," +
				"'EditorFieldValueUnit': 'Ft'," +
				"'Operator': 'all'" +
			"}," +
			"{" +
				"'Name': 'DTD'," +
				"'DisplayName': 'Distance to Destination'," +
				"'EditorFieldType': 'numeric'," +
				"'EditorFieldFormat': 'none'," +
				"'EditorFieldValue': 'none'," +
				"'EditorFieldValueUnit': 'Meters'," +
				"'Operator': 'all'" +
			"}," +
			"{" +
				"'Name': 'DFD'," +
				"'DisplayName': 'Distance from Departure'," +
				"'EditorFieldType': 'numeric'," +
				"'EditorFieldFormat': 'none'," +
				"'EditorFieldValue': 'none'," +
				"'EditorFieldValueUnit': 'Meters'," +
				"'Operator': 'all'" +
			"}," +
			"{" +
				"'Name': 'TTD'," +
				"'DisplayName': 'Time to Destination'," +
				"'EditorFieldType': 'numeric'," +
				"'EditorFieldFormat': 'none'," +
				"'EditorFieldValue': 'none'," +
				"'EditorFieldValueUnit': 'Minutes'," +
				"'Operator': 'all'" +
			"}," +
			"{" +
				"'Name': 'TSD'," +
				"'DisplayName': 'Time Since Departure'," +
				"'EditorFieldType': 'numeric'," +
				"'EditorFieldFormat': 'none'," +
				"'EditorFieldValue': 'none'," +
				"'EditorFieldValueUnit': 'Minutes'," +
				"'Operator': 'all'" +
			"}," +
			"{" +
				"'Name': 'FLTPHASE'," +
				"'DisplayName': 'Flight Phase'," +
				"'EditorFieldType': 'popup'," +
				"'EditorFieldFormat': 'none'," +
				"'EditorFieldValue': 'flightphase'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'EQ,NE'" +
			"}," +
			"{" +
				"'Name': 'PER'," +
				"'DisplayName': 'Periodic'," +
				"'EditorFieldType': 'numeric'," +
				"'EditorFieldFormat': 'none'," +
				"'EditorFieldValue': 'none'," +
				"'EditorFieldValueUnit': 'Seconds'," +
				"'Operator': 'EQ'" +
			"}," +
			"{" +
				"'Name': 'GMTT'," +
				"'DisplayName': 'Time'," +
				"'EditorFieldType': 'time'," +
				"'EditorFieldFormat': 'HHMMSS'," +
				"'EditorFieldValue': 'none'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'all'" +
			"}," +
			"{" +
				"'Name': 'GMTDATE'," +
				"'DisplayName': 'Date'," +
				"'EditorFieldType': 'date'," +
				"'EditorFieldFormat': 'YYMMDD'," +
				"'EditorFieldValue': 'none'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'all'" +
			"}," +
			"{" +
				"'Name': 'GMTDWOY'," +
				"'DisplayName': 'Date Without Year'," +
				"'EditorFieldType': 'date'," +
				"'EditorFieldFormat': 'MMDD'," +
				"'EditorFieldValue': 'none'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'all'" +
			"}," +
			"{" +
				"'Name': 'GMTTIMERANGE'," +
				"'DisplayName': 'GMT Hours'," +
				"'EditorFieldType': 'text'," +
				"'EditorFieldFormat': 'HH'," +
				"'EditorFieldValue': 'none'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'all'" +
			"}," +
			"{" +
				"'Name': 'GMTDATERANGE'," +
				"'DisplayName': 'GMT Month of Year'," +
				"'EditorFieldType': 'text'," +
				"'EditorFieldFormat': 'YYMM'," +
				"'EditorFieldValue': 'none'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'all'" +
			"}," +
			"{" +
				"'Name': 'DEP'," +
				"'DisplayName': 'Departure (IATA)'," +
				"'EditorFieldType': 'text-popup'," +
				"'EditorFieldFormat': 'XXX'," +
				"'EditorFieldValue': 'departure_iata'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'EQ,NE'" +
			"}," +
			"{" +
				"'Name': 'DES'," +
				"'DisplayName': 'Destination (IATA)'," +
				"'EditorFieldType': 'text-popup'," +
				"'EditorFieldFormat': 'XXX'," +
				"'EditorFieldValue': 'destination_iata'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'EQ,NE'" +
			"}," +
			"{" +
				"'Name': 'DOW'," +
				"'DisplayName': 'Day of Week'," +
				"'EditorFieldType': 'popup'," +
				"'EditorFieldFormat': 'none'," +
				"'EditorFieldValue': 'day_of_week'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'EQ,NE'" +
			"}," +
			"{" +
				"'Name': 'MANTRIG'," +
				"'DisplayName': 'Manual Trigger'," +
				"'EditorFieldType': 'popup'," +
				"'EditorFieldFormat': 'none'," +
				"'EditorFieldValue': 'boolean'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'EQ'" + "}," +
			"{" +
				"'Name': 'MIQATPHASE'," +
				"'DisplayName': 'Miqat Phase'," +
				"'EditorFieldType': 'popup'," +
				"'EditorFieldFormat': 'none'," +
				"'EditorFieldValue': 'miqat_phases'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'EQ,NE'" +
			"}," +
			"{" +
				"'Name': 'TYPE'," +
				"'DisplayName': 'Aircraft Type'," +
				"'EditorFieldType': 'popup'," +
				"'EditorFieldFormat': 'none'," +
				"'EditorFieldValue': 'aircraft_types'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'EQ,NE'" +
			"}," +
			"{" +
				"'Name': 'DEPT_ICAO'," +
				"'DisplayName': 'Departure (ICAO)'," +
				"'EditorFieldType': 'text-popup'," +
				"'EditorFieldFormat': 'XXXX'," +
				"'EditorFieldValue': 'departure_icao'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'EQ,NE'" +
			"}," +
			"{" +
				"'Name': 'DEST_ICAO'," +
				"'DisplayName': 'Destination (ICAO)'," +
				"'EditorFieldType': 'text-popup'," +
				"'EditorFieldFormat': 'XXXX'," +
				"'EditorFieldValue': 'destination_icao'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'EQ,NE'" +
			"}," +
			"{" +
				"'Name': 'LCLT'," +
				"'DisplayName': 'Local Time'," +
				"'EditorFieldType': 'time'," +
				"'EditorFieldFormat': 'HHMMSS'," +
				"'EditorFieldValue': 'none'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'all'" +
			"}," +
			"{" +
				"'Name': 'PERSONALITY'," +
				"'DisplayName': 'Personality'," +
				"'EditorFieldType': 'popup'," +
				"'EditorFieldFormat': 'none'," +
				"'EditorFieldValue': 'personality'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'EQ,NE'" +
			"}," +
			"{" +
				"'Name': 'ACARSPRESENT'," +
				"'DisplayName': 'ACARS Present'," +
				"'EditorFieldType': 'popup'," +
				"'EditorFieldFormat': 'none'," +
				"'EditorFieldValue': 'boolean'," +
				"'EditorFieldValueUnit': 'none'," +
				"'Operator': 'EQ'" +
			"}" +
		"]";
		}

		static string triggerOperatorJson()
        {
			return "[{'Name': 'GE','DisplayName': 'Greater or Equal to' }, {'Name': 'LE', 'DisplayName': 'Less than or Equal to' },"+
				"{'Name': 'LT', 'DisplayName': 'Less Than' },{'Name': 'GT', 'DisplayName': 'Greater Than' } ," +
                "{'Name': 'EQ', 'DisplayName': 'Equal to' }, { 'Name': 'NE', 'DisplayName': 'Not Equal to' }]";

		}

		static string triggerFlightPhaseJson()
        {
			return "[{'Name': 'ePreflight','DisplayName': 'Pre-flight'},{'Name': 'eTaxiout','DisplayName': 'Taxi Out'},"+
				"{'Name': 'eClimbout','DisplayName': 'Climb Out'},{'Name': 'eAscent','DisplayName': 'Ascent'},{'Name': 'eCruise','DisplayName': 'Cruise'},"+
				"{'Name': 'eDescent','DisplayName': 'Descent'},{'Name': 'eApproach','DisplayName': 'Approach'},"+
				"{'Name': 'eTaxiin','DisplayName': 'Taxi In'},{'Name': 'ePostflight','DisplayName': 'Post-flight'}]";

		}

		static string triggerMiqatFlightPhaseJson()
        {
			return "[ { 'Name': 'eDisabled', 'DisplayName': 'Disabled'},{'Name': 'eWorking','DisplayName': 'Working' }," +
                "{'Name': 'eCountdown','DisplayName': 'In Countdown'},{	'Name': 'eWelcome','DisplayName': 'Welcome'}]";

		}

		static string triggerDaysOfTheWeekJson()
        {
			return "[{'Name': '1','DisplayName': 'Monday'},{'Name': '2','DisplayName': 'Tuesday'},{'Name': '3','DisplayName': 'Wednesday'}," +
				"{'Name': '4','DisplayName': 'Thursday'},{'Name': '5','DisplayName': 'Friday'},{'Name': '6','DisplayName': 'Saturday'},{'Name': '7','DisplayName': 'Sunday'}]";

		}

		static string triggerAircraftTypesJson()
        {
			return "[{'Name': '737','DisplayName': '737'},{'Name': '747','DisplayName': '747'},{'Name': '787','DisplayName': '787'}," +
				"{'Name': 'A319','DisplayName': 'A319'},{'Name': 'A320','DisplayName': 'A320'},{'Name': 'A340','DisplayName': 'A340'}]";
		}

		static string triggerBooleanJson()
		{
			return "[{'Name': 'true','DisplayName': 'True'},{'Name': 'false','DisplayName': 'False'}]";
		}

		static string triggerPersonalityJson()
		{
			return "[{'Name': 'true','DisplayName': 'True'},{'Name': 'false','DisplayName': 'False'}]";
		}

	}


}
