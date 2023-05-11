#
# helper script to generate a sql script that will drop all the ace specific
# tables. some hard-coded logic is in place to drop certain tables before others
# due to foreign key constraints.
#

import time, glob, sys, os, pathlib

if len(sys.argv) < 2:
    print("Usage: generate-drop-ace-tables.py <output filename> <glob pattern> [<glob pattern>]")
    sys.exit(0)

outfilename = sys.argv[1]
maptables = []
datatables = []

#
# these tables don't have a proper table definition in our project so we
# will manually add them to the list to clean up
#
datatables.append('dbo.UserRoleAssignments')
datatables.append('dbo.UserRoleClaims')
datatables.append('dbo.UserRoles')
datatables.append('dbo.UserClaims')
datatables.append('dbo.tblUserRoleAssignments')
datatables.append('dbo.tblUserRoleClaims')
datatables.append('dbo.tblUserRoles')
datatables.append('dbo.tblUserClaims')

#
# these tables need to be deleted before anything else so we'll manually add them to
# the delete list first
#
datatables.append('dbo.tblSubscriptionFeatureAssignment')
datatables.append('dbo.tblAirshowSubscriptionAssignment')
datatables.append('dbo.tblAircraftConfigurationMapping')
datatables.append('dbo.tblFleetConfigurationMapping')
datatables.append('dbo.tblGlobalConfigurationMapping')
datatables.append('dbo.tblPlatformConfigurationMapping')
datatables.append('dbo.tblProductConfigurationMapping')
datatables.append('dbo.tblTaskData')
datatables.append('dbo.tblTasks')
datatables.append('dbo.tblConfigurations')
datatables.append('dbo.tblConfigurationDefinitions')
datatables.append('dbo.tblOutputTypes')
datatables.append('dbo.tblCountrySpelling')
datatables.append('dbo.tblCountry')



with open(outfilename, 'w') as outfile:
    
    for i in range(2, len(sys.argv)):
        
        pattern = sys.argv[i]
        filenames = glob.glob(pattern)

        for fname in filenames:
            print('found: %s' % (fname))
            
            fullPath = os.path.abspath(fname)

            tablename = os.path.basename(fullPath).replace('.sql', '')
            path = pathlib.Path(fullPath)
            schema = os.path.basename(path.parent.parent.absolute())
            fullname = schema + '.' + tablename
            if tablename.endswith('Map'):
                if maptables.count(fullname) == 0:
                    maptables.append(fullname)
            else:
                if datatables.count(fullname) == 0:
                    datatables.append(fullname)


    def build_sql(tablename):
        (schema, table) = tablename.split('.')
        string = 'if (exists(select * from information_schema.tables where table_schema = \'%s\' and table_name = \'%s\'))\n' % (schema, table)
        string += 'begin\n'
        string += '  drop table %s;\n' % (tablename)
        string += 'end\n'

        return string

    for table in maptables:
        sql = build_sql(table)
        outfile.write(sql)

    for table in datatables:
        sql = build_sql(table)
        outfile.write(sql)
