# Apply Drivers Script
# This script is used to apply device-specific drivers during Windows 11 deployment

# Parameters
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$DriverPackagePath,
    
    [Parameter(Mandatory=$false)]
    [string]$LogPath = "$env:TEMP\driver-application.log"
)

# Function to write to log file
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    $FormattedDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $LogMessage = "[$FormattedDate] [$Level] $Message"
    
    # Write to log file
    Add-Content -Path $LogPath -Value $LogMessage
    
    # Also output to console
    switch ($Level) {
        'Info'    { Write-Host $LogMessage }
        'Warning' { Write-Host $LogMessage -ForegroundColor Yellow }
        'Error'   { Write-Host $LogMessage -ForegroundColor Red }
    }
}

# Function to detect computer model
function Get-ComputerModel {
    try {
        $Manufacturer = (Get-WmiObject -Class Win32_ComputerSystem).Manufacturer
        $Model = (Get-WmiObject -Class Win32_ComputerSystem).Model
        
        # Clean up manufacturer name
        $Manufacturer = $Manufacturer.Trim().Replace(' Inc.', '').Replace(' Corporation', '').Replace(',', '')
        
        Write-Log "Detected manufacturer: $Manufacturer"
        Write-Log "Detected model: $Model"
        
        return @{
            Manufacturer = $Manufacturer
            Model = $Model
        }
    }
    catch {
        Write-Log "Failed to detect computer model: $_" -Level Error
        return $null
    }
}

# Main script logic
try {
    Write-Log "Starting driver application process"
    Write-Log "Driver package path: $DriverPackagePath"
    
    # Validate driver package path exists
    if (-not (Test-Path -Path $DriverPackagePath)) {
        Write-Log "Driver package path does not exist: $DriverPackagePath" -Level Error
        exit 1
    }
    
    # Get computer model information
    $ComputerInfo = Get-ComputerModel
    
    if ($null -eq $ComputerInfo) {
        Write-Log "Unable to determine computer model. Using generic drivers." -Level Warning
        $DriverPath = Join-Path -Path $DriverPackagePath -ChildPath "Generic"
    }
    else {
        # Construct path to model-specific drivers
        $ManufacturerPath = Join-Path -Path $DriverPackagePath -ChildPath $ComputerInfo.Manufacturer
        
        # Check if manufacturer folder exists
        if (-not (Test-Path -Path $ManufacturerPath)) {
            Write-Log "Manufacturer folder not found: $ManufacturerPath" -Level Warning
            Write-Log "Falling back to generic drivers"
            $DriverPath = Join-Path -Path $DriverPackagePath -ChildPath "Generic"
        }
        else {
            # Check for model-specific driver folder
            $ModelPath = Join-Path -Path $ManufacturerPath -ChildPath $ComputerInfo.Model
            
            if (Test-Path -Path $ModelPath) {
                $DriverPath = $ModelPath
                Write-Log "Using model-specific drivers: $DriverPath"
            }
            else {
                # Check for a "Common" folder as fallback
                $CommonPath = Join-Path -Path $ManufacturerPath -ChildPath "Common"
                
                if (Test-Path -Path $CommonPath) {
                    $DriverPath = $CommonPath
                    Write-Log "Model-specific drivers not found. Using common drivers for manufacturer: $DriverPath"
                }
                else {
                    Write-Log "No specific drivers found for this model. Using generic drivers." -Level Warning
                    $DriverPath = Join-Path -Path $DriverPackagePath -ChildPath "Generic"
                }
            }
        }
    }
    
    # Verify the driver path exists
    if (-not (Test-Path -Path $DriverPath)) {
        Write-Log "Final driver path does not exist: $DriverPath" -Level Error
        exit 1
    }
    
    # Apply drivers
    Write-Log "Applying drivers from: $DriverPath"
    
    $Process = Start-Process -FilePath "pnputil.exe" -ArgumentList "/add-driver", "`"$DriverPath\*.inf`"", "/subdirs", "/install" -NoNewWindow -Wait -PassThru
    
    if ($Process.ExitCode -ne 0) {
        Write-Log "Driver installation failed with exit code $($Process.ExitCode)" -Level Error
        exit $Process.ExitCode
    }
    
    Write-Log "Driver installation completed successfully"
}
catch {
    Write-Log "An error occurred during driver application: $_" -Level Error
    exit 1
}