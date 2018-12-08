sl C:\SQLDSCInstall\SQLMofFiles\

Configuration DSCModules
{
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $PackagePath
    )

    
Import-DscResource –ModuleName PSDesiredStateConfiguration

 Node $AllNodes.NodeName
    {
        Log ParamLog
        {
            Message = "Running DSCModules deployment. PackagePath = $PackagePath"
        }


        File CopyDSCModulesToServers 
        {
            Ensure = "Present"
            Type = "Directory"
            Recurse = $true
            MatchSource = $true
            SourcePath = "$PackagePath\Modules"
            DestinationPath = $Node.ModulePath
        }
    }
 }

DSCModules -ConfigurationData C:\SQLDSCInstall\SetupScripts\ServerConfiguration.psd1 -PackagePath "\\DC1\InstallMedia" -verbose 

Start-DscConfiguration -Path C:\SQLDSCInstall\SQLMofFiles\DSCModules -Wait -Force -Verbose
