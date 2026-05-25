#Write whatever is recieved on that port

$port = 9401
$endpoint = new-object System.Net.IPEndPoint ([IPAddress]::Any,$port)
$udpclient = new-Object System.Net.Sockets.UdpClient $port
while($true){
	$content = $udpclient.Receive([ref]$endpoint)
	Write-Host "$([System.BitConverter]::ToInt16($content,0))"
}