using System;
namespace backend.DataLayer.Repository.SqlServer.Queries
{
    public class QueryModeConfiguration
    {

        public static string SQL_GetAllModes = @"SELECT DISTINCT 
                ModesResult.ModeName as Name,
                ModesResult.ModeId as Id,
                ScriptIdLookup.ScriptName as ScriptName,
                ScriptIdLookup.ScriptId as ScriptId

                FROM

                (SELECT 
                isnull(Nodes.Mode.value('(./@name)[1]', 'varchar(max)'),'') as ModeName,
                isnull(Nodes.Mode.value('(./@id)[1]', 'varchar(max)'),'') as ModeId,
                isnull(Nodes.Mode.value('(./mode_item/@scriptidref)[1]', 'varchar(max)'),'') as ScriptId
                FROM cust.tblModeDefs as Modes
                cross apply Modes.ModeDefs.nodes('/mode_defs/mode') as Nodes(Mode)
                INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID
                AND cust.tblModeDefsMap.ConfigurationID = @configurationId)

                as ModesResult

                LEFT OUTER JOIN(
                   SELECT
                isnull(Nodes.Script.value('(./@name)[1]', 'varchar(max)'),'') as ScriptName,
                isnull(Nodes.Script.value('(./@id)[1]', 'varchar(max)'),'') as ScriptId
                FROM cust.tblScriptDefs as Scripts
                cross apply Scripts.ScriptDefs.nodes('/script_defs/script') as Nodes(Script)
                INNER JOIN cust.tblScriptDefsMap ON cust.tblScriptDefsMap.ScriptDefID = Scripts.ScriptDefID
                AND cust.tblScriptDefsMap.ConfigurationID = @configurationId
                )

                as ScriptIdLookup ON ScriptIdLookup.ScriptId = ModesResult.ScriptId";

        public static string SQL_GetMode(string modeId)
        {
            var sqlQuery = "SELECT DISTINCT " +
                " ModesResult.ModeName as Name, " +
                " ModesResult.ModeId as Id, " +
                " ScriptIdLookup.ScriptName as ScriptName, " +
                " ScriptIdLookup.ScriptId as ScriptId " +

                " FROM " +

                " (SELECT  " +
                " isnull(Nodes.Mode.value('(./@name)[1]', 'varchar(max)'),'') as ModeName, " +
                " isnull(Nodes.Mode.value('(./@id)[1]', 'varchar(max)'),'') as ModeId, " +
                " isnull(Nodes.Mode.value('(./mode_item/@scriptidref)[1]', 'varchar(max)'),'') as ScriptId " +
                " FROM cust.tblModeDefs as Modes " +
                " cross apply Modes.ModeDefs.nodes('/mode_defs/mode[@id = " + modeId + " ]') as Nodes(Mode) " +
                " INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID " +
                " AND cust.tblModeDefsMap.ConfigurationID = @configurationId) " +

                " as ModesResult " +

                " LEFT OUTER JOIN(" +
                "    SELECT " +
                " isnull(Nodes.Script.value('(./@name)[1]', 'varchar(max)'),'') as ScriptName, " +
                " isnull(Nodes.Script.value('(./@id)[1]', 'varchar(max)'),'') as ScriptId " +
                " FROM cust.tblScriptDefs as Scripts " +
                " cross apply Scripts.ScriptDefs.nodes('/script_defs/script') as Nodes(Script)" +
                " INNER JOIN cust.tblScriptDefsMap ON cust.tblScriptDefsMap.ScriptDefID = Scripts.ScriptDefID "+
                " AND cust.tblScriptDefsMap.ConfigurationID = @configurationId "+
                " ) " +

                " as ScriptIdLookup ON ScriptIdLookup.ScriptId = ModesResult.ScriptId";
            return sqlQuery;
        }

        public static string SQL_AddModeItem(string modeNode)
        {
            return "UPDATE cust.tblModeDefs " +
                        "SET ModeDefs.modify(' insert " + modeNode +
                        " into /mode_defs[1]') " +
                        " WHERE cust.tblModeDefs.ModeDefID IN ( " +
                        "SELECT distinct cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap " +
                        "WHERE cust.tblModeDefsMap.ConfigurationID = @configurationId)";
        }

        public static string SQL_AddMode(string modeNode)
        {
            return "UPDATE cust.tblModeDefs " +
                        "SET ModeDefs = '" + modeNode + "' " +
                        " WHERE cust.tblModeDefs.ModeDefID IN ( " +
                        "SELECT distinct cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap " +
                        "WHERE cust.tblModeDefsMap.ConfigurationID = @configurationId)";
        }

        public static string SQL_RemoveMode(string modeId)
        {
            return "UPDATE cust.tblModeDefs " +
                          "  SET ModeDefs.modify('delete /mode_defs/mode[@id = " + modeId + "]') " +
                          " WHERE cust.tblModeDefs.ModeDefID IN ( " +
                          "SELECT distinct cust.tblModeDefsMap.ModeDefID FROM cust.tblModeDefsMap " +
                          "WHERE cust.tblModeDefsMap.ConfigurationID = @configurationId)";
        }


        public static string SQL_GetModeItemCount = @"SELECT
                        Modes.ModeDefs.value('count(/mode_defs/mode)', 'int')
                        FROM cust.tblModeDefs as Modes
                        INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID 
                        AND cust.tblModeDefsMap.ConfigurationID = @configurationId";

        public static string SQL_GetMaxModeId = @"SELECT
                        isnull(Max(Nodes.Mode.value('(./@id)', 'varchar(max)')),'0')
                        FROM cust.tblModeDefs as Modes
                        CROSS APPLY Modes.ModeDefs.nodes('/mode_defs/mode') as Nodes(Mode)
                        INNER JOIN cust.tblModeDefsMap ON cust.tblModeDefsMap.ModeDefID = Modes.ModeDefID 
                        AND cust.tblModeDefsMap.ConfigurationID = @configurationId";
    }
}
