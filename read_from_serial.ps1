$COMport= new-Object System.IO.Ports.SerialPort COM6,9600,None,8,one

if(-not $COMport.IsOpen)
{
    $COMport.Open()
}

while(1)
{
    $COMport.ReadLine()
    Start-Sleep -Seconds 1
}
