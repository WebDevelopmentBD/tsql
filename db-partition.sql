SELECT * FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_SCHEMA LIKE DATABASE();

-- Creating Partitions:
ALTER TABLE `table_name`
PARTITION BY RANGE (`status`)
(
 PARTITION p_dead VALUES LESS THAN (1),
 PARTITION p_live VALUES LESS THAN (2),
 PARTITION p_process VALUES LESS THAN (3),
 PARTITION p_done VALUES LESS THAN (4),
 PARTITION p_unknown VALUES LESS THAN MAXVALUE
);

-- Short Syntax
ALTER TABLE `table_name`
  PARTITION BY HASH(`id`)
  PARTITIONS 8;

-- Remove Partitions completely
ALTER TABLE `table_name` REMOVE PARTITIONING;

-- Erase data for specific partition
ALTER TABLE `table_name` TRUNCATE PARTITION p0, p1;

-- Delete Partition Caution: it will destroy data also
ALTER TABLE `table_name` DROP PARTITION p0, p1;
