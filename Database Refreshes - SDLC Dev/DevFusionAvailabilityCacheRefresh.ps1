
$BackupLocation = @{
    FusionAvailabilityCache = '\\VLOPVRSTOAPP01\SQL_Backups_Traveller\TRAVELLERSQLCL\FusionAvailabilityCache\FULL'
    SDLCDevFolder = '\\WERCOVRDEVSQLD1\DBRefresh\ProdBackupFiles\FusionAvailabilityCache'
}
$SDLC = @{
    SQLInstance = 'WERCOVRDEVSQLD1'
    DatabaseName = 'FusionAvailabilityCacheDev'
    DestinationDataDirectory = 'H:\SQLData'
    DestinationLogDirectory = 'H:\SQLTLog'
    Accounts = 'VRGUK\WebTeamReadOnly','VRGUK\Web Dev Team','VRGUK\SDLCQae','VRGUK\SDLCDev','VRGUK\devarajramasamy'
}

#Create folder if not present
if (-not(Test-Path -Path $BackupLocation.SDLCDevFolder)) {New-Item -ItemType directory -Path $BackupLocation.SDLCDevFolder}

#Delete any old backups in the folder
Remove-Item \\WERCOVRDEVSQLD1\DBRefresh\ProdBackupFiles\FusionAvailabilityCache\* -Recurse -Force

write-host 'Copying Latest Backup File to SDLC Dev Server' -ForegroundColor Yellow

#Find the lastest backup file and copy to the SDLC Dev Server
Get-ChildItem -Path $BackupLocation.FusionAvailabilityCache -Filter "*.bak" -Recurse | 
Sort-Object LastWriteTime -Descending | Select-Object -First 1  |
Copy-Item  -Destination $BackupLocation.SDLCDevFolder -Verbose

write-host 'Backup File Copy Complete' -ForegroundColor Yellow

write-host 'Restoring'$SDLC.DatabaseName 'Database' -ForegroundColor Yellow

#Restore Database
$restoreDbaDatabaseSplat = @{
    SqlInstance = $SDLC.SQLInstance
    Path = $BackupLocation.SDLCDevFolder
    WithReplace = $true
    Verbose = $true
    DatabaseName = $SDLC.DatabaseName
    DestinationDataDirectory = $SDLC.DestinationDataDirectory
    DestinationLogDirectory = $SDLC.DestinationLogDirectory
}
Restore-DbaDatabase @restoreDbaDatabaseSplat

#Drop all database users
$DBUsers = Get-DbaDatabaseUser $SDLC.SQLInstance -Database $SDLC.DatabaseName -ExcludeSystemUser 
$DBUsers.Name | ForEach-Object {Remove-DbaDbUser -SqlInstance $SDLC.SQLInstance -Database $SDLC.DatabaseName -User $_}

#Apply permissions
$SDLC.Accounts | ForEach-Object{New-DbaDbUser -SqlInstance $SDLC.SQLInstance -Database $SDLC.DatabaseName -Login $_ -Username $_} 

#ShrinkLogfile
Invoke-Sqlcmd2 -ServerInstance $SDLC.SQLInstance -Database $SDLC.DatabaseName -InputFile F:\PS\SQLRefreshJobs\ShrinkLogFile.sql
