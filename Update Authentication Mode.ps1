#import SQL Server module
Import-Module SQLPS -DisableNameChecking

#replace this with your instance name
$instanceName = "localhost"
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName

#according to MSDN, there are four (4) possible
#values for LoginMode:
#Normal, Integrated, Mixed and Unknown
$server.settings.LoginMode ='MIXED'
$server.settings.Alter()
$server | Get-Member

$server.settings.Urn

Import-Module SQLPS -DisableNameChecking
$instanceName = "localhost"
$sql = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
$sql.Settings

$sql.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Mixed
$sql.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Integrated
$sql.Settings.Alter()
