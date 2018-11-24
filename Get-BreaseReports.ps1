Function Get-BreaseReports {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Please enter either LIVE, UAT, DEV or QAE")]
        [ValidateSet('LIVE', 'DEV', 'DEVMaintenance', 'UAT', 'PreProd', 'QAEFinance', 'QAEMaintenance')]
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
        BreaseLive           = '/Brease/'
        BreaseDev            = '/Brease_DEV/'
        BreaseDevMaintenance = '/Brease_MaintenanceDev/'
        BreaseUAT            = '/BreaseUAT/'
        BreasePreProd        = '/Brease_PreProd/'
        BreaseQAEFinance     = '/Brease_FinanceQAE/'
        BreaseQAEMaintenance = '/Brease_MaintenanceQAE/'
        DetailReports        = "Detail Reports"
        SelectorReports      = "Selector Reports"
    }

    $CurrentDateTime = Get-Date -Format FileDateTime 
    $DateTimeFormatted = $CurrentDateTime.Substring(0, 13)

    switch ($Environment) {
        LIVE { 
            
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

        DEVMaintenance { 
            
            $DownloadSelectorReportsFolderPath = $ReportDownloadFolder + '\DEVMaintenance_' + $Folder.SelectorReports + '\' + $DateTimeFormatted
            $DownloadDetailReportsFolderPath = $ReportDownloadFolder + '\DEVMaintenance_' + $Folder.DetailReports + '\' + $DateTimeFormatted

            if (-not(Test-Path -Path $DownloadSelectorReportsFolderPath)) {New-Item -Path $DownloadSelectorReportsFolderPath -ItemType Directory}
            if (-not(Test-Path -Path $DownloadDetailReportsFolderPath)) {New-Item -Path $DownloadDetailReportsFolderPath -ItemType Directory}

            Get-RsFolderContent -ReportServerUri $ReportServerURL.DEV -RsFolder ($Folder.BreaseDevMaintenance + $Folder.SelectorReports) |  Where-Object TypeName -eq 'Report' |
                Select-Object -ExpandProperty Path |
                Out-RsCatalogItem -ReportServerUri $ReportServerURL.DEV -Destination $DownloadSelectorReportsFolderPath -Verbose

            Get-RsFolderContent -ReportServerUri $ReportServerURL.DEV -RsFolder ($Folder.BreaseDevMaintenance + $Folder.DetailReports) |  Where-Object TypeName -eq 'Report' |
                Select-Object -ExpandProperty Path |
                Out-RsCatalogItem -ReportServerUri $ReportServerURL.DEV -Destination $DownloadDetailReportsFolderPath -Verbose
        }

        UAT { 
            
            $DownloadSelectorReportsFolderPath = $ReportDownloadFolder + '\UAT_' + $Folder.SelectorReports + '\' + $DateTimeFormatted
            $DownloadDetailReportsFolderPath = $ReportDownloadFolder + '\UAT_' + $Folder.DetailReports + '\' + $DateTimeFormatted

            if (-not(Test-Path -Path $DownloadSelectorReportsFolderPath)) {New-Item -Path $DownloadSelectorReportsFolderPath -ItemType Directory}
            if (-not(Test-Path -Path $DownloadDetailReportsFolderPath)) {New-Item -Path $DownloadDetailReportsFolderPath -ItemType Directory}

            Get-RsFolderContent -ReportServerUri $ReportServerURL.UAT -RsFolder ($Folder.BreaseUAT + $Folder.SelectorReports) |  Where-Object TypeName -eq 'Report' |
                Select-Object -ExpandProperty Path |
                Out-RsCatalogItem -ReportServerUri $ReportServerURL.UAT -Destination $DownloadSelectorReportsFolderPath -Verbose

            Get-RsFolderContent -ReportServerUri $ReportServerURL.UAT -RsFolder ($Folder.BreaseUAT + $Folder.DetailReports) |  Where-Object TypeName -eq 'Report' |
                Select-Object -ExpandProperty Path |
                Out-RsCatalogItem -ReportServerUri $ReportServerURL.UAT -Destination $DownloadDetailReportsFolderPath -Verbose
          
        }

        PreProd { 
            
            $DownloadSelectorReportsFolderPath = $ReportDownloadFolder + '\PreProd_' + $Folder.SelectorReports + '\' + $DateTimeFormatted
            $DownloadDetailReportsFolderPath = $ReportDownloadFolder + '\PreProd_' + $Folder.DetailReports + '\' + $DateTimeFormatted

            if (-not(Test-Path -Path $DownloadSelectorReportsFolderPath)) {New-Item -Path $DownloadSelectorReportsFolderPath -ItemType Directory}
            if (-not(Test-Path -Path $DownloadDetailReportsFolderPath)) {New-Item -Path $DownloadDetailReportsFolderPath -ItemType Directory}

            Get-RsFolderContent -ReportServerUri $ReportServerURL.UAT -RsFolder ($Folder.BreasePreProd + $Folder.SelectorReports) |  Where-Object TypeName -eq 'Report' |
                Select-Object -ExpandProperty Path |
                Out-RsCatalogItem -ReportServerUri $ReportServerURL.UAT -Destination $DownloadSelectorReportsFolderPath -Verbose

            Get-RsFolderContent -ReportServerUri $ReportServerURL.UAT -RsFolder ($Folder.BreasePreProd + $Folder.DetailReports) |  Where-Object TypeName -eq 'Report' |
                Select-Object -ExpandProperty Path |
                Out-RsCatalogItem -ReportServerUri $ReportServerURL.UAT -Destination $DownloadDetailReportsFolderPath -Verbose
          
        }

        QAEFinance { 
            
            $DownloadSelectorReportsFolderPath = $ReportDownloadFolder + '\QAEFinance_' + $Folder.SelectorReports + '\' + $DateTimeFormatted
            $DownloadDetailReportsFolderPath = $ReportDownloadFolder + '\QAEFinance_' + $Folder.DetailReports + '\' + $DateTimeFormatted

            if (-not(Test-Path -Path $DownloadSelectorReportsFolderPath)) {New-Item -Path $DownloadSelectorReportsFolderPath -ItemType Directory}
            if (-not(Test-Path -Path $DownloadDetailReportsFolderPath)) {New-Item -Path $DownloadDetailReportsFolderPath -ItemType Directory}

            Get-RsFolderContent -ReportServerUri $ReportServerURL.QAE -RsFolder ($Folder.BreaseQAEFinance + $Folder.SelectorReports) |  Where-Object TypeName -eq 'Report' |
                Select-Object -ExpandProperty Path |
                Out-RsCatalogItem -ReportServerUri $ReportServerURL.QAE -Destination $DownloadSelectorReportsFolderPath -Verbose

            Get-RsFolderContent -ReportServerUri $ReportServerURL.QAE -RsFolder ($Folder.BreaseQAEFinance + $Folder.DetailReports) |  Where-Object TypeName -eq 'Report' |
                Select-Object -ExpandProperty Path |
                Out-RsCatalogItem -ReportServerUri $ReportServerURL.QAE -Destination $DownloadDetailReportsFolderPath -Verbose
        }
    
        QAEMaintenance { 
            
            $DownloadSelectorReportsFolderPath = $ReportDownloadFolder + '\QAEMaintenance' + $Folder.SelectorReports + '\' + $DateTimeFormatted
            $DownloadDetailReportsFolderPath = $ReportDownloadFolder + '\QAEMaintenance' + $Folder.DetailReports + '\' + $DateTimeFormatted

            if (-not(Test-Path -Path $DownloadSelectorReportsFolderPath)) {New-Item -Path $DownloadSelectorReportsFolderPath -ItemType Directory}
            if (-not(Test-Path -Path $DownloadDetailReportsFolderPath)) {New-Item -Path $DownloadDetailReportsFolderPath -ItemType Directory}

            Get-RsFolderContent -ReportServerUri $ReportServerURL.QAE -RsFolder ($Folder.BreaseQAEMaintenance + $Folder.SelectorReports) |  Where-Object TypeName -eq 'Report' |
                Select-Object -ExpandProperty Path |
                Out-RsCatalogItem -ReportServerUri $ReportServerURL.QAE -Destination $DownloadSelectorReportsFolderPath -Verbose

            Get-RsFolderContent -ReportServerUri $ReportServerURL.QAE -RsFolder ($Folder.BreaseQAEMaintenance + $Folder.DetailReports) |  Where-Object TypeName -eq 'Report' |
                Select-Object -ExpandProperty Path |
                Out-RsCatalogItem -ReportServerUri $ReportServerURL.QAE -Destination $DownloadDetailReportsFolderPath -Verbose
        }

    }

}


