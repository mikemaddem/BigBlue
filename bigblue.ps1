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
    #New-NetFirewallRule -DisplayName "Block $ip" -Direction Outbound -LocalPort Any -Protocol TCP -Action Block -RemoteAddress $ip
    #New-NetFirewallRule -DisplayName "Block $ip" -Direction Outbound -LocalPort Any -Protocol UDP -Action Block -RemoteAddress $ip
}
elseif($param1 -eq 'blockip' -And $param2 -eq 'in'){
    write-host "Blocking ip for inbound traffic"
    $ip = Read-Host "Enter the ip address like x.x.x.x"
    echo "Blocking inbound tcp and udp for $ip"
    #New-NetFirewallRule -DisplayName "Block $ip" -Direction Inbound -LocalPort Any -Protocol TCP -Action Block -RemoteAddress $ip
    #New-NetFirewallRule -DisplayName "Block $ip" -Direction Inbound -LocalPort Any -Protocol UDP -Action Block -RemoteAddress $ip
}
elseif($param1 -eq 'commands' -Or $param1 -eq 'help'){
    write-host "Listing all commands"
    write-host "blockip <in/out> ---- block an ip address for inbound or outbound tcp and udp traffic."
    write-host "lockdown"
}
else{
    write-host "Syntax Error"
    write-host "Proper Syntax: bigblue.ps1 <command> <args>"
    write-host "Type commands for a list of all commands" 
}