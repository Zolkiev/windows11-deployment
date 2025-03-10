# Backup User Data Script
# This script is used to backup user data before Windows 11 deployment

# Parameters
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$SourceProfile,
    
    [Parameter(Mandatory=$true)]
    [string]$BackupLocation,
    
    [Parameter(Mandatory=$false)]
    [string[]]$FoldersToBackup = @('Desktop', 'Documents', 'Pictures', 'Downloads')
)

# Script variables
$LogFile = "$env:TEMP\UserDataBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$TimeStamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$BackupFolderName = "UserDataBackup_$TimeStamp"
$BackupPath = Join-Path -Path $BackupLocation -ChildPath $BackupFolderName

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
    Add-Content -Path $LogFile -Value $LogMessage
    
    # Also output to console
    switch ($Level) {
        'Info'    { Write-Host $LogMessage }
        'Warning' { Write-Host $LogMessage -ForegroundColor Yellow }
        'Error'   { Write-Host $LogMessage -ForegroundColor Red }
    }
}

# Main script logic
try {
    Write-Log "Starting user data backup process"
    Write-Log "Source profile: $SourceProfile"
    Write-Log "Backup location: $BackupPath"
    
    # Validate source profile exists
    if (-not (Test-Path -Path $SourceProfile)) {
        Write-Log "Source profile path does not exist: $SourceProfile" -Level Error
        exit 1
    }
    
    # Create backup folder
    if (-not (Test-Path -Path $BackupPath)) {
        Write-Log "Creating backup folder: $BackupPath"
        New-Item -Path $BackupPath -ItemType Directory -Force | Out-Null
    }
    
    # Backup each specified folder
    foreach ($Folder in $FoldersToBackup) {
        $SourceFolder = Join-Path -Path $SourceProfile -ChildPath $Folder
        $DestFolder = Join-Path -Path $BackupPath -ChildPath $Folder
        
        if (Test-Path -Path $SourceFolder) {
            Write-Log "Backing up $Folder folder"
            
            # Create destination folder
            if (-not (Test-Path -Path $DestFolder)) {
                New-Item -Path $DestFolder -ItemType Directory -Force | Out-Null
            }
            
            # Copy files
            Copy-Item -Path "$SourceFolder\*" -Destination $DestFolder -Recurse -Force
            
            Write-Log "Completed backup of $Folder folder"
        } else {
            Write-Log "Source folder does not exist: $SourceFolder" -Level Warning
        }
    }
    
    Write-Log "User data backup completed successfully"
    Write-Log "Backup stored at: $BackupPath"
} catch {
    Write-Log "An error occurred during backup: $_" -Level Error
    exit 1
}