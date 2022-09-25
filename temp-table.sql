CREATE TEMPORARY TABLE IF NOT EXISTS 
  tmp_table ( INDEX(col_2) ) 
ENGINE=MyISAM 
AS (
  SELECT col_1, coll_2, coll_3
  FROM `table_name`
);
