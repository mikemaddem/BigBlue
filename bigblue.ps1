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
}

else{
write-host "Syntax Error"
write-host "Proper Syntax: bigblue.ps1 lockdown"
}