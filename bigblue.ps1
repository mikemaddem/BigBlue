# First Arg
$param1 = $args[0]
# Second arg
$param2 = $args[1]

If($param1 -eq 'lockdown'){
    write-host 'starting lockdown mode'
    
    invoke-expression 'cmd /c start powershell -NoExit -Command {                           `
    cd -path ~/Desktop;                  `
    $host.UI.RawUI.WindowTitle = "BigBlue Defender Scan";                                `
    color -background "red";
    clear;
    write-host "hello";                                                          `
}';
    write-host "Verify that Windows Defender Service is running"
    Get-Service "WinDefend"
}
If($param1 -eq 'blockip' -And $param2 -eq 'out'){
    write-host "Blocking ip for outbound traffic"
    $ip = Read-Host "Enter the ip address like x.x.x.x"
    echo "Blocking outbound tcp and udp for $ip"
    New-NetFirewallRule -DisplayName "Block $ip" -Direction Outbound -LocalPort Any -Protocol TCP -Action Block -RemoteAddress $ip
    New-NetFirewallRule -DisplayName "Block $ip" -Direction Outbound -LocalPort Any -Protocol UDP -Action Block -RemoteAddress $ip
}
If($param1 -eq 'blockip' -And $param2 -eq 'in'){
    write-host "Blocking ip for outbound traffic"
    $ip = Read-Host "Enter the ip address like x.x.x.x"
    echo "Blocking outbound tcp and udp for $ip"
    New-NetFirewallRule -DisplayName "Block $ip" -Direction Inbound -LocalPort Any -Protocol TCP -Action Block -RemoteAddress $ip
    New-NetFirewallRule -DisplayName "Block $ip" -Direction Inbound -LocalPort Any -Protocol UDP -Action Block -RemoteAddress $ip
}
else{
write-host "Syntax Error"
write-host "Proper Syntax: bigblue.ps1 lockdown"
}