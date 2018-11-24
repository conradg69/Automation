<#
    
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('LIVE', 'DEV', 'UAT', 'QAE')]
    [string[]]$Environment,

    [string]$ReportDownloadFolder = '\\WERCOVRDEVSQLD1\BreaseRefresh\Reports'
)

$ReportServerURL = @{
    Live = 'http://thgdocuments/Reportserver'
    QAE  = 'http://wercovrqaesqld1/Reportserver'
    UAT  = 'http://wercovruatsqld1/Reportserver'
    DEV  = 'http://wercovrdevsqld1/Reportserver'
}

$Folder = @{
    Backup          = '/BreaseReportBackups'
    BreaseLive      = '/Brease/'
    BreaseDev       = '/Brease_DEV/'
    DetailReports   = "Detail Reports"
    SelectorReports = "Selector Reports"
}
$CurrentDateTime = Get-Date -Format FileDateTime 
$DateTimeFormatted = $CurrentDateTime.Substring(0, 13)

switch ($Environment) {
    LIVE { 
        Write-Host 'This is Live' 
        $DownloadSelectorReportsFolderPath = $ReportDownloadFolder + '\Live_' + $Folder.SelectorReports + '\' + $DateTimeFormatted
        $DownloadDetailReportsFolderPath = $ReportDownloadFolder + '\Live_' + $Folder.DetailReports + '\' + $DateTimeFormatted

        if (-not(Test-Path -Path $DownloadSelectorReportsFolderPath)) {New-Item -Path $DownloadSelectorReportsFolderPath -ItemType Directory}
        if (-not(Test-Path -Path $DownloadDetailReportsFolderPath)) {New-Item -Path $DownloadDetailReportsFolderPath -ItemType Directory}

        Get-RsFolderContent -ReportServerUri $ReportServerURL.Live -RsFolder ($Folder.BreaseLive + $Folder.SelectorReports) |  Where-Object TypeName -eq 'Report' |
            Select-Object -ExpandProperty Path |
            Out-RsCatalogItem -ReportServerUri $ReportServerURL.Live -Destination $DownloadSelectorReportsFolderPath -Verbose

        Get-RsFolderContent -ReportServerUri $ReportServerURL.Live -RsFolder ($Folder.BreaseLive + $Folder.DetailReports) |  Where-Object TypeName -eq 'Report' |
            Select-Object -ExpandProperty Path |
            Out-RsCatalogItem -ReportServerUri $ReportServerURL.Live -Destination $DownloadDetailReportsFolderPath -Verbose
    }
    
    DEV { 
        Write-Host 'This is DEV' 
        $DownloadSelectorReportsFolderPath = $ReportDownloadFolder + '\Dev_' + $Folder.SelectorReports + '\' + $DateTimeFormatted
        $DownloadDetailReportsFolderPath = $ReportDownloadFolder + '\Dev_' + $Folder.DetailReports + '\' + $DateTimeFormatted

        if (-not(Test-Path -Path $DownloadSelectorReportsFolderPath)) {New-Item -Path $DownloadSelectorReportsFolderPath -ItemType Directory}
        if (-not(Test-Path -Path $DownloadDetailReportsFolderPath)) {New-Item -Path $DownloadDetailReportsFolderPath -ItemType Directory}

        Get-RsFolderContent -ReportServerUri $ReportServerURL.DEV -RsFolder ($Folder.BreaseDev + $Folder.SelectorReports) |  Where-Object TypeName -eq 'Report' |
            Select-Object -ExpandProperty Path |
            Out-RsCatalogItem -ReportServerUri $ReportServerURL.DEV -Destination $DownloadSelectorReportsFolderPath -Verbose

        Get-RsFolderContent -ReportServerUri $ReportServerURL.DEV -RsFolder ($Folder.BreaseDev + $Folder.DetailReports) |  Where-Object TypeName -eq 'Report' |
            Select-Object -ExpandProperty Path |
            Out-RsCatalogItem -ReportServerUri $ReportServerURL.DEV -Destination $DownloadDetailReportsFolderPath -Verbose
    }

    UAT { 
        Write-Host 'This is UAT' 
    }
    QAE { 
        Write-Host 'This is QAE' 
    }
    Default {}
}
