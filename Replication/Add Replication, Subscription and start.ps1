
$DropReplicationScript = @"
EXEC sp_dropsubscription 
  @publication = N'pubFusionILTCache', 
  @article = N'all',
  @subscriber = 'WERCOVRDEVSQLD1';
GO

-- Remove a transactional publication.
EXEC sp_droppublication @publication = N'pubFusionILTCache';
"@
Invoke-DbaSqlQuery -SqlInstance WERCOVRDEVSQLD1 -Database TR4_DEV -File $DropReplicationScript -Verbose

$ReplicationScript = 'P:\PS\PreProd Refresh\DBBackups\Replication\Test1.sql'
Invoke-DbaSqlQuery -SqlInstance WERCOVRDEVSQLD1 -Database TR4_DEV -File $ReplicationScript -Verbose


$SubscriptionScript = @"
exec sp_addsubscription @publication = N'pubFusionILTCache', @subscriber = N'WERCOVRDEVSQLD1', 
@destination_db = N'FusionILTCacheSearchDEV', @subscription_type = N'Push', @sync_type = N'automatic', 
@article = N'all', @update_mode = N'read only', @subscriber_type = 0

exec sp_addpushsubscription_agent @publication = N'pubFusionILTCache', @subscriber = N'WERCOVRDEVSQLD1', 
@subscriber_db = N'FusionILTCacheSearchDEV', @job_login = null, @job_password = null, @subscriber_security_mode = 1, 
@frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, 
@frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, 
@active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
"@

Invoke-DbaSqlQuery -SqlInstance WERCOVRDEVSQLD1 -Database TR4_DEV -Query $SubscriptionScript -Verbose

$SQLJobs = Get-DbaAgentJob -SqlInstance WERCOVRDEVSQLD1 -Verbose | Where {($_.Category -eq "REPL-Snapshot" -and $_.Name -like "*pubFusionILTCache*")}

Start-DbaAgentJob -SqlInstance WERCOVRDEVSQLD1 -Job $SQLJobs.name





