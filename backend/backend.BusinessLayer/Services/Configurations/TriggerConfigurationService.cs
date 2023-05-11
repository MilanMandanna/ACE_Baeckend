using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Xml.Serialization;
using AutoMapper;
using backend.BusinessLayer.Contracts.Configuration;
using backend.DataLayer.Helpers;
using backend.DataLayer.Models.Configuration;
using backend.DataLayer.Repository.Extensions;
using backend.DataLayer.UnitOfWork.Contracts;
using backend.Logging.Contracts;
using backend.Mappers.DataTransferObjects.Configuration;
using backend.Mappers.DataTransferObjects.Generic;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace backend.BusinessLayer.Services.Configurations
{
    public class TriggerConfigurationService : ITriggerConfigurationService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private ILoggerManager _logger;
        public TriggerConfigurationService(IUnitOfWork unitOfWork, IMapper mapper, ILoggerManager logger)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _logger = logger;
        }

        /// <summary>
        /// Gte all the trigger data under <trigger_defs> tag
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>
        public async Task<IEnumerable<Trigger>> GetAllTriggers(int configurationId)
        {
            using var context = _unitOfWork.Create;            
            var triggers = await context.Repositories.TriggerConfigurationRepository.GetAllTriggers(configurationId);
            var alltriggerParams = await GetAllTriggerParameters(configurationId);
            //build paramters from trigger condition.
            var allTriggerOperators = TriggerDataBuilder.TriggerOperators();
            List<string> logicalOperators = new List<string> { "or", "OR", "and", "AND", "not", "NOT" };
            foreach (var trigger in triggers)
            {
                string input = trigger.Condition;
                if (input == "")
                {
                    continue;
                }
                //split the condition on " "
                //this should convert the condition into array of (,), logical operators and sub conditions.
                //build the trigger parameter object from the sub condition.
                List<object> parameters = new List<object>();
                var alltokens = trigger.Condition.Split(" ");
                var inpuString = input;
                var removedIndex = -1;
                foreach (var token in alltokens.Select((value, i) => new { i, value }))
                {
                    inpuString = inpuString.Trim();
                    //skip the processed tokens
                    if (token.value == "" || token.i < removedIndex)
                    {
                        continue;
                    }
                    //add parantheses seperatly to the list as it can be moved independently from the UI
                    if (token.value.Contains("("))
                    {
                        parameters.Add("(");
                        StringBuilder sb = new StringBuilder(inpuString);
                        sb.Remove(0, 1);
                        removedIndex = token.i;
                        inpuString = sb.ToString();
                    }
                    else if (token.value.Contains(")"))
                    {
                        parameters.Add(")");
                        StringBuilder sb = new StringBuilder(inpuString);
                        sb.Remove(0, 1);
                        removedIndex = token.i;
                        inpuString = sb.ToString();
                    }
                    else if(logicalOperators.Contains(token.value))
                    {
                        parameters.Add(token.value);
                        StringBuilder sb = new StringBuilder(inpuString);
                        sb.Remove(0, token.value.Length);
                        removedIndex = token.i;
                        inpuString = sb.ToString();
                    }
                    else
                    {
                        var paramString = inpuString.Split(")").First();
                        if(paramString.Equals(inpuString) || (logicalOperators.Where(op => paramString.Contains(op)).Count() == 1) )
                        {
                            string pattern1 = @" (or) | (OR) | (and) | (AND) | (not) | (NOT)";
                            paramString = Regex.Split(inpuString, pattern1).First();
                        }
                        //For the sub condition build the TriggerParameter object
                        //for operator and FieldValue populate the display name from the Name-Display Name mapping.
                        var parameterCondition = paramString.Trim();
                        var splitCondition = parameterCondition.Split(" ");
                        var paramName = splitCondition.First();
                        var result = alltriggerParams.Where(param => param.Name.ToLower().Equals(paramName.ToLower())).First();
                        var triggerParam = new TriggerParameter(result);
                        if (splitCondition.Count() > 2)
                        {
                            triggerParam.Operator = allTriggerOperators.Where(op => op.Name.ToLower().Equals(splitCondition[1].ToLower())).First().DisplayName;
                            triggerParam.EditorFieldValue = TriggerEditorFieldValueFor(triggerParam, splitCondition[2]);
                        }
                        else
                        {
                            triggerParam.EditorFieldValue = TriggerEditorFieldValueFor(triggerParam, splitCondition[1]);
                        }
                        StringBuilder sb = new StringBuilder(inpuString);
                        sb.Remove(0, paramString.Length);
                        inpuString = sb.ToString();
                        removedIndex = token.i+splitCondition.Count();
                        parameters.Add(triggerParam);
                    }
                }

                trigger.parameters = parameters;
            }
            return triggers;
        }

        private string TriggerEditorFieldValueFor(TriggerParameter parameter, string value)
        {
            switch(parameter.EditorFieldValue)
            {
                case "flightphase":
                    return TriggerDataBuilder.TriggerFlightphases().Where(element => element.Name.ToLower().Equals(value.ToLower())).First().DisplayName;
                case "day_of_week":
                    return TriggerDataBuilder.TriggerDayofWeeks().Where(element => element.Name.ToLower().Equals(value.ToLower())).First().DisplayName;
                case "miqat_phases":
                    return TriggerDataBuilder.TriggerMiqatphases().Where(element => element.Name.ToLower().Equals(value.ToLower())).First().DisplayName;
                case "aircraft_types":
                    return TriggerDataBuilder.TriggerAircraftTypes().Where(element => element.Name.ToLower().Equals(value.ToLower())).First().DisplayName;
                case "boolean":
                    return TriggerDataBuilder.Boolean().Where(element => element.Name.ToLower().Equals(value.ToLower())).First().DisplayName; ;
                default:
                    return value;
            }
        }

        /// <summary>
        /// If the mapping with guven configuration id is not present, insert new Trigger and create a mapping.
        /// else check if the trigger item is alreday present and add the new trigger
        /// 
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="triggerData"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> AddTrigger(int configurationId, Trigger triggerData)
        {

            using var context = _unitOfWork.Create;
            var validateResult = ValidateTrigger(triggerData);
            if (validateResult.IsError == true)
            {
                return new DataCreationResultDTO { IsError = true, Message = "Trigger Condition is not Valid. " + validateResult.Message };

            }
            triggerData.Condition = BuildTriggerCondition(triggerData).Message;
            var insertResult = await context.Repositories.TriggerConfigurationRepository.AddTriggerItem(configurationId, triggerData);

            if (insertResult > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "New Trigger has been added" };
            }

            return new DataCreationResultDTO { IsError = true, Message = "Error adding new Trigger" };

        }

        /// <summary>
        /// Delete trigger with given trigger id
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="triggerId"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> RemoveTrigger(int configurationId, string triggerId)
        {
            using var context = _unitOfWork.Create;
            var result = await context.Repositories.TriggerConfigurationRepository.RemoveTrigger(configurationId, triggerId);
            if (result > 0)
            {
                await context.SaveChanges();
                return new DataCreationResultDTO { IsError = false, Message = "Trigger has been Deleted" };

            }
            return new DataCreationResultDTO { IsError = true, Message = "Error Deleting Trigger" };
        }

        /// <summary>
        /// Update trigger with given trigger data.
        /// As the trigger item order does not matter, removing the existing trigger and inserting the new item.
        /// Also, returns error if the trigger with the given id is not present
        /// </summary>
        /// <param name="configurationId"></param>
        /// <param name="triggerData"></param>
        /// <returns></returns>
        public async Task<DataCreationResultDTO> UpdateTrigger(int configurationId, Trigger triggerData)
        {
            using var context = _unitOfWork.Create;
            var validateResult = ValidateTrigger(triggerData);
            if (validateResult.IsError == true)
            {
                return new DataCreationResultDTO { IsError = true, Message = "Trigger Condition is not Valid " + validateResult.Message };

            }
            triggerData.Condition = BuildTriggerCondition(triggerData).Message;
            var trigger = await context.Repositories.TriggerConfigurationRepository.GetTrigger(configurationId, triggerData.Id);
            if (trigger.Count() == 0)
            {
                return new DataCreationResultDTO { IsError = true, Message = "Error Updating Trigger. Trigger not found!" };
            } else
            {
                var existingTrigger = trigger.First();
                var removeResult = await context.Repositories.TriggerConfigurationRepository.RemoveTrigger(configurationId, existingTrigger.Id);
                if ( removeResult > 0)
                {
                    var updateResult = await context.Repositories.TriggerConfigurationRepository.AddTriggerItem(configurationId, triggerData);
                    if(updateResult > 0)
                    {
                        await context.SaveChanges();
                        return new DataCreationResultDTO { IsError = false, Message = "Trigger has been Updated" };
                    }
                }

                return new DataCreationResultDTO { IsError = true, Message = "Error Updating Trigger." };
            }

        }

        /// <summary>
        /// returns the list of all the available trigger parameters that can be selected
        /// Each trigger parameter will have allowed operators, allowed values, format and type details.
        /// </summary>
        /// <param name="configurationId"></param>
        /// <returns></returns>

        public virtual async Task<IEnumerable<TriggerParameter>> GetAllTriggerParameters(int configurationId)
        {
            using var context = _unitOfWork.Create;
            var iataList = await context.Repositories.AirportInfo.GetIATAList(configurationId);
            var icaoList = await context.Repositories.AirportInfo.GetICAOList(configurationId);

            return TriggerDataBuilder.loadTriggerData(iataList, icaoList);
        }


        /// <summary>
        /// Validates the given trigger data. Data will be present in the parameters object of the Triggerdata.
        /// Validation Conditions are :
        /// 1.empty parentheses, open and close parenthese with nothing in between
        /// 2.non-matched open or close parentheses
        /// 3.Logical operator not followed by a parameter or open parentheses
        /// 4.parameters without a operator in between
        /// 5.invalid values for a parameter type - Valid values are taken from TriggerdataBuilder Json data.
        ///    
        /// </summary>
        /// <param name="triggerData"></param>
        /// <returns></returns>
        /// 
        public DataCreationResultDTO ValidateTrigger(Trigger triggerData)
        {
            var result = new DataCreationResultDTO();

            List<string> logicalOperators = new List<string> { "or", "OR", "and", "AND", "not", "NOT" };

            //validate logical operator not
            if (logicalOperators.Contains(triggerData.parameters[0].ToString()))
            {
                if(!triggerData.parameters[0].ToString().ToLower().Equals("not"))
                {
                    result.IsError = true;
                    result.Message = triggerData.parameters[0].ToString() + " should be followed by a parameter";
                    return result;
                }
               
            }

            //validate for empty parentheses, open and close parenthese with nothing in between
            var openParenthesesIndices = Enumerable.Range(0, triggerData.parameters.Count()).Where(i => triggerData.parameters[i].ToString().Equals("(")).ToArray();
            var closeParenthesesIndices = Enumerable.Range(0, triggerData.parameters.Count()).Where(i => triggerData.parameters[i].ToString().Equals(")")).ToArray();
            foreach(var index in openParenthesesIndices)
            {
                if(closeParenthesesIndices.Contains(index+1))
                {
                    result.IsError = true;
                    result.Message = "Empty Parentheses without any parameter found in the condition!";
                    return result;
                }
            }

            //validate for non-matched open or close parentheses
            if(openParenthesesIndices.Count() != closeParenthesesIndices.Count())
            {
                result.IsError = true;
                result.Message = "Number of ( does not match number of ) in the condition!";
                return result;
            }
   

            //validate for Logical operator item not followed by a parameter or open parentheses
            ValidateDanglingOperator(triggerData, "AND", result);
            if (result.IsError == true)
            {
                return result;
            }
            ValidateDanglingOperator(triggerData, "OR", result);
            if (result.IsError == true)
            {
                return result;
            }
            ValidateDanglingOperator(triggerData, "NOT", result);
            if (result.IsError == true)
            {
                return result;
            }


            //validate for parameters without a operator in between
            foreach (var it in triggerData.parameters.Select((x, i) => new { Value = x, Index = i }))
            {
                if(it.Index < triggerData.parameters.Count() - 1)
                {
                    if (it.Value.ToString().ToLower().Contains("name") && triggerData.parameters[it.Index + 1].ToString().ToLower().Contains("name"))
                    {
                        var parameterOject = JsonConvert.DeserializeObject<TriggerParameter>(it.Value.ToString());
                        var parameterOject1 = JsonConvert.DeserializeObject<TriggerParameter>(triggerData.parameters[it.Index + 1].ToString());
                        result.IsError = true;
                        result.Message = "No logical Operator found between !" + parameterOject.DisplayName +" and "+ parameterOject1.DisplayName;
                        return result;
                    } else if(it.Value.ToString().Equals(")") && triggerData.parameters[it.Index + 1].ToString().Equals("("))
                    {
                        result.IsError = true;
                        result.Message = "No logical Operator found between ) and ( ";
                        return result;
                    }

                }
            }

            //validate for invalid values for a parameter type
            foreach (var parameter in triggerData.parameters)
            {
                if (parameter.ToString().ToLower().Contains("name"))
                {
                    //validate for empty value
                    var parameterOject = JsonConvert.DeserializeObject<TriggerParameter>(parameter.ToString());
                    if (parameterOject.EditorFieldValue == "" || parameterOject.EditorFieldValue == null)
                    {
                        result.IsError = true;
                        result.Message = parameterOject.DisplayName+ " value can not be null or empty!";
                        return result;
                    }
                    //validate for empty operator

                    if (parameterOject.Operator == "" || parameterOject.Operator == null)
                    {
                        result.IsError = true;
                        result.Message = parameterOject.DisplayName + " operator can not be null or empty!";
                        return result;
                    }
                    //validate for given format

                    var regexFormat = "";
                    if(parameterOject.EditorFieldFormat != null && !parameterOject.EditorFieldFormat.Equals("none"))
                    {
                        switch (parameterOject.EditorFieldFormat)
                        {
                            case "HHMMSS":
                                regexFormat = "([01][0-9]|2[0-3])[0-5][0-9][0-5][0-9]";
                                break;
                            case "HH":
                                regexFormat = "([01][0-9]|2[0-3])";
                                break;
                            case "YYMMDD":
                                regexFormat = "^([0-9][0-9])(0?[1-9]|1[012])(0?[1-9]|[12][0-9]|3[01])$";
                                break;
                            case "MMDD":
                                regexFormat = "^(0?[1-9]|1[012])(0?[1-9]|[12][0-9]|3[01])$";
                                break;
                            case "YYMM":
                                regexFormat = "^([0-9][0-9])(0?[1-9]|1[012])$";
                                break;
                            default:
                                break;

                        }
                        ValidateForFormat(parameterOject, regexFormat, result);
                        if(result.IsError == true)
                        {
                            return result;
                        }

                    }

                    //validate for allowed values

                    if (parameterOject.EditorFieldType != null && parameterOject.EditorFieldType.Equals("popup"))
                    {
                        switch (parameterOject.DisplayName)
                        {
                            case "Flight Phase":
                                var flightphase = TriggerDataBuilder.TriggerFlightphases().Where(element => element.DisplayName.Equals(parameterOject.EditorFieldValue));
                                if (flightphase.Count() == 0)
                                {

                                    result.IsError = true;
                                    result.Message = "Invalid flight phase value!";
                                }
                                break;
                            case "Day of Week":
                                var dayofweek = TriggerDataBuilder.TriggerDayofWeeks().Where(element => element.DisplayName.Equals(parameterOject.EditorFieldValue));
                                if (dayofweek.Count() == 0)
                                {

                                    result.IsError = true;
                                    result.Message = "Invalid Day of week value!";
                                }
                                break;
                            case "Miqat Phase":
                                var miqatFlightPhase = TriggerDataBuilder.TriggerMiqatphases().Where(element => element.DisplayName.Equals(parameterOject.EditorFieldValue));
                                if (miqatFlightPhase.Count() == 0)
                                {

                                    result.IsError = true;
                                    result.Message = "Invalid Miqat phase value!";
                                }
                                break;
                            case "Aircraft Type":
                                var aircrafttypes = TriggerDataBuilder.TriggerAircraftTypes().Where(element => element.DisplayName.Equals(parameterOject.EditorFieldValue));
                                if (aircrafttypes.Count() == 0)
                                {

                                    result.IsError = true;
                                    result.Message = "Invalid Aircraft type value!";
                                }
                                break;
                            case "Personality":
                                var personality = TriggerDataBuilder.TriggerPersonalities().Where(element => element.DisplayName.Equals(parameterOject.EditorFieldValue));
                                if (personality.Count() == 0)
                                {

                                    result.IsError = true;
                                    result.Message = "Invalid Personality value!";
                                }
                                break;

                            case "ACARS Present":
                                var acarsPresent = TriggerDataBuilder.Boolean().Where(element => element.DisplayName.Equals(parameterOject.EditorFieldValue));
                                if (acarsPresent.Count() == 0)
                                {
                                    result.IsError = true;
                                    result.Message = "Acars Present should be a boolean value!";
                                }
                                break;
                            case "Manual Trigger":
                                var manualtrigger = TriggerDataBuilder.Boolean().Where(element => element.DisplayName.Equals(parameterOject.EditorFieldValue));
                                if (manualtrigger.Count() == 0)
                                {

                                    result.IsError = true;
                                    result.Message = "Manual Trigger should be a boolean value!";
                                }
                                break;

                        }
                        if (result.IsError == true)
                        {
                            return result;
                        }
                    }
                    if (parameterOject.EditorFieldType != null && parameterOject.EditorFieldType.Equals("text-popup"))
                    {
                        if(parameterOject.DisplayName.Contains("IATA"))
                        {
                            if (!parameterOject.IATAList.Contains(parameterOject.EditorFieldValue))
                            {
                                result.IsError = true;
                                result.Message = parameterOject.EditorFieldValue +" is not a valid IATA value!";
                            }
                        } else if(parameterOject.DisplayName.Contains("ICAO"))
                        {
                            if (!parameterOject.ICAOList.Contains(parameterOject.EditorFieldValue))
                            {
                                result.IsError = true;
                                result.Message = parameterOject.EditorFieldValue + " is not a valid ICAO value!";
                            }
                        }
                        if (result.IsError == true)
                        {
                            return result;
                        }
                    }
                }         
            }
            
            return result;
        }

        private void ValidateForFormat(TriggerParameter parameter, string format, DataCreationResultDTO result)
        {
            if (!Regex.IsMatch(parameter.EditorFieldValue, format))
            {
                result.IsError = true;
                result.Message = parameter.DisplayName +" should be in "+ parameter.EditorFieldFormat+" format!";
            }
        }

        private void ValidateDanglingOperator(Trigger triggerData, string operatorName, DataCreationResultDTO result)
        {
            var indices = new List<int>();
            List<string> logicalOperators = new List<string> { "or", "OR", "and", "AND", "not", "NOT" };
            if (logicalOperators.Contains(operatorName))
            {
                indices = Enumerable.Range(0, triggerData.parameters.Count()).Where(i => triggerData.parameters[i].ToString().ToLower().Equals(operatorName.ToLower())).ToList();
            }
            else
            {
                result.IsError = true;
                result.Message = "Invalid logical operator in the condition!";
            }
            foreach (var index in indices)
            {
                if ((index + 1) >= triggerData.parameters.Count())
                {
                    result.IsError = true;
                    result.Message = operatorName+" item not followed by a parameter or open parentheses in the condition!";
                }
                else if (triggerData.parameters[index + 1].GetType() == typeof(JsonElement))
                {
                    var data = triggerData.parameters[index + 1].ToString();
                    if (!data.Equals("(") && !data.ToLower().Contains("name") && !data.ToLower().Equals("not"))
                    {
                        result.IsError = true;
                        result.Message = operatorName+" item not followed by a parameter or open parentheses in the condition!";
                    }
                }
            }

        }

        /// <summary>
        /// returns condition string from given triggerdata
        /// Processes each parameter of triggerdata.parameters to convert it into Condition to display on the UI
        /// The same conditon string is further stored in the database
        /// </summary>
        /// <param name="triggerData"></param>
        /// <returns></returns>
        /// 
        public DataCreationResultDTO BuildTriggerCondition(Trigger triggerData)
        {

            var validateResult = ValidateTrigger(triggerData);
            if (validateResult.IsError == true)
            {
                return new DataCreationResultDTO { IsError = true, Message = "Trigger Condition is not Valid. " + validateResult.Message };

            }

            string condition = "";
           foreach(var parameter in triggerData.parameters)
            {
                if (!parameter.ToString().ToLower().Contains("name"))
                {
                    condition = condition + parameter.ToString() + " " ;
                } else
                {
                    var parameterOject = JsonConvert.DeserializeObject<TriggerParameter>(parameter.ToString());
                    condition = condition + parameterOject.Name + " ";

                    if(parameterOject.Operator != null && !parameterOject.Operator.ToString().Equals("none"))
                    {
                        var operatorName = TriggerDataBuilder.TriggerOperators().Where(op => op.DisplayName.Equals(parameterOject.Operator.ToString())).First().Name;
                        condition = condition + operatorName + " ";
                    }

                    if (parameterOject.EditorFieldType.Equals("popup"))
                    {
                        switch (parameterOject.DisplayName)
                        {
                            case "Flight Phase":
                                var flightphase = TriggerDataBuilder.TriggerFlightphases().Where(element => element.DisplayName.Equals(parameterOject.EditorFieldValue)).First();
                                condition = condition + flightphase.Name + " ";

                                break;
                            case "Day of Week":
                                var dayofweek = TriggerDataBuilder.TriggerDayofWeeks().Where(element => element.DisplayName.Equals(parameterOject.EditorFieldValue)).First();
                                condition = condition + dayofweek.Name + " ";

                                break;
                            case "Miqat Phase":
                                var miqatFlightPhase = TriggerDataBuilder.TriggerMiqatphases().Where(element => element.DisplayName.Equals(parameterOject.EditorFieldValue)).First();
                                condition = condition + miqatFlightPhase.Name + " ";

                                break;
                            case "Aircraft Type":
                                var aircrafttypes = TriggerDataBuilder.TriggerAircraftTypes().Where(element => element.DisplayName.Equals(parameterOject.EditorFieldValue)).First();
                                condition = condition + aircrafttypes.Name + " ";

                                break;
                            case "Personality":
                                var personality = TriggerDataBuilder.TriggerPersonalities().Where(element => element.DisplayName.Equals(parameterOject.EditorFieldValue)).First();
                                condition = condition + personality.Name + " ";
                                break;

                            case "ACARS Present":
                                var acarsPresent = TriggerDataBuilder.Boolean().Where(element => element.DisplayName.Equals(parameterOject.EditorFieldValue)).First();
                                condition = condition + acarsPresent.Name + " ";

                                break;
                            case "Manual Trigger":
                                var manualtrigger = TriggerDataBuilder.Boolean().Where(element => element.DisplayName.Equals(parameterOject.EditorFieldValue)).First();
                                condition = condition + manualtrigger.Name + " ";

                                break;

                        }
                    } else
                    {
                        condition = condition + parameterOject.EditorFieldValue + " ";

                    }

                }
            }
            return new DataCreationResultDTO() { IsError = false, Message = condition};
        }
    }
}
