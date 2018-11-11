sl C:\DSC\

Configuration SQLInstall
{
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $PackagePath

       # [Parameter(Mandatory = $true)]
       # [System.Management.Automation.PSCredential]
       # [System.Management.Automation.Credential()]
       
    )
    Import-DscResource –ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName xComputerManagement
    Import-DSCResource -ModuleName xSQLServer
    Import-DSCResource -ModuleName SQLServer
    Import-DSCResource -ModuleName ComputerManagementDsc
    Import-DscResource -ModuleName SqlServerDsc
    
    Node $AllNodes.where{ $_.Role.Contains("SQLENGINE") }.NodeName
    {
        
       
                        
        Log ParamLog
        {
            Message = "Running SQLInstall. PackagePath = $PackagePath"
        }
       
        # copy the sqlserver iso to all servers
        File SQLServerIso2016
        {
            SourcePath = "$PackagePath\SQL2016\en_sql_server_2016_developer_with_service_pack_1_x64_dvd_9548071.iso"
            DestinationPath = "C:\SQLSetup\SQLInstall\SQLServer2016.iso"
            Type = "File"
            Ensure = "Present"
        }
        
        #copy SSMS exe to all servers
         File SQLServerSSMS
        {
            SourcePath = "$PackagePath\SSMS-Setup-ENU.exe"
            DestinationPath = "C:\SQLSetup\SQLInstall\SSMS-Setup-ENU.exe"
            Type = "File"
            Ensure = "Present"
        }
        
        # copy the .sql scripts to the temp folder
        File ManagementDBScripts
        {
            SourcePath = "$PackagePath\ManagementDBs\"
            DestinationPath = "C:\SQLSetup\ManagementDBScripts\"
            Type = "Directory"
            Recurse = $true
            MatchSource = $true
            Ensure = "Present"
            DependsOn = "[SqlSetup]InstallDefaultInstance" 
        }

        #copy SSMS exe to all servers
         File AdventureWorksBackup
        {
            SourcePath = "$PackagePath\AdventureWorks\AdventureWorks2014.bak"
            DestinationPath = "C:\SQLSetup\AdventureWorks\AdventureWorks2014.bak"
            Type = "File"
            Ensure = "Present"
        }

        WindowsFeature 'NetFramework45'
        {
        Name = 'NET-Framework-45-Core'
        Ensure = 'Present'
        }
         
        # Install SqlServer 
        Script CreateSQLInstallFolder
        {
            GetScript =
            {
                $PathCheck = Test-Path -Path "C:\SQL2016\"
                
                $vals = @{
                    Exist = $PathCheck;
                    
                }
                $vals
            }
            SetScript =
            {
                
                $script = 
                {
                $setupDriveLetter = (Mount-DiskImage -ImagePath C:\SQLSetup\SQLInstall\SQLServer2016.iso -PassThru | Get-Volume).DriveLetter + ":\"
                if ($setupDriveLetter -eq $null) {
                throw "Could not mount SQL install iso"
                                                }
                 Copy-item -Force -Recurse -Verbose $setupDriveLetter -Destination C:\SQL2016\
                 #dismount the iso
                 Dismount-DiskImage -ImagePath C:\SQLSetup\SQLInstall\SQLServer2016.iso
                 }
                    Invoke-Command -ComputerName localhost -ScriptBlock $script
            }
            TestScript =
            {
                $PathCheck = Test-Path -Path "C:\SQL2016\"
                
                $res = $PathCheck
                if ($res) {
                    Write-Verbose "Folder already created"
                } else {
                    Write-Verbose "Folder not created"
                }
                $res
            }
            DependsOn = "[File]SQLServerIso2016"
        }
        
        SqlSetup InstallDefaultInstance
      {
           InstanceName = 'MSSQLSERVER'
           Features = 'SQLENGINE'
           SourcePath = 'C:\SQL2016'
           SQLSysAdminAccounts = @('Administrators','TESTLAB\conrad','TESTLAB\SQLService','TESTLAB\SQLAgentService')
           InstallSQLDataDir = 'C:\SQLData'
           SQLTempDBDir = 'C:\SQLData'
           SQLTempDBLogDir = 'C:\SQLLog'
           SQLUserDBDir = 'C:\SQLData'
           SQLUserDBLogDir = 'C:\SQLLog'
           #SecurityMode = 'SQL'
           DependsOn = '[WindowsFeature]NetFramework45','[Script]CreateSQLInstallFolder'
            
      }

      SqlDatabase DBAToolKit
       {
            InstanceName = ‘MSSQLSERVER’
            Name = ’DBAToolKit’
            ServerName = ‘localhost’
            DependsOn = '[SqlSetup]InstallDefaultInstance'
            Ensure = ‘Present’
    
      }

    SqlDatabase DBAdmin
       {
            InstanceName = ‘MSSQLSERVER’
            Name = ’DBAdmin’
            ServerName = ‘localhost’
            DependsOn = '[SqlSetup]InstallDefaultInstance'
            Ensure = ‘Present’
    
      }

       SqlServerNetwork SqlNetworkSetup
        {
    InstanceName = ‘MSSQLSERVER’
    ProtocolName = 'Tcp'
    IsEnabled = $true
    DependsOn = '[SqlSetup]InstallDefaultInstance'
    ServerName = ‘localhost’
    RestartService = $true
    TcpPort = 1433     
    }
    
    
        SQLScript WhoIsActive 
       {
            ServerInstance = "localhost"
            SetFilePath = "C:\SQLSetup\ManagementDBScripts\Set-who_is_active_v11_17.sql"
            GetFilePath = "C:\SQLSetup\ManagementDBScripts\Get-WhoIsActive.sql"
            TestFilePath = "C:\SQLSetup\ManagementDBScripts\Test-WhoIsActive.sql"
            QueryTimeout = 600
           DependsOn = "[SqlSetup]InstallDefaultInstance"
        }
        
        #deploy standard operators
        SQLScript Operators 
       {
            ServerInstance = "localhost"
            SetFilePath = "C:\SQLSetup\ManagementDBScripts\Set-Operator.sql"
            GetFilePath = "C:\SQLSetup\ManagementDBScripts\Get-Operator.sql"
            TestFilePath = "C:\SQLSetup\ManagementDBScripts\Test-Operator.sql"
            QueryTimeout = 600
            DependsOn = "[SqlSetup]InstallDefaultInstance"
       }
       
       #Install SSMS on all servers
       Package SSMS
        {
            Name = "SSMS-Setup-ENU"
            Path = "C:\SQLSetup\SQLInstall\SSMS-Setup-ENU.exe"
            ProductId = "1B8CFC46-1F08-4DA7-9FEA-E1F523FBD67F"
            Ensure =  "Present"
            Arguments = "/install /passive /restart"
    
        }
        
        <#
        # Enable TCP 
        Script Enable_TCP
        {
            GetScript =
            {
                
                $ServerName =$env:COMPUTERNAME
                $smo = 'Microsoft.SqlServer.Management.Smo.'  
                $wmi = new-object ($smo + 'Wmi.ManagedComputer').  
                $uri = "ManagedComputer[@Name= '$ServerName']/ ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='Tcp']"  
                $Tcp = $wmi.GetSmoObject($uri)  
                $Result = $Tcp.IsEnabled
                $Result
            }
            SetScript =
            {
                
                $ServerName =$env:COMPUTERNAME
                $smo = 'Microsoft.SqlServer.Management.Smo.'  
                $wmi = new-object ($smo + 'Wmi.ManagedComputer').  
                $uri = "ManagedComputer[@Name= '$ServerName']/ ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='Tcp']"  
                $Tcp = $wmi.GetSmoObject($uri) 
                $Tcp.IsEnabled = $true  
                $Tcp.Alter()  
            }
            TestScript =
            {
                $ServerName =$env:COMPUTERNAME
                $smo = 'Microsoft.SqlServer.Management.Smo.'  
                $wmi = new-object ($smo + 'Wmi.ManagedComputer').  
                $uri = "ManagedComputer[@Name= '$ServerName']/ ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='Tcp']"  
                $Tcp = $wmi.GetSmoObject($uri)  
                $Result = $Tcp.IsEnabled
                $Result
                if ($Result) {
                    Write-Verbose "TCP is already enabled"
                } else {
                    Write-Verbose "TCP not enabled"
                }
                $Result
            }
            DependsOn = "[SqlSetup]InstallDefaultInstance"


        }
        #>

        
        # Set Authentication Mode to MIXED 
        Script SetAuthentionMode
        {
            GetScript =
            {
                
                $instanceName = "localhost"
                $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName 
                $Result = $server.settings.LoginMode
                $Result = ($server.settings.LoginMode -eq 'MIXED') 
                $Result
            }
            SetScript =
            {
                $instanceName = "localhost"
                $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
                $server.settings.LoginMode ='MIXED'
                $server.settings.Alter()   
            }
            TestScript =
            {
                $instanceName = "localhost"
                $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName 
                $Result = $server.settings.LoginMode
                $Result = ($server.settings.LoginMode -eq 'MIXED') 
                $Result
                if ($Result) {
                    Write-Verbose "Authentication is already set to MIXED Mode"
                } else {
                    Write-Verbose "Authentication being set to MIXED Mode"
                }
                $Result
            }
            DependsOn = "[SqlSetup]InstallDefaultInstance"


        }
        


        # Enable Named Pipes 
        Script EnableNamedPipes
        {
            GetScript =
            {
                
                $ServerName =$env:COMPUTERNAME
                $smo = 'Microsoft.SqlServer.Management.Smo.'  
                $wmi = new-object ($smo + 'Wmi.ManagedComputer').  
                $uri = "ManagedComputer[@Name= '$ServerName']/ ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='np']"  
                $np = $wmi.GetSmoObject($uri)  
                $Result = $np.IsEnabled
                $Result
            }
            SetScript =
            {
                
                $ServerName =$env:COMPUTERNAME
                $smo = 'Microsoft.SqlServer.Management.Smo.'  
                $wmi = new-object ($smo + 'Wmi.ManagedComputer').  
                $uri = "ManagedComputer[@Name= '$ServerName']/ ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='np']"  
                $np = $wmi.GetSmoObject($uri) 
                $np.IsEnabled = $true  
                $np.Alter()  
                
            }
            TestScript =
            {
                $ServerName =$env:COMPUTERNAME
                $smo = 'Microsoft.SqlServer.Management.Smo.'  
                $wmi = new-object ($smo + 'Wmi.ManagedComputer').  
                $uri = "ManagedComputer[@Name= '$ServerName']/ ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='np']"  
                $np = $wmi.GetSmoObject($uri)  
                $Result = $np.IsEnabled
                $Result
                if ($Result) {
                    Write-Verbose "Named Pipes already enabled"
                } else {
                    Write-Verbose "Named Pipes not enabled"
                }
                $Result
            }
            DependsOn = "[SqlSetup]InstallDefaultInstance"

            }

        <#
        SQLScript AdventureWorks 
       {
            ServerInstance = "localhost"
            SetFilePath = "C:\SQLSetup\ManagementDBScripts\Set-AdventureWorks2014.sql"
            GetFilePath = "C:\SQLSetup\ManagementDBScripts\Get-AdventureWorks2014.sql"
            TestFilePath = "C:\SQLSetup\ManagementDBScripts\Test-AdventureWorks2014.sql"
            QueryTimeout = 600
           DependsOn = "[SqlSetup]InstallDefaultInstance"
        }
        #>
    }
}
 
SQLInstall -ConfigurationData C:\DSC\MyServerData.psd1 -PackagePath "\\DC1\InstallMedia" -Verbose

Start-DscConfiguration -Path C:\DSC\SQLInstall -Wait -Force -Verbose
