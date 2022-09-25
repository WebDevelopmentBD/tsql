SET @db = DATABASE();

-- Flush whole tables from the database
SET SESSION group_concat_max_len = 65535;
SELECT GROUP_CONCAT(CONCAT('TRUNCATE TABLE ', @db, '.`', `table_name`, '`;') SEPARATOR '\n') AS `EMPTY_QUERY`,
CONCAT('DROP TABLES IF EXISTS\n', GROUP_CONCAT(CONCAT('\t', @db, '.`', `table_name`, '`') SEPARATOR ',\n'),';\n') AS `DROP_QUERY`
FROM information_schema.tables
WHERE table_schema = @db;
