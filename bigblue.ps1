#Requires -RunAsAdministrator
# First Arg
$param1 = $args[0]
# Second arg
$param2 = $args[1]
write-host "Powershell version # ...."
write-host $host.Version
write-host "`n `n"
If($param1 -eq 'lockdown'){
    write-host 'starting lockdown mode'
    
    #invoke-expression 'cmd /c start powershell -NoExit -Command {                           `
    #cd -path ~/Desktop;                  `
    #$host.UI.RawUI.WindowTitle = "BigBlue Defender Scan";                                `
    #color -background "red";
    #clear;
    #write-host "hello";                                                          `
    #}';
    write-host "Starting Windows Defender"
    Start-Service Windefend
    write-host "Verify that Windows Defender Service is running"
    Get-MpComputerStatus | fl Behavior*
    write-host "`n"
    write-host "Updating defender signautres"
    Update-MpSignature
    write-host "Enabling PUAProtection"
    Set-MpPreference -PUAProtection 1
    write-host "Enabling Real Time Monitoring"
    Set-MpPreference -DisableRealtimeMonitoring $false
    write-host "Enabling Behavior Monitoring"
    Set-MpPreference -DisableBehaviorMonitoring $false
    write-host "Enabling IPS"
    Set-MpPreference -DisableIntrusionPreventionSystem $false
    
}
elseif($param1 -eq 'blockip' -And $param2 -eq 'out'){
    write-host "Blocking ip for outbound traffic"
    $ip = Read-Host "Enter the ip address like x.x.x.x"
    echo "Blocking outbound tcp and udp for $ip"
    New-NetFirewallRule -DisplayName "Block $ip" -Direction Outbound -LocalPort Any -Protocol TCP -Action Block -RemoteAddress $ip
    New-NetFirewallRule -DisplayName "Block $ip" -Direction Outbound -LocalPort Any -Protocol UDP -Action Block -RemoteAddress $ip
}
elseif($param1 -eq 'blockip' -And $param2 -eq 'in'){
    write-host "Blocking ip for inbound traffic"
    $ip = Read-Host "Enter the ip address like x.x.x.x"
    echo "Blocking inbound tcp and udp for $ip"
    New-NetFirewallRule -DisplayName "Block $ip" -Direction Inbound -LocalPort Any -Protocol TCP -Action Block -RemoteAddress $ip
    New-NetFirewallRule -DisplayName "Block $ip" -Direction Inbound -LocalPort Any -Protocol UDP -Action Block -RemoteAddress $ip
}
elseif($param1 -eq 'gporeport'){
    Import-Module GroupPolicy
    Get-GPOReport -All -ReportType HTML | out-file .\BigBlue-GPOReport.html
}
elseif($param1 -eq 'gporeport' -And $param2 -eq 'hunt'){
    Import-Module grouppolicy
$ErrorActionPreference ='silentlycontinue'

# Key strings for scheduled tasks and logon/logoff scripts
$schedtasks = "scheduledtask"
$on_off = "command>"

$DomainName = $env:USERDNSDOMAIN
$GPOs = Get-GPO -All -Domain $DomainName
write-host "Finding all the GPOs in $DomainName"

# Search through each GPO's XML for the specific strings
Write-Host "Starting search...."
foreach ($gpo in $GPOs) 
    {
    $report = Get-GPOReport -Guid $gpo.Id -ReportType Xml
    if (($report -match $schedtasks) -or ($report -match $on_off)) 
        {
        write-host "********** Match(es) found in: $($gpo.DisplayName) **********"
        $report1 = $report -split ' '| sls 'name=', 'starthour=', 'args=','startIn=', 'comment=', 'filters'| Get-Unique
        $report2 = $report -split ' '| sls 'command>'

        if ($report1 -ne $null)
            {
            "#######################"
            "#   SCHEDULEDTASKS    #"   
            "#######################"   

             $report_out = ($report1 -replace '"',"")
             for ($i=6;$i -lt $report_out.count;$i+=7) 
                {
                $report_out[$i] = ' '
                }
             $report_out
            "#######################"
            " "
            }
        if ($report2 -ne $null)
            {
            $r2 = [string]$report2
            "#############################"
            "#   LOGON / LOGOFF SCRIPTS  #"   
            "#############################"
            ($r2.Split('<')).split('>')[2,6,10,14,18,22,26,30,34]
            "#############################"
            " "
            }
        }
    }
}
elseif($param1 -eq 'commands' -Or $param1 -eq 'help'){
    write-host "Listing all commands"
    write-host "blockip <in/out> ---- block an ip address for inbound or outbound tcp and udp traffic."
    write-host 'gporeport --- outputs a gpo report in a html file'
    write-host 'gporeport hunt ---- search through all gpos for scheduled tasks and logon/logoff scripts'
    write-host "lockdown"
}
else{
    write-host "Syntax Error"
    write-host "Proper Syntax: bigblue.ps1 <command> <args>"
    write-host "Type commands for a list of all commands" 
}