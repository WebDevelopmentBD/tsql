SET @tbl_name = '';

SET SESSION group_concat_max_len = 65535;
SET @_pklist = (SELECT GROUP_CONCAT(CONCAT('`', `COLUMN_NAME`, '` = {$this->', `COLUMN_NAME`,'}') SEPARATOR ' AND ') AS `PK`
FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = @tbl_name);

/**
* PHP Wrapper Class of SQL-ROW
*/
SELECT
	CONCAT(
		'<?php\n/**\n*  Skeleton class object of table: ', @tbl_name,'\n*/',
		'\nclass ', @tbl_name,
		'\n{\n\t/**\n\t*Database Link\n\t*@var dblink\n\t*/\n\tprivate $dblink, $_rowset=array();\n\n',
		'\t/*Public properties*/\n',
		'\tvar ', GROUP_CONCAT(CONCAT('$', `COLUMN_NAME`) SEPARATOR ', '), ';\n\n',
		'\tconst TABLE_NAME = \'', @tbl_name, '\';\n\n',
		'\tfunction __construct($rowset = NULL){\n',
		'\t\t#$arg = func_get_args();\n',
		'\t\tif($rowset) if($rowset) foreach($rowset as $ff => $data){$this->_rowset[]=$ff; $this->{ $ff }=$data;}\n',
		'\t\tif(isset($GLOBALS[\'dblink\'])) $this->dblink = &$GLOBALS[\'dblink\'];\n',
		'\t\telseif(isset($GLOBALS[\'link\'])) $this->dblink = &$GLOBALS[\'link\'];\n\t}\n\n',
		'\tpublic function setDBlink( &$_link ){ $this->dblink = &$_link; }\n\n',

		'\tpublic function selfUpdate( $_values=array() ){\n\t\tif(empty( $_values )) return FALSE;\n',
		'\t\treturn $this->dblink->set($_values, \"', @_pklist, '\");\n\t}\n\n',
		'\tpublic function getArray(){\n\t\t$row=array(); foreach($this->_rowset as $ff) $row[ $ff ]=$this->{ $ff }; return $row;\n\t}\n',
		'\tpublic function getFields(){ return $this->_rowset; }\n',
		'\tpublic function getValues(){ $row=array(); foreach($this->_rowset as $ff) $row[]=$this->{ $ff }; return $row; }\n',
		'\tpublic function getName(){ return self::TABLE_NAME; }\n',


		'\n\t/** HTML tools **/\n',

		'\tpublic function getTableRow(){ return \"<tr>\\n\" . $this->getTableCell() . \"</tr>\\n\"; }\n',
		'\tpublic function getTableCell( $className=NULL ){\n\t\treturn \"\\t<td>\" . join(\"</td>\\t<td>\", $this->getValues()) . \"</td>\\n\";\n\t}\n',

		'\n\t//garbage-cleanup\n\tfunction __destruct(){}\n\n',
		'\t//getter/setters\n',
		'\tfunction __get( $_key ){ return NULL; }\n',
		'\tfunction __set( $_key, $_value ){}\n\n',
		'\tprivate function logger( $msg ){\n',
		'\t\terror_log(__CLASS__.sprintf(\' %s\',$msg));\n\t\treturn FALSE;\n\t}\n',

		'  //End of class \"',@tbl_name,'\"\n}'
	) AS `PHP_CLASS`,

	CONCAT('/*', GROUP_CONCAT(CONCAT('\r\n\t$row->', `COLUMN_NAME`)), '\r\n*/') AS `ROW_OBJECT`
--	CONCAT('<tr>\r\n', GROUP_CONCAT(CONCAT('\t','<td><?php echo $row->', `COLUMN_NAME`,';?></td>')  SEPARATOR '\r\n'), '\r\n</tr>') AS `HTML`

FROM `INFORMATION_SCHEMA`.`COLUMNS`
WHERE `TABLE_SCHEMA`=DATABASE() AND `TABLE_NAME`=REPLACE(@tbl_name, '`','');
