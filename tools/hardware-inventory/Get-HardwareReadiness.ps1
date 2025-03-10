# Windows 11 Hardware Readiness Assessment Tool
# This script checks if a device meets the minimum hardware requirements for Windows 11

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "$env:USERPROFILE\Desktop\Win11ReadinessReport.csv",
    
    [Parameter(Mandatory=$false)]
    [switch]$ExportToCSV = $true,
    
    [Parameter(Mandatory=$false)]
    [switch]$CheckRemoteComputers = $false,
    
    [Parameter(Mandatory=$false)]
    [string]$ComputerList = ""
)

# Minimum requirements for Windows 11
$MinimumRequirements = @{
    ProcessorFrequency = 1.0 # GHz
    ProcessorCores = 2
    RAM = 4 # GB
    Storage = 64 # GB
    TPMVersion = 2.0
    SecureBoot = $true
    UEFI = $true
}

function Get-ComputerInfo {
    param (
        [Parameter(Mandatory=$false)]
        [string]$ComputerName = $env:COMPUTERNAME
    )
    
    try {
        Write-Host "Checking hardware compatibility for $ComputerName..."
        
        # Create result object
        $Result = New-Object PSObject -Property @{
            ComputerName = $ComputerName
            Manufacturer = "Unknown"
            Model = "Unknown"
            SerialNumber = "Unknown"
            BIOSVersion = "Unknown"
            ProcessorName = "Unknown"
            ProcessorFrequency = 0
            ProcessorCores = 0
            RAM = 0
            StorageAvailable = 0
            TPMPresent = $false
            TPMVersion = "Unknown"
            TPMEnabled = $false
            SecureBootSupported = $false
            SecureBootEnabled = $false
            UEFICapable = $false
            Windows11Ready = $false
            FailureReasons = @()
        }
        
        # Get computer system info
        $ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ComputerName
        $Result.Manufacturer = $ComputerSystem.Manufacturer
        $Result.Model = $ComputerSystem.Model
        
        # Get BIOS info
        $BIOS = Get-WmiObject -Class Win32_BIOS -ComputerName $ComputerName
        $Result.SerialNumber = $BIOS.SerialNumber
        $Result.BIOSVersion = $BIOS.SMBIOSBIOSVersion
        
        # Determine if system is UEFI
        $UEFIInfo = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty BootupState
        $Result.UEFICapable = ($UEFIInfo -ne "Legacy")
        
        # Get processor info
        $Processor = Get-WmiObject -Class Win32_Processor -ComputerName $ComputerName
        $Result.ProcessorName = $Processor.Name
        $Result.ProcessorFrequency = [math]::Round($Processor.MaxClockSpeed / 1000, 2) # Convert MHz to GHz
        $Result.ProcessorCores = $Processor.NumberOfCores
        
        # Get RAM info
        $Result.RAM = [math]::Round($ComputerSystem.TotalPhysicalMemory / 1GB, 2)
        
        # Get storage info
        $SystemDrive = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $ComputerName -Filter "DeviceID='C:'"
        $Result.StorageAvailable = [math]::Round($SystemDrive.Size / 1GB, 2)
        
        # Get TPM info
        try {
            $TPM = Get-WmiObject -Class Win32_Tpm -Namespace root\CIMV2\Security\MicrosoftTpm -ComputerName $ComputerName -ErrorAction Stop
            $Result.TPMPresent = $true
            $Result.TPMEnabled = ($TPM.IsEnabled_InitialValue -eq $true)
            $Result.TPMVersion = $TPM.SpecVersion
        } catch {
            $Result.TPMPresent = $false
            $Result.TPMEnabled = $false
            $Result.TPMVersion = "Not Available"
        }
        
        # Get Secure Boot info
        try {
            $SecureBoot = Confirm-SecureBootUEFI -ErrorAction Stop
            $Result.SecureBootSupported = $true
            $Result.SecureBootEnabled = $SecureBoot
        } catch {
            $Result.SecureBootSupported = $false
            $Result.SecureBootEnabled = $false
        }
        
        # Check if system meets Windows 11 requirements
        $FailureReasons = @()
        
        if ($Result.ProcessorFrequency -lt $MinimumRequirements.ProcessorFrequency) {
            $FailureReasons += "Processor frequency below 1 GHz"
        }
        
        if ($Result.ProcessorCores -lt $MinimumRequirements.ProcessorCores) {
            $FailureReasons += "Processor has fewer than 2 cores"
        }
        
        if ($Result.RAM -lt $MinimumRequirements.RAM) {
            $FailureReasons += "RAM below 4 GB"
        }
        
        if ($Result.StorageAvailable -lt $MinimumRequirements.Storage) {
            $FailureReasons += "Storage below 64 GB"
        }
        
        if (-not $Result.TPMPresent) {
            $FailureReasons += "TPM not present"
        } elseif (-not $Result.TPMEnabled) {
            $FailureReasons += "TPM not enabled"
        } elseif ([version]$Result.TPMVersion -lt [version]$MinimumRequirements.TPMVersion) {
            $FailureReasons += "TPM version below 2.0"
        }
        
        if (-not $Result.SecureBootSupported) {
            $FailureReasons += "Secure Boot not supported"
        } elseif (-not $Result.SecureBootEnabled) {
            $FailureReasons += "Secure Boot not enabled"
        }
        
        if (-not $Result.UEFICapable) {
            $FailureReasons += "UEFI not supported"
        }
        
        $Result.FailureReasons = $FailureReasons
        $Result.Windows11Ready = ($FailureReasons.Count -eq 0)
        
        return $Result
    } catch {
        Write-Error "Error checking hardware compatibility for $ComputerName: $_"
        return $null
    }
}

# Main script logic
$Results = @()

if ($CheckRemoteComputers -and -not [string]::IsNullOrEmpty($ComputerList)) {
    if (Test-Path -Path $ComputerList) {
        $Computers = Get-Content -Path $ComputerList
        foreach ($Computer in $Computers) {
            $Result = Get-ComputerInfo -ComputerName $Computer
            if ($Result) {
                $Results += $Result
            }
        }
    } else {
        Write-Error "Computer list file not found: $ComputerList"
    }
} else {
    $Result = Get-ComputerInfo
    if ($Result) {
        $Results += $Result
    }
}

# Display results
foreach ($Result in $Results) {
    Write-Host "`n----- Hardware Assessment for $($Result.ComputerName) -----" -ForegroundColor Cyan
    Write-Host "Manufacturer: $($Result.Manufacturer)"
    Write-Host "Model: $($Result.Model)"
    Write-Host "Serial Number: $($Result.SerialNumber)"
    Write-Host "BIOS Version: $($Result.BIOSVersion)"
    Write-Host "Processor: $($Result.ProcessorName)"
    Write-Host "Processor Frequency: $($Result.ProcessorFrequency) GHz"
    Write-Host "Processor Cores: $($Result.ProcessorCores)"
    Write-Host "RAM: $($Result.RAM) GB"
    Write-Host "Storage: $($Result.StorageAvailable) GB"
    Write-Host "TPM Present: $($Result.TPMPresent)"
    Write-Host "TPM Version: $($Result.TPMVersion)"
    Write-Host "TPM Enabled: $($Result.TPMEnabled)"
    Write-Host "Secure Boot Supported: $($Result.SecureBootSupported)"
    Write-Host "Secure Boot Enabled: $($Result.SecureBootEnabled)"
    Write-Host "UEFI Capable: $($Result.UEFICapable)"
    
    Write-Host "`nWindows 11 Ready: " -NoNewline
    if ($Result.Windows11Ready) {
        Write-Host "Yes" -ForegroundColor Green
    } else {
        Write-Host "No" -ForegroundColor Red
        Write-Host "Failure Reasons:"
        foreach ($Reason in $Result.FailureReasons) {
            Write-Host " - $Reason" -ForegroundColor Yellow
        }
    }
}

# Export results to CSV if specified
if ($ExportToCSV) {
    $ExportResults = $Results | ForEach-Object {
        $ExportResult = $_ | Select-Object -Property * -ExcludeProperty FailureReasons
        $ExportResult | Add-Member -MemberType NoteProperty -Name "FailureReasons" -Value ($_.FailureReasons -join "; ")
        $ExportResult
    }
    
    try {
        $ExportResults | Export-Csv -Path $OutputPath -NoTypeInformation
        Write-Host "`nResults exported to $OutputPath" -ForegroundColor Green
    } catch {
        Write-Error "Failed to export results to CSV: $_"
    }
}

# Return summary
$TotalComputers = $Results.Count
$ReadyComputers = ($Results | Where-Object { $_.Windows11Ready }).Count
$NotReadyComputers = $TotalComputers - $ReadyComputers

Write-Host "`n----- Summary -----" -ForegroundColor Cyan
Write-Host "Total computers scanned: $TotalComputers"
Write-Host "Ready for Windows 11: $ReadyComputers"
Write-Host "Not ready for Windows 11: $NotReadyComputers"
Write-Host "Readiness percentage: $([math]::Round(($ReadyComputers / $TotalComputers) * 100, 2))%"