SET @tbl_name = '';
SET @row_id = 'id = 0';

SET SESSION group_concat_max_len = 65535;
SET @colwidth = (SELECT MAX(LENGTH(`COLUMN_NAME`))+13 FROM `INFORMATION_SCHEMA`.`COLUMNS`
WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`',''));

SET @colset = (
	SELECT	GROUP_CONCAT(CONCAT('\`', `COLUMN_NAME`, '\`'))
	FROM `INFORMATION_SCHEMA`.`COLUMNS`
	WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`','')
);

SET @converted = (
	SELECT	GROUP_CONCAT(CONCAT('CAST(\`', `COLUMN_NAME`, '\` AS CHAR)'))
	FROM `INFORMATION_SCHEMA`.`COLUMNS`
	WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`','')
);

SET @_tsql=CONCAT('SET @_rowset = (SELECT CONCAT("\'", CONCAT_WS(\'\\\',\\\'\',', @converted, '), "\'") \nFROM ', @tbl_name, ' WHERE ', @row_id,' LIMIT 1)');
PREPARE stmt_val FROM @_tsql; EXECUTE stmt_val;
DEALLOCATE PREPARE stmt_val;

-- Generating Textual Contents
SELECT
--	@colset AS `COLS`,
	CONCAT('REPLACE INTO `',@tbl_name,'`\n(', GROUP_CONCAT(CONCAT('\`', `COLUMN_NAME`, '\`')), ')\nVALUES\n(', @_rowset, ')') AS `ROW_Migrate`,
	CONCAT('SET @tsql=CONCAT(\'REPLACE INTO `',@tbl_name,'` \',\n\'\\n(', @colset, ') \',\n\'\\nVALUES\\n(\\\'\',\nCONCAT_WS("\',\'",', GROUP_CONCAT(CONCAT('CAST(OLD.\`', `COLUMN_NAME`, '\` AS CHAR)')), '),\n\'\\\')\');') AS `ROW_Trigger`,
	CONCAT('SELECT ',@colset, '\nFROM ', @tbl_name,'\nWHERE 1;') AS `SQL`,
	@_rowset AS `VALUED`
FROM `INFORMATION_SCHEMA`.`COLUMNS`
WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`','');
