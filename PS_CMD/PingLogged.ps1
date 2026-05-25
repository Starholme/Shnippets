$target = "someserver" # Or an IP address
$logFile = ".\ping_log.txt"
$intervalMs = 250 #ms between pings

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
"****$timestamp - Ping to $target started****" | Out-File -FilePath $logFile -Append

while ($true) {
    $result = Test-Connection -ComputerName $target -Count 1 -ErrorAction SilentlyContinue
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    if ($result) {
        "$timestamp - Ping to $target successful. Latency: $($result.ResponseTime)ms"
		if ($result.ResponseTime > 50){
			"$timestamp - Ping to $target slow: $($result.ResponseTime)ms" | Out-File -FilePath $logFile -Append
		}
    } else {
        "$timestamp - Ping to $target failed." | Out-File -FilePath $logFile -Append
    }
    Start-Sleep -Milliseconds $intervalMs # Adjust the interval as needed
}