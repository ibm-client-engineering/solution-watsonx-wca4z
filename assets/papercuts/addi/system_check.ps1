$ErrorActionPreference = 'Stop'

$CPU = Get-WmiObject -Class Win32_Processor
$RAM = Get-WmiObject -Class Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
$OS = Get-WmiObject -Class Win32_OperatingSystem
$Disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"

if ($CPU.Name -notmatch 'Intel\(R\) Core\(TM\) i5|Intel\(R\) Core\(TM\) i7|Intel\(R\) Core\(TM\) i9|Intel Xeon') {
    Write-Warning "CPU is not Intel Core i5 or equivalent (CPU is $CPU.Name)"
}

if ($RAM.Sum -lt 32GB) {
    Write-Warning 'RAM is less than 32GB'
}

if ($OS.Caption -notmatch 'Windows 10|Windows 11|Windows Server 2012|Windows Server 2016|Windows Server 2019|Windows Server 2022') {
    Write-Warning 'OS is not Windows 10/11 (64-bit) or Windows Server 2012/2016/2019/2022'
}

if ($Disk.FreeSpace -lt 35GB) {
    Write-Warning 'Disk space is less than 35GB'
}
