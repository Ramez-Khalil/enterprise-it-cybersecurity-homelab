# PowerShell Lab: Windows System Inventory

A beginner Windows administration lab that records the OS, CPU, usable RAM and free space on local fixed drives. It prints a table and saves one CSV row per ready fixed drive. The script reads system information and writes only its report. It does not change settings or contact other machines.

## Run the lab

Use PowerShell on Windows. The lab was tested with PowerShell 7.6.9 on Windows 11. No administrator privileges or extra modules were needed for the verified run. Open PowerShell in this folder:

```powershell
.\System-Inventory.ps1
Import-Csv .\System-Inventory.csv | Format-Table -AutoSize
```

The CSV is saved next to the script. Running it again replaces that report. [See a synthetic sample](examples/sample-inventory.csv). The sample does not describe the test computer.

## What to notice

1. **Collect:** `Get-ItemProperty`, `Get-Item` and `Get-CimInstance` read system facts into variables.
2. **Filter:** `Where-Object` keeps ready fixed drives and skips removable and network drives.
3. **Shape:** `Select-Object` builds the columns. `RAMGiB` is usable physical memory on the tested system, not memory currently free. `FreeGiB` is disk space available to the current user.
4. **Export and verify:** `Export-Csv` saves the objects before `Format-Table` displays them. `Import-Csv` confirms that the file can be read back.

## Verification and limits

- PowerShell parser: zero errors.
- Windows run: exit code 0; the generated CSV was re-imported successfully.
- Older PowerShell releases, multi-drive configurations and the memory fallback were not independently verified.
- Keep generated CSVs local. The script does not collect hostnames, usernames, serial numbers or IP addresses, but the report still describes the computer that produced it.

**Try it yourself:** Re-import the CSV, sort the rows by available space and explain why `[double]` is needed:

```powershell
Import-Csv .\System-Inventory.csv | Sort-Object { [double]$_.FreeGiB }
```
