$targets = "google.ca","123.123.123.123","someMachineName" #List of machine names or IP addresses
$intervalMs = 1000 #ms between pings
$numberOfPings = 0 #number of pings to run before stopping, 0 to run forever
$slowPingMs = 100 #pings over this number of ms will be logged

###region Configuration###

#Logging
#Where do you want the log, and what name? ie: "c:\logs\log.txt"
$logFilePath = ".\ping_log.txt"
#How many lines of log do you want to keep? Setting to 0 or 1 will clear the log file on each start.
$logLength = 10000

###endregion Configuration###

###region Functions###

#region Logging functions

#Writes a string to console and to the log file
Function Log($someText)
{
	Write-Host $someText
	"$someText" | Out-File -FilePath "$logFilePath" -Append -Encoding Unicode
}

#Trims the log file to the log length configured
Function TrimLogFile
{
	try{
		if (Test-Path $logFilePath)
		{
			Get-Content -Tail $logLength $logFilePath | Set-Content $logFilePath
		}
		else
		{
			New-Item -Path $logFilePath -ItemType File -Force
		}
	}
	catch
	{
	}
}

#Logs and records start of script
Function LogStart
{
	TrimLogFile
	$global:executionLogStartTime = Get-Date
	Log("")
	Log("----Start Processing $global:executionLogStartTime----")
}

#Logs and records end of script, trims log file
Function LogEnd
{
	$executionEndTime = Get-Date
	$duration = [int]($executionEndTime-$global:executionLogStartTime).TotalMilliseconds
	Log("----End Processing $executionEndTime, Duration in ms: $duration----")
	Log("")
}
#endregion Logging functions

$ErrorActionPreference = 'Stop'
try
{	
	if ($numberOfPings -eq 0) {LogStart}
	TrimLogFile

	$loopCounter = 1

	while ($loopCounter -ne $numberOfPings) {
		
		foreach ($target in $targets){
			$result = Test-Connection -ComputerName $target -Count 1 -ErrorAction SilentlyContinue
			$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

			if ($result) {
				"$timestamp - Ping to $target successful. Latency: $($result.ResponseTime)ms"
				if ($result.ResponseTime -gt $slowPingMs){
					Log "$timestamp - Ping to $target slow: $($result.ResponseTime)ms"
				}
			} else {
				Log "$timestamp - Ping to $target failed."
			}
		}
		
		if ($loopCounter % 10000 -eq 0)
		{
			TrimLogFile
		}
		Start-Sleep -Milliseconds $intervalMs
		$loopCounter++
	}
}
catch
{
	Log("$($_.Exception.Message)")
}
finally
{
	if ($numberOfPings -eq 0) {LogEnd}
}