SET @tbl_name = '';

SET SESSION group_concat_max_len = 65535;
SET @colwidth = (SELECT MAX(LENGTH(`COLUMN_NAME`))+13 FROM `INFORMATION_SCHEMA`.`COLUMNS`
WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`',''));

SET @_pklist = (SELECT IFNULL(GROUP_CONCAT(CONCAT('`', `COLUMN_NAME`, '` = {$posted->', `COLUMN_NAME`,'}') SEPARATOR ' AND '),'NULL') AS `PK`
FROM `INFORMATION_SCHEMA`.`KEY_COLUMN_USAGE` WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = REPLACE(@tbl_name, '`',''));

SET @tSQL = (SELECT CONCAT('SELECT ',GROUP_CONCAT(CONCAT('`', `COLUMN_NAME`, '`') SEPARATOR ', '),'\nFROM ',CONCAT(DATABASE(),'.',@tbl_name),'\nWHERE {$cond}')
FROM `INFORMATION_SCHEMA`.`COLUMNS` WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`',''));

SET @tHead = (SELECT GROUP_CONCAT(CONCAT('<th scope="col">', UPPER(`COLUMN_NAME`), '</th>') SEPARATOR '\n  ')
FROM `INFORMATION_SCHEMA`.`COLUMNS` WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`',''));

SET @tBody = (SELECT CONCAT('<tr row-id="<?php echo ',@_pklist,';?>">\r\n\t<td class="sni"></td>\r\n', GROUP_CONCAT(CONCAT('\t','<td><?php echo $row->', `COLUMN_NAME`,';?></td>')  SEPARATOR '\r\n'), '\r\n</tr>')
FROM `INFORMATION_SCHEMA`.`COLUMNS` WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`',''));

SET @jsRow = (SELECT GROUP_CONCAT(CONCAT('"<td>"+ row.', `COLUMN_NAME`,' +"</td>"')  SEPARATOR '\n\t  ,')
FROM `INFORMATION_SCHEMA`.`COLUMNS` WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`',''));

SET @_jsPK = (SELECT IFNULL(GROUP_CONCAT(CONCAT('data-', `COLUMN_NAME`, '=\\"row.', `COLUMN_NAME`,'\\"') SEPARATOR ' '),'') AS `PK`
FROM `INFORMATION_SCHEMA`.`KEY_COLUMN_USAGE` WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = REPLACE(@tbl_name, '`',''));


SET @phpCode = (SELECT CONCAT('<?php\n$cond=1;\n$q=$mysqli->query("', @tSQL, '");\nif($q) while($row=$q->fetch_object())\n{\n?>\n'));

-- Generating Textual HTML/PHP Contents
SELECT CONCAT(
	CONCAT('<table class="rowset" border="1" cellpadding="4" cellspacing="0" bgcolor="#FCFCFC" align="center">\n',
	'<thead bgcolor="#EBF1F0"><tr>\n  <th>S/N</th>\n  ',@tHead,'\n</tr></thead>\n'
	),
	CONCAT('<tbody>\n', @phpCode, @tBody, '\n<?php } $q->free();?>\n', '\n</tbody>\n</table>')
) AS HTML_TABLE;

-- Generating Textual HTML/JavaScript Contents
SELECT CONCAT(
	'/*let table = \'<table class="rowset" align="center" cellpadding="4" cellspacing="0" border="1" style="border-collapse:collapse;" bgcolor="#FCFBEB">\'\n  ',
	'+"<thead>"+"<tr>"\n  //+ \'<th scope="col">S/N</th>\'\n  + \'', REPLACE(@tHead, '\n  ','\'\n  + \''), '\'\n  + "</tr></thead>"\n  ',
	'+"<tbody id=\\"', @tbl_name, '\\"></tbody></table>";*/\n\n',
	'let tbody = document.getElementById("', @tbl_name, '") || document.createElement("tbody");\n',
	'let rowset= []; //JSON Callback i.e. fetch("?xhr=banklist").then(resp=>resp.json()).then((json) => { rowset = json.result });\n',
	'rowset.forEach(function( row ){\n\t',
	'tbody.innerHTML += "<tr ', @_jsPK, '>\\n" + Array\n\t(\n\t',
	'  //"<td class=\\"sni\\"></td>",\n\t  ', @jsRow,
	'\n\t).join("\\n") + "</tr>\\n";\n});'
) AS JS_TABLE;

-- Generating Stylesheet
SELECT CONCAT(
  'table.rowset tbody{counter-reset:rowCount;}\n',
  'table.rowset tbody>tr{counter-increment:rowCount;}\n',
  'table.rowset tbody>tr>td:first-child::after{content:counter(rowCount,decimal-leading-zero);}\n',
  'table.rowset tbody>tr:nth-child(even){background-color:rgb(240,240,240);}\n',
  '@media only screen{\n\ttable.rowset{border-collapse:collapse;border-color:#5f9ea0;}\n\ttable.rowset tr>td,table.rowset tr>th{border-color:#5f9ea0;}\n}\n'
) AS CSS;
