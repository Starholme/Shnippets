--Clean up temp tables if they exist
IF OBJECT_ID('tempdb.dbo.##rowspace', 'U') IS NOT NULL
	DROP TABLE #rowspace;
IF OBJECT_ID('tempdb.dbo.##logspace', 'U') IS NOT NULL
	DROP TABLE #logspace;
IF OBJECT_ID('tempdb.dbo.##backups', 'U') IS NOT NULL
	DROP TABLE #backups;

--Get log file size/usage
CREATE TABLE #logspace
( [dbname] sysname
, logSizeMB float
, logSpaceUsedPct float
, Status int)

INSERT INTO #logspace
EXEC ('DBCC SQLPERF(LOGSPACE);')

--SELECT * FROM #logspace

--Get row file usage
CREATE TABLE #rowspace
	(dbname VARCHAR(255), type_desc VARCHAR(50), physical_name VARCHAR(500) ,size_mb int, growth_mb int, used_mb int, is_percent_growth int)
INSERT INTO #rowspace(dbname, type_desc, physical_name, size_mb, growth_mb, is_percent_growth, used_mb)
	EXEC sp_msforeachdb
'use [?];
SELECT dbname = db_name()
	,type_desc
	,physical_name
	,size * 8 / 1024 AS size_in_mb
	,growth * 8 / 1024 AS growth_in_mb
	,is_percent_growth
	,CASE WHEN TYPE = 0 THEN reservedpages ELSE 0 END AS used_mb
FROM sys.database_files sdf,
	(SELECT 
		reservedpages = sum(a.total_pages) * 8 / 1024
		FROM sys.partitions p
		INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
		LEFT JOIN sys.internal_tables it ON p.object_id = it.object_id) AS p
		'
--SELECT * FROM #rowspace

--Get last backups
SELECT 
    database_name, 
    MAX(backup_finish_date) AS LastBackupDate,
    CASE type 
        WHEN 'D' THEN 'Full' 
        WHEN 'I' THEN 'Differential' 
        WHEN 'L' THEN 'Transaction Log' 
    END AS BackupType
INTO #backups
FROM msdb.dbo.backupset
GROUP BY database_name, type
ORDER BY database_name, LastBackupDate DESC

--SELECT * FROM #backups

SELECT R.dbname, R.type_desc, R.physical_name, R.size_mb, 
	CASE WHEN R.type_desc = 'ROWS' THEN R.used_mb ELSE CAST((L.logSizeMB * (L.logSpaceUsedPct / 100)) AS INT) END AS used_mb,
	R.growth_mb, 
	R.is_percent_growth,
	(SELECT LastBackupDate FROM #backups WHERE R.dbname = database_name AND BackupType = 'Full') AS last_full_backup,
	(SELECT LastBackupDate FROM #backups WHERE R.dbname = database_name AND BackupType = 'Transaction Log') AS last_tran_backup
FROM #rowspace AS R 
	LEFT JOIN #logspace AS L ON R.dbname = L.dbname AND R.type_desc = 'LOG'
WHERE R.dbname NOT IN ('master','model','msdb','ReportServer','ReportServerTempDB')


DROP TABLE #rowspace
DROP TABLE #logspace
DROP TABLE #backups