$reportServerUriLive = 'http://thgdocuments/Reportserver'
$reportServerUriDest = 'http://wercovrqaesqld1/Reportserver'
$RootFolderPath = "/"
$RootBackupFolderName = 'BreaseReportBackups'
$RootBackupFolderPath = "$RootFolderPath$RootBackupFolderName"
$BreaseQAEFolder = 'TR4_QAEMaintenance'
$BreaseQAEFolderSSRS = 'Brease_MaintenanceQAE'
$CurrentDateTime = Get-Date -Format FileDateTime 
$DateTimeFormatted = $CurrentDateTime.Substring(0,13)
$QAEBackupFolder = "$BreaseQAEFolder-$DateTimeFormatted"
$DetailReportsFolder = "Detail Reports"
$SelectorReportsFolder = "Selector Reports"
$downloadFolderDetailReports = "H:\SSRSBackupRefresh\ReportBackups\$BreaseQAEFolder\$DetailReportsFolder $DateTimeFormatted"
$downloadFolderSelectorReports = "H:\SSRSBackupRefresh\ReportBackups\$BreaseQAEFolder\Selector Reports $DateTimeFormatted"
$downloadFolderLiveDetailReports = "H:\SSRSBackupRefresh\ReportBackups\$BreaseQAEFolder\Live $DetailReportsFolder $DateTimeFormatted"
$downloadFolderLiveSelectorReports = "H:\SSRSBackupRefresh\ReportBackups\$BreaseQAEFolder\Live $SelectorReportsFolder $DateTimeFormatted"
$DataSourcePath2 = "/Brease_MaintenanceQAE/Data Source/Brease_Maintenance"
$TR4_QAERootFolder = "H:\SSRSBackupRefresh\ReportBackups\$BreaseQAEFolder"


#Create Brease  Folders for the RDL files
New-Item -Path $downloadFolderDetailReports -ItemType directory 
New-Item -Path $downloadFolderSelectorReports -ItemType directory 
New-Item -Path $downloadFolderLiveDetailReports -ItemType directory
New-Item -Path $downloadFolderLiveSelectorReports -ItemType directory

write-host 'Downloading Detail Reports'
#Download all Detail Report RDL files to a Folder 
Get-RsFolderContent -ReportServerUri $reportServerUriDest -RsFolder "$RootFolderPath$BreaseQAEFolderSSRS/$DetailReportsFolder" |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path | Out-RsCatalogItem -ReportServerUri $reportServerUriDest -Destination $downloadFolderDetailReports 

write-host 'Downloading Selector Reports'
#Download all Selector Report RDL files to a Folder 
Get-RsFolderContent -ReportServerUri $reportServerUriDest -RsFolder "$RootFolderPath$BreaseQAEFolderSSRS/$SelectorReportsFolder" |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path | Out-RsCatalogItem -ReportServerUri $reportServerUriDest -Destination $downloadFolderSelectorReports

write-host 'Downloading Live Detail Reports'
#Download all Live Detail Report RDL files to a Folder 
Get-RsFolderContent -ReportServerUri $reportServerUriLive -RsFolder "/Brease/$DetailReportsFolder" |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path | Out-RsCatalogItem -ReportServerUri $reportServerUriLive -Destination $downloadFolderLiveDetailReports

write-host 'Downloading Live Selector Reports'
#Download all Selector Report RDL files to a Folder 
Get-RsFolderContent -ReportServerUri $reportServerUriLive -RsFolder "/Brease/$SelectorReportsFolder" |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path | Out-RsCatalogItem -ReportServerUri $reportServerUriLive -Destination $downloadFolderLiveSelectorReports

#Move Reports that need to be manually uploaded to the a separate folder
Get-ChildItem -Path $downloadFolderLiveDetailReports  -Recurse -Filter "*[*" | Remove-Item
Get-ChildItem -Path $downloadFolderLiveDetailReports  -Recurse -Filter "*WebAppsTest*" | Remove-Item
Get-ChildItem -Path $downloadFolderDetailReports  -Recurse -Filter "*[*" | Remove-Item
Get-ChildItem -Path $downloadFolderDetailReports  -Recurse -Filter "*WebAppsTest*" | Remove-Item

#Drop the Current QAE Maint Brease SSRS Folders
Remove-RsCatalogItem -ReportServerUri $reportServerUriDest -RsItem "$RootFolderPath$BreaseQAEFolderSSRS/$SelectorReportsFolder" -Confirm:$false 
Remove-RsCatalogItem -ReportServerUri $reportServerUriDest -RsItem "$RootFolderPath$BreaseQAEFolderSSRS/$DetailReportsFolder" -Confirm:$false 

write-host 'Creating SSRS Folders'
#create SSRS Folders
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder $RootBackupFolderPath -FolderName $QAEBackupFolder
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$QAEBackupFolder" -FolderName $DetailReportsFolder
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$QAEBackupFolder" -FolderName $SelectorReportsFolder
#New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder $RootFolderPath -FolderName $BreaseQAEFolderSSRS
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder "$RootFolderPath$BreaseQAEFolderSSRS" -FolderName $DetailReportsFolder
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder "$RootFolderPath$BreaseQAEFolderSSRS" -FolderName $SelectorReportsFolder

write-host 'Uploading Detail Reports - Backups'
#Upload all Detail Reports from the download folder
Write-RsFolderContent -ReportServerUri $reportServerUriDest -Path $downloadFolderDetailReports -RsFolder "$RootBackupFolderPath/$QAEBackupFolder/$DetailReportsFolder" -Overwrite

write-host 'Uploading Selector Reports - Backups'
#Upload all Selector Reports from the download folder
Write-RsFolderContent -ReportServerUri $reportServerUriDest -Path $downloadFolderSelectorReports -RsFolder "$RootBackupFolderPath/$QAEBackupFolder/$SelectorReportsFolder" -Overwrite

write-host 'Uploading Detail Reports - Live Copy'
#Upload all Live Detail Reports from the download folder
Write-RsFolderContent -ReportServerUri $reportServerUriDest -Path $downloadFolderLiveDetailReports -RsFolder "$RootFolderPath$BreaseQAEFolderSSRS/$DetailReportsFolder" -Overwrite

write-host 'Uploading Selector Reports - Live Copy'
#Upload all Selector Reports from the download folder
Write-RsFolderContent -ReportServerUri $reportServerUriDest -Path $downloadFolderLiveSelectorReports -RsFolder "$RootFolderPath$BreaseQAEFolderSSRS/$SelectorReportsFolder" -Overwrite

#Clean Up - moved RDL's folder to a New folder
New-Item -Path "$TR4_QAERootFolder/ReportBackups $DateTimeFormatted" -ItemType directory
Move-Item -Path $downloadFolderDetailReports -Destination "$TR4_QAERootFolder/ReportBackups $DateTimeFormatted"
Move-Item -Path $downloadFolderSelectorReports -Destination "$TR4_QAERootFolder/ReportBackups $DateTimeFormatted"
Move-Item -Path $downloadFolderLiveDetailReports -Destination "$TR4_QAERootFolder/ReportBackups $DateTimeFormatted"
Move-Item -Path $downloadFolderLiveSelectorReports -Destination "$TR4_QAERootFolder/ReportBackups $DateTimeFormatted"

write-host 'Updating DataSourses - Backed Up Selector Reports'
$BackedUpSelectorReports = Get-RsCatalogItems -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$QAEBackupFolder/$SelectorReportsFolder"
# Set report datasource
$BackedUpSelectorReports | Where-Object TypeName -eq 'Report' | ForEach-Object {
    $dataSource = Get-RsItemDataSource -ReportServerUri $reportServerUriDest -RsItem $_.Path
    if ($dataSource -ne $null) {
        Set-RsDataSourceReference -ReportServerUri $reportServerUriDest -Path $_.Path -DataSourceName $dataSource.Name -DataSourcePath $DataSourcePath2
        Write-Output "Changed datasource $($dataSource.Name) set to $DataSourcePath2 on report $($_.Path) "
    }
    else {
        Write-Warning "Report $($_.Path) does not contain an datasource"
    }
}

write-host 'Updating DataSourses - Backed Up Detail Reports'
$BackedUpDetailReports = Get-RsCatalogItems -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$QAEBackupFolder/$DetailReportsFolder"
# Set report datasource
$BackedUpDetailReports | Where-Object TypeName -eq 'Report' | ForEach-Object {
    $dataSource = Get-RsItemDataSource -ReportServerUri $reportServerUriDest -RsItem $_.Path
    if ($dataSource -ne $null) {
        Set-RsDataSourceReference -ReportServerUri $reportServerUriDest -Path $_.Path -DataSourceName $dataSource.Name -DataSourcePath $DataSourcePath2
        Write-Output "Changed datasource $($dataSource.Name) set to $DataSourcePath2 on report $($_.Path) "
    }
    else {
        Write-Warning "Report $($_.Path) does not contain an datasource"
    }
}

write-host 'Updating DataSourses - Live Detail Reports'
$BackedUpLiveDetailReports = Get-RsCatalogItems -ReportServerUri $reportServerUriDest -RsFolder "$RootFolderPath$BreaseQAEFolderSSRS/$DetailReportsFolder"
# Set report datasource
$BackedUpLiveDetailReports | Where-Object TypeName -eq 'Report' | ForEach-Object {
    $dataSource = Get-RsItemDataSource -ReportServerUri $reportServerUriDest -RsItem $_.Path
    if ($dataSource -ne $null) {
        Set-RsDataSourceReference -ReportServerUri $reportServerUriDest -Path $_.Path -DataSourceName $dataSource.Name -DataSourcePath $DataSourcePath2
        Write-Output "Changed datasource $($dataSource.Name) set to $DataSourcePath2 on report $($_.Path) "
    }
    else {
        Write-Warning "Report $($_.Path) does not contain an datasource"
    }
}

write-host 'Updating DataSourses - Live Selector Reports'

$BackedUpSelectorReports = Get-RsCatalogItems -ReportServerUri $reportServerUriDest -RsFolder "$RootFolderPath$BreaseQAEFolderSSRS/$SelectorReportsFolder"
# Set report datasource
$BackedUpSelectorReports | Where-Object TypeName -eq 'Report' | ForEach-Object {
    $dataSource = Get-RsItemDataSource -ReportServerUri $reportServerUriDest -RsItem $_.Path
    if ($dataSource -ne $null) {
        Set-RsDataSourceReference -ReportServerUri $reportServerUriDest -Path $_.Path -DataSourceName $dataSource.Name -DataSourcePath $DataSourcePath2
        Write-Output "Changed datasource $($dataSource.Name) set to $DataSourcePath2 on report $($_.Path) "
    }
    else {
        Write-Warning "Report $($_.Path) does not contain an datasource"
    }
}