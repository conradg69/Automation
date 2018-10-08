        $Fusion39Backups = Import-Excel -Path 'P:\PS\PreProd Refresh\DeploymentDetails.xlsx' -WorksheetName DBBackups |
        Where-Object {$_.Category -eq 'Fusion39'}
        $Fusion39Backups = $Fusion39Backups.BackupLocations

        $Databases = Import-Excel -Path 'P:\PS\PreProd Refresh\DeploymentDetails.xlsx' -WorksheetName DBBackups |
        Where-Object {$_.Category -eq 'Fusion39' -or $_.Category -eq 'PreProdILT' }
        $Databases = $Databases.databases

        <#
        $Databases = 
        (
        'HoseasonsAPI',
        'HoseasonsBooking',
        'HoseasonsContent',
        'HoseasonsCore',
        'HoseasonsCustomer',
        'HoseasonsMarketing',
        'HoseasonsProduct',
        'PartnersAllocation',
        'PartnersAudit',
        'PartnersContent',
        'PartnersCore',
        'PartnersPrice',
        'FusionILTCacheSearchPreProd'
        )
        #>

#Backup locations of the Live databases
$FusionILTCacheSearchBackups = '\\10.215.13.143\sqlbackups1\Fusion\Fusion4\ph272908_SQL03\FusionILTCacheSearch\FULL'
$BreaseLiveBackup = '\\VLOPVRSTOAPP01\SQL_Backups_Traveller\TRAVELLERSQLCL\Brease\FULL'

#Backup Destinations on the SDLC Dev Server
$SDLCDev39BackupFolder = "\\WERCOVRDEVSQLD1\PreProd Refresh\DBBackups\Fusion39Backups"
$SDLCDevILTBackupFolder = "\\WERCOVRDEVSQLD1\PreProd Refresh\DBBackups\FusionILTCacheSearchBackup"
$SDLCBreaseBackupFolder = "\\WERCOVRDEVSQLD1\PreProd Refresh\DBBackups\BreaseBackup"
$UserpermissionsScriptOutput = "\\WERCOVRDEVSQLD1\PreProd Refresh\LoginScripts\UserPermissions.sql" 
$UATSQLInstance = 'Wercovruatsqld1,2533'
$DropReplicationScript = '\\WERCOVRDEVSQLD1\PreProd Refresh\DropReplication.sql'
$TravellerLiveBackup = '\\WERCOVRUATSQLD1\DBBackups4\TR4_LIVE\FULL'
$TravellerLiveBackupFile = Get-ChildItem -Path '\\WERCOVRUATSQLD1\DBBackups4\TR4_LIVE\FULL'
$TravellerLiveBackupFile2 = $TravellerLiveBackupFile.FullName
$BreaseDatabase = 'BeaseUAT'

#Brease Setup Files
$BreaseUATConfigFile = '\\WERCOVRDEVSQLD1\PreProd Refresh\BreaseUAT.sql'
$BreaseAccountPermissions = '\\WERCOVRDEVSQLD1\PreProd Refresh\Brease Account Access.sql'

#Invoke-Item '\\10.215.13.143\SQLBackups1\Fusion\Fusion39\HoseasonsAPI\FULL'

#1. Loop through each folder, find the latest backup and copy to the SDLC Dev server
ForEach($BackupFolder in $Fusion39Backups)
    {
        Get-ChildItem -Path $BackupFolder -Filter "*.bak" -Recurse|
        Sort-Object LastWriteTime -Descending | 
        Select-Object -First 1 |
        ForEach-Object($_){Copy-Item $_.FullName -Destination $SDLCDev39BackupFolder -Verbose
    }
} 

#2. Get the details for the latest ILT backup from Live and copy to the SDLC server
Get-ChildItem -Path $FusionILTCacheSearchBackups -Filter "*.bak" -Recurse | Sort-Object LastWriteTime -Descending |
Select-Object -First 1  |Copy-Item  -Destination $SDLCDevILTBackupFolder -Verbose

#3. Get the details for the latest Brease backup from Live and copy to the SDLC server
Get-ChildItem -Path $BreaseLiveBackup -Filter "*.bak" -Recurse | Sort-Object LastWriteTime -Descending |
Select-Object -First 1  |Copy-Item  -Destination $SDLCBreaseBackupFolder -Verbose

#4. Export user accounts for all Fusion 3.9 databases
Export-DbaUser -SqlInstance $UATSQLInstance -Database $Databases -FilePath $UserpermissionsScriptOutput 

#5. Restore all 12 Fusion 3.9 database from the SDLC Dev folder
$restoreDbaDatabaseSplat = @{
    SqlInstance = $UATSQLInstance
    Path = '\\WERCOVRDEVSQLD1\PreProd Refresh\DBBackups\Fusion39Backups'
    WithReplace = $true
    Verbose = $true
    AllowContinue = $true
    WhatIf = $true
}
Restore-DbaDatabase @restoreDbaDatabaseSplat

#6. Drop PreProd Replication
Invoke-DbaSqlQuery -SqlInstance $UATSQLInstance -Database TR4_PRE_PROD -File $DropReplicationScript -Verbose

<#
#7. restore Traveller Database ??? Issues

Restore-DbaDatabase -SqlInstance $UATSQLInstance -DatabaseName TR4_PRE_PROD -Path $TravellerLiveBackup -WithReplace -NoRecovery -Verbose -WhatIf
$inputFile='\\WERCOVRDEVSQLD1\PreProd Refresh\TravellerFULLRefresh.sql'
$BackupFile='\\WERCOVRUATSQLD1\DBBackups4\TR4_LIVE\FULL\TR4_LIVE.FULLCOMP.20180914200000.BAK'

Invoke-DbaSqlQuery -SqlInstance $UATSQLInstance -Database Master -File $inputFile -Verbose
#>

#8. Apply Traveller setup, DB permissions, Traveller Access levels and load CLR

#9. Backup the current UAT Brease Database
Backup-DbaDatabase -SqlInstance $UATSQLInstance -Database BreaseUAT -BackupDirectory K:\DBBackups\BreaseUAT\FULL -CompressBackup

#10. Refresh the UAT Brease database
$restoreDbaDatabaseSplat = @{
    SqlInstance = $UATSQLInstance
    Path = $SDLCBreaseBackupFolder
    WithReplace = $true
    Verbose = $true
    DatabaseName = 'BreaseUAT'
    DestinationDataDirectory = 'K:\SQLData'
    DestinationLogDirectory = 'K:\SQLTLog'
}
Restore-DbaDatabase @restoreDbaDatabaseSplat

#11. Apply Brease UAT configuration
Invoke-DbaSqlQuery -SqlInstance $UATSQLInstance -Database BreaseUAT -File $BreaseUATConfigFile -Verbose

#12. Grant the BreaseUAT account DBO permissions to the Brease database
Invoke-DbaSqlCmd -SqlInstance $UATSQLInstance -Database BreaseUAT -File $BreaseAccountPermissions -Verbose

#Refresh the ILT PreProd database
$restoreDbaDatabaseSplat = @{
    SqlInstance = $UATSQLInstance
    Path = $SDLCDevILTBackupFolder
    DestinationFileSuffix = 'PreProd'
    Verbose = $true
    DatabaseName = 'FusionILTCacheSearchPreProd'
    DestinationDataDirectory = 'F:\SQLData'
    DestinationLogDirectory = 'F:\SQLTLog'
    WithReplace = $true
}
Restore-DbaDatabase @restoreDbaDatabaseSplat

#Add replciation
#Run script
#start agent job

#Add ILT Index

#LOAD CLR


#Checks
#Check Traveller and ILT CLR loaded



