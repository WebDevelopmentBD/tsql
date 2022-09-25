SET @db = DATABASE();

-- Flush whole tables from the database
SET SESSION group_concat_max_len = 65535;
SELECT GROUP_CONCAT(CONCAT('CHECK TABLE ', @db, '.`', `table_name`, '`;') SEPARATOR '\n') AS `T_SQL`
FROM information_schema.tables
WHERE table_schema = @db;

SELECT GROUP_CONCAT(CONCAT('REPAIR TABLE ', @db, '.`', `table_name`, '`;') SEPARATOR '\n') AS `T_SQL`
FROM information_schema.tables
WHERE table_schema = @db;
