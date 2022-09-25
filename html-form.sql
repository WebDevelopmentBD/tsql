SET @tbl_name = '';

SET SESSION group_concat_max_len = 65535;
SET @_pklist = (SELECT IFNULL(GROUP_CONCAT(CONCAT('`', `COLUMN_NAME`, '` = {$posted->', `COLUMN_NAME`,'}') SEPARATOR ' AND '),'NULL') AS `PK`
FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @tbl_name);
SET @_hidden = (SELECT GROUP_CONCAT(
	CONCAT('\t<input name="', `COLUMN_NAME`, '" value="" type="hidden" disabled="" />'
) SEPARATOR '\r\n') AS `hidden`
FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @tbl_name);


-- Generating Stylesheet
SET @formId = (SELECT CONCAT('form#', @tbl_name));
SET @_Styles = (SELECT CONCAT(
  '<style type="text/css">\n',
  'table.ui-inputset tr > td:nth-child(1),\ntable.ui-inputset tr > td:nth-child(3){vertical-align:top;}\n',
  'table.ui-inputset tr > td:nth-child(2)::before,\ntable.ui-inputset tr > td:nth-child(4)::before{content:":";vertical-align:top;color:rgb(110,110,110);}\n',
  'table.ui-inputset tr > td:nth-child(3){padding-left:1em;}\n',
 @formId, ' > fieldset{margin-bottom:4px;background-color:#f2f0de;box-shadow:-1px 1px 2px #8c867d;}\n',
 @formId, ' button,\n', @formId, ' input[type="submit"],\n', @formId, ' input[type="button"]{cursor:pointer;}\n',
  '</style>' 
));

-- Generating Textual Contents
SELECT
	CONCAT(
	'<form id="',@tbl_name,'" action="" method="post">\r\n', @_hidden, '\r\n',
	'\t<fieldset style="max-width:800px;margin-left:auto;margin-right:auto;"><legend>Add/Edit</legend>\r\n\t<table cellspacing="0" cellpadding="1" class="ui-inputset" align="center">\r\n', GROUP_CONCAT(CONCAT('\t','<tr><td><label>', UPPER(REPLACE(`COLUMN_NAME`,'_',' ')), '</label></td><td><input name="', `COLUMN_NAME`,'" value="" type="text" /></td></tr>')  SEPARATOR '\r\n'), '\r\n\t</table></fieldset>\r\n\t<div align="center"><button type="submit" style="font-size:large;padding-left:1.5em;padding-right:1.5em;">Save</button><button type="reset" onClick="self.close()" style="margin-left:2.5em;">Cancel</button></div>\r\n</form>') AS `HTML_FORM`,
	@_pklist AS `SQL_UPDATE`, @_Styles AS 'CSS_Stylesheet',

	CONCAT(
	'$("<form />", {"id": "',@tbl_name,'", "class": "ui-form", "method":"POST", "action":"javascript:void(0);"})\n.append(\'', @_hidden, '\')\n.append(function(i, html){\n',
	'  let fields=$("<fieldset />", {"style": "max-width:800px;margin-left:auto;margin-right:auto;"}).append("<legend>Add/Edit</legend>");\n',
	'  $("<table />", {"cellspacing": 0, "cellpadding":2, "class":"ui-inputset", "align":"center"})\n',
	'  .append([\n  ',
		GROUP_CONCAT(CONCAT('\'<tr>\'+\'<td><label>', UPPER(REPLACE(`COLUMN_NAME`,'_',' ')), '</label></td>\'+\'<td><input name="', `COLUMN_NAME`,'" value="" type="text" /></td>\'+\'</tr>\'')  SEPARATOR '\n  ,')
		,'\n  ]).appendTo(fields); return fields;\n}).submit(function(ev){\n  let fd = new FormData( ev.target );\n  //ev.preventDefault();\n  return false;\n})//.appendTo(document.body);') AS `jQueryUI_FORM`
FROM `INFORMATION_SCHEMA`.`COLUMNS`
WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`','') AND `COLUMN_NAME` NOT IN(
	SELECT `COLUMN_NAME` FROM information_schema.KEY_COLUMN_USAGE
	WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @tbl_name
);
