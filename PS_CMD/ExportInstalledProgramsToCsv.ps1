# Define the registry locations for 64-bit and 32-bit installed programs
$RegPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$dir = [Environment]::GetFolderPath("Desktop")

# Grab the software information, filter out blank rows, and sort by name
Get-ItemProperty -Path $RegPaths |
    Where-Object { $_.DisplayName -and $_.SystemComponent -ne 1 } |
    Select-Object DisplayName, DisplayVersion |
    Sort-Object DisplayName |
    Export-Csv -Path "$dir\InstalledSoftware.csv" -NoTypeInformation