sl C:\DSC\

Configuration DSCModules
{
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $PackagePath
    )

Import-DscResource –ModuleName PSDesiredStateConfiguration

 Node $AllNodes.where{ $_.Role.Contains("SQLENGINE") }.NodeName
    {
        Log ParamLog
        {
            Message = "Running DSCModules deployment. PackagePath = $PackagePath"
        }


        #Copy the xSQLServer and xComputerManagement modules
        File CopyDSCModules {
            Ensure = "Present"
            Type = "Directory"
            Recurse = $true
            MatchSource = $true
            SourcePath = "$PackagePath\Modules"
            DestinationPath = "C:\Program Files\WindowsPowershell\Modules\"
        }
        }
    }

DSCModules -ConfigurationData C:\DSC\MyServerData.psd1 -PackagePath "\\DC1\InstallMedia" -verbose

Start-DscConfiguration -Path C:\DSC\DSCModules -Wait -Force -Verbose
