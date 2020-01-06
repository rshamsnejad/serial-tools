$COMport= new-Object System.IO.Ports.SerialPort COM6,115200,None,8,one

if(-not $COMport.IsOpen)
{
    $COMport.Open()
}

while(1)
{
    $InputChar = [char]$COMport.ReadChar()
    Write-Host -NoNewline $InputChar
}
