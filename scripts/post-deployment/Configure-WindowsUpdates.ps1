# Configure Windows Update for Business Settings
# This script configures Windows Update for Business settings for Windows 11

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [ValidateSet('Preview', 'Normal', 'Extended')]
    [string]$UpdateChannel = 'Normal',
    
    [Parameter(Mandatory=$false)]
    [int]$QualityUpdateDeferralDays = 7,
    
    [Parameter(Mandatory=$false)]
    [int]$FeatureUpdateDeferralDays = 60,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('NotConfigured', 'Enabled', 'Disabled')]
    [string]$AutoRestartNotification = 'Enabled',
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('Automatic', 'ScheduledTime', 'WindowsUpdateForBusinessConfig')]
    [string]$UpdateManagementMethod = 'WindowsUpdateForBusinessConfig',
    
    [Parameter(Mandatory=$false)]
    [string]$LogPath = "$env:TEMP\Windows-Update-Configuration.log"
)

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

# Main script
try {
    Write-Log "Starting Windows Update configuration"
    Write-Log "Update Channel: $UpdateChannel"
    Write-Log "Quality Update Deferral Days: $QualityUpdateDeferralDays"
    Write-Log "Feature Update Deferral Days: $FeatureUpdateDeferralDays"
    Write-Log "Auto Restart Notification: $AutoRestartNotification"
    Write-Log "Update Management Method: $UpdateManagementMethod"
    
    # Check if running as administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Log "Script must be run as administrator" -Level Error
        exit 1
    }
    
    # Create registry path if it doesn't exist
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
        Write-Log "Created registry path: $registryPath"
    }
    
    $auRegistryPath = "$registryPath\AU"
    if (-not (Test-Path $auRegistryPath)) {
        New-Item -Path $auRegistryPath -Force | Out-Null
        Write-Log "Created registry path: $auRegistryPath"
    }
    
    # Configure update channel based on parameter
    switch ($UpdateChannel) {
        'Preview' {
            # Windows Insider Preview
            New-ItemProperty -Path $registryPath -Name "BranchReadinessLevel" -Value 2 -PropertyType DWord -Force | Out-Null
            Write-Log "Set update channel to Preview (Windows Insider)"
        }
        'Normal' {
            # General Availability Channel
            New-ItemProperty -Path $registryPath -Name "BranchReadinessLevel" -Value 0 -PropertyType DWord -Force | Out-Null
            Write-Log "Set update channel to Normal (General Availability)"
        }
        'Extended' {
            # Long-Term Servicing Channel
            New-ItemProperty -Path $registryPath -Name "BranchReadinessLevel" -Value 1 -PropertyType DWord -Force | Out-Null
            Write-Log "Set update channel to Extended (LTSC)"
        }
    }
    
    # Configure deferral periods
    New-ItemProperty -Path $registryPath -Name "DeferQualityUpdates" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "DeferQualityUpdatesPeriodInDays" -Value $QualityUpdateDeferralDays -PropertyType DWord -Force | Out-Null
    Write-Log "Set quality update deferral period to $QualityUpdateDeferralDays days"
    
    New-ItemProperty -Path $registryPath -Name "DeferFeatureUpdates" -Value 1 -PropertyType DWord -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "DeferFeatureUpdatesPeriodInDays" -Value $FeatureUpdateDeferralDays -PropertyType DWord -Force | Out-Null
    Write-Log "Set feature update deferral period to $FeatureUpdateDeferralDays days"
    
    # Configure auto-restart notifications
    switch ($AutoRestartNotification) {
        'NotConfigured' {
            Remove-ItemProperty -Path $registryPath -Name "SetAutoRestartNotificationConfig" -Force -ErrorAction SilentlyContinue
            Write-Log "Auto-restart notification set to Not Configured"
        }
        'Enabled' {
            New-ItemProperty -Path $registryPath -Name "SetAutoRestartNotificationConfig" -Value 1 -PropertyType DWord -Force | Out-Null
            Write-Log "Auto-restart notification set to Enabled"
        }
        'Disabled' {
            New-ItemProperty -Path $registryPath -Name "SetAutoRestartNotificationConfig" -Value 0 -PropertyType DWord -Force | Out-Null
            Write-Log "Auto-restart notification set to Disabled"
        }
    }
    
    # Configure update management method
    switch ($UpdateManagementMethod) {
        'Automatic' {
            New-ItemProperty -Path $auRegistryPath -Name "AUOptions" -Value 3 -PropertyType DWord -Force | Out-Null
            New-ItemProperty -Path $auRegistryPath -Name "NoAutoUpdate" -Value 0 -PropertyType DWord -Force | Out-Null
            Write-Log "Set update management method to Automatic"
        }
        'ScheduledTime' {
            New-ItemProperty -Path $auRegistryPath -Name "AUOptions" -Value 4 -PropertyType DWord -Force | Out-Null
            New-ItemProperty -Path $auRegistryPath -Name "NoAutoUpdate" -Value 0 -PropertyType DWord -Force | Out-Null
            New-ItemProperty -Path $auRegistryPath -Name "ScheduledInstallDay" -Value 0 -PropertyType DWord -Force | Out-Null
            New-ItemProperty -Path $auRegistryPath -Name "ScheduledInstallTime" -Value 3 -PropertyType DWord -Force | Out-Null
            Write-Log "Set update management method to Scheduled Time (every day at 3 AM)"
        }
        'WindowsUpdateForBusinessConfig' {
            New-ItemProperty -Path $auRegistryPath -Name "AUOptions" -Value 5 -PropertyType DWord -Force | Out-Null
            New-ItemProperty -Path $auRegistryPath -Name "NoAutoUpdate" -Value 0 -PropertyType DWord -Force | Out-Null
            Write-Log "Set update management method to Windows Update for Business Configuration"
        }
    }
    
    # Configure other common settings
    # Allow Microsoft Update
    New-ItemProperty -Path $auRegistryPath -Name "AllowMUUpdateService" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Log "Enabled Microsoft Update service"
    
    # Enable updates for other Microsoft products
    New-ItemProperty -Path $registryPath -Name "EnableFeaturedSoftware" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Log "Enabled updates for other Microsoft products"
    
    # Specify target feature update version (uncomment and modify if needed)
    # New-ItemProperty -Path $registryPath -Name "TargetReleaseVersion" -Value 1 -PropertyType DWord -Force | Out-Null
    # New-ItemProperty -Path $registryPath -Name "TargetReleaseVersionInfo" -Value "22H2" -PropertyType String -Force | Out-Null
    # Write-Log "Set target feature update version to 22H2"
    
    Write-Log "Windows Update configuration completed successfully"
    
} catch {
    Write-Log "An error occurred while configuring Windows Update: $_" -Level Error
    exit 1
}