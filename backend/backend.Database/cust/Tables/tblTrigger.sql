CREATE TABLE [cust].[tblTrigger]
(
	[TriggerID] int NOT NULL IDENTITY (1, 1),
	[TriggerDefs] xml NULL
)
GO
ALTER TABLE [cust].[tblTrigger] 
 ADD CONSTRAINT [PK_tblTrigger]
	PRIMARY KEY CLUSTERED ([TriggerID] ASC)
GO
EXEC sys.sp_addextendedproperty 'MS_Description', 'triggers are used to describe logic equations that can then be referenced by other systems to control their execution logic.  triggers can currently be associated with autoplay script items to filter them out of the autoplay sequence (the script item only shows up if its associated trigger is "active". Each trigger is defined by a unique id that is referenced elsewhere in the custom.xml file. Name is a description for readability. Type is either "" or "manual" (not used). Condition is the logic equation used for processing (can contain parentheses). The default  attribute describes the default state for the trigger at startup. The following operands can be used within the condition: GE, GT, LE, LT, EQ, NOT, NE, AND, OR   The following values can be referenced within the condition:  GS, ALT, DTD, DFD, TTD, TSD, FLTPHASE, PER, GMT, GMTDATE, DEP, DES, MANTRIG, MIQATPHASE, TYPE, GMTDATERANGE, GMTDWOY, GMTTIMERANGE,     -- DOW, DEST_GROUP, DEPT_GROUP, DEPT_ICAO, DEST_ICAO, ACARSPRESENT, LCLT, PERSONALITY  <trigger_defs>     <trigger id="1" name="Date 20170816 through 20180816" type="" condition="GMTDATE GE 20170816 AND GMTDATE LT 20180816" default="false" />     <trigger id="2" name="Date 20170816 through NA" type="" condition="GMTDATE GE 20170816" default="false" />   </trigger_defs>', 'SCHEMA', 'cust', 'table', 'tblTrigger'