using System;
namespace backend.DataLayer.Repository.SqlServer.Queries
{
    public class QueryTriggerConfiguration
    {

        public static string SQL_GetAllTriggers = @"SELECT DISTINCT
                isnull(Nodes.TriggerItem.value('(./@name)[1]', 'varchar(max)'),'') as Name,
                isnull(Nodes.TriggerItem.value('(./@condition)[1]', 'varchar(max)'),'') as Condition,
                isnull(Nodes.TriggerItem.value('(./@id)[1]', 'varchar(max)'),'') as Id,
                isnull(Nodes.TriggerItem.value('(./@type)[1]', 'varchar(max)'),'') as Type,
                isnull(Nodes.TriggerItem.value('(./@default)[1]', 'varchar(max)'),'false') as IsDefault
                FROM cust.tblTrigger as T
                cross apply T.TriggerDefs.nodes('/trigger_defs/trigger') as Nodes(TriggerItem)
                INNER JOIN cust.tblTriggerMap ON cust.tblTriggerMap.TriggerID = T.TriggerID 
                AND cust.tblTriggerMap.ConfigurationID = @configurationId ";
    }
}
