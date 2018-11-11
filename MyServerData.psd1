@{
    AllNodes = 
     @(
        @{
            NodeName = '*'
            PSDscAllowDomainUser = $true
        }
           
         @{
           NodeName = 'Client1'
           Role = @('SQLENGINE')
           Configuration = 'SQL2017Config.ini'
           SQLServerServiceAccount = 'TestLab\Administrator'
           SQLServerAgentServiceAccount = 'TestLab\Administrator'
       
         }
        <#
         @{
           NodeName = 'Client2'
           Role = @('SQLENGINE')
         }

        @{
           NodeName = 'Client3'
           Role = @('SQLENGINE')
           
         }

         @{
           NodeName = 'Client4'
           Role = @('SQLENGINE')
          }
          
          @{
           NodeName = 'Client5'
           Role = @('SQLENGINE')
          }
          
         @{
           NodeName = 'Client5'
           Role = @('SQLENGINE')
           Configuration = 'SQL2017Config.ini'
           SQLServerServiceAccount = 'TestLab\Administrator'
           SQLServerAgentServiceAccount = 'TestLab\Administrator'
           SAPwd = 'Somepass1'
           SSISCatalogPWD = "Somepass1"
           SQLAuditFolder = "C:\SQLAudit\"
           TCPPort = "1433"
         }
         #>
         
  )
}
