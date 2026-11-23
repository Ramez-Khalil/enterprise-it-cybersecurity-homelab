# System Inventory Report: read local facts, then export a CSV.
$ErrorActionPreference = 'Stop'
$os = Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
$windowsName = $os.ProductName
if ($os.InstallationType -eq 'Client' -and [int]$os.CurrentBuild -ge 22000) {
    $windowsName = $windowsName -replace '^Windows 10', 'Windows 11'
}
$cpu = (Get-Item -LiteralPath 'HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0').GetValue('ProcessorNameString')
# Total physical memory usable by Windows, not the amount currently free.
try {
    $memory = (Get-CimInstance -ClassName Win32_OperatingSystem).TotalVisibleMemorySize * 1KB
} catch {
    Add-Type -AssemblyName Microsoft.VisualBasic
    $memory = (New-Object Microsoft.VisualBasic.Devices.ComputerInfo).TotalPhysicalMemory
}
# Skip removable and network drives. Keep one row per ready fixed drive.
$disks = [System.IO.DriveInfo]::GetDrives() | Where-Object {
    $_.DriveType -eq 'Fixed' -and $_.IsReady
}
if ($memory -le 0 -or -not $disks) { throw 'Windows did not return memory or fixed disk information.' }

$columns = @(
    @{Name='Windows'; Expression={$windowsName}}
    @{Name='Version'; Expression={$os.DisplayVersion}}
    @{Name='Build'; Expression={"$($os.CurrentBuild).$($os.UBR)"}}
    @{Name='CPU'; Expression={$cpu}}
    @{Name='RAMGiB'; Expression={[math]::Round($memory / 1GB, 1)}}
    @{Name='Drive'; Expression={$_.Name}}
    @{Name='SizeGiB'; Expression={[math]::Round($_.TotalSize / 1GB, 1)}}
    @{Name='FreeGiB'; Expression={[math]::Round($_.AvailableFreeSpace / 1GB, 1)}}
)
$inventory = $disks | Select-Object -Property $columns
# Write next to the script. Repeat runs refresh this lab-owned report.
$reportPath = Join-Path $PSScriptRoot 'System-Inventory.csv'
$inventory | Export-Csv -LiteralPath $reportPath -NoTypeInformation -Encoding UTF8
Write-Host "Report saved to: $reportPath"
$inventory | Format-Table -AutoSize
