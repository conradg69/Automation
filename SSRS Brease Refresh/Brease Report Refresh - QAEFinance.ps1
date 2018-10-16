$ReportServer = @{
    Live = 'http://thgdocuments/Reportserver'
    QAE  = 'http://wercovrqaesqld1/Reportserver'
    DataSourcePath = "/Brease_FinanceQAE/DataSources/Brease_FinanceQAE"
}

$Folder = @{
    Backup                 = '/BreaseReportBackups'
    BreaseBackupFinanceQAE = 'TR4_QAEFinance'
    BreaseFinanceQAE       = '/Brease_FinanceQAE/'
    BreaseLive             = '/Brease/'
    DetailReports          = "Detail Reports"
    SelectorReports        = "Selector Reports"
    ReportBackups          = "\\WERCOVRQAESQLD1\SSRSBackupRefresh\ReportBackups\"
    BackupName             = 'ReportBackups'

}

$CurrentDateTime = Get-Date -Format FileDateTime 
$DateTimeFormatted = $CurrentDateTime.Substring(0, 13)

$QAEBackupFolder = "$BreaseQAEFolder-$DateTimeFormatted"

$Path = '\'
$DownloadFolder = @{
    Root                = $Folder.ReportBackups + $Folder.BreaseBackupFinanceQAE + $Path + $Folder.BackupName + "-$DateTimeFormatted"
    SelectorReports     = $DownloadFolder.Root + $Path + $Folder.SelectorReports
    DetailReports       = $DownloadFolder.Root + $Path + $Folder.DetailReports
    LiveSelectorReports = $DownloadFolder.Root + $Path + 'Live ' + $Folder.SelectorReports
    LiveDetailReports   = $DownloadFolder.Root + $Path + 'Live ' + $Folder.DetailReports
    SSRSDetails         = $Folder.BreaseFinanceQAE + $Folder.DetailReports 
    SSRSSelector        = $Folder.BreaseFinanceQAE + $Folder.SelectorReports 
    LiveSSRSDetails     = $Folder.BreaseLive + $Folder.DetailReports 
    LiveSSRSSelector    = $Folder.BreaseLive + $Folder.SelectorReports     
}

$UploadFolder = @{
    Root                = $Folder.BreaseBackupFinanceQAE + "-$DateTimeFormatted"
    RootPlusDatedFolder = $Folder.Backup + '/' + $Folder.BreaseBackupFinanceQAE + "-$DateTimeFormatted"
    SelectorReports     = $Folder.BackupName + "-$DateTimeFormatted" + '/' + $Folder.SelectorReports

}

#Check and create folders to download the reports - Backup Current QAE Finance Reports
if (-not(Test-Path -Path $DownloadFolder.SelectorReports)) {New-Item -Path $DownloadFolder.SelectorReports -ItemType Directory}
if (-not(Test-Path -Path $DownloadFolder.DetailReports)) {New-Item -Path $DownloadFolder.DetailReports -ItemType Directory}
if (-not(Test-Path -Path $DownloadFolder.LiveSelectorReports)) {New-Item -Path $DownloadFolder.LiveSelectorReports -ItemType Directory}
if (-not(Test-Path -Path $DownloadFolder.LiveDetailReports)) {New-Item -Path $DownloadFolder.LiveDetailReports -ItemType Directory}


write-host 'Downloading Detail Reports'
#Download all Detail Report RDL files to a Folder 
Get-RsFolderContent -ReportServerUri $ReportServer.QAE -RsFolder $DownloadFolder.SSRSDetails |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path |
    Out-RsCatalogItem -ReportServerUri $ReportServer.QAE -Destination $DownloadFolder.DetailReports  -Verbose

write-host 'Downloading Selector Reports'
#Download all Selector Report RDL files to a Folder 
Get-RsFolderContent -ReportServerUri $ReportServer.QAE -RsFolder $DownloadFolder.SSRSSelector |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path |
    Out-RsCatalogItem -ReportServerUri $ReportServer.QAE -Destination $DownloadFolder.SelectorReports -Verbose


write-host 'Downloading Live Detail Reports'
#Download all Live Detail Report RDL files to a Folder 
Get-RsFolderContent -ReportServerUri $ReportServer.Live -RsFolder $DownloadFolder.LiveSSRSDetails |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path |
    Out-RsCatalogItem -ReportServerUri $ReportServer.Live -Destination $DownloadFolder.LiveDetailReports -Verbose

write-host 'Downloading Live Selector Reports'
#Download all Selector Report RDL files to a Folder 
Get-RsFolderContent -ReportServerUri $ReportServer.Live -RsFolder $DownloadFolder.LiveSSRSSelector |  Where-Object TypeName -eq 'Report' |
    Select-Object -ExpandProperty Path |
    Out-RsCatalogItem -ReportServerUri $ReportServer.Live -Destination $DownloadFolder.LiveSelectorReports -Verbose



#Move Reports that need to be manually uploaded to the a separate folder
Get-ChildItem -Path $DownloadFolder.LiveDetailReports  -Recurse -Filter "*[*" | Remove-Item
Get-ChildItem -Path $DownloadFolder.LiveDetailReports  -Recurse -Filter "*WebAppsTest*" | Remove-Item
Get-ChildItem -Path $DownloadFolder.DetailReports   -Recurse -Filter "*[*" | Remove-Item
Get-ChildItem -Path $DownloadFolder.DetailReports   -Recurse -Filter "*WebAppsTest*" | Remove-Item


#Remove-RsCatalogItem -ReportServerUri $ReportServer.QAE -RsItem '/BreaseReportBackups' -Confirm:$false 
#Remove-RsCatalogItem -ReportServerUri $reportServerUriDest -RsItem "$RootFolderPath$BreaseQAEFolderSSRS/$DetailReportsFolder" -Confirm:$false 

write-host 'Creating SSRS Folders'
#create SSRS Folders
#New-RsFolder -ReportServerUri $ReportServer.QAE -RsFolder "/" -FolderName 'BreaseReportBackups'
New-RsFolder -ReportServerUri $ReportServer.QAE -RsFolder $Folder.Backup -FolderName $UploadFolder.Root
New-RsFolder -ReportServerUri $ReportServer.QAE -RsFolder $UploadFolder.RootPlusDatedFolder -FolderName $Folder.DetailReports
New-RsFolder -ReportServerUri $ReportServer.QAE -RsFolder $UploadFolder.RootPlusDatedFolder -FolderName $Folder.SelectorReports

$DetailReportUpload = $UploadFolder.RootPlusDatedFolder + '/' + $Folder.DetailReports
$SelectorReportUpload = $UploadFolder.RootPlusDatedFolder + '/' + $Folder.SelectorReports

write-host 'Uploading Detail Reports - Backups'
#Upload all Detail Reports from the download folder
Write-RsFolderContent -ReportServerUri $ReportServer.QAE  -Path $DownloadFolder.DetailReports -RsFolder $DetailReportUpload -Overwrite

write-host 'Uploading Selector Reports - Backups'
#Upload all Selector Reports from the download folder
Write-RsFolderContent -ReportServerUri $ReportServer.QAE  -Path $DownloadFolder.SelectorReports -RsFolder $SelectorReportUpload -Overwrite


write-host 'Updating DataSourses - Backed Up Selector Reports'
$BackedUpSelectorReports = Get-RsCatalogItems -ReportServerUri $ReportServer.QAE -RsFolder $SelectorReportUpload
# Set report datasource
$BackedUpSelectorReports | Where-Object TypeName -eq 'Report' | ForEach-Object {
    $dataSource = Get-RsItemDataSource -ReportServerUri $ReportServer.QAE -RsItem $_.Path
    if ($dataSource -ne $null) {
        Set-RsDataSourceReference -ReportServerUri $ReportServer.QAE -Path $_.Path -DataSourceName $dataSource.Name -DataSourcePath $ReportServer.DataSourcePath
        Write-Output "Changed datasource $($dataSource.Name) set to $DataSourcePath2 on report $($_.Path) "
    }
    else {
        Write-Warning "Report $($_.Path) does not contain an datasource"
    }
}


write-host 'Updating DataSourses - Backed Up Detail Reports'
$BackedUpSelectorReports = Get-RsCatalogItems -ReportServerUri $ReportServer.QAE -RsFolder $DetailReportUpload
# Set report datasource
$BackedUpSelectorReports | Where-Object TypeName -eq 'Report' | ForEach-Object {
    $dataSource = Get-RsItemDataSource -ReportServerUri $ReportServer.QAE -RsItem $_.Path
    if ($dataSource -ne $null) {
        Set-RsDataSourceReference -ReportServerUri $ReportServer.QAE -Path $_.Path -DataSourceName $dataSource.Name -DataSourcePath $ReportServer.DataSourcePath
        Write-Output "Changed datasource $($dataSource.Name) set to $DataSourcePath2 on report $($_.Path) "
    }
    else {
        Write-Warning "Report $($_.Path) does not contain an datasource"
    }
}

<#
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder "$RootBackupFolderPath/$QAEBackupFolder" -FolderName $SelectorReportsFolder
#New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder $RootFolderPath -FolderName $BreaseQAEFolderSSRS
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder "$RootFolderPath$BreaseQAEFolderSSRS" -FolderName $DetailReportsFolder
New-RsFolder -ReportServerUri $reportServerUriDest -RsFolder "$RootFolderPath$BreaseQAEFolderSSRS" -FolderName $SelectorReportsFolder




$downloadFolderDetailReports = "$Folder.ReportBackups\TR4_QAEFinance\$DetailReportsFolder $DateTimeFormatted"
$downloadFolderSelectorReports = "H:\SSRSBackupRefresh\ReportBackups\TR4_QAEFinance\Selector Reports $DateTimeFormatted"
$downloadFolderLiveDetailReports = "H:\SSRSBackupRefresh\ReportBackups\TR4_QAEFinance\Live $DetailReportsFolder $DateTimeFormatted"
$downloadFolderLiveSelectorReports = "H:\SSRSBackupRefresh\ReportBackups\TR4_QAEFinance\Live $SelectorReportsFolder $DateTimeFormatted"
$DataSourcePath2 = "/Brease_FinanceQAE/DataSources/Brease_FinanceQAE"
$TR4_QAERootFolder = 'H:\SSRSBackupRefresh\ReportBackups\TR4_QAEFinance'
#$BreaseQAEFolderSSRS = 'Brease_FinanceQAE'



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

#>
