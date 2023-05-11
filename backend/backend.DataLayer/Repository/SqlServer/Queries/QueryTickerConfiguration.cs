using System;
namespace backend.DataLayer.Repository.SqlServer.Queries
{
    public class QueryTickerConfiguration
    {
        public static string SQL_GetTicker = @"SELECT 
                isnull(Ticker.value('(/ticker/@position)[1]', 'varchar(max)'),'bottom') as Position, 
                isnull(Ticker.value('(/ticker/@speed)[1]', 'INT'),'0') as Speed, 
                isnull(Ticker.value('(/ticker/@visible)[1]', 'varchar(max)'),'true') as Visible
                FROM cust.tblTicker 
                INNER JOIN cust.tblTickerMap ON cust.tblTickerMap.TickerID = cust.tblTicker.TickerID 
                AND cust.tblTickerMap.ConfigurationID = @configurationId";

        public static string SQL_GetAllTickerParameters = @"SELECT *
                 FROM 
                (SELECT dbo.tblFeatureSet.Value as Name
                FROM dbo.tblFeatureSet
                WHERE dbo.tblFeatureSet.Name = 'ticker-parameters') as NameTable,
                 (SELECT dbo.tblFeatureSet.Value as DisplayName
                FROM dbo.tblFeatureSet
                WHERE dbo.tblFeatureSet.Name = 'ticker-parameters-display') as DisplayNameTable";

        public static string SQL_GetSelectedTickerParameters = @"SELECT "+
                "Nodes.InfoItem.value('(.)[1]','varchar(max)') as Parameter "+
                "FROM "+
                "cust.tblWebMain as WebMain "+
                "cross apply WebMain.InfoItems.nodes('/infoitems/infoitem[@ticker= \"true\"]') as Nodes(InfoItem) "+
                "INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = WebMain.WebMainID "+
                "AND cust.tblWebMainMap.ConfigurationID = @configurationId";

        public static string SQL_IsTickerItemDisabled(string tickerParameterName)
        {
            return "SELECT " +
                "COUNT(*) " +
                "FROM " +
                "cust.tblWebMain as WebMain " +
                "cross apply WebMain.InfoItems.nodes('/infoitems/infoitem') as Nodes(InfoItem)" +
                "INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = WebMain.WebMainID " +
                "AND cust.tblWebMainMap.ConfigurationID = @configurationId AND Nodes.InfoItem.value('(.)[1]', 'varchar(max)') like '%" + tickerParameterName + "%'" +
                "WHERE Nodes.InfoItem.value('(./@ticker)[1]', 'varchar(max)') like '%false%' ";
        }
        public static string SQL_GetTickerAttributeValue(string tickerParameterName)
        {
            return "SELECT "+
                "Nodes.InfoItem.value('(./@ticker)[1]', 'varchar(max)') "+
                "FROM "+
                "cust.tblWebMain as WebMain "+
                "cross apply WebMain.InfoItems.nodes('/infoitems/infoitem') as Nodes(InfoItem) "+
                "INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = WebMain.WebMainID "+
                "AND cust.tblWebMainMap.ConfigurationID =  @configurationId AND Nodes.InfoItem.value('(.)[1]', 'varchar(max)') like '%"+tickerParameterName+"%'";
        }
        
        public static string SQL_AddTickerParameter(string tickerNode)
        {
            return "UPDATE cust.tblWebMain "+
                    "SET InfoItems.modify('insert "+tickerNode+" into /infoitems[1]') " +
                    "WHERE cust.tblWebMain.WebMainID IN( " +
                    "SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap " +
                    "WHERE cust.tblWebMainMap.ConfigurationID = @configurationId) ";
        }

        public static string SQL_RemoveTickerParameter(string tickerParameterName)
        {
            return "UPDATE cust.tblWebMain " +
                 "SET InfoItems.modify('delete /infoitems/infoitem[text()][contains(.,\"" +tickerParameterName +"\")]') " +
                 "WHERE cust.tblWebMain.WebMainID IN( " +
                    "SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap " +
                    "WHERE cust.tblWebMainMap.ConfigurationID = @configurationId " +
                    ") ";
        }

        public static string SQL_GetInfoItemsXML = @"SELECT 
                InfoItems
                FROM cust.tblWebMain
                INNER JOIN cust.tblWebMainMap ON cust.tblWebMainMap.WebMainID = cust.tblWebMain.WebMainID
                AND cust.tblWebMainMap.ConfigurationID = @configurationId ";

        public static string SQL_UpdateInfoItemsXML = @"UPDATE 
                cust.tblWebMain
                SET InfoItems = @xmlValue
                 WHERE cust.tblWebMain.WebMainID IN (
	                SELECT distinct cust.tblWebMainMap.WebMainID FROM cust.tblWebMainMap
	                WHERE cust.tblWebMainMap.ConfigurationID = @configurationId
	                )";
    }



}
