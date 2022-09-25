-- SET FOREIGN_KEY_CHECKS = 0;
-- SET GLOBAL default_password_lifetime = 0;
-- mysqldump -u [user name] –p [password] [options] [database_name] [tablename] > [dumpfilename.sql]
SET @userName = (SELECT SUBSTR(USER(), 1, LOCATE('@', USER())-1));
SET @binPath  = (SELECT CONCAT(@@basedir,'bin'));
SET SESSION group_concat_max_len = 65535;

SET @cmd1 = (SELECT CONCAT('mysqldump -u', @userName, ' --port=', @@port, ' --force -d -R -E',' --databases ', GROUP_CONCAT(schema_name SEPARATOR ' '), ' > ', 'DB_SCHEMA.sql\r\n') AS `MySQL_INFO`
FROM `information_schema`.schemata
WHERE `schema_name` NOT IN('sys','mysql','information_schema','performance_schema','phpmyadmin'));

SET @cmd2 = (SELECT GROUP_CONCAT(CONCAT('mysqldump -u', @userName, ' --port=', @@port, ' --single-transaction --force --quick -t -e -K ', schema_name, ' > ', schema_name, '.sql') SEPARATOR '\r\n') AS `MySQL_DATA`
FROM information_schema.schemata
WHERE schema_name NOT IN('sys','mysql','information_schema','performance_schema','phpmyadmin'));

SET @cmd3 = (SELECT CONCAT('mysql -u', @userName, ' --port=', @@port, ' --force ', ' < ', 'DB_SCHEMA.sql\r\n'));
SET @cmd4 = (SELECT GROUP_CONCAT(CONCAT('mysql -u', @userName, ' --port=', @@port, ' --force --quick --database=', SCHEMA_NAME, ' < ', schema_name, '.sql') SEPARATOR '\r\n') AS `MySQL_DATA`
FROM information_schema.schemata
WHERE schema_name NOT IN('sys','mysql','information_schema','performance_schema','phpmyadmin'));


-- Windows Batch Script
SELECT CONCAT(
	'@ECHO OFF\r\nTITLE Database(s) Backup\r\n',
	':: Windows Envirionment\r\nSET PATH=%SystemRoot%\\System32;%SystemRoot%;',@binPath,';%~dp0;%ProgramFiles%\\WinRAR\r\n'
	'CLS\r\n', @cmd1,
	'\r\n::Dumping database(s)\r\n', @cmd2, '\r\n\r\n::Finished all the required','\r\n::winrar.exe a -df -afzip -agYYYYMMDD "db-" *.sql'
) AS `mysql_dump.bat`,
	CONCAT(
	'@ECHO OFF\r\nTITLE Database(s) Restore\r\n',
	':: Windows Envirionment\r\nSET PATH=%SystemRoot%\\System32;%SystemRoot%;',@binPath,';%~dp0;%ProgramFiles%\\WinRAR\r\n'
	'CLS\r\nREM ', @cmd3,
	'\r\n::Dumping database(s)\r\n',  @cmd4, '\r\n\r\n::Finished all the required'
) AS `mysql_restore.bat`;


-- Preview
SELECT @cmd1 AS `SCHEMA Only`, @cmd2 AS `DATA Only`;
