#Send one packet per second
#Write the incremented value to console and over the line
#Pause if 'p' hit
#Quit if 'q' hit

$ip = "172.26.12.94"
$port = 9400
$udpClient = New-Object System.Net.Sockets.UdpClient($port)
$udpClient.Connect($ip, $port)
$paused = $false
$exit = $false
$counter = 1
while (!$exit) {
    Start-Sleep 1
	
	if (!$paused){
		Write-Host "packet $counter"
		$a = [System.BitConverter]::GetBytes($counter)
		$ignore = $udpClient.Send($a, $a.Length)
		$counter++
	}
	
	while ([Console]::KeyAvailable) {
		$key = [Console]::ReadKey($true).Key.ToString()
		if ( $key -eq 'p' ){ 
			$paused = !$paused 
			Write-Host "Paused: $paused"
		}
		if ( $key -eq 'q' ){ $exit = $true }
	}
}
$udpClient.Close()