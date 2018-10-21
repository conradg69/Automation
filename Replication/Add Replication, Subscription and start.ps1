$SDLC = @{
    DatabaseName = 'TR4_DEV'
    Server       = 'WERCOVRDEVSQLD1'
}

$DropReplicationScript = @"
EXEC sp_dropsubscription 
  @publication = N'pubFusionILTCache', 
  @article = N'all',
  @subscriber = 'WERCOVRDEVSQLD1';
GO

-- Remove a transactional publication.
EXEC sp_droppublication @publication = N'pubFusionILTCache';
"@

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

#Drop the Current replication. Pulication and Subscribers
Invoke-DbaSqlQuery -SqlInstance $SDLC.Server -Database $SDLC.DatabaseName -Query $DropReplicationScript -Verbose

#Add Replication Publisher
$ReplicationScript = '\\WERCOVRDEVSQLD1\PreProd Refresh\DBBackups\Replication\TR4Dev_ILT_ReplicationExport.sql'
Invoke-Sqlcmd2 -ServerInstance $SDLC.Server -Database $SDLC.DatabaseName -InputFile $ReplicationScript 

#Add Subscriber
Invoke-Sqlcmd2 -ServerInstance $SDLC.Server -Database $SDLC.DatabaseName -Query $SubscriptionScript -Verbose

#Get Name of the Publication
$publication = Get-DbaRepPublication -SqlInstance WERCOVRDEVSQLD1 
$PubName = $publication.PublicationName

#Start the Snapshot Agent
$SQLJobs = Get-DbaAgentJob -SqlInstance WERCOVRDEVSQLD1 -Verbose | Where-Object {($_.Category -eq "REPL-Snapshot" -and $_.Name -like "*$PubName*")} 
Start-DbaAgentJob -SqlInstance WERCOVRDEVSQLD1 -Job $SQLJobs.name -Verbose

