SET @tbl_name = '';

SET SESSION group_concat_max_len = 65535;
SET @colwidth = (SELECT MAX(LENGTH(`COLUMN_NAME`))+13 FROM `INFORMATION_SCHEMA`.`COLUMNS`
WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`',''));

-- Generating Textual Contents
SELECT	CONCAT('array(', GROUP_CONCAT(CONCAT('\r\n\t\'', `COLUMN_NAME`, '\'')), '\r\n)') AS `PHP_ARRAY`,
	CONCAT('/*', GROUP_CONCAT(CONCAT('\r\n\t$row->', `COLUMN_NAME`)), '\r\n*/') AS `ROW_OBJECT`,
	CONCAT('array(\r\n\t', GROUP_CONCAT(CONCAT('\'', `COLUMN_NAME`, '\'',LPAD(' => $posted->', @colwidth-LENGTH(`COLUMN_NAME`), ' '), `COLUMN_NAME`) SEPARATOR '\r\n\t,'), '\r\n)') AS `COMBINED`,
	CONCAT('<tr>\r\n', GROUP_CONCAT(CONCAT('\t','<td><?php echo $row->', `COLUMN_NAME`,';?></td>')  SEPARATOR '\r\n'), '\r\n</tr>') AS `HTML`,
	CONCAT('<tr>\r\n', GROUP_CONCAT(CONCAT('\t','<th>', UPPER(`COLUMN_NAME`),'</th>')  SEPARATOR '\r\n'), '\r\n</tr>') AS `THEAD`,
	CONCAT('SELECT ', GROUP_CONCAT(CONCAT('`', `COLUMN_NAME`, '`')), '\nFROM ', @tbl_name) AS `SQL`
FROM `INFORMATION_SCHEMA`.`COLUMNS`
WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`','');
