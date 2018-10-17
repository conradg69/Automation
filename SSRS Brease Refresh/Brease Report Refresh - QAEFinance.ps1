$ReportServer = @{
    Live = 'http://thgdocuments/Reportserver'
    QAE  = 'http://wercovrqaesqld1/Reportserver'
    DataSourcePath = "/Brease_FinanceQAE/DataSources/Brease_FinanceQAE"
}

$Folder = @{
    Backup                 = '/BreaseReportBackups'
    BreaseBackupFinanceQAE = 'TR4_QAEFinance'
    BreaseFinanceQAE       = '/Brease_FinanceQAE'
    BreaseLive             = '/Brease/'
    DetailReports          = "Detail Reports"
    SelectorReports        = "Selector Reports"
    ReportBackups          = "\\WERCOVRQAESQLD1\SSRSBackupRefresh\ReportBackups\"
    BackupName             = 'ReportBackups'
}

$CurrentDateTime = Get-Date -Format FileDateTime 
$DateTimeFormatted = $CurrentDateTime.Substring(0, 13)
$Root                = $Folder.ReportBackups + $Folder.BreaseBackupFinanceQAE + $Path + $Folder.BackupName + "-$DateTimeFormatted"
$Path = '\'
$DownloadFolder = @{
    Root                = $Folder.ReportBackups + $Folder.BreaseBackupFinanceQAE + $Path + $Folder.BackupName + "-$DateTimeFormatted"
    SelectorReports     = $Root + $Path + $Folder.SelectorReports
    DetailReports       = $Root + $Path + $Folder.DetailReports
    LiveSelectorReports = $Root + $Path + 'Live ' + $Folder.SelectorReports
    LiveDetailReports   = $Root + $Path + 'Live ' + $Folder.DetailReports
    SSRSDetails         = $Folder.BreaseFinanceQAE + '/' + $Folder.DetailReports 
    SSRSSelector        = $Folder.BreaseFinanceQAE + '/' + $Folder.SelectorReports 
    LiveSSRSDetails     = $Folder.BreaseLive + $Folder.DetailReports 
    LiveSSRSSelector    = $Folder.BreaseLive + $Folder.SelectorReports     
}

$UploadFolder = @{
    Root                    = $Folder.BreaseBackupFinanceQAE + "-$DateTimeFormatted"
    RootPlusDatedFolder     = $Folder.Backup + '/' + $Folder.BreaseBackupFinanceQAE + "-$DateTimeFormatted"
    RootLivePlusDatedFolder = $Folder.BreaseFinanceQAE + '/' + $Folder.BreaseBackupFinanceQAE + "-$DateTimeFormatted"
    SelectorReports         = $Folder.BackupName + "-$DateTimeFormatted" + '/' + $Folder.SelectorReports

}

$DetailReportUpload = $UploadFolder.RootPlusDatedFolder + '/' + $Folder.DetailReports
$SelectorReportUpload = $UploadFolder.RootPlusDatedFolder + '/' + $Folder.SelectorReports
$DetailQAEReportUpload = $Folder.BreaseFinanceQAE + '/' + $Folder.DetailReports
$SelectorQAEReportUpload = $Folder.BreaseFinanceQAE + '/' + $Folder.SelectorReports


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

#Drop Current QAEFinance Selector and Detail Folders
Remove-RsCatalogItem -ReportServerUri $ReportServer.QAE -RsItem "$SelectorQAEReportUpload" -Confirm:$false 
Remove-RsCatalogItem -ReportServerUri $ReportServer.QAE -RsItem "$DetailQAEReportUpload" -Confirm:$false 
#Remove-RsCatalogItem -ReportServerUri $ReportServer.QAE -RsItem '/BreaseReportBackups/TR4_QAEFinance-20181017T1216' -Confirm:$false 

#$SelectorQAEReportUpload
write-host 'Creating SSRS Folders'
#create SSRS Folders
#New-RsFolder -ReportServerUri $ReportServer.QAE -RsFolder "/" -FolderName 'BreaseReportBackups'
New-RsFolder -ReportServerUri $ReportServer.QAE -RsFolder $Folder.Backup -FolderName $UploadFolder.Root
New-RsFolder -ReportServerUri $ReportServer.QAE -RsFolder $UploadFolder.RootPlusDatedFolder -FolderName $Folder.DetailReports
New-RsFolder -ReportServerUri $ReportServer.QAE -RsFolder $UploadFolder.RootPlusDatedFolder -FolderName $Folder.SelectorReports

New-RsFolder -ReportServerUri $ReportServer.QAE -RsFolder $Folder.BreaseFinanceQAE -FolderName $Folder.SelectorReports
New-RsFolder -ReportServerUri $ReportServer.QAE -RsFolder $Folder.BreaseFinanceQAE -FolderName $Folder.DetailReports



write-host 'Uploading Detail Reports - Backups'
#Upload all Detail Reports from the download folder
Write-RsFolderContent -ReportServerUri $ReportServer.QAE  -Path $DownloadFolder.DetailReports -RsFolder $DetailReportUpload -Overwrite

write-host 'Uploading Selector Reports - Backups'
#Upload all Selector Reports from the download folder
Write-RsFolderContent -ReportServerUri $ReportServer.QAE  -Path $DownloadFolder.SelectorReports -RsFolder $SelectorReportUpload -Overwrite

write-host 'Uploading Selector Reports'
#Upload all Selector Reports from the download folder
Write-RsFolderContent -ReportServerUri $ReportServer.QAE  -Path $DownloadFolder.LiveSelectorReports -RsFolder $SelectorQAEReportUpload -Overwrite

write-host 'Uploading Detail Reports'
#Upload all Selector Reports from the download folder
Write-RsFolderContent -ReportServerUri $ReportServer.QAE  -Path $DownloadFolder.LiveDetailReports -RsFolder $DetailQAEReportUpload -Overwrite


write-host 'Updating DataSourses - Selector Reports'
$BackedUpSelectorReports = Get-RsCatalogItems -ReportServerUri $ReportServer.QAE -RsFolder $SelectorQAEReportUpload
# Set report datasource
$BackedUpSelectorReports | Where-Object TypeName -eq 'Report' | ForEach-Object {
    $dataSource = Get-RsItemDataSource -ReportServerUri $ReportServer.QAE -RsItem $_.Path
    if ($dataSource -ne $null) {
        Set-RsDataSourceReference -ReportServerUri $ReportServer.QAE -Path $_.Path -DataSourceName $dataSource.Name -DataSourcePath $ReportServer.DataSourcePath
        Write-Output "Changed datasource $($dataSource.Name)  on report $($_.Path) "
    }
    else {
        Write-Warning "Report $($_.Path) does not contain an datasource"
    }
}

write-host 'Updating DataSourses - Detail Reports'
$BackedUpSelectorReports = Get-RsCatalogItems -ReportServerUri $ReportServer.QAE -RsFolder $DetailQAEReportUpload
# Set report datasource
$BackedUpSelectorReports | Where-Object TypeName -eq 'Report' | ForEach-Object {
    $dataSource = Get-RsItemDataSource -ReportServerUri $ReportServer.QAE -RsItem $_.Path
    if ($dataSource -ne $null) {
        Set-RsDataSourceReference -ReportServerUri $ReportServer.QAE -Path $_.Path -DataSourceName $dataSource.Name -DataSourcePath $ReportServer.DataSourcePath
        Write-Output "Changed datasource $($dataSource.Name)  on report $($_.Path) "
    }
    else {
        Write-Warning "Report $($_.Path) does not contain an datasource"
    }
}

write-host 'Updating DataSourses - Backed Up Selector Reports'
$BackedUpSelectorReports = Get-RsCatalogItems -ReportServerUri $ReportServer.QAE -RsFolder $SelectorReportUpload
# Set report datasource
$BackedUpSelectorReports | Where-Object TypeName -eq 'Report' | ForEach-Object {
    $dataSource = Get-RsItemDataSource -ReportServerUri $ReportServer.QAE -RsItem $_.Path
    if ($dataSource -ne $null) {
        Set-RsDataSourceReference -ReportServerUri $ReportServer.QAE -Path $_.Path -DataSourceName $dataSource.Name -DataSourcePath $ReportServer.DataSourcePath
        Write-Output "Changed datasource $($dataSource.Name)  on report $($_.Path) "
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
        Write-Output "Changed datasource $($dataSource.Name)  on report $($_.Path) "
    }
    else {
        Write-Warning "Report $($_.Path) does not contain an datasource"
    }
}



