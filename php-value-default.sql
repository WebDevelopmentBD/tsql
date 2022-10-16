SET @tbl_name = '';

SET SESSION group_concat_max_len = 65535;
SET @colwidth = (SELECT MAX(LENGTH(`COLUMN_NAME`))+4 FROM information_schema.`COLUMNS`
WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`',''));

SET @_pklist = (SELECT IFNULL(GROUP_CONCAT(DISTINCT CONCAT('`', `COLUMN_NAME`, '` = \'{$_GET[\'', `COLUMN_NAME`,'\']}\'') SEPARATOR ' AND '),'1') AS `PK`
FROM `INFORMATION_SCHEMA`.`KEY_COLUMN_USAGE` WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = REPLACE(@tbl_name, '`',''));

START TRANSACTION;
CREATE TEMPORARY TABLE IF NOT EXISTS php_schema AS (
  SELECT `COLUMN_NAME` AS ff, `COLUMN_DEFAULT` AS `fv`, CONCAT(`COLUMN_COMMENT`,' ',`EXTRA`) AS `remarks`, UCASE(`DATA_TYPE`) AS `datatype`, `IS_NULLABLE` AS `allow_null`
  FROM information_schema.`COLUMNS`
  WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`','')
  ORDER BY `COLUMN_KEY` DESC
);

-- Some PHP-Based modifications
UPDATE `php_schema` SET datatype = 'STRING' WHERE datatype IN('VARCHAR','CHAR','TINYTEXT','TEXT','MEDIUMTEXT','LONGTEXT','BINARY','VARBINARY','TINYBLOB','BLOB','MEDIUMBLOB','LONGBLOB','ENUM','SET');
UPDATE `php_schema` SET datatype = 'INT' WHERE datatype IN('TINYINT','SMALLINT','MEDIUMINT','BIGINT', 'BIT','BOOL','BOOLEAN');
UPDATE `php_schema` SET datatype = 'NUMBER' WHERE datatype IN('FLOAT','DOUBLE','DECIMAL', 'DEC');
UPDATE `php_schema` SET fv = 0 WHERE datatype = 'INT' AND fv IS NULL;
UPDATE `php_schema` SET fv = 0.0 WHERE datatype = 'NUMBER' AND fv IS NULL;
UPDATE `php_schema` SET fv = '\'\'' WHERE datatype = 'STRING' AND fv IS NULL;
UPDATE `php_schema` SET fv = 'gmdate(\'Y-m-d H:i:s\')' WHERE datatype = 'TIMESTAMP';
UPDATE `php_schema` SET fv = 'date(\'Y-m-d H:i:s\')' WHERE datatype = 'DATETIME';
UPDATE `php_schema` SET fv = 'date(\'Y-m-d\')' WHERE datatype = 'DATE' AND fv IS NULL;

-- Generating Source Codes
SELECT CONCAT(
  '//Default values of "',@tbl_name,'"\n$record = (object)array(\n\t',
  GROUP_CONCAT(CONCAT('\'', `ff`, '\'',LPAD(' => ', @colwidth-LENGTH(`ff`), ' '), `fv`, '\t  //@', `datatype`, ': ', `remarks`) SEPARATOR '\n\t, '),
  '\n);\n'
) AS `PHP_VALUE`,
CONCAT(
  '//Default values of "',@tbl_name,'"\nlet record = {\n\t',
  GROUP_CONCAT(CONCAT('\'', `ff`, '\'',LPAD(': ', @colwidth-LENGTH(`ff`), ' '), LCASE(`fv`), '\t  //@', `datatype`, ': ', `remarks`) SEPARATOR '\n\t, '),
  '\n};\n'
) AS `JS_VALUE`,
CONCAT(
  '//Existing row\n$record = $link->query("', 'SELECT * FROM ', DATABASE(), '.', @tbl_name, ' WHERE ', @_pklist, '")->fetch_object();'
) AS `MySQLi`
FROM `php_schema`;

SELECT * FROM php_schema;
DROP TEMPORARY TABLE IF EXISTS `php_schema`;

/*
SELECT * FROM information_schema.`COLUMNS`
WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`','');
*/
