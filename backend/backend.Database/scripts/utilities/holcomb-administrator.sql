declare @userid uniqueidentifier = (select id from aspnetusers where username = 'katherine.holcomb');
declare @roleid uniqueidentifier = (select id from userroles where name = 'Engineering Administrator');

insert into userroleassignments (id, userid, roleid)  values ('6dc10c18-83d3-4d39-b0b9-63183871f4c3', @userid, @roleid);